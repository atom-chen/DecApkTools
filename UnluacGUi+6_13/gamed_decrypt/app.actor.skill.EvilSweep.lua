local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local VampireBoss = require("app.actor.VampireBoss")
local EvilSweep = class("EvilSweep", SkillBase)
EvilSweep.HitbackDis = 200
function EvilSweep:ctor(pActor, id, pData)
  EvilSweep.super.ctor(self, pActor, id, pData)
end
function EvilSweep:Update(dt)
  EvilSweep.super.Update(self, dt)
end
function EvilSweep:Execute(endCallback)
  EvilSweep.super.Execute(self, endCallback)
end
function EvilSweep:IsTriggered()
  local supCondition = EvilSweep.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  if self.m_pActor:GetBossState() ~= VampireBoss.BossState.Normal2 then
    return false
  end
  local vec = {}
  if self.m_pActor:GetGroupType() == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetEnemyVec()
  elseif self.m_pActor:GetGroupType() == td.GroupType.Enemy then
    vec = ActorManager:GetInstance():GetSelfVec()
  end
  local selfPos = cc.p(self.m_pActor:getPosition())
  local count = 0
  for key, v in pairs(vec) do
    if v:IsCanAttacked() then
      local actorPos = cc.p(v:getPosition())
      if cc.pDistanceSQ(actorPos, selfPos) <= self.m_iAtkRangeSQ then
        count = count + 1
        if count >= 3 then
          return true
        end
      end
    end
  end
  self.m_iCheckTime = 0
  return false
end
function EvilSweep:DidHit(pActor)
  EvilSweep.super.DidHit(self, pActor)
  if pActor and pActor:IsCanBeMoved() then
    self:HitBack(pActor, EvilSweep.HitbackDis)
  end
end
return EvilSweep
