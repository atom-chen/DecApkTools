local CDPassive = require("app.actor.skill.passive.CDPassive")
local BuffManager = require("app.buff.BuffManager")
local CDBuffPassive = class("CDBuffPassive", CDPassive)
function CDBuffPassive:ctor(pActor, id, pData)
  CDBuffPassive.super.ctor(self, pActor, id, pData)
  self.m_vBuffIds = pData.get_buff_id
end
function CDBuffPassive:OnWork()
  for i, v in ipairs(self.m_vBuffIds) do
    BuffManager:GetInstance():AddBuff(self.m_pActor, v, nil)
  end
end
return CDBuffPassive
