local StateBase = import(".StateBase")
local BuildingAttackState = class("BuildingAttackState", StateBase)
function BuildingAttackState:ctor(pStateManager, pActor)
  BuildingAttackState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.BuildingAttack
  self.m_bActionOver = false
  self.m_bIsAttacking = false
  self.m_bFirstAttack = true
  self.m_fStartTime = 0
  self.m_didEnter = false
end
function BuildingAttackState:OnEnter()
  self.m_bActionOver = false
  self.m_bIsAttacking = false
  self.m_fStartTime = 0
  local pEnemy = self.m_pActor:GetEnemy()
  if pEnemy then
    self.m_pActor:SelectPriorSkill()
    self:Attack(pEnemy)
  end
  self.m_didEnter = true
  self.m_bFirstAttack = false
end
function BuildingAttackState:OnExit()
  self.m_didEnter = false
end
function BuildingAttackState:Update(dt)
  if not self.m_didEnter then
    return
  end
  if self.m_pActor:IsDead() then
    return
  end
  if not self.m_pActor:IsCanAttack() then
    self.m_pStateManager:ChangeState(td.StateType.BuildingIdle)
    return
  end
  if self.m_bActionOver then
    self.m_pStateManager:ChangeState(td.StateType.BuildingIdle)
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
  if nil == pEnemy or not pEnemy:IsCanAttacked() or not self.m_pActor:IsInAttackRange(pEnemy) then
    self.m_pActor:SetEnemy(nil)
    self.m_pStateManager:ChangeState(td.StateType.BuildingIdle)
    return
  end
  self:Attack(pEnemy)
end
function BuildingAttackState:Attack(pEnemy)
  local pSkill = self.m_pActor:GetCurSkill()
  if pSkill:IsTriggered() then
    self.m_bIsAttacking = true
    self.m_pActor:Skill(pSkill:GetID(), handler(self, self.ActionOver))
  end
end
function BuildingAttackState:ActionOver()
  if self.m_pActor:IsDead() then
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
        self.m_pStateManager:ChangeState(td.StateType.BuildingIdle)
        return
      end
    end
  end
  self.m_bActionOver = true
end
return BuildingAttackState
