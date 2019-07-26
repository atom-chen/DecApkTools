local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local LifeDrawingSuper = class("LifeDrawingSuper", SkillBase)
LifeDrawingSuper.MaxTime = 3
function LifeDrawingSuper:ctor(pActor, id, pData)
  LifeDrawingSuper.super.ctor(self, pActor, id, pData)
  self.m_bIsExecuting = false
  self.m_iTimeInterval = 0
  self.m_hEndCallback = nil
  self.m_changeHP = 0
  self.m_vTags = {}
  self.m_vChangeHp = {}
  self.m_vEffects = {}
  self.m_soundHandle = nil
end
function LifeDrawingSuper:Update(dt)
  LifeDrawingSuper.super.Update(self, dt)
  if self.m_bIsExecuting then
    if self.m_pActor:IsDead() then
      self:ExecuteOver()
      return
    end
    local bOver = true
    local count = #self.m_vTags
    for i = count, 1, -1 do
      local tag = self.m_vTags[i]
      local target = ActorManager:GetInstance():FindActorByTag(tag)
      if not target or target:IsDead() then
        for i, effect in ipairs(self.m_vEffects[tag]) do
          effect:SetRemove()
        end
        self.m_vEffects[tag] = nil
        table.remove(self.m_vTags, i)
      else
        bOver = false
        local tmpHp = self.m_vChangeHp[tag] * dt / LifeDrawingSuper.MaxTime
        target:ChangeHp(-tmpHp)
      end
    end
    if bOver then
      self:ExecuteOver()
      return
    end
    self.m_iTimeInterval = self.m_iTimeInterval + dt
    if self.m_iTimeInterval >= LifeDrawingSuper.MaxTime then
      self:ExecuteOver()
      return
    end
  end
end
function LifeDrawingSuper:Execute(endCallback)
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  self.m_vTags = self:FindTargets()
  if #self.m_vTags > 0 then
    self.m_fStartTime = 0
    self.m_pActor:PlayAnimation(pData.skill_name, true)
    local pMap = require("app.GameDataManager"):GetInstance():GetGameMap()
    pMap:performWithDelay(function()
      if not self.m_pActor:IsDead() then
        self.m_bIsExecuting = true
        for i, tag in ipairs(self.m_vTags) do
          local pTarget = ActorManager:GetInstance():FindActorByTag(tag)
          self:Draw(pTarget)
          self.m_vChangeHp[tag] = td.AttackFormula(td.CreateActorParams(self.m_pActor), pTarget, self.m_iSkillRatio, self.m_iSkillFixed)
        end
      end
    end, 0.3)
    self.m_hEndCallback = endCallback
    self.m_soundHandle = G_SoundUtil:PlaySound(305, true)
    return true
  else
    endCallback()
    return false
  end
end
function LifeDrawingSuper:ExecuteOver()
  LifeDrawingSuper.super.ExecuteOver(self)
  if self.m_hEndCallback then
    self.m_hEndCallback()
    self.m_hEndCallback = nil
  end
  for key, effects in pairs(self.m_vEffects) do
    for i, effect in ipairs(effects) do
      effect:SetRemove()
    end
  end
  self.m_vEffects = {}
  self.m_bIsExecuting = false
  self.m_vChangeHp = {}
  self.m_iTimeInterval = 0
  if self.m_soundHandle then
    G_SoundUtil:StopSound(self.m_soundHandle)
    self.m_soundHandle = nil
  end
end
function LifeDrawingSuper:Draw(target)
  local tag = target:getTag()
  if target and self.m_pActor ~= target then
    self.m_vEffects[tag] = self.m_vEffects[tag] or {}
    local pMap = require("app.GameDataManager"):GetInstance():GetGameMap()
    local linkEffect = EffectManager:GetInstance():CreateEffect(self.m_atkEffect, target, self.m_pActor)
    linkEffect:AddToMap(pMap)
    table.insert(self.m_vEffects[tag], linkEffect)
    local effect1 = EffectManager:GetInstance():CreateEffect(self.m_hurtEffect)
    effect1:AddToActor(target)
    table.insert(self.m_vEffects[tag], effect1)
  end
end
function LifeDrawingSuper:IsTriggered()
  local supCondition = LifeDrawingSuper.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local targets = self:FindTargets()
  return #targets > 0
end
function LifeDrawingSuper:FindTargets()
  local targets = {}
  local actorMng = ActorManager:GetInstance()
  local vec = self.m_pActor:GetGroupType() == td.GroupType.Self and actorMng:GetEnemyVec() or actorMng:GetSelfVec()
  local selfPos = cc.p(self.m_pActor:getPosition())
  for key, v in pairs(vec) do
    if v:IsCanAttacked() and v:GetCareerType() == td.CareerType.Saber then
      local actorPos = cc.p(v:getPosition())
      if cc.pDistanceSQ(actorPos, selfPos) <= self.m_iAtkRangeSQ then
        table.insert(targets, v:getTag())
      end
    end
  end
  return targets
end
return LifeDrawingSuper
