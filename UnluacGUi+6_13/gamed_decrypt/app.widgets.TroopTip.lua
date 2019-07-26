local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local TroopTip = class("TroopTip", function(data)
  if data.bFly then
    return display.newSprite("#UI/battle/flayTag.png")
  end
  return display.newSprite("#UI/battle/combat.png")
end)
local TIMEOFFSET = 2
function TroopTip:ctor(data)
  self.m_data = data
  self.m_bFly = data.bFly
  self.m_iCD = data.waitTime
  self.m_iCDTime = 0
  self.m_bContentTipShow = false
  self.m_pMap = nil
  self:Init()
  self:setNodeEventEnabled(true)
end
function TroopTip:Init()
  local fileName, fileName2
  if self.m_bFly then
    fileName2 = "#UI/battle/flayTagLight.png"
  else
    fileName2 = "#UI/battle/combatLight.png"
  end
  local arrowSpr = display.newSprite("#UI/battle/arrow.png")
  arrowSpr:setTag(1)
  td.AddRelaPos(self, arrowSpr)
  local monstTagLight = display.newSprite(fileName2)
  monstTagLight:setTag(2)
  td.AddRelaPos(self, monstTagLight)
  monstTagLight:setVisible(fasle)
  self.m_selectLight = monstTagLight
  self:CreateCdBar(self)
  self:AdjustSelfDir()
  self:StartAnim(self)
end
function TroopTip:AdjustSelfDir()
  local dir = self.m_data.dir
  local dgr = -90 + dir * 45
  self:getChildByTag(1):setRotation(dgr)
end
function TroopTip:AddToMap(pMap)
  self.m_zorder = td.InMapZOrder.UI
  local pos = pMap:GetMapPath(self.m_data.pathID)[self.m_data.pathIndex]
  if not pos then
    print("TroopTip position error,pathId:" .. self.m_data.pathID .. ",pathIndex:" .. self.m_data.pathIndex)
    td.alertDebug("TroopTip position error,pathId:" .. self.m_data.pathID .. ",pathIndex:" .. self.m_data.pathIndex)
    return
  end
  self.m_pos = pMap:GetPixelPosFromTilePos(PulibcFunc:GetInstance():GetPointForInt(pos))
  self.m_pMap = pMap
  pMap:addChild(self)
  self:setPosition(self.m_pos)
  self:setLocalZOrder(self.m_zorder)
  self:CreateSubTip()
end
function TroopTip:onEnter()
  td.CreateUIEffect(self, "Spine/UI_effect/UI_kezhitishi_01")
  self:AddTouch()
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
  self:scheduleUpdate()
  GameDataManager.GetInstance():SetEndTime(self.m_iCD + TIMEOFFSET)
end
function TroopTip:onExit()
end
function TroopTip:update(dt)
  if self.m_subTip then
    if not self:IsInScene(self.m_pos) then
      if not self.m_subTip:isVisible() then
        self.m_subTip:setVisible(true)
        td.CreateUIEffect(self.m_subTip, "Spine/UI_effect/UI_kezhitishi_01")
      end
      self:AdjustSubTipPos()
      self.m_subTip:getChildByTag(3):setPercentage(self.m_iCDTime / self.m_iCD * 100)
    elseif self.m_subTip:isVisible() then
      self.m_subTip:setVisible(false)
    end
  end
  if display.getRunningScene():IsPause() or self.m_iCD <= 0 or self.m_iCDTime >= self.m_iCD then
    return
  end
  self.m_iCDTime = cc.clampf(self.m_iCDTime + dt, 0, self.m_iCD)
  self:getChildByTag(3):setPercentage(self.m_iCDTime / self.m_iCD * 100)
  if self.m_iCDTime >= self.m_iCD then
    self:TimeOver()
  end
end
function TroopTip:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    if GameDataManager:GetInstance():GetActorCanTouch() then
      local rect = _event:getCurrentTarget():getBoundingBox()
      local pos = cc.p(_touch:getLocation())
      pos = self:getParent():convertToNodeSpace(pos)
      if cc.rectContainsPoint(rect, pos) then
        td.dispatchEvent(td.GUIDE_FINISHED, td.UIModule.BattleScene)
        self:SetContentVisible(not self.m_bContentTipShow)
        return true
      elseif self.m_bContentTipShow then
        self:SetContentVisible(not self.m_bContentTipShow)
        return false
      end
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function TroopTip:CreateCdBar(parent)
  local timerSpr = display.newSprite("#UI/battle/progress.png")
  local progressTimer = cc.ProgressTimer:create(timerSpr)
  progressTimer:setTag(3)
  progressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
  progressTimer:setPercentage(0)
  td.AddRelaPos(parent, progressTimer, -1)
end
function TroopTip:InitContent(pMap, zorder)
  if not self.m_contentTip then
    self.m_contentTip = self:CreateContent()
    pMap:addChild(self.m_contentTip)
    self.m_contentTip:setScale(1 / self.m_contentTip:getParent():getScale() * td.GetAutoScale())
    self.m_contentTip:setLocalZOrder(zorder)
  end
end
function TroopTip:CreateContent()
  local size = cc.size(200, 150)
  local contentTip = display.newScale9Sprite("UI/scale9/shang_dikuang.png", 0, 0, size)
  local infunc1 = function(data)
    local node = data.node
    data.parent:addChild(node)
    node:setAnchorPoint(data.ancPos)
    node:setPosition(data.pos)
  end
  local pos = cc.p(size.width * 0.5, size.height)
  local pLabel = td.CreateLabel(g_LM:getBy("a00117"), td.YELLOW, 18, td.OL_BLACK, 2)
  pos.y = pos.y - 25
  infunc1({
    node = pLabel,
    parent = contentTip,
    pos = pos,
    ancPos = cc.p(0.5, 0.5)
  })
  local pLine = display.newSprite("UI/common/guang_fengexian.png")
  pLine:setScaleX(0.5)
  pos.y = pos.y - 15
  infunc1({
    node = pLine,
    parent = contentTip,
    pos = pos,
    ancPos = cc.p(0.5, 0.5)
  })
  pos.y = pos.y - 20
  local lineH = 40
  local pActorInfoManager = require("app.info.ActorInfoManager").GetInstance()
  for i, value in ipairs(self.m_data.monstInfo) do
    local value = self.m_data.monstInfo[i]
    local monstData = pActorInfoManager:GetMonsterInfo(value.monstId)
    local textData = {}
    if td.CAREER_ICON[monstData.career] then
      local iconSpr = td.CreateCareerIcon(monstData.career)
      iconSpr:scale(0.5)
      table.insert(textData, {type = 3, node = iconSpr})
    end
    table.insert(textData, {
      type = 1,
      color = td.WHITE,
      size = 18,
      str = monstData.name .. " x" .. value.monstNum
    })
    local pLabel = td.RichText(textData)
    infunc1({
      node = pLabel,
      parent = contentTip,
      pos = pos,
      ancPos = cc.p(0.5, 0.5)
    })
    pos.y = pos.y - lineH
  end
  local arrow = display.newSprite("UI/common/bantoumingjiantou.png", 0, 0, size)
  arrow:setTag(1)
  infunc1({
    node = arrow,
    parent = contentTip,
    pos = cc.p(size.width / 2, size.height / 2),
    ancPos = cc.p(0.5, 0.5)
  })
  return contentTip
end
function TroopTip:SetContentVisible(_visible)
  if _visible then
    self:InitContent(self:getParent(), self.m_zorder)
    local size = self.m_contentTip:getContentSize()
    local offset = 70
    local offset2 = 20
    local xOffset = size.width * 0.5 + offset + offset2
    local realPos = clone(self.m_pos)
    local arrow = self.m_contentTip:getChildByTag(1)
    arrow:setFlippedX(false)
    local pos = self.m_pMap:GetTileMap():convertToWorldSpace(realPos)
    local pos2 = cc.p(0, size.height * 0.5)
    if pos.x < display.width / 2 then
      realPos.x = realPos.x + xOffset
      pos2.x = pos2.x - offset2
      arrow:setFlippedX(true)
    else
      realPos.x = realPos.x - xOffset
      pos2.x = pos2.x + offset2 + size.width
    end
    self.m_contentTip:setPosition(realPos)
    arrow:setPosition(pos2)
  elseif self.m_contentTip then
    self.m_contentTip:removeFromParent()
    self.m_contentTip = nil
  end
  self.m_selectLight:setVisible(_visible)
  self.m_bContentTipShow = _visible
end
function TroopTip:TimeOver()
  td.dispatchEvent(td.TROOP_TIME_OVER, {
    index = self.m_data.index
  })
  self:unscheduleUpdate()
  self:performWithDelay(function()
    self:RemoveOther()
    self:removeFromParent()
  end, 0.1)
end
function TroopTip:RemoveOther()
  if self.m_subTip then
    self.m_subTip:removeFromParent(true)
    self.m_subTip = nil
  end
  if self.m_subContentTip then
    self.m_subContentTip:removeFromParent(true)
    self.m_subContentTip = nil
  end
  if self.m_contentTip then
    self.m_contentTip:removeFromParent(true)
    self.m_contentTip = nil
  end
end
function TroopTip:StartAnim(node)
  local oriScale = node:getScale()
  local duration = 0.6
  local action = cca.repeatForever(cca.seq({
    cca.scaleTo(duration, 1.1 * oriScale),
    cca.scaleTo(duration, 0.95 * oriScale)
  }))
  node:runAction(action)
end
function TroopTip:IsInScene(pos)
  pos = self.m_pMap:GetTileMap():convertToWorldSpace(pos)
  if pos.x < 0 or pos.x > display.width or 0 > pos.y or pos.y > display.height then
    return false
  end
  return true
end
function TroopTip:CreateSubTip()
  local uiLayer = display.getRunningScene():GetUILayer()
  if self.m_bFly then
    self.m_subTip = display.newSprite("#UI/battle/flayTag.png")
  else
    self.m_subTip = display.newSprite("#UI/battle/combat.png")
  end
  self.m_subTip:setScale(td.GetAutoScale())
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    if GameDataManager:GetInstance():GetActorCanTouch() and self.m_subTip:isVisible() then
      local rect = _event:getCurrentTarget():getBoundingBox()
      local pos = cc.p(_touch:getLocation())
      pos = self.m_subTip:getParent():convertToNodeSpace(pos)
      if cc.rectContainsPoint(rect, pos) or self.m_subContentTip then
        return true
      end
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    if self.m_subContentTip then
      self.m_subContentTip:removeFromParent()
      self.m_subContentTip = nil
    else
      local autoScale = td.GetAutoScale()
      self.m_subContentTip = self:CreateContent()
      self.m_subContentTip:setScale(autoScale)
      local subTipPos = cc.p(self.m_subTip:getPosition())
      local arrow = self.m_subContentTip:getChildByTag(1)
      arrow:setFlippedX(false)
      if subTipPos.x < display.width / 2 then
        self.m_subContentTip:setPosition(subTipPos.x + 160 * autoScale, subTipPos.y)
        arrow:setFlippedX(true)
        arrow:setPositionX(-20)
      else
        self.m_subContentTip:setPosition(subTipPos.x - 160 * autoScale, subTipPos.y)
        arrow:setPositionX(220)
      end
      self.m_subContentTip:addTo(self.m_subTip:getParent(), 100)
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.m_subTip)
  local arrowSpr = display.newSprite("#UI/battle/arrow.png")
  td.AddRelaPos(self.m_subTip, arrowSpr)
  arrowSpr:setTag(1)
  self.m_subTip:setPosition(self.m_pMap:GetTileMap():convertToWorldSpace(self.m_pos))
  uiLayer.m_uiRoot:addChild(self.m_subTip, -1)
  self:CreateCdBar(self.m_subTip)
  self:StartAnim(self.m_subTip)
  self.m_subTip:setVisible(false)
end
function TroopTip:AdjustSubTipPos()
  local oriPos = self.m_pMap:GetTileMap():convertToWorldSpace(self.m_pos)
  local newPos = clone(oriPos)
  local autoScale = td.GetAutoScale()
  newPos.x = cc.clampf(newPos.x, 50 * autoScale, display.width - 50 * autoScale)
  newPos.y = cc.clampf(newPos.y, display.height * 0.25, display.height * 0.85)
  self.m_subTip:setPosition(newPos)
  local pNormal = cc.pSub(oriPos, newPos)
  local angle = cc.pGetAngle(pNormal, cc.p(0, 1)) * 180 / math.pi
  self.m_subTip:getChildByTag(1):setRotation(angle)
end
return TroopTip
