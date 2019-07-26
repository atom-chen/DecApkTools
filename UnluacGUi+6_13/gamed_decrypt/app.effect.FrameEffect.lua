local EffectBase = import(".EffectBase")
local FrameEffect = class("FrameEffect", EffectBase)
function FrameEffect:ctor(pActorBase, pTargetActor, pEffectInfo)
  FrameEffect.super.ctor(self, pActorBase, pTargetActor, pEffectInfo)
  cc.SpriteFrameCache:getInstance():addSpriteFrames(pEffectInfo.file .. ".plist")
  self.m_pContentNode = display.newSprite("#" .. pEffectInfo.file .. "0001" .. td.PNG_Suffix)
  if self.m_pContentNode then
    self.m_pContentNode:setPosition(0, 0)
    self:addChild(self.m_pContentNode, 1)
  end
  self:AddMembers(pEffectInfo.members)
end
function FrameEffect:GetContentSize()
  if self.m_pContentNode then
    return self.m_pContentNode:getContentSize()
  else
    return cc.size(1, 1)
  end
end
function FrameEffect:GetBoundingBox()
  if self.m_pContentNode then
    return self.m_pContentNode:getBoundingBox()
  else
    return self:getBoundingBox()
  end
end
return FrameEffect
