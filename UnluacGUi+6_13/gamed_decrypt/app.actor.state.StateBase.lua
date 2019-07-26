local StateBase = class("StateBase")
function StateBase:ctor(pStateManager, pActor)
  self.m_eType = td.StateType.Idle
  self.m_pActor = pActor
  self.m_pStateManager = pStateManager
end
function StateBase:OnEnter()
end
function StateBase:OnExit()
end
function StateBase:GetType()
  return self.m_eType
end
return StateBase
