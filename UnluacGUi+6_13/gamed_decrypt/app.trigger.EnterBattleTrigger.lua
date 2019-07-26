local scheduler = require("framework.scheduler")
local TriggerBase = import(".TriggerBase")
local EnterBattleTrigger = class("EnterBattleTrigger", TriggerBase)
function EnterBattleTrigger:ctor(iID, iType, bLoop, conditionType, data)
  EnterBattleTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_mapId = data.mapId
  self.m_missionId = data.missionId or data.mapId
  self.m_delay = data.delay or 0
end
function EnterBattleTrigger:Active()
  EnterBattleTrigger.super.Active(self)
  scheduler.performWithDelayGlobal(function()
    local loadingScene = require("app.scenes.LoadingScene").new(self.m_mapId, self.m_missionId)
    cc.Director:getInstance():replaceScene(loadingScene)
  end, self.m_delay)
end
return EnterBattleTrigger
