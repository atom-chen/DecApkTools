local ConditionBase = import(".ConditionBase")
local SacrificeMonster_Condition = class("SacrificeMonster_Condition", ConditionBase)
function SacrificeMonster_Condition:ctor(data)
  SacrificeMonster_Condition.super.ctor(self, td.ConditionType.SacrificeMonster)
  self.m_monsterId = data.monsterId
end
function SacrificeMonster_Condition:CheckSatisfy(data)
  if self.m_monsterId == data.monsterId then
    return true
  end
  return false
end
return SacrificeMonster_Condition
