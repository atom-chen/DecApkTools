local NormalSkill = import(".NormalSkill")
local SkillInfoManager = require("app.info.SkillInfoManager")
local ActorManager = require("app.actor.ActorManager")
local MummyNormalSkill = class("MummyNormalSkill", NormalSkill)
function MummyNormalSkill:ctor(pActor, id, pData)
  MummyNormalSkill.super.ctor(self, pActor, id, pData)
  self.m_odds = 20
end
function MummyNormalSkill:Execute(endCallback)
  self.m_fStartTime = 0
  local animations = string.split(self.m_pData.skill_name, "#")
  local aniName
  local rand = math.random(100)
  if rand <= self.m_odds then
    aniName = animations[2]
  else
    aniName = animations[1]
  end
  self.m_pActor:PlayAnimation(aniName, false, function()
    self:ExecuteOver()
    endCallback()
  end, sp.EventType.ANIMATION_COMPLETE)
  if self.m_pActor.m_attackSound then
    G_SoundUtil:PlaySound(self.m_pActor.m_attackSound, false)
  end
end
return MummyNormalSkill
