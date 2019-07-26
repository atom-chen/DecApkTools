local SkillBase = require("app.actor.skill.SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local KillPassive = class("KillPassive", SkillBase)
function KillPassive:ctor(pActor, id, pData)
  KillPassive.super.ctor(self, pActor, id, pData)
  local monsterMap = string.split(pData.custom_data, "#")
  self.m_iMonsterID = tonumber(monsterMap[1]) or 6010
  self.m_iMonsterNum = tonumber(monsterMap[2]) or 1
  self.m_bActive = false
end
function KillPassive:Active()
  self.m_bActive = true
end
function KillPassive:Inactive()
  self.m_bActive = false
end
function KillPassive:OnWork(enemyTag)
  local pEnemy = ActorManager:GetInstance():FindActorByTag(enemyTag)
  if not pEnemy then
    return
  end
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local enemyPos = cc.p(pEnemy:getPosition())
  local bIsEnemy = self.m_pActor:GetGroupType() == td.GroupType.Enemy
  for i = 1, self.m_iMonsterNum do
    local monster = ActorManager:GetInstance():CreateActor(td.ActorType.Monster, self.m_iMonsterID, bIsEnemy)
    monster:SetEnterEffect(18)
    local mPos = cc.p(enemyPos.x + math.random(20) - 10, enemyPos.y + math.random(20) - 10)
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
return KillPassive
