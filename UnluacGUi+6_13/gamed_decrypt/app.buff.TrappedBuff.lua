local BuffBase = require("app.buff.BuffBase")
local TrappedBuff = class("TrappedBuff", BuffBase)
function TrappedBuff:ctor(pActor, info, callBackFunc)
  TrappedBuff.super.ctor(self, pActor, info, callBackFunc)
end
function TrappedBuff:OnEnter()
  TrappedBuff.super.OnEnter(self)
  self.m_pActor:SetTrapped(true)
end
function TrappedBuff:OnExit()
  TrappedBuff.super.OnExit(self)
  self.m_pActor:SetTrapped(false)
end
function TrappedBuff:Update(dt)
  TrappedBuff.super.Update(self, dt)
end
return TrappedBuff
