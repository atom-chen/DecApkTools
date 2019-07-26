local StateBase = import(".StateBase")
local TrappedState = class("TrappedState", StateBase)
function TrappedState:ctor(pStateManager, pActor)
  TrappedState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.Trapped
end
function TrappedState:OnEnter()
  self.m_pActor:StopMove()
  self.m_pActor:PlayAnimation("stand")
end
function TrappedState:OnExit()
end
function TrappedState:Update(dt)
  if self.m_pActor:IsDead() and self.m_pStateManager:ChangeState(td.StateType.Dead) then
    return
  end
  if self.m_pActor:IsHex() and self.m_pStateManager:ChangeState(td.StateType.Hex) then
    return
  end
  if not self.m_pActor:IsTrapped() then
    self.m_pStateManager:ChangeState(td.StateType.Idle)
  end
end
return TrappedState
