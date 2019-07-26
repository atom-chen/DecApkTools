local ConditionBase = import(".ConditionBase")
local AllSideDeadCondition = class("AllSideDeadCondition", ConditionBase)
function AllSideDeadCondition:ctor(data)
  AllSideDeadCondition.super.ctor(self, td.ConditionType.AllSideDead)
  self.m_isEnemy = data.isEnemy
  self.m_mapType = data.mapType
end
function AllSideDeadCondition:CheckSatisfy(data)
  local curMapInfo = require("app.GameDataManager").GetInstance():GetGameMapInfo()
  if curMapInfo then
    local mapType = curMapInfo.type
    if data.isEnemy == self.m_isEnemy and self.m_mapType == mapType then
      return true
    end
  end
  return false
end
return AllSideDeadCondition
