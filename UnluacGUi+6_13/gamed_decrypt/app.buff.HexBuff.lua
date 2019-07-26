local BuffBase = require("app.buff.BuffBase")
local HexBuff = class("HexBuff", BuffBase)
function HexBuff:ctor(pActor, info, callBackFunc, pActorBase)
  HexBuff.super.ctor(self, pActor, info, callBackFunc)
end
function HexBuff:OnEnter()
  HexBuff.super.OnEnter(self)
  self.m_pActor:SetIsHex(true)
end
function HexBuff:OnExit()
  HexBuff.super.OnExit(self)
  self.m_pActor:SetIsHex(false)
end
function HexBuff:Update(dt)
  HexBuff.super.Update(self, dt)
  if self.m_pActor:IsDead() then
    self:SetRemove()
  end
end
return HexBuff
