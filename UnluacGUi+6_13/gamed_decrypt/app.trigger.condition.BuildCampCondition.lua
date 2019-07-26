local ConditionBase = import(".ConditionBase")
local BuildCampCondition = class("BuildCampCondition", ConditionBase)
function BuildCampCondition:ctor(data)
  BuildCampCondition.super.ctor(self, td.ConditionType.BuildCamp)
  self.m_campId = data.campId
  self.m_campType = data.campType
  self.m_level = data.level
end
function BuildCampCondition:CheckSatisfy(data)
  if self.m_campId and data.campId ~= self.m_campId then
    return false
  end
  if self.m_campType and data.campType ~= self.m_campType then
    return false
  end
  if self.m_level and data.level ~= self.m_level then
    return false
  end
  return true
end
return BuildCampCondition
