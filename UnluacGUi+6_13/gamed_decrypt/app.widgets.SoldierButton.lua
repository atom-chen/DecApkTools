local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local GuideManager = require("app.GuideManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local UnitDataManager = require("app.UnitDataManager")
local SoldierButton = class("SoldierButton", function(index)
  return display.newSprite("UI/battle/yingxiongkuang_0.png")
end)
SoldierButton.BtnType = {
  BRANCH_1 = 7,
  BRANCH_2 = 8,
  UPGRADE = 9
}
function SoldierButton:ctor(index)
  self.m_index = index
  self.m_soldierId = 0
  self.m_iCD = 0
  self.m_iSpace = 0
  self.m_iNum = 0
  self.m_pHead = nil
  self.numLabel = nil
  self.m_careerIcon = nil
  self.m_bIsEnable = false
  self.m_isActive = false
  self:Init()
  self:setNodeEventEnabled(true)
end
function SoldierButton:onEnter()
  self:AddTouch()
end
function SoldierButton:Init()
  self:setScale(0.85)
  local conSize = self:getContentSize()
  self.bg = display.newSprite("#UI/battle/xiaobingkuang2.png")
  self.bg:pos(conSize.width / 2, conSize.height * 0.5):scale(1.2)
  self.bg:addTo(self, -4)
  self.numLabel = td.CreateLabel("0", nil, 16)
  td.AddRelaPos(self, self.numLabel, 1, cc.p(0.5, 0.1))
  self.m_door = SkeletonUnit:create("Spine/UI_effect/EFT_zhandoumen_01")
  self.m_door:scale(1.2)
  td.AddRelaPos(self, self.m_door, -1)
  self.m_seleSpr = display.newSprite("UI/scale9/xiaobingxuanzhongkuang.png")
  self.m_seleSpr:setVisible(false)
  self.m_seleSpr:scale(1.2)
  td.AddRelaPos(self, self.m_seleSpr, 0, cc.p(0.5, 0.55))
  self.m_careerBg = display.newSprite("#UI/battle/zhiyedikuang.png")
  self.m_careerBg:pos(25, conSize.height - 25):addTo(self)
  self:CreateCdBar()
end
function SoldierButton:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    if not g_MC:GetEnableUI() or not td.IsVisible(self) then
      return false
    end
    local rect = self.bg:getBoundingBox()
    local pos = _touch:getLocation()
    pos = self:convertToNodeSpace({
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
        self:onTouchMoved(_touch:getLocation())
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
        td.dispatchEvent(td.GUIDE_FINISHED, td.UIModule.BattleUI)
      end
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function SoldierButton:onTouchBegan()
  if self.m_bIsEnable then
    self.m_seleSpr:setVisible(true)
  end
  g_MC:UpdateOpTime()
end
function SoldierButton:onTouchMoved(_pos)
  if GuideManager:GetInstance():IsGuidingSoldier() then
    return
  end
  local pos = self:convertToNodeSpace(cc.p(_pos.x, _pos.y))
  if self.m_skeleton then
    self.m_skeleton:setPosition(pos)
  else
    self.m_skeleton = SkeletonUnit:create("Spine/UI_effect/EFT_biaoji_01")
    self.m_skeleton:setScale(0.5)
    self.m_skeleton:PlayAni("animation", true)
    self.m_skeleton:setPosition(pos)
    self.m_skeleton:addTo(self, 0)
  end
  g_MC:UpdateOpTime()
end
function SoldierButton:onTouchEnded(_pos)
  if GuideManager:GetInstance():IsGuidingSoldier() then
    self.m_seleSpr:setVisible(false)
    return
  end
  self.m_seleSpr:setVisible(false)
  self:AddSoldier(_pos)
  if self.m_skeleton then
    self.m_skeleton:removeFromParent()
    self.m_skeleton = nil
  end
end
function SoldierButton:UpdateSelf()
  local gdMng = GameDataManager:GetInstance()
  self.m_soldierId = gdMng:GetCampRole(self.m_index)
  if not self.m_soldierId then
    return
  end
  local soldierInfo = ActorInfoManager:GetInstance():GetSoldierInfo(self.m_soldierId)
  self.m_iCD = soldierInfo.role_cd
  self.m_iSpace = soldierInfo.space
  self.m_iNum = gdMng:GetSoldierNum(self.m_soldierId)
  self.numLabel:setString(tostring(self.m_iNum))
  if self.m_pHead then
    self.m_pHead:setTexture(cc.Director:getInstance():getTextureCache():addImage(soldierInfo.head .. td.PNG_Suffix))
  else
    self.m_pHead = display.newSprite(soldierInfo.head .. td.PNG_Suffix)
    td.AddRelaPos(self, self.m_pHead, -2)
    self.m_bIsEnable = true
    self.m_door:PlayAni("animation", false)
  end
  self:ShowFlash()
  if not self.m_careerIcon then
    self.m_careerIcon = display.newSprite(td.CAREER_ICON[soldierInfo.career]):scale(0.55)
    td.AddRelaPos(self.m_careerBg, self.m_careerIcon)
    td.setTexture(self, "UI/battle/yingxiongkuang_" .. soldierInfo.career .. ".png")
  end
end
function SoldierButton:ShowFlash()
  local conSize = self:getContentSize()
  td.CreateUIEffect(self, "Spine/UI_effect/UI_iconchuxian_01", {
    zorder = 10,
    pos = cc.p(conSize.width * 0.5, conSize.height * 0.5)
  })
end
function SoldierButton:Reset()
  if self.m_pHead then
    self.m_pHead:removeFromParent()
    self.m_pHead = nil
  end
  self.m_bIsEnable = false
  self.m_careerIcon:removeFromParent()
  self.m_careerIcon = nil
  self.m_door:removeFromParent()
  self.m_door = SkeletonUnit:create("Spine/UI_effect/EFT_zhandoumen_01")
  self.m_door:scale(1.2)
  td.AddRelaPos(self, self.m_door, -1)
  self:CreateCdBar()
end
function SoldierButton:CreateCdBar()
  local timerSpr = display.newSprite("UI/common/mask_80.png")
  timerSpr:setColor(display.COLOR_BLACK)
  local progressTimer = cc.ProgressTimer:create(timerSpr)
  self.m_pProgressTimer = progressTimer
  progressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
  progressTimer:setPercentage(0)
  progressTimer:setPosition(0, 5)
  self.m_door:addChild(progressTimer, 1)
  local sSize = cc.size(78, 78)
  local tSize = timerSpr:getContentSize()
  progressTimer:setScaleX(sSize.width / tSize.width)
  progressTimer:setScaleY(sSize.height / tSize.height)
end
function SoldierButton:PlayCD()
  self.m_bIsEnable = false
  self.m_pProgressTimer:runAction(cca.seq({
    cca.progressFromTo(self.m_iCD, 100, 0),
    cca.cb(function()
      self.m_bIsEnable = true
      td.CreateUIEffect(self.m_pHead, "Spine/UI_effect/UI_CDwancheng_01", {scale = 1.2})
    end)
  }))
end
function SoldierButton:CheckCanAddSoldier(_pos)
  local gdMng = GameDataManager:GetInstance()
  local curPopu = gdMng:GetCurPopulation()
  local maxPopu = gdMng:GetMaxPopulation()
  if maxPopu < curPopu + self.m_iSpace then
    return false, td.ErrorCode.POPU_MAX
  elseif self.m_iNum <= 0 then
    return false, td.ErrorCode.POPU_LACK
  end
  if _pos then
    local pMap = gdMng:GetGameMap()
    local childPos = pMap:GetMapPosFromWorldPos(_pos)
    local tilePos = pMap:GetTilePosFromPixelPos(childPos)
    local home = ActorManager:GetInstance():FindHome(false)
    if home and home:IsInEllipse(childPos) then
      return false, g_LM:getBy("a00176")
    end
    if not pMap:IsWalkable(tilePos) then
      childPos = td.GetValidPos(pMap, {100}, childPos)
      tilePos = pMap:GetTilePosFromPixelPos(childPos)
    end
    local roleBornPos = gdMng:GetBornPos() or childPos
    local camp = ActorManager:GetInstance():FindCamp(self.m_index)
    if camp then
      roleBornPos = camp:GetRoleBornPos()
    end
    pMap:AddPassableRoadType(100)
    local v = pMap:FindPath(roleBornPos, childPos)
    pMap:RemovePassableRoadType(100)
    if table.getn(v) == 0 then
      return false, g_LM:getBy("a00176")
    end
  end
  return true
end
function SoldierButton:AddSoldier(_pos)
  local bCanAdd, errorCode = self:CheckCanAddSoldier(_pos)
  if not bCanAdd then
    td.alertErrorMsg(errorCode)
    return
  end
  local gdMng = GameDataManager:GetInstance()
  local pMap = gdMng:GetGameMap()
  local childPos = pMap:GetMapPosFromWorldPos(_pos)
  local tilePos = pMap:GetTilePosFromPixelPos(childPos)
  if not pMap:IsWalkable(tilePos) then
    childPos = td.GetValidPos(pMap, {100}, childPos)
    tilePos = pMap:GetTilePosFromPixelPos(childPos)
  end
  gdMng:UpdateCurPopulation(self.m_iSpace)
  gdMng:UpdateUnitNum(self.m_soldierId, -1)
  td.dispatchEvent(td.ADD_SOLDIER_EVENT, {
    type = 0,
    index = self.m_index,
    id = self.m_soldierId,
    x = childPos.x,
    y = childPos.y
  })
  self.m_iNum = self.m_iNum - 1
  self.numLabel:setString(self.m_iNum)
  self:PlayCD()
  td.dispatchEvent(td.GUIDE_FINISHED, td.UIModule.BattleScene)
end
function SoldierButton:SetSelected(bSele)
  self.m_seleSpr:setVisible(bSele)
end
function SoldierButton:setEnable(bEnable)
  if bEnable == self.m_bIsEnable then
    return
  end
  self.m_bIsEnable = bEnable
  if bEnable then
    self:setColor(display.COLOR_WHITE)
  else
    self:setColor(td.BTN_PRESSED_COLOR)
  end
end
function SoldierButton:isEnable()
  local bCanAdd = self:CheckCanAddSoldier()
  return self.m_bIsEnable and bCanAdd
end
function SoldierButton:CheckCanUpgrade()
  if self.m_level == 0 then
    return false
  end
  local actorInfoMng = ActorInfoManager:GetInstance()
  local unitMng = UnitDataManager:GetInstance()
  local campInfo = actorInfoMng:GetCampInfo(self.m_type)
  if self.m_level == 1 then
    local soldierInfo = actorInfoMng:GetSoldierInfo(campInfo.level2_role)
    if not unitMng:IsRoleUnlock(soldierInfo.id) then
      return false
    end
  elseif self.m_level == 2 then
    local bIsUnlock = false
    for i = 1, 2 do
      local soldierInfo = actorInfoMng:GetSoldierInfo(campInfo["level3_branch" .. i])
      if unitMng:IsRoleUnlock(soldierInfo.id) then
        bIsUnlock = true
        break
      end
    end
    if not bIsUnlock then
      return false
    end
  elseif self.m_level == 3 then
    local soldierInfo = actorInfoMng:GetSoldierInfo(campInfo["level4_final" .. self.m_branch])
    if not unitMng:IsRoleUnlock(soldierInfo.id) then
      return false
    end
  else
    return false
  end
  return true
end
function SoldierButton:ShowDetail()
  if self.m_pTip then
    self.m_pTip:removeFromParent()
    self.m_pTip = nil
  end
  local conSize = cc.size(300, 190)
  self.m_pTip = display.newScale9Sprite("UI/scale9/tipskuang.png", 0, 0, conSize)
  local tipPos = cc.p(self:getPositionX(), self:getPositionY() + 220)
  if tipPos.x < 160 then
    tipPos.x = 160
  end
  self.m_pTip:setPosition(tipPos)
  self:addChild(self.m_pTip)
  self.m_pTip:setOpacity(0)
  self.m_pTip:runAction(cca.fadeIn(0.3))
  local soldierInfo = ActorInfoManager:GetInstance():GetSoldierInfo(self.m_soldierId)
  local iconSpr = td.CreateCareerIcon(soldierInfo.career)
  iconSpr:scale(0.5)
  local nameLabel = td.RichText({
    {
      type = 1,
      str = soldierInfo.name,
      color = td.LIGHT_GREEN,
      size = 18
    },
    {type = 3, node = iconSpr}
  })
  nameLabel:align(display.LEFT_CENTER, 20, conSize.height - 20):addTo(self.m_pTip)
  local popuLabel = td.RichText({
    {
      type = 2,
      file = "UI/icon/renkou_icon.png",
      scale = 0.7
    },
    {
      type = 1,
      str = string.format(" %d", self.m_iSpace),
      color = td.YELLOW,
      size = 18
    }
  })
  popuLabel:align(display.RIGHT_CENTER, conSize.width - 20, conSize.height - 20):addTo(self.m_pTip)
  local line = display.newSprite("UI/common/fengexian.png")
  line:setScaleX(conSize.width * 0.9)
  line:pos(conSize.width / 2, conSize.height - 40):addTo(self.m_pTip)
  local spineBg = display.newSprite("UI/scale9/lanse_xiaobingkuang.png")
  spineBg:scale(1.2):pos(50, conSize.height - 83):addTo(self.m_pTip)
  local spine = SkeletonUnit:create(soldierInfo.image)
  spine:PlayAni("stand")
  spine:scale(0.3)
  td.AddRelaPos(spineBg, spine, 1, cc.p(0.5, 0.2))
  local posY = conSize.height - 45
  local tmp1 = string.split(soldierInfo.desc, "#")
  local textData = {}
  for i, text in ipairs(tmp1) do
    local label
    if i % 2 == 1 then
      label = td.CreateLabel(text, td.WHITE, 16, nil, nil, cc.size(200, 0))
    else
      label = td.CreateLabel(text, td.YELLOW, 16, nil, nil, cc.size(200, 0))
    end
    label:setAnchorPoint(0, 1)
    label:pos(95, posY):addTo(self.m_pTip)
    posY = posY - label:getContentSize().height
  end
end
function SoldierButton:ActiveFocus()
  GameDataManager:GetInstance():SetActorCanTouch(false)
  if GuideManager:GetInstance():ShouldWeakGuide() then
    display.getRunningScene():GetUILayer():ShowUIMessage(g_LM:getBy("a00218"))
  end
  self.m_seleSpr:setVisible(true)
  self.m_isActive = true
  self:ShowDetail()
end
function SoldierButton:InactiveFocus()
  GameDataManager:GetInstance():SetActorCanTouch(true)
  if GuideManager:GetInstance():ShouldWeakGuide() then
    display.getRunningScene():GetUILayer():ShowUIMessage()
  end
  self.m_seleSpr:setVisible(false)
  self.m_isActive = false
  if self.m_pTip then
    self.m_pTip:removeFromParent()
    self.m_pTip = nil
  end
end
function SoldierButton:DoFocus(_pos)
  self:AddSoldier(_pos)
  GameDataManager:GetInstance():SetFocusNode(nil)
end
return SoldierButton
