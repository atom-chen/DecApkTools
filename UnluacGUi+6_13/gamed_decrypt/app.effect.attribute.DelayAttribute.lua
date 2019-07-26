local AttributeBase = import(".AttributeBase")
local DelayAttribute = class("DelayAttribute", AttributeBase)
function DelayAttribute:ctor(pEffect, fNextAttributeTime, range)
  if range and range.min and range.max then
    if range.max > 1 then
      fNextAttributeTime = range.min + math.random(range.max - range.min)
    elseif range.max > 0 and range.max <= 1 then
      fNextAttributeTime = range.min + math.random((range.max - range.min) * 100) / 100
    end
  end
  DelayAttribute.super.ctor(self, td.AttributeType.Delay, pEffect, fNextAttributeTime)
end
function DelayAttribute:Update(dt)
  if not self.m_bActive then
    return
  end
  if self:IsOver() then
    return
  end
  if self.m_fNextAttributeTime > 0 then
    if self.m_fNextAttributeStartTime >= self.m_fNextAttributeTime then
      self.m_bExecuteNextAttribute = true
      self:SetOver()
    else
      self.m_fNextAttributeStartTime = self.m_fNextAttributeStartTime + dt
    end
  end
end
return DelayAttribute
