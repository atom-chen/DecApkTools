local ConditionBase = import(".ConditionBase")
local MonsterRefreshCountCondition = class("MonsterRefreshCountCondition", ConditionBase)
function MonsterRefreshCountCondition:ctor(data)
  MonsterRefreshCountCondition.super.ctor(self, td.ConditionType.BeforeRefreshMonster)
  self.m_waveCnts = data.waveCnt
end
function MonsterRefreshCountCondition:CheckSatisfy(data)
  for k, value in pairs(self.m_waveCnts) do
    if value == data.waveCnt or value == -1 then
      return true
    end
  end
  return false
end
return MonsterRefreshCountCondition
