local BuffBase = require("app.buff.BuffBase")
local SkillRatioBuff = class("SkillRatioBuff", BuffBase)
function SkillRatioBuff:ctor(pActor, info, callBackFunc)
  SkillRatioBuff.super.ctor(self, pActor, info, callBackFunc)
end
function SkillRatioBuff:OnEnter()
  SkillRatioBuff.super.OnEnter(self)
  self.m_pActor:SetSkillRatioVary(self:GetValue())
end
function SkillRatioBuff:OnExit()
  SkillRatioBuff.super.OnExit(self)
  self.m_pActor:SetSkillRatioVary(-self:GetValue())
end
return SkillRatioBuff
