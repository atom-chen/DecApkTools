local BuffBase = require("app.buff.BuffBase")
local CharmedBuff = class("CharmedBuff", BuffBase)
function CharmedBuff:ctor(pActor, info, callBackFunc)
  CharmedBuff.super.ctor(self, pActor, info, callBackFunc)
end
function CharmedBuff:OnEnter()
  CharmedBuff.super.OnEnter(self)
  self.m_pActor:SetIsCharmed(true)
  self.m_pActor:SetEnemy(nil)
end
function CharmedBuff:OnExit()
  self.m_pActor:SetEnemy(nil)
  self.m_pActor:SetIsCharmed(false)
  CharmedBuff.super.OnExit(self)
end
return CharmedBuff
