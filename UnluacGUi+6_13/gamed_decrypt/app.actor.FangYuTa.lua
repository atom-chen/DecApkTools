local ActorBase = import(".ActorBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local GameDataManager = require("app.GameDataManager")
local BaseInfoManager = require("app.info.BaseInfoManager")
local StateManager = require("app.actor.state.StateManager")
local SkillManager = require("app.actor.skill.SkillManager")
local FangYuTa = class("FangYuTa", ActorBase)
function FangYuTa:ctor(eType, pData, bIsEnemy)
  FangYuTa.super.ctor(self, eType, pData.image)
  self.m_pCurSkill = nil
  self.m_iMaxHp = 0
  self.m_iCurHp = 0
  self.m_iAttack = 0
  self.m_fStartTime = 0
  self:SetData(pData, bIsEnemy)
end
function FangYuTa:onEnter()
  FangYuTa.super.onEnter(self)
  self:CreateHPBar()
  self:InitState()
  self:InitSkill()
end
function FangYuTa:onExit()
  FangYuTa.super.onExit(self)
end
function FangYuTa:InitState()
  self.m_pStateManager = StateManager.new(self)
  self.m_pStateManager:AddStates(td.StatesType.Building)
  self.m_pStateManager:ChangeState(td.StateType.BuildingIdle)
end
function FangYuTa:InitSkill()
  self.m_pSkillManager = SkillManager.new(self)
  for i, v in ipairs(self.m_pData.skill) do
    if v ~= 0 then
      self.m_pSkillManager:AddSkill(v)
    end
  end
  self.m_pSkillManager:OnEnter()
end
function FangYuTa:Update(dt)
  FangYuTa.super.Update(self, dt)
  if self:IsDead() then
    return
  end
  self.m_pSkillManager:Update(dt)
  self.m_pStateManager:Update(dt)
end
function FangYuTa:CreateHPBar()
  local height = self.m_pSkeleton:GetContentSize().height
  local BloodBar = require("app.widgets.BloodBar")
  self.m_pHpBar = BloodBar.new(1, self.m_eGroupType)
  self.m_pHpBar:setScale(self.m_pHpBar:getScale() / self:getScale())
  self.m_pHpBar:setPosition(cc.p(0, height))
  self:addChild(self.m_pHpBar, 1)
end
function FangYuTa:ChangeHp(iHp)
  self.m_iCurHp = cc.clampf(self.m_iCurHp + iHp, 0, self:GetMaxHp())
  if self.m_iCurHp <= 0 then
    self:OnDead()
    td.dispatchEvent(td.ACTOR_DIED, self:getTag())
  end
  self.m_pHpBar:SetPercentage(self:GetCurHp() / self:GetMaxHp() * 100)
end
function FangYuTa:OnDead()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local mapType = pMap:GetMapType()
  local groupType = self:GetRealGroupType()
  if groupType == td.GroupType.Enemy then
  end
  self.m_bAttacked = false
  local pEffect = require("app.effect.EffectManager"):GetInstance():CreateEffect(2063)
  local effectPos = cc.pAdd(cc.p(self:getPosition()), cc.p(self:getContentSize().width / 2, -self:getContentSize().height * 0.25))
  pEffect:setPosition(effectPos)
  pEffect:AddToMap(pMap)
  self:PlayAnimation("fangyuta_02", false, callFunc, sp.EventType.ANIMATION_COMPLETE)
end
function FangYuTa:IsInViewRange(pEnemy)
  local pos, enemyPos = cc.p(self:getPosition()), cc.p(pEnemy:getPosition())
  return self:IsInAttackRange(pEnemy), cc.pDistanceSQ(pos, enemyPos)
end
function FangYuTa:IsInAttackRange(pEnemy)
  local curPos = cc.p(self:getPosition())
  return self:IsInAttackRangeForPos(pEnemy, curPos)
end
function FangYuTa:IsInAttackRangeForPos(pEnemy, pos)
  if not pEnemy then
    return false
  end
  self:SelectPriorSkill()
  local pSkill = self:GetCurSkill()
  local iRange = pSkill:GetAttackRange()
  local enemyPos = cc.p(pEnemy:getPosition())
  if pEnemy:GetType() == td.ActorType.Home then
    if pEnemy:GetGroupType() == td.GroupType.Self then
      local center = pEnemy:GetCenterPos()
      local isIn = IsCircleAndEllipseCross(center.x, center.y, pEnemy:GetEllipseSize().width / 2, pEnemy:GetEllipseSize().height / 2, pos.x, pos.y, iRange)
      return isIn
    else
      local size = pEnemy:getContentSize()
      local isIn = IsRectAndCircleCross(pos.x, pos.y, iRange, enemyPos.x, enemyPos.y, size.width, size.height)
      return isIn
    end
  elseif cc.pDistanceSQ(pos, enemyPos) <= iRange * iRange then
    return true
  end
  return false
end
function FangYuTa:SetData(pData, bIsEnemy)
  self.m_pData = clone(pData)
  local mapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  local level = 1
  if bIsEnemy then
    if mapInfo.type == td.MapType.Rob then
      level = GameDataManager:GetInstance():GetRobData().level
    else
      self.m_iMaxHp = mapInfo.enemy_tower_hp * 0.5
      self.m_iCurHp = self.m_iMaxHp
      self.m_iAttack = mapInfo.enemy_tower_hp * 0.025
      return
    end
  else
    level = GameDataManager:GetInstance():GetHomeLevel()
  end
  self.m_iMaxHp = td.CalculateTowerHp(level, bIsEnemy)
  self.m_iCurHp = self.m_iMaxHp
  self.m_iAttack = td.CalculateTowerAttack(level, bIsEnemy)
end
function FangYuTa:GetData()
  return self.m_pData
end
function FangYuTa:GetAttackSpeed()
  return self.m_pData.attack_speed
end
function FangYuTa:IsDead()
  return self.m_iCurHp <= 0
end
function FangYuTa:SetCurHp(iHp)
  self.m_iCurHp = iHp
end
function FangYuTa:GetCurHp()
  return self.m_iCurHp
end
function FangYuTa:GetMaxHp()
  return self.m_iMaxHp
end
function FangYuTa:GetAttackValue()
  return self.m_iAttack
end
function FangYuTa:GetDefense()
  return self.m_pData.def
end
function FangYuTa:GetSuckHp()
  return 0
end
function FangYuTa:GetReflect(careerType)
  return 0
end
function FangYuTa:IsCanBuffed()
  return false
end
function FangYuTa:IsCanBeMoved()
  return false
end
function FangYuTa:GetSkillManager()
  return self.m_pSkillManager
end
function FangYuTa:Skill(id, endCallback)
  self.m_pSkillManager:Skill(id, endCallback)
end
function FangYuTa:SelectPriorSkill()
  self.m_pSkillManager:SelectPriorSkill()
end
function FangYuTa:SetCurSkill(id)
  if self:IsDead() then
    return
  end
  self.m_iCurSkillID = id
end
function FangYuTa:GetCurSkill()
  return self.m_pSkillManager:GetSkill(self.m_iCurSkillID)
end
return FangYuTa
