local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local TDHttpRequest = require("app.net.TDHttpRequest")
local BaseInfoManager = class("BaseInfoManager", GameControl)
BaseInfoManager.instance = nil
function BaseInfoManager:ctor(eType)
  BaseInfoManager.super.ctor(self, eType)
  self:Init()
end
function BaseInfoManager:GetInstance()
  if BaseInfoManager.instance == nil then
    BaseInfoManager.instance = BaseInfoManager.new(td.GameControlType.ExitGame)
  end
  return BaseInfoManager.instance
end
function BaseInfoManager:Init()
  self.m_baseInfos = {}
  self.m_arenashopInfos = {}
  self.m_openInfos = {}
  self:SaveInfo()
end
function BaseInfoManager:ClearValue()
end
function BaseInfoManager:SaveInfo()
  local vData = CSVLoader.loadCSV("Config/base.csv")
  for i, v in ipairs(vData) do
    v.next_level_unlock = string.split(v.next_level_unlock, "#")
    local tmp = {}
    for j, var in ipairs(v.next_level_unlock) do
      table.insert(tmp, tonumber(var))
    end
    v.next_level_unlock = tmp
    self.m_baseInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/arena_shop.csv")
  for i, v in ipairs(vData) do
    self.m_arenashopInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/open.csv")
  for i, v in ipairs(vData) do
    local strVec = string.split(v.open_condition, "#")
    local t = {}
    if strVec[1] == "1" then
      t.baseLevel = tonumber(strVec[2])
    elseif strVec[1] == "2" then
      t.missionId = tonumber(strVec[2])
    elseif strVec[1] == "3" then
      t.baseLevel = tonumber(strVec[2])
      t.missionId = tonumber(strVec[3])
    end
    self.m_openInfos[v.id] = t
  end
end
function BaseInfoManager:GetBaseInfo(id)
  return self.m_baseInfos[id]
end
function BaseInfoManager:GetArenashopInfos()
  return self.m_arenashopInfos
end
function BaseInfoManager:GetArenashopInfo(id)
  return self.m_arenashopInfos[id]
end
function BaseInfoManager:GetOpenInfo(id)
  return self.m_openInfos[id]
end
function BaseInfoManager:sendBaseCmpUpgradeRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.BaseCampUpgrade_req
  Msg.sendData = nil
  TDHttpRequest:getInstance():Send(Msg)
end
function BaseInfoManager:checkBaseCampHasFullLevel(campLevel)
  local nextInfo = self:GetBaseInfo(campLevel + 1)
  if nextInfo then
    return false
  end
  return true
end
function BaseInfoManager:checkBaseCampCanUpgrade(campLevel)
  local rtnTag, errorCode = true, td.ErrorCode.SUCCESS
  if self:checkBaseCampHasFullLevel(campLevel) then
    rtnTag = false
    errorCode = td.ErrorCode.LEVEL_MAX
  else
    local hasYL = require("app.UserDataManager"):GetInstance():GetUserDetail().campExp or 0
    local needYL = self:GetBaseInfo(campLevel).exp or 0
    if hasYL < needYL then
      rtnTag = false
      errorCode = td.ErrorCode.EXP_NOT_ENOUGH
    else
    end
  end
  return rtnTag, errorCode
end
return BaseInfoManager
