local TriggerBase = import(".TriggerBase")
local ForbidPathMonsterTrigger = class("ForbidPathMonsterTrigger", TriggerBase)
function ForbidPathMonsterTrigger:ctor(iID, iType, bLoop, conditionType, data)
  ForbidPathMonsterTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_vPath = data.path
end
function ForbidPathMonsterTrigger:Active()
  ForbidPathMonsterTrigger.super.Active(self)
  require("app.GameDataManager"):GetInstance():AddClearPath(self.m_vPath)
end
return ForbidPathMonsterTrigger
