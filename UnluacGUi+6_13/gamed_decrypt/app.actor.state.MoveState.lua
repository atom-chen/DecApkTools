local StateBase = import(".StateBase")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local MoveState = class("MoveState", StateBase)
function MoveState:ctor(pStateManager, pActor)
  MoveState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.Move
  self.m_bStartMove = false
  self.m_bMoveOver = false
  self.m_findEnemyTime = 0.5
  self.m_findEnemyStartTime = 0
end
function MoveState:OnEnter()
  self.m_bStartMove = false
  self.m_bMoveOver = false
  self.m_findEnemyStartTime = 0
end
function MoveState:OnExit()
end
function MoveState:Update(dt)
  self.m_findEnemyStartTime = self.m_findEnemyStartTime + dt
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
  local pMap = GameDataManager:GetInstance():GetGameMap()
  if self.m_findEnemyStartTime >= self.m_findEnemyTime then
    if not ActorManager:GetInstance():UpdateFindEnemyCount(self.m_pActor:getTag()) then
      ActorManager:GetInstance():AddToWaitFindEnemyVec(self.m_pActor:getTag())
      return
    end
    self.m_findEnemyStartTime = 0
    if self.m_pActor:IsCanAttack() then
      local selfType = self.m_pActor:GetType()
      local mapType = pMap:GetMapType()
      if self.m_pActor:GetBehaveType() ~= td.BehaveType.Collect and (mapType == td.MapType.PVP or mapType == td.MapType.PVPGuild or selfType == td.ActorType.Soldier or selfType == td.ActorType.Monster) then
        local pEnemy = self.m_pActor:GetEnemy()
        if nil == pEnemy or not pEnemy:IsCanAttacked() or pEnemy:GetType() == td.ActorType.Home or pEnemy:GetType() == td.ActorType.FangYuTa then
          pEnemy = self.m_pActor:FindEnemy()
        end
        if pEnemy and pEnemy:IsCanAttacked() then
          if self.m_pActor:IsInAttackRange(pEnemy) then
            self.m_pActor:SetEnemy(pEnemy)
            if pMap:GetMapType() == td.MapType.Endless then
              self.m_pStateManager:ChangeState(td.StateType.Attack)
            else
              self.m_pStateManager:ChangeState(td.StateType.MoveToHole)
            end
            return
          end
          if self.m_pActor:GetBehaveType() ~= td.BehaveType.Collect then
            local enemyType = pEnemy:GetType()
            self.m_pActor:StopMove()
            self.m_pActor:SetEnemy(pEnemy)
            if enemyType == td.ActorType.Home then
              local enemyPos = cc.p(pEnemy:getPosition())
              self.m_pActor:SetTempTargetPos(enemyPos)
            else
              local enemyPos = cc.p(pEnemy:getPosition())
              self.m_pActor:SetTempTargetPos(enemyPos)
            end
            self.m_pStateManager:ChangeState(td.StateType.Track)
            return
          end
        end
      end
    end
  end
  if self.m_bMoveOver then
    self.m_pStateManager:ChangeState(td.StateType.Idle)
    require("app.trigger.TriggerManager"):GetInstance():SendEvent({
      eType = td.ConditionType.MonsterStop,
      monsterId = self.m_pActor:GetID(),
      pathId = self.m_pActor:GetPathId()
    })
    return
  end
  if not self.m_bStartMove then
    local pos = cc.p(self.m_pActor:GetTempTargetPos())
    local curPos = cc.p(self.m_pActor:getPosition())
    local vec
    if pMap:IsLineWalkable(cc.p(self.m_pActor:getPosition()), pos) then
      vec = {pos}
    elseif ActorManager:GetInstance():UpdateFindPathCount(self.m_pActor:getTag()) then
      vec = self.m_pActor:FindPath(pos)
    else
      ActorManager:GetInstance():AddToWaitFindPathVec(self.m_pActor:getTag())
      return
    end
    if #vec == 0 then
      if cc.pFuzzyEqual(pMap:GetTilePosFromPixelPos(pos), pMap:GetTilePosFromPixelPos(curPos), 0) and not cc.pFuzzyEqual(pos, curPos, 1) then
        table.insert(vec, pos)
        self.m_pActor:MoveAction(vec[1])
        self.m_pActor:SetPathList(vec, handler(self, self.MoveOver))
      elseif not pMap:IsWalkable(cc.p(pMap:GetTilePosFromPixelPos(curPos))) then
        local validPos = td.GetValidPos(pMap, self.m_pActor:GetCanMoveBlocks(), curPos)
        table.insert(vec, validPos)
        self.m_pActor:MoveAction(vec[1])
        self.m_pActor:SetPathList(vec, handler(self, self.MoveOver))
      else
        self.m_pStateManager:ChangeState(td.StateType.Idle)
        return
      end
    else
      self.m_pActor:MoveAction(vec[1])
      self.m_pActor:SetPathList(vec, handler(self, self.MoveOver))
    end
    self.m_bStartMove = true
  end
end
function MoveState:MoveOver()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local finalPos = cc.p(self.m_pActor:GetFinalTargetPos())
  local curPos = cc.p(self.m_pActor:getPosition())
  if cc.pFuzzyEqual(curPos, finalPos, 1) then
    self.m_bMoveOver = true
    local mapType = pMap:GetMapType()
    if self.m_pActor:GetBehaveType() == td.BehaveType.Collect then
      if self.m_pActor:GetType() == td.ActorType.Monster then
        self.m_pActor:SetRemove(true)
        self.m_pActor:OnDead()
      elseif self.m_pActor:GetType() == td.ActorType.Soldier then
        local path = self.m_pActor:GetPath()
        local bInverted = self.m_pActor:GetInverted()
        if bInverted then
          self.m_pActor:SetCurPathCount(1)
          self.m_pActor:SetFinalTargetPos(pMap:GetPixelPosFromTilePos(path[#path]))
          local GameDataManager = require("app.GameDataManager")
          local eType, iNum = self.m_pActor:HandinCollectionRes()
          if eType == td.ResourceType.ZiYuan then
          else
            GameDataManager:GetInstance():UpdateNeedResCount(eType, iNum)
          end
        else
          local ActorManager = require("app.actor.ActorManager")
          local vec = ActorManager:GetInstance():GetNeutralityVec()
          for i, v in pairs(vec) do
            if v:GetType() == td.ActorType.ShadeHole then
              local rect = {}
              local size = v:getContentSize()
              rect.x = v:getPositionX() - size.width / 2
              rect.y = v:getPositionY() - size.height / 2
              rect.width = size.width
              rect.height = size.height
              if cc.rectContainsPoint(rect, curPos) then
                self.m_pActor:SetCollectionRes(v:GetResourceType(), v:GetSingleNum())
                break
              end
            end
          end
          self.m_pActor:SetCurPathCount(#path)
          self.m_pActor:SetFinalTargetPos(pMap:GetPixelPosFromTilePos(path[1]))
        end
        self.m_pActor:SetInverted(not bInverted)
        return
      end
    end
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
return MoveState
