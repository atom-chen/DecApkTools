local GameControl = require("app.GameControl")
local BaseInfoManager = require("app.info.BaseInfoManager")
local UserDataManager = require("app.UserDataManager")
local MissionInfoManager = require("app.info.MissionInfoManager")
local ModuleControl = class("ModuleControl", GameControl)
ModuleControl.instance = nil
function ModuleControl:ctor(eType)
  ModuleControl.super.ctor(self, eType)
  self:InitData()
  self.m_vModeState = {}
end
function ModuleControl:GetInstance()
  if ModuleControl.instance == nil then
    ModuleControl.instance = ModuleControl.new(td.GameControlType.SwichScene)
  end
  return ModuleControl.instance
end
function ModuleControl:ClearValue()
  self:InitData()
end
function ModuleControl:InitData()
  self.m_vShowingModule = {}
  self.m_vUpdateModule = {
    [td.UIModule.Mail] = true
  }
  self.m_bShowAlert = true
  self.m_bEnableUI = true
  self.m_onlyEnableName = ""
  self.m_lastOpTime = UserDataManager:GetInstance():GetServerTime()
end
function ModuleControl:InitModeState()
  local modes = {
    td.UIModule.PVP,
    td.UIModule.Endless,
    td.UIModule.Collect,
    td.UIModule.Trial,
    td.UIModule.Rob
  }
  for i, mode in ipairs(modes) do
    if self:IsModuleUnlock(mode) then
      self.m_vModeState[mode] = td.LockState.Unlocked
    else
      self.m_vModeState[mode] = td.LockState.Lock
    end
  end
end
function ModuleControl:GetModeState(mode)
  if self.m_vModeState[mode] == td.LockState.Lock and self:IsModuleUnlock(mode) then
    return td.LockState.Unlocking
  else
    return self.m_vModeState[mode]
  end
end
function ModuleControl:UpdateModeState(mode, lockState)
  self.m_vModeState[mode] = lockState
end
function ModuleControl:SetShowAlert(b)
  self.m_bShowAlert = b
end
function ModuleControl:GetShowAlert()
  return self.m_bShowAlert
end
function ModuleControl:SetEnableUI(b)
  self.m_bEnableUI = b
end
function ModuleControl:GetEnableUI()
  return self.m_bEnableUI
end
function ModuleControl:IsModuleUnlock(id, bNotGuide)
  local openInfo = BaseInfoManager:GetInstance():GetOpenInfo(id)
  if not openInfo then
    return true
  end
  if openInfo.baseLevel then
    local baseLevel = UserDataManager:GetInstance():GetUserDetail().camp
    if baseLevel < openInfo.baseLevel then
      return false
    end
    if not bNotGuide then
      local guideLevel = require("app.GuideManager"):GetInstance():GetGuideLevelUp()
      if guideLevel and guideLevel == openInfo.baseLevel then
        return false
      end
    end
  end
  if openInfo.missionId and not UserDataManager:GetInstance():GetCityData(openInfo.missionId) then
    return false
  end
  return true
end
function ModuleControl:AddShowingModule(id)
  table.insert(self.m_vShowingModule, id)
end
function ModuleControl:OpenModule(id, data, vSubIndex, vGuideNode)
  self:UpdateOpTime()
  if self:IsModuleShowing(id) then
    return
  elseif not self:IsModuleUnlock(id) then
    local openInfo = BaseInfoManager:GetInstance():GetOpenInfo(id)
    if openInfo.baseLevel then
      td.alert(string.format(g_LM:getMode("tipmsg", td.ErrorCode.BASE_LEVEL_LOW), openInfo.baseLevel), true)
    elseif openInfo.missionId then
      local cityName = require("app.info.MissionInfoManager"):GetInstance():GetMissionInfo(openInfo.missionId).name
      td.alert(string.format(g_LM:getMode("tipmsg", td.ErrorCode.MISSION_LOCKED), cityName), true)
    end
    return
  end
  if id == td.UIModule.Guild then
    local scene = require("app.scenes.GuildScene").new()
    display.replaceScene(scene)
    return
  end
  local dlgClass
  if id == td.UIModule.Mission then
    dlgClass = require("app.layers.MainMenuUI.MissionChooseLayer")
  elseif id == td.UIModule.MissionDetail then
    local miMng = MissionInfoManager:GetInstance()
    local missionInfo = miMng:GetMissionInfo(data)
    if not miMng:IsChapterUnlock(missionInfo.chapter, missionInfo.mode) then
      td.alertErrorMsg(td.ErrorCode.MISSION_LOCKED)
      return
    end
    if not miMng:IsMissionUnlock(data) then
      td.alertErrorMsg(td.ErrorCode.MISSION_LOCKED)
      return
    end
    dlgClass = require("app.layers.MainMenuUI.MissionLayer")
  elseif id == td.UIModule.Task then
    dlgClass = require("app.layers.MainMenuUI.TaskDlg")
  elseif id == td.UIModule.PVP then
    dlgClass = require("app.layers.MainMenuUI.ArenaDlg")
  elseif id == td.UIModule.Endless then
    dlgClass = require("app.layers.MainMenuUI.EndlessDlg")
  elseif id == td.UIModule.Hero then
    dlgClass = require("app.layers.MainMenuUI.HeroInfoNewDlg")
  elseif id == td.UIModule.Camp then
    dlgClass = require("app.layers.MainMenuUI.UnitDlg")
  elseif id == td.UIModule.Rank then
    dlgClass = require("app.layers.MainMenuUI.RankDlg")
  elseif id == td.UIModule.Mail then
    dlgClass = require("app.layers.MainMenuUI.MailBoxDlg")
  elseif id == td.UIModule.Pack then
    dlgClass = require("app.layers.MainMenuUI.BackpackDlg")
  elseif id == td.UIModule.Chat then
  elseif id == td.UIModule.Store then
    dlgClass = require("app.layers.MainMenuUI.StoreDlg")
  elseif id == td.UIModule.Supply then
    dlgClass = require("app.layers.MainMenuUI.SupplyDlg")
  elseif id == td.UIModule.Topup then
    dlgClass = require("app.layers.MainMenuUI.TopupDlg")
  elseif id == td.UIModule.DrawCard then
    dlgClass = require("app.layers.MainMenuUI.DrawCardDlg")
  elseif id == td.UIModule.Title then
  elseif id == td.UIModule.System then
    dlgClass = require("app.layers.worldmap.SettingDlg")
  elseif id == td.UIModule.WeaponUpgrade then
    dlgClass = require("app.layers.MainMenuUI.WeaponDlg")
  elseif id == td.UIModule.HeroSkill then
    dlgClass = require("app.layers.MainMenuUI.HeroEquipSkillDlg")
  elseif id == td.UIModule.BaseCamp then
    dlgClass = require("app.layers.MainMenuUI.BaseCampUpgradeDlg")
  elseif id == td.UIModule.Pokedex then
    dlgClass = require("app.layers.MainMenuUI.TujianDlg")
  elseif id == td.UIModule.BuyGold then
    data = td.UIModule.BuyGold
    dlgClass = require("app.layers.MainMenuUI.GoldBuyDlg")
  elseif id == td.UIModule.BuyStamina then
    data = td.UIModule.BuyStamina
    dlgClass = require("app.layers.MainMenuUI.GoldBuyDlg")
  elseif id == td.UIModule.Achievement then
    dlgClass = require("app.layers.MainMenuUI.AchievementDlg")
  elseif id == td.UIModule.PlayerInfo then
    dlgClass = require("app.layers.worldmap.PlayerInfoDlg")
  elseif id == td.UIModule.Friend then
    dlgClass = require("app.layers.MainMenuUI.FriendDlg")
  elseif id == td.UIModule.Rob then
    dlgClass = require("app.layers.MainMenuUI.RobDlg")
  elseif id == td.UIModule.Trial then
    dlgClass = require("app.layers.MainMenuUI.TrialDlg")
  elseif id == td.UIModule.Name then
    dlgClass = require("app.layers.NameDlg")
  elseif id == td.UIModule.NewSignIn then
    dlgClass = require("app.layers.MainMenuUI.NewSignInDlg")
  elseif id == td.UIModule.Activity then
    dlgClass = require("app.layers.MainMenuUI.ActivityDlg")
  elseif id == td.UIModule.ItemDetail then
    dlgClass = require("app.layers.MainMenuUI.ItemDetailDlg")
  elseif id == td.UIModule.BaseSkill then
    dlgClass = require("app.layers.MainMenuUI.BaseSkillDlg")
  elseif id == td.UIModule.UpgradeHeroOrSoldier then
    dlgClass = require("app.layers.MainMenuUI.UpgradeDlg")
  elseif id == td.UIModule.Collect then
    dlgClass = require("app.layers.MainMenuUI.CollectDlg")
  elseif id == td.UIModule.Bombard then
    dlgClass = require("app.layers.MainMenuUI.BombDlg")
  elseif id == td.UIModule.Dungeon then
    dlgClass = require("app.layers.MainMenuUI.DungeonLayer")
  elseif id == td.UIModule.VIP then
    dlgClass = require("app.layers.MainMenuUI.VIPDlg")
  elseif id == td.UIModule.ItemSell then
    dlgClass = require("app.layers.MainMenuUI.ItemSellDlg")
  elseif id == td.UIModule.SignInBox then
    dlgClass = require("app.layers.MainMenuUI.SignInBoxDlg")
  elseif id == td.UIModule.Compose then
    dlgClass = require("app.layers.MainMenuUI.ItemComposeDlg")
  elseif id == td.UIModule.Decompose then
    dlgClass = require("app.layers.MainMenuUI.ItemDecomposeDlg")
  elseif id == td.UIModule.WeaponDecompose then
    dlgClass = require("app.layers.MainMenuUI.WeaponDecomposeDlg")
  elseif id == td.UIModule.Gem then
    dlgClass = require("app.layers.MainMenuUI.GemDlg")
  elseif id == td.UIModule.UnitTrain then
    dlgClass = require("app.layers.MainMenuUI.UnitTrainDlg")
  elseif id == td.UIModule.MissionReady then
    dlgClass = require("app.layers.MainMenuUI.MissionReadyLayer")
  elseif id == td.UIModule.BuyForce then
    data = td.UIModule.BuyForce
    dlgClass = require("app.layers.MainMenuUI.GoldBuyDlg")
  end
  if dlgClass then
    local pDlg = dlgClass.new(data, vSubIndex)
    pDlg:SetEnterSubIndex(vSubIndex, vGuideNode)
    td.popView(pDlg)
    self:AddShowingModule(id)
    return pDlg
  end
end
function ModuleControl:CloseModule(id)
  self:UpdateOpTime()
  table.removebyvalue(self.m_vShowingModule, id, true)
  if self:IsAllModuleClose() then
    td.dispatchEvent(td.ON_All_DLG_CLOSE)
  end
end
function ModuleControl:IsAllModuleClose()
  if table.nums(self.m_vShowingModule) == 0 then
    return true
  end
  return false
end
function ModuleControl:IsModuleShowing(id)
  if id and table.indexof(self.m_vShowingModule, id) then
    return true
  end
  return false
end
function ModuleControl:SetOnlyEnableName(name)
  self.m_onlyEnableName = name
end
function ModuleControl:GetOnlyEnableName()
  return self.m_onlyEnableName
end
function ModuleControl:SetModuleUpdate(id, bUpdate)
  self.m_vUpdateModule[id] = bUpdate
end
function ModuleControl:IsModuleUpdate(id)
  return self.m_vUpdateModule[id]
end
function ModuleControl:UpdateOpTime()
  self.m_lastOpTime = UserDataManager:GetInstance():GetServerTime()
end
function ModuleControl:GetOpTime()
  return self.m_lastOpTime
end
function ModuleControl:SetRecentOpenChapter(diff, chapter)
  self.m_curDiff = diff
  self.m_curChapter = chapter
end
function ModuleControl:GetRecentOpenChapter()
  return self.m_curDiff, self.m_curChapter
end
function ModuleControl:SetRecentTrialDiff(diff)
  self.m_curTrialDiff = diff
end
function ModuleControl:GetRecentTrialDiff()
  return self.m_curTrialDiff
end
g_MC = g_MC or ModuleControl:GetInstance()
