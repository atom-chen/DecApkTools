local ConditionBase = import(".ConditionBase")
local MonsterRefreshCountEndCondition = class("MonsterRefreshCountEndCondition", ConditionBase)
function MonsterRefreshCountEndCondition:ctor(data)
  MonsterRefreshCountEndCondition.super.ctor(self, td.ConditionType.AfterRefreshMonster)
  self.m_waveCnts = data.waveCnt
end
function MonsterRefreshCountEndCondition:CheckSatisfy(data)
  for k, value in pairs(self.m_waveCnts) do
    if value == data.waveCnt then
      return true
    end
  end
  return false
end
return MonsterRefreshCountEndCondition
