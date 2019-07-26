local TriggerBase = import(".TriggerBase")
local OpenUIModuleTrigger = class("OpenUIModuleTrigger", TriggerBase)
function OpenUIModuleTrigger:ctor(iID, iType, bLoop, conditionType, data)
  OpenUIModuleTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_uiModuleId = data.moduleId
  self.m_vSubIndex = data.subIndex
end
function OpenUIModuleTrigger:Active()
  OpenUIModuleTrigger.super.Active(self)
  if not g_MC:IsModuleShowing(self.m_uiModuleId) then
    g_MC:OpenModule(self.m_uiModuleId, nil, self.m_vSubIndex)
  end
end
return OpenUIModuleTrigger
