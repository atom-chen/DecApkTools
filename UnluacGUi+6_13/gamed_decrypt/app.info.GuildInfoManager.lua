local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local TDHttpRequest = require("app.net.TDHttpRequest")
local GuildInfoManager = class("GuildInfoManager", GameControl)
GuildInfoManager.instance = nil
function GuildInfoManager:ctor(eType)
  GuildInfoManager.super.ctor(self, eType)
  self:Init()
end
function GuildInfoManager:GetInstance()
  if GuildInfoManager.instance == nil then
    GuildInfoManager.instance = GuildInfoManager.new(td.GameControlType.ExitGame)
  end
  return GuildInfoManager.instance
end
function GuildInfoManager:Init()
  self.m_buildInfos = {}
  self.m_skillInfos = {}
  self.m_exchangeRates = {}
  self.m_bossInfos = {}
  self.m_bossAwardInfos = {}
  self:SaveInfo()
end
function GuildInfoManager:SaveInfo()
  local vData = CSVLoader.loadCSV("Config/league.csv")
  for i, v in ipairs(vData) do
    local tmp = string.split(v.pos, "#")
    v.pos = cc.p(tonumber(tmp[1]), tonumber(tmp[2]))
    tmp = string.split(v.donate, "#")
    v.donate = {
      tonumber(tmp[1]),
      tonumber(tmp[2]),
      tonumber(tmp[3])
    }
    tmp = string.split(v.need, "#")
    v.need = {}
    for i, var in ipairs(tmp) do
      table.insert(v.need, tonumber(var))
    end
    if v.skills == "" then
      v.skills = {}
    else
      local tmp = string.split(v.skills, "#")
      v.skills = {}
      for i, var in ipairs(tmp) do
        table.insert(v.skills, tonumber(var))
      end
    end
    v.name = g_LM:getBy(v.name) or v.name
    self.m_buildInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/league_skill.csv")
  for i, v in ipairs(vData) do
    if v.need ~= "" then
      local tmp = string.split(v.need, "#")
      v.need = {}
      for i, var in ipairs(tmp) do
        table.insert(v.need, tonumber(var))
      end
    end
    if v.type_param ~= "" then
      local tmp = string.split(v.type_param, "#")
      v.type_param = {}
      for i, var in ipairs(tmp) do
        table.insert(v.type_param, tonumber(var))
      end
    end
    v.desc = g_LM:getBy(v.desc) or v.desc
    self.m_skillInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/league_donate.csv")
  for i, v in ipairs(vData) do
    self.m_exchangeRates[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/league_boss.csv")
  for i, v in ipairs(vData) do
    self.m_bossInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/boss_award.csv")
  for i, v in ipairs(vData) do
    local tmp = string.split(v.level, "#")
    for k, val in ipairs(tmp) do
      tmp[k] = tonumber(val)
      v.level = tmp
    end
    tmp = string.split(v.award, "|")
    v.award = {}
    for j, var in ipairs(tmp) do
      local tmp1 = string.split(var, "#")
      local award = {
        itemId = tonumber(tmp1[1]),
        num = tonumber(tmp1[2])
      }
      table.insert(v.award, award)
    end
    self.m_bossAwardInfos[v.id] = v
  end
end
function GuildInfoManager:GetBuildingInfo(id)
  return self.m_buildInfos[id]
end
function GuildInfoManager:GetSkillInfo(id)
  if id then
    return self.m_skillInfos[id]
  end
  return self.m_skillInfos
end
function GuildInfoManager:GetExchangeRate(id)
  if not self.m_exchangeRates[id] then
    return 0
  end
  return self.m_exchangeRates[id].exchange
end
function GuildInfoManager:GetBossInfo(id)
  return self.m_bossInfos[id]
end
function GuildInfoManager:GetBossAwardInfo(rank)
  if not rank then
    return self.m_bossAwardInfos
  else
    for i, val in ipairs(self.m_bossAwardInfos) do
      local min, max = self.m_bossAwardInfos[i], nil
      if rank <= max and rank >= min then
        return self.m_bossAwardInfos[i]
      end
    end
  end
end
return GuildInfoManager
