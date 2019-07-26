local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local FireworkShot = class("FireworkShot", SkillBase)
FireworkShot.ShotDis = 300
function FireworkShot:ctor(pActor, id, pData)
  FireworkShot.super.ctor(self, pActor, id, pData)
end
function FireworkShot:Update(dt)
  FireworkShot.super.Update(self, dt)
end
function FireworkShot:Execute(endCallback)
  FireworkShot.super.Execute(self, endCallback)
  G_SoundUtil:PlaySound(311, false)
end
function FireworkShot:Shoot()
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  local enemy = self.m_pActor:GetEnemy()
  local bonePos = self.m_pActor:FindBonePos("bone_shoot")
  bonePos = cc.pAdd(bonePos, cc.p(self.m_pActor:getPosition()))
  local pMap = GameDataManager:GetInstance():GetGameMap()
  if pData.atk_effect and pData.atk_effect ~= 0 then
    local pEffect = EffectManager:GetInstance():CreateEffect(pData.atk_effect, self.m_pActor)
    pEffect:AddToActor(self.m_pActor)
  end
  if pData.track_effect and pData.track_effect ~= 0 then
    local pEffect = EffectManager:GetInstance():CreateEffect(pData.track_effect, self.m_pActor, enemy, bonePos)
    local moveX = enemy:getPositionX() - self.m_pActor:getPositionX()
    local moveY = enemy:getPositionY() - self.m_pActor:getPositionY()
    for j, v in ipairs(pEffect.m_vAttributes) do
      if v:GetType() == td.AttributeType.Parabola then
        v.m_pos.x = moveX
        v.m_pos.y = v.m_pos.y + moveY
        break
      end
    end
    pEffect:SetSkill(self)
    pEffect:AddToMap(pMap)
  end
end
return FireworkShot
