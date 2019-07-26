local scheduler = require("framework.scheduler")
local TriggerBase = import(".TriggerBase")
local GuideManager = require("app.GuideManager")
local SaveGuideGroupTrigger = class("SaveGuideGroupTrigger", TriggerBase)
function SaveGuideGroupTrigger:ctor(iID, iType, bLoop, conditionType, data)
  SaveGuideGroupTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_guideGroup = data.group
end
function SaveGuideGroupTrigger:Active()
  SaveGuideGroupTrigger.super.Active(self)
  local mng = GuideManager:GetInstance()
  if not mng:IsGuideGroupOver(self.m_guideGroup) then
    mng:SaveGuideGroup(self.m_guideGroup)
  end
end
return SaveGuideGroupTrigger
