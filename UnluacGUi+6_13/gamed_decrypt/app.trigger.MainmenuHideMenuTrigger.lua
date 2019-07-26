local scheduler = require("framework.scheduler")
local TriggerBase = import(".TriggerBase")
local MainmenuHideMenuTrigger = class("MainmenuHideMenuTrigger", TriggerBase)
function MainmenuHideMenuTrigger:ctor(iID, iType, bLoop, conditionType, data)
  MainmenuHideMenuTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_menuIndex = data.menu
end
function MainmenuHideMenuTrigger:Active()
  MainmenuHideMenuTrigger.super.Active(self)
  local pScene = display.getRunningScene()
  if pScene.GetType and pScene:GetType() == td.SceneType.Main then
    pScene:ToggleBottomMenu(self.m_menuIndex, cc.p(0, 0))
  end
end
return MainmenuHideMenuTrigger
