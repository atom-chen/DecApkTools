local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local GameControl = require("app.GameControl")
local InformationManager = require("app.layers.InformationManager")
local ActivityDataManager = class("ActivityDataManager", GameControl)
ActivityDataManager.instance = nil
function ActivityDataManager:ctor(eType)
  ActivityDataManager.super.ctor(self, eType)
  self:Init()
  self:AddListeners()
end
function ActivityDataManager:GetInstance()
  if ActivityDataManager.instance == nil then
    ActivityDataManager.instance = ActivityDataManager.new(td.GameControlType.Login)
  end
  return ActivityDataManager.instance
end
function ActivityDataManager:ClearValue()
  self:Init()
end
function ActivityDataManager:AddListeners()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetActivityList, handler(self, self.GetActivityListCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetActivityAward, handler(self, self.GetActivityAwardCallback))
end
function ActivityDataManager:Init()
  self.m_data = {}
  self.m_data[1] = {
    {
      type = td.ActType.Notice,
      icon = 2,
      name = "\229\133\172\229\145\138"
    },
    {
      type = td.ActType.Charge,
      icon = 1,
      name = "\229\133\133\229\128\188"
    },
    {
      type = td.ActType.Redeem,
      icon = 1,
      name = "\231\164\188\229\140\133\229\133\145\230\141\162"
    }
  }
  self.m_data[2] = {
    {
      type = td.ActType.MonthSignIn,
      name = "\230\156\136\231\173\190\229\136\176"
    },
    {
      type = td.ActType.MonthCard,
      name = "\230\156\136\229\141\161"
    }
  }
end
function ActivityDataManager:GetActivityData()
  if not self.m_data then
    return nil
  end
  local data = {}
  data[1] = {}
  for i, var in ipairs(self.m_data[1]) do
    if self:_CheckTime(var.from, var.to) and var.type ~= td.ActType.SoldierBag then
      table.insert(data[1], var)
    end
  end
  data[2] = self.m_data[2]
  return data
end
function ActivityDataManager:GetSoldierBagActivityData()
  for i, var in ipairs(self.m_data[1]) do
    if var.type == td.ActType.SoldierBag and self:_CheckTime(var.from, var.to) and var.items[1].result ~= 1 then
      return var
    end
  end
  return nil
end
function ActivityDataManager:UpdateSoldierBagActivity()
  local curSoldierBagActivity = self:GetSoldierBagActivityData()
  if curSoldierBagActivity then
    self:UpdateActivityAward(curSoldierBagActivity.id, 1)
  end
end
function ActivityDataManager:UpdateActivityAward(_actId, _itemIndex)
  for i, activities in ipairs(self.m_data) do
    for j, activity in ipairs(activities) do
      if activity.id == _actId then
        for k, item in ipairs(activity.items) do
          if item.id == _itemIndex then
            item.result = 1
            if activity.type ~= td.ActType.SoldierBag then
              self:_ShowGetAwardMsg(item.award)
            end
          end
        end
      end
    end
  end
end
function ActivityDataManager:_CheckTime(timeFrom, timeTo)
  if not timeTo or not timeFrom then
    return true
  end
  local servertime = UserDataManager:GetInstance():GetServerTime()
  if timeFrom <= servertime and timeTo >= servertime then
    return true
  end
  return false
end
function ActivityDataManager:CheckRP(_index)
  local vShowActData = self:GetActivityData()
  if not vShowActData then
    return false
  end
  if not _index or not {_index} then
    local vTabIndex = {1, 2}
  end
  local bResult, vIndexes = false, {}
  local udMng = UserDataManager:GetInstance()
  local serverTime = udMng:GetServerTime()
  for i, index in ipairs(vTabIndex) do
    for j, activity in ipairs(vShowActData[index]) do
      if activity.type == td.ActType.NewSignIn then
        local signDays = udMng:GetSignInDay()
        local lastSignTime = udMng:GetSignInTime()
        if signDays == 0 or signDays < 7 and td.TimeCompare(serverTime, lastSignTime) then
          bResult = true
          table.insert(vIndexes, j)
        end
      elseif activity.type == td.ActType.MonthSignIn then
        if udMng:GetSignInDay(true) == 0 or td.TimeCompare(serverTime, udMng:GetSignInTime(true)) then
          bResult = true
          table.insert(vIndexes, j)
        end
      elseif activity.type == td.ActType.MonthCard then
        local vipData = UserDataManager:GetInstance():GetVIPData()
        if 0 >= vipData.week_day or 0 >= vipData.month_day then
          table.insert(vIndexes, j)
        end
      elseif activity.items and (activity.type ~= td.ActType.Fund or activity.type == td.ActType.Fund and 0 < udMng:GetVIPData().fund) then
        for k, actItem in ipairs(activity.items) do
          if actItem.result ~= 1 and self:CheckCondition(actItem.condition, activity.from, activity.to) then
            bResult = true
            table.insert(vIndexes, j)
            break
          end
        end
      end
    end
  end
  return bResult, vIndexes
end
function ActivityDataManager:CheckCondition(condition, startTime, endTime)
  local udMng = UserDataManager:GetInstance()
  if condition.id == td.ActConditionType.Base then
    if udMng:GetBaseCampLevel() >= condition.value then
      return true
    end
  elseif condition.id == td.ActConditionType.Mission then
    if udMng:GetCityData(condition.value) then
      return true
    end
  elseif condition.id == td.ActConditionType.Arena then
    local pvpData = udMng:GetPVPData()
    if pvpData.selfData and pvpData.selfData.max_rank <= condition.value then
      return true
    end
  elseif condition.id == td.ActConditionType.Online then
    local serverTime = udMng:GetServerTime()
    local lastTime = udMng:GetOnlineAwardTime()
    if serverTime >= lastTime + condition.value then
      return true
    end
  elseif condition.id == td.ActConditionType.Charge then
    local totalCharge = udMng:GetUserLog(1, startTime, endTime)
    if totalCharge >= condition.value then
      return true
    end
  elseif condition.id == td.ActConditionType.Consume then
    local totalConsume = udMng:GetUserLog(td.ItemID_Diamond, startTime, endTime)
    if totalConsume >= condition.value then
      return true
    end
  end
  return false
end
function ActivityDataManager:_ShowGetAwardMsg(award)
  local _items = {}
  for i, var in ipairs(award) do
    _items[var.itemId] = var.num
  end
  InformationManager:GetInstance():ShowInfoDlg({
    type = td.ShowInfo.Item,
    items = _items
  })
end
function ActivityDataManager:GetUserLogs(vLogParam)
  local count = #vLogParam
  if count == 0 then
    td.dispatchEvent(td.ACTIVITY_INITED)
  else
    local var = vLogParam[count]
    table.remove(vLogParam, count)
    UserDataManager:GetInstance():SendGetUserLogRequest(var.id, var.type, var.from, var.to, function()
      self:GetUserLogs(vLogParam)
    end)
  end
end
function ActivityDataManager:GetActivityListRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetActivityList
  TDHttpRequest:getInstance():Send(Msg)
end
function ActivityDataManager:GetActivityListCallback(data, cbData)
  local vLogParam = {}
  for i, var in ipairs(data.activityProto) do
    local activity = {}
    activity.id = var.type
    activity.name = var.name
    activity.icon = tonumber(var.icon)
    activity.desc = var.desc
    if var.start_time ~= 0 and var.end_time ~= 0 then
      activity.from = var.start_time
      activity.to = var.end_time
    end
    activity.items = var.activityProto
    for j, item in ipairs(activity.items) do
      local award = {}
      for k, itemStr in ipairs(item.award) do
        local tmp = string.split(itemStr, "#")
        table.insert(award, {
          itemId = tonumber(tmp[1]),
          num = tonumber(tmp[2])
        })
      end
      item.award = award
      item.condition = item.conditions[1]
      item.conditions = nil
    end
    table.sort(activity.items, function(a, b)
      if a.condition.id == td.ActConditionType.Arena then
        return a.condition.value > b.condition.value
      else
        return a.condition.value < b.condition.value
      end
    end)
    if var.type == td.ActType.Fund then
      activity.type = var.type
    elseif var.type >= 10000 then
      activity.type = td.ActType.SoldierBag
    elseif activity.items[1] then
      local conditionType = activity.items[1].condition.id
      if conditionType == td.ActConditionType.Base then
        activity.type = td.ActType.Level
      elseif conditionType == td.ActConditionType.Mission then
        activity.type = td.ActType.Mission
      elseif conditionType == td.ActConditionType.Arena then
        activity.type = td.ActType.Arena
      elseif conditionType == td.ActConditionType.Online then
        activity.type = td.ActType.OnlineTime
      elseif conditionType == td.ActConditionType.Charge then
        activity.type = td.ActType.TotalCharge
        table.insert(vLogParam, {
          id = 1,
          type = 1,
          from = activity.from,
          to = activity.to
        })
      elseif conditionType == td.ActConditionType.Consume then
        activity.type = td.ActType.Consume
        table.insert(vLogParam, {
          id = td.ItemID_Diamond,
          type = 0,
          from = activity.from,
          to = activity.to
        })
      else
        activity.type = var.type
      end
    else
      activity.type = var.type
    end
    table.insert(self.m_data[1], 3, activity)
  end
  self:GetUserLogs(vLogParam)
end
function ActivityDataManager:GetActivityAwardRequest(_actId, _itemIndex)
  local Msg = {}
  Msg.msgType = td.RequestID.GetActivityAward
  Msg.sendData = {type = _actId, id = _itemIndex}
  Msg.cbData = {actId = _actId, itemIndex = _itemIndex}
  TDHttpRequest:getInstance():Send(Msg)
end
function ActivityDataManager:GetActivityAwardCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    self:UpdateActivityAward(cbData.actId, cbData.itemIndex)
    td.dispatchEvent(td.GET_ACTIVITY_AWARD)
  end
end
return ActivityDataManager
