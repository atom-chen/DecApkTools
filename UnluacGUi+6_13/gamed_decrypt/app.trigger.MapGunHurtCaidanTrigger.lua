local scheduler = require("framework.scheduler")
local TriggerBase = import(".TriggerBase")
local MapGunHurtCaidanTrigger = class("MapGunHurtCaidanTrigger", TriggerBase)
function MapGunHurtCaidanTrigger:ctor(iID, iType, bLoop, conditionType, data)
  MapGunHurtCaidanTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_caidanEffectId = data.caidanEffectId
  self.m_pEffectManager = require("app.effect.EffectManager").GetInstance()
end
function MapGunHurtCaidanTrigger:Active()
  MapGunHurtCaidanTrigger.super.Active(self)
  local effect = self.m_pEffectManager:GetEffectById(self.m_caidanEffectId)
  local pEffAttr = effect:GetAttributeByType(td.AttributeType.Sleep)
  if pEffAttr then
    pEffAttr:WakeUp()
  end
end
return MapGunHurtCaidanTrigger
