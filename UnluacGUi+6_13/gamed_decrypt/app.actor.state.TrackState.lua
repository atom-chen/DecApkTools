local StateBase = import(".StateBase")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local TrackState = class("TrackState", StateBase)
function TrackState:ctor(pStateManager, pActor)
  TrackState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.Track
  self.m_bMoveOver = false
  self.m_bTrack = false
end
function TrackState:OnEnter()
  self.m_bMoveOver = false
  self.m_bTrack = false
end
function TrackState:OnExit()
end
function TrackState:Update(dt)
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
  if not pEnemy or not pEnemy:IsCanAttacked() or not self.m_pActor:IsInViewRange(pEnemy) then
    if pMap:GetMapType() ~= td.MapType.PVP and pMap:GetMapType() ~= td.MapType.PVPGuild then
      self.m_pActor:SetTempTargetPos(self.m_pActor:GetFinalTargetPos())
    end
    self.m_pActor:SetEnemy(nil)
    self.m_pStateManager:ChangeState(td.StateType.Move)
    return
  end
  if pEnemy and pEnemy:GetType() == td.ActorType.Home then
    local tempEnemy = self.m_pActor:FindEnemy(pEnemy)
    if tempEnemy and (not self.m_home or not self.m_home:IsInEllipse(cc.p(tempEnemy:getPosition()))) then
      local enemyPos = cc.p(tempEnemy:getPosition())
      local vec
      if pMap:IsLineWalkable(cc.p(self.m_pActor:getPosition()), enemyPos) then
        vec = {enemyPos}
      elseif ActorManager:GetInstance():UpdateFindPathCount(self.m_pActor:getTag()) then
        vec = self.m_pActor:FindPath(enemyPos)
      else
        ActorManager:GetInstance():AddToWaitFindPathVec(self.m_pActor:getTag())
        return
      end
      if #vec ~= 0 then
        self.m_pActor:SetEnemy(tempEnemy)
        self.m_pActor:SetTempTargetPos(enemyPos)
        self.m_bTrack = false
      end
    end
  end
  if self.m_pActor:IsInAttackRange(pEnemy) then
    if pMap:GetMapType() == td.MapType.Endless then
      self.m_pStateManager:ChangeState(td.StateType.Attack)
    else
      self.m_pStateManager:ChangeState(td.StateType.MoveToHole)
    end
    return
  end
  self.m_pActor:SetTempTargetPos(cc.p(pEnemy:getPosition()))
  if pEnemy and pEnemy ~= self.m_home and self.m_home and self.m_home:IsInEllipse(cc.p(pEnemy:getPosition())) then
    local tempEnemy = self.m_pActor:FindEnemy(pEnemy)
    if tempEnemy then
      self.m_bTrack = false
      self.m_bMoveOver = false
      self.m_pActor:SetEnemy(tempEnemy)
      self.m_pActor:SetTempTargetPos(cc.p(tempEnemy:getPosition()))
    else
      self.m_pActor:SetEnemy(nil)
      self.m_pStateManager:ChangeState(td.StateType.Move)
      return
    end
  end
  local pos = cc.p(self.m_pActor:GetTempTargetPos())
  local curPos = cc.p(self.m_pActor:getPosition())
  if cc.pFuzzyEqual(pos, curPos, 1) then
    if pMap:GetMapType() == td.MapType.Endless then
      self.m_pStateManager:ChangeState(td.StateType.Attack)
    else
      self.m_pStateManager:ChangeState(td.StateType.MoveToHole)
    end
    return
  end
  if pEnemy:GetType() == td.ActorType.Home and pEnemy:GetGroupType() == td.GroupType.Self then
    pMap:AddPassableRoadType(100)
  end
  local vec
  if pMap:IsLineWalkable(cc.p(self.m_pActor:getPosition()), pos) then
    vec = {pos}
  elseif ActorManager:GetInstance():UpdateFindPathCount(self.m_pActor:getTag()) then
    vec = self.m_pActor:FindPath(pos)
  else
    ActorManager:GetInstance():AddToWaitFindPathVec(self.m_pActor:getTag())
    return
  end
  if pEnemy:GetType() == td.ActorType.Home and pEnemy:GetGroupType() == td.GroupType.Self then
    pMap:RemovePassableRoadType(100)
  end
  if #vec == 0 then
    self.m_pActor:SetEnemy(nil)
    self.m_pStateManager:ChangeState(td.StateType.Idle)
    return
  else
    self.m_pActor:MoveAction(vec[1])
    self.m_pActor:SetPathList(vec, handler(self, self.MoveOver))
  end
end
function TrackState:MoveOver()
  self.m_bMoveOver = true
end
return TrackState
