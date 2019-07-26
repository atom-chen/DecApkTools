local ConditionBase = import(".ConditionBase")
local DeputyHomeDead_Condition = class("DeputyHomeDead_Condition", ConditionBase)
function DeputyHomeDead_Condition:ctor(data)
  DeputyHomeDead_Condition.super.ctor(self, td.ConditionType.DeputyDead)
  self.m_deputyId = data.deputyId
end
function DeputyHomeDead_Condition:CheckSatisfy(data)
  if self.m_deputyId == data.deputyId then
    return true
  end
  return false
end
return DeputyHomeDead_Condition
