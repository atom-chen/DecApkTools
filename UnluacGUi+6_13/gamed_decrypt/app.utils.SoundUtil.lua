local SoundUtil = class("SoundUtil")
require("app.config.SoundConfig")
SoundUtil.instance = nil
function SoundUtil:ctor()
  self.m_bgmTag = cc.UserDefault:getInstance():getBoolForKey("music", true)
  self.m_effectTag = cc.UserDefault:getInstance():getBoolForKey("sound", true)
  self.m_bgmId = nil
  self.m_preloadList = {}
end
function SoundUtil:GetInstance()
  if SoundUtil.instance == nil then
    SoundUtil.instance = SoundUtil.new()
  end
  return SoundUtil.instance
end
function SoundUtil:Pause(bIsAll)
  audio.pauseAllSounds()
  if bIsAll then
    audio.pauseMusic()
  end
end
function SoundUtil:Resume(bIsAll)
  audio.resumeAllSounds()
  if bIsAll then
    audio.resumeMusic()
  end
end
function SoundUtil:Stop(bIsAll)
  audio.stopAllSounds()
  if bIsAll then
    audio.stopMusic()
  end
end
function SoundUtil:SwitchMusic(isOn)
  if self.m_bgmTag == isOn then
    return
  end
  self.m_bgmTag = isOn
  if not self.m_bgmTag then
    audio.stopMusic()
  else
    self:PlayMusic(self.m_bgmId, isLoop)
  end
  cc.UserDefault:getInstance():setBoolForKey("music", isOn)
end
function SoundUtil:SwitchSound(isOn)
  if self.m_effectTag == isOn then
    return
  end
  self.m_effectTag = isOn
  if not self.m_effectTag then
    audio.stopAllSounds()
  else
  end
  cc.UserDefault:getInstance():setBoolForKey("sound", isOn)
end
function SoundUtil:PreloadMusic(id)
  audio.preloadMusic(GetSoundFile(id))
end
function SoundUtil:PlayMusic(id, isLoop)
  self.m_bgmId = id
  if self.m_bgmTag and id then
    if nil == isLoop then
      isLoop = true
    end
    audio.playMusic(GetSoundFile(id), isLoop)
  end
end
function SoundUtil:StopMusic()
  audio.stopMusic(true)
end
function SoundUtil:PreloadSound(id)
  if not self.m_preloadList[id] then
    audio.preloadSound(GetSoundFile(id))
    self.m_preloadList[id] = 1
  end
end
function SoundUtil:UnloadSound(id)
  if self.m_preloadList[id] then
    audio.unloadSound(GetSoundFile(id))
    self.m_preloadList[id] = nil
  end
end
function SoundUtil:UnloadAllSound()
  for id, var in pairs(self.m_preloadList) do
    audio.unloadSound(GetSoundFile(id))
  end
  self.m_preloadList = {}
end
function SoundUtil:PlaySound(id, isLoop)
  if self.m_effectTag and id then
    if nil == isLoop then
      isLoop = false
    end
    if isLoop then
      self:PreloadSound(id)
    end
    return audio.playSound(GetSoundFile(id), isLoop)
  end
end
function SoundUtil:StopSound(handle)
  if handle then
    audio.stopSound(handle)
  end
end
function SoundUtil:StopAllSounds()
  audio.stopAllSounds()
end
G_SoundUtil = G_SoundUtil or SoundUtil:GetInstance()
