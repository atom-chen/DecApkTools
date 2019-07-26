local ConditionBase = import(".ConditionBase")
local TimeoverCondition = class("TimeoverCondition", ConditionBase)
function TimeoverCondition:ctor(data)
  TimeoverCondition.super.ctor(self, td.ConditionType.TimeOver)
  self.m_timeOver = data.timeOver
  self.m_mapType = data.mapType
end
function TimeoverCondition:CheckSatisfy(data)
  local curMapInfo = require("app.GameDataManager").GetInstance():GetGameMapInfo()
  if curMapInfo then
    local mapType = curMapInfo.type
    if data.timeOver == self.m_timeOver and self.m_mapType == mapType then
      return true
    end
  end
  return false
end
return TimeoverCondition
