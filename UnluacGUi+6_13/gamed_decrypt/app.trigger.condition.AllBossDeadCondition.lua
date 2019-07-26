local ConditionBase = import(".ConditionBase")
local AllBossDeadCondition = class("AllBossDeadCondition", ConditionBase)
function AllBossDeadCondition:ctor(data)
  AllBossDeadCondition.super.ctor(self, td.ConditionType.AllBossDead)
  self.m_allBossCnt = 2
  self.m_mapType = data.mapType
end
function AllBossDeadCondition:CheckSatisfy(data)
  local curMapInfo = require("app.GameDataManager").GetInstance():GetGameMapInfo()
  if curMapInfo then
    local mapType = curMapInfo.type
    if data.deadBossCnt == self.m_allBossCnt and self.m_mapType == mapType then
      return true
    end
  end
  return false
end
return AllBossDeadCondition
