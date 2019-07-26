local NormalSkill = import(".NormalSkill")
local SkillInfoManager = require("app.info.SkillInfoManager")
local GameDataManager = require("app.GameDataManager")
local BuffManager = require("app.buff.BuffManager")
local EffectManager = require("app.effect.EffectManager")
local FireNormalSkill = class("FireNormalSkill", NormalSkill)
FireNormalSkill.HitbackDis = 100
FireNormalSkill.SeniorTrack = 68
function FireNormalSkill:ctor(pActor, id, pData)
  FireNormalSkill.super.ctor(self, pActor, id, pData)
  self.m_executeCount = 0
  self.m_isSenior = id == 1020 and true or false
end
function FireNormalSkill:Execute(endCallback)
  self.m_fStartTime = 0
  local aniNames = string.split(self.m_pData.skill_name, "#")
  self.m_pActor:PlayAnimation(aniNames[1], false, function()
    self:ExecuteOver()
    endCallback()
  end, sp.EventType.ANIMATION_COMPLETE)
end
function FireNormalSkill:Shoot()
  local enemy = self.m_pActor:GetEnemy()
  local bonePos = self.m_pActor:FindBonePos("bone_shoot")
  bonePos = cc.pAdd(bonePos, cc.p(self.m_pActor:getPosition()))
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local effectId = self.m_pData.track_effect
  self.m_executeCount = self.m_executeCount + 1
  if self.m_isSenior and self.m_executeCount >= 3 then
    effectId = FireNormalSkill.SeniorTrack
    self.m_executeCount = 0
    self:ShowSkillName()
  end
  local pEffect = EffectManager:GetInstance():CreateEffect(effectId, self.m_pActor, enemy, bonePos)
  pEffect:SetSkill(self)
  pEffect:AddToMap(pMap)
  if self.m_pActor.m_attackSound then
    G_SoundUtil:PlaySound(self.m_pActor.m_attackSound, false)
  end
end
function FireNormalSkill:DidHit(pActor, pEffect)
  FireNormalSkill.super.DidHit(self, pActor)
  if pActor and pActor:IsCanBeMoved() and pEffect:GetID() == FireNormalSkill.SeniorTrack then
    self:HitBack(pActor, FireNormalSkill.HitbackDis)
  end
end
return FireNormalSkill
