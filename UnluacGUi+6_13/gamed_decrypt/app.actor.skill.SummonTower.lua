local Summon = import(".Summon")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local SummonTower = class("SummonTower", Summon)
function SummonTower:ctor(pActor, id, pData)
  SummonTower.super.ctor(self, pActor, id, pData)
end
function SummonTower:Summon()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local bIsEnemy = self.m_pActor:GetGroupType() == td.GroupType.Enemy
  local monster = ActorManager:GetInstance():CreateActor(td.ActorType.FangYuTa, 8000, bIsEnemy)
  local mPos = self:GetSkillPos()
  monster:setPosition(mPos)
  local mTilePos = pMap:GetTilePosFromPixelPos(mPos)
  GameDataManager:GetInstance():SetActorInTile(PulibcFunc:GetInstance():GetIntForPoint(mTilePos), PulibcFunc:GetInstance():GetIntForPoint(mTilePos), monster)
  pMap:addChild(monster, pMap:GetPiexlSize().height - monster:getPositionY(), monster:getTag())
end
return SummonTower
