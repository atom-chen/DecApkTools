local TriggerBase = import(".TriggerBase")
local scheduler = require("framework.scheduler")
local DispatchEventTrigger = class("DispatchEventTrigger", TriggerBase)
function DispatchEventTrigger:ctor(iID, iType, bLoop, conditionType, data)
  DispatchEventTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_eventName = data.eventName
  self.m_eventData = data.eventData
  self.m_delay = data.delay or 0
end
function DispatchEventTrigger:Active()
  DispatchEventTrigger.super.Active(self)
  scheduler.performWithDelayGlobal(function()
    td.dispatchEvent(self.m_eventName, self.m_eventData)
  end, self.m_delay)
end
return DispatchEventTrigger
