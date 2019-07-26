local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local ImproveSelf = class("ImproveSelf", SkillBase)
function ImproveSelf:ctor(pActor, id, pData)
  ImproveSelf.super.ctor(self, pActor, id, pData)
end
function ImproveSelf:Execute(endCallback)
  ImproveSelf.super.Execute(self, endCallback)
  self.m_pActor:performWithDelay(function()
    local buffMng, effectMng = BuffManager:GetInstance(), EffectManager:GetInstance()
    local pEffect = effectMng:CreateEffect(self.m_pData.atk_effect)
    if pEffect then
      pEffect:AddToActor(self.m_pActor)
    end
    for j, buffid in ipairs(self.m_pData.get_buff_id) do
      buffMng:AddBuff(self.m_pActor, buffid)
    end
  end, 0.5)
end
return ImproveSelf
