local scheduler = require("framework.scheduler")
local GameDataManager = require("app.GameDataManager")
local TriggerBase = import(".TriggerBase")
local GuideManager = require("app.GuideManager")
local scheduler = require("framework.scheduler")
local MoveType = {
  home = 1,
  enemyHome = 2,
  actor = 3,
  abspos = 4
}
local StateManagerPauseTrigger = class("StateManagerPauseTrigger", TriggerBase)
function StateManagerPauseTrigger:ctor(iID, iType, bLoop, conditionType, data)
  StateManagerPauseTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_monstId = data.monstId
  self.m_bPause = data.bPause or false
end
function StateManagerPauseTrigger:Active()
  StateManagerPauseTrigger.super.Active(self)
  local pActorManager = require("app.actor.ActorManager").GetInstance()
  local pMonster = pActorManager:FindActorById(self.m_monstId)
  pMonster.m_pStateManager:SetPause(self.m_bPause)
end
return StateManagerPauseTrigger
