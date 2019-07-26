local TDHttpRequest = require("app.net.TDHttpRequest")
local GuideManager = require("app.GuideManager")
local BaseInfoManager = require("app.info.BaseInfoManager")
local UserDataManager = require("app.UserDataManager")
local BaseDlg = require("app.layers.BaseDlg")
local RichIcon = require("app.widgets.RichIcon")
local BaseCampUpgradeDlg = class("BaseCampUpgradeDlg", BaseDlg)
local touchHelpTag = 0
function BaseCampUpgradeDlg:ctor()
  BaseCampUpgradeDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.BaseCamp
  self.m_udMng = UserDataManager:GetInstance()
  self.m_bIsRequesting = false
  self.m_upgradeEffect = {}
  self:InitUI()
end
function BaseCampUpgradeDlg:onEnter()
  BaseCampUpgradeDlg.super.onEnter(self)
  self:AddBtnEvents()
  self:AddListeners()
  self:PlayEnterAnime()
  self:CheckGuide()
end
function BaseCampUpgradeDlg:onExit()
  BaseCampUpgradeDlg.super.onExit(self)
end
function BaseCampUpgradeDlg:PlayEnterAnime()
  local deco = cc.uiloader:seekNodeByName(self.m_bg, "Image_decoration")
  deco:runAction(cca.moveBy(0.2, -600, 0))
  for i = 1, #self.m_panels do
    self.m_panels[i]:runAction(cca.seq({
      cca.delay(i * 0.15),
      cc.EaseBackIn:create(cca.moveBy(0.15, -600, 0))
    }))
  end
  for i = 1, #self.m_btns do
    self.m_btns[i]:runAction(cca.seq({
      cca.delay(0.5 + i * 0.2),
      cc.EaseBackOut:create(cca.scaleTo(0.2, 1, 1))
    }))
  end
  self.m_panelExp:runAction(cca.seq({
    cca.delay(0.2),
    cc.EaseBackOut:create(cca.moveBy(0.2, 0, 180))
  }))
  self.m_bgSpine:runAction(cca.seq({
    cca.delay(0.2),
    cca.fadeIn(0.3, 1)
  }))
end
function BaseCampUpgradeDlg:InitUI()
  self:LoadUI("CCS/BaseCampUpgradeDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "BG")
  self.m_bgSpine = cc.uiloader:seekNodeByName(self.m_bg, "BG1")
  td.CreateUIEffect(self.m_bgSpine, "Spine/UI_effect/UI_bingyingyuanhuan_01", {
    loop = true,
    pos = cc.p(160, 130)
  })
  self.m_bgDetail = cc.uiloader:seekNodeByName(self.m_bg, "BG2")
  self.m_bgUpgradeButtons = cc.uiloader:seekNodeByName(self.m_bg, "BG3")
  self.m_panelExp = cc.uiloader:seekNodeByName(self.m_bg, "Panel_level")
  self.m_expBar = cc.uiloader:seekNodeByName(self.m_panelExp, "Image_exp_bar")
  self.m_expLabel = cc.uiloader:seekNodeByName(self.m_panelExp, "Text_exp")
  self.m_levelLabel = cc.uiloader:seekNodeByName(self.m_panelExp, "Text_lvl")
  self:SetTitle(td.Word_Path .. "wenzi_dabenying.png")
  self.m_panels = {}
  for i = 1, 4 do
    local panel = cc.uiloader:seekNodeByName(self.m_bg, "Panel_" .. i)
    table.insert(self.m_panels, panel)
  end
  self.m_btns = {}
  self.m_skillMissionBtn = cc.uiloader:seekNodeByName(self.m_bgUpgradeButtons, "Button_1")
  table.insert(self.m_btns, self.m_skillMissionBtn)
  self.m_skillArenaBtn = cc.uiloader:seekNodeByName(self.m_bgUpgradeButtons, "Button_2")
  if g_MC:IsModuleUnlock(td.UIModule.PVP) then
    table.insert(self.m_btns, self.m_skillArenaBtn)
  else
    self.m_skillArenaBtn:setVisible(false)
    local x, y = self.m_skillArenaBtn:getPosition()
  end
  self:RefreshUI()
end
function BaseCampUpgradeDlg:RefreshUI(event)
  local userDetail = UserDataManager:GetInstance():GetUserDetail()
  self.m_campLevel = userDetail.camp
  local baseCampInfo = BaseInfoManager:GetInstance():GetBaseInfo(self.m_campLevel)
  local currMissionLevel = userDetail.mission_level
  local currArenaLevel = userDetail.arena_level
  local infoMission = BaseInfoManager:GetInstance():GetBaseInfo(currMissionLevel + 1)
  local infoArena = BaseInfoManager:GetInstance():GetBaseInfo(currArenaLevel + 1)
  self.m_levelLabel:setString("LV." .. self.m_campLevel)
  self.m_expBar:setScaleX(cc.clampf(userDetail.campExp / baseCampInfo.exp, 0, 1))
  self.m_expLabel:setString(string.format("%d/%d", userDetail.campExp, baseCampInfo.exp))
  local vCurValue = {
    baseCampInfo.hp,
    baseCampInfo.vit,
    td.CalculateTowerHp(self.m_campLevel, false),
    td.CalculateTowerAttack(self.m_campLevel, false)
  }
  for i = 1, 4 do
    local txtTitle = cc.uiloader:seekNodeByName(self.m_bgDetail, "Text_" .. i)
    txtTitle:setString(g_LM:getBy("a0016" .. i + 4) .. ": ")
    local txtData = cc.uiloader:seekNodeByName(self.m_bgDetail, "Text_num" .. i)
    txtData:setString(vCurValue[i])
  end
  for i, val in ipairs(self.m_upgradeEffect) do
    val:removeFromParent()
  end
  self.m_upgradeEffect = {}
  if infoMission and currMissionLevel <= self.m_campLevel - 1 then
    if infoMission.skill_cost <= self.m_udMng:GetGold() then
      local upgradeEffect = SkeletonUnit:create("Spine/UI_effect/UI_liubianxing_01")
      upgradeEffect:PlayAni("animation", true)
      table.insert(self.m_upgradeEffect, upgradeEffect)
      td.AddRelaPos(self.m_skillMissionBtn, upgradeEffect)
    end
    local arrow = display.newSprite("UI/common/shangsheng_jiantou.png")
    table.insert(self.m_upgradeEffect, arrow)
    arrow:pos(100, 80):addTo(self.m_skillMissionBtn)
    arrow:runAction(cca.repeatForever(cca.seq({
      cca.moveBy(0.8, 0, 25),
      cca.moveBy(0.2, 0, -25)
    })))
  end
  if infoArena and currArenaLevel <= self.m_campLevel - 1 then
    if infoArena.skill_cost <= self.m_udMng:GetGold() then
      local upgradeEffect = SkeletonUnit:create("Spine/UI_effect/UI_liubianxing_01")
      upgradeEffect:PlayAni("animation", true)
      table.insert(self.m_upgradeEffect, upgradeEffect)
      td.AddRelaPos(self.m_skillArenaBtn, upgradeEffect)
    end
    local arrow = display.newSprite("UI/common/shangsheng_jiantou.png")
    table.insert(self.m_upgradeEffect, arrow)
    arrow:pos(100, 80):addTo(self.m_skillArenaBtn)
    arrow:runAction(cca.repeatForever(cca.seq({
      cca.moveBy(0.8, 0, 25),
      cca.moveBy(0.2, 0, -25)
    })))
  end
  self:CreateSpine(self.m_campLevel)
  self:RefreshBaseSkill()
end
function BaseCampUpgradeDlg:CreateSpine(level)
  level = math.min(level, 30)
  if self.spine then
    if math.ceil((level - 1) / 5) ~= math.ceil(level / 5) then
      self.spine:removeFromParent()
    else
      return
    end
  end
  local strFileName = td.HOME_FILE
  strFileName = strFileName .. math.ceil(level / 5)
  self.spine = SkeletonUnit:create(strFileName)
  self.spine:PlayAni("dabenying_01")
  td.AddRelaPos(self.m_bgSpine, self.spine, 1, cc.p(0.5, 0.3))
end
function BaseCampUpgradeDlg:RefreshBaseSkill()
  local udMng = UserDataManager:GetInstance()
  local userDetail = udMng:GetUserDetail()
  local skillLvLabel1 = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_mission_lvl")
  skillLvLabel1:setString("LV." .. userDetail.mission_level)
  local skillDescLabel1 = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_mission")
  skillDescLabel1:setString(g_LM:getBy("a00370"))
  local skillLvLabel2 = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_arena_lvl")
  skillLvLabel2:setString("LV." .. userDetail.arena_level)
  local skillDescLabel2 = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_arena")
  skillDescLabel2:setString(g_LM:getBy("a00371"))
  local skillNumLabel1 = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_mis_inc_data")
  skillNumLabel1:setString(udMng:GetMaxPopu())
  local skillNumLabel2 = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_arena_inc_data")
  skillNumLabel2:setString(udMng:GetMaxPopu(td.MapType.PVP))
  local label = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_mis_inc")
  label:setString(g_LM:getBy("a00374"))
  label = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_arena_inc")
  label:setString(g_LM:getBy("a00374"))
end
function BaseCampUpgradeDlg:AddBtnEvents()
  td.BtnAddTouch(self.m_skillMissionBtn, function()
    g_MC:OpenModule(td.UIModule.BaseSkill, 1)
  end)
  td.BtnAddTouch(self.m_skillArenaBtn, function()
    g_MC:OpenModule(td.UIModule.BaseSkill, 2)
  end)
end
function BaseCampUpgradeDlg:AddListeners()
  self:AddCustomEvent(td.USERWEALTH_CHANGED, handler(self, self.RefreshUI))
  self:AddCustomEvent(td.BASECAMP_UPGRADE, handler(self, self.RefreshUI))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
return BaseCampUpgradeDlg
