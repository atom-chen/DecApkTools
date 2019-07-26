local AttributeBase = import(".AttributeBase")
local ParabolaAttribute = class("ParabolaAttribute", AttributeBase)
local G = 30
local MeterPix = 50
ParabolaAttribute.FixedType = {Time = 0, Speed = 1}
ParabolaAttribute.MoveType = {Absolute = 0, Relative = 1}
function ParabolaAttribute:ctor(pEffect, fNextAttributeTime, fixedType, fixedValue, rotate, pos, eMoveType, ccpRandom, gravity)
  ParabolaAttribute.super.ctor(self, td.AttributeType.Parabola, pEffect, fNextAttributeTime)
  if fixedType == ParabolaAttribute.FixedType.Time then
    self.m_iTime = fixedValue
  else
    self.m_iSpeed = fixedValue
  end
  self.m_iGravity = gravity or G
  self.m_pos = pos
  if ccpRandom.x ~= 0 or not 0 then
  end
  if ccpRandom.y ~= 0 or not 0 then
  end
  self.m_iRandomPos = cc.p(math.random(ccpRandom.x) - ccpRandom.x / 2, math.random(ccpRandom.y) - ccpRandom.y / 2)
  self.m_bRotate = rotate
  self.m_eMoveType = eMoveType or ParabolaAttribute.MoveType.Absolute
  self.m_fTimeInterval = 0
end
function ParabolaAttribute:Active()
  ParabolaAttribute.super.Active(self)
  self.m_beginPos = cc.p(self.m_pEffect:getPosition())
  if self.m_eMoveType == ParabolaAttribute.MoveType.Absolute then
    if self.m_pos then
      self.m_endPos = self.m_pos
    elseif self.m_pEffect:GetTargetActor() then
      local pTargetActor = self.m_pEffect:GetTargetActor()
      if pTargetActor:GetType() == td.ActorType.Home or pTargetActor:GetCareerType() == td.CareerType.Fly then
        self.m_endPos = pTargetActor:GetBeHitPos()
      else
        self.m_endPos = cc.p(pTargetActor:getPosition())
      end
    else
      self.m_endPos = cc.p(self.m_pEffect:getPosition())
    end
  else
    self.m_endPos = cc.pAdd(self.m_pos or cc.p(0, 0), cc.p(self.m_pEffect:getPosition()))
  end
  self.m_endPos = cc.pAdd(self.m_endPos, self.m_iRandomPos)
  if self.m_iTime == nil then
    self.m_iTime = cc.pGetDistance(self.m_beginPos, self.m_endPos) / self.m_iSpeed
  end
  self.m_speedX = (self.m_endPos.x - self.m_beginPos.x) / self.m_iTime
  self.m_speedY = self:GetBeginSpeedY()
  if self.m_bRotate then
    self:SetRotation(self.m_fTimeInterval)
  end
end
function ParabolaAttribute:Update(dt)
  ParabolaAttribute.super.Update(self, dt)
  if self:IsOver() then
    return
  end
  local lastTime = self.m_fTimeInterval
  self.m_fTimeInterval = cc.clampf(self.m_fTimeInterval + dt, 0, self.m_iTime)
  local posX = self.m_fTimeInterval * self.m_speedX
  local posY = 0
  local timeHighest = self.m_speedY / self.m_iGravity
  if timeHighest >= self.m_fTimeInterval then
    posY = (self.m_speedY + self.m_speedY - self.m_iGravity * self.m_fTimeInterval) * self.m_fTimeInterval / 2
  else
    local highest = self.m_speedY * timeHighest / 2
    local fallTime = self.m_fTimeInterval - timeHighest
    posY = highest - self.m_iGravity * fallTime * fallTime / 2
  end
  posY = posY * MeterPix
  self.m_pEffect:setPosition(cc.pAdd(self.m_beginPos, cc.p(posX, posY)))
  if self.m_bRotate then
    self:SetRotation(self.m_fTimeInterval)
  end
  if self.m_fTimeInterval == self.m_iTime then
    self:SetOver()
  end
end
function ParabolaAttribute:SetRotation(time)
  local spX = self.m_speedX / MeterPix
  local spY = self.m_speedY - self.m_iGravity * time
  local angle = GetAzimuth(cc.p(0, 0), cc.p(spX, spY))
  self.m_pEffect:setRotation(angle)
end
function ParabolaAttribute:GetBeginSpeedY()
  local diffInMeter = (self.m_endPos.y - self.m_beginPos.y) / MeterPix
  return (self.m_iGravity * self.m_iTime * self.m_iTime + 2 * diffInMeter) / (2 * self.m_iTime)
end
return ParabolaAttribute
