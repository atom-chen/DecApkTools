local BuffBase = require("app.buff.BuffBase")
local HurtlessBuff = class("HurtlessBuff", BuffBase)
function HurtlessBuff:ctor(pActor, info, callBackFunc)
  HurtlessBuff.super.ctor(self, pActor, info, callBackFunc)
end
function HurtlessBuff:OnEnter()
  HurtlessBuff.super.OnEnter(self)
  self.m_pActor:SetHurtless(true)
end
function HurtlessBuff:OnExit()
  HurtlessBuff.super.OnExit(self)
  self.m_pActor:SetHurtless(false)
end
return HurtlessBuff
