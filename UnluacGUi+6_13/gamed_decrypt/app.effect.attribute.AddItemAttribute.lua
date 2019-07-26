local TDHttpRequest = require("app.net.TDHttpRequest")
local AttributeBase = import(".AttributeBase")
local AddItemAttribute = class("AddItemAttribute", AttributeBase)
function AddItemAttribute:ctor(pEffect, fNextAttributeTime, data)
  AddItemAttribute.super.ctor(self, td.AttributeType.AddItem, pEffect, fNextAttributeTime)
  self.m_itemId = data.achievementId
  self.m_itemNum = data.itemNum
end
function AddItemAttribute:Active()
  AddItemAttribute.super.Active(self)
  self.m_callback = handler(self, self.AddItemCallback)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetItem, self.m_callback)
  local data = {}
  data.itemId = self.m_itemId
  data.itemNum = self.m_itemNum
  local Msg = {}
  Msg.msgType = td.RequestID.GetItem
  Msg.sendData = data
  TDHttpRequest:getInstance():Send(Msg)
end
function AddItemAttribute:AddItemCallback(data)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetItem, self.m_callback)
  self:SetOver()
end
return AddItemAttribute
