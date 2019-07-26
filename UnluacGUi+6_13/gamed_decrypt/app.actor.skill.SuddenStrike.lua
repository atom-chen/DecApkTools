local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local BuffManager = require("app.buff.BuffManager")
local SuddenStrike = class("SuddenStrike", SkillBase)
function SuddenStrike:ctor(pActor, id, pData)
  SuddenStrike.super.ctor(self, pActor, id, pData)
  self.m_pTarget = nil
  self.m_shadowId = id == 1012 and 1001 or 1031
  self.m_vBuffs = {}
end
function SuddenStrike:Update(dt)
  SuddenStrike.super.Update(self, dt)
end
function SuddenStrike:Execute(endCallback)
  if self.m_pTarget and self.m_pTarget:IsCanAttacked() then
    self.m_fStartTime = 0
    self.m_pActor:SetEnemy(self.m_pTarget)
    do
      local selfPos = cc.p(self.m_pActor:getPosition())
      local enemyPos = cc.p(self.m_pTarget:getPosition())
      local aniNames = string.split(self.m_pData.skill_name, ";")
      local dirType = selfPos.x < enemyPos.x and td.DirType.Right or td.DirType.Left
      self.m_pActor:SetDirType(dirType)
      self.m_pActor:PlayAnimation(aniNames[1])
      for i, v in ipairs(self.m_pData.get_buff_id) do
        local buff = BuffManager:GetInstance():AddBuff(self.m_pActor, v, nil)
        if buff then
          table.insert(self.m_vBuffs, buff)
        end
      end
      local shadowEffect = EffectManager:GetInstance():CreateEffect(self.m_shadowId, self.m_pActor, nil)
      local pMap = GameDataManager:GetInstance():GetGameMap()
      shadowEffect:AddToMap(pMap)
      local targetPos = self:GetAttackPos(enemyPos, 30)
      local rushTime = cc.pGetLength(cc.pSub(targetPos, selfPos)) / 600
      local rushAct = cc.EaseSineInOut:create(cca.moveTo(rushTime, targetPos.x, targetPos.y))
      local callbackAct = cca.callFunc(function()
        shadowEffect:SetRemove()
        local dir = self.m_pActor:getPositionX() < enemyPos.x and td.DirType.Right or td.DirType.Left
        self.m_pActor:SetDirType(dir)
        self.m_pActor:PlayAnimation(aniNames[2], false, function(event)
          if self.m_pTarget and not self.m_pTarget:IsDead() then
            for i, v in ipairs(self.m_pData.buff_id[1]) do
              BuffManager:GetInstance():AddBuff(self.m_pTarget, v, nil)
            end
          end
          for i, buff in ipairs(self.m_vBuffs) do
            buff:SetRemove()
          end
          self.m_vBuffs = {}
          if td.HurtEnemy(td.CreateActorParams(self.m_pActor), enemy, self.m_iSkillRatio, self.m_iSkillFixed, self:IsMustHit()) then
            self:DidHit(enemy)
          end
          self.m_pTarget = nil
          endCallback()
          self:ExecuteOver()
        end, sp.EventType.ANIMATION_COMPLETE)
      end)
      self.m_pActor:runAction(cca.seq({rushAct, callbackAct}))
      G_SoundUtil:PlaySound(201, false)
      self:ShowSkillName()
    end
  else
    endCallback()
    self.m_pTarget = nil
  end
end
function SuddenStrike:IsTriggered()
  local supCondition = SuddenStrike.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local enemy = self.m_pActor:GetEnemy()
  if enemy then
    if enemy:GetCareerType() == td.CareerType.Archer or enemy:GetCareerType() == td.CareerType.Caster then
      self.m_pTarget = enemy
      return true
    end
    if not self.m_pActor:IsTaunted() then
      enemy = self:FindTarget()
      if enemy then
        self.m_pTarget = enemy
        return true
      end
    end
  end
  self.m_iCheckTime = 0
  return false
end
function SuddenStrike:GetAttackPos(enemyPos, radius)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local selfPos = cc.p(self.m_pActor:getPosition())
  local pos = enemyPos
  local param
  if selfPos.x < enemyPos.x then
    param = {0, 180}
  else
    param = {180, 0}
  end
  for n = 1, #param do
    for i = 0, 120, 10 do
      local randAngle = math.random(120) - 60 + param[n]
      pos = cc.p(enemyPos.x + radius * math.cos(math.rad(randAngle)), enemyPos.y + radius * math.sin(math.rad(randAngle)))
      if 0 < #pMap:FindPath(selfPos, pos) then
        return pos
      end
    end
  end
  return pos
end
function SuddenStrike:FindTarget()
  local ActorManager = require("app.actor.ActorManager")
  local vEnemy = {}
  local eGroupType = self.m_pActor:GetGroupType()
  if eGroupType == td.GroupType.Self then
    vEnemy = ActorManager:GetInstance():GetEnemyVec()
  else
    vEnemy = ActorManager:GetInstance():GetSelfVec()
  end
  local minDis = -1
  local iIndex = 0
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local targets = {}
  for i, enemy in pairs(vEnemy) do
    if self.m_pActor ~= enemy then
      local enemyType = enemy:GetCareerType()
      if (enemyType == td.CareerType.Archer or enemyType == td.CareerType.Caster) and enemy:IsCanAttacked() then
        local enemyPos = cc.p(enemy:getPosition())
        local selfPos = cc.p(self.m_pActor:getPosition())
        if cc.pDistanceSQ(selfPos, enemyPos) <= self.m_iAtkRangeSQ and pMap:IsLineWalkable(selfPos, enemyPos) then
          table.insert(targets, enemy)
        end
      end
    end
  end
  if #targets > 1 then
    return targets[math.random(#targets)]
  elseif #targets == 1 then
    return targets[1]
  end
  return nil
end
return SuddenStrike
