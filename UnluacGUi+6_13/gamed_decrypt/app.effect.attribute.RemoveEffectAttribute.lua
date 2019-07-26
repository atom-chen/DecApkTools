local AttributeBase = import(".AttributeBase")
local RemoveEffectAttribute = class("RemoveEffectAttribute", AttributeBase)
function RemoveEffectAttribute:ctor(pEffect, fNextAttributeTime, id)
  RemoveEffectAttribute.super.ctor(self, td.AttributeType.RemoveEffect, pEffect, fNextAttributeTime)
  self.m_RemoveId = id
end
function RemoveEffectAttribute:Active()
  RemoveEffectAttribute.super.Active(self)
  local EffectManager = require("app.effect.EffectManager")
  if self.m_RemoveId == -1 then
    EffectManager:RemoveEffect(self.m_pEffect)
  else
    EffectManager:RemoveEffectForID(self.m_RemoveId)
  end
  self:SetOver()
end
return RemoveEffectAttribute
