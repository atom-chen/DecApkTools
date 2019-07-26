local SkillBase = require("app.actor.skill.SkillBase")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local GetHurtPassive = class("GetHurtPassive", SkillBase)
function GetHurtPassive:ctor(pActor, id, pData)
  GetHurtPassive.super.ctor(self, pActor, id, pData)
  local values = string.split(pData.custom_data, "#")
  self.conditions = {}
  for j, var in ipairs(values) do
    table.insert(self.conditions, tonumber(var))
  end
  self.m_bActive = false
end
function GetHurtPassive:Active()
  self.m_bActive = true
end
function GetHurtPassive:Inactive()
  self.m_bActive = false
end
function GetHurtPassive:OnWork(enemy)
  if not self:IsTriggered() then
    return
  end
  self:ShowSkillName()
  for i, v in ipairs(self.m_pData.get_buff_id) do
    BuffManager:GetInstance():AddBuff(self.m_pActor, v, nil)
  end
  if enemy then
    for i, v in ipairs(self.m_pData.buff_id) do
      BuffManager:GetInstance():AddBuff(enemy, v, nil)
    end
  end
end
function GetHurtPassive:IsTriggered()
  local condition = self.m_pActor:GetMaxHp() * self.conditions[2] / 100
  if condition < self.m_pActor:GetCurHp() then
    return false
  end
  local randNum = math.random(100)
  if randNum > self.conditions[1] then
    return false
  end
  return true
end
return GetHurtPassive
