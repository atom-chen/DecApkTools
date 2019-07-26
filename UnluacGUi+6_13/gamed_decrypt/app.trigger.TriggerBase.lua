local TriggerBase = class("TriggerBase")
function TriggerBase:ctor(iID, eType, bLoop, conditionType)
  self.m_iID = iID
  self.m_eType = eType
  self.m_bLoop = bLoop
  self.m_conditionType = conditionType or td.ConditionLogicType.type_and
  self.m_bRemove = false
  self.m_vConditions = {}
  self.m_bActive = false
end
function TriggerBase:Update(dt)
  if self.m_bActive then
    return
  end
  local bAllSatisfy = td.ConditionLogicType.type_and == self.m_conditionType and true or false
  for i, v in ipairs(self.m_vConditions) do
    if td.ConditionLogicType.type_and == self.m_conditionType then
      if not v:IsSatisfy() then
        bAllSatisfy = false
        break
      end
    elseif td.ConditionLogicType.type_or == self.m_conditionType and v:IsSatisfy() then
      bAllSatisfy = true
      break
    end
  end
  if bAllSatisfy then
    self:Active()
    if self.m_bLoop then
      for i, v in ipairs(self.m_vConditions) do
        v:SetSatisfy(false)
      end
      self.m_bActive = false
    end
  end
end
function TriggerBase:Active()
  self.m_bActive = true
end
function TriggerBase:SetActive(active)
  self.m_bActive = active
end
function TriggerBase:AddCondition(pCondition)
  table.insert(self.m_vConditions, pCondition)
end
function TriggerBase:RemoveCondition(pCondition)
  table.removebyvalue(self.m_vConditions, pCondition, true)
end
function TriggerBase:ClearAllCondition()
  self.m_vConditions = {}
end
function TriggerBase:GetConditions()
  return self.m_vConditions
end
function TriggerBase:GetID()
  return self.m_iID
end
function TriggerBase:GetType()
  return self.m_eType
end
function TriggerBase:GetLoop()
  return self.m_bLoop
end
function TriggerBase:IsRemove()
  return self.m_bRemove
end
return TriggerBase
