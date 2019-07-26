local scheduler = require("framework.scheduler")
local TriggerBase = import(".TriggerBase")
local GameDataManager = require("app.GameDataManager")
local GamePauseUITrigger = class("GamePauseUITrigger", TriggerBase)
function GamePauseUITrigger:ctor(iID, iType, bLoop, conditionType, data)
  GamePauseUITrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_bIsPause = data.pause
  self.m_iDelay = data.delay or 0
end
function GamePauseUITrigger:Active()
  GamePauseUITrigger.super.Active(self)
  scheduler.performWithDelayGlobal(function()
    GameDataManager:GetInstance():SetPauseUI(self.m_bIsPause)
  end, self.m_iDelay)
end
return GamePauseUITrigger
