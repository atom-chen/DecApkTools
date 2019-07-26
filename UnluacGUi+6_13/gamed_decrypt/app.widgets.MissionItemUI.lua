local MissionInfoManager = require("app.info.MissionInfoManager")
local UserDataManager = require("app.UserDataManager")
local MissionItemUI = class("MissionItemUI", function()
  return display.newLayer()
end)
local BOSS_CITY = {
  11,
  23,
  31
}
function MissionItemUI:ctor()
  self.m_cityId = 0
  self.m_missionId = 0
  self.m_eState = nil
  self:InitUI()
  self:setContentSize(cc.size(80, 80))
end
function MissionItemUI:onEnter()
end
function MissionItemUI:onExit()
end
function MissionItemUI:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/CheckpointItem.csb")
  self:addChild(self.m_uiRoot, 1)
  self.m_touchNode = self.m_uiRoot:getChildByTag(1)
  self.btnFight = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_fight")
  td.BtnAddTouch(self.btnFight, handler(self, self.GoToMission))
end
function MissionItemUI:GoToMission()
  g_MC:OpenModule(td.UIModule.MissionDetail, self.m_occupMissionId)
end
function MissionItemUI:initMissonItem(value, handler, posType)
  if not value then
    return
  end
  self.m_missionId = value.missionId
  self.m_cityId = math.floor(self.m_missionId % 1000)
  local info = MissionInfoManager:GetInstance():GetMissionInfo(self.m_missionId)
  local fileName
  if table.indexof(BOSS_CITY, self.m_cityId) then
    fileName = "Spine/UI_effect/UI_bossguanka_02"
  else
    fileName = "Spine/UI_effect/UI_guanqiatubiao_02"
  end
  local pTmpNode = self.m_touchNode:getChildByTag(5)
  self.m_pSpriTag = SkeletonUnit:create(fileName)
  if self.m_pSpriTag then
    self.m_pSpriTag:setScale(0.4)
    pTmpNode:getParent():addChild(self.m_pSpriTag, -1)
    self.m_pSpriTag:setPosition(cc.p(pTmpNode:getPosition()))
    self.m_pSpriTag:PlayAni("animation", true)
  end
  local cityName = g_LM:getBy(info.name)
  posType = posType or 3
  local tmpLabel = td.CreateLabel(cityName, td.WHITE, 15, td.OL_BLACK)
  if 0 == posType then
    tmpLabel:setAnchorPoint(cc.p(1, 0.5))
    self.m_touchNode:addChild(tmpLabel)
    tmpLabel:setPosition(cc.p(0, 20))
  elseif 1 == posType then
    tmpLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_touchNode:addChild(tmpLabel)
    tmpLabel:setPosition(cc.p(20, 50))
  elseif 2 == posType then
    tmpLabel:setAnchorPoint(cc.p(0, 0.5))
    self.m_touchNode:addChild(tmpLabel)
    tmpLabel:setPosition(cc.p(40, 20))
  else
    tmpLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_touchNode:addChild(tmpLabel)
    tmpLabel:setPosition(cc.p(20, -10))
  end
  tmpLabel:setTag(2)
  tmpLabel:setVisible(false)
  local touchNode = self:GetTouchNode()
  touchNode:addTouchEventListener(handler)
  touchNode:setSwallowTouches(false)
  touchNode:setTouchEnabled(true)
  touchNode:setTag(math.floor(self.m_missionId % 1000))
  self:CheckState()
end
function MissionItemUI:UpdateState(occupState)
  if self.m_eState == occupState then
    return
  end
  self.m_eState = occupState
  local showFGTip = false
  if self.m_eState == td.OccupState.Occupieding then
    self:LightAnim("animation02")
    showFGTip = true
  else
    if self.m_eState == td.OccupState.Occupieded then
      self:LightAnim("animation02")
      showFGTip = true
    else
    end
  end
  if showFGTip then
    self.btnFight:setVisible(true)
    self.btnFight:stopAllActions()
    self.btnFight:setPositionY(5)
    self.btnFight:runAction(cca.repeatForever(cca.seq({
      cca.moveBy(1, 0, 10),
      cca.moveBy(1, 0, -10)
    })))
  else
    self.btnFight:setVisible(false)
  end
end
function MissionItemUI:CheckState()
  local udMng = UserDataManager:GetInstance()
  local occupState = td.OccupState.Normal
  for i = 1, 3 do
    local missionData = udMng:GetInstance():GetCityData(i * 1000 + self.m_cityId)
    if missionData and missionData.occupation ~= td.OccupState.Normal then
      self.m_occupMissionId = i * 1000 + self.m_cityId
      occupState = missionData.occupation
      break
    end
  end
  self:UpdateState(occupState)
end
function MissionItemUI:GetTouchNode()
  return self.m_touchNode
end
function MissionItemUI:ShowCityName(isShow)
  self.m_touchNode:getChildByTag(2):setVisible(isShow)
end
function MissionItemUI:createMissonItemAnim()
  local pShuijin = self.m_touchNode:getChildByTag(5)
  local duration = 1 + math.random()
  local action1 = self.createAnim1(nil, duration)
  pShuijin:runAction(action1)
end
function MissionItemUI.createAnim1(yOffset, duration)
  if yOffset == nil then
    yOffset = 10
  end
  if duration == nil then
    duration = 1 + math.random()
  end
  local toScale = 0.4
  local easeRate = 1.4
  local delay = 0.2
  local fromScale = 1
  local actionSeq1 = cc.Sequence:create(cc.EaseIn:create(cc.MoveBy:create(duration, cc.p(0, yOffset)), easeRate), cc.DelayTime:create(delay), cc.EaseIn:create(cc.MoveBy:create(duration, cc.p(0, -yOffset)), easeRate), cc.DelayTime:create(delay))
  local action1 = cc.RepeatForever:create(actionSeq1)
  return action1
end
function MissionItemUI:LightAnim(animName)
  if self.m_pSpriTag then
    self.m_pSpriTag:PlayAni(animName, true, false)
  end
end
return MissionItemUI
