local GameControl = require("app.GameControl")
local TDHttpRequest = require("app.net.TDHttpRequest")
local socket = require("socket")
local ChatManager = class("ChatManager", GameControl)
ChatManager.instance = nil
ChatManager.MAX_MSG_CNT = 50
function ChatManager:ctor(eType)
  ChatManager.super.ctor(self, eType)
  self:Reset()
  self.m_udMng = require("app.UserDataManager"):GetInstance()
  self.m_useStroke = false
  self:addListeners()
end
function ChatManager:setChatDlg(dlg)
  self.m_chatDlg = dlg
end
function ChatManager:addListeners()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetChatList_req, handler(self, self.getChatResponse))
end
function ChatManager:GetInstance()
  if ChatManager.instance == nil then
    ChatManager.instance = ChatManager.new(td.GameControlType.Login)
  end
  return ChatManager.instance
end
function ChatManager:ClearValue()
  self:Reset()
end
function ChatManager:Reset()
  local chatDataStr = g_LD:GetStr("chat")
  if chatDataStr ~= "" then
    self.m_msgdatas = string.toTable(chatDataStr)
  else
    self.m_msgdatas = {
      {},
      {},
      {}
    }
  end
end
function ChatManager:setUseStroke(isStroke)
  self.m_useStroke = isStroke
end
function ChatManager:addSelfMsg(channelType, data)
  self:insertMsg(channelType, data)
end
function ChatManager:insertMsg(channelType, data)
  self.m_msgdatas[channelType] = self.m_msgdatas[channelType] or {}
  if #self.m_msgdatas[channelType] >= ChatManager.MAX_MSG_CNT then
    table.remove(self.m_msgdatas[channelType], 1)
  end
  table.insert(self.m_msgdatas[channelType], data)
end
function ChatManager:getMsgData(channelType, index)
  if channelType and index then
    return self.m_msgdatas[channelType][index]
  end
  return self.m_msgdatas
end
function ChatManager:createSelfMsgData(msg, toFriName)
  local data = {}
  data.reputation = self.m_udMng:GetReputation()
  data.uname = toFriName and toFriName or self.m_udMng:GetNickname()
  data.date = socket.gettime() * 1000
  data.messages = msg
  data.uid = self.m_udMng:GetUId()
  data.index = 0
  data.isSelfSend = true
  return data
end
function ChatManager:sendChatMsgRequest(data)
  local Msg = {}
  Msg.msgType = td.RequestID.SendChatMsg_req
  Msg.sendData = data
  TDHttpRequest:getInstance():Send(Msg)
end
function ChatManager:sendGetChatRequest(data)
  local Msg = {}
  Msg.msgType = td.RequestID.GetChatList_req
  Msg.sendData = data
  TDHttpRequest:getInstance():SendPrivate(Msg, true)
end
function ChatManager:getChatResponse(data)
  local channelType = data.type
  if #data.messages == 0 then
    return
  end
  self.m_msgdatas[channelType] = self.m_msgdatas[channelType] or {}
  for k, value in ipairs(data.messages) do
    self:insertMsg(channelType, value)
    value.index = #self.m_msgdatas[channelType] or 1
    value.isSelfSend = false
    if self.m_chatDlg then
      self.m_chatDlg:appendContent(value, channelType)
    end
  end
end
return ChatManager
