local AttributeBase = import(".AttributeBase")
local LinkAttribute = class("LinkAttribute", AttributeBase)
function LinkAttribute:ctor(pEffect, fNextAttributeTime, sBaseBone, sTargetBone, iOffset)
  LinkAttribute.super.ctor(self, td.AttributeType.Link, pEffect, fNextAttributeTime)
  self.m_baseBone = sBaseBone or "bone_beiji"
  self.m_targetBone = sTargetBone or "bone_beiji"
  self.m_offset = iOffset or 0
  self.m_basePos = cc.p(0, 0)
  self.m_targetPos = cc.p(0, 0)
end
function LinkAttribute:Active()
  LinkAttribute.super.Active(self)
  self:SetOver()
  self.m_basePos = cc.p(self.m_pEffect:getPosition())
  self.m_targetPos = cc.p(self.m_pEffect:getPosition())
  self:Link()
end
function LinkAttribute:Update(dt)
  LinkAttribute.super.Update(self, dt)
  self:Link()
end
function LinkAttribute:Link()
  local base = self.m_pEffect:GetSelfActor()
  if base then
    self.m_basePos = cc.pAdd(cc.p(base:getPosition()), base:FindBonePos(self.m_baseBone))
  end
  local target = self.m_pEffect:GetTargetActor()
  if target then
    self.m_targetPos = cc.pAdd(cc.p(target:getPosition()), target:FindBonePos(self.m_targetBone))
  end
  self.m_pEffect:setPosition(self.m_basePos)
  self.m_pEffect:setRotation(GetAzimuth(self.m_basePos, self.m_targetPos))
  if self.m_pEffect:GetType() == td.EffectType.Spine then
    local scale = self.m_pEffect:getScaleY()
    local oriWidth = self.m_pEffect:GetContentSize().width - self.m_offset
    self.m_pEffect:setScaleX(cc.pGetDistance(self.m_basePos, self.m_targetPos) / oriWidth)
  end
end
return LinkAttribute
