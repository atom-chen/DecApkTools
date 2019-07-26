local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local VampireBoss = require("app.actor.VampireBoss")
local ForceSource = class("ForceSource", SkillBase)
function ForceSource:ctor(pActor, id, pData)
  ForceSource.super.ctor(self, pActor, id, pData)
  self.m_pData = pData
  self.m_iTimeInterval = 0
  self.m_bIsExecuting = false
  self.m_hEndCallback = nil
  self.m_vSourceEffect = {}
  self.m_vLinkEffect = {}
  self.m_vBuffs = {}
end
function ForceSource:Execute(endCallback)
  self.m_fStartTime = 0
  local t = string.split(self.m_pData.skill_name, ";")
  self.m_pActor:PlayAnimation(t[1], false, function()
    self:HexAllSoldiers()
    self.m_pActor:PlayAnimation(t[2], false, function()
      self:ExecuteOver()
      endCallback()
    end, sp.EventType.ANIMATION_COMPLETE)
  end, sp.EventType.ANIMATION_COMPLETE)
end
function ForceSource:HexAllSoldiers()
  local vec = {}
  if self.m_pActor:GetGroupType() == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetEnemyVec()
  elseif self.m_pActor:GetGroupType() == td.GroupType.Enemy then
    vec = ActorManager:GetInstance():GetSelfVec()
  end
  for key, v in pairs(vec) do
    if v:GetType() == td.ActorType.Soldier and not v:IsDead() then
      for i, buffId in ipairs(self.m_pData.buff_id[1]) do
        local buff = BuffManager:GetInstance():AddBuff(v, buffId)
        if buff then
          table.insert(self.m_vBuffs, buff)
        end
      end
    end
  end
end
function ForceSource:IsTriggered()
  local supCondition = ForceSource.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  if self.m_pActor:GetBossState() ~= VampireBoss.BossState.Normal2 then
    return false
  end
  return true
end
return ForceSource
