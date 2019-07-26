local Monster = require("app.actor.Monster")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local MummyBoss = class("MummyBoss", Monster)
MummyBoss.DIE_DISTANCE = 200
function MummyBoss:ctor(eType, pData)
  MummyBoss.super.ctor(self, eType, pData)
  self.m_timeInvl = 0
  self.m_pCompanion = nil
  self.m_pDeadEffect = nil
  self.m_bIsRealDead = false
  self.m_bIsFakingDead = false
  local enemyVec = ActorManager:GetInstance():GetEnemyVec()
  for key, var in pairs(enemyVec) do
    if var.m_pData.monster_type == td.MonsterType.BOSS and self:MakeCompanions(var) then
      break
    end
  end
end
function MummyBoss:Update(dt)
  MummyBoss.super.Update(self, dt)
end
function MummyBoss:MakeCompanions(p)
  if p and p ~= self and p ~= self.m_pCompanion then
    self.m_pCompanion = p
    self.m_pCompanion:MakeCompanions(self)
    return true
  end
  return false
end
function MummyBoss:GetCompanion()
  return self.m_pCompanion
end
function MummyBoss:Reborn()
  self.m_pHpBar:setVisible(true)
  self:SetCurHp(self:GetMaxHp())
  self.m_pStateManager:SetPause(false)
  self.m_pStateManager:ChangeState(td.StateType.Idle)
  td.dispatchEvent(td.UPDATE_BOSS_HP, self:GetCurHp() / self:GetMaxHp() * 100)
  if self.m_pDeadEffect then
    self.m_pDeadEffect:removeFromParent()
    self.m_pDeadEffect = nil
  end
  self.m_bIsFakingDead = false
  local BattleWord = require("app.widgets.BattleWord")
  local blockWord = BattleWord.new("UI/skill_words/wenzi_tongshenggongsi")
  blockWord:AddToActor(self)
end
function MummyBoss:Combo()
  self.m_comboEffect1 = SkeletonUnit:create("Spine/skill/EFT_shuangziSHOU_01")
  self.m_comboEffect1:PlayAni("animation", true)
  local boneNode = self:FindBoneNode("bone_shou01")
  boneNode:addChild(self.m_comboEffect1)
  self.m_comboEffect2 = SkeletonUnit:create("Spine/skill/EFT_shuangziSHOU_01")
  self.m_comboEffect2:PlayAni("animation", true)
  local boneNode2 = self:FindBoneNode("bone_shou02")
  boneNode2:addChild(self.m_comboEffect2)
  self:setScale(self:getScale() * 1.2)
end
function MummyBoss:Decompose()
  self.m_comboEffect1:removeFromParent()
  self.m_comboEffect1 = nil
  self.m_comboEffect2:removeFromParent()
  self.m_comboEffect2 = nil
  self:setScale(self:getScale() / 1.2)
end
function MummyBoss:IsCanAttacked()
  return self.m_iCurHp > 0 and not self:IsPeace() and not self:IsHiding()
end
function MummyBoss:IsDead()
  return self.m_bIsRealDead
end
function MummyBoss:ChangeHp(iHp, isIndirect, attacker)
  local bIsDead = MummyBoss.super.ChangeHp(self, iHp, isIndirect, attacker)
  if iHp <= 0 and self.m_pCompanion and not isIndirect then
    self.m_pCompanion:ChangeHp(iHp, true)
  end
  return bIsDead
end
function MummyBoss:OnDead()
  local distance = cc.pGetDistance(cc.p(self:getPosition()), cc.p(self.m_pCompanion:getPosition()))
  if distance > MummyBoss.DIE_DISTANCE then
    if self.m_bIsFakingDead then
      return
    end
    self.m_pStateManager:ChangeState(td.StateType.Idle)
    self.m_pStateManager:SetPause(true)
    self:PlayAnimation("dead", false, function()
      self:PlayAnimation("dead01", true)
    end, sp.EventType.ANIMATION_COMPLETE)
    self:runAction(cca.seq({
      cca.delay(1),
      cca.cb(function()
        local EffectManager = require("app.effect.EffectManager")
        self.m_pDeadEffect = EffectManager:GetInstance():CreateEffect(1011)
        self.m_pDeadEffect:AddToActor(self)
      end),
      cca.delay(10),
      cca.cb(function()
        self:Reborn()
      end)
    }))
    self.m_bIsFakingDead = true
  else
    self.m_bIsRealDead = true
    MummyBoss.super.OnDead(self)
  end
end
return MummyBoss
