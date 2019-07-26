local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local BuffManager = require("app.buff.BuffManager")
local ActorManager = require("app.actor.ActorManager")
local AncientShield = class("AncientShield", SkillBase)
function AncientShield:ctor(pActor, id, pData)
  AncientShield.super.ctor(self, pActor, id, pData)
end
function AncientShield:Update(dt)
  AncientShield.super.Update(self, dt)
end
function AncientShield:Execute(endCallback)
  self.m_fStartTime = 0
  local aniNames = string.split(self.m_pData.skill_name, "#")
  self.m_pActor:PlayAnimation(aniNames[1], false, function(event)
    local vec = {}
    local eGroupType = self.m_pActor:GetGroupType()
    if eGroupType == td.GroupType.Self then
      vec = ActorManager:GetInstance():GetSelfVec()
    else
      vec = ActorManager:GetInstance():GetEnemyVec()
    end
    for i, actor in pairs(vec) do
      local eType = actor:GetType()
      if not actor:IsDead() and (eType == td.ActorType.Soldier or eType == td.ActorType.Hero or eType == td.ActorType.Monster) and cc.pDistanceSQ(cc.p(self.m_pActor:getPosition()), cc.p(actor:getPosition())) <= self.m_iAtkRangeSQ then
        for k, id in ipairs(self.m_pData.buff_id[1]) do
          BuffManager:GetInstance():AddBuff(actor, id)
        end
      end
    end
    endCallback()
    self:ExecuteOver()
  end, sp.EventType.ANIMATION_COMPLETE)
  self:ShowSkillName()
end
function AncientShield:IsTriggered()
  local supCondition = AncientShield.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local selfVec, enemyVec
  local existSelf, existEnemy = false, false
  local groupType = self.m_pActor:GetGroupType()
  if groupType == td.GroupType.Self then
    selfVec = ActorManager:GetInstance():GetSelfVec()
    enemyVec = ActorManager:GetInstance():GetEnemyVec()
  else
    selfVec = ActorManager:GetInstance():GetEnemyVec()
    enemyVec = ActorManager:GetInstance():GetSelfVec()
  end
  for i, v in pairs(selfVec) do
    if v and (v:GetType() == td.ActorType.Soldier or v:GetType() == td.ActorType.Hero or v:GetType() == td.ActorType.Monster) and cc.pDistanceSQ(cc.p(self.m_pActor:getPosition()), cc.p(v:getPosition())) <= self.m_iAtkRangeSQ then
      existSelf = true
      break
    end
  end
  for i, v in pairs(enemyVec) do
    if v and cc.pDistanceSQ(cc.p(self.m_pActor:getPosition()), cc.p(v:getPosition())) <= self.m_iAtkRangeSQ then
      existEnemy = true
      break
    end
  end
  if existSelf and existEnemy then
    return true
  else
    self.m_iCheckTime = 0
    return false
  end
end
return AncientShield
