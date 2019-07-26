local scheduler = require("framework.scheduler")
local GameDataManager = require("app.GameDataManager")
local TriggerBase = import(".TriggerBase")
local GuideManager = require("app.GuideManager")
local MoveType = {
  home = 1,
  enemyHome = 2,
  center = 3,
  abspos = 4
}
local ViewPortMoveTrigger = class("ViewPortMoveTrigger", TriggerBase)
function ViewPortMoveTrigger:ctor(iID, iType, bLoop, conditionType, data)
  ViewPortMoveTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_yOffset = data.yOffset or 0
  self.m_xOffset = data.xOffset or 0
  self.m_moveType = data.moveType
  self.m_actorId = data.actorId
  self.m_delay = data.delay or 0
  self.m_pos = cc.p(data.x or 0, data.y or 0)
  self.m_preDelay = data.preDelay or 0
  if data.autoPause == nil then
    self.m_bAutoPause = true
  else
    self.m_bAutoPause = data.autoPause
  end
end
function ViewPortMoveTrigger:Active()
  ViewPortMoveTrigger.super.Active(self)
  local function infunc2()
    if self.m_bAutoPause then
      display.getRunningScene():SetPause(true)
    end
    local dataManager = require("app.GameDataManager").GetInstance()
    local speed = 1000
    local pos
    if MoveType.home == self.m_moveType or MoveType.enemyHome == self.m_moveType then
      local isSelf
      if self.m_moveType == 1 then
        isEnemy = false
      else
        isEnemy = true
      end
      pos = cc.p(require("app.actor.ActorManager").GetInstance():FindHome(isEnemy):getPosition())
    elseif MoveType.center == self.m_moveType then
      local pMap = dataManager:GetGameMap()
      pos = cc.p(pMap:GetPiexlSize().width / 2, pMap:GetPiexlSize().height / 2)
    else
      pos = self.m_pos
    end
    pos.x = pos.x + self.m_xOffset
    pos.y = pos.y + self.m_yOffset
    local pMap = dataManager:GetGameMap()
    pMap:HighlightPos(pos, speed, function()
      scheduler.performWithDelayGlobal(function()
        if self.m_bAutoPause then
          display.getRunningScene():SetPause(false)
        end
        require("app.trigger.TriggerManager"):GetInstance():SendEvent({
          eType = td.ConditionType.ViewportMoveOver,
          triggerId = self:GetID()
        })
      end, self.m_delay)
    end)
  end
  scheduler.performWithDelayGlobal(infunc2, self.m_preDelay)
end
return ViewPortMoveTrigger
