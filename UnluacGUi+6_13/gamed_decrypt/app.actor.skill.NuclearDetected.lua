local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local NuclearDetected = class("NuclearDetected", SkillBase)
function NuclearDetected:ctor(pActor, id, pData)
  NuclearDetected.super.ctor(self, pActor, id, pData)
  self.m_pTarget = nil
end
function NuclearDetected:Update(dt)
  NuclearDetected.super.Update(self, dt)
end
function NuclearDetected:Execute(endCallback)
  if self.m_pTarget and self.m_pTarget:IsCanAttacked() then
    self.m_fStartTime = 0
    local aniNames = string.split(self.m_pData.skill_name, "#")
    self.m_pActor:PlayAnimation(aniNames[1], false, function()
      endCallback()
      self:ExecuteOver()
    end, sp.EventType.ANIMATION_COMPLETE)
    local effect = EffectManager:GetInstance():CreateEffect(self.m_pData.track_effect, self.m_pActor, self.m_pTarget)
    effect:SetSkill(self)
    effect:AddToActor(self.m_pTarget, 100)
    G_SoundUtil:PlaySound(208, false)
    self:ShowSkillName()
  else
    endCallback()
    self.m_pTarget = nil
  end
end
function NuclearDetected:IsTriggered()
  local supCondition = NuclearDetected.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local enemy = self.m_pActor:GetEnemy()
  if enemy and enemy:IsCanAttacked() then
    self.m_pTarget = enemy
    return true
  end
  return false
end
return NuclearDetected
