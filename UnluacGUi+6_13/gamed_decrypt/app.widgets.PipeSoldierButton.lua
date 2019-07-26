local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local PipeSoldierButton = class("PipeSoldierButton", function(index)
  return display.newSprite("#UI/battle/touxiangkuang.png")
end)
function PipeSoldierButton:ctor(roleId)
  local actorInfo = ActorInfoManager:GetInstance():GetSoldierInfo(roleId)
  self.m_roleId = roleId
  self.m_fileName = actorInfo.head .. td.PNG_Suffix
  self.m_iCost = actorInfo.cost
  self.m_CostLabel = nil
  self.m_uiLayer = nil
  self.m_bIsEnable = false
  self.m_isActive = false
  self:Init()
  self:setNodeEventEnabled(true)
end
function PipeSoldierButton:Init()
  local conSize = self:getContentSize()
  local glassBg = display.newSprite("#UI/battle/touxiangdi.png")
  glassBg:setPosition(conSize.width / 2, conSize.height / 2)
  glassBg:addTo(self, -3)
  local headSpr = display.newSprite(self.m_fileName)
  headSpr:setPosition(conSize.width / 2, conSize.height / 2)
  headSpr:addTo(self, -2)
  self.m_bIsEnable = true
  local iconSpr = display.newSprite(td.FORCE_ICON)
  iconSpr:setAnchorPoint(1, 0.5)
  iconSpr:scale(0.5)
  td.AddRelaPos(self, iconSpr, 10, cc.p(0.3, 0.8))
  self.m_CostLabel = td.CreateLabel(self.m_iCost, td.WHITE, 16, td.OL_BLACK, 1)
  self.m_CostLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self, self.m_CostLabel, 10, cc.p(0.3, 0.8))
end
function PipeSoldierButton:onEnter()
  self:AddTouch()
end
function PipeSoldierButton:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    local rect = _event:getCurrentTarget():getBoundingBox()
    local pos = _touch:getLocation()
    pos = self:getParent():convertToNodeSpace({
      x = pos.x,
      y = pos.y
    })
    if cc.rectContainsPoint(rect, pos) then
      self:onTouchBegan()
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    if not self.m_bIsEnable then
      return
    end
    if not self.m_isActive then
      local rect = _event:getCurrentTarget():getBoundingBox()
      local pos = _touch:getLocation()
      pos = self:getParent():convertToNodeSpace({
        x = pos.x,
        y = pos.y
      })
      if not cc.rectContainsPoint(rect, pos) then
        self:onTouchMoved(pos)
      elseif self.m_skeleton then
        self.m_skeleton:removeFromParent()
        self.m_skeleton = nil
      end
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(_touch, _event)
    if not self.m_bIsEnable then
      return
    end
    if self.m_isActive then
      GameDataManager:GetInstance():SetFocusNode(nil)
    else
      local rect = _event:getCurrentTarget():getBoundingBox()
      local pos = _touch:getLocation()
      pos = self:getParent():convertToNodeSpace({
        x = pos.x,
        y = pos.y
      })
      if not cc.rectContainsPoint(rect, pos) then
        self:onTouchEnded(_touch:getLocation())
      else
        GameDataManager:GetInstance():SetFocusNode(self)
      end
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function PipeSoldierButton:onTouchBegan()
  if not self:getChildByTag(233) then
    local selectedSpr = display.newSprite("#UI/battle/xuanzhongfaguangkuang.png")
    selectedSpr:setTag(233)
    td.AddRelaPos(self, selectedSpr)
  end
end
function PipeSoldierButton:onTouchMoved(_pos)
  local pos = _pos
  if self.m_skeleton then
    self.m_skeleton:setPosition(pos)
  else
    self.m_skeleton = SkeletonUnit:create("Spine/UI_effect/EFT_biaoji_01")
    self.m_skeleton:setScale(0.5)
    self.m_skeleton:PlayAni("animation", true)
    self.m_skeleton:setPosition(pos)
    self.m_skeleton:addTo(self:getParent():getParent(), 10)
  end
end
function PipeSoldierButton:onTouchEnded(_pos)
  if self.m_skeleton then
    self.m_skeleton:removeFromParent()
    self.m_skeleton = nil
  end
  self:AddSoldier(_pos)
end
function PipeSoldierButton:SetUILayer(layer)
  self.m_uiLayer = layer
end
function PipeSoldierButton:AddSoldier(_pos)
  local gdMng = GameDataManager:GetInstance()
  self:removeChildByTag(233)
  local totalRes = gdMng:GetCurResCount()
  local curPopu = gdMng:GetCurPopulation()
  local maxPopu = gdMng:GetMaxPopulation()
  if totalRes < self.m_iCost then
    td.alert(g_LM:getBy("a00174"), true)
    return
  elseif curPopu >= maxPopu then
    td.alert(g_LM:getBy("a00175"), true)
    return
  end
  local pMap = gdMng:GetGameMap()
  local childPos = pMap:GetMapPosFromWorldPos(_pos)
  local validPos = td.GetValidPos(pMap, {100}, childPos)
  local home = ActorManager:GetInstance():FindHome(false)
  if home then
    if home:IsInEllipse(childPos) then
      td.alert(g_LM:getBy("a00176"), true)
      return
    end
    local roleBornPos = cc.p(home:getPosition())
    pMap:AddPassableRoadType(100)
    local v = pMap:FindPath(roleBornPos, validPos)
    pMap:RemovePassableRoadType(100)
    if table.getn(v) == 0 then
      td.alert(g_LM:getBy("a00176"), true)
      return
    end
  end
  local skeleton = SkeletonUnit:create("Spine/UI_effect/EFT_biaoji_01")
  skeleton:setPosition(childPos)
  skeleton:setScale(0.7)
  pMap:addChild(skeleton, pMap:GetPiexlSize().height - childPos.y)
  skeleton:PlayAni("animation01", false)
  skeleton:runAction(cca.seq({
    cca.delay(1.5),
    cca.fadeOut(0.5),
    cca.removeSelf()
  }))
  td.dispatchEvent(td.ADD_SOLDIER_EVENT, {
    type = 1,
    id = self.m_roleId,
    x = validPos.x,
    y = validPos.y
  })
  self:stopAllActions()
  if GameDataManager:GetInstance():GetFocusNode() == self then
    GameDataManager:GetInstance():SetFocusNode(nil)
  end
  self:removeFromParent()
end
function PipeSoldierButton:Disappear()
  if self.m_skeleton then
    self.m_skeleton:removeFromParent()
    self.m_skeleton = nil
  end
  if GameDataManager:GetInstance():GetFocusNode() == self then
    GameDataManager:GetInstance():SetFocusNode(nil)
  end
  self:removeFromParent()
end
function PipeSoldierButton:setEnable(bEnable)
  if bEnable == self.m_bIsEnable then
    return
  end
  self.m_bIsEnable = bEnable
end
function PipeSoldierButton:ActiveFocus()
  GameDataManager:GetInstance():SetActorCanTouch(false)
  self.m_isActive = true
end
function PipeSoldierButton:InactiveFocus()
  GameDataManager:GetInstance():SetActorCanTouch(true)
  self:removeChildByTag(233)
  self.m_isActive = false
end
function PipeSoldierButton:DoFocus(_pos)
  self:AddSoldier(_pos)
end
return PipeSoldierButton
