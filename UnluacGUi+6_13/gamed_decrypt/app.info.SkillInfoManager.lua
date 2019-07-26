local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local UserDataManager = require("app.UserDataManager")
local SkillInfoManager = class("SkillInfoManager", GameControl)
SkillInfoManager.instance = nil
function SkillInfoManager:ctor(eType)
  SkillInfoManager.super.ctor(self, eType)
  self:Init()
end
function SkillInfoManager:GetInstance()
  if SkillInfoManager.instance == nil then
    SkillInfoManager.instance = SkillInfoManager.new(td.GameControlType.ExitGame)
  end
  return SkillInfoManager.instance
end
function SkillInfoManager:Init()
  self.m_skillInfos = {}
  self.m_soldierSkillInfos = {}
  self.m_heroSkillInfos = {}
  self.m_itemSkillInfos = {}
  self:SaveInfo()
end
function SkillInfoManager:ClearValue()
end
function SkillInfoManager:SaveInfo()
  local vData = CSVLoader.loadCSV("Config/skill.csv")
  for i, var in ipairs(vData) do
    local temp = {}
    local sounds = string.split(var.sounds, "#")
    for j, soundId in ipairs(sounds) do
      table.insert(temp, tonumber(soundId))
    end
    var.sounds = temp
    var.name = g_LM:getBy(var.name) or var.name
    var.desc = g_LM:getBy(var.desc) or var.desc
    var.get_buff_id = self:_ParseGetBuff(var.get_buff_id)
    var.buff_id = self:_ParseBuff(var.buff_id)
    self.m_skillInfos[var.id] = var
  end
  local vData2 = CSVLoader.loadCSV("Config/skill_soldier.csv")
  for i, v in ipairs(vData2) do
    local tmp = string.split(v.property, ":")
    v.property = {}
    for j, v1 in ipairs(tmp) do
      local property = {}
      local tmp1 = string.split(v1, "|")
      for k, v2 in ipairs(tmp1) do
        local tmp2 = string.split(v2, "*")
        property[tonumber(tmp2[1])] = tmp2[2]
      end
      v.property[j] = property
    end
    tmp = string.split(v.variable, ";")
    v.variable = {}
    for j, v2 in ipairs(tmp) do
      local vary = {}
      local tmp2 = string.split(v2, "#")
      for k, v3 in ipairs(tmp2) do
        table.insert(vary, v3)
      end
      table.insert(v.variable, vary)
    end
    self.m_soldierSkillInfos[v.id] = v
  end
  self:SaveHeroSkillInfo()
end
function SkillInfoManager:_ParseGetBuff(var)
  local temp = {}
  local getBuffs = string.split(var, "#")
  for j, id in ipairs(getBuffs) do
    table.insert(temp, tonumber(id))
  end
  return temp
end
function SkillInfoManager:_ParseBuff(var)
  local temp = {}
  local buffGroups = string.split(var, ";")
  for j, buffGroup in ipairs(buffGroups) do
    local buffs = string.split(buffGroup, "#")
    local vBuffs = {}
    for k, id in ipairs(buffs) do
      table.insert(vBuffs, tonumber(id))
    end
    table.insert(temp, vBuffs)
  end
  return temp
end
function SkillInfoManager:SaveHeroSkillInfo()
  local vData3 = CSVLoader.loadCSV("Config/skill_hero.csv")
  for i, v in ipairs(vData3) do
    local tmp = string.split(v.property, ":")
    v.property = {}
    for j, v1 in ipairs(tmp) do
      local property = {}
      local tmp1 = string.split(v1, "|")
      for k, v2 in ipairs(tmp1) do
        local tmp2 = string.split(v2, "*")
        property[tonumber(tmp2[1])] = tmp2[2]
      end
      v.property[j + 1] = property
    end
    tmp = string.split(v.variable, ";")
    v.variable = {}
    for j, v2 in ipairs(tmp) do
      local vary = {}
      local tmp2 = string.split(v2, "#")
      for k, v3 in ipairs(tmp2) do
        table.insert(vary, v3)
      end
      table.insert(v.variable, vary)
    end
    tmp = string.split(v.star_cost, ";")
    v.star_cost = {}
    for j, v1 in ipairs(tmp) do
      local tmp2 = string.split(v1, "#")
      table.insert(v.star_cost, {
        itemId = tonumber(tmp2[1]),
        num = tonumber(tmp2[2])
      })
    end
    self.m_heroSkillInfos[v.id] = v
    self.m_itemSkillInfos[v.itemId] = {
      skill_id = v.id,
      type = v.type
    }
  end
end
function SkillInfoManager:GetInfo(id)
  return clone(self.m_skillInfos[id])
end
function SkillInfoManager:GetSoldierSkillInfo(id)
  return self.m_soldierSkillInfos[id]
end
function SkillInfoManager:GetHeroSkillInfo(id)
  if id then
    return self.m_heroSkillInfos[id]
  end
  return self.m_heroSkillInfos
end
function SkillInfoManager:GetItemSkillInfo(itemId)
  if itemId then
    return self.m_itemSkillInfos[itemId]
  end
  return self.m_itemSkillInfos
end
function SkillInfoManager:MakeSkillData(skillProto, bNotSelf, boostData)
  local skillData = {
    id = skillProto.id,
    skill_id = skillProto.skill_id,
    star = skillProto.star
  }
  local skillHeroInfo = self:GetHeroSkillInfo(skillProto.skill_id)
  local skillInfo = self:GetInfo(skillProto.skill_id)
  if not skillHeroInfo or not skillInfo then
    td.alertDebug("\230\138\128\232\131\189id\228\184\141\229\173\152\229\156\168:" .. skillProto.skill_id)
    return
  end
  skillData.quality = skillHeroInfo.quality
  skillData.state = 1
  if skillData.star ~= 0 and skillData.star < skillData.quality then
    skillData.itemNeed = skillHeroInfo.star_cost[skillData.star].itemId
    skillData.curNeed = 0
    if not bNotSelf and skillProto.items ~= "" then
      local tmp = string.split(skillProto.items, ",")
      for i, var in ipairs(tmp) do
        local tmp1 = string.split(var, "#")
        if tonumber(tmp1[1]) == skillData.itemNeed then
          skillData.curNeed = tonumber(tmp1[2])
        end
      end
    end
    if skillData.curNeed >= skillHeroInfo.star_cost[skillData.star].num then
      skillData.state = 2
    end
  elseif skillData.star >= skillData.quality then
    skillData.star = skillData.quality
    skillData.itemNeed = skillHeroInfo.star_cost[skillData.star - 1].itemId
    skillData.curNeed = skillHeroInfo.star_cost[skillData.star - 1].num
  end
  if skillData.star > 1 then
    for key, v in pairs(skillHeroInfo.property[skillData.star]) do
      if key == 1 then
        skillInfo.damage_ratio = tonumber(v)
      elseif key == 2 then
        skillInfo.cd = tonumber(v)
      elseif key == 3 then
        skillInfo.get_buff_id = self:_ParseGetBuff(v)
      elseif key == 4 then
        skillInfo.buff_id = self:_ParseBuff(v)
      elseif key == 5 then
        skillInfo.basic_damage = tonumber(v)
      elseif key == 6 then
        skillInfo.custom_data = v
      end
    end
  end
  if boostData then
    local bootstCd = boostData:GetValue(td.BoostType.Skill, skillProto.skill_id)
    skillInfo.cd = skillInfo.cd * ((100 - bootstCd) / 100)
  end
  skillData.skillInfo = skillInfo
  return skillData
end
function SkillInfoManager:GetFinalSkillInfo(skillId, skillLevel, actorType)
  local skillInfo = self:GetInfo(skillId)
  local skillLevelInfo
  if actorType == td.ActorType.Hero then
    skillLevelInfo = self:GetHeroSkillInfo(skillId)
  elseif actorType == td.ActorType.Soldier then
    skillLevelInfo = self:GetSoldierSkillInfo(skillId)
  end
  if skillLevelInfo and skillLevel and skillLevel > 1 then
    for key, v in pairs(skillLevelInfo.property[skillLevel]) do
      if key == 1 then
        skillInfo.damage_ratio = tonumber(v)
      elseif key == 2 then
        skillInfo.cd = tonumber(v)
      elseif key == 3 then
        skillInfo.get_buff_id = self:_ParseGetBuff(v)
      elseif key == 4 then
        skillInfo.buff_id = self:_ParseBuff(v)
      elseif key == 5 then
        skillInfo.basic_damage = tonumber(v)
      elseif key == 6 then
        skillInfo.custom_data = v
      end
    end
  end
  return skillInfo
end
function SkillInfoManager:GetNotLearnSkills(bActive)
  local vResult = {}
  local skillLib = UserDataManager:GetInstance():GetSkillLib()
  for key, var in pairs(self.m_heroSkillInfos) do
    if self:CheckSkillType(bActive, self.m_skillInfos[key].type) then
      local bLearned = false
      for k, v in pairs(skillLib) do
        if key == v.skillInfo.id then
          bLearned = true
          break
        end
      end
      if not bLearned then
        table.insert(vResult, key)
      end
    end
  end
  return vResult
end
function SkillInfoManager:GetIdleHeroSkill(bActive)
  local vResult = {}
  local heroSkills = {}
  local herosdata = UserDataManager:GetInstance():GetHeroData()
  for key, herodata in pairs(herosdata) do
    local skills = {}
    if bActive == nil or bActive == true then
      for i, skillId in ipairs(herodata.activeSkill) do
        table.insert(heroSkills, skillId)
      end
    end
    if bActive == nil or bActive == false then
      for i, skillId in ipairs(herodata.passiveSkill) do
        table.insert(heroSkills, skillId)
      end
    end
  end
  local userSkills = UserDataManager:GetInstance():GetSkillLib()
  for id, var in pairs(userSkills) do
    if self:CheckSkillType(bActive, var.skillInfo.type) and not table.indexof(heroSkills, id) then
      table.insert(vResult, var)
    end
  end
  return vResult
end
function SkillInfoManager:GetLearnSkills(bActive)
  local vResult = {}
  local userSkills = UserDataManager:GetInstance():GetSkillLib()
  for id, var in pairs(userSkills) do
    if self:CheckSkillType(bActive, var.skillInfo.type) then
      table.insert(vResult, var)
    end
  end
  return vResult
end
function SkillInfoManager:CheckSkillType(bActive, type)
  if bActive == nil then
    return true
  end
  if bActive then
    if type == td.SkillType.RandomMagic or type == td.SkillType.FixedMagic then
      return true
    end
  elseif type == td.SkillType.BuffPassive or type == td.SkillType.Passive then
    return true
  end
  return false
end
return SkillInfoManager
