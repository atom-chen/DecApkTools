local StateBase = import(".StateBase")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local GuardState = class("GuardState", StateBase)
function GuardState:ctor(pStateManager, pActor)
  GuardState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.Guard
  self.m_bMoveOver = false
  self.m_bTrack = false
end
function GuardState:OnEnter()
  self.m_bMoveOver = false
  self.m_bTrack = false
end
function GuardState:OnExit()
end
function GuardState:Update(dt)
  if self.m_pActor:IsDead() and self.m_pStateManager:ChangeState(td.StateType.Dead) then
    return
  end
  if self.m_pActor:IsHex() and self.m_pStateManager:ChangeState(td.StateType.Hex) then
    return
  end
  if self.m_pActor:IsTrapped() and self.m_pStateManager:ChangeState(td.StateType.Trapped) then
    return
  end
  local pMap = GameDataManager:GetInstance():GetGameMap()
  if not self.m_pActor:IsCanAttack() then
    self.m_pActor:SetEnemy(nil)
    self.m_pStateManager:ChangeState(td.StateType.Idle)
    return
  end
  local pEnemy = self.m_pActor:GetEnemy()
  if not pEnemy or not pEnemy:IsCanAttacked() then
    if pMap:GetMapType() ~= td.MapType.PVP and pMap:GetMapType() ~= td.MapType.PVPGuild then
      self.m_pActor:SetTempTargetPos(self.m_pActor:GetFinalTargetPos())
    end
    self.m_pActor:SetEnemy(nil)
    self.m_pStateManager:ChangeState(td.StateType.Move)
    return
  end
  if self.m_pActor:IsInAttackRange(pEnemy) then
    if pMap:GetMapType() == td.MapType.Endless then
      self.m_pStateManager:ChangeState(td.StateType.Attack)
    else
      self.m_pStateManager:ChangeState(td.StateType.MoveToHole)
    end
    return
  end
  if self.m_bTrack and self.m_bMoveOver then
    self.m_bTrack = false
    self.m_bMoveOver = false
    self.m_pActor:SetTempTargetPos(cc.p(pEnemy:getPosition()))
  end
  if not self.m_bTrack then
    local pos = cc.p(self.m_pActor:GetTempTargetPos())
    local curPos = cc.p(self.m_pActor:getPosition())
    if cc.pFuzzyEqual(pos, curPos, 0) then
      if pMap:GetMapType() == td.MapType.Endless then
        self.m_pStateManager:ChangeState(td.StateType.Attack)
      else
        self.m_pStateManager:ChangeState(td.StateType.MoveToHole)
      end
      return
    end
    local vec
    if ActorManager:GetInstance():UpdateFindPathCount(self.m_pActor:getTag()) then
      vec = self.m_pActor:FindPath(pos)
    else
      ActorManager:GetInstance():AddToWaitFindPathVec(self.m_pActor:getTag())
      return
    end
    if #vec == 0 then
      self.m_pActor:SetEnemy(nil)
      self.m_pStateManager:ChangeState(td.StateType.Idle)
      return
    else
      self.m_pActor:MoveAction(vec[1])
      self.m_pActor:SetPathList(vec, handler(self, self.MoveOver))
    end
    self.m_bTrack = true
  end
end
function GuardState:MoveOver()
  self.m_bMoveOver = true
end
return GuardState
