local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local GameDataManager = require("app.GameDataManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local CrossChop = class("CrossChop", SkillBase)
CrossChop.AttackType = {Range = 0, Seckill = 1}
function CrossChop:ctor(pActor, id, pData)
  CrossChop.super.ctor(self, pActor, id, pData)
  self.m_eAttackType = -1
  self.m_iViewSQ = self.m_pActor:GetViewRange() * self.m_pActor:GetViewRange()
  self.m_pTarget = nil
end
function CrossChop:Execute(endCallback)
  self.m_fStartTime = 0
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  local aniNames = string.split(pData.skill_name, "#")
  local ani = self.m_eAttackType == CrossChop.AttackType.Range and aniNames[1] or aniNames[2]
  self.m_pActor:PlayAnimation(ani, false, function()
    self:ExecuteOver()
    endCallback()
  end, sp.EventType.ANIMATION_COMPLETE)
end
function CrossChop:IsTriggered()
  local supCondition = CrossChop.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local selfPos = cc.p(self.m_pActor:getPosition())
  local vec = {}
  if self.m_pActor:GetGroupType() == td.GroupType.Enemy then
    vec = ActorManager:GetInstance():GetSelfVec()
  elseif self.m_pActor:GetGroupType() == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetEnemyVec()
  end
  local actorsInView = {}
  for tag, actor in pairs(vec) do
    if not actor:IsDead() and actor:GetType() ~= td.ActorType.Home and actor:GetType() ~= td.ActorType.FangYuTa then
      local pos = cc.p(actor:getPosition())
      local disSQ = cc.pDistanceSQ(selfPos, pos)
      if disSQ <= self.m_iAtkRangeSQ then
        self.m_eAttackType = CrossChop.AttackType.Range
        return true
      elseif disSQ <= self.m_iViewSQ then
        table.insert(actorsInView, actor)
      end
    end
  end
  local count = #actorsInView
  if count > 0 then
    self.m_eAttackType = CrossChop.AttackType.Seckill
    self.m_pTarget = actorsInView[count]
    return true
  end
  self.m_iCheckTime = 0
  return false
end
function CrossChop:Shoot()
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  local bonePos = self.m_pActor:FindBonePos("bone_shoot")
  bonePos = cc.pAdd(bonePos, cc.p(self.m_pActor:getPosition()))
  local pMap = GameDataManager:GetInstance():GetGameMap()
  if self.m_eAttackType == CrossChop.AttackType.Range then
    local pEffect = EffectManager:GetInstance():CreateEffect(pData.atk_effect, self.m_pActor, nil, bonePos)
    pEffect:SetSkill(self)
    pEffect:AddToMap(pMap)
  elseif self.m_eAttackType == CrossChop.AttackType.Seckill then
    local pEffect = EffectManager:GetInstance():CreateEffect(pData.track_effect, self.m_pActor, self.m_pTarget, bonePos)
    pEffect:AddToMap(pMap)
    self.m_pTarget = nil
  end
end
return CrossChop
