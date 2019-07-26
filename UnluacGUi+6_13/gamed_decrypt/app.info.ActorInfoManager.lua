local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local UserDataManager = require("app.UserDataManager")
local ActorInfoManager = class("ActorInfoManager", GameControl)
ActorInfoManager.instance = nil
function ActorInfoManager:ctor(eType)
  ActorInfoManager.super.ctor(self, eType)
  self:Init()
end
function ActorInfoManager:GetInstance()
  if ActorInfoManager.instance == nil then
    ActorInfoManager.instance = ActorInfoManager.new(td.GameControlType.ExitGame)
  end
  return ActorInfoManager.instance
end
function ActorInfoManager:Init()
  self.m_HeroInfos = {}
  self.m_MonsterInfos = {}
  self.m_SoldierInfos = {}
  self.m_CampInfos = {}
  self.m_TowerInfos = {}
  self:SaveHeroInfo()
  self:SaveMonsterInfo()
  self:SaveSoldierInfo()
  self:SaveCampInfo()
  self:SaveTowerInfo()
end
function ActorInfoManager:ClearValue()
end
function ActorInfoManager:MakeProperties(info)
  local properties = {}
  local propNames = {
    "hp",
    "attack",
    "def",
    "move_speed",
    "attack_speed",
    "crit_rate",
    "dodge_rate"
  }
  local propTypes = {
    td.Property.HP,
    td.Property.Atk,
    td.Property.Def,
    td.Property.Speed,
    td.Property.AtkSp,
    td.Property.Crit,
    td.Property.Dodge
  }
  for i, propName in ipairs(propNames) do
    local _value = info[propName] or 0
    if type(_value) == "string" then
      local tmp = string.split(_value, "#")
      properties[propTypes[i]] = {
        value = tonumber(tmp[1]),
        ratio = tonumber(tmp[2])
      }
    else
      properties[propTypes[i]] = {value = _value, ratio = 0}
    end
  end
  properties[td.Property.SuckHp] = {value = 0, ratio = 0}
  properties[td.Property.Reflect] = {value = 0, ratio = 0}
  return properties
end
function ActorInfoManager:SaveHeroInfo()
  local vHeroData = CSVLoader.loadCSV("Config/hero.csv")
  for i, v in ipairs(vHeroData) do
    v.name = g_LM:getBy(v.name)
    v.property = self:MakeProperties(v)
    local skillsStr = string.split(v.skill, "#")
    v.skill = {}
    v.basic_skill = {}
    for j, var in ipairs(skillsStr) do
      if j == #skillsStr then
        table.insert(v.skill, tonumber(var))
      else
        table.insert(v.basic_skill, tonumber(var))
      end
    end
    local tmp = string.split(v.star_cost, ";")
    v.star_cost = {}
    for j, v1 in ipairs(tmp) do
      local p = {}
      local tmp1 = string.split(v1, "|")
      for k, v2 in ipairs(tmp1) do
        local tmp2 = string.split(v2, "#")
        table.insert(p, {
          itemId = tonumber(tmp2[1]),
          num = tonumber(tmp2[2])
        })
      end
      table.insert(v.star_cost, p)
    end
    if v.unlock == "" then
      v.unlock = {}
    else
      tmp = string.split(v.unlock, "|")
      local items = {}
      for i, itemStr in ipairs(tmp) do
        local itemDetail = string.split(itemStr, "#")
        local item = {}
        item.itemId = tonumber(itemDetail[1])
        item.num = tonumber(itemDetail[2])
        table.insert(items, item)
      end
      v.unlock = items
    end
    self.m_HeroInfos[v.id] = v
  end
end
function ActorInfoManager:SaveMonsterInfo()
  local vMonster = CSVLoader.loadCSV("Config/monster.csv")
  for i, v in ipairs(vMonster) do
    v.name = g_LM:getBy(v.name)
    v.desc = g_LM:getBy(v.desc)
    v.property = self:MakeProperties(v)
    local skillsStr = string.split(v.skill, "#")
    v.skill = {}
    for j, var in ipairs(skillsStr) do
      table.insert(v.skill, tonumber(var))
    end
    self.m_MonsterInfos[v.id] = v
  end
end
function ActorInfoManager:SaveSoldierInfo()
  local vData = CSVLoader.loadCSV("Config/role_detail.csv")
  for i, v in ipairs(vData) do
    v.name = g_LM:getBy(v.name)
    v.desc = g_LM:getBy(v.desc)
    v.ro_desc = g_LM:getBy(v.ro_desc)
    v.profile = g_LM:getBy(v.profile)
    v.property = self:MakeProperties(v)
    local skillsStr = string.split(v.skill, "#")
    v.skill = {}
    for j, var in ipairs(skillsStr) do
      table.insert(v.skill, tonumber(var))
    end
    self.m_SoldierInfos[v.id] = v
  end
end
function ActorInfoManager:SaveCampInfo()
  local vCamp = CSVLoader.loadCSV("Config/camp.csv")
  for i, v in ipairs(vCamp) do
    v.name = g_LM:getBy(v.name)
    v.desc = g_LM:getBy(v.desc)
    v.property = self:MakeProperties(v)
    self.m_CampInfos[v.id] = v
  end
end
function ActorInfoManager:SaveTowerInfo()
  local vTower = CSVLoader.loadCSV("Config/tower.csv")
  for i, v in ipairs(vTower) do
    v.property = self:MakeProperties(v)
    local skillsStr = string.split(v.skill, "#")
    v.skill = {}
    for j, var in ipairs(skillsStr) do
      table.insert(v.skill, tonumber(var))
    end
    self.m_TowerInfos[v.id] = v
  end
end
function ActorInfoManager:GetHeroInfos()
  return clone(self.m_HeroInfos)
end
function ActorInfoManager:GetHeroInfo(id)
  return clone(self.m_HeroInfos[id])
end
function ActorInfoManager:GetMonsterInfos()
  return clone(self.m_MonsterInfos)
end
function ActorInfoManager:GetMonsterInfo(id)
  return clone(self.m_MonsterInfos[id])
end
function ActorInfoManager:GetSoldierInfos()
  return clone(self.m_SoldierInfos)
end
function ActorInfoManager:GetSoldierInfo(id)
  return clone(self.m_SoldierInfos[id])
end
function ActorInfoManager:GetCampInfo(id)
  return clone(self.m_CampInfos[id])
end
function ActorInfoManager:GetTowerInfo(id)
  return clone(self.m_TowerInfos[id])
end
function ActorInfoManager:GetAllRoleCnt()
  return table.nums(self.m_SoldierInfos)
end
function ActorInfoManager:GetAllRoleIds()
  local result = {}
  for id, value in pairs(self.m_SoldierInfos) do
    table.insert(result, id)
  end
  return result
end
return ActorInfoManager
