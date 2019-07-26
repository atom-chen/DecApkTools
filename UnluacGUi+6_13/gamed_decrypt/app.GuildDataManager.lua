local TDHttpRequest = require("app.net.TDHttpRequest")
local GameControl = require("app.GameControl")
local GuildDataManager = class("GuildDataManager", GameControl)
GuildDataManager.instance = nil
function GuildDataManager:ctor(eType)
  GuildDataManager.super.ctor(self, eType)
  self:Init()
  self:AddListeners()
end
function GuildDataManager:GetInstance()
  if GuildDataManager.instance == nil then
    GuildDataManager.instance = GuildDataManager.new(td.GameControlType.Login)
  end
  return GuildDataManager.instance
end
function GuildDataManager:Init()
  self.m_guildMemberList = {}
  self.m_guildData = nil
  self.m_data = nil
  self.m_upgAvailable = {}
  self.m_rpMembers = {}
  self.m_appliedGuilds = {}
  self.m_buildingsRP = {
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true
  }
  self.m_guildPVPData = nil
end
function GuildDataManager:ClearValue()
  self:Init()
end
function GuildDataManager:AddListeners()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetGuild, handler(self, self.SendGetGuildCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.CreateGuild, handler(self, self.CreateGuildCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.ModifyGuild, handler(self, self.ModifyGuildCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.ModifyMemberPosition, handler(self, self.ModifyPositionCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetGuildPVPInfo, handler(self, self.SetGuildPVPData))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetGuildPVPDetail, handler(self, self.GetPVPDetailCallback))
end
function GuildDataManager:UpdateData(guildData, members)
  if not guildData then
    self.m_guildData = nil
    self.m_guildMemberList = {}
    self.m_data = nil
    return
  end
  self:SetGuildData(guildData)
  self.m_guildMemberList = members
  local uid = require("app.UserDataManager"):GetInstance():GetUId()
  for i, var in ipairs(members) do
    if var.uid == uid then
      self:SetSelfData(var)
      break
    end
  end
  self.m_appliedGuilds = {}
end
function GuildDataManager:SetGuildData(guildData)
  self.m_guildData = guildData
  if guildData then
    self.m_guildData.builds = {}
    table.insert(self.m_guildData.builds, {
      id = 1,
      level = guildData.level,
      num = guildData.num
    })
    table.insert(self.m_guildData.builds, {
      id = 2,
      level = guildData.weapon_level,
      num = guildData.weapon_num
    })
    table.insert(self.m_guildData.builds, {
      id = 3,
      level = guildData.armor_level,
      num = guildData.armor_num
    })
    table.insert(self.m_guildData.builds, {
      id = 4,
      level = guildData.skill_level,
      num = guildData.skill_num
    })
    table.insert(self.m_guildData.builds, {
      id = 5,
      level = guildData.hero_level,
      num = guildData.hero_num
    })
    table.insert(self.m_guildData.builds, {
      id = 6,
      level = guildData.science_level,
      num = guildData.science_num
    })
    self.m_guildPVPData = require("app.data.GuildPVPData").new()
  end
end
function GuildDataManager:GetGuildData()
  return self.m_guildData
end
function GuildDataManager:SetSelfData(selfData)
  self.m_data = selfData
  self.m_guildPVPData:UpdateTroopData(selfData)
end
function GuildDataManager:GetSelfData()
  return self.m_data
end
function GuildDataManager:GetGuildLevel()
  if self.m_guildData then
    return self.m_guildData.builds[1].level
  end
  return 0
end
function GuildDataManager:GetAppliedGuilds()
  return self.m_appliedGuilds
end
function GuildDataManager:SetAppliedGuilds(id)
  table.insert(self.m_appliedGuilds, id)
end
function GuildDataManager:GetRPMembers()
  return self.m_rpMembers
end
function GuildDataManager:RemoveRPMember(uid)
  for key, val in ipairs(clone(self.m_rpMembers)) do
    if val.uid == uid then
      table.remove(self.m_rpMembers, key)
    end
  end
end
function GuildDataManager:SetBuildingRP(id, isShow)
  self.m_buildingsRP[id] = isShow
end
function GuildDataManager:UpdateBuilding(id, num, level)
  self.m_guildData.builds[id].num = num
  self.m_guildData.builds[id].level = level
end
function GuildDataManager:GetRPBuildings()
  return self.m_buildingsRP
end
function GuildDataManager:AddRPMember(uid)
  table.insert(self.m_rpMembers, uid)
end
function GuildDataManager:GetMemberData(id)
  for i, var in ipairs(self.m_guildMemberList) do
    if var.uid == id then
      return var
    end
  end
end
function GuildDataManager:GetGuildMemberList()
  return self.m_guildMemberList
end
function GuildDataManager:GetBuildingLevel(id)
  return self.m_guildData.builds[id].level
end
function GuildDataManager:SetBuildingNum(id, num)
  self.m_guildData.builds[id].num = num
end
function GuildDataManager:SetGuildMemberList(guildMemberList)
  self.m_guildMemberList = guildMemberList
end
function GuildDataManager:RemoveMember(uid)
  for key, val in ipairs(clone(self.m_guildData)) do
    if val.id == uid then
      table.remove(self.m_guildData, key)
    end
  end
end
function GuildDataManager:CalContribution(itemId, num)
  local exRate = require("app.info.GuildInfoManager"):GetInstance():GetExchangeRate(itemId)
  return exRate * num
end
function GuildDataManager:UpdateContribution(num)
  self.m_data.contribute = self.m_data.contribute + num
  td.dispatchEvent(td.CONTRIBUTION_CHANGED)
end
function GuildDataManager:GetBuildData(id)
  return self.m_guildData.builds[id]
end
function GuildDataManager:SetBuildLevel(id, level)
  self.m_guildData.builds[id].level = level
end
function GuildDataManager:DonateBuild(bid, num)
  local buildData = self.m_guildData.builds[bid]
  buildData.num = num
  self.m_data.num[bid] = self.m_data.num[bid] - 1
end
function GuildDataManager:LearnSkill(skillId)
  local udMng = require("app.UserDataManager"):GetInstance()
  local skillInfo = require("app.info.GuildInfoManager"):GetInstance():GetSkillInfo(skillId)
  local skillLevel = udMng:GetGuildSkillLevel(skillId)
  self:UpdateContribution(-skillInfo.need[skillLevel + 1])
  udMng:UpdateGuildSkill(skillId)
end
function GuildDataManager:GetGuildPVPData()
  return self.m_guildPVPData
end
function GuildDataManager:IsGuildPVPStart()
  local bStart, cdTime = true, 0
  local udMng = require("app.UserDataManager"):GetInstance()
  local serverTime = udMng:GetServerTime()
  local weekday, hour = tonumber(os.date("%w", serverTime)), tonumber(os.date("%H", serverTime))
  if hour < 19 then
    bStart = false
  elseif hour >= 19 and hour < 20 then
    local min, sec = tonumber(os.date("%M", serverTime)), tonumber(os.date("%S", serverTime))
    cdTime = (20 - hour) * 3600 - min * 60 - sec
  end
  return bStart, cdTime
end
function GuildDataManager:SetGuildPVPData(data)
  self.m_guildPVPData:UpdatePVPData(data.guild1Proto)
  for i, member in ipairs(data.guildMemberProto) do
    self.m_guildPVPData:UpdateMemberData(member)
  end
  td.dispatchEvent(td.GUILD_PVP_INFO_UPDATE)
end
function GuildDataManager:GetGuildPVPData()
  return self.m_guildPVPData
end
function GuildDataManager:GetPendingMembers()
  local aList = {}
  if self.m_guildMemberList then
    for key, val in ipairs(self.m_guildMemberList) do
      if val.type == td.GuildPos.Pending then
        table.insert(aList, val)
      end
    end
  end
  return aList
end
function GuildDataManager:RemovePendingMember(_uid, isReject)
  for key, val in ipairs(clone(self.m_guildMemberList)) do
    if val.uid == _uid then
      if isReject then
        table.remove(self.m_guildMemberList, key)
      else
        val.type = td.GuildPos.Member
      end
    end
  end
end
function GuildDataManager:CreateGuildCallback(data)
  if #data.guildMemberProto > 0 then
    self:UpdateData(data.guildProto, data.guildMemberProto)
    td.dispatchEvent(td.GUILD_UPDATE)
  end
end
function GuildDataManager:SendGetGuildRequest(isInit)
  local Msg = {}
  Msg.msgType = td.RequestID.GetGuild
  Msg.cbData = isInit
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildDataManager:SendGetGuildCallback(data, cbData)
  if #self.m_guildMemberList > 0 and #data.guildMemberProto > #self.m_guildMemberList then
    self.m_rpMembers = clone(data.guildMemberProto)
    for i, val in ipairs(data.guildMemberProto) do
      for j, member in ipairs(self.m_guildMemberList) do
        if val.uid == member.uid then
          table.remove(self.m_rpMembers, i)
        end
      end
    end
  end
  if 0 < #data.guildMemberProto then
    self:UpdateData(data.guildProto, data.guildMemberProto)
  else
    self:UpdateData(nil, {})
  end
  if not cbData then
    td.dispatchEvent(td.GUILD_UPDATE)
  else
    td.dispatchEvent(td.GUILD_LISTS_REFRESH)
  end
end
function GuildDataManager:SendModifyGuildRequest(data)
  local Msg = {}
  Msg.msgType = td.RequestID.ModifyGuild
  Msg.sendData = data
  Msg.cbData = {}
  if data.guild_type then
    Msg.cbData = {
      type = "type",
      data = data.guild_type
    }
  elseif data.notice then
    Msg.cbData = {
      type = "notice",
      data = data.notice
    }
  end
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildDataManager:ModifyGuildCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    if cbData.type == "notice" then
      self.m_guildData.notice = cbData.data
      print(self.m_guildData.notice)
      td.dispatchEvent(td.GUILD_NOTICE_CHANGED, cbData.data)
    else
      self.m_guildData.audit = cbData.data
      print(self.m_guildData.audit)
      print("\229\134\155\229\155\162\231\155\174\229\137\141\231\177\187\229\158\139\228\184\186" .. self.m_guildData.audit)
      td.dispatchEvent(td.GUILD_TYPE_CHANGED, cbData.data)
    end
  end
end
function GuildDataManager:SendRequest(data, reqID)
  local Msg = {}
  Msg.msgType = reqID
  Msg.sendData = data
  Msg.cbData = clone(data)
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildDataManager:ModifyPositionCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    local targetType = cbData.type
    self:GetMemberData(cbData.uid).type = cbData.type
    if targetType == td.GuildPos.Master then
      self:GetSelfData().type = td.GuildPos.ViceMaster
    elseif targetType == 0 then
      for i, member in ipairs(clone(self.m_guildMemberList)) do
        if member.uid == cbData.uid then
          table.remove(self.m_guildMemberList, i)
        end
      end
    end
  else
    td.alertDebug(g_LM:getBy("a00322"))
  end
  td.dispatchEvent(td.GUILD_RANK_CHANGED)
end
function GuildDataManager:GetPVPDetailReq()
  local Msg = {}
  Msg.msgType = td.RequestID.GetGuildPVPDetail
  Msg.sendData = {
    team_id = self.m_guildPVPData:GetValue("battleId")
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildDataManager:GetPVPDetailCallback(data, cbData)
  for i, var in ipairs(data.guildProto) do
    self.m_guildPVPData:UpdateResData(var)
  end
  for key, var in ipairs(data.guildBattleProto) do
    self.m_guildPVPData:UpdateBattlePosData(var)
  end
  td.dispatchEvent(td.GUILD_PVP_UPDATE)
end
return GuildDataManager
