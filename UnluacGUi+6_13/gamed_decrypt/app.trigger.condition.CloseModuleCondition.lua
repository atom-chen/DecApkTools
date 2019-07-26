local ConditionBase = import(".ConditionBase")
local CloseModuleCondition = class("CloseModuleCondition", ConditionBase)
function CloseModuleCondition:ctor(data)
  CloseModuleCondition.super.ctor(self, td.ConditionType.CloseModule)
  self.m_moduleID = data.moduleID
end
function CloseModuleCondition:CheckSatisfy(data)
  if data.moduleID == self.m_moduleID then
    return true
  end
  return false
end
return CloseModuleCondition
