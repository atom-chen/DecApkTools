local SkillBase = require("app.actor.skill.SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local AlongPassive = class("AlongPassive", SkillBase)
function AlongPassive:ctor(pActor, id, pData)
  AlongPassive.super.ctor(self, pActor, id, pData)
  self.m_vGetBuffId = pData.get_buff_id
  self.m_vBuffs = {}
  self.m_bActive = false
end
function AlongPassive:Active()
  self.m_bActive = true
end
function AlongPassive:Inactive()
  for key, buff in ipairs(self.m_vBuffs) do
    buff:SetRemove()
  end
  self.m_vBuffs = {}
  self.m_bActive = false
end
function AlongPassive:Update(dt)
  if not self.m_bActive then
    return
  end
  if nil == self.m_pActor or self.m_pActor:IsDead() then
    self.m_bActive = false
  end
  if self:CheckAlong() then
    if #self.m_vBuffs <= 0 then
      self:ShowSkillName()
      for key, id in ipairs(self.m_vGetBuffId) do
        local buff = BuffManager:GetInstance():AddBuff(self.m_pActor, id)
        if buff then
          table.insert(self.m_vBuffs, buff)
        end
      end
    end
  elseif #self.m_vBuffs > 0 then
    for key, var in ipairs(self.m_vBuffs) do
      var:SetRemove()
    end
    self.m_vBuffs = {}
  end
end
function AlongPassive:CheckAlong()
  local vec = {}
  if self.m_pActor:GetGroupType() == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetSelfVec()
  elseif self.m_pActor:GetGroupType() == td.GroupType.Enemy then
    vec = ActorManager:GetInstance():GetEnemyVec()
  end
  local selfPos = cc.p(self.m_pActor:getPosition())
  for key, var in pairs(vec) do
    if var ~= self.m_pActor and var:GetType() ~= td.ActorType.Home and var:GetType() ~= td.ActorType.FangYuTa then
      local pos = cc.p(var:getPosition())
      if cc.pDistanceSQ(selfPos, pos) <= self.m_iAtkRangeSQ then
        return false
      end
    end
  end
  return true
end
return AlongPassive
