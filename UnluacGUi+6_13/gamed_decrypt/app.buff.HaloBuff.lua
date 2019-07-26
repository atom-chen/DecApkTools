local BuffBase = require("app.buff.BuffBase")
local BuffManager = require("app.buff.BuffManager")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local HaloBuff = class("HaloBuff", BuffBase)
function HaloBuff:ctor(pActor, info, callBackFunc, pActorBase)
  HaloBuff.super.ctor(self, pActor, info, callBackFunc)
  self.m_pEffect = nil
  self.m_vTerrainBuffs = {}
  self.m_vTriggerBuffId = info.custom_data
end
function HaloBuff:OnEnter()
  self.m_pEffect = EffectManager:GetInstance():CreateEffect(self.m_iEffectId, self.m_pActor)
  self.m_pEffect:setScaleY(self.m_pEffect:getScaleY() / 2)
  self.m_pEffect:SetSkill(self)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  self.m_pEffect:AddToMap(pMap)
end
function HaloBuff:GetDamageRange()
  return 150, 100
end
function HaloBuff:OnClearTerrain()
  for key, var in pairs(self.m_vTerrainBuffs) do
    for i, v in ipairs(var) do
      v:SetRemove()
    end
  end
  self.m_vTerrainBuffs = {}
end
function HaloBuff:ClearLeavers(vActors)
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
function HaloBuff:DidCollide(vActors)
  self:ClearLeavers(vActors)
  for i, pActor in ipairs(vActors) do
    if pActor and not pActor:IsDead() and pActor:IsCanBuffed() and not self.m_vTerrainBuffs[pActor:getTag()] then
      local terrainBuffs = {}
      for i, id in ipairs(self.m_vTriggerBuffId) do
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
function HaloBuff:SetRemove()
  HaloBuff.super.SetRemove(self)
  self:OnClearTerrain()
  if self.m_pEffect then
    self.m_pEffect:SetRemove()
    self.m_pEffect = nil
  end
end
return HaloBuff
