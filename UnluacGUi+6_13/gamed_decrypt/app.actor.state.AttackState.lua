local StateBase = import(".StateBase")
local AttackState = class("AttackState", StateBase)
function AttackState:ctor(pStateManager, pActor)
  AttackState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.Attack
  self.m_bActionOver = false
  self.m_bIsAttacking = false
  self.m_bFirstAttack = true
  self.m_fStartTime = 0
  self.m_didEnter = false
end
function AttackState:OnEnter()
  self.m_bActionOver = false
  self.m_bIsAttacking = false
  self.m_fStartTime = 0
  self.m_pActor:StopMove()
  local pEnemy = self.m_pActor:GetEnemy()
  self.m_pActor:BeforeAttack(function()
    if pEnemy then
      self.m_pActor:SelectPriorSkill()
      self:Attack(pEnemy)
    end
    self.m_didEnter = true
  end)
  self.m_bFirstAttack = false
end
function AttackState:OnExit()
  self.m_didEnter = false
end
function AttackState:ChangeToState(iState)
  if iState == td.StateType.Dead or iState == td.StateType.Trapped or iState == td.StateType.Hex then
    if self.m_pStateManager:ChangeState(iState) then
      self.m_didEnter = false
    else
      return false
    end
  else
    self.m_didEnter = false
    self.m_pActor:AfterAttack(function()
      if not self.m_pStateManager:ChangeState(iState) then
        self.m_didEnter = true
      end
    end)
  end
  return true
end
function AttackState:Update(dt)
  if not self.m_didEnter then
    return
  end
  if self.m_pActor:IsDead() and self:ChangeToState(td.StateType.Dead) then
    return
  end
  if self.m_pActor:IsHex() and self:ChangeToState(td.StateType.Hex) then
    return
  end
  if self.m_pActor:IsTrapped() and self:ChangeToState(td.StateType.Trapped) then
    return
  end
  if not self.m_pActor:IsCanAttack() then
    self:ChangeToState(td.StateType.Idle)
    return
  end
  if self.m_bActionOver then
    self:ChangeToState(td.StateType.Idle)
    return
  end
  if self.m_bIsAttacking then
    return
  end
  self.m_fStartTime = self.m_fStartTime + dt
  if self.m_fStartTime < self.m_pActor:GetAttackSpeed() then
    return
  else
    self.m_fStartTime = 0
  end
  local curSkill = self.m_pActor:GetCurSkill()
  if curSkill and self.m_pActor:GetSkillManager():IsSkillNoTarget(curSkill) then
    self:Attack()
    return
  end
  local pEnemy = self.m_pActor:GetEnemy()
  if nil == pEnemy or not pEnemy:IsCanAttacked() then
    self.m_pActor:SetEnemy(nil)
    self:ChangeToState(td.StateType.Idle)
    return
  end
  if not self.m_pActor:IsInAttackRange(pEnemy) then
    local enemyPos = cc.p(pEnemy:getPosition())
    self.m_pActor:SetTempTargetPos(enemyPos)
    self:ChangeToState(td.StateType.Track)
    return
  end
  self:Attack(pEnemy)
end
function AttackState:Attack(pEnemy)
  local pSkill = self.m_pActor:GetCurSkill()
  if pSkill:IsTriggered() then
    self.m_bIsAttacking = true
    self.m_pActor:Skill(pSkill:GetID(), handler(self, self.ActionOver))
    if pEnemy then
      local pos = cc.p(pEnemy:getPosition())
      local curPos = cc.p(self.m_pActor:getPosition())
      if pos.x >= curPos.x then
        self.m_pActor:SetDirType(td.DirType.Right)
      else
        self.m_pActor:SetDirType(td.DirType.Left)
      end
    end
  end
end
function AttackState:ActionOver()
  if self.m_pActor:IsDead() or self.m_pActor:IsTrapped() or self.m_pActor:IsHex() then
    return
  end
  local curSkill = self.m_pActor:GetCurSkill()
  if curSkill and curSkill:GetType() == td.SkillType.Normal then
    local pEnemy = self.m_pActor:GetEnemy()
    if not pEnemy or not pEnemy:IsCanAttacked() or pEnemy:GetType() == td.ActorType.Home or pEnemy:GetType() == td.ActorType.FangYuTa then
      pEnemy = self.m_pActor:FindEnemy()
    end
    if pEnemy and pEnemy:IsCanAttacked() then
      self.m_pActor:SetEnemy(pEnemy)
      if self.m_pActor:IsInAttackRange(pEnemy) then
        self.m_bActionOver = false
        self.m_bIsAttacking = false
        return
      else
        local enemyPos = cc.p(pEnemy:getPosition())
        self.m_pActor:SetTempTargetPos(enemyPos)
        self:ChangeToState(td.StateType.Track)
        return
      end
    end
  end
  self.m_bActionOver = true
end
return AttackState
