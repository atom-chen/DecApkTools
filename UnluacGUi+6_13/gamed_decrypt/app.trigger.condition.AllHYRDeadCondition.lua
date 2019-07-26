local ConditionBase = import(".ConditionBase")
local AllHYRDeadCondition = class("AllHYRDeadCondition", ConditionBase)
function AllHYRDeadCondition:ctor(data)
  AllHYRDeadCondition.super.ctor(self, td.ConditionType.AllHYRDead)
end
function AllHYRDeadCondition:CheckSatisfy(data)
  return true
end
return AllHYRDeadCondition
