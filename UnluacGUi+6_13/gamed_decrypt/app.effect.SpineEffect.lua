local EffectBase = import(".EffectBase")
local SpineEffect = class("SpineEffect", EffectBase)
function SpineEffect:ctor(pActorBase, pTargetActor, pEffectInfo)
  SpineEffect.super.ctor(self, pActorBase, pTargetActor, pEffectInfo)
  self.m_pContentNode = SkeletonUnit:create(pEffectInfo.file)
  if self.m_pContentNode then
    self.m_pContentNode:setPosition(0, 0)
    self:addChild(self.m_pContentNode, 1)
  end
  self:AddMembers(pEffectInfo.members)
end
function SpineEffect:GetContentSize()
  if self.m_pContentNode then
    return self.m_pContentNode:GetContentSize()
  else
    return cc.size(1, 1)
  end
end
function SpineEffect:GetBoundingBox()
  if self.m_pContentNode then
    return self.m_pContentNode:getBoundingBox()
  else
    return self:getBoundingBox()
  end
end
return SpineEffect
