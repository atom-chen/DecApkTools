local ConditionBase = import(".ConditionBase")
local MonsterStop_Condition = class("MonsterStop_Condition", ConditionBase)
function MonsterStop_Condition:ctor(data)
  MonsterStop_Condition.super.ctor(self, td.ConditionType.MonsterStop)
  self.m_monsterId = data.monsterId
  self.m_pathId = data.pathId
end
function MonsterStop_Condition:CheckSatisfy(data)
  if self.m_monsterId == data.monsterId and self.m_pathId == data.pathId then
    return true
  end
  return false
end
return MonsterStop_Condition
