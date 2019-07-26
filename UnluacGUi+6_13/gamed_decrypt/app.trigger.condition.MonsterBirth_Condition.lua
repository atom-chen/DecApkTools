local ConditionBase = import(".ConditionBase")
local MonsterBirth_Condition = class("MonsterBirth_Condition", ConditionBase)
function MonsterBirth_Condition:ctor(data)
  MonsterBirth_Condition.super.ctor(self, td.ConditionType.MonsterBirth)
  self.m_monsterId = data.monsterId
end
function MonsterBirth_Condition:CheckSatisfy(data)
  if self.m_monsterId == data.monsterId then
    return true
  end
  return false
end
return MonsterBirth_Condition
