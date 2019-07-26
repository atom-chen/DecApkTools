local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local AreaSkill = class("AreaSkill", SkillBase)
function AreaSkill:ctor(pActor, id, pData)
  AreaSkill.super.ctor(self, pActor, id, pData)
  self.m_skillPos = nil
  self.m_skillRatioVary = 0
  self.m_pTerrainEffect = nil
  self.m_vTerrainBuffs = {}
end
function AreaSkill:Execute(endCallback)
  AreaSkill.super.Execute(self, endCallback)
  self.m_skillRatioVary = self.m_pActor:GetSkillRatioVary()
  if self.m_pTerrainEffect then
    self.m_pTerrainEffect:SetRemove()
    self.m_pTerrainEffect = nil
  end
  local gameDataMng = GameDataManager:GetInstance()
  self.m_skillPos = self:GetSkillPos()
  self.m_pTerrainEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.atk_effect, self.m_pActor, nil, self.m_skillPos)
  self.m_pTerrainEffect:SetSkill(self)
  self.m_pTerrainEffect:SetEndCallback(function()
    self.m_pTerrainEffect = nil
    self:OnClearTerrain()
  end)
  local pMap = gameDataMng:GetGameMap()
  self.m_pTerrainEffect:AddToMap(pMap)
end
function AreaSkill:OnClearTerrain()
  for key, var in pairs(self.m_vTerrainBuffs) do
    for i, v in ipairs(var) do
      v:SetRemove()
    end
  end
  self.m_vTerrainBuffs = {}
end
function AreaSkill:ClearLeavers(vActors)
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
function AreaSkill:GetSkillRatio()
  local ratio = self.m_iSkillRatio * math.max(0, 1 + self.m_skillRatioVary / 100)
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  if mapType == td.MapType.PVP or mapType == td.MapType.PVPGuild then
    return ratio * 0.5
  end
  return ratio
end
function AreaSkill:DidCollide(vActors)
  if not self.m_pData.buff_id[2] then
    return
  end
  self:ClearLeavers(vActors)
  for i, pActor in ipairs(vActors) do
    if pActor and not pActor:IsDead() and pActor:IsCanBuffed() and not self.m_vTerrainBuffs[pActor:getTag()] then
      local terrainBuffs = {}
      for i, id in ipairs(self.m_pData.buff_id[2]) do
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
function AreaSkill:DidHit(pActor, pEffect)
  AreaSkill.super.DidHit(self, pActor, pEffect)
  if not pActor then
    local hitPos = cc.p(pEffect:getPosition())
    require("app.trigger.TriggerManager"):GetInstance():SendEvent({
      eType = td.ConditionType.MapGunFire,
      pos = hitPos,
      size = cc.size(self.m_iDamageRangeW, self.m_iDamageRangeH)
    })
  end
end
function AreaSkill:Shoot()
end
return AreaSkill
