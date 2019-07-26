local ConditionBase = import(".ConditionBase")
local AddOrRemoveBuffCondition = class("AddOrRemoveBuffCondition", ConditionBase)
function AddOrRemoveBuffCondition:ctor(data)
  AddOrRemoveBuffCondition.super.ctor(self, td.ConditionType.AddOrRemoveBuff)
end
function AddOrRemoveBuffCondition:CheckSatisfy(data)
  if self.pTrigger.m_monsterId == data.monsterId and self.pTrigger.m_isAdd == data.isAdd then
    self.pTrigger.m_buffId = data.buffId
    return true
  end
  return false
end
return AddOrRemoveBuffCondition
