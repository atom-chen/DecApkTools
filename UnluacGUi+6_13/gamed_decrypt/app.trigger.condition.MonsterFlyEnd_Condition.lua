local ConditionBase = import(".ConditionBase")
local MonsterFlyEnd_Condition = class("MonsterFlyEnd_Condition", ConditionBase)
function MonsterFlyEnd_Condition:ctor(data)
  MonsterFlyEnd_Condition.super.ctor(self, td.ConditionType.MonsterFlyEnd)
  self.m_monsterId = data.monsterId
  self.m_time = data.time
end
function MonsterFlyEnd_Condition:CheckSatisfy(data)
  if self.m_monsterId == data.monsterId and data.time == self.m_time then
    return true
  end
  return false
end
return MonsterFlyEnd_Condition
