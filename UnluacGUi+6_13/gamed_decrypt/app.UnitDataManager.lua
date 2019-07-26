local TDHttpRequest = require("app.net.TDHttpRequest")
local GameControl = require("app.GameControl")
local UserDataManager = require("app.UserDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local UnitDataManager = class("UnitDataManager", GameControl)
UnitDataManager.instance = nil
function UnitDataManager:ctor(eType)
  UnitDataManager.super.ctor(self, eType)
  self:Init()
  self:AddListeners()
end
function UnitDataManager:GetInstance()
  if UnitDataManager.instance == nil then
    UnitDataManager.instance = UnitDataManager.new(td.GameControlType.Login)
  end
  return UnitDataManager.instance
end
function UnitDataManager:Init()
  self.vSoldiersData = {}
  self.vSoldierNum = {}
  self.vSoldierPlan = {}
end
function UnitDataManager:ClearValue()
  self:Init()
end
function UnitDataManager:Update(dt)
  for roleId, plan in pairs(self.vSoldierPlan) do
    if plan.num > 0 then
      plan.curTime = math.max(plan.curTime - dt, 0)
      if 0 >= plan.curTime then
        plan.curTime = plan.costTime
        plan.num = plan.num - 1
        self:UpdateSoldierNum(roleId, 1)
      end
    end
  end
end
function UnitDataManager:AddListeners()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetSoldiers, handler(self, self.GetSoldiersCallback))
end
function UnitDataManager:GetSoldierNum(roleId)
  return self.vSoldierNum[roleId] or 0
end
function UnitDataManager:UpdateSoldierNum(roleId, num)
  if not self.vSoldierNum[roleId] then
    self.vSoldierNum[roleId] = 0
  end
  self.vSoldierNum[roleId] = self.vSoldierNum[roleId] + num
  if self.vSoldierNum[roleId] < 0 then
    self.vSoldierNum[roleId] = 0
    td.alertDebug("warning:\229\163\171\229\133\181\230\149\176\233\135\143\229\176\143\228\186\1420")
  end
  td.dispatchEvent(td.SOLDIER_NUM_UPDATE, roleId)
end
function UnitDataManager:UpdateSoldierData(data)
  local udMng = UserDataManager:GetInstance()
  local soldierData = StrongInfoManager:GetInstance():MakeSoldierData(data, udMng:GetBoostData())
  self.vSoldiersData[soldierData.role_id] = soldierData
  UserDataManager:GetInstance():UpdateTotalPower()
end
function UnitDataManager:GetSoldierData(roldId)
  if roldId then
    return self.vSoldiersData[roldId]
  end
  return self.vSoldiersData
end
function UnitDataManager:UnlockSoldier(id)
  local soldierData = {
    role_id = id,
    star = 1,
    level = 1,
    exp = 0,
    skill_level = 1
  }
  self:UpdateSoldierData(soldierData)
end
function UnitDataManager:UpdateSoldierSkill(id)
  local soldierData = self:GetSoldierData(id)
  soldierData.skill_level = soldierData.skill_level + 1
end
function UnitDataManager:GetPlan(roleId)
  return self.vSoldierPlan[roleId]
end
function UnitDataManager:UpdatePlan(roleId, num)
  local bSuccess, errorCode = self:CheckPlan(roleId, num)
  if not bSuccess then
    td.alertErrorMsg(errorCode)
    return
  end
  return self:_UpdatePlan(roleId, num)
end
function UnitDataManager:_UpdatePlan(roleId, num)
  local info = StrongInfoManager:GetInstance():GetSoldierStrongInfo(roleId)
  if not self.vSoldierPlan[roleId] then
    local plan = {
      id = roleId,
      num = 0,
      costTime = info.create_time,
      curTime = info.create_time
    }
  end
  plan.num = plan.num + num
  if plan.num == 0 then
    self.vSoldierPlan[roleId] = nil
  else
    self.vSoldierPlan[roleId] = plan
  end
  return plan
end
function UnitDataManager:CompletePlanInstantly(roleId)
  local plan = self.vSoldierPlan[roleId]
  if not plan then
    return
  end
  self:UpdateSoldierNum(roleId, plan.num)
  self.vSoldierPlan[roleId] = nil
end
function UnitDataManager:CheckPlan(roleId, num)
  local info = StrongInfoManager:GetInstance():GetSoldierStrongInfo(roleId)
  if not self.vSoldierPlan[roleId] then
    local plan = {
      id = roleId,
      num = 0,
      costTime = info.create_time,
      curTime = info.create_time
    }
  end
  if plan.num + num > td.GetConst("queue_size") then
    return false, "\233\152\159\229\136\151\229\183\178\232\190\190\228\184\138\233\153\144"
  elseif plan.num + num + self:GetSoldierNum(roleId) > info.storage then
    return false, "\229\133\181\232\144\165\228\186\186\229\143\163\229\183\178\232\190\190\228\184\138\233\153\144"
  elseif plan.num + num < 0 then
    return false, "error:\233\152\159\229\136\151\229\176\143\228\186\1420"
  elseif num > 0 and UserDataManager:GetInstance():GetItemNum(td.ItemID_Force) < info.create_cost then
    return false, td.ErrorCode.MATERIAL_NOT_ENOUGH
  end
  return true, td.ErrorCode.SUCCESS
end
function UnitDataManager:IsRoleUnlock(roleId)
  local soldier = self:GetSoldierData(roleId)
  if soldier then
    return true
  end
  return false
end
function UnitDataManager:IsRoleCanUnlock(roleId)
  local udm = UserDataManager:GetInstance()
  local info = StrongInfoManager:GetInstance():GetSoldierStrongInfo(roleId)
  local preSoldierData = self:GetSoldierData(info.unlock.soldierId)
  local items = info.unlock.item
  if preSoldierData and preSoldierData.level >= info.unlock.level then
    for key, val in ipairs(items) do
      if udm:GetItemNum(val.itemId) < val.num then
        return false
      end
    end
    return true
  end
  return false
end
function UnitDataManager:GetUnlockedRoleIds()
  return table.keys(self.vSoldiersData)
end
function UnitDataManager:IsRoleCanEvo(roleId)
  local udm = UserDataManager:GetInstance()
  local soldierInfo = StrongInfoManager:GetInstance():GetSoldierStrongInfo(roleId)
  local soldierData = self:GetSoldierData(roleId)
  if soldierData then
    local star = soldierData.star
    local starCost = soldierInfo.star_cost
    local data = starCost[star]
    if data and #data > 0 then
      for key, val in ipairs(data) do
        if val and val.num then
          local ownItemNum
          if val.itemId ~= td.ItemID_Gold then
            ownItemNum = udm:GetItemNum(val.itemId)
          else
            ownItemNum = udm:GetGold()
          end
          local needItemNum = val.num
          if ownItemNum < needItemNum then
            return false, td.ErrorCode.MATERIAL_NOT_ENOUGH
          end
        else
          return false, td.ErrorCode.STAR_MAX
        end
      end
    end
    if soldierData.star >= soldierData.quality then
      return false, td.ErrorCode.STAR_MAX
    elseif soldierData.level < soldierData.star * 10 then
      return false, td.ErrorCode.LEVEL_LOW
    end
  else
    return false, 0
  end
  return true, 0
end
function UnitDataManager:SendSoldierRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetSoldiers
  TDHttpRequest:getInstance():Send(Msg)
end
function UnitDataManager:GetSoldiersCallback(data)
  local siMng = StrongInfoManager:GetInstance()
  local serverTime = UserDataManager:GetInstance():GetServerTime()
  for i, var in ipairs(data.roleProtos) do
    if var.cnum > 0 then
      local info = siMng:GetSoldierStrongInfo(var.role_id)
      local completeNum = cc.clampf(math.floor((serverTime - var.ctime) / info.create_time), 0, var.cnum)
      var.num = var.num + completeNum
      local remainNum = math.max(var.cnum - completeNum, 0)
      local curPassTime = 0
      if remainNum > 0 then
        curPassTime = (serverTime - var.ctime) % info.create_time
      end
      local plan = self:_UpdatePlan(var.role_id, remainNum)
      plan.curTime = plan.curTime - curPassTime
    end
    self:UpdateSoldierData(var)
    self:UpdateSoldierNum(var.role_id, var.num)
  end
  td.dispatchEvent(td.SOLDIER_DATA_INITED)
end
function UnitDataManager:ConsumeSoldierRequest(roldId, num)
  local data = {}
  self:UpdateSoldierNum(roldId, -num)
  table.insert(data, {role_id = roldId, num = num})
  local Msg = {}
  Msg.msgType = td.RequestID.UpdateSoldierNum
  Msg.sendData = {queue = data}
  Msg.cbData = deadUnit
  TDHttpRequest:getInstance():SendPrivate(Msg)
end
function UnitDataManager:IsSoldierCanUpgrade(soldierId)
  local soldiersData = self:GetSoldierData(soldierId)
  if soldierId then
    soldiersData = {soldiersData}
  end
  local ItemInfoManager = require("app.info.ItemInfoManager")
  local expItems = ItemInfoManager:GetInstance():GetExpItemInfos(3)
  local udMng = UserDataManager:GetInstance()
  for key, soldierData in pairs(soldiersData) do
    local requiredExp = td.CalSoldierExp(soldierData.star, soldierData.level, soldierData.quality)
    local exp = 0
    for i, var in ipairs(expItems) do
      local haveNum = udMng:GetItemNum(var.id)
      local material = {
        itemId = var.id,
        num = haveNum,
        exp = var.quantity
      }
      exp = exp + haveNum * var.quantity
    end
    if requiredExp <= exp + soldierData.exp and soldierData.level < soldierData.star * 10 then
      return true
    end
  end
  return false
end
return UnitDataManager
