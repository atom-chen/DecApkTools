local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local ActorManager = require("app.actor.ActorManager")
local Charge = class("Charge", SkillBase)
Charge.ChargeSpeed = 400
Charge.HitBackSpeed = 600
Charge.HitBackDis = 200
function Charge:ctor(pActor, id, pData)
  Charge.super.ctor(self, pActor, id, pData)
  self.m_bIsExecuting = false
  self.m_hEndCallback = nil
  self.m_rushDir = cc.p(0, 0)
end
function Charge:Update(dt)
  Charge.super.Update(self, dt)
  if self.m_bIsExecuting then
    local enemy = self.m_pActor:GetEnemy()
    if enemy then
      local selfPos = cc.p(self.m_pActor:getPosition())
      local enemyPos = cc.p(enemy:getPosition())
      if cc.pDistanceSQ(selfPos, enemyPos) <= 2500 then
        self:Hit()
      end
    end
  end
end
function Charge:Execute(endCallback)
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  if self:IsTriggered() then
    self.m_fStartTime = 0
    local selfPos = cc.p(self.m_pActor:getPosition())
    local enemy = self.m_pActor:GetEnemy()
    local enemyPos = cc.p(enemy:getPosition())
    self.m_rushDir = cc.pNormalize(cc.pSub(enemyPos, selfPos))
    local rushTime = cc.pGetLength(cc.pSub(enemyPos, selfPos)) / Charge.ChargeSpeed
    local rushAct = cc.EaseSineInOut:create(cca.moveTo(rushTime, enemyPos.x, enemyPos.y))
    local callbackAct = cca.callFunc(function()
      self.m_bIsExecuting = false
      self:ExecuteOver()
      endCallback()
    end)
    self.m_pActor:runAction(cca.seq({rushAct, callbackAct}))
    local dirType = selfPos.x < enemyPos.x and td.DirType.Right or td.DirType.Left
    self.m_pActor:SetDirType(dirType)
    self.m_pActor:PlayAnimation(pData.skill_name, true)
    G_SoundUtil:PlaySound(301, false)
    self.m_bIsExecuting = true
    return true
  else
    endCallback()
    return false
  end
end
function Charge:Hit()
  if self.m_bIsExecuting then
    local enemy = self.m_pActor:GetEnemy()
    self:HitBack(enemy, Charge.HitBackDis)
    if td.HurtEnemy(td.CreateActorParams(self.m_pActor), enemy, self.m_iSkillRatio, self.m_iSkillFixed, self:IsMustHit()) then
      self:DidHit(enemy)
    end
    self.m_bIsExecuting = false
  end
end
function Charge:HitBack(pActor, offset)
  local selfPos = cc.p(self.m_pActor:getPosition())
  local enemyPos = cc.p(pActor:getPosition())
  local dir = cc.pNormalize(cc.pAdd(self.m_rushDir, cc.pSub(enemyPos, selfPos)))
  local pMap = require("app.GameDataManager"):GetInstance():GetGameMap()
  local backPos
  local dis = offset
  repeat
    dis = dis - 10
    backPos = cc.pAdd(enemyPos, cc.pMul(dir, dis))
  until pMap:IsWalkable(cc.p(pMap:GetTilePosFromPixelPos(backPos))) or dis <= 0
  pActor:stopActionByTag(td.HitBackActionTag)
  local hitbackAction = cca.moveTo(dis / Charge.HitBackSpeed, backPos.x, backPos.y)
  hitbackAction:setTag(td.HitBackActionTag)
  pActor:runAction(hitbackAction)
end
function Charge:IsTriggered()
  local supCondition = Charge.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local enemy = self.m_pActor:GetEnemy()
  if not enemy or not enemy:IsCanAttacked() then
    return false
  end
  if enemy:GetType() ~= td.ActorType.Hero and enemy:GetType() ~= td.ActorType.Soldier and enemy:GetType() ~= td.ActorType.Monster then
    return false
  end
  local selfPos = cc.p(self.m_pActor:getPosition())
  local enemyPos = cc.p(enemy:getPosition())
  local pMap = require("app.GameDataManager"):GetInstance():GetGameMap()
  if not pMap:IsLineWalkable(selfPos, enemyPos) then
    self.m_iCheckTime = 0
    return false
  end
  return true
end
return Charge
