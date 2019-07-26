local ObjectiveBuff = require("app.buff.ObjectiveBuff")
local TauntedBuff = class("TauntedBuff", ObjectiveBuff)
function TauntedBuff:ctor(pActor, info, callBackFunc, iActorObjectTag)
  TauntedBuff.super.ctor(self, pActor, info, callBackFunc, iActorObjectTag)
end
function TauntedBuff:OnEnter()
  TauntedBuff.super.OnEnter(self)
  self.m_pActor:SetIsTaunted(true)
end
function TauntedBuff:OnExit()
  TauntedBuff.super.OnExit(self)
  self.m_pActor:SetIsTaunted(false)
  local enemy = self.m_pActor:GetEnemy()
  if enemy and enemy:GetGroupType() == self.m_pActor:GetGroupType() then
    self.m_pActor:SetEnemy(nil)
  end
end
return TauntedBuff
