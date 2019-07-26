local Summon = import(".Summon")
local ActorManager = require("app.actor.ActorManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local GameDataManager = require("app.GameDataManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local BuffManager = require("app.buff.BuffManager")
local SummonSprite = class("SummonSprite", Summon)
function SummonSprite:ctor(pActor, id, pData)
  SummonSprite.super.ctor(self, pActor, id, pData)
  local tmp = string.split(self.m_pData.custom_data, ";")
  self.vMonsterId = string.split(tmp[1], "#")
  self.atkRatio = tonumber(tmp[2]) or 0.5
  self.life = tonumber(tmp[3]) or 10
end
function SummonSprite:Summon()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local bIsEnemy = self.m_pActor:GetGroupType() == td.GroupType.Enemy
  local skillPos = self:GetSkillPos()
  for i, mId in ipairs(self.vMonsterId) do
    local pData = self:MakeData(tonumber(mId))
    local monster = ActorManager:GetInstance():CreateActor(td.ActorType.SummonUnit, mId, bIsEnemy, pData)
    monster:SetEnterEffect(18)
    BuffManager:GetInstance():AddBuff(monster, 476)
    local angle = (i - 1) * 120
    local mPos = cc.pAdd(skillPos, cc.p(50 * math.cos(math.rad(angle)), 50 * math.sin(math.rad(angle))))
    monster:setPosition(mPos)
    local mTilePos = pMap:GetTilePosFromPixelPos(mPos)
    GameDataManager:GetInstance():SetActorInTile(PulibcFunc:GetInstance():GetIntForPoint(mTilePos), PulibcFunc:GetInstance():GetIntForPoint(mTilePos), monster)
    pMap:addChild(monster, pMap:GetPiexlSize().height - monster:getPositionY(), monster:getTag())
  end
end
function SummonSprite:MakeData(monsterId)
  local summonerData = clone(self.m_pActor:GetData())
  local pData = ActorInfoManager:GetInstance():GetMonsterInfo(monsterId)
  pData.property[td.Property.Atk].value = summonerData.property[td.Property.Atk].value * self.atkRatio
  pData.life = self.life
  pData.summonerTag = self.m_pActor:getTag()
  return pData
end
return SummonSprite
