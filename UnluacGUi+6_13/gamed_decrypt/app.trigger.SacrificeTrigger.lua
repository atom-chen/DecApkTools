local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local scheduler = require("framework.scheduler")
local TriggerBase = import(".TriggerBase")
local SacrificeTrigger = class("SacrificeTrigger", TriggerBase)
function SacrificeTrigger:ctor(iID, iType, bLoop, conditionType, data)
  SacrificeTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_fromActorId = data.fromActorId
  self.m_toActorId = data.toActorId
  self.m_delay = data.delay
  self.m_vEffects = {}
end
function SacrificeTrigger:Active()
  SacrificeTrigger.super.Active(self)
  local pMap = require("app.GameDataManager").GetInstance():GetGameMap()
  local pActorManager = require("app.actor.ActorManager").GetInstance()
  local fromActor = pActorManager:FindActorById(self.m_fromActorId, true)
  local toActor = pActorManager:FindActorById(self.m_toActorId, true)
  if fromActor and toActor and toActor ~= fromActor then
    local linkEffect = EffectManager:GetInstance():CreateEffect(141, toActor, fromActor)
    linkEffect:AddToMap(pMap)
    table.insert(self.m_vEffects, linkEffect)
    local effect1 = EffectManager:GetInstance():CreateEffect(142)
    effect1:AddToActor(toActor)
    table.insert(self.m_vEffects, effect1)
    local effect2 = EffectManager:GetInstance():CreateEffect(142)
    effect2:AddToActor(fromActor)
    table.insert(self.m_vEffects, effect2)
  end
  scheduler.performWithDelayGlobal(function()
    if toActor and fromActor and not fromActor:IsDead() then
      toActor:Sacrify(fromActor)
      require("app.trigger.TriggerManager"):GetInstance():SendEvent({
        eType = td.ConditionType.SacrificeMonster,
        monsterId = self.m_fromActorId
      })
    end
    for i, effect in ipairs(self.m_vEffects) do
      effect:SetRemove()
    end
    self.m_vEffects = {}
  end, self.m_delay)
end
return SacrificeTrigger
