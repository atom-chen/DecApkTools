local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local ActorManager = require("app.actor.ActorManager")
local ImproveMate = class("ImproveMate", SkillBase)
function ImproveMate:ctor(pActor, id, pData)
  ImproveMate.super.ctor(self, pActor, id, pData)
end
function ImproveMate:Execute(endCallback)
  ImproveMate.super.Execute(self, endCallback)
  self.m_pActor:performWithDelay(function()
    local vec = self:FindMates()
    local buffMng, effectMng = BuffManager:GetInstance(), EffectManager:GetInstance()
    for key, actor in pairs(vec) do
      local pEffect = effectMng:CreateEffect(self.m_pData.atk_effect)
      if pEffect then
        pEffect:AddToActor(actor)
      end
      for j, buffid in ipairs(self.m_pData.buff_id[1]) do
        buffMng:AddBuff(actor, buffid)
      end
    end
  end, 0.5)
  G_SoundUtil:PlaySound(518)
end
function ImproveMate:FindMates()
  local vec = {}
  local eGroupType = self.m_pActor:GetGroupType()
  if eGroupType == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetSelfVec()
  else
    vec = ActorManager:GetInstance():GetEnemyVec()
  end
  local mates = {}
  local atkRangeSQ = self.m_iDamageRangeW * self.m_iDamageRangeH
  local selfPos = cc.p(self.m_pActor:getPosition())
  for k, actor in pairs(vec) do
    if (actor:GetType() == td.ActorType.Hero or actor:GetType() == td.ActorType.Soldier or actor:GetType() == td.ActorType.Monster) and atkRangeSQ >= cc.pDistanceSQ(selfPos, cc.p(actor:getPosition())) then
      table.insert(mates, actor)
    end
  end
  return mates
end
return ImproveMate
