local EffectBase = import(".EffectBase")
local ImageEffect = class("ImageEffect", EffectBase)
function ImageEffect:ctor(pActorBase, pTargetActor, pEffectInfo)
  ImageEffect.super.ctor(self, pActorBase, pTargetActor, pEffectInfo)
  self.m_pContentNode = display.newSprite(pEffectInfo.file .. td.PNG_Suffix)
  if self.m_pContentNode then
    self.m_pContentNode:setPosition(0, 0)
    if pEffectInfo.anchor then
      self.m_pContentNode:setAnchorPoint(pEffectInfo.anchor)
    end
    self:addChild(self.m_pContentNode, 1)
  end
  self:AddMembers(pEffectInfo.members)
end
function ImageEffect:GetContentSize()
  if self.m_pContentNode then
    return self.m_pContentNode:getContentSize()
  else
    return cc.size(1, 1)
  end
end
function ImageEffect:GetBoundingBox()
  if self.m_pContentNode then
    return self.m_pContentNode:getBoundingBox()
  else
    return self:getBoundingBox()
  end
end
return ImageEffect
