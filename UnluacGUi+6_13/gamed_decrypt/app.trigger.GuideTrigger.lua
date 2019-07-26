local scheduler = require("framework.scheduler")
local TriggerBase = import(".TriggerBase")
local GuideManager = require("app.GuideManager")
local GuideTrigger = class("GuideTrigger", TriggerBase)
function GuideTrigger:ctor(iID, iType, bLoop, conditionType, data)
  GuideTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  if data.group then
    self.m_guideGroup = data.group
  elseif data.groupSerial then
    self.m_guideGroupSerial = data.groupSerial
  end
  self.m_delay = data.delay or 0
end
function GuideTrigger:Active()
  GuideTrigger.super.Active(self)
  scheduler.performWithDelayGlobal(function()
    if self.m_guideGroup then
      GuideManager.H_StartGuideGroup(self.m_guideGroup)
    elseif self.m_guideGroupSerial then
      GuideManager.H_StartGuideGroup(self.m_guideGroupSerial)
    end
  end, self.m_delay)
end
return GuideTrigger
