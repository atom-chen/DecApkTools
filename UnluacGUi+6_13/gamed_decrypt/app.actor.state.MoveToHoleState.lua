local StateBase = import(".StateBase")
local GameDataManager = require("app.GameDataManager")
local MoveToHoleState = class("MoveToHoleState", StateBase)
function MoveToHoleState:ctor(pStateManager, pActor)
  MoveToHoleState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.MoveToHole
  self.m_bStartMove = false
  self.m_bMoveOver = false
end
function MoveToHoleState:OnEnter()
  self.m_bStartMove = false
  self.m_bMoveOver = false
  self.m_pActor:StopMove()
end
function MoveToHoleState:OnExit()
end
function MoveToHoleState:Update(dt)
  if self.m_pActor.m_bDebug then
    local pause = 1
  end
  if self.m_pActor:IsNothingnessState() then
    self.m_pStateManager:ChangeState(td.StateType.Idle)
    return
  end
  if self.m_pActor:IsDead() and self.m_pStateManager:ChangeState(td.StateType.Dead) then
    return
  end
  if self.m_pActor:IsHex() and self.m_pStateManager:ChangeState(td.StateType.Hex) then
    return
  end
  if self.m_pActor:IsTrapped() and self.m_pStateManager:ChangeState(td.StateType.Trapped) then
    return
  end
  if self.m_bMoveOver then
    self.m_pStateManager:ChangeState(td.StateType.Attack)
    return
  end
  local pEnemy = self.m_pActor:GetEnemy()
  if not pEnemy or pEnemy:IsDead() or not pEnemy:IsCanAttacked() then
    self.m_pStateManager:ChangeState(td.StateType.Idle)
    return
  end
  if not self.m_bStartMove then
    local pMap = GameDataManager:GetInstance():GetGameMap()
    local pos = self.m_pActor:GetHole(pEnemy)
    local curPos = cc.p(self.m_pActor:getPosition())
    if cc.pFuzzyEqual(pos, curPos, 1) then
      self.m_pStateManager:ChangeState(td.StateType.Attack)
      return
    end
    local vec = {pos}
    self.m_pActor:MoveAction(vec[1])
    self.m_pActor:SetPathList(vec, handler(self, self.MoveOver))
    local lastTilePos = pMap:GetTilePosFromPixelPos(curPos)
    local tilePos = pMap:GetTilePosFromPixelPos(vec[#vec])
    GameDataManager:GetInstance():SetActorInTile(PulibcFunc:GetInstance():GetIntForPoint(lastTilePos), PulibcFunc:GetInstance():GetIntForPoint(tilePos), self.m_pActor)
    self.m_bStartMove = true
  end
end
function MoveToHoleState:MoveOver()
  local pEnemy = self.m_pActor:GetEnemy()
  if not pEnemy or pEnemy:IsDead() or not pEnemy:IsCanAttacked() then
    self.m_pStateManager:ChangeState(td.StateType.Idle)
    return
  end
  self.m_bMoveOver = true
end
return MoveToHoleState
