local TriggerBase = import(".TriggerBase")
local PlayerSoundTrigger = class("PlayerSoundTrigger", TriggerBase)
function PlayerSoundTrigger:ctor(iID, iType, bLoop, conditionType, data)
  PlayerSoundTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_sound = data.sound
end
function PlayerSoundTrigger:Active()
  PlayerSoundTrigger.super.Active(self)
  G_SoundUtil:PlaySound(self.m_sound, false)
end
return PlayerSoundTrigger
