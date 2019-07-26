local GameDataManager = require("app.GameDataManager")
local TriggerBase = import(".TriggerBase")
local NothingnessStateTrigger = class("NothingnessStateTrigger", TriggerBase)
function NothingnessStateTrigger:ctor(iID, iType, bLoop, conditionType, data)
  NothingnessStateTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_isAdd = data.isAdd
  self.m_monsterId = data.monsterId
  self.m_addBuffIds = data.addBuffIds
  self.m_addSkillIds = data.addSkillIds
  self.m_removeBuffIds = data.removeBuffIds
  self.m_removeSkillIds = data.removeSkillIds
  self.m_dirType = data.dirType
  if data.pathId then
    self.m_pathId = data.pathId
    self.m_isReverse = data.isReverse or false
  end
  if data.removeTriggerId then
    self.m_removeTriggerId = data.removeTriggerId
  end
  if data.bMoveViewPort then
    self.m_bMoveViewPort = data.bMoveViewPort
    self.m_yOffset = data.yOffset or 0
  end
  if data.delay then
    self.m_delay = data.delay
  end
end
function NothingnessStateTrigger:Active()
  NothingnessStateTrigger.super.Active(self)
  local pActorManager = require("app.actor.ActorManager").GetInstance()
  local pMonster = pActorManager:FindActorById(self.m_monsterId, true)
  if pMonster then
    local startPos = cc.p(pMonster:getPosition())
    if self.m_isAdd then
      pMonster:SetIsNothingnessState(true)
    else
      pMonster:SetIsNothingnessState(false)
      if self.m_pathId then
        pActorManager:CreateActorPathById(pMonster, self.m_pathId, self.m_isReverse)
        pMonster.m_pStateManager:ChangeState(td.StateType.Idle)
      end
    end
    pMonster:SetDirType(self.m_dirType)
    self:MoveViewPoint(startPos)
    local pTriggerManager = require("app.trigger.TriggerManager"):GetInstance()
    local pBuffManager = require("app.buff.BuffManager").GetInstance()
    if self.m_addBuffIds and table.nums(self.m_addBuffIds) > 0 then
      for k, value in pairs(self.m_addBuffIds) do
        pBuffManager:AddBuff(pMonster, value)
      end
    end
    if self.m_removeBuffIds and 0 < table.nums(self.m_removeBuffIds) then
      for k, value in pairs(self.m_removeBuffIds) do
        pBuffManager:RemoveActorBuff(pMonster, value)
      end
    end
    if self.m_addSkillIds and 0 < table.nums(self.m_addSkillIds) then
      for k, value in pairs(self.m_addSkillIds) do
        pMonster:AddSkill(value, 0)
      end
    end
    if self.m_removeSkillIds and 0 < table.nums(self.m_removeSkillIds) then
      for k, value in pairs(self.m_removeSkillIds) do
        pMonster:RemoveSkill(value)
      end
    end
    local pTriggerManager = require("app.trigger.TriggerManager").GetInstance()
    if self.m_removeTriggerId and 0 < table.nums(self.m_removeTriggerId) then
      for k, value in pairs(self.m_removeTriggerId) do
        pTriggerManager:RemoveTriggerById(value)
      end
    end
  end
end
function NothingnessStateTrigger:MoveViewPoint(pos)
  if self.m_bMoveViewPort then
    local dataManager = require("app.GameDataManager").GetInstance()
    local speed = 2000
    pos.y = pos.y - self.m_yOffset
    dataManager:GetGameMap():HighlightPos(pos, speed)
  end
end
return NothingnessStateTrigger
