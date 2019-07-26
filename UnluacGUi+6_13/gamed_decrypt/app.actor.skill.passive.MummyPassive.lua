local SkillBase = require("app.actor.skill.SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local MummyPassive = class("MummyPassive", SkillBase)
MummyPassive.COMBO_DIS = 200
function MummyPassive:ctor(pActor, id, pData)
  MummyPassive.super.ctor(self, pActor, id, pData)
  self.m_TimeInterval = MummyPassive.CHANGE_TIME
  self.m_bIsCombo = false
  self.m_vBuffs = {}
  self.m_vBuffCombo = pData.get_buff_id
  self.m_bActive = false
end
function MummyPassive:Active()
  local effectManager = EffectManager:GetInstance()
  local pEffect = effectManager:CreateEffect(self.m_atkEffect)
  pEffect:AddToActor(self.m_pActor, -1)
  self.m_bActive = true
end
function MummyPassive:Inactive()
  self.m_bActive = false
end
function MummyPassive:Update(dt)
  if not self.m_bActive then
    return
  end
  local companion = self.m_pActor:GetCompanion()
  if companion then
    local aPos = cc.p(self.m_pActor:getPosition())
    local cPos = cc.p(companion:getPosition())
    local dis = cc.pGetDistance(aPos, cPos)
    if dis > MummyPassive.COMBO_DIS then
      if self.m_bIsCombo then
        self:RemoveBuffs()
        self.m_bIsCombo = false
        self.m_pActor:Decompose()
      end
    elseif not self.m_bIsCombo then
      self:AddBuffs(self.m_vBuffCombo)
      self.m_bIsCombo = true
      self.m_pActor:Combo()
    end
  end
end
function MummyPassive:RemoveBuffs()
  for i, buff in ipairs(self.m_vBuffs) do
    buff:SetRemove()
  end
end
function MummyPassive:AddBuffs(IDs)
  for j, id in ipairs(IDs) do
    local buff = BuffManager:GetInstance():AddBuff(self.m_pActor, id, nil, nil, true)
    if buff then
      table.insert(self.m_vBuffs, buff)
    end
  end
end
return MummyPassive
