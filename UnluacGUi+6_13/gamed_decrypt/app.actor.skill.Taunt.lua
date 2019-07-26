local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local ActorManager = require("app.actor.ActorManager")
local Taunt = class("Taunt", SkillBase)
function Taunt:ctor(pActor, id, pData)
  Taunt.super.ctor(self, pActor, id, pData)
end
function Taunt:Update(dt)
  Taunt.super.Update(self, dt)
end
function Taunt:Execute(endCallback)
  self.m_fStartTime = 0
  local aniNames = string.split(self.m_pData.skill_name, "#")
  self.m_pActor:PlayAnimation(aniNames[1], false, function()
    for i, enemy in ipairs(self.m_vTargets) do
      if enemy and not enemy:IsDead() and enemy:IsCanBuffed() then
        for j, id in ipairs(self.m_pData.buff_id[1]) do
          local buff = BuffManager:GetInstance():AddBuff(enemy, id, nil, self.m_pActor:getTag())
          if buff and buff:GetType() == td.BuffType.Taunted then
            enemy:SetEnemy(self.m_pActor)
          end
        end
      end
      enemy:release()
    end
    self.m_vTargets = {}
    for j, id in ipairs(self.m_pData.get_buff_id) do
      BuffManager:GetInstance():AddBuff(self.m_pActor, id, nil)
    end
    endCallback()
    self:ExecuteOver()
  end, sp.EventType.ANIMATION_COMPLETE)
  local pEffect = EffectManager:GetInstance():CreateEffect(self.m_atkEffect)
  pEffect:AddToActor(self.m_pActor, 1)
  G_SoundUtil:PlaySound(204, false)
  self:ShowSkillName()
end
function Taunt:IsTriggered()
  for i, var in ipairs(self.m_vTargets) do
    var:release()
  end
  self.m_vTargets = {}
  local supCondition = Taunt.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local rangeSQ = self.m_pActor:GetViewRange() * self.m_pActor:GetViewRange()
  local actorPos = cc.p(self.m_pActor:getPosition())
  local function func(v)
    if nil == v or v:IsDead() or not v:IsCanBuffed() then
      return false
    end
    if cc.pDistanceSQ(cc.p(v:getPosition()), actorPos) <= rangeSQ then
      return true
    else
      return false
    end
  end
  local selfInView = ActorManager:GetInstance():FindActorByFunc(func, self.m_pActor:GetGroupType() ~= td.GroupType.Self)
  local enemyInView = ActorManager:GetInstance():FindActorByFunc(func, self.m_pActor:GetGroupType() == td.GroupType.Self)
  if #selfInView < #enemyInView then
    self.m_vTargets = enemyInView
    for i, var in ipairs(self.m_vTargets) do
      var:retain()
    end
    return true
  end
  self.m_iCheckTime = 0
  return false
end
return Taunt
