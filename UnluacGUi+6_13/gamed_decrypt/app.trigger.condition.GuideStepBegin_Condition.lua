local ConditionBase = import(".ConditionBase")
local GuideStepBegin_Condition = class("GuideStepBegin_Condition", ConditionBase)
function GuideStepBegin_Condition:ctor(data)
  GuideStepBegin_Condition.super.ctor(self, td.ConditionType.GuideStepBegin)
  self.m_guideGroup = data.group
  self.m_guideIdx = data.guideIdx
end
function GuideStepBegin_Condition:CheckSatisfy(data)
  if self.m_guideGroup == data.guideGroup and self.m_guideIdx == data.guideIdx then
    return true
  end
  return false
end
return GuideStepBegin_Condition
