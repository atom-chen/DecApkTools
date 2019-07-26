local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local BuffManager = require("app.buff.BuffManager")
local Flashbomb = class("Flashbomb", SkillBase)
function Flashbomb:ctor(pActor, id, pData)
  Flashbomb.super.ctor(self, pActor, id, pData)
end
function Flashbomb:Execute(endCallback)
  self.m_fStartTime = 0
  local t = string.split(self.m_pData.skill_name, "#")
  local aniName = t[1]
  self.m_pActor:PlayAnimation(aniName, false, function(event)
    endCallback()
  end, sp.EventType.ANIMATION_COMPLETE)
  self.m_pActor:runAction(cca.seq({
    cca.delay(0.6),
    cca.cb(function()
      self:CastBomb()
    end)
  }))
  G_SoundUtil:PlaySound(207, false)
  self:ShowSkillName()
end
function Flashbomb:CastBomb()
  local enemy = self.m_pActor:GetEnemy()
  local bonePos = self.m_pActor:FindBonePos("bone_shoot")
  bonePos = cc.pAdd(bonePos, cc.p(self.m_pActor:getPosition()))
  local pMap = GameDataManager:GetInstance():GetGameMap()
  if self.m_pData.track_effect and self.m_pData.track_effect ~= 0 then
    local pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.track_effect, self.m_pActor, enemy, bonePos)
    pEffect:SetSkill(self)
    pEffect:AddToMap(pMap)
  end
end
function Flashbomb:IsTriggered()
  local supCondition = Flashbomb.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local enemy = self.m_pActor:GetEnemy()
  if enemy and enemy:GetType() ~= td.ActorType.Home then
    return true
  end
  return false
end
return Flashbomb
