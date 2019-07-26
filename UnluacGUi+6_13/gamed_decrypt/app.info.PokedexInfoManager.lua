local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local TDHttpRequest = require("app.net.TDHttpRequest")
local PokedexInfoManager = class("PokedexInfoManager", GameControl)
PokedexInfoManager.instance = nil
local PokedexTypes = {
  Soldier = 0,
  Hero = 1,
  Monster = 2,
  Item = 3
}
PokedexInfoManager.NotShowVec = {
  9006,
  9007,
  9008,
  9009
}
function PokedexInfoManager:ctor(eType)
  PokedexInfoManager.super.ctor(self, eType)
  self:Init()
end
function PokedexInfoManager:GetInstance()
  if PokedexInfoManager.instance == nil then
    PokedexInfoManager.instance = PokedexInfoManager.new(td.GameControlType.ExitGame)
  end
  return PokedexInfoManager.instance
end
function PokedexInfoManager:Init()
  self.m_Infos = {}
  self.m_InfosSort = {}
  self:SaveInfo()
end
function PokedexInfoManager:ClearValue()
end
function PokedexInfoManager:SaveInfo()
  local vData = CSVLoader.loadCSV("Config/pokedex.csv")
  for i, v in ipairs(vData) do
    local type = -1
    if v.id >= 101 and v.id <= 999 then
      type = 0
    elseif v.id >= 1000 and v.id <= 4999 then
      type = 1
    elseif v.id >= 5000 and v.id <= 9999 then
      type = 2
    elseif v.id >= 10000 then
      type = 3
    end
    assert(type ~= -1)
    if not self.m_Infos[type] then
      self.m_Infos[type] = {}
      self.m_InfosSort[type] = {}
    end
    self.m_Infos[type][v.id] = v
    table.insert(self.m_InfosSort[type], v.id)
  end
end
function PokedexInfoManager:GetInfo(type, id)
  if self.m_Infos[type] then
    return self.m_Infos[type][id]
  end
  return nil
end
function PokedexInfoManager:GetInfoForType(type)
  return self.m_Infos[type]
end
function PokedexInfoManager:GetInfoSortForType(type)
  return self.m_InfosSort[type]
end
function PokedexInfoManager:UnlockRole(event)
  local data = tonumber(event:getDataString())
  if not self.m_Infos[0][data] then
    return
  end
  self.m_Infos[0][data].start_unlock = 0
end
function PokedexInfoManager:IsUnlocked(_type, id)
  local userData = require("app.UserDataManager"):GetInstance():GetUserData()
  if userData.pokedex[_type][id] == 1 then
    return true
  end
  return false
end
function PokedexInfoManager:CanUnlock(_type, id)
  local userData = require("app.UserDataManager"):GetInstance():GetUserData()
  if userData.pokedex[_type][id] == 1 then
    return false
  end
  if _type == td.PokedexType.Monster and table.indexof(PokedexInfoManager.NotShowVec, id) then
    return false
  end
  return true
end
function PokedexInfoManager:SendAddCardRequest(cards)
  local userData = require("app.UserDataManager"):GetInstance():GetUserData()
  local data = {}
  data.cardProts = {}
  for _type, vec in pairs(cards) do
    if #vec > 0 then
      table.insert(data.cardProts, {type = _type, itemId = vec})
      for i, id in ipairs(vec) do
        userData.pokedex[_type][id] = 1
      end
    end
  end
  if #data.cardProts > 0 then
    local Msg = {}
    Msg.msgType = td.RequestID.AddCardRequest
    Msg.sendData = data
    TDHttpRequest:getInstance():Send(Msg)
  end
end
return PokedexInfoManager
