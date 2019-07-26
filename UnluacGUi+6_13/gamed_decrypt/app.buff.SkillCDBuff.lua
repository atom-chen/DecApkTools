local BuffBase = require("app.buff.BuffBase")
local SkillCDBuff = class("SkillCDBuff", BuffBase)
function SkillCDBuff:ctor(pActor, info, callBackFunc)
  SkillCDBuff.super.ctor(self, pActor, info, callBackFunc)
end
function SkillCDBuff:OnEnter()
  SkillCDBuff.super.OnEnter(self)
  self.m_pActor:SetSkillCDVary(self:GetValue())
end
function SkillCDBuff:OnExit()
  SkillCDBuff.super.OnExit(self)
  self.m_pActor:SetSkillCDVary(-self:GetValue())
end
return SkillCDBuff
