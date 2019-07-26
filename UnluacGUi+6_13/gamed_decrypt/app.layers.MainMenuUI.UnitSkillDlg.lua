local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local SkillInfoManager = require("app.info.SkillInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local UserDataManager = require("app.UserDataManager")
local UnitDataManager = require("app.UnitDataManager")
local TouchIcon = require("app.widgets.TouchIcon")
local UnitSkillDlg = class("UnitSkillDlg", BaseDlg)
local CostItemId = 20006
function UnitSkillDlg:ctor(soldierId)
  UnitSkillDlg.super.ctor(self, 200)
  self.m_soldierId = soldierId
  self.soldierData = UnitDataManager:GetInstance():GetSoldierData(soldierId)
  self.m_skillId = self.soldierData.soldierInfo.skill[1]
  self:InitUI()
end
function UnitSkillDlg:onEnter()
  UnitSkillDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UpSoldierSkill, handler(self, self.SkillUpgradeSuccess))
  self:AddEvents()
end
function UnitSkillDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.UpSoldierSkill)
  UnitSkillDlg.super.onExit(self)
end
function UnitSkillDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/UnitSkillDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:SetTitle(td.Word_Path .. "wenzi_shengji.png")
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self:AddCloseTip()
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_21")
  label:setString(g_LM:getBy("a00389") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_21_0")
  label:setString(g_LM:getBy("a00390") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_21_0_0")
  label:setString(g_LM:getBy("a00082") .. ":")
  self.pBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_3")
  td.BtnSetTitle(self.pBtn, g_LM:getBy("a00025"))
  td.BtnAddTouch(self.pBtn, function()
    local bEnable, errorCode = self:CheckCanUpgrade()
    if bEnable then
      self:SendCampSkillRequest()
    else
      td.alertErrorMsg(errorCode)
    end
  end, nil, td.ButtonEffectType.Short)
  self:RefreshUI()
end
function UnitSkillDlg:RefreshUI()
  local bEnable, errorCode = self:CheckCanUpgrade()
  if bEnable then
    td.EnableButton(self.pBtn, true)
  else
    td.EnableButton(self.pBtn, false)
  end
  local skillInfo = SkillInfoManager:GetInstance():GetInfo(self.m_skillId)
  local skillLevelInfo = SkillInfoManager:GetInstance():GetSoldierSkillInfo(self.m_skillId)
  local skillIcon = cc.uiloader:seekNodeByName(self.m_bg, "Image_icon")
  skillIcon:loadTexture(skillInfo.icon .. td.PNG_Suffix)
  local nameLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_name")
  nameLabel:setString(skillInfo.name)
  local skillLevel = self.soldierData.skill_level
  local levelLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_level")
  levelLabel:setString("LV." .. skillLevel)
  local needLevel = (self.soldierData.skill_level - 1) * 2
  local needLevelLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_need_level")
  needLevelLabel:setString("LV." .. needLevel)
  if needLevel > self.soldierData.level then
    needLevelLabel:setColor(td.RED)
  end
  local matIcon = TouchIcon.new(CostItemId)
  matIcon:pos(418, 168):scale(0.5):addTo(self.m_bg)
  self:RefreshNeedItem(CostItemId)
  if skillLevelInfo then
    local skillContent = skillInfo.desc
    for i, var in ipairs(skillLevelInfo.variable[skillLevel]) do
      skillContent = string.gsub(skillContent, "{" .. i .. "}", "#" .. var .. "#")
    end
    local textData = {}
    local vStr = string.split(skillContent, "#")
    for i, var in ipairs(vStr) do
      if i % 2 == 1 then
        table.insert(textData, {
          type = 1,
          color = td.LIGHT_BLUE,
          size = 18,
          str = var
        })
      else
        table.insert(textData, {
          type = 1,
          color = td.YELLOW,
          size = 18,
          str = var
        })
      end
    end
    if self.m_conLabel then
      self.m_conLabel:removeFromParent()
      self.m_conLabel = nil
    end
    self.m_conLabel = td.RichText(textData, cc.size(320, 0))
    self.m_conLabel:align(display.LEFT_TOP, 190, 335):addTo(self.m_bg)
  end
end
function UnitSkillDlg:RefreshNeedItem()
  local haveMatNum = UserDataManager:GetInstance():GetItemNum(CostItemId)
  local needNum = self:GetUpgradeNeedNum(self.soldierData.skill_level)
  local needMatLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_need_mat")
  needMatLabel:setString(string.format("%d/%d", haveMatNum, needNum))
  if haveMatNum < needNum then
    needMatLabel:setColor(td.RED)
  else
    needMatLabel:setColor(td.WHITE)
  end
  local bEnable, errorCode = self:CheckCanUpgrade()
  if bEnable then
    td.EnableButton(self.pBtn, true)
  else
    td.EnableButton(self.pBtn, false)
  end
end
function UnitSkillDlg:CheckCanUpgrade()
  local skillLevelInfo = SkillInfoManager:GetInstance():GetSoldierSkillInfo(self.m_skillId)
  local skillLevel = self.soldierData.skill_level + 1
  local needLevel = (self.soldierData.skill_level - 1) * 2
  local haveMatNum = UserDataManager:GetInstance():GetItemNum(CostItemId)
  if not skillLevelInfo.variable[skillLevel] or skillLevelInfo.variable[skillLevel][1] == "" then
    return false, td.ErrorCode.LEVEL_MAX
  elseif self.soldierData.star < 4 then
    return false, td.ErrorCode.STAR_LOW
  elseif needLevel > self.soldierData.level then
    return false, td.ErrorCode.LEVEL_LOW
  elseif haveMatNum < self:GetUpgradeNeedNum(self.soldierData.skill_level) then
    return false, td.ErrorCode.MATERIAL_NOT_ENOUGH
  end
  return true
end
function UnitSkillDlg:GetUpgradeNeedNum(curSkillLevel)
  return curSkillLevel * 2
end
function UnitSkillDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      scheduler.performWithDelayGlobal(function()
        self:close()
      end, 0.1)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.SOLDIER_SKILL_UPGRADE, handler(self, self.SkillUpgradeSuccess))
end
function UnitSkillDlg:OnWealthChanged()
  UnitSkillDlg.super.OnWealthChanged(self)
  self:RefreshNeedItem()
end
function UnitSkillDlg:OnItemUpdate()
  UnitSkillDlg.super.OnItemUpdate(self)
  self:RefreshNeedItem()
end
function UnitSkillDlg:SendCampSkillRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.UpSoldierSkill
  Msg.sendData = {
    role_id = self.m_soldierId
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function UnitSkillDlg:SkillUpgradeSuccess(data)
  if data.state == td.ResponseState.Success then
    UnitDataManager:GetInstance():UpdateSoldierSkill(self.m_soldierId)
    self:RefreshUI()
    local headIcon = cc.uiloader:seekNodeByName(self.m_bg, "Image_icon")
    td.CreateUIEffect(headIcon, "Spine/UI_effect/UI_iconshengji_01")
  else
    td.alertDebug("\229\141\135\231\186\167\229\164\177\232\180\165")
  end
end
return UnitSkillDlg
