local AttributeBase = import(".AttributeBase")
local PathTrackAttribute = class("PathTrackAttribute", AttributeBase)
function PathTrackAttribute:ctor(pEffect, fNextAttributeTime, iSpeed, bRotate, bRefind)
  PathTrackAttribute.super.ctor(self, td.AttributeType.Track, pEffect, fNextAttributeTime)
  self.m_iSpeed = iSpeed
  self.m_bRotate = bRotate
  self.m_bRefind = bRefind
  self.m_pTarget = nil
  self.m_targetPos = nil
  self.m_pMap = require("app.GameDataManager"):GetInstance():GetGameMap()
end
function PathTrackAttribute:Active()
  PathTrackAttribute.super.Active(self)
  self:FindTargetAndSetPath()
end
function PathTrackAttribute:FindTargetAndSetPath()
  self.m_pTarget = self:FindTarget()
  if not self.m_pTarget then
    self:SetOver()
    return false
  end
  self.m_targetPos = cc.p(self.m_pTarget:GetBeHitPos())
  self.m_startPos = cc.p(self.m_pEffect:getPosition())
  self.m_PathVec = self.m_pMap:FindPath(self.m_startPos, self.m_targetPos)
  if #self.m_PathVec == 0 then
    self:SetOver()
    return false
  end
  return true
end
function PathTrackAttribute:Update(dt)
  PathTrackAttribute.super.Update(self, dt)
  if self:IsOver() then
    return
  end
  if self.m_pTarget:IsDead() and not self:FindTargetAndSetPath() then
    return
  end
  if #self.m_PathVec ~= 0 then
    local pos = self.m_PathVec[1]
    local curPos = cc.p(self.m_pEffect:getPosition())
    local normalizePos = cc.pNormalize(cc.pSub(pos, curPos))
    local tempPos = cc.pAdd(curPos, cc.pMul(normalizePos, self.m_iSpeed * dt))
    if PulibcFunc:GetInstance():GetDirection(curPos, pos) == PulibcFunc:GetInstance():GetDirection(tempPos, pos) and not cc.pFuzzyEqual(normalizePos, cc.p(0, 0), 0) then
      self.m_pEffect:setPosition(tempPos)
    else
      tempPos = pos
      table.remove(self.m_PathVec, 1)
      self.m_pEffect:setPosition(tempPos)
      if table.nums(self.m_PathVec) == 0 then
        self:SetOver()
      end
    end
  end
  self.m_pMap:reorderChild(self.m_pEffect, self.m_pMap:GetPiexlSize().height - self.m_pEffect:getPositionY())
end
function PathTrackAttribute:SetRotation(pos, nextPos)
  if cc.pFuzzyEqual(pos, nextPos, 0) then
    return
  end
  local angle = GetAzimuth(pos, nextPos)
  self.m_pEffect:setRotation(angle)
end
function PathTrackAttribute:FindTarget()
  if self.m_pTarget and not self.m_pTarget:IsDead() then
    return self.m_pTarget
  end
  local target = self.m_pEffect:GetTargetActor()
  if target and not target:IsDead() then
    return target
  elseif not self.m_bRefind then
    return nil
  end
  local actorManager = require("app.actor.ActorManager"):GetInstance()
  local pMap = self.m_pMap
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
return PathTrackAttribute
