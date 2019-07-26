local ConditionBase = import(".ConditionBase")
local ActorPlayAnimEnd_Condition = class("ActorPlayAnimEnd_Condition", ConditionBase)
function ActorPlayAnimEnd_Condition:ctor(data)
  ActorPlayAnimEnd_Condition.super.ctor(self, td.ConditionType.ActorAnimOver)
  self.m_monsterId = data.monsterId
  self.m_triggerId = data.triggerId
end
function ActorPlayAnimEnd_Condition:CheckSatisfy(data)
  if self.m_monsterId == data.monsterId and data.triggerId == self.m_triggerId then
    return true
  end
  return false
end
return ActorPlayAnimEnd_Condition
