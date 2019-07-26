local ConditionBase = import(".ConditionBase")
local UnlockModuleCondition = class("UnlockModuleCondition", ConditionBase)
function UnlockModuleCondition:ctor(data)
  UnlockModuleCondition.super.ctor(self, td.ConditionType.UnlockModule)
  self.uiId = data.uiId
end
function UnlockModuleCondition:CheckSatisfy(data)
  if data.uiId == self.uiId then
    return true
  end
  return false
end
return UnlockModuleCondition
