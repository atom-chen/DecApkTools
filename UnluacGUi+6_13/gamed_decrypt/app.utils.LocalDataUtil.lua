local LocalDataUtil = class("LocalDataUtil")
LocalDataUtil.instance = nil
function LocalDataUtil:ctor()
  self.cryptoKey = "1qaz2wsx3edc"
end
function LocalDataUtil:GetInstance()
  if LocalDataUtil.instance == nil then
    LocalDataUtil.instance = LocalDataUtil.new()
  end
  return LocalDataUtil.instance
end
function LocalDataUtil:SetAccount(acc, psw)
  local oriAcc, oriPsw = self:GetAccount()
  if oriAcc == acc and oriPsw == psw then
    return
  end
  local encAcc = acc
  local encPsw = psw
  self:SetStr("uname", encAcc)
  self:SetStr("pwd", encPsw)
end
function LocalDataUtil:GetAccount()
  local acc = self:GetStr("uname")
  local psw = self:GetStr("pwd")
  if acc == "" and psw == "" then
    return "", ""
  end
  return acc, psw
end
function LocalDataUtil:SetServer(serverId)
  local lastServer = self:GetInt("lastServer", 0)
  if serverId ~= lastServer then
    self:SetInt("lastServer", serverId)
    self:SetStr("chat", "")
    self:ClearAccountData()
  end
end
function LocalDataUtil:SetUId(uid)
  local lastUid = self:GetStr("uid", "")
  if uid ~= lastUid then
    self:SetStr("uid", uid)
    self:ClearAccountData()
  end
end
function LocalDataUtil:ClearAccountData()
  self:SetInt("bomb_hero", 0)
  self:SetStr("openStore", "0")
  self:SetStr("soldier_sel", "")
end
function LocalDataUtil:SetInt(key, value)
  cc.UserDefault:getInstance():setIntegerForKey(key, value)
end
function LocalDataUtil:GetInt(key, default)
  default = default or 0
  return cc.UserDefault:getInstance():getIntegerForKey(key, default)
end
function LocalDataUtil:SetStr(key, value)
  cc.UserDefault:getInstance():setStringForKey(key, value)
end
function LocalDataUtil:GetStr(key, default)
  default = default or ""
  return cc.UserDefault:getInstance():getStringForKey(key, default)
end
g_LD = g_LD or LocalDataUtil:GetInstance()
