local AttributeBase = import(".AttributeBase")
local AnimateOtherAttribute = class("AnimateOtherAttribute", AttributeBase)
function AnimateOtherAttribute:ctor(pEffect, fNextAttributeTime, data)
  AnimateOtherAttribute.super.ctor(self, td.AttributeType.Animate, pEffect, fNextAttributeTime)
  self.m_animation = data.animation
  self.m_bIsLoop = data.loop
  self.m_random = false
  if true == data.random then
    self.m_random = true
  end
  self.m_cnt = data.cnt or 1
  self.m_tmpCnt = 0
  self.m_effectId = data.effectId
end
function AnimateOtherAttribute:Active()
  AnimateOtherAttribute.super.Active(self)
  local pEffect = require("app.effect.EffectManager").GetInstance():GetEffectById(self.m_effectId)
  if nil == pEffect then
    self:SetOver()
    return
  end
  local skeleton = pEffect:GetContentNode()
  if nil == skeleton then
    self:SetOver()
    return
  end
  if self.m_bIsLoop then
    self:SetOver()
    if self.m_random then
      skeleton:registerSpineEventHandler(function(event)
        if event.animation == self.m_animation then
          local delay = math.random(2, 5)
          pEffect:performWithDelay(function()
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
end
return AnimateOtherAttribute
