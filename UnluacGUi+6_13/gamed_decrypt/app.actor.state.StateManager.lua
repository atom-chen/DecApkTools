local StateManager = class("StateManager")
StateManager.StateConfig = {
  [td.StatesType.Hero] = {
    0,
    1,
    2,
    3,
    4,
    6,
    7,
    8,
    10
  },
  [td.StatesType.Soldier] = {
    0,
    1,
    2,
    3,
    4,
    5,
    7,
    8,
    10,
    11
  },
  [td.StatesType.ResSoldier] = {
    0,
    1,
    2,
    3,
    4,
    5,
    7,
    10
  },
  [td.StatesType.Monster] = {
    0,
    1,
    2,
    3,
    4,
    5,
    7,
    8,
    10
  },
  [td.StatesType.ResMonster] = {
    0,
    4,
    5,
    9
  },
  [td.StatesType.Boss] = {
    0,
    1,
    2,
    3,
    4,
    5,
    7
  },
  [td.StatesType.BombMonster] = {
    0,
    1,
    4,
    7,
    10
  },
  [td.StatesType.Building] = {12, 13}
}
function StateManager:ctor(actor)
  self.m_pCurState = nil
  self.m_StateMap = {}
  self.m_pActor = actor
  self.m_bPause = false
  self.m_vHistory = {}
end
function StateManager:onCleanup()
  self.m_StateMap = {}
end
function StateManager:AddState(eType)
  local State
  if eType == td.StateType.Idle then
    State = require("app.actor.state.IdleState")
  elseif eType == td.StateType.Move then
    State = require("app.actor.state.MoveState")
  elseif eType == td.StateType.Track then
    State = require("app.actor.state.TrackState")
  elseif eType == td.StateType.Attack then
    State = require("app.actor.state.AttackState")
  elseif eType == td.StateType.Dead then
    State = require("app.actor.state.DeadState")
  elseif eType == td.StateType.Transfer then
    State = require("app.actor.state.TransferState")
  elseif eType == td.StateType.Magic then
    State = require("app.actor.state.MagicState")
  elseif eType == td.StateType.Trapped then
    State = require("app.actor.state.TrappedState")
  elseif eType == td.StateType.MoveToHole then
    State = require("app.actor.state.MoveToHoleState")
  elseif eType == td.StateType.MoveAttack then
    State = require("app.actor.state.MoveAttackState")
    eType = td.StateType.Move
  elseif eType == td.StateType.Hex then
    State = require("app.actor.state.HexState")
  elseif eType == td.StateType.Guard then
    State = require("app.actor.state.GuardState")
  elseif eType == td.StateType.BuildingIdle then
    State = require("app.actor.state.BuildingIdleState")
  elseif eType == td.StateType.BuildingAttack then
    State = require("app.actor.state.BuildingAttackState")
  else
    return
  end
  self.m_StateMap[eType] = State.new(self, self.m_pActor)
end
function StateManager:DelState(eType)
  self.m_StateMap[eType] = nil
end
function StateManager:AddStates(eType)
  local vStates = StateManager.StateConfig[eType]
  for key, stateType in ipairs(vStates) do
    self:AddState(stateType)
  end
end
function StateManager:ChangeState(eType)
  if self.m_StateMap[eType] == nil then
    return false
  end
  if self.m_pCurState and self.m_pCurState:GetType() == td.StateType.Dead and self.m_pActor:IsDead() then
    return false
  end
  if self.m_pCurState and self.m_pCurState:GetType() == td.StateType.Hex and self.m_pActor:IsHex() then
    return false
  end
  if nil ~= self.m_pCurState then
    self.m_pCurState:OnExit()
  end
  self.m_pCurState = self.m_StateMap[eType]
  self.m_pCurState:OnEnter()
  if td.Debug_Tag then
    table.insert(self.m_vHistory, eType)
  end
  return true
end
function StateManager:Update(dt)
  if self.m_pCurState == nil or self.m_bPause then
    return
  end
  self.m_pCurState:Update(dt)
end
function StateManager:GetCurState()
  return self.m_pCurState
end
function StateManager:SetPause(bPause)
  self.m_bPause = bPause
end
function StateManager:IsPause()
  return self.m_bPause
end
function StateManager:GetState(eType)
  return self.m_StateMap[eType]
end
return StateManager
