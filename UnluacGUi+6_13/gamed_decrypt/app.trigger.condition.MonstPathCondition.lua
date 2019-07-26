local ConditionBase = import(".ConditionBase")
local MonstPathCondition = class("MonstPathCondition", ConditionBase)
function MonstPathCondition:ctor(data)
  MonstPathCondition.super.ctor(self, td.ConditionType.MonstPath)
  self.m_pathId = data.pathId
end
function MonstPathCondition:CheckSatisfy(data)
  if data.pathId == self.m_pathId then
    return true
  end
  return false
end
return MonstPathCondition
