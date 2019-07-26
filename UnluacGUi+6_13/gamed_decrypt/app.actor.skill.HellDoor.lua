local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local VampireBoss = require("app.actor.VampireBoss")
local HellDoor = class("HellDoor", SkillBase)
HellDoor.CallTimeGap = 5
function HellDoor:ctor(pActor, id, pData)
  HellDoor.super.ctor(self, pActor, id, pData)
  self.m_pDoor = nil
  self.m_iTimeInterval = 0
end
function HellDoor:Update(dt)
  HellDoor.super.Update(self, dt)
  if not self.m_pDoor then
    return
  end
  self.m_iTimeInterval = self.m_iTimeInterval + dt
  if self.m_iTimeInterval >= HellDoor.CallTimeGap then
    self.m_iTimeInterval = 0
    self:CallMonster()
  end
end
function HellDoor:Execute(endCallback)
  self.m_fStartTime = 0
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  self.m_pActor:PlayAnimation(pData.skill_name, false, function()
    self:ExecuteOver()
    if endCallback then
      endCallback()
    end
  end, sp.EventType.ANIMATION_COMPLETE)
  self:CallDoor()
end
function HellDoor:IsTriggered()
  local supCondition = HellDoor.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  if self.m_pActor:GetType() == td.ActorType.Monster then
    if self.m_pActor:GetBossState() ~= VampireBoss.BossState.Normal1 then
      return false
    end
    if self.m_pDoor then
      return false
    end
  end
  return true
end
function HellDoor:CallDoor()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  self.m_pDoor = ActorManager:GetInstance():CreateActor(td.ActorType.Door, nil, self.m_pActor:GetRealGroupType() == td.GroupType.Enemy)
  self.m_pDoor:SetBelongSkill(self)
  if self.m_pActor:GetType() == td.ActorType.Monster then
    local actorPos = cc.p(self.m_pActor:getPosition())
    self.m_pDoor:setPosition(actorPos.x + 300, actorPos.y + 150)
  else
    self.m_pDoor:setPosition(self:GetSkillPos())
  end
  pMap:addChild(self.m_pDoor, pMap:GetPiexlSize().height - self.m_pDoor:getPositionY(), self.m_pDoor:getTag())
end
function HellDoor:CallMonster()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local bombEffect = EffectManager:GetInstance():CreateEffect(self.m_atkEffect, self.m_pActor, nil, cc.p(self.m_pDoor:getPosition()))
  bombEffect:SetSkill(self)
  bombEffect:AddToMap(pMap)
end
function HellDoor:OnDoorDisapear()
  self.m_pDoor = nil
  self.m_iTimeInterval = 0
end
return HellDoor
