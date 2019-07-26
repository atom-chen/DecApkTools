local SkillBase = require("app.actor.skill.SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local BuffPassive = class("BuffPassive", SkillBase)
function BuffPassive:ctor(pActor, id, pData)
  BuffPassive.super.ctor(self, pActor, id, pData)
  self.m_vBuffs = {}
end
function BuffPassive:Active()
  local buffIds = self.m_pData.get_buff_id
  for i, v in ipairs(buffIds) do
    local buff = BuffManager:GetInstance():AddBuff(self.m_pActor, v, nil)
    if buff then
      table.insert(self.m_vBuffs, buff)
    end
  end
end
function BuffPassive:Inactive()
  for key, buff in ipairs(self.m_vBuffs) do
    buff:SetRemove()
  end
  self.m_vBuffs = {}
end
function BuffPassive:Update(dt)
end
return BuffPassive
