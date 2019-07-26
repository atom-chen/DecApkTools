local AttributeBase = import(".AttributeBase")
local RevolveAttribute = class("RevolveAttribute", AttributeBase)
td.RevolveType = {
  Relative = 0,
  Absolute = 1,
  Forever = 2
}
function RevolveAttribute:ctor(pEffect, fNextAttributeTime, eRevolveType, iSpeed, angle, center, bRotate)
  RevolveAttribute.super.ctor(self, td.AttributeType.Revolve, pEffect, fNextAttributeTime)
  self.m_eRevolveType = eRevolveType
  self.m_iSpeed = iSpeed
  self.m_iAngle = 0
  self.m_iStartAngle = 0
  self.m_iEndAngle = angle
  self.m_iRadius = 0
  self.m_centerPos = center
  self.m_iClockwise = bClockwise and -1 or 1
  self.m_bRotate = bRotate
end
function RevolveAttribute:Active()
  RevolveAttribute.super.Active(self)
  local effectPos = cc.p(self.m_pEffect:getPosition())
  if not self.m_centerPos then
    local boneName = self.m_pEffect:GetBindingBone()
    if self.m_pEffect:GetSelfActor() then
      if boneName then
        self.m_centerPos = cc.pAdd(cc.p(self.m_pEffect:GetSelfActor():getPosition()), self.m_pEffect:GetSelfActor():FindBonePos(boneName))
      else
        self.m_centerPos = cc.p(self.m_pEffect:GetSelfActor():getPosition())
      end
    elseif self.m_pEffect:GetTargetActor() then
      if boneName then
        self.m_centerPos = cc.pAdd(cc.p(self.m_pEffect:GetTargetActor():getPosition()), self.m_pEffect:GetTargetActor():FindBonePos(boneName))
      else
        self.m_centerPos = cc.p(self.m_pEffect:GetTargetActor():getPosition())
      end
    else
      self.m_centerPos = effectPos
    end
  end
  self.m_iRadius = cc.pGetDistance(effectPos, self.m_centerPos)
  self.m_iStartAngle = self:GetNormalAngle(-GetAzimuth(self.m_centerPos, effectPos))
  if self.m_eRevolveType == td.RevolveType.Absolute then
    self.m_iEndAngle = self.m_iEndAngle - self.m_iStartAngle
  elseif self.m_eRevolveType == td.RevolveType.Forever then
    self:IsOver()
  end
  if self.m_iEndAngle >= 0 then
    self.m_iClockwise = 1
  else
    self.m_iClockwise = -1
  end
end
function RevolveAttribute:Update(dt)
  RevolveAttribute.super.Update(self, dt)
  local angleDt = self.m_iClockwise * self.m_iSpeed * dt
  if self.m_eRevolveType == td.RevolveType.Forever then
    if self.m_iClockwise == 1 then
      self.m_iAngle = self.m_iAngle + angleDt
    else
      self.m_iAngle = self.m_iAngle + angleDt
    end
  else
    if self:IsOver() then
      return
    end
    if self.m_iClockwise == 1 then
      self.m_iAngle = cc.clampf(self.m_iAngle + angleDt, self.m_iAngle, self.m_iEndAngle)
    else
      self.m_iAngle = cc.clampf(self.m_iAngle + angleDt, self.m_iEndAngle, self.m_iAngle)
    end
  end
  local nextAngle = self.m_iStartAngle + self.m_iAngle
  local lastPos = cc.p(self.m_pEffect:getPosition())
  local posX = self.m_iRadius * math.cos(math.rad(nextAngle))
  local posY = self.m_iRadius * math.sin(math.rad(nextAngle))
  local nextPos = cc.pAdd(self.m_centerPos, cc.p(posX, posY))
  self.m_pEffect:setPosition(nextPos)
  if self.m_bRotate then
    self:SetRotation(lastPos, nextPos)
  end
  if self.m_eRevolveType ~= td.RevolveType.Forever and self.m_iAngle == self.m_iEndAngle then
    self:SetOver()
  end
end
function RevolveAttribute:SetRotation(pos, nextPos)
  if cc.pFuzzyEqual(pos, nextPos, 0) then
    return
  end
  local angle = GetAzimuth(pos, nextPos)
end
function RevolveAttribute:GetNormalAngle(angle)
  return (360 + angle) % 360
end
return RevolveAttribute
