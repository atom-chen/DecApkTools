local SkillBase = require("app.actor.skill.SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local HomeSkill2 = class("HomeSkill2", SkillBase)
function HomeSkill2:ctor(pActor, id, pData)
  HomeSkill2.super.ctor(self, pActor, id, pData)
end
function HomeSkill2:Execute(endCallback)
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local enemy = self.m_pActor:GetEnemy()
  if enemy and enemy:IsCanAttacked() then
    local bonePos = self.m_pActor:FindBonePos("bone_shoot")
    local skPos = cc.p(self.m_pActor.m_pSkeleton:getPosition())
    local pos = cc.pAdd(cc.p(self.m_pActor:getPosition()), cc.pAdd(skPos, bonePos))
    local pEffect = EffectManager:GetInstance():CreateEffect(pData.atk_effect, self.m_pActor, nil, pos)
    pEffect:AddToMap(pMap)
    local pTrackEffect = EffectManager:GetInstance():CreateEffect(pData.track_effect, self.m_pActor, self.m_pActor:GetEnemy(), pos)
    pTrackEffect:AddToMap(pMap)
  end
  endCallback()
end
return HomeSkill2
