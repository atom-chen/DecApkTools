local ConditionBase = import(".ConditionBase")
local ViewportMoveOver_Condition = class("ViewportMoveOver_Condition", ConditionBase)
function ViewportMoveOver_Condition:ctor(data)
  ViewportMoveOver_Condition.super.ctor(self, td.ConditionType.ViewportMoveOver)
  self.m_triggerId = data.triggerId
end
function ViewportMoveOver_Condition:CheckSatisfy(data)
  if data.triggerId == self.m_triggerId then
    return true
  end
  return false
end
return ViewportMoveOver_Condition
