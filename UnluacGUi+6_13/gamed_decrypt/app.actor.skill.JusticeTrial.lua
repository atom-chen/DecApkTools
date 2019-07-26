local AreaSkill = import(".AreaSkill")
local SkillInfoManager = require("app.info.SkillInfoManager")
local BuffManager = require("app.buff.BuffManager")
local JusticeTrial = class("JusticeTrial", AreaSkill)
function JusticeTrial:ctor(pActor, id, pData)
  JusticeTrial.super.ctor(self, pActor, id, pData)
  self.m_eGroupType = -1
end
function JusticeTrial:Execute(endCallback)
  JusticeTrial.super.Execute(self, endCallback)
  self.m_eGroupType = self.m_pActor:GetGroupType()
end
function JusticeTrial:DidCollide(vActors)
  self:ClearLeavers(vActors)
  for i, pActor in ipairs(vActors) do
    if pActor and not pActor:IsDead() and pActor:IsCanBuffed() and not self.m_vTerrainBuffs[pActor:getTag()] then
      local terrainBuffs = {}
      if pActor:GetGroupType() == self.m_eGroupType then
        for i, id in ipairs(self.m_pData.get_buff_id) do
          local buff = BuffManager:GetInstance():AddBuff(pActor, id)
          if buff and not buff:IsAutoRemove() then
            table.insert(terrainBuffs, buff)
          end
        end
      else
        for i, id in ipairs(self.m_pData.buff_id[2]) do
          local buff = BuffManager:GetInstance():AddBuff(pActor, id)
          if buff and not buff:IsAutoRemove() then
            table.insert(terrainBuffs, buff)
          end
        end
      end
      self.m_vTerrainBuffs[pActor:getTag()] = terrainBuffs
    end
  end
end
return JusticeTrial
