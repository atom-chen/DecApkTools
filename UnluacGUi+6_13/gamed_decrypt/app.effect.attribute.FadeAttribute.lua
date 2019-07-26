local AttributeBase = import(".AttributeBase")
local FadeAttribute = class("FadeAttribute", AttributeBase)
function FadeAttribute:ctor(pEffect, fNextAttributeTime, time, fromOpacity, toOpacity)
  FadeAttribute.super.ctor(self, td.AttributeType.Fade, pEffect, fNextAttributeTime)
  self.m_fTime = time
  self.m_iFromOpacity = fromOpacity
  self.m_iToOpacity = toOpacity
end
function FadeAttribute:Active()
  FadeAttribute.super.Active(self)
  local pNode = self.m_pEffect:GetContentNode()
  if pNode then
    pNode:setOpacity(self.m_iFromOpacity)
    pNode:runAction(cca.seq({
      cc.FadeTo:create(self.m_fTime, self.m_iToOpacity),
      cca.callFunc(function()
        self:SetOver()
      end)
    }))
  else
    self:SetOver()
  end
end
return FadeAttribute
