local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local BuffManager = require("app.buff.BuffManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local EffectManager = require("app.effect.EffectManager")
local HitBackShort = class("HitBackShort", SkillBase)
HitBackShort.Condition = {
  0.8,
  0.5,
  0.2
}
HitBackShort.HitGap = 0.5
HitBackShort.HitTime = 5
HitBackShort.HitDis = 160
function HitBackShort:ctor(pActor, id, pData)
  HitBackShort.super.ctor(self, pActor, id, pData)
  self.m_iLastHp = 1
  self.m_iTimeInterval = HitBackShort.HitGap
  self.m_iTime = 0
  self.m_bIsExecuting = false
  self.m_pHitEffect = nil
  self.m_pFireEffect = nil
  self.m_soundHandle = nil
  self.m_hEndCallback = nil
  self.m_vBuffs = {}
end
function HitBackShort:Update(dt)
  HitBackShort.super.Update(self, dt)
  if self.m_bIsExecuting then
    if self.m_pActor:IsDead() then
      self:ExecuteOver()
      return
    end
    self.m_iTimeInterval = self.m_iTimeInterval + dt
    if self.m_iTimeInterval >= HitBackShort.HitGap then
      self.m_pHitEffect:GetContentNode():PlayAni("animation", false)
      local vActors = self:GetActorsInRange()
      for i, actor in ipairs(vActors) do
        self:Hit(actor)
      end
      self.m_iTime = self.m_iTime + HitBackShort.HitGap
      if self.m_iTime >= HitBackShort.HitTime then
        self:ExecuteOver()
        self.m_iTime = 0
      else
        self.m_iTimeInterval = 0
      end
    end
  end
end
function HitBackShort:Execute(endCallback)
  self.m_fStartTime = 0
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  self.m_pActor:PlayAnimation(pData.skill_name, true)
  self.m_bIsExecuting = true
  self.m_hEndCallback = endCallback
  local buffIds = pData.get_buff_id
  for i, v in ipairs(buffIds) do
    local buff = BuffManager:GetInstance():AddBuff(self.m_pActor, v, nil)
    if buff then
      table.insert(self.m_vBuffs, buff)
    end
  end
  self.m_pFireEffect = EffectManager:GetInstance():CreateEffect(128)
  self.m_pFireEffect:AddToActor(self.m_pActor)
  self.m_pHitEffect = EffectManager:GetInstance():CreateEffect(129, self.m_pActor, nil, cc.p(self.m_pActor:getPosition()))
  local scaleX = self.m_pActor:GetDirType()
  self.m_pHitEffect:setScaleX(self.m_pHitEffect:getScaleX() * scaleX)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  self.m_pHitEffect:AddToMap(pMap)
  self.m_soundHandle = G_SoundUtil:PlaySound(106, true)
  return true
end
function HitBackShort:ExecuteOver()
  HitBackShort.super.ExecuteOver(self)
  if self.m_hEndCallback then
    self.m_hEndCallback()
    self.m_hEndCallback = nil
  end
  self.m_pFireEffect:SetRemove()
  self.m_pFireEffect = nil
  self.m_pHitEffect:SetRemove()
  self.m_pHitEffect = nil
  self.m_bIsExecuting = false
  self.m_iLastHp = self.m_pActor:GetCurHp() / self.m_pActor:GetMaxHp()
  for key, buff in ipairs(self.m_vBuffs) do
    buff:SetRemove()
  end
  self.m_vBuffs = {}
  if self.m_soundHandle then
    G_SoundUtil:StopSound(self.m_soundHandle)
    self.m_soundHandle = nil
  end
end
function HitBackShort:IsTriggered()
  local supCondition = HitBackShort.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  if self.m_pActor:GetType() == td.ActorType.Monster then
    local curHp = self.m_pActor:GetCurHp() / self.m_pActor:GetMaxHp()
    for key, var in ipairs(HitBackShort.Condition) do
      if var <= self.m_iLastHp and var > curHp then
        return true
      end
    end
    return false
  end
  return true
end
function HitBackShort:GetActorsInRange()
  local vActors = {}
  local selfPos = cc.p(self.m_pActor:getPosition())
  local hitDisSQ = HitBackShort.HitDis * HitBackShort.HitDis
  local dirType = self.m_pActor:GetDirType()
  local vec = {}
  if self.m_pActor:GetGroupType() == td.GroupType.Enemy then
    vec = ActorManager:GetInstance():GetSelfVec()
  elseif self.m_pActor:GetGroupType() == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetEnemyVec()
  end
  for tag, actor in pairs(vec) do
    local enemyPos = cc.p(actor:getPosition())
    if (dirType == td.DirType.Left and enemyPos.x < selfPos.x or dirType == td.DirType.Right and enemyPos.x > selfPos.x) and hitDisSQ > cc.pDistanceSQ(selfPos, enemyPos) then
      table.insert(vActors, actor)
    end
  end
  return vActors
end
function HitBackShort:Hit(pActor)
  if td.HurtEnemy(td.CreateActorParams(self.m_pActor), pActor, self.m_iSkillRatio, self.m_iSkillFixed, self:IsMustHit()) then
    self:DidHit(pActor)
  end
end
function HitBackShort:DidHit(pActor)
  if pActor and pActor:IsCanBeMoved() then
    self:HitBack(pActor)
  end
end
function HitBackShort:HitBack(pActor)
  local selfPos = cc.p(self.m_pActor:getPosition())
  local enemyPos = cc.p(pActor:getPosition())
  local dir = cc.pNormalize(cc.pSub(enemyPos, selfPos))
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local backPos
  local dis = HitBackShort.HitDis + 10
  repeat
    dis = dis - 10
    backPos = cc.pAdd(enemyPos, cc.pMul(dir, dis))
  until pMap:IsLineWalkable(enemyPos, backPos) or dis <= 0
  pActor:stopActionByTag(td.HitBackActionTag)
  local hitbackAction = cca.moveTo(dis / 500, backPos.x, backPos.y)
  hitbackAction:setTag(td.HitBackActionTag)
  pActor:runAction(hitbackAction)
  local pEffect = EffectManager:GetInstance():CreateEffect(self.m_hurtEffect)
  if pEffect then
    pEffect:AddToActor(pActor)
  end
end
return HitBackShort
