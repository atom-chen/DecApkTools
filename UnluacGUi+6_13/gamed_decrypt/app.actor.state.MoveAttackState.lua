local StateBase = import(".StateBase")
local GameDataManager = require("app.GameDataManager")
local MoveAttackState = class("MoveAttackState", StateBase)
function MoveAttackState:ctor(pStateManager, pActor)
  MoveAttackState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.MoveAttack
  self.m_fStartTime = 0
  self.m_bStartMove = false
  self.m_bMoveOver = false
end
function MoveAttackState:OnEnter()
  self.m_fStartTime = 0
  self.m_bStartMove = false
  self.m_bMoveOver = false
  local curPos = cc.p(self.m_pActor:getPosition())
  local nextPos, isTransfer = self.m_pActor:GetNextMovePos()
  if not cc.pFuzzyEqual(nextPos, cc.p(-1, -1), 0) and not cc.pFuzzyEqual(curPos, nextPos, 1) then
    self.m_pActor:SetTempTargetPos(nextPos)
  end
end
function MoveAttackState:OnExit()
  self.m_pActor:SetEnemy(nil)
end
function MoveAttackState:Update(dt)
  if self.m_pActor:IsNothingnessState() then
    self.m_pStateManager:ChangeState(td.StateType.Idle)
    return
  end
  if self.m_pActor:IsDead() then
    self.m_pStateManager:ChangeState(td.StateType.Dead)
    return
  end
  if self.m_bMoveOver then
    self.m_pActor:SetRemove(true)
    return
  end
  if not self.m_bStartMove then
    local pos = cc.p(self.m_pActor:GetTempTargetPos())
    local curPos = cc.p(self.m_pActor:getPosition())
    local vec = self.m_pActor:FindPath(pos)
    if #vec == 0 then
      local pMap = GameDataManager:GetInstance():GetGameMap()
      if cc.pFuzzyEqual(pMap:GetTilePosFromPixelPos(pos), pMap:GetTilePosFromPixelPos(curPos), 0) and not cc.pFuzzyEqual(pos, curPos, 1) then
        table.insert(vec, pos)
        self.m_pActor:MoveAction(vec[1])
        self.m_pActor:SetPathList(vec, handler(self, self.MoveOver))
      else
        self:MoveOver()
      end
    else
      self.m_pActor:MoveAction(vec[1])
      self.m_pActor:SetPathList(vec, handler(self, self.MoveOver))
    end
    self.m_bStartMove = true
  end
  if self.m_fStartTime < self.m_pActor:GetAttackSpeed() then
    self.m_fStartTime = self.m_fStartTime + dt
    return
  end
  local pEnemy = self.m_pActor:GetEnemy()
  if nil == pEnemy or not pEnemy:IsCanAttacked() or pEnemy:GetType() == td.ActorType.Home or pEnemy:GetType() == td.ActorType.FangYuTa or not self.m_pActor:IsInAttackRange(pEnemy) then
    pEnemy = self.m_pActor:FindEnemy()
  end
  if pEnemy and pEnemy:IsCanAttacked() and self.m_pActor:IsInAttackRange(pEnemy) then
    self:Attack(pEnemy)
    self.m_fStartTime = 0
  end
end
function MoveAttackState:MoveOver()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local finalPos = cc.p(self.m_pActor:GetFinalTargetPos())
  local curPos = cc.p(self.m_pActor:getPosition())
  if cc.pFuzzyEqual(curPos, finalPos, 1) then
    self.m_bMoveOver = true
    return
  end
  local nextPos, isTransfer = self.m_pActor:GetNextMovePos()
  if not cc.pFuzzyEqual(nextPos, cc.p(-1, -1), 0) and not cc.pFuzzyEqual(curPos, nextPos, 1) then
    self.m_pActor:SetTempTargetPos(nextPos)
    if isTransfer then
      self.m_pStateManager:ChangeState(td.StateType.Transfer)
      return
    end
    self.m_bStartMove = false
    return
  end
  self.m_bMoveOver = true
end
function MoveAttackState:Attack(pEnemy)
  local pSkill = self.m_pActor:GetCurSkill()
  if pSkill:IsTriggered() then
    self.m_pActor:Skill(pSkill:GetID())
    local pos = cc.p(pEnemy:getPosition())
    local curPos = cc.p(self.m_pActor:getPosition())
    if pos.x >= curPos.x then
      self.m_pActor:SetDirType(td.DirType.Right)
    else
      self.m_pActor:SetDirType(td.DirType.Left)
    end
  end
  self.m_pActor:SetEnemy(pEnemy)
end
return MoveAttackState
