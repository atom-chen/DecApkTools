local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local VampireBoss = require("app.actor.VampireBoss")
local FuryCharge = class("FuryCharge", SkillBase)
function FuryCharge:ctor(pActor, id, pData)
  FuryCharge.super.ctor(self, pActor, id, pData)
  self.m_pColideEffect = nil
  self.m_bIsMoveEnd = false
end
function FuryCharge:Update(dt)
  FuryCharge.super.Update(self, dt)
end
function FuryCharge:Execute(endCallback)
  self.m_fStartTime = 0
  self.m_bIsMoveEnd = false
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  local t = string.split(pData.skill_name, ";")
  local buff = BuffManager:GetInstance():AddBuff(self.m_pActor, 391)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local curPos = cc.p(self.m_pActor:getPosition())
  local targetPos = self.m_pActor:GetFinalTargetPos()
  local dirType = curPos.x < targetPos.x and td.DirType.Right or td.DirType.Left
  self.m_pActor:SetDirType(dirType)
  self.m_pActor:PlayAnimation(t[1], false, function()
    self.m_pActor:PlayAnimation(t[2], true)
    self.m_pColideEffect = EffectManager:GetInstance():CreateEffect(164, self.m_pActor, nil, curPos)
    self.m_pColideEffect:SetSkill(self)
    for j, v in ipairs(self.m_pColideEffect.m_vAttributes) do
      if v:GetType() == td.AttributeType.Move then
        v.m_pos = cc.p(targetPos.x, targetPos.y)
        break
      end
    end
    self.m_pColideEffect:AddToMap(pMap)
    local hurtPos = self.m_pActor:FindBonePos("bone_beiji")
    pMap:runAction(cca.seq({
      cca.delay(cc.pGetDistance(curPos, targetPos) / 1000),
      cca.cb(function()
        local effectPos = cc.pAdd(curPos, hurtPos)
        local moveEffect = EffectManager:GetInstance():CreateEffect(2008, self.m_pActor, nil, effectPos)
        moveEffect:AddToMap(pMap)
        self.m_bIsMoveEnd = true
      end),
      cca.delay(0.5),
      cca.cb(function()
        self.m_pActor:setVisible(false)
      end),
      cca.delay(0.5),
      cca.cb(function()
        local effectPos = cc.pAdd(targetPos, hurtPos)
        local moveEffect = EffectManager:GetInstance():CreateEffect(2008, self.m_pActor, nil, effectPos)
        moveEffect:AddToMap(pMap)
        self.m_pActor:setPosition(targetPos)
      end),
      cca.delay(0.2),
      cca.cb(function()
        self.m_pActor:setVisible(true)
        self.m_pActor:PlayAnimation(t[3], false, function()
          buff:SetRemove()
          self:ExecuteOver()
          if endCallback then
            endCallback()
          end
        end, sp.EventType.ANIMATION_COMPLETE)
      end),
      cca.delay(1.5),
      cca.cb(function()
        self.m_pColideEffect:SetRemove()
        self.m_pColideEffect = nil
      end)
    }))
  end, sp.EventType.ANIMATION_COMPLETE)
end
function FuryCharge:ExecuteOver()
  FuryCharge.super.ExecuteOver(self)
  require("app.trigger.TriggerManager"):GetInstance():SendEvent({
    eType = td.ConditionType.MonsterStop,
    monsterId = self.m_pActor:GetID(),
    pathId = self.m_pActor:GetPathId()
  })
end
function FuryCharge:IsTriggered()
  local supCondition = FuryCharge.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  if self.m_pActor:GetBossState() ~= VampireBoss.BossState.Normal1 then
    return false
  end
  if self.m_pActor:GetCurHp() / self.m_pActor:GetMaxHp() <= 0.2 then
    return true
  end
  return false
end
function FuryCharge:DidCollide(vActors, pEffect)
  if self.m_bIsMoveEnd then
    return
  end
  for i, var in ipairs(vActors) do
    if var:IsCanAttacked() and td.HurtEnemy(td.CreateActorParams(self.m_pActor), var, self.m_iSkillRatio, self.m_iSkillFixed, self:IsMustHit()) then
      self:DidHit(var)
    end
  end
end
return FuryCharge
