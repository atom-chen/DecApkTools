local AttributeBase = import(".AttributeBase")
local AnimateSwitchAttribute = class("AnimateSwitchAttribute", AttributeBase)
function AnimateSwitchAttribute:ctor(pEffect, fNextAttributeTime, data)
  AnimateSwitchAttribute.super.ctor(self, td.AttributeType.AnimSwitch, pEffect, fNextAttributeTime)
  self.m_lastAnim = nil
  self.m_maxRate = 0
  self.m_animations = data.animations
  for _, value in pairs(self.m_animations) do
    self.m_maxRate = self.m_maxRate + value[2]
  end
end
function AnimateSwitchAttribute:Active()
  AnimateSwitchAttribute.super.Active(self)
  local skeleton = self.m_pEffect:GetContentNode()
  skeleton:registerSpineEventHandler(function(event)
    if event.animation == self.m_lastAnim then
      skeleton:performWithDelay(function()
        self.m_lastAnim = self:NextAnim()
        skeleton:PlayAni(self.m_lastAnim, false)
      end, 0.016666666666666666)
    end
  end, sp.EventType.ANIMATION_COMPLETE)
  self.m_lastAnim = self:NextAnim()
  skeleton:PlayAni(self.m_lastAnim, false)
end
function AnimateSwitchAttribute:NextAnim()
  local rate = math.random(0, self.m_maxRate)
  local tmpRate = 0
  for _, value in pairs(self.m_animations) do
    tmpRate = tmpRate + value[2]
    if rate <= tmpRate then
      return value[1]
    end
  end
  return nil
end
function AnimateSwitchAttribute:Update(dt)
  AnimateSwitchAttribute.super.Update(self, dt)
  if self.m_bExecuteNextAttribute then
    self:SetOver()
  end
end
return AnimateSwitchAttribute
