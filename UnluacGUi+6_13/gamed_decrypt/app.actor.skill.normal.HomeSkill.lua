local SkillBase = require("app.actor.skill.SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local HomeSkill = class("HomeSkill", SkillBase)
function HomeSkill:ctor(pActor, id, pData)
  HomeSkill.super.ctor(self, pActor, id, pData)
end
function HomeSkill:Execute(endCallback)
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local enemy = self.m_pActor:GetEnemy()
  if enemy and enemy:IsCanAttacked() then
    do
      local bonePos = self.m_pActor:FindBonePos("bone_shoot")
      local skPos = cc.p(self.m_pActor.m_pSkeleton:getPosition())
      local pos = cc.pAdd(cc.p(self.m_pActor:getPosition()), cc.pAdd(skPos, bonePos))
      local pEffect = EffectManager:GetInstance():CreateEffect(pData.atk_effect, self.m_pActor, nil, pos)
      pEffect:AddToMap(pMap)
      local targetPos = enemy:GetBeHitPos()
      pMap:runAction(cca.seq({
        cca.delay(0.4),
        cca.cb(function()
          local pTrackEffect = EffectManager:GetInstance():CreateEffect(pData.track_effect, self.m_pActor, self.m_pActor:GetEnemy(), pos)
          pTrackEffect:AddToMap(pMap)
          local angle = GetAzimuth(pos, targetPos)
          pTrackEffect:setRotation(angle)
          local dis = cc.pGetLength(cc.pSub(pos, targetPos))
          local scale = dis / (pTrackEffect:GetContentSize().width - 20)
          pTrackEffect:setScaleX(scale)
        end),
        cca.delay(0.1),
        cca.cb(function()
          local pHurtEffect = EffectManager:GetInstance():CreateEffect(pData.hurt_effect, self.m_pActor, self.m_pActor:GetEnemy(), targetPos)
          pHurtEffect:AddToMap(pMap)
          endCallback()
        end)
      }))
    end
  else
    endCallback()
  end
end
return HomeSkill
