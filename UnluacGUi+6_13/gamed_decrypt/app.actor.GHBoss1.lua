local Monster = require("app.actor.Monster")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local BuffManager = require("app.buff.BuffManager")
local EffectManager = require("app.effect.EffectManager")
local GHBoss1 = class("GHBoss1", Monster)
GHBoss1.BossState = {
  Saber = 1,
  Archor = 2,
  Caster = 3
}
function GHBoss1:ctor(eType, pData)
  GHBoss1.super.ctor(self, eType, pData)
  self.m_bossState = GHBoss1.BossState.Saber
end
function GHBoss1:GetBossState()
  return self.m_bossState
end
function GHBoss1:Transform(endCb)
  local state = self.m_bossState + 1
  if state > 3 then
    state = 1
  end
  self:CreateAnimation("Spine/renwu/GHboss_004")
  self:PlayAnimation("animation", true)
  self:performWithDelay(function()
    if state == GHBoss1.BossState.Saber then
      self:CreateAnimation("Spine/renwu/GHboss_001")
      self:ResetSkill({
        3121,
        3115,
        3116,
        1
      })
      self.m_iCareerType = td.CareerType.Saber
    elseif state == GHBoss1.BossState.Archor then
      self:CreateAnimation("Spine/renwu/GHboss_002")
      self:ResetSkill({
        3121,
        3117,
        22,
        3118
      })
      self.m_iCareerType = td.CareerType.Archer
    else
      self:CreateAnimation("Spine/renwu/GHboss_003")
      self:ResetSkill({
        3121,
        3119,
        77,
        3120
      })
      self.m_iCareerType = td.CareerType.Caster
    end
    self:SetDirType(self:GetDirType())
    self.m_bossState = state
    self:PlayAnimation("bianxing_02", false, endCb, sp.EventType.ANIMATION_COMPLETE)
  end, 2)
end
function GHBoss1:ResetSkill(skills)
  self.m_pSkillManager:EmptySkill()
  for i, v in ipairs(skills) do
    if v ~= 0 then
      self.m_pSkillManager:AddSkill(v)
    end
  end
  self.m_pSkillManager:OnEnter()
end
function GHBoss1:ChangeHp(iHp, isIndirect, attacker)
  if isIndirect == nil then
    isIndirect = false
  end
  if self:IsDead() then
    return true, 0
  end
  iHp = self:_HandleHpWithBuffs(iHp, isIndirect, attacker)
  if iHp == 0 then
    return false, 0
  end
  local oriHp = self.m_iCurHp
  local nextHp = cc.clampf(self.m_iCurHp + iHp, 0, self:GetMaxHp())
  td.dispatchEvent(td.GUILD_BOSS_HP, nextHp - oriHp)
  return bIsDead, iHp
end
return GHBoss1
