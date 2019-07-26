local EffectBase = import(".EffectBase")
local ParticleEffect = class("ParticleEffect", EffectBase)
ParticleEffect.PositionType = {Grouped = 0, Relative = 1}
function ParticleEffect:ctor(pActorBase, pTargetActor, pEffectInfo)
  ParticleEffect.super.ctor(self, pActorBase, pTargetActor, pEffectInfo)
  self.m_pContentNode = ParticleManager:GetInstance():CreateParticle(pEffectInfo.file .. ".plist")
  self.m_pContentNode:setIsRotate(false)
  self.m_pContentNode:retain()
  self.m_ePosType = pEffectInfo.posType or ParticleEffect.PositionType.Relative
  self:AddMembers(pEffectInfo.members)
end
function ParticleEffect:onEnter()
  ParticleEffect.super.onEnter(self)
  if self.m_pContentNode then
    if self.m_ePosType == ParticleEffect.PositionType.Grouped then
      self.m_pContentNode:setPositionType(cc.POSITION_TYPE_GROUPED)
      self:addChild(self.m_pContentNode, 1)
    else
      self.m_pContentNode:setPosition(self:getPosition())
      self.m_pContentNode:setPositionType(cc.POSITION_TYPE_RELATIVE)
      self:getParent():addChild(self.m_pContentNode, 1)
    end
  end
end
function ParticleEffect:onExit()
  ParticleEffect.super.onExit(self)
end
function ParticleEffect:Update(dt)
  ParticleEffect.super.Update(self, dt)
  if self.m_pContentNode then
    local pos = cc.p(self:getPosition())
    local zorder = self:getLocalZOrder()
    self.m_pContentNode:setPosition(pos)
    self.m_pContentNode:setLocalZOrder(zorder)
  end
end
function ParticleEffect:SetRemove()
  ParticleEffect.super.SetRemove(self)
  if self.m_pContentNode then
    self.m_pContentNode:removeFromParent()
    self.m_pContentNode:release()
    self.m_pContentNode = nil
  end
end
function ParticleEffect:setVisible(b)
  if self.m_pContentNode then
    self.m_pContentNode:setVisible(b)
  end
end
function ParticleEffect:setRotation(angle)
  if self.m_pContentNode then
    self.m_pContentNode:setStartSpin(angle)
  end
end
function ParticleEffect:setScale(scale)
  if self.m_pContentNode then
    self.m_pContentNode:setScale(scale)
  end
end
return ParticleEffect
