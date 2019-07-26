local AttributeBase = import(".AttributeBase")
local TurnAttribute = class("TurnAttribute", AttributeBase)
function TurnAttribute:ctor(pEffect, fNextAttributeTime, iSpeed, radius, bRotate)
  TurnAttribute.super.ctor(self, td.AttributeType.Turn, pEffect, fNextAttributeTime)
  self.m_eRevolveType = eRevolveType
  self.m_iSpeed = iSpeed
  self.m_iAngle = 0
  self.m_iStartAngle = 0
  self.m_iRadius = radius
  self.m_centerPos = nil
  self.m_iClockwise = bClockwise and -1 or 1
  self.m_bRotate = bRotate
  self.m_targetPos = nil
  self.m_iOffset = iSpeed / 30 + 1
end
function TurnAttribute:Active()
  TurnAttribute.super.Active(self)
  local curRotation = GetAzimuth(cc.p(0, 0), self.m_pEffect:GetDirection())
  local effectPos = cc.p(self.m_pEffect:getPosition())
  self.m_targetPos = self.m_pEffect:UpdateTargetPos()
  local v1 = self.m_pEffect:GetDirection()
  local v2 = cc.pNormalize(cc.pSub(self.m_targetPos, effectPos))
  local cross = cc.pCross(v1, v2)
  if cross >= 0 then
    self.m_iClockwise = -1
  else
    self.m_iClockwise = 1
  end
  local center = cc.p(self.m_iRadius * math.cos(math.rad(-curRotation + self.m_iClockwise * 90)), self.m_iRadius * math.sin(math.rad(-curRotation + self.m_iClockwise * 90)))
  self.m_centerPos = cc.pAdd(effectPos, center)
  self.m_iStartAngle = self:GetNormalAngle(-1 * self.m_iClockwise * 90) - self:GetNormalAngle(curRotation)
  self.m_iStartAngle = self:GetNormalAngle(self.m_iStartAngle)
end
function TurnAttribute:Update(dt)
  TurnAttribute.super.Update(self, dt)
  if self:IsOver() then
    return
  end
  self.m_targetPos = self.m_pEffect:UpdateTargetPos()
  if cc.pDistanceSQ(self.m_targetPos, self.m_centerPos) <= self.m_iRadius * self.m_iRadius then
    self:SetOver()
    return
  end
  self.m_iAngle = self:GetNormalAngle(self.m_iAngle + self.m_iClockwise * self.m_iSpeed * dt)
  local curAngle = self.m_iStartAngle + self.m_iAngle
  local lastPos = cc.p(self.m_pEffect:getPosition())
  local posX = self.m_iRadius * math.cos(math.rad(curAngle))
  local posY = self.m_iRadius * math.sin(math.rad(curAngle))
  local nextPos = cc.pAdd(self.m_centerPos, cc.p(posX, posY))
  self.m_pEffect:setPosition(nextPos)
  local dir = self.m_pEffect:GetDirection()
  local targetDir = cc.pSub(self.m_targetPos, nextPos)
  local dirAngle1 = self.m_iClockwise * math.deg(cc.pGetAngle(dir, targetDir))
  local dirAngle2 = self.m_iClockwise * math.deg(cc.pGetAngle(targetDir, dir))
  if dirAngle1 >= 0 and dirAngle1 < self.m_iOffset or dirAngle1 <= 0 and dirAngle1 > -self.m_iOffset then
    self:SetOver()
  elseif dirAngle2 >= 0 and dirAngle2 < self.m_iOffset or dirAngle2 <= 0 and dirAngle2 > -self.m_iOffset then
    self:SetOver()
  end
  if self.m_bRotate then
    self:SetRotation(lastPos, nextPos)
  end
end
function TurnAttribute:SetRotation(pos, nextPos)
  if cc.pFuzzyEqual(pos, nextPos, 0) then
    return
  end
  local angle = GetAzimuth(pos, nextPos)
  self.m_pEffect:setRotation(angle)
end
function TurnAttribute:GetNormalAngle(angle)
  return (360 + angle) % 360
end
return TurnAttribute
