local TriggerBase = import(".TriggerBase")
local NewActorTrigger = class("NewActorTrigger", TriggerBase)
function NewActorTrigger:ctor(iID, iType, bLoop, conditionType, data)
  NewActorTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_pathId = data.pathId
  self.m_isReverse = data.isReverse
  self.m_actorId = data.actorId
  self.m_actorType = data.actorType
  self.m_removeSkillIds = data.removeSkillIds
  if data.yxwave ~= nil then
    self.m_yxwave = data.yxwave
  else
    self.m_yxwave = true
  end
end
function NewActorTrigger:Active()
  NewActorTrigger.super.Active(self)
  local GameDataManager = require("app.GameDataManager")
  local pMap = GameDataManager:GetInstance():GetGameMap()
  if not pMap then
    return
  end
  local pActorManager = require("app.actor.ActorManager").GetInstance()
  local pActor = pActorManager:CreateActor(self.m_actorType, self.m_actorId, true)
  pActorManager:CreateActorPathById(pActor, self.m_pathId, self.m_isReverse)
  pMap:addChild(pActor, pMap:GetPiexlSize().height - pActor:getPositionY(), pActor:getTag())
  pActor:SetYXWave(self.m_yxwave)
  pActor.m_pStateManager:SetPause(true)
  if self.m_removeSkillIds and table.nums(self.m_removeSkillIds) > 0 then
    for k, value in pairs(self.m_removeSkillIds) do
      pActor:RemoveSkill(value)
    end
  end
  local pEffect = require("app.effect.EffectManager").GetInstance():CreateEffect(188, pActor, pActor)
  pEffect:AddToActor(pActor)
  local pBuffManager = require("app.buff.BuffManager").GetInstance()
  pBuffManager:AddBuff(pActor, 97)
end
return NewActorTrigger
