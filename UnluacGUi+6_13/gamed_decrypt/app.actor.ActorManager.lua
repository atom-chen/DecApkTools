local GameControl = require("app.GameControl")
local UserDataManager = require("app.UserDataManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local GameDataManager = require("app.GameDataManager")
local PokedexInfoManager = require("app.info.PokedexInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local UnitDataManager = require("app.UnitDataManager")
local ActorManager = class("ActorManager", GameControl)
ActorManager.instance = nil
ActorManager.KEY_HERO = 1
ActorManager.uniqueKey = 2
ActorManager.MaxFindPathCount = 100
ActorManager.MaxFindEnemyCount = 100
function ActorManager:ctor(eType)
  ActorManager.super.ctor(self, eType)
  self:Init()
end
function ActorManager:GetInstance()
  if ActorManager.instance == nil then
    ActorManager.instance = ActorManager.new(td.GameControlType.EnterMap)
  end
  return ActorManager.instance
end
function ActorManager:Init()
  self.m_bPause = false
  self.m_iUniqueKey = ActorManager.uniqueKey
  self.m_SelfVec = {}
  self.m_EnemyVec = {}
  self.m_NeutralityVec = {}
  self.m_iFindPathCount = 0
  self.m_vWaitFindPathVec = {}
  self.m_iFindEnemyCount = 0
  self.m_vWaitFindEnemyVec = {}
  self.m_vLogTime = {
    0,
    0,
    0
  }
end
function ActorManager:ClearValue()
  for key, var in pairs(self.m_SelfVec) do
    self:RemoveActor(var)
    var:removeFromParent()
  end
  for key, var in pairs(self.m_EnemyVec) do
    self:RemoveActor(var)
    var:removeFromParent()
  end
  for key, var in pairs(self.m_NeutralityVec) do
    self:RemoveActor(var)
    var:removeFromParent()
  end
  self:Init()
end
function ActorManager:UpdateFindPathCount(_tag)
  if self.m_iFindPathCount >= ActorManager.MaxFindPathCount then
    return false
  end
  local waitNum = #self.m_vWaitFindPathVec
  if waitNum > 0 then
    if not self:_IsInWaitVec(self.m_vWaitFindPathVec, _tag) and waitNum + self.m_iFindPathCount < ActorManager.MaxFindPathCount then
      self.m_iFindPathCount = self.m_iFindPathCount + 1
      return true
    end
    local max = math.min(waitNum, ActorManager.MaxFindPathCount - self.m_iFindPathCount)
    for i = 1, max do
      if _tag == self.m_vWaitFindPathVec[i].tag then
        self.m_iFindPathCount = self.m_iFindPathCount + 1
        table.remove(self.m_vWaitFindPathVec, i)
        print("RemoveWaitFindPath:" .. _tag)
        return true
      end
    end
    return false
  end
  self.m_iFindPathCount = self.m_iFindPathCount + 1
  return true
end
function ActorManager:AddToWaitFindPathVec(tag)
  if not self:_IsInWaitVec(self.m_vWaitFindPathVec, _tag) then
    table.insert(self.m_vWaitFindPathVec, {tag = _tag, age = 0})
  end
end
function ActorManager:UpdateFindEnemyCount(_tag)
  if self.m_iFindEnemyCount >= ActorManager.MaxFindEnemyCount then
    return false
  end
  local waitNum = #self.m_vWaitFindEnemyVec
  if waitNum > 0 then
    if not self:_IsInWaitVec(self.m_vWaitFindEnemyVec, _tag) and waitNum + self.m_iFindEnemyCount < ActorManager.MaxFindEnemyCount then
      self.m_iFindEnemyCount = self.m_iFindEnemyCount + 1
      return true
    end
    local max = math.min(waitNum, ActorManager.MaxFindEnemyCount - self.m_iFindEnemyCount)
    for i = 1, max do
      if _tag == self.m_vWaitFindEnemyVec[i].tag then
        self.m_iFindEnemyCount = self.m_iFindEnemyCount + 1
        table.remove(self.m_vWaitFindEnemyVec, i)
        print("RemoveWaitFindEnemy:" .. _tag)
        return true
      end
    end
    return false
  end
  self.m_iFindEnemyCount = self.m_iFindEnemyCount + 1
  return true
end
function ActorManager:AddToWaitFindEnemyVec(_tag)
  if not self:_IsInWaitVec(self.m_vWaitFindEnemyVec, _tag) then
    table.insert(self.m_vWaitFindEnemyVec, {tag = _tag, age = 0})
  end
end
function ActorManager:_IsInWaitVec(_vec, _tag)
  for i, var in ipairs(_vec) do
    if var.tag == _tag then
      return true
    end
  end
  return false
end
function ActorManager:CreateActor(eType, id, isEnemy, info)
  local pActorBase
  if eType == td.ActorType.Hero then
    local Hero
    if id == 1100 or id == 1400 or id == 1700 then
      Hero = require("app.actor.GunHero")
    else
      Hero = require("app.actor.Hero")
    end
    pActorBase = Hero.new(td.ActorType.Hero, info)
  elseif eType == td.ActorType.Soldier then
    local Soldier
    if id >= 401 and id <= 406 then
      Soldier = require("app.actor.GunSoldier")
    else
      Soldier = require("app.actor.Soldier")
    end
    if not info then
      local soldierData = UnitDataManager:GetInstance():GetSoldierData(id)
      info = soldierData.soldierInfo
    end
    pActorBase = Soldier.new(td.ActorType.Soldier, info, isEnemy)
  elseif eType == td.ActorType.Monster then
    local pData = ActorInfoManager:GetInstance():GetMonsterInfo(id)
    if not pData then
      td.alertDebug("monster id not found:" .. id)
      return nil
    end
    local pClass
    if pData.monster_type == td.MonsterType.Patrol then
      pClass = require("app.actor.Patrol")
    elseif id == 9000 or id == 9001 then
      pClass = require("app.actor.MummyBoss")
    elseif id == 9002 or id == 9003 or id == 9004 or id == 9009 then
      pClass = require("app.actor.MonsterMachine")
    elseif id == 9004 then
      pClass = require("app.actor.GunMonster")
    elseif id == 9005 then
      pClass = require("app.actor.VampireBoss")
    elseif id == 9010 then
      pClass = require("app.actor.GHBoss1")
    elseif id >= 5105 and id <= 5107 then
      pClass = require("app.actor.GunMonster")
    else
      pClass = require("app.actor.Monster")
    end
    pActorBase = pClass.new(td.ActorType.Monster, pData)
    GameDataManager:GetInstance():AddPokedex(td.PokedexType.Monster, id)
  elseif eType == td.ActorType.Camp then
    local Camp = require("app.actor.Camp")
    pActorBase = Camp.new(td.ActorType.Camp, "")
    pActorBase:SetCanAttacked(false)
  elseif eType == td.ActorType.Home then
    local Home = require("app.actor.Home")
    pActorBase = Home.new(td.ActorType.Home, "")
  elseif eType == td.ActorType.ShadeHole then
    local ShadeHole = require("app.actor.ShadeHole")
    pActorBase = ShadeHole.new(td.ActorType.ShadeHole, "")
  elseif eType == td.ActorType.Stronghold then
    local Stronghold = require("app.actor.Stronghold")
    pActorBase = Stronghold.new(td.ActorType.Stronghold, "")
  elseif eType == td.ActorType.ZiYuan then
    local ZiYuan = require("app.actor.ZiYuan")
    pActorBase = ZiYuan.new(td.ActorType.ZiYuan, "")
  elseif eType == td.ActorType.FangYuTa then
    local FangYuTa = require("app.actor.FangYuTa")
    local pData = ActorInfoManager:GetInstance():GetTowerInfo(id)
    pActorBase = FangYuTa.new(td.ActorType.FangYuTa, pData, isEnemy)
  elseif eType == td.ActorType.Door then
    local Door = require("app.actor.Door")
    pActorBase = Door.new(td.ActorType.Door)
  elseif eType == td.ActorType.Coffers then
    pActorBase = require("app.actor.Coffers").new(td.ActorType.Coffers)
  elseif eType == td.ActorType.SummonUnit then
    pActorBase = require("app.actor.SummonUnit").new(td.ActorType.SummonUnit, info)
  end
  if pActorBase then
    pActorBase:retain()
    pActorBase:SetID(id)
    local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
    pActorBase:SetBehaveType(ActorManager.GetBehaveType(mapType, eType))
    if mapType ~= td.MapType.PVP and mapType ~= td.MapType.PVPGuild and mapType ~= td.MapType.Rob and eType == td.ActorType.Hero then
      pActorBase:setTag(ActorManager.KEY_HERO)
      pActorBase:SetGroupType(td.GroupType.Self)
      return pActorBase
    end
    pActorBase:setTag(self.m_iUniqueKey)
    if eType == td.ActorType.Camp or eType == td.ActorType.ShadeHole or eType == td.ActorType.ZiYuan or eType == td.ActorType.Stronghold or eType == td.ActorType.Coffers then
      pActorBase:SetGroupType(td.GroupType.Neutrality)
      self.m_NeutralityVec[self.m_iUniqueKey] = pActorBase
    elseif isEnemy then
      pActorBase:SetGroupType(td.GroupType.Enemy)
      self.m_EnemyVec[self.m_iUniqueKey] = pActorBase
    else
      pActorBase:SetGroupType(td.GroupType.Self)
      self.m_SelfVec[self.m_iUniqueKey] = pActorBase
    end
    self.m_iUniqueKey = self.m_iUniqueKey + 1
  end
  td.dispatchEvent(td.ACTOR_BORN, pActorBase:getTag())
  return pActorBase
end
function ActorManager:RemoveRelation(pActor)
  local eRealGroupType = pActor:GetRealGroupType()
  local eGroupType = pActor:GetGroupType()
  if eGroupType == td.GroupType.Self or eRealGroupType == td.GroupType.Self then
    for k, v in pairs(self.m_EnemyVec) do
      if v and v:GetEnemy() == pActor then
        v:SetEnemy(nil)
      end
    end
  end
  if eGroupType == td.GroupType.Enemy or eRealGroupType == td.GroupType.Enemy then
    for k, v in pairs(self.m_SelfVec) do
      if v and v:GetEnemy() == pActor then
        v:SetEnemy(nil)
      end
    end
  end
end
function ActorManager:RemoveActor(pActor)
  local key = pActor:getTag()
  local eRealGroupType = pActor:GetRealGroupType()
  if eRealGroupType == td.GroupType.Self then
    self.m_SelfVec[key] = nil
  elseif eRealGroupType == td.GroupType.Enemy then
    self.m_EnemyVec[key] = nil
  else
    self.m_NeutralityVec[key] = nil
  end
  pActor:release()
  td.dispatchEvent(td.ACTOR_REMOVE, key)
end
function ActorManager:ChangeActorGroup(pActor, groupType)
  local key = pActor:getTag()
  local oriGroupType = pActor:GetRealGroupType()
  if groupType == oriGroupType then
    return
  end
  self:RemoveRelation(pActor)
  if oriGroupType == td.GroupType.Self then
    self.m_SelfVec[key] = nil
  elseif oriGroupType == td.GroupType.Enemy then
    self.m_EnemyVec[key] = nil
  else
    self.m_NeutralityVec[key] = nil
  end
  if groupType == td.GroupType.Self then
    pActor:SetGroupType(td.GroupType.Self)
    self.m_SelfVec[key] = pActor
  elseif groupType == td.GroupType.Enemy then
    pActor:SetGroupType(td.GroupType.Enemy)
    self.m_EnemyVec[key] = pActor
  else
    pActor:SetGroupType(td.GroupType.Neutrality)
    self.m_NeutralityVec[key] = pActor
  end
end
function ActorManager:Update(dt)
  if self.m_bPause then
    return
  end
  self.m_iFindPathCount = 0
  self.m_iFindEnemyCount = 0
  local vRemoveActors = {}
  local actorVecs = {
    self.m_SelfVec,
    self.m_EnemyVec,
    self.m_NeutralityVec
  }
  for i, vec in ipairs(actorVecs) do
    for k, v in pairs(vec) do
      if v:IsInScene() and not v:IsRemove() then
        v:Update(dt)
      else
        self:RemoveRelation(v)
        table.insert(vRemoveActors, v)
      end
    end
  end
  for i, v in ipairs(vRemoveActors) do
    self:RemoveActor(v)
    ActorManager.FadeOutActorAndRemove(v)
  end
  local vWaitVec = {
    self.m_vWaitFindPathVec,
    self.m_vWaitFindEnemyVec
  }
  local vRemoveCount = {
    ActorManager.MaxFindPathCount - self.m_iFindPathCount,
    ActorManager.MaxFindEnemyCount - self.m_iFindEnemyCount
  }
  for i, vec in ipairs(vWaitVec) do
    local waitCount = #vec
    local e = math.min(waitCount, vRemoveCount[i])
    if e > 0 then
      for i = e, 1, -1 do
        if 1 <= vec[i].age then
          table.remove(vec, i)
        else
          vec[i].age = vec[i].age + 1
        end
      end
    end
  end
end
function ActorManager:FindCamp(id)
  for k, v in pairs(self.m_NeutralityVec) do
    if v:GetType() == td.ActorType.Camp and v:GetID() == id then
      return v
    end
  end
  return nil
end
function ActorManager:FindHome(isEnemy)
  if isEnemy then
    for k, v in pairs(self.m_EnemyVec) do
      if v:GetType() == td.ActorType.Home then
        return v
      end
    end
  else
    for k, v in pairs(self.m_SelfVec) do
      if v:GetType() == td.ActorType.Home then
        return v
      end
    end
  end
  return nil
end
function ActorManager:FindActorByTag(tag, isEnemy)
  if tag == nil then
    return nil
  end
  if (isEnemy == nil or isEnemy == true) and self.m_EnemyVec[tag] then
    return self.m_EnemyVec[tag]
  end
  if (isEnemy == nil or isEnemy == false) and self.m_SelfVec[tag] then
    return self.m_SelfVec[tag]
  end
  return nil
end
function ActorManager:FindActorById(id, isEnemy)
  if id == nil then
    return nil
  end
  if isEnemy == nil or isEnemy == true then
    for k, v in pairs(self.m_EnemyVec) do
      if v:GetID() == id then
        return v
      end
    end
  end
  if isEnemy == nil or isEnemy == false then
    for k, v in pairs(self.m_SelfVec) do
      if v:GetID() == id then
        return v
      end
    end
  end
  return nil
end
function ActorManager:FindActorByFunc(func, isEnemy)
  local actors = {}
  if isEnemy == nil or isEnemy == true then
    table.walk(self.m_EnemyVec, function(v, k)
      if func(v) then
        table.insert(actors, v)
      end
    end)
  end
  if isEnemy == nil or isEnemy == false then
    table.walk(self.m_SelfVec, function(v, k)
      if func(v) then
        table.insert(actors, v)
      end
    end)
  end
  return actors
end
function ActorManager:CreateActorPathById(pActor, pathId, isReverse, bornPos)
  if not pActor then
    return
  end
  pActor:SetPathId(pathId, isReverse)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local vPath = pMap:GetMapPath(pActor:GetPathId())
  local vTemp = {}
  for k, v in pairs(vPath) do
    local tempPos = pMap:GetPixelPosFromTilePos(PulibcFunc:GetInstance():GetPointForInt(v))
    table.insert(vTemp, pMap:GetTilePosFromPixelPos(tempPos))
  end
  local beginPos, nextPos, endPos = cc.p(0, 0), cc.p(0, 0), cc.p(0, 0)
  if 0 < table.getn(vTemp) then
    if isReverse then
      beginPos = vTemp[#vTemp]
      nextPos = vTemp[#vTemp - 1]
      endPos = vTemp[1]
      pActor:SetCurPathCount(#vTemp)
    else
      beginPos = vTemp[1]
      nextPos = vTemp[2]
      endPos = vTemp[#vTemp]
      pActor:SetCurPathCount(1)
    end
  end
  if bornPos then
    beginPos = pMap:GetTilePosFromPixelPos(cc.p(bornPos.x, bornPos.y))
    nextPos = endPos
  end
  if nextPos and nextPos.x >= beginPos.x then
    pActor:SetDirType(td.DirType.Right)
  else
    pActor:SetDirType(td.DirType.Left)
  end
  pActor:setPosition(pMap:GetPixelPosFromTilePos(beginPos))
  pActor:SetFinalTargetPos(pMap:GetPixelPosFromTilePos(endPos))
  GameDataManager:GetInstance():SetActorInTile(PulibcFunc:GetInstance():GetIntForPoint(beginPos), PulibcFunc:GetInstance():GetIntForPoint(beginPos), pActor)
  local mapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  if mapInfo.type ~= td.MapType.PVP and mapInfo.type ~= td.MapType.PVPGuild and mapInfo.type ~= td.MapType.Endless then
    local vPath = pMap:GetMapPath(pActor:GetPathId())
    if #vPath > 0 then
      local vTemp = {}
      for i, v in ipairs(vPath) do
        local tempPos = pMap:GetPixelPosFromTilePos(PulibcFunc:GetInstance():GetPointForInt(v))
        table.insert(vTemp, pMap:GetTilePosFromPixelPos(tempPos))
      end
      pActor:SetPath(vTemp)
    end
  end
end
function ActorManager:CreateActorPath(pActor, bornPos, mapPos)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  pActor:setPosition(bornPos)
  local campBornTilePos = pMap:GetTilePosFromPixelPos(bornPos)
  GameDataManager:GetInstance():SetActorInTile(PulibcFunc:GetInstance():GetIntForPoint(campBornTilePos), PulibcFunc:GetInstance():GetIntForPoint(campBornTilePos), pActor)
  local mapType = pMap:GetMapType()
  local mapTilePos = pMap:GetTilePosFromPixelPos(mapPos)
  local iPathID = pMap:GetPathID(mapTilePos, GameDataManager:GetInstance():GetGameMapInfo().role_move_path)
  pActor:SetPathId(iPathID)
  local vPath = pMap:GetMapPath(pActor:GetPathId())
  if pActor:GetBehaveType() == td.BehaveType.Defend then
    local dis = 0
    if 0 < table.nums(vPath) then
      local vTemp = {}
      for i, v in ipairs(vPath) do
        local tempPos = pMap:GetPixelPosFromTilePos(PulibcFunc:GetInstance():GetPointForInt(v))
        local startPos = {}
        if i == 1 then
          startPos = cc.p(pActor:getPosition())
        else
          startPos = pMap:GetPixelPosFromTilePos(PulibcFunc:GetInstance():GetPointForInt(vPath[i - 1]))
        end
        if cc.pDistanceSQ(startPos, mapPos) <= cc.pDistanceSQ(startPos, tempPos) then
          table.insert(vTemp, mapTilePos)
          break
        else
          local tempTilePos = pMap:GetTilePosFromPixelPos(tempPos)
          table.insert(vTemp, tempTilePos)
          if cc.pFuzzyEqual(tempTilePos, mapTilePos, 0) then
            break
          end
        end
      end
      pActor:SetPath(vTemp)
      pActor:SetCurPathCount(1)
    end
    pActor:SetFinalTargetPos(mapPos)
  elseif pActor:GetBehaveType() == td.BehaveType.Attack then
    if 0 < table.nums(vPath) then
      local vTemp = {}
      for i, v in ipairs(vPath) do
        local tempPos = pMap:GetPixelPosFromTilePos(PulibcFunc:GetInstance():GetPointForInt(v))
        table.insert(vTemp, pMap:GetTilePosFromPixelPos(tempPos))
      end
      pActor:SetPath(vTemp)
      pActor:SetCurPathCount(1)
      pActor:SetFinalTargetPos(pMap:GetPixelPosFromTilePos(vTemp[#vTemp]))
    end
  elseif pActor:GetBehaveType() == td.BehaveType.Collect and 0 < table.nums(vPath) then
    local vTemp = {}
    for i, v in ipairs(vPath) do
      local tempPos = pMap:GetPixelPosFromTilePos(PulibcFunc:GetInstance():GetPointForInt(v))
      table.insert(vTemp, pMap:GetTilePosFromPixelPos(tempPos))
    end
    pActor:SetPath(vTemp)
    pActor:SetCurPathCount(1)
    pActor:SetFinalTargetPos(pMap:GetPixelPosFromTilePos(vTemp[#vTemp]))
  end
end
function ActorManager:CreateActorForCamp(id, pos)
  local gdMng = GameDataManager:GetInstance()
  local pCamp = self:FindCamp(id)
  local soldierId = pCamp:GetSoldierId()
  local pActor
  if gdMng:GetGameMapInfo().id == td.TRAIN_ID then
    local soldierInfo = gdMng:GetGuideSoldiers()[soldierId].soldierInfo
    pActor = self:CreateActor(td.ActorType.Soldier, soldierId, false, soldierInfo)
  else
    pActor = self:CreateActor(td.ActorType.Soldier, soldierId, false)
  end
  if pActor then
    gdMng:UpdateStarCondition(td.StarLevel.UNIT_LIMIT, pActor:GetCareerType())
    if soldierId % 100 > 1 then
      gdMng:UpdateStarCondition(td.StarLevel.ONLY_PRIMITIVE, 1)
    end
    local pMap = gdMng:GetGameMap()
    local campBornPos = pCamp:GetBornPos()
    self:CreateActorPath(pActor, campBornPos, pos)
  end
  return pActor
end
function ActorManager:SetPause(bPause)
  self.m_bPause = bPause
end
function ActorManager:IsPause()
  return self.m_bPause
end
function ActorManager:GetSelfVec()
  return self.m_SelfVec
end
function ActorManager:GetEnemyVec()
  return self.m_EnemyVec
end
function ActorManager:GetNeutralityVec()
  return self.m_NeutralityVec
end
function ActorManager:SetHero(pHero)
  if self.m_SelfVec[ActorManager.KEY_HERO] then
    local lastHero = self.m_SelfVec[ActorManager.KEY_HERO]
    self:RemoveRelation(lastHero)
    self:RemoveActor(lastHero)
    ActorManager.FadeOutActorAndRemove(lastHero)
  end
  self.m_SelfVec[ActorManager.KEY_HERO] = pHero
end
function ActorManager:IsAllSideDead(bEnemy)
  local vActor = bEnemy and self.m_EnemyVec or self.m_SelfVec
  for k, v in pairs(vActor) do
    if v and self:IsCreature(v) and not v:IsRemove() and not v:IsDead() then
      return false
    end
  end
  return true
end
function ActorManager:IsCreature(pActor)
  local actorType = pActor:GetType()
  if actorType == td.ActorType.Hero or actorType == td.ActorType.Soldier or actorType == td.ActorType.Monster then
    return true
  end
  return false
end
function ActorManager:IsAllEnemyDeadExceptBoss()
  for k, v in pairs(self.m_EnemyVec) do
    if v and v:GetType() ~= td.ActorType.Home and not v:IsDead() and v:GetType() == td.ActorType.Monster and v:GetYXWave() then
      local pData = require("app.info.ActorInfoManager"):GetInstance():GetMonsterInfo(v:GetID())
      if pData.monster_type ~= td.MonsterType.BOSS or pData.monster_type == td.MonsterType.BOSS and not v:IsNothingnessState() then
        return false
      end
    end
  end
  return true
end
function ActorManager.FadeOutActorAndRemove(pActor)
  if pActor:GetType() == td.ActorType.Home or not pActor:IsInScene() then
    return
  end
  if pActor and pActor.m_pSkeleton then
    pActor.m_pSkeleton:runAction(cca.seq({
      cca.fadeOut(0.3),
      cca.cb(function()
        pActor:removeFromParent(true)
      end)
    }))
  else
    pActor:removeFromParent(true)
  end
end
function ActorManager.GetBehaveType(mapType, actorType)
  local vBuildingType = {
    td.ActorType.Camp,
    td.ActorType.Door,
    td.ActorType.FangYuTa,
    td.ActorType.Home,
    td.ActorType.ShadeHole,
    td.ActorType.Stronghold,
    td.ActorType.ZiYuan
  }
  if table.indexof(vBuildingType, actorType) then
    return td.BehaveType.Non
  end
  if mapType == td.MapType.TuiTa or mapType == td.MapType.PVP or mapType == td.MapType.PVPGuild or mapType == td.MapType.Trial then
    return td.BehaveType.Attack
  elseif mapType == td.MapType.ZiYuan or mapType == td.MapType.Rob or mapType == td.MapType.Collect then
    if actorType == td.ActorType.Soldier then
      return td.BehaveType.Collect
    elseif actorType == td.ActorType.Monster then
      return td.BehaveType.UFO
    end
  end
  return td.BehaveType.Defend
end
function ActorManager:LogTime()
  print("self:" .. self.m_vLogTime[1] .. ",enemy:" .. self.m_vLogTime[2])
end
return ActorManager
