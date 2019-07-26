local scheduler = require("framework.scheduler")
local TriggerBase = import(".TriggerBase")
local GameWinTrigger = class("GameWinTrigger", TriggerBase)
function GameWinTrigger:ctor(iID, iType, bLoop, conditionType, data)
  GameWinTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
end
function GameWinTrigger:Active()
  GameWinTrigger.super.Active(self)
  scheduler.performWithDelayGlobal(function()
    require("app.GameDataManager"):GetInstance():GameWin()
  end, 0.5)
end
return GameWinTrigger
