local AttributeBase = import(".AttributeBase")
local TrackAttribute = class("TrackAttribute", AttributeBase)
function TrackAttribute:ctor(pEffect, fNextAttributeTime, iSpeed, bRotate, bRefind, bRandom)
  TrackAttribute.super.ctor(self, td.AttributeType.Track, pEffect, fNextAttributeTime)
  self.m_iSpeed = iSpeed
  self.m_bRotate = bRotate
  self.m_bRefind = bRefind
  if bRandom then
    self.m_iRandomPos = cc.p(math.random(30) - 15, math.random(30) - 15)
  else
    self.m_iRandomPos = cc.p(0, 0)
  end
  self.m_pTarget = nil
  self.m_targetPos = cc.pAdd(self.m_iRandomPos, self.m_pEffect:UpdateTargetPos())
end
function TrackAttribute:Active()
  TrackAttribute.super.Active(self)
  self.m_pTarget = self:FindTarget()
  if self.m_pTarget then
    self.m_targetPos = cc.pAdd(self.m_iRandomPos, self.m_pEffect:UpdateTargetPos())
  end
  self.m_startPos = cc.p(self.m_pEffect:getPosition())
  if self.m_bRotate then
    self:SetRotation(cc.p(self.m_pEffect:getPosition()), self.m_targetPos)
  end
end
function TrackAttribute:Update(dt)
  TrackAttribute.super.Update(self, dt)
  if self:IsOver() then
    return
  end
  local pTarget = self:FindTarget()
  if pTarget then
    self.m_targetPos = cc.pAdd(self.m_iRandomPos, self.m_pEffect:UpdateTargetPos())
  end
  local curPos = cc.p(self.m_pEffect:getPosition())
  local normalizeDir = cc.pNormalize(cc.pSub(self.m_targetPos, curPos))
  local nextPos = cc.pAdd(curPos, cc.pMul(normalizeDir, self.m_iSpeed * dt))
  nextPos = cc.pGetClampPoint(nextPos, self.m_startPos, self.m_targetPos)
  self.m_pEffect:setPosition(nextPos)
  if self.m_bRotate then
    self:SetRotation(curPos, nextPos)
  end
  if cc.pFuzzyEqual(nextPos, self.m_targetPos, self.m_iSpeed * dt) then
    self:SetOver()
  end
end
function TrackAttribute:SetRotation(pos, nextPos)
  if cc.pFuzzyEqual(pos, nextPos, 0) then
    return
  end
  local angle = GetAzimuth(pos, nextPos)
  self.m_pEffect:setRotation(angle)
end
function TrackAttribute:FindTarget()
  local target = self.m_pEffect:GetTargetActor()
  if target and not target:IsDead() then
    return target
  elseif not self.m_bRefind then
    return nil
  end
  local actorManager = require("app.actor.ActorManager"):GetInstance()
  local pMap = require("app.GameDataManager"):GetInstance():GetGameMap()
  local selfPos = cc.p(self.m_pEffect:getPosition())
  local vec = {}
  if self.m_pEffect:GetSelfActorParams().group == td.GroupType.Enemy then
    vec = actorManager:GetSelfVec()
  elseif self.m_pEffect:GetSelfActorParams().group == td.GroupType.Self then
    vec = actorManager:GetEnemyVec()
  end
  local shortDisSQ = -1
  for tag, actor in pairs(vec) do
    if not actor:IsDead() then
      local pos = cc.p(actor:getPosition())
      local disSQ = cc.pDistanceSQ(selfPos, pos)
      if shortDisSQ == -1 or shortDisSQ > disSQ then
        shortDisSQ = disSQ
        target = actor
      end
    end
  end
  self.m_pEffect:SetTargetActor(target)
  return target
end
return TrackAttribute
