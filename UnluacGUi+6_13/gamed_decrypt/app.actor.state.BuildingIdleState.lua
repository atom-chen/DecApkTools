local StateBase = import(".StateBase")
local ActorManager = require("app.actor.ActorManager")
local BuildingIdleState = class("BuildingIdleState", StateBase)
function BuildingIdleState:ctor(pStateManager, pActor)
  BuildingIdleState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.BuildingIdle
  self.m_fStartTime = 0
  self.m_fSpaceTime = 0
  self.m_findEnemyTime = 0
  self.m_findEnemyStartTime = 0
end
function BuildingIdleState:OnEnter()
  self.m_fStartTime = 0
  self.m_fSpaceTime = 0.5
  self.m_pActor:PlayAnimation("fangyuta_01", true)
  self.m_findEnemyTime = math.random(1, 5) * 0.1
  self.m_findEnemyStartTime = 0
end
function BuildingIdleState:OnExit()
end
function BuildingIdleState:Update(dt)
  self.m_findEnemyStartTime = self.m_findEnemyStartTime + dt
  if self.m_pActor:IsDead() then
    return
  end
  self.m_fStartTime = self.m_fStartTime + dt
  if self.m_fStartTime < self.m_fSpaceTime then
    return
  end
  if self.m_pActor:IsCanAttack() then
    local pEnemy = self.m_pActor:GetEnemy()
    if (nil == pEnemy or not pEnemy:IsCanAttacked()) and self.m_findEnemyStartTime >= self.m_findEnemyTime then
      if not ActorManager:GetInstance():UpdateFindEnemyCount(self.m_pActor:getTag()) then
        ActorManager:GetInstance():AddToWaitFindEnemyVec(self.m_pActor:getTag())
        return
      end
      self.m_findEnemyStartTime = 0
      pEnemy = self.m_pActor:FindEnemy()
    end
    if pEnemy and pEnemy:IsCanAttacked() and self.m_pActor:IsInAttackRange(pEnemy) then
      self.m_pActor:SetEnemy(pEnemy)
      self.m_pStateManager:ChangeState(td.StateType.BuildingAttack)
    end
  end
end
return BuildingIdleState
