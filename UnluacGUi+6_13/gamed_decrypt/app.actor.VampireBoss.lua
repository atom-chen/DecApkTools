local Monster = require("app.actor.Monster")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local BuffManager = require("app.buff.BuffManager")
local EffectManager = require("app.effect.EffectManager")
local VampireBoss = class("VampireBoss", Monster)
VampireBoss.BossState = {
  Born = 1,
  Summon1 = 2,
  Normal1 = 3,
  Summon2 = 4,
  Normal2 = 5
}
local SummonBufffs = {
  354,
  3,
  355
}
local SacrifyBufffs = {
  398,
  399,
  400
}
function VampireBoss:ctor(eType, pData)
  VampireBoss.super.ctor(self, eType, pData)
  self.m_bossState = VampireBoss.BossState.Born
  self.m_sacrifyState = 0
end
function VampireBoss:PlayEnterAni()
  self:FlyToPos(self:GetFinalTargetPos(), nil, 1)
end
function VampireBoss:SetBossState(state)
  if self.m_bossState == state then
    return
  end
  local buffMng = BuffManager:GetInstance()
  if state == VampireBoss.BossState.Summon1 or state == VampireBoss.BossState.Summon2 then
    for i, id in ipairs(SummonBufffs) do
      buffMng:AddBuff(self, id)
    end
    self:Nothingness(true)
  elseif state == VampireBoss.BossState.Normal1 or state == VampireBoss.BossState.Normal2 then
    for i, id in ipairs(SummonBufffs) do
      buffMng:RemoveActorBuff(self, id)
    end
    buffMng:AddBuff(self, SacrifyBufffs[self.m_sacrifyState])
    self:Nothingness(false)
    if state == VampireBoss.BossState.Normal2 then
      self:RemoveSkill(1)
      self:AddSkill(64)
    end
  end
  self.m_bossState = state
end
function VampireBoss:GetBossState()
  return self.m_bossState
end
function VampireBoss:Nothingness(b)
  self:SetIsNothingnessState(b)
  if not b then
    ActorManager:GetInstance():CreateActorPathById(self, self.m_iPathId, self.m_bInverted)
    self.m_pStateManager:ChangeState(td.StateType.Idle)
  end
end
function VampireBoss:Sacrify(pActor)
  local blood = pActor:GetCurHp()
  pActor:ChangeHp(-blood, false)
  self.m_sacrifyState = self.m_sacrifyState + 1
end
function VampireBoss:FlyToPos(endPos, callback, flyDur)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local curPos = cc.p(self:getPosition())
  self:_FlyBefore()
  local dirType = curPos.x < endPos.x and td.DirType.Right or td.DirType.Left
  self:SetDirType(dirType)
  self:PlayAnimation("skill_11", false, function()
    self:PlayAnimation("skill_12", true)
    local pColideEffect = EffectManager:GetInstance():CreateEffect(187, self, nil, curPos)
    pColideEffect:SetSkill(nil)
    for j, v in ipairs(pColideEffect.m_vAttributes) do
      if v:GetType() == td.AttributeType.Move then
        v.m_pos = cc.p(endPos.x, endPos.y)
        break
      end
    end
    pColideEffect:AddToMap(pMap)
    local hurtPos = self:FindBonePos("bone_beiji")
    pMap:runAction(cca.seq({
      cca.delay(cc.pGetDistance(curPos, endPos) / 1000),
      cca.cb(function()
        local effectPos = cc.pAdd(curPos, hurtPos)
        local moveEffect = EffectManager:GetInstance():CreateEffect(2008, self, nil, effectPos)
        moveEffect:AddToMap(pMap)
      end),
      cca.delay(0.5),
      cca.cb(function()
        self:setVisible(false)
      end),
      cca.delay(0.5),
      cca.cb(function()
        local effectPos = cc.pAdd(endPos, hurtPos)
        local moveEffect = EffectManager:GetInstance():CreateEffect(2008, self, nil, effectPos)
        moveEffect:AddToMap(pMap)
        self:setPosition(endPos)
      end),
      cca.delay(0.2),
      cca.cb(function()
        self:setVisible(true)
        self:PlayAnimation("skill_13", false)
      end),
      cca.delay(1.5),
      cca.cb(function()
        pColideEffect:SetRemove()
        self:_FlyAfter()
      end)
    }))
  end, sp.EventType.ANIMATION_COMPLETE)
end
return VampireBoss
