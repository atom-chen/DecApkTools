local SkillBase = import(".SkillBase")
local DarkInvade = class("DarkInvade", SkillBase)
DarkInvade.InvadeTime = 10
function DarkInvade:ctor(pActor, id, pData)
  DarkInvade.super.ctor(self, pActor, id, pData)
  self.m_pTarget = nil
  self.m_bIsInvading = false
  self.m_iTimeInterval = 0
end
function DarkInvade:Update(dt)
  DarkInvade.super.Update(self, dt)
  if self.m_bIsInvading and self.m_pTarget then
    if self.m_pTarget:IsDead() then
      self.m_bIsInvading = false
      self.m_pTarget = nil
      self.m_iTimeInterval = 0
      return
    end
    self.m_iTimeInterval = self.m_iTimeInterval + dt
    if self.m_iTimeInterval >= DarkInvade.InvadeTime then
      self.m_pTarget:SetCurHp(0)
    end
  end
end
function DarkInvade:Execute(endCallback)
  self.m_pActor:PlayAnimation(self.m_pData.skill_name, false, function()
    self:ExecuteOver()
    if endCallback then
      endCallback()
    end
  end, sp.EventType.ANIMATION_COMPLETE)
  self:ShowSkillName()
  if self.m_pTarget then
    self.m_fStartTime = 0
    do
      local SkillInfoManager = require("app.info.SkillInfoManager")
      local EffectManager = require("app.effect.EffectManager")
      local BuffManager = require("app.buff.BuffManager")
      local GameDataManager = require("app.GameDataManager")
      local pMap = GameDataManager:GetInstance():GetGameMap()
      local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
      local pos = cc.p(self.m_pTarget:getPosition())
      local pEffect = EffectManager:GetInstance():CreateEffect(pData.atk_effect, self.m_pActor, self.m_pTarget, pos)
      pEffect:setPosition(self.m_pTarget:getPosition())
      pEffect:AddToMap(pMap, pMap:GetPiexlSize().height - pos.y + 1)
      self.m_pTarget.m_pStateManager:GetCurState().m_fStartTime = 0
      pMap:runAction(cca.seq({
        cca.delay(0.5),
        cca.cb(function()
          self.m_pTarget:Alive(self.m_pTarget:GetMaxHp(), self.m_pActor:GetGroupType())
          for j, id in ipairs(pData.buff_id[1]) do
            BuffManager:GetInstance():AddBuff(self.m_pTarget, id)
          end
          self.m_bIsInvading = true
        end)
      }))
      G_SoundUtil:PlaySound(310, false)
      return true
    end
  end
  return false
end
function DarkInvade:IsTriggered()
  local supCondition = DarkInvade.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local ActorManager = require("app.actor.ActorManager")
  local actorPos = cc.p(self.m_pActor:getPosition())
  local vec = {}
  if self.m_pActor:GetGroupType() == td.GroupType.Enemy then
    vec = ActorManager:GetInstance():GetSelfVec()
  elseif self.m_pActor:GetGroupType() == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetEnemyVec()
  end
  for key, var in pairs(vec) do
    if var:IsDead() and (var:GetType() == td.ActorType.Monster or var:GetType() == td.ActorType.Soldier) and not var:IsZombie() and cc.pDistanceSQ(actorPos, cc.p(var:getPosition())) <= self.m_iAtkRangeSQ then
      if self.m_bIsInvading and self.m_pTarget then
        self.m_pTarget:SetCurHp(0)
        self.m_bIsInvading = false
        self.m_pTarget = nil
        self.m_iTimeInterval = 0
      end
      self.m_pTarget = var
      return true
    end
  end
  return false
end
return DarkInvade
