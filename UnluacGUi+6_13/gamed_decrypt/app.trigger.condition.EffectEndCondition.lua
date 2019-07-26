local ConditionBase = import(".ConditionBase")
local EffectEndCondition = class("EffectEndCondition", ConditionBase)
function EffectEndCondition:ctor(data)
  EffectEndCondition.super.ctor(self, td.ConditionType.EffectEnd)
  self.m_effectID = data.effectID
end
function EffectEndCondition:CheckSatisfy(data)
  if data.effectID == self.m_effectID then
    return true
  end
  return false
end
return EffectEndCondition
