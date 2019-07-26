local scheduler = require("framework.scheduler")
local TriggerBase = import(".TriggerBase")
local GameLoseTrigger = class("GameLoseTrigger", TriggerBase)
function GameLoseTrigger:ctor(iID, iType, bLoop, conditionType, data)
  GameLoseTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
end
function GameLoseTrigger:Active()
  GameLoseTrigger.super.Active(self)
  scheduler.performWithDelayGlobal(function()
    require("app.GameDataManager"):GetInstance():GameLose()
  end, 0.5)
end
return GameLoseTrigger
