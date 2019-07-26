local ConditionBase = import(".ConditionBase")
local CityStateCondition = class("CityStateCondition", ConditionBase)
function CityStateCondition:ctor(data)
  CityStateCondition.super.ctor(self, td.ConditionType.CityState)
  self.m_cityId = data.cityId
  self.m_cityState = data.state
end
function CityStateCondition:CheckSatisfyOnInit()
  local udMng = require("app.UserDataManager"):GetInstance()
  local citiData = udMng:GetCityData(self.m_cityId)
  if citiData and citiData.state == self.m_cityState then
    return true
  end
  return false
end
function CityStateCondition:CheckSatisfy(data)
  if self.m_cityId == data.cityId and self.m_cityState == data.state then
    return true
  end
  return false
end
return CityStateCondition
