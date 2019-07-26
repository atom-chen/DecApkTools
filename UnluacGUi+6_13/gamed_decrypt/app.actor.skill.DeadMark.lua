local SkillBase = import(".SkillBase")
local BuffManager = require("app.buff.BuffManager")
local ActorManager = require("app.actor.ActorManager")
local DeadMark = class("DeadMark", SkillBase)
function DeadMark:ctor(pActor, id, pData)
  DeadMark.super.ctor(self, pActor, id, pData)
  if id == 1017 then
    self.m_targetCount = 2
  else
    self.m_targetCount = 1
  end
  self.m_vTargets = {}
end
function DeadMark:Update(dt)
  DeadMark.super.Update(self, dt)
end
function DeadMark:Execute(endCallback)
  local aniNames = string.split(self.m_pData.skill_name, "#")
  self.m_pActor:PlayAnimation(aniNames[1], false, function(event)
    local bExecute = false
    for i, target in ipairs(self.m_vTargets) do
      if not target:IsHex() and not target:IsDead() then
        for j, buff in ipairs(self.m_pData.buff_id[1]) do
          BuffManager:GetInstance():AddBuff(target, buff)
        end
        bExecute = true
      end
      target:release()
    end
    self.m_vTargets = {}
    if bExecute then
      self.m_fStartTime = 0
    end
    endCallback()
    self:ExecuteOver()
  end, sp.EventType.ANIMATION_COMPLETE)
  G_SoundUtil:PlaySound(tonumber(self.m_pData.sounds), false)
  self:ShowSkillName()
end
function DeadMark:IsTriggered()
  local supCondition = DeadMark.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  self:FindTarget()
  if #self.m_vTargets > 0 then
    return true
  end
  self.m_iCheckTime = 0
  return false
end
function DeadMark:FindTarget()
  for i, var in ipairs(self.m_vTargets) do
    var:release()
  end
  self.m_vTargets = {}
  local ActorManager = require("app.actor.ActorManager")
  local vec = {}
  local eGroupType = self.m_pActor:GetGroupType()
  if eGroupType == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetEnemyVec()
  else
    vec = ActorManager:GetInstance():GetSelfVec()
  end
  local count = 0
  for i, v in pairs(vec) do
    if self:IsTarget(v) then
      v:retain()
      table.insert(self.m_vTargets, v)
      count = count + 1
      if count >= self.m_targetCount then
        break
      end
    end
  end
end
function DeadMark:IsTarget(pActor)
  if self.m_pActor == pActor then
    return false
  end
  if not pActor:IsCanAttacked() then
    return false
  end
  local eType = pActor:GetType()
  if eType == td.ActorType.Monster then
    local mType = pActor:GetMonsterType()
    if mType == td.MonsterType.BOSS or mType == td.MonsterType.DeputyBoss then
      return false
    end
  elseif eType ~= td.ActorType.Hero and eType ~= td.ActorType.Soldier then
    return false
  end
  local distance = cc.pDistanceSQ(cc.p(self.m_pActor:getPosition()), cc.p(pActor:getPosition()))
  if distance > self.m_iAtkRangeSQ then
    return false
  end
  return true
end
return DeadMark
