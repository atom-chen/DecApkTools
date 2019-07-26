local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local AngelCure = class("AngelCure", SkillBase)
function AngelCure:ctor(pActor, id, pData)
  AngelCure.super.ctor(self, pActor, id, pData)
  self.m_isSenior = id == 1022 and true or false
end
function AngelCure:Update(dt)
  AngelCure.super.Update(self, dt)
end
function AngelCure:Execute(endCallback)
  local cureRatio = self.m_iSkillRatio / 100
  local cureFixed = self.m_iSkillFixed
  local weakFriends = self:FindWounded()
  local count = #weakFriends
  if count > 0 then
    self.m_fStartTime = 0
    local aniNames = string.split(self.m_pData.skill_name, "#")
    self.m_pActor:PlayAnimation(aniNames[1], false, function(event)
      for i = count, 1, -1 do
        if weakFriends[i]:IsDead() then
          table.remove(weakFriends, i)
        end
      end
      count = #weakFriends
      if count > 0 then
        self:Cure(nil, weakFriends[1], cureRatio, cureFixed, 0)
        if self.m_isSenior and count > 1 then
          local index = math.min(count, 4)
          for i = 2, index do
            self:Cure(weakFriends[i - 1], weakFriends[i], cureRatio / 2, cureFixed / 2, 0.2 * (i - 1))
          end
        end
      end
      endCallback()
      self:ExecuteOver()
    end, sp.EventType.ANIMATION_COMPLETE)
    G_SoundUtil:PlaySound(212, false)
    self:ShowSkillName()
  else
    endCallback()
  end
end
function AngelCure:Cure(lastActor, target, ratio, fixed, delay)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  pMap:performWithDelay(function()
    target:ChangeHp(target:GetMaxHp() * ratio + fixed)
    if lastActor and lastActor ~= target then
      local linkEffect = EffectManager:GetInstance():CreateEffect(62, lastActor, target)
      linkEffect:AddToMap(pMap)
    end
    local effect = EffectManager:GetInstance():CreateEffect(1020)
    effect:AddToActor(target)
  end, delay)
end
function AngelCure:IsTriggered()
  local supCondition = AngelCure.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local vec = {}
  local groupType = self.m_pActor:GetGroupType()
  if groupType == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetSelfVec()
  else
    vec = ActorManager:GetInstance():GetEnemyVec()
  end
  for k, v in pairs(vec) do
    if self:Check(v) and v:GetCurHp() / v:GetMaxHp() <= 0.9 then
      return true
    end
  end
  self.m_iCheckTime = 0
  return false
end
function AngelCure:FindWounded()
  local vec = {}
  local eGroupType = self.m_pActor:GetGroupType()
  if eGroupType == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetSelfVec()
  else
    vec = ActorManager:GetInstance():GetEnemyVec()
  end
  local weakFriends = {}
  local minHp = 1
  for k, actor in pairs(vec) do
    if self:Check(actor) then
      local hpRatio = actor:GetCurHp() / actor:GetMaxHp()
      if hpRatio > 0 and hpRatio < 1 then
        if minHp > hpRatio then
          minHp = hpRatio
          table.insert(weakFriends, 1, actor)
        else
          table.insert(weakFriends, actor)
        end
      end
    end
  end
  return weakFriends
end
function AngelCure:Check(pActor)
  if pActor and not pActor:IsDead() then
    local eType = pActor:GetType()
    if (eType == td.ActorType.Soldier or eType == td.ActorType.Hero or eType == td.ActorType.Monster) and cc.pDistanceSQ(cc.p(self.m_pActor:getPosition()), cc.p(pActor:getPosition())) <= self.m_iAtkRangeSQ then
      return true
    end
  end
  return false
end
return AngelCure
