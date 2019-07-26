local StateBase = import(".StateBase")
local DeadState = class("DeadState", StateBase)
function DeadState:ctor(pStateManager, pActor)
  DeadState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.Dead
  self.m_fStartTime = 0
  self.m_fEndTime = 0
end
function DeadState:OnEnter()
  self.m_fStartTime = 0
  self.m_fEndTime = 5
  self.m_pActor:PlayAnimation("dead", false)
  self.m_pActor:StopMove()
  self.m_pActor:SetEnemy(nil)
end
function DeadState:OnExit()
end
function DeadState:Update(dt)
  self.m_fStartTime = self.m_fStartTime + dt
  if self.m_fStartTime < self.m_fEndTime then
    return
  end
  self.m_pActor:SetRemove(true)
end
return DeadState
