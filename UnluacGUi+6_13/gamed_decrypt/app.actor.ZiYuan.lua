local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local ActorBase = import(".ActorBase")
local ZiYuan = class("ZiYuan", ActorBase)
function ZiYuan:ctor(eType, fileNmae)
  ZiYuan.super.ctor(self, eType, fileNmae)
  self.m_vPath = {}
  self.m_PathVec = {}
  self.m_pathCount = 1
  self.m_eResource = td.ResourceType.Non
  self.m_iNum = 0
  self.m_iSpeed = 10
  self.m_pTarget = nil
  self.m_startTime = 0
  self:setNodeEventEnabled(true)
end
function ZiYuan:onEnter()
  ZiYuan.super.onEnter(self)
end
function ZiYuan:onExit()
  ZiYuan.super.onExit(self)
end
function ZiYuan:Update(dt)
  ZiYuan.super.Update(self)
  local curPos = cc.p(self:getPosition())
  if self.m_pTarget then
    if self.m_pTarget:IsDead() then
      self.m_pTarget = nil
      if self.m_pathCount > #self.m_vPath then
        self.m_pathCount = #self.m_vPath
      end
    else
      local pos = cc.p(self.m_pTarget:getPosition())
      if cc.pDistanceSQ(curPos, pos) <= 2500 then
        self.m_pTarget:PickupCollectionRes(self.m_eResource, self.m_iNum)
        self:SetRemove(true)
        return
      end
      local normalizePos = cc.pNormalize(cc.pSub(pos, curPos))
      local tempPos = cc.pAdd(curPos, cc.pMul(normalizePos, 600 * dt))
      self:setPosition(tempPos)
      return
    end
  end
  local pMap = GameDataManager:GetInstance():GetGameMap()
  if #self.m_PathVec == 0 and self.m_pathCount <= #self.m_vPath then
    local targetPos = self.m_vPath[self.m_pathCount]
    self.m_pathCount = self.m_pathCount + 1
    self.m_PathVec = pMap:FindPath(curPos, pMap:GetPixelPosFromTilePos(targetPos))
  end
  if #self.m_PathVec ~= 0 then
    local pos = self.m_PathVec[1]
    local normalizePos = cc.pNormalize(cc.pSub(pos, curPos))
    local tempPos = cc.pAdd(curPos, cc.pMul(normalizePos, self:GetSpeed() * dt))
    if PulibcFunc:GetInstance():GetDirection(curPos, pos) == PulibcFunc:GetInstance():GetDirection(tempPos, pos) and not cc.pFuzzyEqual(normalizePos, cc.p(0, 0), 0) then
      self:setPosition(tempPos)
    else
      tempPos = pos
      table.remove(self.m_PathVec, 1)
      self:setPosition(tempPos)
      if self.m_pathCount > #self.m_vPath and table.nums(self.m_PathVec) == 0 then
        self:SetRemove(true)
        return
      end
    end
  end
  local vec = ActorManager:GetInstance():GetSelfVec()
  local curPos = cc.p(self:getPosition())
  for i, v in pairs(vec) do
    if v:GetType() == td.ActorType.Soldier then
      local pos = cc.p(v:getPosition())
      if not v:IsDead() and not v:IsAttractRes() and cc.pDistanceSQ(curPos, pos) <= 10000 then
        local eType, iNum = v:GetCollectionRes()
        if eType == td.ResourceType.Non then
          v:SetAttractRes(true)
          self.m_pTarget = v
          self.m_PathVec = {}
        end
      end
    end
  end
  pMap:reorderChild(self, pMap:GetPiexlSize().height - self:getPositionY())
end
function ZiYuan:SetPath(v)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local pos = pMap:GetTilePosFromPixelPos(cc.p(self:getPosition()))
  local minCount = GetMinCountForPath(v, pos)
  if minCount > #v then
    minCount = #v
  elseif minCount == 0 then
    minCount = 1
  end
  local vTemp = {}
  if minCount >= #v - 1 then
    table.insert(vTemp, v[minCount])
  else
    for i = minCount + 1, #v do
      table.insert(vTemp, v[i])
    end
  end
  self.m_vPath = vTemp
end
function ZiYuan:GetPath()
  return self.m_vPath
end
function ZiYuan:SetCollectionRes(eCollectionResType, iCollectionRes)
  self.m_eResource = eCollectionResType
  self.m_iNum = iCollectionRes
end
function ZiYuan:GetSpeed()
  return self.m_iSpeed
end
return ZiYuan
