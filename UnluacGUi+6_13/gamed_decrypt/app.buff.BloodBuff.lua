local BuffBase = require("app.buff.BuffBase")
local BloodBuff = class("BloodBuff", BuffBase)
function BloodBuff:ctor(pActor, info, callBackFunc, pActorBase)
  BloodBuff.super.ctor(self, pActor, info, callBackFunc)
  self.m_fTimeInterval = 0
end
function BloodBuff:OnEnter()
  BloodBuff.super.OnEnter(self)
  self:ChangeHp()
end
function BloodBuff:Update(dt)
  BloodBuff.super.Update(self, dt)
  if self:IsRemove() then
    return
  end
  self.m_fTimeInterval = self.m_fTimeInterval + dt
  if self.m_fTimeInterval >= 1 then
    self:ChangeHp()
    self.m_fTimeInterval = 0
  end
end
function BloodBuff:ChangeHp()
  if self.m_pActor and not self.m_pActor:IsDead() then
    local eType = self:GetType()
    if eType == td.BuffType.HpVary_P or eType == td.BuffType.HpVaryAC_P then
      local hp = self.m_pActor:GetMaxHp() * self:GetValue() / 100
      self.m_pActor:ChangeHp(hp, true)
    elseif eType == td.BuffType.HpVary_V or eType == td.BuffType.HpVaryAC_V then
      self.m_pActor:ChangeHp(self:GetValue(), true)
    end
  end
end
return BloodBuff
