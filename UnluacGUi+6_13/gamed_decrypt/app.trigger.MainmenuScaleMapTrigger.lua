local scheduler = require("framework.scheduler")
local TriggerBase = import(".TriggerBase")
local MainmenuScaleMapTrigger = class("MainmenuScaleMapTrigger", TriggerBase)
function MainmenuScaleMapTrigger:ctor(iID, iType, bLoop, conditionType, data)
  MainmenuScaleMapTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_point = data.point
end
function MainmenuScaleMapTrigger:Active()
  MainmenuScaleMapTrigger.super.Active(self)
  local pScene = display.getRunningScene()
  if pScene.GetType and pScene:GetType() == td.SceneType.Main then
    pScene:PanelBgCallback(self.m_point)
  end
end
return MainmenuScaleMapTrigger
