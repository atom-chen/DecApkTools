local TriggerBase = import(".TriggerBase")
local TroopTrigger = class("TroopTrigger", TriggerBase)
function TroopTrigger:ctor(iID, iType, bLoop, conditionType)
  TroopTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
end
function TroopTrigger:Active()
  TroopTrigger.super.Active(self)
  td.dispatchEvent(td.TROOP_TIME_OVER, {index = -1})
end
return TroopTrigger
