local SkillBase = require("app.actor.skill.SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local GameDataManager = require("app.GameDataManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local DeadCallPassive = class("DeadCallPassive", SkillBase)
function DeadCallPassive:ctor(pActor, id, pData)
  DeadCallPassive.super.ctor(self, pActor, id, pData)
  local tmp = string.split(self.m_pData.custom_data, ";")
  local monsterMap = string.split(tmp[1], "#")
  self.m_iMonsterID = tonumber(monsterMap[1]) or 6010
  self.m_iMonsterNum = tonumber(monsterMap[2]) or 1
  self.proRatio = tonumber(tmp[2]) or 0.5
  self.life = tonumber(tmp[3]) or 30
  self.m_bActive = false
end
function DeadCallPassive:Active()
  self.m_bActive = true
end
function DeadCallPassive:Inactive()
  self.m_bActive = false
end
function DeadCallPassive:Update(dt)
  if not self.m_bActive or nil == self.m_pActor then
    return
  end
  if not self.m_pActor:IsDead() then
    return
  end
  self:OnWork()
  self.m_bActive = false
end
function DeadCallPassive:OnWork()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local selfPos = cc.p(self.m_pActor:getPosition())
  local pEffect = EffectManager:GetInstance():CreateEffect(self.m_atkEffect, nil, nil, selfPos)
  pEffect:AddToMap(pMap)
  local angle = math.random(360)
  for i = 0, self.m_iMonsterNum - 1 do
    local monster
    if self.m_iMonsterID == 1 then
      monster = self:CreateDeadBody()
    else
      monster = ActorManager:GetInstance():CreateActor(td.ActorType.Monster, self.m_iMonsterID, true)
    end
    monster:SetEnterEffect(self.m_atkEffect)
    monster:SetEnemy(self.m_pActor:GetEnemy())
    angle = angle + i * 120
    local mPos = cc.pAdd(selfPos, cc.p(15 * math.cos(math.rad(angle)), 15 * math.sin(math.rad(angle))))
    monster:setPosition(mPos)
    local mTilePos = pMap:GetTilePosFromPixelPos(mPos)
    GameDataManager:GetInstance():SetActorInTile(PulibcFunc:GetInstance():GetIntForPoint(mTilePos), PulibcFunc:GetInstance():GetIntForPoint(mTilePos), monster)
    local iPathID = self.m_pActor:GetPathId()
    monster:SetPathId(iPathID, self.m_pActor:GetInverted())
    monster:SetPath(self.m_pActor:GetPath())
    monster:SetCurPathCount(self.m_pActor:GetCurPathCount())
    monster:SetFinalTargetPos(self.m_pActor:GetFinalTargetPos())
    monster:SetDirType(self.m_pActor:GetDirType())
    pMap:addChild(monster, pMap:GetPiexlSize().height - monster:getPositionY(), monster:getTag())
  end
end
function DeadCallPassive:CreateDeadBody()
  local pData = clone(self.m_pActor:GetData())
  pData.property[td.Property.HP].value = self.m_pActor:GetMaxHp() * self.proRatio
  pData.skill = self:_filterSkill(pData.skill)
  pData.life = self.life
  local bIsEnemy = self.m_pActor:GetGroupType() == td.GroupType.Enemy
  local monster = ActorManager:GetInstance():CreateActor(td.ActorType.SummonUnit, pData.id, bIsEnemy, pData)
  require("app.buff.BuffManager"):GetInstance():AddBuff(monster, 97)
  return monster
end
function DeadCallPassive:_filterSkill(skills)
  local result = {}
  local siMng = SkillInfoManager:GetInstance()
  for i, var in ipairs(skills) do
    local skillInfo = siMng:GetInfo(var)
    if skillInfo and skillInfo.type == td.SkillType.Normal then
      table.insert(result, var)
      break
    end
  end
  return result
end
return DeadCallPassive
