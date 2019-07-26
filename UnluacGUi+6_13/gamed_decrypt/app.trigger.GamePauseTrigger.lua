local scheduler = require("framework.scheduler")
local TriggerBase = import(".TriggerBase")
local GamePauseTrigger = class("GamePauseTrigger", TriggerBase)
function GamePauseTrigger:ctor(iID, iType, bLoop, conditionType, data)
  GamePauseTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_bIsPause = data.pause
  self.m_iDelay = data.delay or 0
end
function GamePauseTrigger:Active()
  GamePauseTrigger.super.Active(self)
  scheduler.performWithDelayGlobal(function()
    display.getRunningScene():SetPause(self.m_bIsPause)
  end, self.m_iDelay)
end
return GamePauseTrigger
