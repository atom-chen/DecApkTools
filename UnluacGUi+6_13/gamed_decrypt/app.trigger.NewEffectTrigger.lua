local scheduler = require("framework.scheduler")
local GameDataManager = require("app.GameDataManager")
local TriggerBase = import(".TriggerBase")
local NewEffectTrigger = class("NewEffectTrigger", TriggerBase)
function NewEffectTrigger:ctor(iID, iType, bLoop, conditionType, data)
  NewEffectTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_randomDelay = data.randomDelay
  self.m_effectIds = data.effectIds
  self.m_pEffectManager = require("app.effect.EffectManager").GetInstance()
end
function NewEffectTrigger:Active()
  NewEffectTrigger.super.Active(self)
  if self.m_randomDelay then
    local delay = math.random(self.m_randomDelay[1], self.m_randomDelay[2])
    scheduler.performWithDelayGlobal(function()
      self:StartDo()
    end, delay)
  else
    self:StartDo()
  end
end
function NewEffectTrigger:StartDo()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  for k, value in pairs(self.m_effectIds) do
    local pEffect = self.m_pEffectManager:CreateEffect(value)
    pEffect:AddToMap(pMap)
  end
end
function NewEffectTrigger:RemoveNewEffectId(effectId)
  for k, value in pairs(self.m_effectIds) do
    if value == effectId then
      table.remove(self.m_effectIds, k)
      return true
    end
  end
  return false
end
function NewEffectTrigger:GetNewEffectIdCnt(args)
  return table.nums(self.m_effectIds)
end
return NewEffectTrigger
