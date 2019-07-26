local BuffBase = require("app.buff.BuffBase")
local PeaceBuff = class("PeaceBuff", BuffBase)
function PeaceBuff:ctor(pActor, info, callBackFunc)
  PeaceBuff.super.ctor(self, pActor, info, callBackFunc)
end
function PeaceBuff:OnEnter()
  PeaceBuff.super.OnEnter(self)
  self.m_pActor:SetIsPeace(true)
end
function PeaceBuff:OnExit()
  PeaceBuff.super.OnExit(self)
  self.m_pActor:SetIsPeace(false)
end
return PeaceBuff
