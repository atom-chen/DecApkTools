local Summon = import(".Summon")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local SummonShadow = class("SummonShadow", Summon)
function SummonShadow:ctor(pActor, id, pData)
  SummonShadow.super.ctor(self, pActor, id, pData)
end
function SummonShadow:Summon()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local pData = clone(self.m_pActor:GetData())
  pData.property[td.Property.HP].value = self.m_pActor:GetMaxHp() * 0.5
  pData.skill = self:_filterSkill(pData.skill)
  pData.life = tonumber(self.m_pData.custom_data)
  pData.summonerTag = self.m_pActor:getTag()
  local bIsEnemy = self.m_pActor:GetGroupType() == td.GroupType.Enemy
  local monster = ActorManager:GetInstance():CreateActor(td.ActorType.SummonUnit, pData.id, bIsEnemy, pData)
  monster:SetEnterEffect(18)
  local mPos = self:GetSkillPos()
  monster:setPosition(mPos)
  local mTilePos = pMap:GetTilePosFromPixelPos(mPos)
  GameDataManager:GetInstance():SetActorInTile(PulibcFunc:GetInstance():GetIntForPoint(mTilePos), PulibcFunc:GetInstance():GetIntForPoint(mTilePos), monster)
  pMap:addChild(monster, pMap:GetPiexlSize().height - monster:getPositionY(), monster:getTag())
  monster:setColor(cc.c3b(0, 0, 0))
end
function SummonShadow:_filterSkill(skills)
  local result = {3053, 3054}
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
return SummonShadow
