local TDHttpRequest = require("app.net.TDHttpRequest")
local GuideManager = require("app.GuideManager")
local BaseInfoManager = require("app.info.BaseInfoManager")
local UserDataManager = require("app.UserDataManager")
local BaseDlg = require("app.layers.BaseDlg")
local RichIcon = require("app.widgets.RichIcon")
local BaseSkillDlg = class("BaseSkillDlg", BaseDlg)
BaseSkillDlg.Types = {Mission = 1, Arena = 2}
function BaseSkillDlg:ctor(type)
  BaseSkillDlg.super.ctor(self, 200)
  self.m_uiId = td.UIModule.BaseSkill
  self.m_udMng = UserDataManager:GetInstance()
  self:InitUI()
  self:SetData(type)
end
function BaseSkillDlg:onEnter()
  BaseSkillDlg.super.onEnter(self)
  self:AddBtnEvents()
  self:AddListeners()
  self:CheckGuide()
end
function BaseSkillDlg:onExit()
  self:RemoveListeners()
  BaseSkillDlg.super.onExit(self)
end
function BaseSkillDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/BaseSkillDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_levelLabel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_level")
  self.m_descLabel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_desc")
  self.m_baseLabel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_base_level")
  self.m_costLabel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_cost")
  self.m_icon = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_icon")
  self.m_upBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_upgrade_2")
  td.BtnSetTitle(self.m_upBtn, g_LM:getBy("a00025"))
  local label = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_1_1")
  label:setString(g_LM:getBy("a00373") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_1_1_0")
  label:setString(g_LM:getBy("a00372") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_1_1_1")
  label:setString(g_LM:getBy("a00082") .. ":")
end
function BaseSkillDlg:SetData(type)
  self.m_type = type
  self:RefreshUI()
end
function BaseSkillDlg:RefreshUI()
  local userDetail = self.m_udMng:GetUserDetail()
  local descStr1, valKey = 0, 0
  if self.m_type == BaseSkillDlg.Types.Mission then
    self.skillLevel = userDetail.mission_level
    valKey = "init_force"
    descStr1 = g_LM:getBy("a00370")
    self.m_icon:loadTexture("UI/basecamp/guanqiayuanli_icon.png")
    self.m_descLabel:setString(g_LM:getBy("a00370"))
  else
    self.skillLevel = userDetail.arena_level
    valKey = "arena_resource_max"
    descStr1 = g_LM:getBy("a00371")
    self.m_icon:loadTexture("UI/basecamp/jingjichangyuanli_icon.png")
    self.m_descLabel:setString(g_LM:getBy("a00371"))
  end
  local info = BaseInfoManager:GetInstance():GetBaseInfo(self.skillLevel)
  local nextInfo = BaseInfoManager:GetInstance():GetBaseInfo(self.skillLevel + 1) or info
  self.m_levelLabel:setString("LV." .. self.skillLevel)
  self.m_baseLabel:setString(self.skillLevel + 1)
  if self.m_udMng:GetBaseCampLevel() < self.skillLevel + 1 then
    self.m_baseLabel:setColor(td.RED)
  else
    self.m_baseLabel:setColor(td.WHITE)
  end
  self.m_costLabel:setString("x" .. info.skill_cost)
  if info.skill_cost > self.m_udMng:GetGold() then
    self.m_costLabel:setColor(td.RED)
  else
    self.m_costLabel:setColor(td.WHITE)
  end
  if self.m_nextDescLabel then
    self.m_nextDescLabel:removeFromParent()
  end
  self.m_nextDescLabel = td.RichText({
    {
      type = 1,
      str = descStr1,
      color = cc.c3b(7, 168, 197),
      size = 20
    },
    {
      type = 1,
      str = "" .. info[valKey],
      color = td.GREEN,
      size = 20
    },
    {
      type = 1,
      str = g_LM:getBy("a00374"),
      color = cc.c3b(7, 168, 197),
      size = 20
    },
    {
      type = 1,
      str = "" .. nextInfo[valKey],
      color = td.GREEN,
      size = 20
    }
  })
  self.m_nextDescLabel:align(display.LEFT_CENTER, 255, 265):addTo(self.m_bg)
  self.m_upBtn:setDisable(not self:CheckCanUpgrade())
end
function BaseSkillDlg:AddBtnEvents()
  td.BtnAddTouch(self.m_upBtn, function()
    local info = BaseInfoManager:GetInstance():GetBaseInfo(self.skillLevel + 1)
    local bEnable, errorCode = self:CheckCanUpgrade()
    if bEnable then
      self:SendUpgradeRequest()
      self.m_upBtn:setDisable(true)
    else
      td.EnableButton(self.m_upBtn, false)
      td.alertErrorMsg(errorCode)
    end
  end)
end
function BaseSkillDlg:AddListeners()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(handler(self, self.close), 0.1)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UpgradeMissionRes, handler(self, self.UpgradeCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UpgradeArenaRes, handler(self, self.UpgradeCallback))
end
function BaseSkillDlg:RemoveListeners()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.UpgradeMissionRes)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.UpgradeArenaRes)
end
function BaseSkillDlg:CheckCanUpgrade()
  local info = BaseInfoManager:GetInstance():GetBaseInfo(self.skillLevel)
  local userDetail = UserDataManager:GetInstance():GetUserDetail()
  local currBaseLevel = userDetail.camp
  local currSkillLevel
  if self.m_type == 1 then
    currSkillLevel = userDetail.mission_level
  elseif self.m_type == 2 then
    currSkillLevel = userDetail.arena_level
  end
  if currBaseLevel <= currSkillLevel then
    return false, td.ErrorCode.BASE_LEVEL_LOW
  end
  if not info then
    return false, td.ErrorCode.LEVEL_MAX
  end
  if info.skill_cost > self.m_udMng:GetGold() then
    return false, td.ErrorCode.GOLD_NOT_ENOUGH
  end
  return true, td.ErrorCode.SUCCESS
end
function BaseSkillDlg:SendUpgradeRequest()
  local Msg = {}
  if self.m_type == BaseSkillDlg.Types.Mission then
    Msg.msgType = td.RequestID.UpgradeMissionRes
  else
    Msg.msgType = td.RequestID.UpgradeArenaRes
  end
  TDHttpRequest:getInstance():Send(Msg)
end
function BaseSkillDlg:UpgradeCallback(data)
  if data.state == td.ResponseState.Success then
    self.m_udMng:UpdateBaseSkill(self.m_type)
    td.dispatchEvent(td.BASECAMP_UPGRADE)
    self:RefreshUI()
    td.CreateUIEffect(self.m_icon, "Spine/UI_effect/EFT_dedaojineng_01")
    G_SoundUtil:PlaySound(65)
    if self:CheckCanUpgrade() then
      self.m_upBtn:setDisable(false)
    end
  else
    td.alert(g_LM:getBy("a00340"))
  end
end
return BaseSkillDlg
