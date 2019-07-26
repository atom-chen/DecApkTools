local AttributeBase = import(".AttributeBase")
local SinMoveAttribute = class("SinMoveAttribute", AttributeBase)
function SinMoveAttribute:ctor(pEffect, fNextAttributeTime, iSpeed, pos, bRotate)
  SinMoveAttribute.super.ctor(self, td.AttributeType.SinMove, pEffect, fNextAttributeTime)
  self.m_iSpeed = iSpeed
  self.m_Pos = pos
  self.m_bRotate = bRotate
  self.m_iTimeInterval = 0
  self.m_iWavelength = 100
  self.m_iA = 5
  self.m_iW = 0
end
function SinMoveAttribute:Active()
  SinMoveAttribute.super.Active(self)
  if self.m_Pos == nil then
    self.m_Pos = self.m_pEffect:UpdateTargetPos()
  end
  self.m_startPos = cc.p(self.m_pEffect:getPosition())
  self.m_iAngle = -GetAzimuth(self.m_startPos, self.m_Pos)
  self.m_iLength = cc.pGetLength(cc.pSub(self.m_startPos, self.m_Pos))
  local n = math.round(self.m_iLength / (self.m_iWavelength / 2))
  self.m_iW = math.pi / (self.m_iLength / n)
  if self.m_bRotate then
    self:SetRotation(self.m_startPos, self.m_Pos)
  end
end
function SinMoveAttribute:Update(dt)
  SinMoveAttribute.super.Update(self, dt)
  if self:IsOver() then
    return
  end
  self.m_iTimeInterval = self.m_iTimeInterval + dt
  local curPos = cc.p(self.m_pEffect:getPosition())
  local nextX = self.m_iTimeInterval * self.m_iSpeed
  if nextX >= self.m_iLength then
    nextX = self.m_iLength
    self:SetOver()
  end
  local nextY = self.m_iA * math.sin(self.m_iW * nextX)
  local nextPos = cc.p(nextX, nextY)
  nextPos = cc.pRotate(nextPos, cc.pForAngle(math.rad(self.m_iAngle)))
  nextPos = cc.pAdd(self.m_startPos, nextPos)
  self.m_pEffect:setPosition(nextPos)
  if self.m_bRotate then
    self:SetRotation(curPos, nextPos)
  end
end
function SinMoveAttribute:SetRotation(pos, nextPos)
  if cc.pFuzzyEqual(pos, nextPos, 0) then
    return
  end
  local angle = GetAzimuth(pos, nextPos)
  self.m_pEffect:setRotation(angle)
end
return SinMoveAttribute
