local scheduler = require("framework.scheduler")
local TriggerBase = import(".TriggerBase")
local GuideContinueTrigger = class("GuideContinueTrigger", TriggerBase)
function GuideContinueTrigger:ctor(iID, iType, bLoop, conditionType, data)
  GuideContinueTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_delay = data.delay or 0
end
function GuideContinueTrigger:Active()
  GuideContinueTrigger.super.Active(self)
  scheduler.performWithDelayGlobal(function()
    td.dispatchEvent(td.GUIDE_CONTINUE)
  end, self.m_delay)
  print("GuideContinueTrigger:Active()")
end
return GuideContinueTrigger
