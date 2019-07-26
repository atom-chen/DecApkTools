local StateBase = import(".StateBase")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local IdleState = class("IdleState", StateBase)
function IdleState:ctor(pStateManager, pActor)
  IdleState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.Idle
  self.m_fStartTime = 0
  self.m_fSpaceTime = 0
  self.m_fStartChangeDirTime = 0
  self.m_fEndChangeDirTime = 0
  self.m_findEnemyTime = 0
  self.m_findEnemyStartTime = 0
end
function IdleState:OnEnter()
  self.m_fStartTime = 0
  self.m_fSpaceTime = 0.5
  self.m_fStartChangeDirTime = 0
  self.m_fEndChangeDirTime = 5
  self.m_pActor:StopMove()
  self.m_pActor:PlayAnimation("stand")
  self.m_findEnemyTime = math.random(1, 5) * 0.1
  self.m_findEnemyStartTime = 0
end
function IdleState:OnExit()
end
function IdleState:Update(dt)
  self.m_findEnemyStartTime = self.m_findEnemyStartTime + dt
  self.m_fStartChangeDirTime = self.m_fStartChangeDirTime + dt
  if self.m_pActor:IsDead() and self.m_pStateManager:ChangeState(td.StateType.Dead) then
    return
  end
  if self.m_pActor:IsHex() and self.m_pStateManager:ChangeState(td.StateType.Hex) then
    return
  end
  if self.m_pActor:IsTrapped() and self.m_pStateManager:ChangeState(td.StateType.Trapped) then
    return
  end
  if self.m_pActor:IsNothingnessState() then
    if self.m_pActor:GetSkillManager():HasSkillNoTarget() then
      self.m_pActor:GetSkillManager():SetCurrSkillNoTarget()
      self.m_pStateManager:ChangeState(td.StateType.Attack)
    end
    return
  end
  if self.m_fStartChangeDirTime >= self.m_fEndChangeDirTime then
    local dir = self.m_pActor:GetDirType()
    if dir == td.DirType.Left then
      self.m_pActor:SetDirType(td.DirType.Right)
    else
      self.m_pActor:SetDirType(td.DirType.Left)
    end
    self.m_fStartChangeDirTime = 0
    self.m_fEndChangeDirTime = 5 + math.random(5)
  end
  self.m_fStartTime = self.m_fStartTime + dt
  if self.m_fStartTime < self.m_fSpaceTime then
    return
  end
  local curPos = cc.p(self.m_pActor:getPosition())
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local mapType = pMap:GetMapType()
  if pMap:GetMapType() == td.MapType.PVP or pMap:GetMapType() == td.MapType.PVPGuild then
    local ActorManager = require("app.actor.ActorManager")
    local vec = {}
    local eGroupType = self.m_pActor:GetGroupType()
    if eGroupType == td.GroupType.Self then
      vec = ActorManager:GetInstance():GetSelfVec()
    else
      vec = ActorManager:GetInstance():GetEnemyVec()
    end
    for i, v in pairs(vec) do
      local pEnemy = v:GetEnemy()
      if pEnemy then
        local enemyPos = cc.p(pEnemy:getPosition())
        self.m_pActor:SetEnemy(pEnemy)
        self.m_pActor:SetTempTargetPos(enemyPos)
        self.m_pStateManager:ChangeState(td.StateType.Track)
        return
      end
    end
  elseif self.m_pActor:IsCanAttack() and self.m_pActor:GetBehaveType() ~= td.BehaveType.Collect and self.m_pActor:GetBehaveType() ~= td.BehaveType.UFO then
    local pEnemy = self.m_pActor:GetEnemy()
    if (nil == pEnemy or not pEnemy:IsCanAttacked() or pEnemy:GetType() == td.ActorType.Home or pEnemy:GetType() == td.ActorType.FangYuTa) and self.m_findEnemyStartTime >= self.m_findEnemyTime then
      if not ActorManager:GetInstance():UpdateFindEnemyCount(self.m_pActor:getTag()) then
        ActorManager:GetInstance():AddToWaitFindEnemyVec(self.m_pActor:getTag())
        return
      end
      self.m_findEnemyStartTime = 0
      pEnemy = self.m_pActor:FindEnemy()
    end
    if pEnemy and pEnemy:IsCanAttacked() then
      local enemyPos = cc.p(pEnemy:getPosition())
      self.m_pActor:SetEnemy(pEnemy)
      self.m_pActor:SetTempTargetPos(enemyPos)
      self.m_pStateManager:ChangeState(td.StateType.Track)
      return
    end
  end
  local nextPos, isTransfer = self.m_pActor:GetNextMovePos()
  if not cc.pFuzzyEqual(nextPos, cc.p(-1, -1), 0) and not cc.pFuzzyEqual(curPos, nextPos, 1) then
    self.m_pActor:SetTempTargetPos(nextPos)
    if isTransfer then
      self.m_pStateManager:ChangeState(td.StateType.Transfer)
      return
    end
    self.m_pStateManager:ChangeState(td.StateType.Move)
    return
  else
    self.m_fStartTime = 0
  end
end
return IdleState
