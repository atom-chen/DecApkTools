local GameControl = require("app.GameControl")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local NetManager = class("NetManager", GameControl)
NetManager.instance = nil
function NetManager:ctor(eType)
  NetManager.super.ctor(self, eType)
  self.m_TDHttpRequest = TDHttpRequest:getInstance()
  self.m_TDHttpRequest:registerCallback(td.RequestID.SendHeartBeat, handler(self, self.heartbeatCallback))
  self.m_scheduleHandle = nil
  self.m_data = {}
end
function NetManager:onCleanup()
  self:ClearValue()
end
function NetManager:ClearValue()
  self.m_data = nil
  self.m_TDHttpRequest:unregisterCallback(td.RequestID.SendHeartBeat)
end
function NetManager:GetInstance()
  if NetManager.instance == nil then
    NetManager.instance = NetManager.new(td.GameControlType.ExitGame)
  end
  return NetManager.instance
end
function NetManager:startHeartBeat()
  if not self.m_scheduleHandle then
    printInfo(".....[startHeartBeat].....")
    self:sendHeartBeat()
    self.m_scheduleHandle = scheduler.scheduleGlobal(self.sendHeartBeat, td.HEARTBEAT_INTERVAL)
  else
    self:redispatchAllMsg()
  end
end
function NetManager:stopHeartBeat()
  printInfo(".....[stopHeartBeat].....")
  if self.m_scheduleHandle then
    scheduler.unscheduleGlobal(self.m_scheduleHandle)
    self.m_scheduleHandle = nil
  end
end
function NetManager:sendHeartBeat()
  local Msg = {}
  Msg.msgType = td.RequestID.SendHeartBeat
  Msg.sendData = nil
  TDHttpRequest:getInstance():SendPrivate(Msg)
end
function NetManager:heartbeatCallback(data)
  if #data.toolProto > 0 then
    for i, value in ipairs(data.toolProto) do
      self:dispatchMsg(value.type, value.num, value.items)
    end
  end
end
function NetManager:dispatchMsg(_msgType, _num, _items)
  if self:_canDispatch(_msgType) then
    td.dispatchEvent(td.HEART_BEAT, {
      type = _msgType,
      num = _num,
      items = _items
    })
  else
    self.m_data[_msgType] = self.m_data[_msgType] or {}
    self.m_data[_msgType].num = _num
    if self.m_data[_msgType].items then
      for i, var in ipairs(_items) do
        table.insert(self.m_data[_msgType].items, var)
      end
    else
      self.m_data[_msgType].items = _items
    end
  end
end
function NetManager:_canDispatch(_msgType)
  local sceneType = cc.Director:getInstance():getRunningScene():GetType()
  if sceneType == td.SceneType.Main then
    return true
  elseif sceneType == td.SceneType.Guild and table.indexof({
    td.HBType.Kick,
    td.HBType.Promote,
    td.HBType.Reject,
    td.HBType.Recruit,
    td.HBType.Apply,
    td.HBType.Quit,
    td.HBType.BUpgrade,
    td.HBType.Chat
  }, _msgType) then
    return true
  elseif sceneType == td.SceneType.GuildPVP and table.indexof({
    td.HBType.GuildPVPOver,
    td.HBType.GuildPVPUp
  }, _msgType) then
    return true
  elseif sceneType == td.SceneType.Battle and table.indexof({
    td.HBType.GuildBossHp
  }, _msgType) then
    return true
  end
  return false
end
function NetManager:redispatchAllMsg()
  local data = self.m_data
  self.m_data = {}
  for k, value in pairs(data) do
    self:dispatchMsg(k, value.num, value.items)
  end
end
g_NetManager = g_NetManager or NetManager:GetInstance()
