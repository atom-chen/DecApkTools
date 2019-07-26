local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local LifeDrawing = class("LifeDrawing", SkillBase)
LifeDrawing.MaxTime = 3
function LifeDrawing:ctor(pActor, id, pData)
  LifeDrawing.super.ctor(self, pActor, id, pData)
  self.m_isSenior = id == 3037 and true or false
  self.m_bIsExecuting = false
  self.m_iTimeInterval = 0
  self.m_hEndCallback = nil
  self.m_changeHP = 0
  self.m_pTarget = nil
  self.m_vEffects = {}
  self.m_soundHandle = nil
end
function LifeDrawing:Update(dt)
  LifeDrawing.super.Update(self, dt)
  if self.m_bIsExecuting then
    if self.m_pActor:IsDead() then
      self:ExecuteOver()
      return
    end
    local enemy = self.m_pActor:GetEnemy()
    if not self.m_pTarget or self.m_pTarget ~= enemy or not self.m_pTarget:IsCanAttacked() then
      self:ExecuteOver()
      return
    end
    self.m_iTimeInterval = self.m_iTimeInterval + dt
    if self.m_iTimeInterval >= LifeDrawing.MaxTime then
      self:ExecuteOver()
      return
    end
    local tmpHp = self.m_changeHP * dt / LifeDrawing.MaxTime
    self.m_pTarget:ChangeHp(-tmpHp)
    self.m_pActor:ChangeHp(tmpHp)
  end
end
function LifeDrawing:Execute(endCallback)
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  if self:IsTriggered() then
    self.m_fStartTime = 0
    self.m_pActor:PlayAnimation(pData.skill_name, true)
    local pMap = require("app.GameDataManager"):GetInstance():GetGameMap()
    pMap:performWithDelay(function()
      if not self.m_pActor:IsDead() then
        self.m_bIsExecuting = true
        self:Draw(self.m_pTarget, self.m_pActor)
      end
    end, 0.3)
    self.m_changeHP = td.AttackFormula(td.CreateActorParams(self.m_pActor), self.m_pTarget, self.m_iSkillRatio, self.m_iSkillFixed)
    self.m_hEndCallback = endCallback
    self.m_soundHandle = G_SoundUtil:PlaySound(305, true)
    return true
  else
    endCallback()
    return false
  end
end
function LifeDrawing:ExecuteOver()
  LifeDrawing.super.ExecuteOver(self)
  if self.m_hEndCallback then
    self.m_hEndCallback()
    self.m_hEndCallback = nil
  end
  for i, effect in ipairs(self.m_vEffects) do
    effect:SetRemove()
  end
  self.m_vEffects = {}
  self.m_bIsExecuting = false
  self.m_pTarget = nil
  self.m_changeHP = 0
  self.m_iTimeInterval = 0
  if self.m_soundHandle then
    G_SoundUtil:StopSound(self.m_soundHandle)
    self.m_soundHandle = nil
  end
end
function LifeDrawing:Draw(lastActor, target)
  if lastActor and lastActor ~= target then
    local pMap = require("app.GameDataManager"):GetInstance():GetGameMap()
    local linkEffect = EffectManager:GetInstance():CreateEffect(self.m_atkEffect, target, lastActor)
    linkEffect:AddToMap(pMap)
    table.insert(self.m_vEffects, linkEffect)
  end
  local effect1 = EffectManager:GetInstance():CreateEffect(self.m_hurtEffect)
  effect1:AddToActor(target)
  table.insert(self.m_vEffects, effect1)
  local effect2 = EffectManager:GetInstance():CreateEffect(self.m_hurtEffect)
  effect2:AddToActor(lastActor)
  table.insert(self.m_vEffects, effect2)
end
function LifeDrawing:IsTriggered()
  local supCondition = LifeDrawing.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local enemy = self.m_pActor:GetEnemy()
  if not enemy or not enemy:IsCanAttacked() then
    return false
  end
  if enemy:GetType() ~= td.ActorType.Hero and enemy:GetType() ~= td.ActorType.Soldier and enemy:GetType() ~= td.ActorType.Monster then
    return false
  end
  self.m_pTarget = enemy
  return true
end
return LifeDrawing
