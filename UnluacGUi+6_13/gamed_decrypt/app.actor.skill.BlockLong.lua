local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local BuffManager = require("app.buff.BuffManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local BlockLong = class("BlockLong", SkillBase)
BlockLong.Condition = {
  0.8,
  0.5,
  0.2
}
BlockLong.BlockTime = 5
function BlockLong:ctor(pActor, id, pData)
  BlockLong.super.ctor(self, pActor, id, pData)
  self.m_iLastHp = 1
  self.m_iTimeInterval = 0
  self.m_bIsExecuting = false
  self.m_hEndCallback = nil
  self.m_vBuffs = {}
  self.m_soundHandle = nil
end
function BlockLong:Update(dt)
  BlockLong.super.Update(self, dt)
  if self.m_bIsExecuting then
    self.m_iTimeInterval = self.m_iTimeInterval + dt
    if self.m_iTimeInterval >= BlockLong.BlockTime then
      self:ExecuteOver()
      self.m_iTimeInterval = 0
    end
  end
end
function BlockLong:Execute(endCallback)
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  local aniNames = string.split(pData.skill_name, ";")
  self.m_pActor:PlayAnimation(aniNames[1], false, function(event)
    local buffIds = pData.get_buff_id
    for i, v in ipairs(buffIds) do
      local buff = BuffManager:GetInstance():AddBuff(self.m_pActor, v, nil)
      if buff then
        table.insert(self.m_vBuffs, buff)
      end
    end
    self.m_pActor:PlayAnimation(aniNames[2], true)
    self.m_bIsExecuting = true
  end, sp.EventType.ANIMATION_COMPLETE)
  self.m_hEndCallback = endCallback
  self.m_soundHandle = G_SoundUtil:PlaySound(318, true)
end
function BlockLong:ExecuteOver()
  BlockLong.super.ExecuteOver(self)
  if self.m_hEndCallback then
    self.m_hEndCallback()
    self.m_hEndCallback = nil
  end
  self.m_bIsExecuting = false
  self.m_iLastHp = self.m_pActor:GetCurHp() / self.m_pActor:GetMaxHp()
  for key, buff in ipairs(self.m_vBuffs) do
    buff:SetRemove()
  end
  self.m_vBuffs = {}
  if self.m_soundHandle then
    G_SoundUtil:StopSound(self.m_soundHandle)
    self.m_soundHandle = nil
  end
end
function BlockLong:IsTriggered()
  local supCondition = BlockLong.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local curHp = self.m_pActor:GetCurHp() / self.m_pActor:GetMaxHp()
  for key, var in ipairs(BlockLong.Condition) do
    if var <= self.m_iLastHp and var > curHp then
      return true
    end
  end
  return false
end
return BlockLong
