local ConditionBase = import(".ConditionBase")
local HomeStateCondition = class("HomeStateCondition", ConditionBase)
function HomeStateCondition:ctor(data)
  HomeStateCondition.super.ctor(self, td.ConditionType.HomeState)
  self.m_isEnemy = data.isEnemy
  self.m_mapType = data.mapType
end
function HomeStateCondition:CheckSatisfy(data)
  local curMapInfo = require("app.GameDataManager").GetInstance():GetGameMapInfo()
  if curMapInfo and data.isEnemy == self.m_isEnemy and self.m_mapType == curMapInfo.type then
    return true
  end
  return false
end
return HomeStateCondition
