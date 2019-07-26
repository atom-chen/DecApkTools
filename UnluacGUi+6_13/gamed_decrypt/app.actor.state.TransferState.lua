local StateBase = import(".StateBase")
local TransferState = class("TransferState", StateBase)
function TransferState:ctor(pStateManager, pActor)
  TransferState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.Transfer
  self.m_fStartTime = 0
  self.m_fEndTime = 5
end
function TransferState:OnEnter()
  self.m_fStartTime = 0
  self.m_fEndTime = 5
  local pos = self.m_pActor:GetTempTargetPos()
  self.m_pActor:setPosition(pos)
  self.m_pActor:StopMove()
  self.m_pActor:SetEnemy(nil)
end
function TransferState:OnExit()
end
function TransferState:Update(dt)
  if self.m_pActor:IsDead() then
    self.m_pStateManager:ChangeState(td.StateType.Dead)
    return
  end
  self.m_fStartTime = self.m_fStartTime + dt
  if self.m_fStartTime < self.m_fEndTime then
    return
  end
  local curPos = cc.p(self.m_pActor:getPosition())
  local nextPos, isTransfer = self.m_pActor:GetNextMovePos()
  if not cc.pFuzzyEqual(nextPos, cc.p(-1, -1), 0) and not cc.pFuzzyEqual(curPos, nextPos, 1) then
    if isTransfer then
      self.m_pActor:setPosition(nextPos)
      self.m_fStartTime = 0
    else
      self.m_pActor:SetTempTargetPos(nextPos)
      self.m_pStateManager:ChangeState(td.StateType.Move)
    end
    return
  end
  self.m_pStateManager:ChangeState(td.StateType.Idle)
end
return TransferState
