local ConditionBase = import(".ConditionBase")
local AddOrRemoveSkillCondition = class("AddOrRemoveSkillCondition", ConditionBase)
function AddOrRemoveSkillCondition:ctor(data)
  AddOrRemoveSkillCondition.super.ctor(self, td.ConditionType.IncreaseOrDecreasePath)
  self.m_caidanEffectId = data.caidanEffectId
end
function AddOrRemoveSkillCondition:CheckSatisfy(data)
  if self.pTrigger.m_monsterId == data.monsterId and self.pTrigger.m_isAdd == data.isAdd then
    self.pTrigger.m_skillId = data.skillId
    return true
  end
  return false
end
return AddOrRemoveSkillCondition
