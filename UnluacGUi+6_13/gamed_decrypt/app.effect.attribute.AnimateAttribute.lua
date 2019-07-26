local AttributeBase = import(".AttributeBase")
local AnimateAttribute = class("AnimateAttribute", AttributeBase)
function AnimateAttribute:ctor(pEffect, fNextAttributeTime, animation, bLoop, random, cnt, frames)
  AnimateAttribute.super.ctor(self, td.AttributeType.Animate, pEffect, fNextAttributeTime)
  self.m_animation = animation
  self.m_bIsLoop = bLoop
  self.m_random = false
  if true == random then
    self.m_random = true
  end
  self.m_frameCnt = frames or 1
  self.m_cnt = cnt or 1
  self.m_tmpCnt = 0
end
function AnimateAttribute:Active()
  AnimateAttribute.super.Active(self)
  local skeleton = self.m_pEffect:GetContentNode()
  if self.m_pEffect:GetType() == td.EffectType.Spine and skeleton then
    if self.m_bIsLoop then
      self:SetOver()
      if self.m_random then
        skeleton:registerSpineEventHandler(function(event)
          if event.animation == self.m_animation then
            local delay = math.random(2, 5)
            self.m_pEffect:performWithDelay(function()
              skeleton:PlayAni(self.m_animation, false)
            end, delay)
          end
        end, sp.EventType.ANIMATION_COMPLETE)
        skeleton:PlayAni(self.m_animation, false)
      else
        skeleton:PlayAni(self.m_animation, true)
      end
    else
      skeleton:registerSpineEventHandler(function(event)
        if event.animation == self.m_animation then
          self.m_tmpCnt = self.m_tmpCnt + 1
          if self.m_cnt <= self.m_tmpCnt then
            self:SetOver()
          else
            skeleton:PlayAni(self.m_animation, false)
          end
        end
      end, sp.EventType.ANIMATION_COMPLETE)
      skeleton:PlayAni(self.m_animation, false)
    end
  elseif self.m_pEffect:GetType() == td.EffectType.Frames then
    local frames = display.newFrames(self.m_animation .. "%04d.png", 1, self.m_frameCnt)
    local animation = display.newAnimation(frames, 0.04)
    if self.m_bIsLoop then
      skeleton:playAnimationForever(animation)
      self:SetOver()
    else
      skeleton:playAnimationOnce(animation, true, function()
        self:SetOver()
      end)
    end
  end
end
return AnimateAttribute
