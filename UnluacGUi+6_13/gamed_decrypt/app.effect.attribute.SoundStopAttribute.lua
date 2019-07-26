local AttributeBase = import(".AttributeBase")
local BuffManager = require("app.buff.BuffManager")
local SoundStopAttribute = class("SoundStopAttribute", AttributeBase)
function SoundStopAttribute:ctor(pEffect, fNextAttributeTime)
  SoundStopAttribute.super.ctor(self, td.AttributeType.Attack, pEffect, fNextAttributeTime)
end
function SoundStopAttribute:Active()
  SoundStopAttribute.super.Active(self)
  if self.m_pEffect.m_pSound then
    G_SoundUtil:StopSound(self.m_pEffect.m_pSound)
    self.m_pEffect.m_pSound = nil
  end
  self:SetOver()
end
return SoundStopAttribute
