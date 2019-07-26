local ConditionBase = class("ConditionBase")
function ConditionBase:ctor(eType)
  self.m_eType = eType
  self.m_bSatisfy = false
end
function ConditionBase:CheckSatisfyOnInit()
  return false
end
function ConditionBase:CheckSatisfy(data)
  return false
end
function ConditionBase:SetSatisfy(bSatisfy)
  self.m_bSatisfy = bSatisfy
end
function ConditionBase:IsSatisfy()
  return self.m_bSatisfy
end
function ConditionBase:GetType()
  return self.m_eType
end
return ConditionBase
