local NormalSkill = import(".NormalSkill")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local GunNormalSkill = class("GunNormalSkill", NormalSkill)
local SHOOT_COUNT = 6
function GunNormalSkill:ctor(pActor, id, pData)
  GunNormalSkill.super.ctor(self, pActor, id, pData)
  self.m_pShootEffect = nil
  self.m_iJudgeHitTime = SHOOT_COUNT
  self.m_bIsPlayingSound = false
end
function GunNormalSkill:OnExit()
  if self.m_pShootEffect then
    self.m_pShootEffect:SetRemove(true)
    self.m_pShootEffect = nil
  end
  GunNormalSkill.super.OnExit(self)
end
function GunNormalSkill:Update(dt)
  GunNormalSkill.super.Update(self, dt)
end
function GunNormalSkill:Execute(endCallback)
  self.m_fStartTime = 0
  self.m_pActor:UpdateEnemyAzimuth()
  local aniName = "fire_0" .. self.m_pActor.m_pEnemyAzimuth
  self.m_pActor:PlayAnimation(aniName, false, function()
    self:ExecuteOver()
    endCallback()
  end, sp.EventType.ANIMATION_COMPLETE)
  if self.m_pActor.m_attackSound and not self.m_bIsPlayingSound then
    G_SoundUtil:PlaySound(self.m_pActor.m_attackSound, false)
    self.m_bIsPlayingSound = true
    self.m_pActor:performWithDelay(function()
      self.m_bIsPlayingSound = false
    end, 1)
  end
end
function GunNormalSkill:ExecuteOver()
end
function GunNormalSkill:Shoot()
  local pData = self.m_pData
  local enemy = self.m_pActor:GetEnemy()
  local bonePos = self.m_pActor:FindBonePos("bone_shoot")
  bonePos = cc.pAdd(bonePos, cc.p(self.m_pActor:getPosition()))
  local pMap = GameDataManager:GetInstance():GetGameMap()
  if self.m_pShootEffect then
    self.m_pShootEffect:GetContentNode():PlayAni("animation", false)
  elseif pData.atk_effect and pData.atk_effect ~= 0 then
    self.m_pShootEffect = EffectManager:GetInstance():CreateEffect(pData.atk_effect, self.m_pActor, nil)
    self.m_pShootEffect:AddToActor(self.m_pActor)
  end
  if pData.track_effect and pData.track_effect ~= 0 then
    local seq = {}
    for i = 0, SHOOT_COUNT - 1 do
      do
        local pEffect = EffectManager:GetInstance():CreateEffect(pData.track_effect, self.m_pActor, enemy, bonePos)
        pEffect:SetSkill(self)
        table.insert(seq, cca.delay(i * 0.05))
        table.insert(seq, cca.cb(function()
          pEffect:AddToMap(pMap)
        end))
      end
    end
    pMap:runAction(cca.seq(seq))
  end
end
return GunNormalSkill
