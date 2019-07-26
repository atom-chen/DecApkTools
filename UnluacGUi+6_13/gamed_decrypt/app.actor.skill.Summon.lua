local SkillBase = import(".SkillBase")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local scheduler = require("framework.scheduler")
local Summon = class("Summon", SkillBase)
function Summon:ctor(pActor, id, pData)
  Summon.super.ctor(self, pActor, id, pData)
end
function Summon:Execute(endCallback)
  self.m_pActor:PlayAnimation(self.m_pData.skill_name, false)
  self.m_pActor:performWithDelay(function()
    self:Summon()
    endCallback()
    self.m_fStartTime = 0
  end, 1)
  G_SoundUtil:PlaySound(312, false)
end
function Summon:Summon()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local monsterId = tonumber(self.m_pData.custom_data)
  local monster = ActorManager:GetInstance():CreateActor(td.ActorType.Monster, monsterId, true)
  monster:SetEnterEffect(18)
  monster:SetEnemy(self.m_pActor:GetEnemy())
  local angle = math.random(360)
  local mPos = cc.pAdd(cc.p(self.m_pActor:getPosition()), cc.p(30 * math.cos(math.rad(angle)), 30 * math.sin(math.rad(angle))))
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
return Summon
