local SkillBase = import(".SkillBase")
local ActorManager = require("app.actor.ActorManager")
local BuffManager = require("app.buff.BuffManager")
local Charm = class("Charm", SkillBase)
function Charm:ctor(pActor, id, pData)
  Charm.super.ctor(self, pActor, id, pData)
  self.m_targetCount = tonumber(pData.custom_data) or 1
end
function Charm:Execute(endCallback)
  Charm.super.Execute(self, endCallback)
  local vTargets = self:FindTarget()
  for i, target in ipairs(vTargets) do
    for j, buff in ipairs(self.m_pData.buff_id[1]) do
      BuffManager:GetInstance():AddBuff(target, buff)
    end
  end
  G_SoundUtil:PlaySound(tonumber(self.m_pData.sounds), false)
  return true
end
function Charm:FindTarget()
  local vTargets = {}
  if self.m_pActor:GetType() == td.ActorType.Monster then
    table.insert(vTargets, self.m_pActor:GetEnemy())
  else
    local skillPos = self:GetSkillPos()
    local vec = {}
    local eGroupType = self.m_pActor:GetGroupType()
    if eGroupType == td.GroupType.Self then
      vec = ActorManager:GetInstance():GetEnemyVec()
    else
      vec = ActorManager:GetInstance():GetSelfVec()
    end
    for i, v in pairs(vec) do
      if self:CheckCanBeCharm(v) and cc.pDistanceSQ(skillPos, cc.p(v:getPosition())) <= self.m_iAtkRangeSQ then
        table.insert(vTargets, v)
        if #vTargets >= self.m_targetCount then
          break
        end
      end
    end
  end
  return vTargets
end
function Charm:CheckCanBeCharm(pActor)
  if self.m_pActor == pActor then
    return false
  end
  if pActor:GetType() ~= td.ActorType.Soldier and pActor:GetType() ~= td.ActorType.Monster then
    return false
  end
  if pActor:GetType() == td.ActorType.Monster and pActor:GetMonsterType() ~= td.MonsterType.Normal then
    return false
  end
  if not pActor:IsCanAttacked() or not pActor:IsCanBuffed() or pActor:IsCharmed() then
    return false
  end
  return true
end
return Charm
