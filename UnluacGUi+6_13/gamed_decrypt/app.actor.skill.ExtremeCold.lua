local AreaSkill = import(".AreaSkill")
local SkillInfoManager = require("app.info.SkillInfoManager")
local BuffManager = require("app.buff.BuffManager")
local ExtremeCold = class("ExtremeCold", AreaSkill)
function ExtremeCold:ctor(pActor, id, pData)
  ExtremeCold.super.ctor(self, pActor, id, pData)
end
function ExtremeCold:DidHit(pActor, pEffect)
  ExtremeCold.super.DidHit(self, pActor, pEffect)
  if pActor and pActor:IsCanBeMoved() then
    self:HitBack(pActor)
  end
end
function ExtremeCold:HitBack(pActor)
  local enemyPos = cc.p(pActor:getPosition())
  local dir = cc.pNormalize(cc.pSub(enemyPos, self.m_skillPos))
  local GameDataManager = require("app.GameDataManager")
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local backPos
  local dis = 30 * math.random(3)
  repeat
    dis = dis - 10
    backPos = cc.pAdd(enemyPos, cc.pMul(dir, dis))
  until pMap:IsLineWalkable(enemyPos, backPos) or dis <= 0
  pActor:stopActionByTag(td.HitBackActionTag)
  local hitbackAction = cca.moveTo(dis / 500, backPos.x, backPos.y)
  hitbackAction:setTag(td.HitBackActionTag)
  pActor:runAction(hitbackAction)
end
return ExtremeCold
