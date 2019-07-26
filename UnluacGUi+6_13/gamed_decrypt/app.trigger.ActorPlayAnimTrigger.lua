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
local ActorPlayAnimTrigger = class("ActorPlayAnimTrigger", TriggerBase)
function ActorPlayAnimTrigger:ctor(iID, iType, bLoop, conditionType, data)
  ActorPlayAnimTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_actorId = data.actorId
  self.m_anims = data.anims
end
function ActorPlayAnimTrigger:Active()
  ActorPlayAnimTrigger.super.Active(self)
  local pActorManager = require("app.actor.ActorManager").GetInstance()
  local pMonster = pActorManager:FindActorById(self.m_actorId)
  for _, value in ipairs(self.m_anims) do
    pMonster.m_pSkeleton:PlayAni(value[1], value[2], true)
  end
  local function callback()
    local mapId = GameDataManager.GetInstance():GetGameMapInfo().id
    require("app.trigger.TriggerManager"):GetInstance():SendEvent({
      eType = td.ConditionType.ActorAnimOver,
      monsterId = self.m_actorId,
      triggerId = self:GetID()
    })
  end
  scheduler.performWithDelayGlobal(callback, 0.5 * table.nums(self.m_anims))
end
return ActorPlayAnimTrigger
