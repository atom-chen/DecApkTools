local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local GameDataManager = require("app.GameDataManager")
local BuffManager = require("app.buff.BuffManager")
local EffectManager = require("app.effect.EffectManager")
local CastBomb = class("CastBomb", SkillBase)
CastBomb.CastNum = 3
function CastBomb:ctor(pActor, id, pData)
  CastBomb.super.ctor(self, pActor, id, pData)
  self.m_executeCount = 0
  self.m_pMap = GameDataManager:GetInstance():GetGameMap()
  self.m_actorManager = require("app.actor.ActorManager").GetInstance()
end
function CastBomb:Execute(endCallback)
  self.m_fStartTime = 0
  self.m_executeCount = self.m_executeCount + 1
  local aniNames = string.split(self.m_pData.skill_name, "#")
  self.m_pActor:PlayAnimation(aniNames[1], false, function()
    self:ExecuteOver()
    endCallback()
  end, sp.EventType.ANIMATION_COMPLETE)
end
function CastBomb:Shoot()
  local bonePos = self.m_pActor:FindBonePos("bone_shoot")
  bonePos = cc.pAdd(bonePos, cc.p(self.m_pActor:getPosition()))
  local pMap = self.m_pMap
  local pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.track_effect, self.m_pActor, nil, bonePos)
  pEffect:SetSkill(self)
  local tileSize = pMap:GetMapSize()
  for i, v in ipairs(pEffect.m_vAttributes) do
    if v:GetType() == td.AttributeType.Parabola then
      v.m_pos = self:FindTargetPos()
      break
    end
  end
  pEffect:AddToMap(pMap)
end
function CastBomb:FindTargetPos(seed)
  local pMap = self.m_pMap
  local success = true
  while true do
    success = true
    local tileSize = pMap:GetMapSize()
    local tmpPos = cc.p(math.random(tileSize.width), math.random(tileSize.height))
    tmpPos = cc.p(pMap:FindValidPos(tmpPos))
    tmpPos = cc.p(pMap:GetPixelPosFromTilePos(tmpPos))
    local home = self.m_actorManager:FindHome(false)
    if home and home:IsInEllipse(tmpPos) then
      success = false
    end
    if success then
      home = self.m_actorManager:FindHome(true)
      if home and home:IsInEllipse(tmpPos) then
        success = false
      end
    end
    if success then
      return tmpPos
    end
  end
end
return CastBomb
