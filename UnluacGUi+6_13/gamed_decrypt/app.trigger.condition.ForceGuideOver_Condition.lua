local ConditionBase = import(".ConditionBase")
local ForceGuideOver_Condition = class("ForceGuideOver_Condition", ConditionBase)
function ForceGuideOver_Condition:ctor(data)
  ForceGuideOver_Condition.super.ctor(self, td.ConditionType.ForceGuide)
  self.m_bOver = data.over
end
function ForceGuideOver_Condition:CheckSatisfyOnInit()
  local GuideManager = require("app.GuideManager")
  if GuideManager:GetInstance():IsForceGuideOver() == self.m_bOver then
    return true
  end
  return false
end
function ForceGuideOver_Condition:CheckSatisfy(data)
  local GuideManager = require("app.GuideManager")
  if GuideManager:GetInstance():IsForceGuideOver() == self.m_bOver then
    return true
  end
  return false
end
return ForceGuideOver_Condition
