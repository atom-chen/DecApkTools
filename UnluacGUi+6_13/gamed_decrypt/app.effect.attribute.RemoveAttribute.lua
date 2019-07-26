local AttributeBase = import(".AttributeBase")
local RemoveAttribute = class("RemoveAttribute", AttributeBase)
function RemoveAttribute:ctor(pEffect, fNextAttributeTime, data)
  RemoveAttribute.super.ctor(self, td.AttributeType.RemoveAttri, pEffect, fNextAttributeTime)
  self.m_attributeType = data.attributeType
end
function RemoveAttribute:Active()
  RemoveAttribute.super.Active(self)
  if self.m_pEffect then
    self.m_pEffect:RemoveAttributeByType(self.m_attributeType)
  end
end
function RemoveAttribute:Update(dt)
  RemoveAttribute.super.Update(self, dt)
  if self.m_bExecuteNextAttribute then
    self:SetOver()
  end
end
return RemoveAttribute
