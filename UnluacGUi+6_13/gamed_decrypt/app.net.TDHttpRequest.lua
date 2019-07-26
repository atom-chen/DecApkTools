require("app.utils.protobuf")
local ByteArray = require("app.utils.ByteArray")
local scheduler = require("framework.scheduler")
local Protobuf = protobuf
local TDHttpRequest = class("TDHttpRequest")
TDHttpRequest.DidInit = false
TDHttpRequest.instance = nil
function TDHttpRequest:ctor()
  self.m_msgType_protobuf = {}
  self.m_sendMsgs = {}
  self.m_callbacks = {}
  self.m_noProtoCb = {}
  self.m_vCbData = {}
  self.m_delay = td.SHOW_WAITING_DIG_DELAY
  self.m_scheculeHander = nil
  self.m_bLostConect = false
  self.m_serverUrl = td.SERVER_URL
  self.m_payUrl = td.SERVER_URL
  self:initMsgTypeProtoBuf()
  scheduler.scheduleGlobal(function()
    self:_Send()
  end, 0.03333333333333333)
end
function TDHttpRequest:getInstance()
  if TDHttpRequest.instance == nil then
    TDHttpRequest.instance = TDHttpRequest.new()
  end
  return TDHttpRequest.instance
end
function TDHttpRequest:initMsgTypeProtoBuf()
  self.m_msgType_protobuf = require("app.net.ProtobufMsgConfig")
end
function TDHttpRequest:Send(_msg, bNoWaiting)
  if self.m_bLostConect then
    return
  end
  local msgData = {
    msg = _msg,
    bNoWait = bNoWaiting,
    bSended = false
  }
  table.insert(self.m_sendMsgs, msgData)
  if _msg.cbData then
    self.m_vCbData[_msg.msgType] = _msg.cbData
  end
  if not bNoWaiting then
    self:showWaitingDlg()
  end
end
function TDHttpRequest:ReSend()
  for key, var in ipairs(self.m_sendMsgs) do
    var.bSended = false
    if not var.bNoWait then
      self:showWaitingDlg()
    end
  end
end
function TDHttpRequest:SendPrivate(msg)
  if self.m_bLostConect then
    return
  end
  if msg == nil then
    return
  end
  local sendPack, packLen = self:Package(msg)
  if sendPack == nil or packLen < td.PACK_HEAD_LEN then
    return
  end
  local request = network.createHTTPRequest(handler(self, self.OnPrivateRequestFinished), self.m_serverUrl, "POST")
  local packData = sendPack:getPack()
  request:setPOSTData(packData)
  request:setTimeout(100)
  request:start()
end
function TDHttpRequest:_Send(Msg)
  local sendPack, packLen = self:Package(Msg)
  if sendPack == nil or packLen < td.PACK_HEAD_LEN then
    return
  end
  local request = network.createHTTPRequest(handler(self, self.OnRequestFinished), self.m_serverUrl, "POST")
  local packData = sendPack:getPack()
  request:setPOSTData(packData)
  request:setTimeout(100)
  request:start()
end
function TDHttpRequest:OnRequestFinished(event)
  if self.m_bLostConect then
    return
  end
  local request = event.request
  if event.name ~= "completed" then
    if event.name == "failed" then
      print(request:getErrorCode(), request:getErrorMessage())
      td.alertDebug("\232\175\183\230\177\130\229\164\177\232\180\165")
      for key, var in ipairs(self.m_sendMsgs) do
        print("\229\164\177\232\180\165id:" .. var.msg.msgType)
      end
      self:whenResponse()
      self:OnRequestFailed()
    end
    return
  end
  self:whenResponse()
  local code = request:getResponseStatusCode()
  if code == 200 then
    self:OnRequestSuccess(request)
  else
    print("code=" .. code, request:getErrorCode(), request:getErrorMessage())
  end
  self:CleanMsgData()
  for i = #self.m_sendMsgs, 1, -1 do
    local msgData = self.m_sendMsgs[i]
    if not msgData.bNoWait then
      return
    end
  end
end
function TDHttpRequest:OnPrivateRequestFinished(event)
  if self.m_bLostConect then
    return
  end
  local request = event.request
  if event.name ~= "completed" then
    return
  end
  local code = request:getResponseStatusCode()
  if code == 200 then
    self:OnRequestSuccess(request)
  else
    print("code=" .. code, request:getErrorCode(), request:getErrorMessage())
  end
end
function TDHttpRequest:SendNoProto(subAddr, sendData, cb)
  if self.m_bLostConect then
    return
  end
  table.insert(self.m_noProtoCb, cb)
  local url = td.SERVER_URL .. subAddr
  local request = network.createHTTPRequest(handler(self, self.OnNoProtoRequestFinished), url, "POST")
  if sendData then
    local packData = self:PackNoProtoData(sendData)
    request:setPOSTData(packData)
  end
  request:setTimeout(100)
  request:start()
  self:showWaitingDlg()
end
function TDHttpRequest:OnNoProtoRequestFinished(event)
  local request = event.request
  if event.name ~= "completed" then
    if event.name == "failed" then
      if self.m_noProtoCb[1] then
        table.remove(self.m_noProtoCb, 1)
      end
      td.alertDebug("\232\175\183\230\177\130\229\164\177\232\180\165,error code:" .. request:getErrorCode())
      self:whenResponse()
    end
    return
  end
  local code = request:getResponseStatusCode()
  if code == 200 then
    local respData = request:getResponseData()
    local data = json.decode(respData)
    if data and data.state and data.state ~= td.ResponseState.Success then
      td.alertErrorMsg(data.state)
    elseif self.m_noProtoCb[1] then
      self.m_noProtoCb[1](data)
    end
  else
    td.alertDebug("\232\175\183\230\177\130\229\164\177\232\180\165,error code:" .. request:getErrorCode())
  end
  if self.m_noProtoCb[1] then
    table.remove(self.m_noProtoCb, 1)
  end
  self:whenResponse()
end
function TDHttpRequest:PackNoProtoData(data)
  local result = ""
  for key, var in pairs(data) do
    result = result .. key .. "=" .. var .. "&"
  end
  if result == "" then
    return result
  end
  return string.sub(result, 1, string.len(result) - 1)
end
function TDHttpRequest:CleanMsgData()
  local count = #self.m_sendMsgs
  for i = count, 1, -1 do
    local msgData = self.m_sendMsgs[i]
    if msgData.bSended then
      table.remove(self.m_sendMsgs, i)
    end
  end
end
function TDHttpRequest:SetServer(server)
  self.m_serverUrl = string.format("http://%s:%d/tafang/", server.ip, server.port)
end
function TDHttpRequest:ResetServer()
  self.m_serverUrl = td.SERVER_URL
end
function TDHttpRequest:GetServerUrl()
  return self.m_serverUrl
end
function TDHttpRequest:GetPayUrl()
  return self.m_payUrl
end
function TDHttpRequest:OnLostConnect()
  require("app.net.NetManager")
  g_NetManager:stopHeartBeat()
  self.m_bLostConect = true
  local msgData = {}
  msgData.content = g_LM:getBy("a00277")
  local button1 = {
    text = g_LM:getBy("a00009"),
    callFunc = function()
      local GameControl = require("app.GameControl")
      GameControl.Logout()
      self.m_bLostConect = false
    end
  }
  msgData.buttons = {button1}
  local messageBox = require("app.layers.MessageBoxDlg").new(msgData)
  messageBox:Show()
end
function TDHttpRequest:OnRequestFailed()
  local msgData = {}
  msgData.content = g_LM:getBy("a00316")
  local button1 = {
    text = g_LM:getBy("a00009"),
    callFunc = function()
      self:ReSend()
    end
  }
  msgData.buttons = {button1}
  local messageBox = require("app.layers.MessageBoxDlg").new(msgData)
  messageBox:Show()
end
function TDHttpRequest:OnRequestSuccess(request)
  local dataLen = request:getResponseDataLength()
  local respData = request:getResponseData()
  local MessageTable, isSuccess = self:UnPackage(respData, dataLen)
  if isSuccess == true then
    for _, value in ipairs(MessageTable) do
      local msgType = value[1]
      local protoBufObj = value[2]
      if msgType == td.RequestID.ServerInfo then
        if protoBufObj.error_id == 10000 then
          self:OnLostConnect()
          return
        elseif protoBufObj.error_id > 10000 then
          td.alertErrorMsg(protoBufObj.error_id)
        else
          print("\229\174\140\230\136\144\230\136\144\229\176\177\239\188\140id" .. protoBufObj.error_id)
          local InformationManager = require("app.layers.InformationManager")
          InformationManager:GetInstance():addAchievementText(protoBufObj.error_id)
          self:DispatchEvents(msgType, protoBufObj)
        end
      else
        self:DispatchEvents(msgType, protoBufObj)
      end
    end
  end
end
function TDHttpRequest:DispatchEvents(messageType, protoBufObj)
  if self.m_callbacks[messageType] ~= nil then
    for k, value in ipairs(self.m_callbacks[messageType]) do
      local cbData = self.m_vCbData[messageType]
      self.m_vCbData[messageType] = nil
      value(protoBufObj, cbData)
    end
  end
end
function TDHttpRequest:registerCallback(messaeType, callback)
  self.m_callbacks[messaeType] = self.m_callbacks[messaeType] or {}
  table.insert(self.m_callbacks[messaeType], callback)
end
function TDHttpRequest:unregisterCallback(messaeType, callback)
  if not self.m_callbacks[messaeType] then
    return
  end
  if nil == callback then
    self.m_callbacks[messaeType] = nil
  else
    for k, value in ipairs(self.m_callbacks[messaeType]) do
      if value == callback then
        table.remove(self.m_callbacks[messaeType], k)
        break
      end
    end
  end
end
function TDHttpRequest.RegisterAllProtobuf()
  if not TDHttpRequest.DidInit then
    local pbAllName = {
      "pb/FriendProto.pb",
      "pb/HeroProto.pb",
      "pb/ItemProto.pb",
      "pb/MailProto.pb",
      "pb/UserProto.pb",
      "pb/WeaponProto.pb",
      "pb/ErrorProto.pb",
      "pb/MissionProto.pb",
      "pb/ArenaProto.pb",
      "pb/ToolProto.pb",
      "pb/MallProto.pb",
      "pb/EndlessProto.pb",
      "pb/AchievementProto.pb",
      "pb/RankProto.pb",
      "pb/TaskProto.pb",
      "pb/GuildProto.pb",
      "pb/SkillProto.pb",
      "pb/RoleProto.pb",
      "pb/PayProto.pb",
      "pb/GuildBattleProto.pb",
      "pb/GemstoneProtos.pb"
    }
    for i = 1, #pbAllName do
      local fileData = cc.HelperFunc:getFileData(pbAllName[i])
      Protobuf.register(fileData)
    end
    TDHttpRequest.DidInit = true
  end
end
function TDHttpRequest:Package(Msg)
  repeat
    if Msg ~= nil then
      local encodeMsg = self:encodeMsg(Msg.msgType, Msg.sendData)
      local byteArr = self:makePackageHead()
      local dataLen = 0
      if encodeMsg ~= nil then
        dataLen = string.len(encodeMsg)
      end
      local messageType = Msg.msgType
      byteArr:writeShort(dataLen + td.SHORT_LEN + td.SHORT_LEN)
      byteArr:writeShort(messageType)
      if encodeMsg ~= nil then
        byteArr:writeString(encodeMsg)
      end
      return byteArr, byteArr:getLen()
    end
    if not self:CheckMsgToSend() then
      break
    end
    local index = 1
    local byteArr = self:makePackageHead()
    while index <= #self.m_sendMsgs do
      local msgData = self.m_sendMsgs[index]
      if not msgData.bSended then
        msgData.bSended = true
        local tmpMsg = msgData.msg
        local messageType = tmpMsg.msgType
        local encodeMsg = self:encodeMsg(messageType, tmpMsg.sendData)
        local dataLen = 0
        if encodeMsg ~= nil then
          dataLen = string.len(encodeMsg)
        end
        byteArr:writeShort(dataLen + td.SHORT_LEN + td.SHORT_LEN)
        byteArr:writeShort(messageType)
        if encodeMsg ~= nil then
          byteArr:writeString(encodeMsg)
        end
      end
      index = index + 1
    end
    return byteArr, byteArr:getLen()
  until false
  return nil, 0
end
function TDHttpRequest:CheckMsgToSend()
  for i, msgData in ipairs(self.m_sendMsgs) do
    if not msgData.bSended then
      return true
    end
  end
  return false
end
function TDHttpRequest:makePackageHead()
  local byteArr = ByteArray:new()
  byteArr:setEndian(ByteArray.ENDIAN_BIG)
  local token = require("app.UserDataManager"):GetInstance():GetSessionId()
  if token == nil or token == "" then
    token = td.ORI_SESSION
  end
  byteArr:writeString(token)
  return byteArr
end
function TDHttpRequest:UnPackage(respData, dataLen)
  local MessgeTables = {}
  local isResult = true
  if dataLen < td.PACK_HEAD_LEN then
    print("\230\148\182\229\136\176\231\154\132\232\191\148\229\155\158\229\140\133\228\191\161\230\129\175\228\184\141\229\174\140\230\149\180")
    return MessgeTables, false
  end
  local currIndex = 1
  local byteArr = ByteArray:new()
  byteArr:setEndian(ByteArray.ENDIAN_BIG)
  byteArr:writeString(respData)
  byteArr:setPos(currIndex)
  local btArrLen = byteArr:getLen()
  if btArrLen ~= dataLen then
    print("\228\184\141\231\155\184\231\173\137\239\188\159")
    return MessgeTables, false
  end
  while dataLen > currIndex do
    if byteArr:getAvailable() < td.SHORT_LEN then
      td.alertDebug("\229\140\133\230\149\176\230\141\174\230\156\137\232\175\1751")
      isResult = false
      break
    end
    local packLen = byteArr:readShort()
    currIndex = currIndex + td.SHORT_LEN
    byteArr:setPos(currIndex)
    if byteArr:getAvailable() < td.SHORT_LEN then
      td.alertDebug("\229\140\133\230\149\176\230\141\174\230\156\137\232\175\1752")
      isResult = false
      break
    end
    local msgType = byteArr:readShort()
    currIndex = currIndex + td.SHORT_LEN
    byteArr:setPos(currIndex)
    packLen = packLen - td.SHORT_LEN - td.SHORT_LEN
    if packLen > byteArr:getAvailable() then
      td.alertDebug("\229\140\133\230\149\176\230\141\174\230\156\137\232\175\1753")
      isResult = false
      break
    end
    local respData = byteArr:readString(packLen)
    currIndex = currIndex + packLen
    byteArr:setPos(currIndex)
    local protoObj = self:decodeMsg(msgType, respData, packLen)
    if protoObj ~= nil then
      local dataTmp = {}
      dataTmp[1] = msgType
      dataTmp[2] = protoObj
      table.insert(MessgeTables, dataTmp)
    end
  end
  return MessgeTables, isResult
end
function TDHttpRequest:encodeMsg(msgType, msgData)
  if msgData == nil then
    return nil
  end
  local protobufDef = self.m_msgType_protobuf[msgType][1]
  if protobufDef == nil then
    print("msgType = " .. msgType .. "\230\178\161\230\156\137\230\179\168\229\134\140 ")
    return nil
  end
  return Protobuf.encode(protobufDef, msgData)
end
function TDHttpRequest:decodeMsg(msgType, msgData, lenth)
  local protobufDef = self.m_msgType_protobuf[msgType][2]
  if protobufDef == nil then
    print("msgType = " .. msgType .. "\230\178\161\230\156\137\230\179\168\229\134\140 ")
    return nil
  end
  return Protobuf.decode(protobufDef, msgData, lenth)
end
function TDHttpRequest:setDelayTime(delay)
  if delay > 0 then
    self.m_delay = delay
  end
end
function TDHttpRequest:showWaitingDlg()
  self:unScheduleShowWaitingDlg()
  local function listener()
    if not self.m_waitingLayer then
      self.m_waitingLayer = require("app.layers.WaitingDlg"):new()
      td.popView(self.m_waitingLayer)
    end
  end
  self.m_scheculeHander = scheduler.performWithDelayGlobal(listener, self.m_delay)
  self.m_delay = td.SHOW_WAITING_DIG_DELAY
end
function TDHttpRequest:unScheduleShowWaitingDlg()
  if self.m_scheculeHander ~= nil then
    scheduler.unscheduleGlobal(self.m_scheculeHander)
    self.m_scheculeHander = nil
  end
  if self.m_waitingLayer then
    td.dispatchEvent(td.STOP_WAITING)
    self.m_waitingLayer = nil
  end
end
function TDHttpRequest:whenResponse()
  self:unScheduleShowWaitingDlg()
end
TDHttpRequest.RegisterAllProtobuf()
return TDHttpRequest
