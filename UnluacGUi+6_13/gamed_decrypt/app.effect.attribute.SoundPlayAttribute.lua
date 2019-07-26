local AttributeBase = import(".AttributeBase")
local BuffManager = require("app.buff.BuffManager")
local SoundAttribute = class("SoundAttribute", AttributeBase)
function SoundAttribute:ctor(pEffect, fNextAttributeTime, id, bLoop)
  SoundAttribute.super.ctor(self, td.AttributeType.Attack, pEffect, fNextAttributeTime)
  self.m_iSoundId = id
  self.m_bLoop = bLoop
end
function SoundAttribute:Active()
  SoundAttribute.super.Active(self)
  local soundhandler = G_SoundUtil:PlaySound(self.m_iSoundId, self.m_bLoop)
  if self.m_bLoop then
    self.m_pEffect.m_pSound = soundhandler
  end
  self:SetOver()
end
return SoundAttribute
