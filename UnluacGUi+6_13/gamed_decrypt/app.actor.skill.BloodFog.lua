local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local BloodFog = class("BloodFog", SkillBase)
function BloodFog:ctor(pActor, id, pData)
  BloodFog.super.ctor(self, pActor, id, pData)
  self.m_pTerrainEffect = nil
  self.m_vTerrainBuffs = {}
  self.m_targetPos = nil
end
function BloodFog:Execute(endCallback)
  BloodFog.super.Execute(self, endCallback)
  if self.m_pTerrainEffect then
    self.m_pTerrainEffect:SetRemove()
    self.m_pTerrainEffect = nil
  end
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  self.m_targetPos = cc.p(self.m_pActor:GetEnemy():getPosition())
  self.m_pTerrainEffect = EffectManager:GetInstance():CreateEffect(pData.atk_effect, self.m_pActor, nil, self.m_targetPos)
  self.m_pTerrainEffect:SetSkill(self)
  self.m_pTerrainEffect:SetEndCallback(function()
    self.m_pTerrainEffect = nil
    self:OnClearTerrain()
  end)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  self.m_pTerrainEffect:AddToMap(pMap)
  G_SoundUtil:PlaySound(307, false)
end
function BloodFog:OnClearTerrain()
  for key, var in pairs(self.m_vTerrainBuffs) do
    for i, v in ipairs(var) do
      v:SetRemove()
    end
  end
  self.m_vTerrainBuffs = {}
end
function BloodFog:ClearLeavers(vActors)
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
function BloodFog:DidCollide(vActors)
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  if not pData.buff_id[2] then
    return
  end
  self:ClearLeavers(vActors)
  for i, pActor in ipairs(vActors) do
    if pActor and not pActor:IsDead() and pActor:IsCanBuffed() and not self.m_vTerrainBuffs[pActor:getTag()] then
      local terrainBuffs = {}
      for i, id in ipairs(pData.buff_id[2]) do
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
return BloodFog
