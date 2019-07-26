local BuffBase = require("app.buff.BuffBase")
local EffectManager = require("app.effect.EffectManager")
local ZombieBuff = class("ZombieBuff", BuffBase)
function ZombieBuff:ctor(pActor, info, callBackFunc)
  ZombieBuff.super.ctor(self, pActor, info, callBackFunc)
end
function ZombieBuff:OnEnter()
  ZombieBuff.super.OnEnter(self)
  self.m_pActor:SetIsZombie(true)
  local pEffect = EffectManager:GetInstance():CreateEffect(1010)
  pEffect:AddToActor(self.m_pActor, -1)
end
function ZombieBuff:OnExit()
  ZombieBuff.super.OnExit(self)
end
function ZombieBuff:Update(dt)
  ZombieBuff.super.Update(self, dt)
end
return ZombieBuff
