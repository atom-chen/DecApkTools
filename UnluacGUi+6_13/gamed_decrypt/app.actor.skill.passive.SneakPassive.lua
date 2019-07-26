local SkillBase = require("app.actor.skill.SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local SneakPassive = class("SneakPassive", SkillBase)
function SneakPassive:ctor(pActor, id, pData)
  SneakPassive.super.ctor(self, pActor, id, pData)
  self.m_vGetBuffId = pData.get_buff_id
  self.m_vBuffs = {}
  self.m_bActive = false
  self.m_bIsStealthy = false
end
function SneakPassive:Active()
  self.m_bActive = true
end
function SneakPassive:Inactive()
  if self.m_bIsStealthy then
    self:BeNotStealthy()
  end
  self.m_bActive = false
end
function SneakPassive:Update(dt)
  if not self.m_bActive then
    return
  end
  if nil == self.m_pActor or self.m_pActor:IsDead() then
    self.m_bActive = false
  end
  local state = self.m_pActor.m_pStateManager:GetCurState():GetType()
  if self:CheckCanBeStealthy(state) then
    if not self.m_bIsStealthy then
      self:BeStealthy()
    end
  elseif self.m_bIsStealthy then
    self:BeNotStealthy()
  end
end
function SneakPassive:CheckCanBeStealthy(state)
  if state == td.StateType.Attack or state == td.StateType.Trapped or state == td.StateType.Dead or state == td.StateType.Hex then
    return false
  end
  return true
end
function SneakPassive:BeStealthy()
  for key, id in ipairs(self.m_vGetBuffId) do
    local buff = BuffManager:GetInstance():AddBuff(self.m_pActor, id)
    if buff then
      table.insert(self.m_vBuffs, buff)
    end
  end
  self.m_pActor.m_pSkeleton:runAction(cca.fadeTo(1, 0.4))
  self.m_bIsStealthy = true
end
function SneakPassive:BeNotStealthy()
  for key, buff in ipairs(self.m_vBuffs) do
    buff:SetRemove()
  end
  self.m_vBuffs = {}
  self.m_pActor.m_pSkeleton:runAction(cca.fadeTo(1, 1))
  self.m_bIsStealthy = false
end
return SneakPassive
