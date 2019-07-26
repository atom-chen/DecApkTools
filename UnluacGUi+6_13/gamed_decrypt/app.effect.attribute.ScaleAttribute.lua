local AttributeBase = import(".AttributeBase")
local ScaleAttribute = class("ScaleAttribute", AttributeBase)
ScaleAttribute.ScaleType = {Relative = 0, Absolute = 1}
function ScaleAttribute:ctor(pEffect, fNextAttributeTime, eScaleType, time, scalex, scaley)
  ScaleAttribute.super.ctor(self, td.AttributeType.Scale, pEffect, fNextAttributeTime)
  self.m_eScaleType = eScaleType
  self.m_fTime = time
  self.m_fScaleX = scalex
  self.m_fScaleY = scaley or self.m_fScaleX
  self.m_fBeginScaleX = 1
  self.m_fBeginScaleY = 1
  self.m_fTimeInterval = 0
end
function ScaleAttribute:Active()
  ScaleAttribute.super.Active(self)
  self.m_fBeginScaleX = self.m_pEffect:getScaleX()
  self.m_fBeginScaleY = self.m_pEffect:getScaleY()
  if self.m_eScaleType == ScaleAttribute.ScaleType.Relative then
    self.m_fScaleX = self.m_fScaleX * self.m_fBeginScaleX
    self.m_fScaleY = self.m_fScaleY * self.m_fBeginScaleY
  end
end
function ScaleAttribute:Update(dt)
  ScaleAttribute.super.Update(self, dt)
  if self:IsOver() then
    return
  end
  self.m_fTimeInterval = self.m_fTimeInterval + dt
  if self.m_fTimeInterval >= self.m_fTime then
    self.m_fTimeInterval = self.m_fTime
    self:SetOver()
  end
  local ratio = self.m_fTimeInterval / self.m_fTime
  self.m_pEffect:setScaleX(self.m_fBeginScaleX + ratio * (self.m_fScaleX - self.m_fBeginScaleX))
  self.m_pEffect:setScaleY(self.m_fBeginScaleY + ratio * (self.m_fScaleY - self.m_fBeginScaleY))
end
return ScaleAttribute
