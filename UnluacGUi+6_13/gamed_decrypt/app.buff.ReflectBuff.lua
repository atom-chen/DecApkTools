local BuffBase = require("app.buff.BuffBase")
local EffectManager = require("app.effect.EffectManager")
local BattleWord = require("app.widgets.BattleWord")
local ReflectBuff = class("ReflectBuff", BuffBase)
function ReflectBuff:ctor(pActor, info, callBackFunc, pActorBase)
  ReflectBuff.super.ctor(self, pActor, info, callBackFunc)
  self.m_fTimeInterval = 0
  self.m_pEffect = nil
  self.m_bIsPlaying = false
end
function ReflectBuff:OnEnter()
  ReflectBuff.super.OnEnter(self)
end
function ReflectBuff:OnExit()
  ReflectBuff.super.OnExit(self)
  if self.m_CallBackFunc then
    self.m_CallBackFunc()
  end
end
function ReflectBuff:OnWork()
  if self.m_iEffectId ~= 0 and not self.m_bIsPlaying then
    local pEffect = EffectManager:GetInstance():CreateEffect(self.m_iEffectId)
    if pEffect then
      self.m_bIsPlaying = true
      pEffect:AddToActor(self.m_pActor)
      pEffect:SetEndCallback(function()
        self.m_bIsPlaying = false
      end)
    end
  end
  if table.indexof({
    td.BuffType.ReflectCaster,
    td.BuffType.ReflectArcher,
    td.BuffType.ReflectSaber,
    td.BuffType.Rebound
  }, self.m_eType) then
    local blockWord = BattleWord.new("ref")
    blockWord:AddToActor(self.m_pActor)
  elseif table.indexof({
    td.BuffType.SaberHurtVary,
    td.BuffType.ArcherHurtVary,
    td.BuffType.CasterHurtVary
  }, self.m_eType) and 0 > self:GetValue() then
    local blockWord = BattleWord.new("block")
    blockWord:AddToActor(self.m_pActor)
  end
end
return ReflectBuff
