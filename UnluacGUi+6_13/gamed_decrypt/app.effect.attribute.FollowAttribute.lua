local AttributeBase = import(".AttributeBase")
local FollowAttribute = class("FollowAttribute", AttributeBase)
function FollowAttribute:ctor(pEffect, fNextAttributeTime, zOrder, time, offsetX, offsetY, bTarget)
  FollowAttribute.super.ctor(self, td.AttributeType.Follow, pEffect, fNextAttributeTime)
  self.m_iZOrder = zOrder
  self.m_iTime = time
  self.m_iOffsetX = offsetX or 0
  self.m_iOffsetY = offsetY or 0
  self.m_bone = self.m_pEffect:GetBindingBone() or "root"
  self.m_bIsFollowTarget = bTarget
  self.m_iTimeInterval = 0
end
function FollowAttribute:Active()
  FollowAttribute.super.Active(self)
  self:Follow()
  if self.m_iTime == -1 then
    self:SetOver()
  end
end
function FollowAttribute:Update(dt)
  FollowAttribute.super.Update(self, dt)
  if self:IsOver() and self.m_iTime ~= -1 then
    return
  end
  self.m_iTimeInterval = self.m_iTimeInterval + dt
  if self.m_iTime ~= -1 and self.m_iTimeInterval >= self.m_iTime then
    self:SetOver()
  end
  self:Follow()
end
function FollowAttribute:Follow()
  local targetActor
  if self.m_bIsFollowTarget then
    targetActor = self.m_pEffect:GetTargetActor()
  else
    targetActor = self.m_pEffect:GetSelfActor()
  end
  if targetActor then
    local pos = cc.pAdd(cc.p(targetActor:getPosition()), targetActor:FindBonePos(self.m_bone))
    self.m_pEffect:setPosition(cc.pAdd(pos, cc.p(self.m_iOffsetX, self.m_iOffsetY)))
    if self.m_iZOrder then
      self.m_pEffect:setLocalZOrder(targetActor:getLocalZOrder() + self.m_iZOrder)
    end
  end
end
return FollowAttribute
