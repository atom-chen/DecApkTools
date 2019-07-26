local GameDataManager = require("app.GameDataManager")
local TriggerBase = import(".TriggerBase")
local EffectPlayAnimTrigger = class("EffectPlayAnimTrigger", TriggerBase)
function EffectPlayAnimTrigger:ctor(iID, iType, bLoop, conditionType, data)
  EffectPlayAnimTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_caidanEffectId = data.caidanEffectId
  self.m_animName = data.animName
  self.m_newEffectId = data.newEffectId
  self.m_randomDelay = data.randomDelay
  self.m_pEffectManager = require("app.effect.EffectManager").GetInstance()
end
function EffectPlayAnimTrigger:Active()
  EffectPlayAnimTrigger.super.Active(self)
  local effect = self.m_pEffectManager:GetEffectById(self.m_caidanEffectId)
  if self.m_randomDelay then
    local delay = math.random(self.m_randomDelay[1], self.m_randomDelay[2])
    effect:performWithDelay(function()
      self:StartDo()
    end, delay)
  else
    self:StartDo()
  end
end
function EffectPlayAnimTrigger:StartDo()
  local effect = self.m_pEffectManager:GetEffectById(self.m_caidanEffectId)
  effect:GetContentNode():PlayAni(self.m_animName, false)
  effect:GetContentNode():registerSpineEventHandler(function(event)
    if event.animation == self.m_animName then
      if not self.m_newEffectId then
        return
      end
      local pEffect = self.m_pEffectManager:CreateEffect(self.m_newEffectId)
      local pMap = GameDataManager:GetInstance():GetGameMap()
      pEffect:AddToMap(pMap)
    end
  end, sp.EventType.ANIMATION_END)
end
return EffectPlayAnimTrigger
