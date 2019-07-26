local BuffBase = require("app.buff.BuffBase")
local HidingBuff = class("HidingBuff", BuffBase)
function HidingBuff:ctor(pActor, info, callBackFunc)
  HidingBuff.super.ctor(self, pActor, info, callBackFunc)
end
function HidingBuff:OnEnter()
  HidingBuff.super.OnEnter(self)
  self.m_pActor:SetIsHiding(true)
  if self:GetValue() ~= 0 then
    self.m_pActor.m_pSkeleton:runAction(cca.fadeTo(0.2, 0.4))
  end
end
function HidingBuff:OnExit()
  HidingBuff.super.OnExit(self)
  self.m_pActor:SetIsHiding(false)
  if self:GetValue() ~= 0 then
    self.m_pActor.m_pSkeleton:runAction(cca.fadeTo(1, 1))
  end
end
return HidingBuff
