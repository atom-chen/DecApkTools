local AttributeBase = import(".AttributeBase")
local ActorManager = require("app.actor.ActorManager")
local CollideAttribute = class("CollideAttribute", AttributeBase)
CollideAttribute.OverType = {
  Count = 0,
  Time = 1,
  Forever = 2
}
CollideAttribute.GroupType = {
  All = 0,
  Self = 1,
  Enemy = 2
}
CollideAttribute.CHECK_TIME_GAP = 0.5
function CollideAttribute:ctor(pEffect, fNextAttributeTime, eGroupType, eOverType, value, iWidth, iHeight)
  CollideAttribute.super.ctor(self, td.AttributeType.Collide, pEffect, fNextAttributeTime)
  self.m_eGroupType = eGroupType
  self.m_eOverType = eOverType
  self.m_iValue = value or 0
  self.m_iWidth = iWidth
  self.m_iHeight = iHeight
  self.m_iCount = 0
  self.m_iTimeInterval = 0
  self.m_iCheckTime = 0
  self.m_vCollideActors = {}
end
function CollideAttribute:Active()
  CollideAttribute.super.Active(self)
  self.m_eSelfGroup = self.m_pEffect:GetSelfActorParams().group
  local pSkill = self.m_pEffect:GetSkill()
  if pSkill and (self.m_iWidth == nil or self.m_iHeight == nil) then
    self.m_iWidth, self.m_iHeight = pSkill:GetDamageRange()
  end
end
function CollideAttribute:Update(dt)
  CollideAttribute.super.Update(self, dt)
  if not self.m_bActive then
    return
  end
  if self:IsOver() and self.m_eOverType ~= CollideAttribute.OverType.Forever then
    return
  end
  if self.m_eOverType == CollideAttribute.OverType.Time then
    self.m_iTimeInterval = self.m_iTimeInterval + dt
    if self.m_iTimeInterval >= self.m_iValue then
      self:SetOver()
      return
    end
  end
  self.m_iCheckTime = self.m_iCheckTime + dt
  if self.m_iCheckTime < CollideAttribute.CHECK_TIME_GAP then
    return
  else
    self.m_iCheckTime = 0
  end
  local x, y = self.m_pEffect:getPosition()
  local checkRect = cc.rect(x - self.m_iWidth / 2, y - self.m_iHeight / 2, self.m_iWidth, self.m_iHeight)
  if self.m_eGroupType == CollideAttribute.GroupType.All or self.m_eGroupType == CollideAttribute.GroupType.Self and self.m_eSelfGroup == td.GroupType.Self or self.m_eGroupType == CollideAttribute.GroupType.Enemy and self.m_eSelfGroup == td.GroupType.Enemy then
    local vec = ActorManager:GetInstance():GetSelfVec()
    for i, v in pairs(vec) do
      local isOver = self:CollideCheck(checkRect, v)
      if isOver then
        self:DoCollide()
        return
      end
    end
  end
  if self.m_eGroupType == CollideAttribute.GroupType.All or self.m_eGroupType == CollideAttribute.GroupType.Self and self.m_eSelfGroup == td.GroupType.Enemy or self.m_eGroupType == CollideAttribute.GroupType.Enemy and self.m_eSelfGroup == td.GroupType.Self then
    local vec = ActorManager:GetInstance():GetEnemyVec()
    for i, v in pairs(vec) do
      if not v:IsDead() then
        local isOver = self:CollideCheck(checkRect, v)
        if isOver then
          self:DoCollide()
          return
        end
      end
    end
  end
  self:DoCollide()
end
function CollideAttribute:CollideCheck(rect, pActor)
  if cc.rectContainsPoint(rect, cc.p(pActor:getPosition())) then
    local pSkill = self.m_pEffect:GetSkill()
    if pSkill then
      table.insert(self.m_vCollideActors, pActor)
      self.m_iCount = self.m_iCount + 1
    else
      self.m_iCount = self.m_iCount + 1
    end
    if self.m_eOverType == CollideAttribute.OverType.Count and self.m_iCount >= self.m_iValue then
      self:SetOver()
      return true
    end
  end
  return false
end
function CollideAttribute:DoCollide()
  local pSkill = self.m_pEffect:GetSkill()
  if pSkill then
    pSkill:DidCollide(self.m_vCollideActors, self.m_pEffect)
  end
  self.m_vCollideActors = {}
end
return CollideAttribute
