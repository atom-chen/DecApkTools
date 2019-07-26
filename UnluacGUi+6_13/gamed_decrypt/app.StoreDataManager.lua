local UserDataManager = require("app.UserDataManager")
local GameControl = require("app.GameControl")
local StoreDataManager = class("StoreDataManager", GameControl)
StoreDataManager.instance = nil
StoreDataManager.UPDATE_TIME = 600
function StoreDataManager:ctor(eType)
  StoreDataManager.super.ctor(self, eType)
end
function StoreDataManager:GetInstance()
  if StoreDataManager.instance == nil then
    StoreDataManager.instance = StoreDataManager.new(td.GameControlType.Login)
  end
  return StoreDataManager.instance
end
function StoreDataManager:InitData()
end
function StoreDataManager:CheckRP()
  local bResult, vIndex = false, {}
  if self:CheckStoreRefresh() then
    bResult = true
    table.insert(vIndex, 1)
  end
  if self:CheckDiamondLottery() or self:CheckGoldLottery() then
    bResult = true
    table.insert(vIndex, 2)
  end
  return bResult, vIndex
end
function StoreDataManager:UpdateOpenStoreDate()
  local udMng = UserDataManager:GetInstance()
  local serverTime = udMng:GetServerTime()
  g_LD:SetStr("openStore", tostring(serverTime))
end
function StoreDataManager:CheckStoreRefresh()
  local udMng = UserDataManager:GetInstance()
  local lastOpenTime = tonumber(g_LD:GetStr("openStore"))
  if lastOpenTime and lastOpenTime ~= 0 then
    local serverTime = udMng:GetServerTime()
    if td.TimeCompare(serverTime, lastOpenTime) then
      return true
    end
    return false
  end
  return true
end
function StoreDataManager:CheckDiamondLottery()
  if self:GetFreeLotteryGap(td.LotteryType.DiamondOne) == 0 then
    return true
  end
  return false
end
function StoreDataManager:CheckGoldLottery()
  if self:GetFreeLotteryGap(td.LotteryType.GoldOne) == 0 then
    return true
  end
  return false
end
function StoreDataManager:GetFreeLotteryGap(_type)
  local udMng = UserDataManager:GetInstance()
  local serverTime = udMng:GetServerTime()
  local lastTime, freeGap
  if _type == td.LotteryType.DiamondOne then
    lastTime = udMng:GetUserDetail().diamond_time
    freeGap = td.DiamondLotteryTimeGap
  elseif _type == td.LotteryType.GoldOne then
    lastTime = udMng:GetUserDetail().gold_time
    freeGap = td.GoldLotteryTimeGap
  end
  if lastTime and freeGap then
    return cc.clampf(freeGap - (serverTime - lastTime), 0, freeGap)
  else
    return 99999999
  end
end
return StoreDataManager
