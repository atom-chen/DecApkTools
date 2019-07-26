local ConditionBase = import(".ConditionBase")
local MapGunFireCondition = class("MapGunFireCondition", ConditionBase)
function MapGunFireCondition:ctor(data)
  MapGunFireCondition.super.ctor(self, td.ConditionType.MapGunFire)
  self.m_caidanEffectId = data.caidanEffectId
end
function MapGunFireCondition:CheckSatisfy(data)
  local effect = require("app.effect.EffectManager"):GetInstance():GetEffectById(self.m_caidanEffectId)
  if nil ~= effect then
    local effPos = cc.p(effect:getPosition())
    local rect = {}
    rect.width = data.size.width
    rect.height = data.size.height
    rect.x = data.pos.x - rect.width * 0.5
    rect.y = data.pos.y - rect.height * 0.5
    if cc.rectContainsPoint(rect, effPos) then
      return true
    end
  end
  return false
end
return MapGunFireCondition
