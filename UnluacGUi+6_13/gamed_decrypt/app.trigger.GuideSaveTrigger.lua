local TriggerBase = import(".TriggerBase")
local GuideManager = require("app.GuideManager")
local GuideSaveTrigger = class("GuideSaveTrigger", TriggerBase)
function GuideSaveTrigger:ctor(iID, iType, bLoop, conditionType, data)
  GuideSaveTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_guideGroup = data.group
end
function GuideSaveTrigger:Active()
  GuideSaveTrigger.super.Active(self)
  GuideManager:GetInstance():SaveGuideGroup(self.m_guideGroup)
end
return GuideSaveTrigger
