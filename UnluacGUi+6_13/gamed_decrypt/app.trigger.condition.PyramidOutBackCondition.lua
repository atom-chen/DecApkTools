local ConditionBase = import(".ConditionBase")
local PyramidOutBackCondition = class("PyramidOutBackCondition", ConditionBase)
function PyramidOutBackCondition:ctor(data)
  PyramidOutBackCondition.super.ctor(self, td.ConditionType.PyramidOutBack)
  self.m_state = data.state
end
function PyramidOutBackCondition:CheckSatisfy(data)
  if data.state == self.m_state then
    return true
  end
  return false
end
return PyramidOutBackCondition
