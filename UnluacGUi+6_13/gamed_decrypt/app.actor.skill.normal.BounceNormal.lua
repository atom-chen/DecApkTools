local NormalSkill = import(".NormalSkill")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local BounceNormal = class("BounceNormal", NormalSkill)
function BounceNormal:ctor(pActor, id, pData)
  BounceNormal.super.ctor(self, pActor, id, pData)
  self.m_pLastTarget = nil
  self.m_iBoundTime = 0
  self.m_iMaxTime = tonumber(pData.custom_data)
  self.m_iOriSkillRatio = self.m_iSkillRatio
end
function BounceNormal:Update(dt)
  BounceNormal.super.Update(self, dt)
end
function BounceNormal:Execute(endCallback)
  BounceNormal.super.Execute(self, endCallback)
end
function BounceNormal:Shoot()
  self.m_pLastTarget = self.m_pActor:GetEnemy()
  local bonePos = self.m_pActor:FindBonePos("bone_shoot")
  bonePos = cc.pAdd(bonePos, cc.p(self.m_pActor:getPosition()))
  local pMap = GameDataManager:GetInstance():GetGameMap()
  if self.m_pData.atk_effect and self.m_pData.atk_effect ~= 0 then
    local pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.atk_effect, self.m_pActor)
    pEffect:AddToActor(self.m_pActor)
  end
  if self.m_pData.track_effect and self.m_pData.track_effect ~= 0 then
    local pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.track_effect, self.m_pActor, self.m_pLastTarget, bonePos)
    pEffect:SetSkill(self)
    pEffect:AddToMap(pMap)
  end
  self.m_iBoundTime = 1
end
function BounceNormal:DidHit(pActor, pEffect)
  BounceNormal.super.DidHit(self, pActor)
  if self.m_iBoundTime < self.m_iMaxTime then
    local vTargets = self:FindTargets()
    local num = #vTargets
    local pEnemy = num > 0 and vTargets[math.random(num)] or nil
    if pEnemy then
      pEffect:SetTargetActor(pEnemy)
      pEffect:ClearAllAttribute()
      local effectInfo = {
        attrs = {
          {
            type = 3,
            timeNext = 0,
            animation = "animation",
            loop = true
          },
          {
            type = 19,
            timeNext = -1,
            speed = 500,
            rotate = true
          },
          {
            type = 14,
            timeNext = -1,
            newID = 101
          },
          {type = 1, timeNext = -1}
        }
      }
      EffectManager:GetInstance():CreateAttribute(pEffect, effectInfo)
      self.m_iBoundTime = self.m_iBoundTime + 1
      self.m_iSkillRatio = self.m_iOriSkillRatio * (1.2 - self.m_iBoundTime * 0.2)
      self.m_pLastTarget = pEnemy
      return
    end
  end
  pEffect:SetRemove()
  self.m_pLastTarget = nil
  self.m_iSkillRatio = self.m_iOriSkillRatio
end
function BounceNormal:FindTargets()
  local ActorManager = require("app.actor.ActorManager")
  local vTargets = {}
  local vec = {}
  local eGroupType = self.m_pActor:GetGroupType()
  if eGroupType == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetEnemyVec()
  else
    vec = ActorManager:GetInstance():GetSelfVec()
  end
  local selfPos = cc.p(self.m_pLastTarget:getPosition())
  for key, var in pairs(vec) do
    if var ~= self.m_pLastTarget and cc.pDistanceSQ(selfPos, cc.p(var:getPosition())) <= self.m_iAtkRangeSQ then
      table.insert(vTargets, var)
    end
  end
  return vTargets
end
return BounceNormal
