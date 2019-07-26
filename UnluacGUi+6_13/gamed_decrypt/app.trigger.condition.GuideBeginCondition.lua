local ConditionBase = import(".ConditionBase")
local GuideBeginCondition = class("GuideBeginCondition", ConditionBase)
function GuideBeginCondition:ctor(data)
  GuideBeginCondition.super.ctor(self, td.ConditionType.GuideBegin)
  self.m_guideGroup = data.group
end
function GuideBeginCondition:CheckSatisfy(data)
  if type(self.m_guideGroup) == "table" then
    if table.indexof(self.m_guideGroup, data.group) then
      return true
    end
  elseif self.m_guideGroup == data.group then
    return true
  end
  return false
end
return GuideBeginCondition
