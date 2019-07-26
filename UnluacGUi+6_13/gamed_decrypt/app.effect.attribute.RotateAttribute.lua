local AttributeBase = import(".AttributeBase")
local RotateAttribute = class("RotateAttribute", AttributeBase)
RotateAttribute.RotateType = {
  Relative = 0,
  Absolute = 1,
  Random = 2,
  Forever = 3
}
function RotateAttribute:ctor(pEffect, fNextAttributeTime, eRotateType, angle, speed)
  RotateAttribute.super.ctor(self, td.AttributeType.Rotate, pEffect, fNextAttributeTime)
  if bForever == nil then
    bForever = false
  end
  self.m_eRotateType = eRotateType
  self.m_iAngle = 0
  self.m_iEndAngle = angle or 0
  self.m_iSpeed = speed or 0
end
function RotateAttribute:Active()
  RotateAttribute.super.Active(self)
  if self.m_eRotateType == RotateAttribute.RotateType.Absolute then
    local startAngle = self.m_pEffect:getRotation()
    self.m_iEndAngle = self.m_iEndAngle - startAngle
  elseif self.m_eRotateType == RotateAttribute.RotateType.Random then
    self.m_pEffect:setRotation(math.random(360))
    self:SetOver()
  elseif self.m_eRotateType == RotateAttribute.RotateType.Forever then
    self:SetOver()
  end
  if self.m_iEndAngle >= 0 then
    self.m_iClockwise = 1
  else
    self.m_iClockwise = -1
  end
  self.m_iAngle = self.m_pEffect:getRotation()
end
function RotateAttribute:Update(dt)
  RotateAttribute.super.Update(self, dt)
  local angleDt = self.m_iClockwise * self.m_iSpeed * dt
  if self.m_eRotateType == RotateAttribute.RotateType.Forever then
    self.m_iAngle = self.m_iAngle + angleDt
  else
    if self:IsOver() then
      return
    end
    if self.m_iClockwise == 1 then
      self.m_iAngle = cc.clampf(self.m_iAngle + angleDt, self.m_iAngle, self.m_iEndAngle)
    else
      self.m_iAngle = cc.clampf(self.m_iAngle + angleDt, self.m_iEndAngle, self.m_iAngle)
    end
    if self.m_iAngle == self.m_iEndAngle then
      self:SetOver()
    end
  end
  self.m_pEffect:setRotation(self.m_iAngle)
end
return RotateAttribute
