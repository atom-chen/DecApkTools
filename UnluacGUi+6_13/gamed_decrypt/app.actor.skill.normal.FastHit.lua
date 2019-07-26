local NormalSkill = import(".NormalSkill")
local SkillInfoManager = require("app.info.SkillInfoManager")
local BuffManager = require("app.buff.BuffManager")
local ActorManager = require("app.actor.ActorManager")
local FastHit = class("FastHit", NormalSkill)
function FastHit:ctor(pActor, id, pData)
  FastHit.super.ctor(self, pActor, id, pData)
  local t = string.split(pData.custom_data, "#")
  self.m_odds = tonumber(t[1])
  if t[2] then
    self.m_specialBuff = tonumber(t[2])
  end
end
function FastHit:Execute(endCallback)
  self.m_fStartTime = 0
  local animations = string.split(self.m_pData.skill_name, "#")
  local aniName
  local rand = math.random(100)
  if rand <= self.m_odds then
    aniName = animations[1]
    G_SoundUtil:PlaySound(202, false)
    if self.m_specialBuff then
      BuffManager:GetInstance():AddBuff(self.m_pActor, self.m_specialBuff)
    end
    self:ShowSkillName()
  else
    aniName = animations[math.random(2, 3)]
    if self.m_pActor.m_attackSound then
      G_SoundUtil:PlaySound(self.m_pActor.m_attackSound, false)
    end
  end
  self.m_pActor:PlayAnimation(aniName, false, function()
    self:ExecuteOver()
    endCallback()
  end, sp.EventType.ANIMATION_COMPLETE)
end
return FastHit
