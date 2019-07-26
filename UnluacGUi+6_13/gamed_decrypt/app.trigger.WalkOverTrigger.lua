local scheduler = require("framework.scheduler")
local GameDataManager = require("app.GameDataManager")
local TriggerBase = import(".TriggerBase")
local WalkOverTrigger = class("WalkOverTrigger", TriggerBase)
function WalkOverTrigger:ctor(iID, iType, bLoop, conditionType, data)
  WalkOverTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_effectIds = data.effectIds
  self.m_triggerIds = data.triggerIds
  self.m_pEffectManager = require("app.effect.EffectManager").GetInstance()
  self.m_pTriggerManager = require("app.trigger.TriggerManager").GetInstance()
end
function WalkOverTrigger:Active()
  WalkOverTrigger.super.Active(self)
  for _, value in pairs(self.m_effectIds) do
    local effect = self.m_pEffectManager:GetEffectById(value)
    if effect then
      local pEffAttr = effect:GetAttributeByType(td.AttributeType.Walk)
      if pEffAttr then
        pEffAttr:ForceSetOver()
      end
    end
  end
  for _, value in pairs(self.m_triggerIds) do
    local trigger = self.m_pTriggerManager:GetTriggerById(value)
    if trigger then
      for _, value2 in pairs(self.m_effectIds) do
        trigger:RemoveNewEffectId(value2)
      end
      if trigger:GetNewEffectIdCnt() == 1 then
        require("app.trigger.TriggerManager").GetInstance():SendEvent({
          eType = td.ConditionType.AllHYRDead
        })
      end
    end
  end
end
return WalkOverTrigger
