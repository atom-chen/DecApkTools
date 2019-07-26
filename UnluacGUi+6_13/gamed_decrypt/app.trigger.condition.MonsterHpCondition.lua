local ConditionBase = import(".ConditionBase")
local MonsterHpCondition = class("MonsterHpCondition", ConditionBase)
function MonsterHpCondition:ctor(data)
  MonsterHpCondition.super.ctor(self, td.ConditionType.MonsterHp)
  self.m_monsterId = data.monsterId
  self.hpRatio = data.hpRatio or 0
end
function MonsterHpCondition:CheckSatisfy(data)
  if data.monsterId == self.m_monsterId and data.hpRatio <= self.hpRatio then
    return true
  end
  return false
end
return MonsterHpCondition
