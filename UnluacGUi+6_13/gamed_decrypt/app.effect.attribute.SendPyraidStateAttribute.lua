local TDHttpRequest = require("app.net.TDHttpRequest")
local AttributeBase = import(".AttributeBase")
local SendPyraidStateAttribute = class("SendPyraidStateAttribute", AttributeBase)
function SendPyraidStateAttribute:ctor(pEffect, fNextAttributeTime, data)
  SendPyraidStateAttribute.super.ctor(self, td.AttributeType.SendPyramidState, pEffect, fNextAttributeTime)
  self.m_state = data.state
end
function SendPyraidStateAttribute:Active()
  SendPyraidStateAttribute.super.Active(self)
  local mapId = require("app.GameDataManager").GetInstance():GetGameMapInfo().id
  require("app.trigger.TriggerManager").GetInstance():SendEvent({
    eType = td.ConditionType.PyramidOutBack,
    state = self.m_state
  })
end
function SendPyraidStateAttribute:Update(dt)
  SendPyraidStateAttribute.super.Update(self, dt)
  if self.m_bExecuteNextAttribute then
    self:SetOver()
  end
end
return SendPyraidStateAttribute
