local UserDataManager = require("app.UserDataManager")
local GuildDataManager = require("app.GuildDataManager")
local GuildPVPData = class("GuildPVPData")
function GuildPVPData:ctor()
  self:InitData()
end
function GuildPVPData:InitData()
  local udMng = UserDataManager:GetInstance()
  local guildMng = GuildDataManager:GetInstance()
  self.m_data = {}
  self.m_data.guildId = guildMng:GetGuildData().id
  self.m_data.selfId = udMng:GetUId()
  self.m_data.battleId = nil
  self.m_data.battleState = td.GuildPVPState.NotOver
  self.m_data.enemyGuild = {}
  self.m_data.battlePos = {}
  self.m_data.isIn = false
  self.m_data.totalRes = 0
  self.m_data.totalEnemyRes = 0
  self.m_data.members = {}
  self.m_data.hero_item = {}
  self.m_data.soldier_item = {}
  self.m_data.fightingIndex = nil
  self.m_data.enemyData = nil
  self.m_data.logId = nil
end
function GuildPVPData:UpdatePVPData(vData)
  local selfWin, enemyWin = 0, 0
  for i, data in ipairs(vData) do
    if data.guild_id ~= self.m_data.guildId then
      self.m_data.enemyGuild.name = data.name
      self.m_data.enemyGuild.head = data.image_id
      enemyWin = data.win
    else
      selfWin = data.win
    end
    self.m_data.battleId = data.team_id
    self:UpdateResData(data)
  end
  if enemyWin < selfWin then
    self.m_data.battleState = td.GuildPVPState.Win
  elseif enemyWin > selfWin then
    self.m_data.battleState = td.GuildPVPState.Lose
  end
end
function GuildPVPData:UpdateBattlePosData(data)
  local posData
  if data.uid and data.uid ~= "" then
    posData = {}
    posData.isSelf = data.guild_id == self.m_data.guildId
    posData.id = data.uid
    posData.name = data.uname
    posData.head = data.image_id
    posData.power = data.max_attack
    posData.win = data.win_num
    posData.atkedTime = data.battle_time
    posData.startTime = data.c_time
    posData.attack_uid = data.attack_uid
  end
  self.m_data.battlePos[data.index] = posData
  self:_CheckSelfIn()
end
function GuildPVPData:UpdateTroopData(data)
  if data then
    self.m_data.hero_item = {}
    if data.hero_item ~= "" then
      local tmp = string.split(data.hero_item, ";")
      for i, v in ipairs(tmp) do
        local t1 = string.split(v, ":")
        table.insert(self.m_data.hero_item, {
          id = tonumber(t1[1]),
          x = tonumber(t1[2]),
          y = tonumber(t1[3])
        })
      end
    end
    self.m_data.soldier_item = {}
    if data.soldier_item ~= "" then
      local tmp = string.split(data.soldier_item, ";")
      for i, v in ipairs(tmp) do
        local t1 = string.split(v, ":")
        table.insert(self.m_data.soldier_item, {
          id = tonumber(t1[1]),
          x = tonumber(t1[2]),
          y = tonumber(t1[3])
        })
      end
    end
  end
end
function GuildPVPData:UpdateResData(data)
  if data.guild_id == self.m_data.guildId then
    self.m_data.totalRes = data.guild_num
  else
    self.m_data.totalEnemyRes = data.guild_num
  end
end
function GuildPVPData:UpdateMemberData(data)
  self.m_data.members[data.uid] = clone(data)
  self.m_data.members[data.uid].isSelf = data.guild_id == self.m_data.guildId
end
function GuildPVPData:GetMemberData(uid)
  return self.m_data.members[uid]
end
function GuildPVPData:SetEnemyPVPData(otherArena)
  if otherArena then
    local siMng = require("app.info.StrongInfoManager"):GetInstance()
    local otherData = {}
    otherData.reputation = otherArena.reputation
    local vGuildSkill = {}
    if otherArena.guildSkill then
      for j, var in ipairs(otherArena.guildSkill) do
        local guildSkill = {
          id = var.id,
          level = var.level
        }
        vGuildSkill[guildSkill.id] = guildSkill
      end
    end
    otherData.boostData = require("app.data.BoostData").new(vGuildSkill)
    local SkillInfoManager = require("app.info.SkillInfoManager")
    otherData.skills = {}
    if otherArena.skillProto then
      for j, var in ipairs(otherArena.skillProto) do
        local skillData = SkillInfoManager:GetInstance():MakeSkillData(var, true, otherData.boostData)
        otherData.skills[skillData.id] = skillData
      end
    end
    otherData.weapons = {}
    if otherArena.weapons then
      for j, var in ipairs(otherArena.weapons) do
        local weaponData = siMng:MakeWeaponData(var)
        otherData.weapons[weaponData.id] = weaponData
      end
    end
    otherData.heros = {}
    otherData.hero_item = {}
    if otherArena.heros then
      for j, var in ipairs(otherArena.heros) do
        local heroData = siMng:MakeHeroData(var, otherData.boostData)
        otherData.heros[heroData.hid] = heroData
        table.insert(otherData.hero_item, {
          id = var.hid,
          x = var.x,
          y = var.y
        })
      end
    end
    otherData.soldiers = {}
    if otherArena.arenaRoleProto then
      for j, var in ipairs(otherArena.arenaRoleProto) do
        local soldierData = siMng:MakeSoldierData(var, otherData.boostData)
        otherData.soldiers[soldierData.role_id] = soldierData
      end
    end
    otherData.soldier_item = {}
    if otherArena.soldier_item == "" and #otherData.hero_item == 0 then
      otherArena.soldier_item = require("app.config.pvp_config")
    end
    if otherArena.soldier_item ~= "" then
      local tmp = string.split(otherArena.soldier_item, ";")
      for i, v in ipairs(tmp) do
        local t1 = string.split(v, ":")
        table.insert(otherData.soldier_item, {
          id = tonumber(t1[1]),
          x = tonumber(t1[2]),
          y = tonumber(t1[3])
        })
      end
    end
    self.m_data.enemyData = otherData
  end
end
function GuildPVPData:UpdateValue(key, value)
  self.m_data[key] = value
end
function GuildPVPData:GetValue(key)
  return self.m_data[key]
end
function GuildPVPData:_CheckSelfIn()
  local bIsSelfIn = false
  for key, var in pairs(self.m_data.battlePos) do
    if var.id == self.m_data.selfId then
      bIsSelfIn = true
      break
    end
  end
  self.m_data.isIn = bIsSelfIn
end
return GuildPVPData
