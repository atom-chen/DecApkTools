local SkillBase = require("app.actor.skill.SkillBase")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local NormalSkill = class("NormalSkill", SkillBase)
function NormalSkill:ctor(pActor, id, pData)
  NormalSkill.super.ctor(self, pActor, id, pData)
  self.m_iCurHit = 0
  self.m_iJudgeHitTime = 1
end
function NormalSkill:Update(dt)
  NormalSkill.super.Update(self, dt)
end
function NormalSkill:Execute(endCallback)
  NormalSkill.super.Execute(self, endCallback)
end
function NormalSkill:Hit()
  NormalSkill.super.Hit(self)
  if self.m_pActor.m_attackSound then
    G_SoundUtil:PlaySound(self.m_pActor.m_attackSound, false)
  end
end
function NormalSkill:Shoot()
  NormalSkill.super.Shoot(self)
  if self.m_pActor.m_attackSound then
    G_SoundUtil:PlaySound(self.m_pActor.m_attackSound, false)
  end
end
function NormalSkill:IsMustHit()
  return false
end
function NormalSkill:DidHit(pActor)
  NormalSkill.super.DidHit(self, pActor)
  if pActor then
    self.m_iCurHit = self.m_iCurHit + 1
    if self.m_iCurHit < self.m_iJudgeHitTime then
      return
    else
      self.m_iCurHit = 0
    end
    local buffs = BuffManager:GetInstance():GetBuffByTag(self.m_iActorTag)
    if buffs and buffs[td.BuffType.AttackCauseSkill] and 0 < #buffs[td.BuffType.AttackCauseSkill] then
      for i, buff in ipairs(buffs[td.BuffType.AttackCauseSkill]) do
        if buff:IsTriggered() then
          local triSkill = self.m_pActor.m_pSkillManager:CreateSkill(buff:GetTriggerSkillId())
          if triSkill then
            triSkill:SetSkillRatio(self:GetSkillRatio())
            triSkill:Execute()
          end
          buff:OnWork()
        end
      end
    end
    if pActor:IsCanBuffed() and buffs[td.BuffType.AttackCauseBuff] and 0 < #buffs[td.BuffType.AttackCauseBuff] and not pActor:IsDead() then
      for i, buff in ipairs(buffs[td.BuffType.AttackCauseBuff]) do
        if buff:IsTriggered() then
          for j, var in ipairs(buff:GetTriggerBuffId()) do
            BuffManager:GetInstance():AddBuff(pActor, var)
          end
          buff:OnWork()
        end
      end
    end
  end
end
return NormalSkill
