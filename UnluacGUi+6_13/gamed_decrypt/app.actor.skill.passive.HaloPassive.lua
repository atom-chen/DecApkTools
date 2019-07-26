local SkillBase = require("app.actor.skill.SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local HaloPassive = class("HaloPassive", SkillBase)
function HaloPassive:ctor(pActor, id, pData)
  HaloPassive.super.ctor(self, pActor, id, pData)
  self.m_pEffect = nil
  self.m_vTerrainBuffs = {}
  self.m_bActive = false
end
function HaloPassive:Active()
  self.m_pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.atk_effect, self.m_pActor)
  if self.m_pEffect then
    self.m_pEffect:setScaleY(self.m_pEffect:getScaleY() / 2)
    self.m_pEffect:SetSkill(self)
    local pMap = GameDataManager:GetInstance():GetGameMap()
    self.m_pEffect:AddToMap(pMap)
  end
  self.m_bActive = true
end
function HaloPassive:Inactive()
  self:OnClearTerrain()
  if self.m_pEffect then
    self.m_pEffect:SetRemove()
    self.m_pEffect = nil
  end
  self.m_bActive = false
end
function HaloPassive:Update(dt)
end
function HaloPassive:OnClearTerrain()
  for key, var in pairs(self.m_vTerrainBuffs) do
    for i, v in ipairs(var) do
      v:SetRemove()
    end
  end
  self.m_vTerrainBuffs = {}
end
function HaloPassive:ClearLeavers(vActors)
  for key, var in pairs(self.m_vTerrainBuffs) do
    local bStillIn = false
    for i, pActor in ipairs(vActors) do
      if pActor:getTag() == key then
        bStillIn = true
        break
      end
    end
    if not bStillIn then
      for i, v in ipairs(var) do
        v:SetRemove()
      end
      self.m_vTerrainBuffs[key] = nil
    end
  end
end
function HaloPassive:DidCollide(vActors)
  if not self.m_pData.buff_id[1] then
    return
  end
  self:ClearLeavers(vActors)
  for i, pActor in ipairs(vActors) do
    if pActor and not pActor:IsDead() and pActor:IsCanBuffed() and not self.m_vTerrainBuffs[pActor:getTag()] then
      local terrainBuffs = {}
      for i, id in ipairs(self.m_pData.buff_id[1]) do
        local buff = BuffManager:GetInstance():AddBuff(pActor, id)
        if buff then
          table.insert(terrainBuffs, buff)
        end
      end
      if #terrainBuffs > 0 then
        self.m_vTerrainBuffs[pActor:getTag()] = terrainBuffs
      end
    end
  end
end
return HaloPassive
