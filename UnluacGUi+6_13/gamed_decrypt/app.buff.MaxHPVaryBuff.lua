local BuffBase = require("app.buff.BuffBase")
local MaxHPVaryBuff = class("MaxHPVaryBuff", BuffBase)
function MaxHPVaryBuff:ctor(pActor, info, callBackFunc, pActorBase)
  MaxHPVaryBuff.super.ctor(self, pActor, info, callBackFunc)
end
function MaxHPVaryBuff:OnEnter()
  MaxHPVaryBuff.super.OnEnter(self)
end
function MaxHPVaryBuff:DidEnter()
  MaxHPVaryBuff.super.DidEnter(self)
  if self.m_eType == td.BuffType.HpMaxAdd then
    local ratio = math.abs(self:GetValue(1)) / 100
    local hp = self.m_pActor:GetCurHp() * ratio
    self.m_pActor:ChangeHp(hp, true)
  elseif self.m_eType == td.BuffType.HpMaxReduce then
    local ratio = math.abs(self:GetValue(1)) / 100
    local hp = self.m_pActor:GetCurHp() * (1 - ratio) - self.m_pActor:GetCurHp()
    if hp < 0 then
      self.m_pActor:ChangeHp(hp, true)
    end
  end
end
function MaxHPVaryBuff:OnExit()
  MaxHPVaryBuff.super.OnExit(self)
  if self.m_eType == td.BuffType.HpMaxAdd then
    local hp = self.m_pActor:GetMaxHp() - self.m_pActor:GetCurHp()
    if hp < 0 then
      self.m_pActor:ChangeHp(hp, true)
    end
  end
end
function MaxHPVaryBuff:Update(dt)
  MaxHPVaryBuff.super.Update(self, dt)
end
return MaxHPVaryBuff
