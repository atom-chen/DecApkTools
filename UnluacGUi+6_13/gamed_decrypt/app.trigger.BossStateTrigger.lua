local GameDataManager = require("app.GameDataManager")
local TriggerBase = import(".TriggerBase")
local BossStateTrigger = class("BossStateTrigger", TriggerBase)
function BossStateTrigger:ctor(iID, iType, bLoop, conditionType, data)
  BossStateTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_iState = data.state
  self.m_monsterId = data.monsterId
  self.m_pathId = data.pathId
  self.m_bInverted = data.inverted
end
function BossStateTrigger:Active()
  BossStateTrigger.super.Active(self)
  local pActorManager = require("app.actor.ActorManager").GetInstance()
  local pMonster = pActorManager:FindActorById(self.m_monsterId, true)
  if pMonster and pMonster:GetType() == td.ActorType.Monster and (pMonster:GetMonsterType() == td.MonsterType.BOSS or pMonster:GetMonsterType() == td.MonsterType.DeputyBoss) then
    if self.m_pathId then
      pMonster:SetPathId(self.m_pathId, self.m_bInverted)
    end
    pMonster:SetBossState(self.m_iState)
  end
end
return BossStateTrigger
