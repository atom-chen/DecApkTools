local AttributeBase = import(".AttributeBase")
local BuffManager = require("app.buff.BuffManager")
local AttackAttribute = class("AttackAttribute", AttributeBase)
function AttackAttribute:ctor(pEffect, fNextAttributeTime, iDamage, iFixed)
  AttackAttribute.super.ctor(self, td.AttributeType.Attack, pEffect, fNextAttributeTime)
  self.m_iDamageRatio = iDamage
  self.m_iDamageFixed = iFixed
end
function AttackAttribute:Active()
  AttackAttribute.super.Active(self)
  local pSelfActor = self.m_pEffect:GetSelfActor()
  local pSelfParams = self.m_pEffect:GetSelfActorParams()
  local pSkill = self.m_pEffect:GetSkill()
  local isMustHit = false
  if pSkill then
    if self.m_iDamageRatio == nil then
      self.m_iDamageRatio = pSkill:GetSkillRatio()
    end
    if self.m_iDamageFixed == nil then
      self.m_iDamageFixed = pSkill:GetSkillFixed()
    end
    isMustHit = pSkill:IsMustHit()
  end
  local pActor = self.m_pEffect:GetTargetActor()
  if pActor and td.HurtEnemy(pSelfParams, pActor, self.m_iDamageRatio, self.m_iDamageFixed, isMustHit) then
    if pSkill then
      pSkill:DidHit(pActor, self.m_pEffect)
    end
  elseif pSkill then
    pSkill:DidHit(nil, self.m_pEffect)
  end
  self:SetOver()
end
return AttackAttribute
