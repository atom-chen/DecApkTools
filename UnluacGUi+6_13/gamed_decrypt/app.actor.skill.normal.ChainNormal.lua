local NormalSkill = import(".NormalSkill")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local ChainNormal = class("ChainNormal", NormalSkill)
function ChainNormal:ctor(pActor, id, pData)
  ChainNormal.super.ctor(self, pActor, id, pData)
  self.m_iChainCount = 3
end
function ChainNormal:Execute()
  self.m_fStartTime = 0
  local targets = self:FindTargets()
  for i, var in ipairs(targets) do
    if i == 1 then
      self:Shock(nil, targets[1], self.m_iSkillRatio, self.m_iSkillFixed, 0)
    else
      self:Shock(targets[i - 1], targets[i], self.m_iSkillRatio * (1.2 - 0.2 * i), self.m_iSkillFixed * (1.2 - 0.2 * i), 0.2 * (i - 1))
    end
  end
end
function ChainNormal:Shock(lastActor, target, ratio, fixed, delay)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  pMap:performWithDelay(function()
    if td.HurtEnemy(td.CreateActorParams(self.m_pActor), target, ratio, fixed, self:IsMustHit()) then
      self:DidHit(target)
    end
    if lastActor and lastActor ~= target then
      local linkEffect = EffectManager:GetInstance():CreateEffect(112, lastActor, target)
      linkEffect:AddToMap(pMap)
    end
    local effect = EffectManager:GetInstance():CreateEffect(113)
    effect:AddToActor(target)
  end, delay)
end
function ChainNormal:FindTargets()
  local vec = {}
  local eGroupType = self.m_pActor:GetGroupType()
  if eGroupType == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetEnemyVec()
  else
    vec = ActorManager:GetInstance():GetSelfVec()
  end
  local pPreActor = self.m_pActor:GetEnemy()
  local targets = {}
  table.insert(targets, pPreActor)
  local count = 1
  for k, actor in pairs(vec) do
    if not table.indexof(targets, actor) and self:Check(actor, pPreActor) then
      table.insert(targets, actor)
      count = count + 1
      if count >= self.m_iChainCount then
        break
      end
      pPreActor = actor
    end
  end
  return targets
end
function ChainNormal:Check(pActor, pPreActor)
  pPreActor = pPreActor or self.m_pActor
  if pActor and not pActor:IsDead() then
    local eType = pActor:GetType()
    if (eType == td.ActorType.Soldier or eType == td.ActorType.Hero or eType == td.ActorType.Monster) and cc.pDistanceSQ(cc.p(pPreActor:getPosition()), cc.p(pActor:getPosition())) <= self.m_iAtkRangeSQ then
      return true
    end
  end
  return false
end
return ChainNormal
