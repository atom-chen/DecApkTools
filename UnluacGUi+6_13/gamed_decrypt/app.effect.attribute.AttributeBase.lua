local AttributeBase = class("AttributeBase")
function AttributeBase:ctor(eType, pEffect, fNextAttributeTime)
  self.m_eType = eType
  self.m_iTag = 0
  self.m_bActive = false
  self.m_bOver = false
  self.m_pEffect = pEffect
  self.m_fNextAttributeStartTime = 0
  self.m_fNextAttributeTime = fNextAttributeTime
  self.m_bExecuteNextAttribute = false
  self.m_isRemove = false
end
function AttributeBase:Active()
  self.m_bActive = true
  if self.m_fNextAttributeTime == 0 then
    self.m_bExecuteNextAttribute = true
  end
end
function AttributeBase:Update(dt)
  if not self.m_bActive then
    return
  end
  if self.m_fNextAttributeTime > 0 and self.m_fNextAttributeStartTime < self.m_fNextAttributeTime then
    self.m_fNextAttributeStartTime = self.m_fNextAttributeStartTime + dt
    if self.m_fNextAttributeStartTime >= self.m_fNextAttributeTime then
      self.m_bExecuteNextAttribute = true
    end
  end
end
function AttributeBase:IsActive()
  return self.m_bActive
end
function AttributeBase:GetType()
  return self.m_eType
end
function AttributeBase:SetTag(iTag)
  self.m_iTag = iTag or 0
end
function AttributeBase:GetTag()
  return self.m_iTag
end
function AttributeBase:SetOver()
  if self.m_fNextAttributeTime == -1 then
    self.m_bExecuteNextAttribute = true
  end
  self.m_bOver = true
end
function AttributeBase:IsOver()
  return self.m_bOver
end
function AttributeBase:IsExecuteNextAttribute()
  return self.m_bExecuteNextAttribute
end
function AttributeBase:Reset()
  self.m_bOver = false
  self.m_bActive = false
  self.m_fNextAttributeStartTime = 0
end
function AttributeBase:SetRemove(isRemove)
  self.m_isRemove = isRemove
end
function AttributeBase:IsRemove()
  return self.m_isRemove
end
return AttributeBase
