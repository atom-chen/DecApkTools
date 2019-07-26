local scheduler = require("framework.scheduler")
local GameDataManager = require("app.GameDataManager")
local TriggerBase = import(".TriggerBase")
local GuideManager = require("app.GuideManager")
local scheduler = require("framework.scheduler")
local GuideStepTrigger = class("GuideStepTrigger", TriggerBase)
function GuideStepTrigger:ctor(iID, iType, bLoop, conditionType, data)
  GuideStepTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_guideType = data.guideType
  self.m_guideId = data.guideId
  self.m_delay = data.delay or 0
end
function GuideStepTrigger:Active()
  GuideStepTrigger.super.Active(self)
  scheduler.performWithDelayGlobal(function()
    if 1 == self.m_guideType then
      GuideManager:GetInstance():StartSpeak(self.m_guideId)
    elseif 2 == self.m_guideType then
      GuideManager:GetInstance():StartUI(self.m_guideId)
    elseif 3 == self.m_guideType then
      GuideManager:GetInstance():StartTip(self.m_guideId)
    end
  end, self.m_delay)
end
return GuideStepTrigger
