local NormalSkill = import(".NormalSkill")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local SnipeNormalSkill = class("SnipeNormalSkill", NormalSkill)
function SnipeNormalSkill:ctor(pActor, id, pData)
  SnipeNormalSkill.super.ctor(self, pActor, id, pData)
end
function SnipeNormalSkill:Update(dt)
  SnipeNormalSkill.super.Update(self, dt)
end
function SnipeNormalSkill:Execute(endCallback)
  self.m_fStartTime = 0
  self.m_pActor:UpdateEnemyAzimuth()
  local aniName = "fire_0" .. self.m_pActor.m_pEnemyAzimuth
  self.m_pActor:PlayAnimation(aniName, false, function()
    self:ExecuteOver()
    endCallback()
  end, sp.EventType.ANIMATION_COMPLETE)
  if self.m_pActor.m_attackSound then
    G_SoundUtil:PlaySound(self.m_pActor.m_attackSound, false)
  end
end
return SnipeNormalSkill
