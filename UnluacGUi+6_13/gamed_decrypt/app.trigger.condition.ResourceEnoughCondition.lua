local ConditionBase = import(".ConditionBase")
local ResourceEnoughCondition = class("ResourceEnoughCondition", ConditionBase)
function ResourceEnoughCondition:ctor(data)
  ResourceEnoughCondition.super.ctor(self, td.ConditionType.ResourceEnough)
  self.m_mapType = data.mapType
end
function ResourceEnoughCondition:CheckSatisfy(data)
  return true
end
return ResourceEnoughCondition
