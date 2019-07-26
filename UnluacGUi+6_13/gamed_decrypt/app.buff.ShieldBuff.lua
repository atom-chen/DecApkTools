local BuffBase = require("app.buff.BuffBase")
local BloodBar = require("app.widgets.BloodBar")
local ShieldBuff = class("ShieldBuff", BuffBase)
function ShieldBuff:ctor(pActor, info, callBackFunc)
  ShieldBuff.super.ctor(self, pActor, info, callBackFunc)
  self.bBreak = false
  if self.m_eType == td.BuffType.Shield then
    self.m_iMaxArmor = self.m_vValue[1]
    self.m_iCurArmor = self.m_vValue[1]
  else
    self.m_iMaxArmor = pActor:GetMaxHp() * (self.m_vValue[1] / 100)
    self.m_iCurArmor = self.m_iMaxArmor
  end
  self.m_pEffect = nil
end
function ShieldBuff:OnEnter()
  local EffectManager = require("app.effect.EffectManager")
  local pEffect = EffectManager:GetInstance():CreateEffect(self.m_iEffectId)
  if pEffect then
    pEffect:AddToActor(self.m_pActor)
    self.m_pEffect = pEffect
  end
  local height = self.m_pActor.m_pSkeleton:GetContentSize().height
  local timerSpr = display.newSprite("#UI/battle/huduntiao.png")
  self.m_pArmorBar = cc.ProgressTimer:create(timerSpr)
  self.m_pArmorBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  self.m_pArmorBar:setMidpoint(cc.p(0, 0))
  self.m_pArmorBar:setBarChangeRate(cc.p(1, 0))
  self.m_pArmorBar:setPercentage(100)
  self.m_pArmorBar:setPosition(cc.p(0, height))
  self.m_pArmorBar:setScale(1 / self.m_pActor:getScale())
  self.m_pActor:addChild(self.m_pArmorBar, 11)
  local conSize = timerSpr:getContentSize()
  local barBg = display.newSprite("#UI/battle/xuetiaodi.png")
  barBg:setPosition(cc.p(conSize.width / 2, conSize.height / 2))
  self.m_pArmorBar:addChild(barBg, -1)
end
function ShieldBuff:Update(dt)
  ShieldBuff.super.Update(self, dt)
end
function ShieldBuff:GetMaxArmor()
  return self.m_iMaxArmor
end
function ShieldBuff:BlockDamage(damage, attacker)
  if self.m_bRemove or self.bBreak then
    return damage
  end
  local remain = 0
  self.m_iCurArmor = self.m_iCurArmor + damage
  if 0 >= self.m_iCurArmor then
    remain = self.m_iCurArmor
    self.m_iCurArmor = 0
    self:Break(attacker)
  else
    self.m_pArmorBar:setPercentage(self.m_iCurArmor / self.m_iMaxArmor * 100)
  end
  return remain
end
function ShieldBuff:Break(attacker)
  self.bBreak = true
  if self.m_pEffect and self.m_pEffect:GetType() == td.EffectType.Spine then
    local skeleton = self.m_pEffect:GetContentNode()
    if skeleton:FindAnimation("animation_02") then
      skeleton:registerSpineEventHandler(function(event)
        if event.animation == "animation_02" then
          self:SetRemove()
        end
      end, sp.EventType.ANIMATION_COMPLETE)
      skeleton:PlayAni("animation_02", false)
      if attacker and not attacker:IsDead() then
        attacker:ChangeHp(-self.m_iMaxArmor, true)
      end
      return
    end
  end
  self:SetRemove()
end
function ShieldBuff:SetRemove()
  ShieldBuff.super.SetRemove(self)
  if self.m_pArmorBar then
    self.m_pArmorBar:removeFromParent(true)
    self.m_pArmorBar = nil
  end
  if self.m_pEffect then
    self.m_pEffect:SetRemove()
    self.m_pEffect = nil
  end
end
return ShieldBuff
