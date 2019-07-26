local GameControl = require("app.GameControl")
local GameDataManager = require("app.GameDataManager")
require("app.config.TriggerConfig")
local TriggerManager = class("TriggerManager", GameControl)
TriggerManager.instance = nil
local TriggerTypeStr = {
  [0] = "mapId",
  [1] = "mapType",
  [2] = "taskGuide"
}
function TriggerManager:ctor(eType)
  TriggerManager.super.ctor(self, eType)
  self:Init()
end
function TriggerManager:GetInstance()
  if TriggerManager.instance == nil then
    TriggerManager.instance = TriggerManager.new(td.GameControlType.SwichScene)
  end
  return TriggerManager.instance
end
function TriggerManager:Init()
  self.m_bPause = false
  self.m_vTriggers = {}
  self.m_enableGuide = true
end
function TriggerManager:ClearValue()
  self:Init()
end
function TriggerManager:AddTriggerByType(triggerType, subKey)
  local configs = GetTriggerConfigAll()
  for k, value in pairs(configs) do
    if value.triggerType == triggerType then
      if td.TriggerType.MapType == triggerType then
        if value.mapType == subKey or value.mapType == td.MapType.All then
          self:AddTrigger(value)
        end
      elseif td.TriggerType.MapId == triggerType then
        for k, mapId in pairs(value.mapId) do
          if mapId == subKey then
            self:AddTrigger(value, mapId)
            break
          end
        end
      elseif td.TriggerType.TaskGuide == triggerType and self.m_enableGuide then
        self:AddTrigger(value)
      end
    end
  end
end
function TriggerManager:RemoveTriggerByType(triggerType)
  local str_key = self:GetTriggerStrKey(triggerType)
  self.m_vTriggers[str_key] = {}
end
function TriggerManager:RemoveTriggerById(triggerId)
  for k, value in pairs(self.m_vTriggers) do
    for k2, value2 in pairs(value) do
      for k3, value3 in pairs(value2) do
        if triggerId == value3:GetID() then
          self:RemoveTrigger(value3)
          break
        end
      end
    end
  end
end
function TriggerManager:AddTrigger(pTriggerInfo, subKey)
  if nil == pTriggerInfo then
    return nil
  end
  local pTrigger
  local triggerClassName = "app.trigger." .. pTriggerInfo.className
  local trigger = require(triggerClassName)
  if trigger then
    local typeStr = self:GetTriggerStrKey(pTriggerInfo.triggerType)
    local typeId
    if td.TriggerType.MapType == pTriggerInfo.triggerType then
      pTrigger = trigger.new(pTriggerInfo.id, td.TriggerType.MapType, pTriggerInfo.loop, pTriggerInfo.conditionType, pTriggerInfo)
      typeId = pTriggerInfo.mapType
    elseif td.TriggerType.MapId == pTriggerInfo.triggerType then
      pTrigger = trigger.new(pTriggerInfo.id, td.TriggerType.MapId, pTriggerInfo.loop, pTriggerInfo.conditionType, pTriggerInfo)
      if nil == subKey then
        typeId = pTriggerInfo.mapId
      else
        typeId = subKey
      end
    elseif td.TriggerType.TaskGuide == pTriggerInfo.triggerType then
      pTrigger = trigger.new(pTriggerInfo.id, td.TriggerType.TaskGuide, pTriggerInfo.loop, pTriggerInfo.conditionType, pTriggerInfo)
      typeId = pTriggerInfo.id
    end
    if nil ~= pTrigger and nil ~= typeStr and nil ~= typeId then
      self:CreateCondition(pTrigger, pTriggerInfo)
      self.m_vTriggers[typeStr] = self.m_vTriggers[typeStr] or {}
      if type(typeId) == "table" then
        for k, mapId in pairs(typeId) do
          self.m_vTriggers[typeStr][mapId] = self.m_vTriggers[typeStr][mapId] or {}
          table.insert(self.m_vTriggers[typeStr][mapId], pTrigger)
        end
      else
        self.m_vTriggers[typeStr][typeId] = self.m_vTriggers[typeStr][typeId] or {}
        table.insert(self.m_vTriggers[typeStr][typeId], pTrigger)
      end
      return pTrigger
    end
  end
  return nil
end
function TriggerManager:GetTriggerStrKey(triggerType)
  return TriggerTypeStr[triggerType]
end
function TriggerManager:RemoveTrigger(pTrigger)
  if not pTrigger then
    return
  end
  local str_key = self:GetTriggerStrKey(pTrigger:GetType())
  local int_key
  local curMapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  if td.TriggerType.MapType == pTrigger:GetType() then
    int_key = curMapInfo.type
  elseif td.TriggerType.MapId == pTrigger:GetType() then
    int_key = curMapInfo.id
  elseif td.TriggerType.TaskGuide == pTrigger:GetType() then
    int_key = pTrigger:GetID()
  end
  if self.m_vTriggers[str_key] and self.m_vTriggers[str_key][int_key] then
    table.removebyvalue(self.m_vTriggers[str_key][int_key], pTrigger, true)
  end
end
function TriggerManager:Update(dt)
  if self.m_bPause then
    return
  end
  local currScene = cc.Director:getInstance():getRunningScene()
  if td.SceneType.Battle == currScene:GetType() then
    local curMapInfo = GameDataManager:GetInstance():GetGameMapInfo()
    if not curMapInfo then
      return
    end
    local mapId = curMapInfo.id
    local mapType = curMapInfo.type
    local str_key = self:GetTriggerStrKey(td.TriggerType.MapType)
    if self.m_vTriggers[str_key] then
      if self.m_vTriggers[str_key][mapType] then
        for i, v in pairs(self.m_vTriggers[str_key][mapType]) do
          v:Update(dt)
        end
      end
      if self.m_vTriggers[str_key][td.MapType.All] then
        for i, v in pairs(self.m_vTriggers[str_key][td.MapType.All]) do
          v:Update(dt)
        end
      end
    end
    local str_key = self:GetTriggerStrKey(td.TriggerType.MapId)
    if self.m_vTriggers[str_key] and self.m_vTriggers[str_key][mapId] then
      for i, v in pairs(self.m_vTriggers[str_key][mapId]) do
        v:Update(dt)
      end
    end
  end
  if self.m_enableGuide then
    local str_key = self:GetTriggerStrKey(td.TriggerType.TaskGuide)
    if self.m_vTriggers[str_key] then
      for i, v in pairs(self.m_vTriggers[str_key]) do
        v[1]:Update(dt)
      end
    end
  end
end
function TriggerManager:CreateCondition(pTrigger, pInfo)
  for i, v in ipairs(pInfo.conditions) do
    local pCondition
    local ConditionClass = self:GetConditionClass(v.type)
    pCondition = ConditionClass.new(v)
    if nil ~= pCondition then
      pTrigger:AddCondition(pCondition)
      if pCondition:CheckSatisfyOnInit() then
        pCondition:SetSatisfy(true)
      end
    else
      print("[error:]Trigger id =" .. pTrigger:GetID() .. "add Condition id =" .. pInfo.id)
    end
  end
end
function TriggerManager:GetConditionClass(conType)
  local Condition
  local filePath = "app.trigger.condition."
  if conType == td.ConditionType.AllHYRDead then
    Condition = require(filePath .. "AllHYRDeadCondition")
  elseif conType == td.ConditionType.DeputyDead then
    Condition = require(filePath .. "DeputyHomeDead_Condition")
  elseif conType == td.ConditionType.EffectEnd then
    Condition = require(filePath .. "EffectEndCondition")
  elseif conType == td.ConditionType.AllBossDead then
    Condition = require(filePath .. "AllBossDeadCondition")
  elseif conType == td.ConditionType.AllSideDead then
    Condition = require(filePath .. "AllSideDeadCondition")
  elseif conType == td.ConditionType.HomeState then
    Condition = require(filePath .. "HomeStateCondition")
  elseif conType == td.ConditionType.ResourceEnough then
    Condition = require(filePath .. "ResourceEnoughCondition")
  elseif conType == td.ConditionType.TimeOver then
    Condition = require(filePath .. "TimeoverCondition")
  elseif conType == td.ConditionType.GuideStepEnd then
    Condition = require(filePath .. "GuideStepEnd_Condition")
  elseif conType == td.ConditionType.AddOrRemoveBuff then
    Condition = require(filePath .. "AddOrRemoveBuffCondition")
  elseif conType == td.ConditionType.AddOrRemoveSkill then
    Condition = require(filePath .. "AddOrRemoveSkillCondition")
  elseif conType == td.ConditionType.MapGunFire then
    Condition = require(filePath .. "MapGunFireCondition")
  elseif conType == td.ConditionType.MonsterBirth then
    Condition = require(filePath .. "MonsterBirth_Condition")
  elseif conType == td.ConditionType.MonsterHp then
    Condition = require(filePath .. "MonsterHpCondition")
  elseif conType == td.ConditionType.MonsterFlyEnd then
    Condition = require(filePath .. "MonsterFlyEnd_Condition")
  elseif conType == td.ConditionType.AfterRefreshMonster then
    Condition = require(filePath .. "MonsterRefreshCountEndCondition")
  elseif conType == td.ConditionType.BeforeRefreshMonster then
    Condition = require(filePath .. "MonsterRefreshCountCondition")
  elseif conType == td.ConditionType.SacrificeMonster then
    Condition = require(filePath .. "SacrificeMonster_Condition")
  elseif conType == td.ConditionType.MonsterStop then
    Condition = require(filePath .. "MonsterStop_Condition")
  elseif conType == td.ConditionType.MonstPath then
    Condition = require(filePath .. "MonstPathCondition")
  elseif conType == td.ConditionType.PyramidOutBack then
    Condition = require(filePath .. "PyramidOutBackCondition")
  elseif conType == td.ConditionType.ViewportMoveOver then
    Condition = require(filePath .. "ViewportMoveOver_Condition")
  elseif conType == td.ConditionType.CloseModule then
    Condition = require(filePath .. "CloseModuleCondition")
  elseif conType == td.ConditionType.GuideStepBegin then
    Condition = require(filePath .. "GuideStepBegin_Condition")
  elseif conType == td.ConditionType.GuideEnd then
    Condition = require(filePath .. "GuideEndCondition")
  elseif conType == td.ConditionType.CityState then
    Condition = require(filePath .. "CityStateCondition")
  elseif conType == td.ConditionType.ActorAnimOver then
    Condition = require(filePath .. "ActorPlayAnimEnd_Condition")
  elseif conType == td.ConditionType.ForceGuide then
    Condition = require(filePath .. "ForceGuideOver_Condition")
  elseif conType == td.ConditionType.GuideBegin then
    Condition = require(filePath .. "GuideBeginCondition")
  elseif conType == td.ConditionType.BuildCamp then
    Condition = require(filePath .. "BuildCampCondition")
  elseif conType == td.ConditionType.UnlockModule then
    Condition = require(filePath .. "UnlockModuleCondition")
  else
    Condition = require(filePath .. "ConditionBase")
  end
  return Condition
end
function TriggerManager:SendEvent(data)
  local inCheckFunc = function(triggers, data)
    for i, v in pairs(triggers) do
      for j, k in ipairs(v:GetConditions()) do
        if k:GetType() == data.eType and k:CheckSatisfy(data) then
          k:SetSatisfy(true)
        end
      end
    end
  end
  local pMapInfo = GameDataManager.GetInstance():GetGameMapInfo()
  if pMapInfo then
    local mapId = pMapInfo.id
    local str_key = self:GetTriggerStrKey(td.TriggerType.MapId)
    if self.m_vTriggers[str_key] and self.m_vTriggers[str_key][mapId] then
      inCheckFunc(self.m_vTriggers[str_key][mapId], data)
    end
    local mapType = pMapInfo.type
    str_key = self:GetTriggerStrKey(td.TriggerType.MapType)
    if self.m_vTriggers[str_key] and self.m_vTriggers[str_key][mapType] then
      inCheckFunc(self.m_vTriggers[str_key][mapType], data)
    end
  end
  if self.m_vTriggers.mapType and self.m_vTriggers.mapType[td.MapType.All] then
    inCheckFunc(self.m_vTriggers.mapType[td.MapType.All], data)
  end
  if self.m_enableGuide then
    local str_key = self:GetTriggerStrKey(td.TriggerType.TaskGuide)
    if self.m_vTriggers[str_key] then
      for i, v in pairs(self.m_vTriggers[str_key]) do
        for j, k in ipairs(v[1]:GetConditions()) do
          if k:GetType() == data.eType and k:CheckSatisfy(data) then
            k:SetSatisfy(true)
          end
        end
      end
    end
  end
end
function TriggerManager:SetPause(bPause)
  self.m_bPause = bPause
end
function TriggerManager:IsPause()
  return self.m_bPause
end
function TriggerManager:SetGuideTriggerEnable(enable)
  self.m_enableGuide = enable
end
function TriggerManager:GetTriggerById(triggerId)
  for _, value in pairs(self.m_vTriggers) do
    for _, value2 in pairs(value) do
      for _, value3 in pairs(value2) do
        if value3:GetID() == triggerId then
          return value3
        end
      end
    end
  end
  return nil
end
return TriggerManager
