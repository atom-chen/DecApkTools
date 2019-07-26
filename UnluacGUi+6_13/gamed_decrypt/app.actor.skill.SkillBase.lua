local SkillInfoManager = require("app.info.SkillInfoManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local EffectManager = require("app.effect.EffectManager")
local SkillBase = class("SkillBase")
SkillBase.CHECK_TIME_GAP = 1
function SkillBase:ctor(pActor, id, pData)
  self.m_Id = id
  self.m_eType = pData.type
  self.m_pActor = pActor
  self.m_pActor:retain()
  self.m_iActorTag = self.m_pActor:getTag()
  self.m_vTargets = {}
  self.m_fCD = pData.cd
  self.m_fStartTime = pData.cd
  self.m_iCheckTime = SkillBase.CHECK_TIME_GAP
  self.m_iAttackRange = pData.atk_distance
  if self.m_iAttackRange == -1 then
    self.m_iAttackRange = self.m_pActor:GetData().view
  end
  self.m_iAtkRangeSQ = self.m_iAttackRange * self.m_iAttackRange
  self.m_iSkillRatio = pData.damage_ratio
  self.m_iSkillFixed = pData.basic_damage
  self.m_iDamageRangeW = pData.range_long
  self.m_iDamageRangeH = pData.range_high
  self.m_atkEffect = pData.atk_effect
  self.m_trackEffect = pData.track_effect
  self.m_hurtEffect = pData.hurt_effect
  self.m_pData = pData
  self.m_iPriority = 0
end
function SkillBase:OnExit()
  self.m_pActor:release()
  self.m_pActor = nil
  for i, var in ipairs(self.m_vTargets) do
    var:release()
  end
  self.m_vTargets = {}
end
function SkillBase:Update(dt)
  if self.m_fStartTime < self.m_fCD then
    self.m_fStartTime = self.m_fStartTime + dt
  end
  if self.m_iCheckTime < SkillBase.CHECK_TIME_GAP then
    self.m_iCheckTime = self.m_iCheckTime + dt
  end
end
function SkillBase:Execute(endCallback)
  self.m_fStartTime = 0
  local t = string.split(self.m_pData.skill_name, "#")
  local aniName = t[math.random(#t)]
  self.m_pActor:PlayAnimation(aniName, false, function()
    self:ExecuteOver()
    if endCallback then
      endCallback()
    end
  end, sp.EventType.ANIMATION_COMPLETE)
  self:ShowSkillName()
  return true
end
function SkillBase:ShowSkillName()
  if self.m_pData.word ~= "" and self.m_pData.word ~= "0" then
    local BattleWord = require("app.widgets.BattleWord")
    local blockWord = BattleWord.new(self.m_pData.word)
    blockWord:AddToActor(self.m_pActor)
  end
end
function SkillBase:ExecuteOver()
  if not self.m_pActor:IsDead() and not self.m_pActor:IsTrapped() and not self.m_pActor:IsHex() then
    self.m_pActor:PlayAnimation("stand")
  end
end
function SkillBase:GetActor()
  return self.m_pActor
end
function SkillBase:GetID()
  return self.m_Id
end
function SkillBase:GetCD()
  if self.m_pActor then
    return self.m_fCD * math.max(0, 1 + self.m_pActor:GetSkillCDVary() / 100)
  else
    return self.m_fCD
  end
end
function SkillBase:SetCDTime(time)
  self.m_fStartTime = time
end
function SkillBase:GetCDTime()
  return math.min(self.m_fStartTime, self:GetCD())
end
function SkillBase:IsCDOver()
  return self.m_fStartTime >= self:GetCD()
end
function SkillBase:IsTriggered()
  local bCanCheck = true
  if self.m_iCheckTime < SkillBase.CHECK_TIME_GAP then
    bCanCheck = false
  end
  return bCanCheck and self:IsCDOver()
end
function SkillBase:GetAttackRange()
  return self.m_iAttackRange
end
function SkillBase:GetDamageRange()
  return self.m_iDamageRangeW, self.m_iDamageRangeH
end
function SkillBase:SetSkillRatio(iRatio)
  self.m_iSkillRatio = iRatio
end
function SkillBase:GetSkillRatio()
  return self.m_iSkillRatio
end
function SkillBase:GetSkillFixed()
  return self.m_iSkillFixed
end
function SkillBase:GetType()
  return self.m_eType
end
function SkillBase:SetPriority(arg)
  self.m_iPriority = arg
end
function SkillBase:GetPriority()
  return self.m_iPriority
end
function SkillBase:IsMustHit()
  return true
end
function SkillBase:Hit()
  local enemy = self.m_pActor:GetEnemy()
  if td.HurtEnemy(td.CreateActorParams(self.m_pActor), enemy, self.m_iSkillRatio, self.m_iSkillFixed, self:IsMustHit()) then
    self:DidHit(enemy)
  end
end
function SkillBase:Shoot()
  local enemy = self.m_pActor:GetEnemy()
  local bonePos = self.m_pActor:FindBonePos("bone_shoot")
  bonePos = cc.pAdd(bonePos, cc.p(self.m_pActor:getPosition()))
  local pMap = GameDataManager:GetInstance():GetGameMap()
  if self.m_pData.atk_effect and self.m_pData.atk_effect ~= 0 then
    local pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.atk_effect, self.m_pActor)
    pEffect:AddToActor(self.m_pActor)
  end
  if self.m_pData.track_effect and self.m_pData.track_effect ~= 0 then
    local pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.track_effect, self.m_pActor, enemy, bonePos)
    pEffect:SetSkill(self)
    pEffect:AddToMap(pMap)
  end
end
function SkillBase:DidHit(pActor)
  if pActor then
    if self.m_pData.hurt_effect and self.m_pData.hurt_effect ~= 0 then
      local enemyType = pActor:GetType()
      if enemyType == td.ActorType.Hero or enemyType == td.ActorType.Soldier or enemyType == td.ActorType.Monster then
        local pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.hurt_effect, enemy, nil)
        if pEffect then
          pEffect:AddToActor(pActor)
        end
      end
    end
    if not pActor:IsDead() and pActor:IsCanBuffed() then
      for i, id in ipairs(self.m_pData.buff_id[1]) do
        BuffManager:GetInstance():AddBuff(pActor, id)
      end
    end
  end
end
function SkillBase:DidCollide(vActors)
end
function SkillBase:HitBack(pActor, distance)
  local selfActor = require("app.actor.ActorManager"):GetInstance():FindActorByTag(self.m_iActorTag)
  if not selfActor then
    return
  end
  local selfPos = cc.p(selfActor:getPosition())
  local enemyPos = cc.p(pActor:getPosition())
  local dir = cc.pNormalize(cc.pSub(enemyPos, selfPos))
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local backPos
  local dis = distance + 10
  repeat
    dis = dis - 10
    backPos = cc.pAdd(enemyPos, cc.pMul(dir, dis))
  until pMap:IsLineWalkable(enemyPos, backPos) or dis <= 0
  pActor:stopActionByTag(td.HitBackActionTag)
  pActor:SetBeingHitback(true)
  local hitbackAction = cca.seq({
    cca.moveTo(dis / 500, backPos.x, backPos.y),
    cca.cb(function()
      pActor:SetBeingHitback(false)
    end)
  })
  hitbackAction:setTag(td.HitBackActionTag)
  pActor:runAction(hitbackAction)
end
function SkillBase:GetSkillPos()
  local gameDataMng = GameDataManager:GetInstance()
  local mapType = gameDataMng:GetGameMapInfo().type
  if mapType == td.MapType.PVP or mapType == td.MapType.PVPGuild or mapType == td.MapType.Rob then
    return cc.p(self.m_pActor:GetEnemy():getPosition())
  else
    return gameDataMng:GetSkillTarget()
  end
end
return SkillBase
