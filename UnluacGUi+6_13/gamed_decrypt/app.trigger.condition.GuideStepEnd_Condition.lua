local ConditionBase = import(".ConditionBase")
local GuideStepEnd_Condition = class("GuideStepEnd_Condition", ConditionBase)
function GuideStepEnd_Condition:ctor(data)
  GuideStepEnd_Condition.super.ctor(self, td.ConditionType.GuideStepEnd)
  self.m_guideGroup = data.group
  self.m_guideIdx = data.guideIdx
end
function GuideStepEnd_Condition:CheckSatisfy(data)
  if self.m_guideGroup == data.guideGroup and self.m_guideIdx == data.guideIdx then
    return true
  end
  return false
end
return GuideStepEnd_Condition
