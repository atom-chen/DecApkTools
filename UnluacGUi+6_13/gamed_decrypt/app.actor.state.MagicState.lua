local SkillInfoManager = require("app.info.SkillInfoManager")
local StateBase = import(".StateBase")
local GameDataManager = require("app.GameDataManager")
local MagicState = class("MagicState", StateBase)
function MagicState:ctor(pStateManager, pActor)
  MagicState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.Magic
  self.m_bActionOver = false
end
function MagicState:OnEnter()
  self.m_bActionOver = false
  self.m_pActor:StopMove()
  self.m_pActor:PlayAnimation("stand")
  local pSkill = self.m_pActor:GetCurSkill()
  if pSkill and pSkill:IsTriggered() then
    self.m_pActor:Skill(pSkill:GetID(), handler(self, self.ActionOver))
    if pSkill:GetType() ~= td.SkillType.RandomMagic then
      local pos = GameDataManager:GetInstance():GetSkillTarget()
      local curPos = cc.p(self.m_pActor:getPosition())
      if pos.x >= curPos.x then
        self.m_pActor:SetDirType(td.DirType.Right)
      else
        self.m_pActor:SetDirType(td.DirType.Left)
      end
    end
  end
end
function MagicState:OnExit()
  self.m_pActor:SetCurSkill(nil)
end
function MagicState:Update(dt)
  if self.m_pActor:IsDead() and self.m_pStateManager:ChangeState(td.StateType.Dead) then
    return
  end
  if self.m_pActor:IsHex() and self.m_pStateManager:ChangeState(td.StateType.Hex) then
    return
  end
  if self.m_pActor:IsTrapped() and self.m_pStateManager:ChangeState(td.StateType.Trapped) then
    return
  end
  if self.m_bActionOver then
    self.m_pStateManager:ChangeState(td.StateType.Idle)
    return
  end
end
function MagicState:ActionOver()
  self.m_bActionOver = true
end
return MagicState
