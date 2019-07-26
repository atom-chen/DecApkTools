local AttributeBase = import(".AttributeBase")
local MoveAttribute = class("MoveAttribute", AttributeBase)
MoveAttribute.MoveType = {Absolute = 0, Relative = 1}
function MoveAttribute:ctor(pEffect, fNextAttributeTime, eMoveType, iSpeed, pos, bRotate, bRandom, iAcc, adjustDir)
  MoveAttribute.super.ctor(self, td.AttributeType.Move, pEffect, fNextAttributeTime)
  self.m_pos = pos or cc.p(self.m_pEffect:getPosition())
  self.m_eMoveType = eMoveType or MoveAttribute.MoveType.Relative
  self.m_iSpeed = iSpeed
  self.m_bRotate = bRotate
  if bRandom then
    self.m_iRandomPos = cc.p(math.random(30) - 15, math.random(30) - 15)
  else
    self.m_iRandomPos = cc.p(0, 0)
  end
  self.m_iAccSpeed = iAcc or 0
  self.m_adjustDir = false
  if true == adjustDir then
    self.m_adjustDir = true
  end
end
function MoveAttribute:Active()
  MoveAttribute.super.Active(self)
  if self.m_eMoveType == MoveAttribute.MoveType.Absolute then
    self.m_targetPos = self.m_pos
  elseif self.m_eMoveType == MoveAttribute.MoveType.Relative then
    self.m_targetPos = cc.pAdd(self.m_pos or cc.p(0, 0), cc.p(self.m_pEffect:getPosition()))
  end
  self.m_targetPos = cc.pAdd(self.m_iRandomPos, self.m_targetPos)
  self.m_startPos = cc.p(self.m_pEffect:getPosition())
  if self.m_adjustDir then
    local scaleX = self.m_pEffect:GetContentNode():getScaleX()
    local xOffset = self.m_targetPos.x - self.m_startPos.x
    if xOffset * scaleX < 0 then
      self.m_targetPos.x = self.m_targetPos.x * -1
    end
  end
  if self.m_bRotate then
    self:SetRotation(self.m_startPos, self.m_targetPos)
  end
end
function MoveAttribute:Update(dt)
  MoveAttribute.super.Update(self, dt)
  if self:IsOver() then
    return
  end
  self.m_iSpeed = cc.clampf(self.m_iSpeed + self.m_iAccSpeed * dt, 0, 2000)
  local curPos = cc.p(self.m_pEffect:getPosition())
  local normalizeDir = cc.pNormalize(cc.pSub(self.m_targetPos, curPos))
  local nextPos = cc.pAdd(curPos, cc.pMul(normalizeDir, self.m_iSpeed * dt))
  nextPos = cc.pGetClampPoint(nextPos, self.m_startPos, self.m_targetPos)
  self.m_pEffect:setPosition(nextPos)
  if self.m_bRotate then
    self:SetRotation(curPos, nextPos)
  end
  if cc.pFuzzyEqual(nextPos, self.m_targetPos, 0) then
    self:SetOver()
  end
end
function MoveAttribute:SetRotation(pos, nextPos)
  if cc.pFuzzyEqual(pos, nextPos, 0) then
    return
  end
  local angle = GetAzimuth(pos, nextPos)
  self.m_pEffect:setRotation(angle)
end
return MoveAttribute
