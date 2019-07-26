local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local BuffManager = require("app.buff.BuffManager")
local BlinkStrike = class("BlinkStrike", SkillBase)
function BlinkStrike:ctor(pActor, id, pData)
  BlinkStrike.super.ctor(self, pActor, id, pData)
  self.m_pTarget = nil
  self.m_vBuffs = {}
end
function BlinkStrike:Update(dt)
  BlinkStrike.super.Update(self, dt)
end
function BlinkStrike:Execute(endCallback)
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  if self.m_pTarget and self.m_pTarget:IsCanAttacked() then
    self.m_fStartTime = 0
    self.m_pActor:SetEnemy(self.m_pTarget)
    do
      local selfPos = cc.p(self.m_pActor:getPosition())
      local enemyPos = cc.p(self.m_pTarget:getPosition())
      local dirType = selfPos.x < enemyPos.x and td.DirType.Right or td.DirType.Left
      self.m_pActor:SetDirType(dirType)
      for i, v in ipairs(pData.get_buff_id) do
        local buff = BuffManager:GetInstance():AddBuff(self.m_pActor, v, nil)
        if buff then
          table.insert(self.m_vBuffs, buff)
        end
      end
      local hurtPos = self.m_pActor:FindBonePos("bone_beiji")
      local pMap = GameDataManager:GetInstance():GetGameMap()
      pMap:runAction(cca.seq({
        cca.cb(function()
          local effectPos = selfPos
          local moveEffect = EffectManager:GetInstance():CreateEffect(self.m_atkEffect, self.m_pActor, nil, effectPos)
          moveEffect:AddToMap(pMap)
        end),
        cca.delay(0.2),
        cca.cb(function()
          self.m_pActor:setVisible(false)
        end),
        cca.delay(0.5),
        cca.cb(function()
          local targetPos = self:GetAttackPos(cc.p(self.m_pTarget:getPosition()), 30)
          local effectPos = targetPos
          local moveEffect = EffectManager:GetInstance():CreateEffect(self.m_atkEffect, self.m_pActor, nil, effectPos)
          moveEffect:AddToMap(pMap)
          self.m_pActor:setPosition(targetPos)
        end),
        cca.delay(0.3),
        cca.cb(function()
          local dirType = selfPos.x < enemyPos.x and td.DirType.Right or td.DirType.Left
          self.m_pActor:SetDirType(dirType)
          self.m_pActor:setVisible(true)
          self:ClearBuffs()
          if td.HurtEnemy(td.CreateActorParams(self.m_pActor), self.m_pTarget, self.m_iSkillRatio, self.m_iSkillFixed, self:IsMustHit()) then
            self:DidHit(self.m_pTarget)
          end
          self.m_pTarget = nil
          endCallback()
          self:ExecuteOver()
        end)
      }))
    end
  else
    endCallback()
    self.m_pTarget = nil
  end
end
function BlinkStrike:IsTriggered()
  local supCondition = BlinkStrike.super.IsTriggered(self)
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
function BlinkStrike:GetAttackPos(enemyPos, radius)
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
function BlinkStrike:FindTarget()
  local ActorManager = require("app.actor.ActorManager")
  local vec = {}
  local eGroupType = self.m_pActor:GetGroupType()
  if eGroupType == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetEnemyVec()
  else
    vec = ActorManager:GetInstance():GetSelfVec()
  end
  local selfPos = cc.p(self.m_pActor:getPosition())
  local iIndex = 0
  local pMap = GameDataManager:GetInstance():GetGameMap()
  for i, v in pairs(vec) do
    if self.m_pActor ~= v then
      local enemyType = v:GetCareerType()
      if (enemyType == td.CareerType.Archer or enemyType == td.CareerType.Caster) and v:IsCanAttacked() and cc.pDistanceSQ(selfPos, cc.p(v:getPosition())) <= self.m_iAtkRangeSQ then
        iIndex = i
        break
      end
    end
  end
  if iIndex > 0 then
    return vec[iIndex]
  end
  return nil
end
function BlinkStrike:ClearBuffs(enemyPos, radius)
  for i, buff in ipairs(self.m_vBuffs) do
    buff:SetRemove()
  end
  self.m_vBuffs = {}
end
return BlinkStrike
