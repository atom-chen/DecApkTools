local AttributeBase = import(".AttributeBase")
local VisibleAttribute = class("VisibleAttribute", AttributeBase)
function VisibleAttribute:ctor(pEffect, fNextAttributeTime, visible)
  VisibleAttribute.super.ctor(self, td.AttributeType.Visible, pEffect, fNextAttributeTime)
  self.m_bVisible = visible
end
function VisibleAttribute:Active()
  VisibleAttribute.super.Active(self)
  if self.m_pEffect:GetType() == td.EffectType.Group then
    for key, var in ipairs(self.m_pEffect.m_vMembers) do
      var.effect:setVisible(self.m_bVisible)
    end
  else
    self.m_pEffect:setVisible(self.m_bVisible)
  end
  self:SetOver()
end
function VisibleAttribute:SetOver()
  self.m_bExecuteNextAttribute = true
  self.m_bOver = true
end
return VisibleAttribute
