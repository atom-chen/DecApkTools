local SkillBase = require("app.actor.skill.SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local DeadPassive = class("DeadPassive", SkillBase)
function DeadPassive:ctor(pActor, id, pData)
  DeadPassive.super.ctor(self, pActor, id, pData)
  self.m_vTerrainBuffs = {}
  self.m_bActive = false
end
function DeadPassive:Active()
  self.m_bActive = true
end
function DeadPassive:Inactive()
  self:OnClearTerrain()
  self.m_bActive = false
end
function DeadPassive:Update(dt)
  if not self.m_bActive or nil == self.m_pActor then
    return
  end
  if not self.m_pActor:IsDead() then
    return
  end
  self:Work()
  self.m_bActive = false
end
function DeadPassive:Work()
  local pos = cc.p(self.m_pActor:getPosition())
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.atk_effect, self.m_pActor, nil, pos)
  pEffect:SetSkill(self)
  pEffect:AddToMap(pMap)
  pMap:performWithDelay(function()
    local pTerrainEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.track_effect, self.m_pActor, nil, pos)
    if pTerrainEffect then
      pTerrainEffect:SetSkill(self)
      pTerrainEffect:SetEndCallback(handler(self, self.OnClearTerrain))
      pTerrainEffect:AddToMap(pMap)
    end
  end, 0.5)
end
function DeadPassive:OnClearTerrain()
  for key, var in pairs(self.m_vTerrainBuffs) do
    for i, v in ipairs(var) do
      v:SetRemove()
    end
  end
  self.m_vTerrainBuffs = {}
end
function DeadPassive:ClearLeavers(vActors)
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
function DeadPassive:DidCollide(vActors)
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
return DeadPassive
