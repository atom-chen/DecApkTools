local GameControl = require("app.GameControl")
local GuideLayer = require("app.layers.GuideLayer")
local GuideSpeakLayer = require("app.layers.GuideSpeakLayer")
local GuideWeakLayer = require("app.layers.GuideWeakLayer")
local GameDataManager = require("app.GameDataManager")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
require("app.config.guide_config")
local GuideManager = class("GuideManager", GameControl)
local GuideType = {
  Speak = 1,
  UI = 2,
  Tips = 3,
  Weak = 4
}
GuideManager.LastForceGuide = 6
GuideManager.instance = nil
function GuideManager:ctor(eType)
  GuideManager.super.ctor(self, eType)
  self:Init()
  local eventDsp = cc.Director:getInstance():getEventDispatcher()
  self.m_customListener = cc.EventListenerCustom:create(td.GUIDE_CONTINUE, function()
    if self.m_bIsPause then
      self.m_bIsPause = false
      self:DoNextGuide()
    end
  end)
  eventDsp:addEventListenerWithFixedPriority(self.m_customListener, 1)
end
function GuideManager:GetInstance()
  if GuideManager.instance == nil then
    GuideManager.instance = GuideManager.new(td.GameControlType.EnterMap)
  end
  return GuideManager.instance
end
function GuideManager:Init()
  self.m_savedGroup = self:GetSavedGroup()
  self.m_curGuideGroup = nil
  self.m_curGuideIdx = nil
  self.m_bGuideing = false
  self.m_didGuide = false
  self.m_bIsPause = false
  self.m_currGuideType = nil
  self.m_savingGroupId = nil
  self.m_curGuideInfo = nil
  self.m_curGuidePriority = 0
  self.m_iGuideLevelUp = nil
end
function GuideManager:ClearValue()
  self:Init()
end
function GuideManager:SetGuideLevelUp(level)
  self.m_iGuideLevelUp = level
end
function GuideManager:GetGuideLevelUp()
  return self.m_iGuideLevelUp
end
function GuideManager:IsGuiding()
  return self.m_bGuideing
end
function GuideManager:GetCurGuidePriority()
  return self.m_curGuidePriority
end
function GuideManager:IsGuidingSoldier()
  if not self.m_curGuideInfo or not self.m_curGuideInfo.steps or not self.m_curGuideIdx then
    return false
  end
  local curStepInfo = self.m_curGuideInfo.steps[self.m_curGuideIdx]
  if curStepInfo and curStepInfo.nodeName then
    local subStr = string.sub(curStepInfo.nodeName, 1, 10)
    if subStr == "SoldierBtn" then
      return true
    end
  end
  return false
end
function GuideManager:IsForceGuideOver()
  return self:IsGuideGroupOver(GuideManager.LastForceGuide)
end
function GuideManager:ShouldWeakGuide()
  if GameDataManager:GetInstance():GetGameMapInfo().id == td.TRAIN_ID then
    return false
  end
  if UserDataManager:GetInstance():GetCityData(1003) then
    return false
  end
  return true
end
function GuideManager:IsGuideGroupOver(groupId)
  if groupId < GuideManager.LastForceGuide and self:IsGuideGroupOver(GuideManager.LastForceGuide) then
    return true
  end
  local guideGroupInfo = GetGuideConfig(groupId)
  if guideGroupInfo and guideGroupInfo.conditions then
    for i, var in ipairs(guideGroupInfo.conditions) do
      if self:_CheckCondition(var, groupId) then
        return true
      end
    end
  end
  return false
end
function GuideManager:_CheckCondition(con, groupId)
  local udMng = UserDataManager:GetInstance()
  if con.type == 1 or con.type == 2 then
    if udMng:GetCityData(con.cityId) then
      return true
    end
  elseif con.type == 3 then
    local baseLevel = udMng:GetBaseCampLevel()
    if baseLevel >= con.level then
      return true
    end
  elseif con.type == 4 then
    local mainTasks = udMng:GetTaskData()[td.TaskType.MainLine]
    if not mainTasks or #mainTasks == 0 then
      return true
    end
    local StateMapping = {
      [td.TaskState.Incomplete] = 0,
      [td.TaskState.Complete] = 1,
      [td.TaskState.Received] = 2
    }
    for i, task in ipairs(mainTasks) do
      if task.tid > con.taskId or task.tid == con.taskId and StateMapping[task.state] >= con.state then
        return true
      end
    end
  elseif con.type == 5 then
    local skillLib = udMng:GetSkillLib()
    if 0 < table.nums(skillLib) then
      return true
    end
  elseif con.type == 6 then
    local herosData = udMng:GetHeroData()
    for key, heroData in pairs(herosData) do
      if heroData.activeSkill[1] ~= 0 then
        return true
      end
    end
  elseif con.type == 7 then
    if self:IsForceGuideOver() then
      return true
    end
  elseif con.type == 8 then
    local selfData = udMng:GetPVPData().selfData
    if selfData and (0 < #selfData.hero_item or 0 < #selfData.soldier_item) then
      return true
    end
  elseif con.type == 9 then
    local herosData = udMng:GetHeroData()
    for key, heroData in pairs(herosData) do
      if heroData.level >= con.level then
        return true
      end
    end
  elseif con.type == 10 then
    local herosData = udMng:GetHeroData()
    for key, heroData in pairs(herosData) do
      if heroData.attackSite ~= 0 or heroData.defSite ~= 0 then
        return true
      end
    end
  elseif con.type == 11 then
    local soldierData = require("app.UnitDataManager"):GetInstance():GetSoldierData(con.soldierId)
    if soldierData and soldierData.level >= con.level then
      return true
    end
  elseif con.type == 12 then
    if table.indexof(self.m_savedGroup, groupId) then
      return true
    end
  elseif con.type == 13 then
    local weaponsData = udMng:GetWeaponData()
    for key, weaponData in pairs(weaponsData) do
      if weaponData.level >= con.level then
        return true
      end
    end
  elseif con.type == 14 then
    if UserDataManager:GetInstance():IsAchieveReached(con.achieveId) then
      return true
    end
  elseif con.type == 15 then
    local haveNum = require("app.UnitDataManager"):GetInstance():GetSoldierNum(con.soldierId)
    if haveNum >= con.num then
      return true
    end
  end
  return false
end
function GuideManager:StartGuideGroup(groupId, priority)
  if not td.Guide_Flag then
    return
  end
  priority = priority or 2
  if self:IsGuideGroupOver(groupId) then
    return
  end
  self.m_curGuideInfo = GetGuideConfig(groupId)
  if self.m_curGuideInfo then
    self.m_curGuideGroup = groupId
    self.m_curGuideIdx = 1
    self.m_didGuide = false
    self.m_bGuideing = true
    self.m_curGuidePriority = priority
    self:DoNextGuide()
    require("app.trigger.TriggerManager"):GetInstance():SendEvent({
      eType = td.ConditionType.GuideBegin,
      group = self.m_curGuideGroup
    })
  end
end
function GuideManager:SaveGuideGroup(groupId)
  table.insert(self.m_savedGroup, groupId)
  local saveGroups = table.unique(self.m_savedGroup)
  local guideString = ""
  for key, gid in pairs(saveGroups) do
    guideString = guideString .. gid .. ","
  end
  if guideString ~= "" then
    guideString = string.sub(guideString, 1, string.len(guideString) - 1)
  end
  g_LD:SetStr("guide", guideString)
end
function GuideManager:GetSavedGroup()
  local guideString = g_LD:GetStr("guide", "")
  local guideGroups = {}
  if guideString and guideString ~= "" then
    local tmp = string.split(guideString, ",")
    for i, gid in ipairs(tmp) do
      table.insert(guideGroups, tonumber(gid))
    end
  end
  return guideGroups
end
function GuideManager:DoNextGuide()
  if not self.m_bGuideing then
    return
  end
  self.m_didGuide = false
  local info = self.m_curGuideInfo.steps[self.m_curGuideIdx]
  if info.enableUI ~= nil then
    g_MC:SetEnableUI(info.enableUI)
  end
  if info.sound then
    G_SoundUtil:PlaySound(info.sound)
  end
  if GuideType.Speak == info.type then
    if info.uiId then
      td.dispatchEvent(td.CHECK_GUIDE)
    else
      GuideSpeakLayer.AddToScene(nil, info)
    end
  elseif GuideType.UI == info.type or GuideType.Weak == info.type then
    td.dispatchEvent(td.CHECK_GUIDE)
  elseif GuideType.Tips == info.type then
    local pDlg = require("app.layers.GuideTipsDlg").new(info)
    td.popView(pDlg, true)
  end
  require("app.trigger.TriggerManager"):GetInstance():SendEvent({
    eType = td.ConditionType.GuideStepBegin,
    guideGroup = self.m_curGuideGroup,
    guideIdx = self.m_curGuideIdx
  })
end
function GuideManager:UpdateGuide()
  if self.m_bIsPause then
    return
  end
  require("app.trigger.TriggerManager"):GetInstance():SendEvent({
    eType = td.ConditionType.GuideStepEnd,
    guideGroup = self.m_curGuideGroup,
    guideIdx = self.m_curGuideIdx
  })
  local guideInfo = self.m_curGuideInfo.steps[self.m_curGuideIdx]
  if guideInfo.save and self.m_curGuideGroup then
    self:SaveGuideGroup(self.m_curGuideGroup)
  end
  if guideInfo and self.m_curGuideIdx + 1 <= #self.m_curGuideInfo.steps then
    self.m_curGuideIdx = self.m_curGuideIdx + 1
    if guideInfo.pause then
      self.m_bIsPause = true
    else
      self:DoNextGuide()
    end
  else
    self:StopGuide()
    if self.m_curGuideGroup then
      require("app.trigger.TriggerManager"):GetInstance():SendEvent({
        eType = td.ConditionType.GuideEnd,
        group = self.m_curGuideGroup
      })
      if self.m_curGuideGroup == GuideManager.LastForceGuide then
        td.dispatchEvent(td.FORCE_GUIDE_OVER)
      end
    end
  end
end
function GuideManager:StopGuide()
  self.m_curGuideInfo = nil
  self.m_curGuideIdx = nil
  self.m_bGuideing = false
  self.m_curGuidePriority = 0
end
function GuideManager:GuideUI(uiId, uiRoot)
  if not self.m_bGuideing or self.m_bIsPause then
    return
  end
  local info = self.m_curGuideInfo.steps[self.m_curGuideIdx]
  if not self.m_didGuide and uiRoot and uiId and info.uiId == uiId then
    if info.type == GuideType.UI then
      if GuideLayer.AddToNode(uiRoot, info) then
        self.m_didGuide = true
      end
    elseif info.type == GuideType.Weak then
      if GuideWeakLayer.AddToNode(uiRoot, info) then
        self.m_didGuide = true
      end
    elseif info.type == GuideType.Speak and GuideSpeakLayer.AddToScene(uiRoot, info) then
      self.m_didGuide = true
    end
  end
end
function GuideManager.H_StartGuideGroup(group, priority)
  priority = priority or 2
  local pGuideManager = GuideManager.GetInstance()
  if type(group) ~= "table" then
    group = {group}
  end
  for i, var in ipairs(group) do
    if not pGuideManager:IsGuideGroupOver(var) and priority > pGuideManager:GetCurGuidePriority() then
      pGuideManager:StartGuideGroup(var, priority)
      break
    end
  end
end
function GuideManager:StartUI(id)
  self.m_bGuideing = true
  self.m_currGuideId = id
  self.m_currGuideType = GuideType.UI
  self:DoNextGuide()
end
function GuideManager.H_GuideUI(uiId, uiRoot)
  local pGuideManager = GuideManager.GetInstance()
  pGuideManager:GuideUI(uiId, uiRoot)
end
return GuideManager
