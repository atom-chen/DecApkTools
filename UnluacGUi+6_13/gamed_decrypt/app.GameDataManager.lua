local GameControl = require("app.GameControl")
local MissionInfoManager = require("app.info.MissionInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local UnitDataManager = require("app.UnitDataManager")
local PokedexInfoManager = require("app.info.PokedexInfoManager")
local GameDataManager = class("GameDataManager", GameControl)
GameDataManager.instance = nil
function GameDataManager:ctor(eType)
  GameDataManager.super.ctor(self, eType)
  self:Init()
end
function GameDataManager:GetInstance()
  if GameDataManager.instance == nil then
    GameDataManager.instance = GameDataManager.new(td.GameControlType.EnterMap)
  end
  return GameDataManager.instance
end
function GameDataManager:Update(dt)
  if self.bPause then
    return
  end
  for i, v in ipairs(self.vHeros) do
    for id, var in pairs(v.skillCD) do
      var.time = cc.clampf(var.time + dt, 0, 1000)
    end
  end
end
function GameDataManager:Init()
  self.bFightOver = false
  self.bPause = false
  self.bPauseUI = false
  self.waveGapTime = 0
  self.iCurMonsterCount = 1
  self.iMaxMonsterCount = 0
  self.iCurSubMonsterCount = 1
  self.iMaxSubMonsterCount = 0
  self.bCreateAll = false
  self.iMonsterWave = 1
  self.iMaxPopulation = 0
  self.iCurPopulation = 0
  self.iMaxCampNum = 0
  self.vForbidCamps = {}
  self.iDeadBoss = 0
  self.iWaveReward = 0
  self.iDeputyNum = 0
  self.bIsTraining = false
  self.dicStarCondition = {}
  self.selUnit = {}
  self.selUnitNum = {}
  self.deadUnit = {}
  self.iCurShiYouCount = 0
  self.iCurShuiJingCount = 0
  self.iCurDanYaoCount = 0
  self.iCurGoldCount = 0
  self.iCurEnergyCount = 0
  self.iMaxShiYouCount = 0
  self.iMaxShuiJingCount = 0
  self.iMaxDanYaoCount = 0
  self.iMaxGoldCount = 0
  self.iMaxEnergyCount = 0
  self.mBattleLog = {}
  self.iEnemyLevel = 0
  self.iMissionId = 0
  self.oriMissionData = nil
  self.gameMap = nil
  self.gameMapInfo = nil
  self.ActorTiles = {}
  self.bornPos = nil
  self.vClearPath = {}
  self.vAllPassBlock = {}
  self.iCurHeroIndex = 0
  self.iChangeHeroIndex = nil
  self.pChangeHeroPos = nil
  self.vHeros = {}
  self.ptSkillTarget = cc.p(-1, -1)
  self.iRebornTime = 0
  self.iClearCDTime = 0
  self.pFocusNode = nil
  self.iActorCanTouch = 0
  self.vNewMonsterIds = {}
  self.vToSendPokedex = {}
  self.guideSoldiers = {}
end
function GameDataManager:ClearValue()
  self:Init()
end
function GameDataManager:SetCampRole(soldiers)
  self.selUnit = soldiers
  local unitMng = UnitDataManager:GetInstance()
  for i, roleId in pairs(self.selUnit) do
    self.selUnitNum[roleId] = unitMng:GetSoldierNum(roleId)
  end
end
function GameDataManager:GetCampRole(id)
  return self.selUnit[id]
end
function GameDataManager:GetSoldierNum(id)
  return self.selUnitNum[id] or 0
end
function GameDataManager:SetGuideSoldiers(data)
  self.guideSoldiers = data
end
function GameDataManager:GetGuideSoldiers()
  return self.guideSoldiers
end
function GameDataManager:InitHeros(herosData)
  if #herosData < 1 then
    return
  end
  local stiMng = require("app.info.StrongInfoManager"):GetInstance()
  local udMng = UserDataManager:GetInstance()
  for i, data in ipairs(herosData) do
    local heroData = {}
    heroData.hid = data.hid
    heroData.heroInfo = stiMng:GetHeroFinalInfo(data)
    heroData.level = data.level
    heroData.bDead = false
    heroData.skillCD = {}
    for j, skillId in ipairs(heroData.heroInfo.skill) do
      local skillInfo = require("app.info.SkillInfoManager"):GetInstance():GetInfo(skillId)
      if skillInfo and (skillInfo.type == td.SkillType.FixedMagic or skillInfo.type == td.SkillType.RandomMagic) then
        local bootstCd = udMng:GetBoostValue(td.BoostType.Skill, skillId)
        local skillCd = skillInfo.cd * ((100 - bootstCd) / 100)
        heroData.skillCD[skillId] = {time = skillCd}
      end
    end
    heroData.weaponSkills = {}
    local weapons = {
      data.attackSite,
      data.defSite
    }
    for i, var in ipairs(weapons) do
      local weaponData = udMng:GetWeaponData(var)
      if weaponData then
        table.insert(heroData.weaponSkills, weaponData.weaponInfo.skill)
      end
    end
    table.insert(self.vHeros, heroData)
  end
  self:AutoSelectHero()
end
function GameDataManager:SetGameMap(mapId, missonId)
  missonId = missonId or mapId
  local udMng = UserDataManager:GetInstance()
  self.oriMissionData = clone(udMng:GetCityData(missonId))
  self.gameMapInfo = clone(MissionInfoManager:GetInstance():GetMissionInfo(mapId))
  if not self.gameMapInfo then
    return
  end
  self.iMissionId = missonId
  self.iMapId = mapId
  self.gameMap = CGameTileMap:create(self.gameMapInfo.map, self.gameMapInfo.type)
  local pTileMap = self.gameMap:GetTileMap()
  self.gameMap:SetOriScale(td.GetAutoScale())
  local mapSize = self.gameMap:GetPiexlSize()
  local scale = td.GetAutoScale() * 0.7
  local minScale = math.max(math.max(display.width / mapSize.width, display.height / mapSize.height), 0.6 * td.GetAutoScale())
  scale = math.min(1.2 * td.GetAutoScale(), math.max(minScale, scale))
  pTileMap:setScale(scale)
  if self.gameMapInfo.camera_dot then
    self.gameMap:HighlightPos(self.gameMapInfo.camera_dot, -1)
  end
  self.iMaxPopulation = udMng:GetMaxPopu(self.gameMapInfo.type)
  self.waveGapTime = self.gameMapInfo.time
  self.iMaxCampNum = self.gameMapInfo.camp_num or 0
  if self.gameMapInfo.lock_camp and self.gameMapInfo.lock_camp ~= "0" then
    local t1 = string.split(self.gameMapInfo.lock_camp, "#")
    for key, var in ipairs(t1) do
      self.vForbidCamps[tonumber(var)] = true
    end
  end
  if self.gameMapInfo.type == td.MapType.ZiYuan or self.gameMapInfo.type == td.MapType.ZhanLing then
    local t1 = string.split(self.gameMapInfo.oil, "#")
    if #t1 > 1 then
      self.iMaxShiYouCount = tonumber(t1[2])
    else
      self.iMaxShiYouCount = 0
    end
    local t2 = string.split(self.gameMapInfo.crystal, "#")
    if #t2 > 1 then
      self.iMaxShuiJingCount = tonumber(t2[2])
    else
      self.iMaxShuiJingCount = 0
    end
    local t3 = string.split(self.gameMapInfo.bullet, "#")
    if #t3 > 1 then
      self.iMaxDanYaoCount = tonumber(t3[2])
    else
      self.iMaxDanYaoCount = 0
    end
  elseif self.gameMapInfo.type == td.MapType.Rob and self.robData then
    self:SetMaxNeedCount(self.robData.type, self.robData.num)
  end
  if mapId == 8010 or mapId == td.TRAIN_ID then
    self.bIsTraining = true
  end
end
function GameDataManager:GetCostRes()
  return self.dicStarCondition[td.StarLevel.FORCE_LIMIT] or 0
end
function GameDataManager:SetTrialGameMap(mode, level)
  GameControl.ClearValueForType(td.GameControlType.EnterMap)
  self.iMissionId = 7010
  local trialLevelInfo = MissionInfoManager:GetInstance():GetTrialLevelInfo(mode, level)
  local trialId = trialLevelInfo.maps[1]
  if #trialLevelInfo.maps > 1 then
    trialId = trialLevelInfo.maps[math.random(#trialLevelInfo.maps)]
  end
  local trialInfo = MissionInfoManager:GetInstance():GetTrialInfo(trialId)
  self.gameMapInfo = clone(MissionInfoManager:GetInstance():GetMissionInfo(self.iMissionId))
  self.gameMapInfo.map = trialInfo.map
  self.gameMapInfo.monster_plan = trialInfo.monster_plan
  self.gameMapInfo.max_time = trialInfo.max_time
  self.gameMapInfo.difficult = trialInfo.difficult
  self.gameMapInfo.mini_map = trialInfo.mini_map
  self.gameMapInfo.award = trialLevelInfo.award
  self.iMaxPopulation = trialInfo.resource
  self.gameMap = CGameTileMap:create(self.gameMapInfo.map, td.MapType.Trial)
  local pTileMap = self.gameMap:GetTileMap()
  self.gameMap:SetOriScale(td.GetAutoScale())
  local mapSize = self.gameMap:GetPiexlSize()
  local scale = td.GetAutoScale() * 0.8
  local minScale = math.max(math.max(display.width / mapSize.width, display.height / mapSize.height), 0.6 * td.GetAutoScale())
  scale = math.min(1.2 * td.GetAutoScale(), math.max(minScale, scale))
  pTileMap:setScale(scale)
  self.waveGapTime = self.gameMapInfo.time
end
function GameDataManager:GetGameMap()
  return self.gameMap
end
function GameDataManager:GetGameMapInfo()
  return self.gameMapInfo
end
function GameDataManager:GetMissionId()
  return self.iMissionId
end
function GameDataManager:GetOriMissionData()
  return self.oriMissionData
end
function GameDataManager:SetBornPos(pos)
  self.bornPos = pos
end
function GameDataManager:GetBornPos()
  if nil == self.bornPos then
    local ActorManager = require("app.actor.ActorManager")
    self.bornPos = cc.p(ActorManager:GetInstance():FindHome(false):getPosition())
  end
  return self.bornPos
end
function GameDataManager:SetCurPVPInfo(info)
  self.curPVPInfo = info
end
function GameDataManager:GetCurPVPInfo()
  return self.curPVPInfo
end
function GameDataManager:GetHomeLevel()
  return UserDataManager:GetInstance():GetBaseCampLevel()
end
function GameDataManager:GetHeros()
  return self.vHeros
end
function GameDataManager:GetHeroCount()
  return #self.vHeros
end
function GameDataManager:AutoSelectHero()
  if self.iChangeHeroIndex then
    local nextHeroIndex = self.iChangeHeroIndex
    self.iChangeHeroIndex = nil
    if not self.vHeros[nextHeroIndex].bDead then
      self.iCurHeroIndex = nextHeroIndex
      self:SetCurHero(nextHeroIndex)
      return true
    end
  end
  local heroCount = self:GetHeroCount()
  local cdTime = 999999
  for i = 1, heroCount do
    local nextHeroIndex = self.iCurHeroIndex + i
    if heroCount < nextHeroIndex then
      nextHeroIndex = nextHeroIndex - heroCount
    end
    if not self.vHeros[nextHeroIndex].bDead then
      self.iCurHeroIndex = nextHeroIndex
      self:SetCurHero(nextHeroIndex)
      return true
    end
  end
  return false
end
function GameDataManager:SetCurHero(heroIndex)
  local ActorManager = require("app.actor.ActorManager")
  local heroData = self.vHeros[heroIndex]
  local hero = ActorManager:GetInstance():CreateActor(td.ActorType.Hero, heroData.hid, false, heroData.heroInfo)
  hero:SetInitSkillCD(heroData.skillCD)
  ActorManager:GetInstance():SetHero(hero)
end
function GameDataManager:GetCurHero()
  local ActorManager = require("app.actor.ActorManager")
  return ActorManager:GetInstance():FindActorByTag(ActorManager.KEY_HERO, false)
end
function GameDataManager:GetCurHeroIndex()
  return self.iCurHeroIndex
end
function GameDataManager:GetCurHeroData()
  return self.vHeros[self.iCurHeroIndex]
end
function GameDataManager:OnCurHeroDead()
  self.vHeros[self.iCurHeroIndex].bDead = true
end
function GameDataManager:RebornHero(index)
  index = index or self.iCurHeroIndex
  if self.vHeros[index] then
    self.vHeros[index].bDead = false
    self.iRebornTime = self.iRebornTime + 1
  end
end
function GameDataManager:ClearSkillCD(skillId)
  if self.vHeros[self.iCurHeroIndex].skillCD[skillId] then
    self.vHeros[self.iCurHeroIndex].skillCD[skillId].time = 1000
    self.iClearCDTime = self.iClearCDTime + 1
    local curHero = self:GetCurHero()
    if curHero then
      curHero:SetSkillCD(skillId, 1000)
    end
  end
end
function GameDataManager:SetChangeHeroIndex(index)
  if index and self.vHeros[index] then
    self.iChangeHeroIndex = index
  end
end
function GameDataManager:SetChangeHeroPos(pos)
  self.pChangeHeroPos = pos
end
function GameDataManager:GetChangeHeroPos()
  return self.pChangeHeroPos
end
function GameDataManager:GetRebornTime()
  return self.iRebornTime
end
function GameDataManager:GetClearCDTime()
  return self.iClearCDTime
end
function GameDataManager:SetEndTime(arg)
  self.waveGapTime = arg
end
function GameDataManager:GetEndTime()
  return self.waveGapTime
end
function GameDataManager:UpdateDeputyNum(n)
  self.iDeputyNum = self.iDeputyNum + n
end
function GameDataManager:GetDeputyNum()
  return self.iDeputyNum
end
function GameDataManager:SetCurMonsterCount(arg)
  self.iCurMonsterCount = arg
end
function GameDataManager:GetCurMonsterCount()
  return self.iCurMonsterCount
end
function GameDataManager:SetCurSubMonsterCount(arg)
  self.iCurSubMonsterCount = arg
end
function GameDataManager:GetCurSubMonsterCount()
  return self.iCurSubMonsterCount
end
function GameDataManager:SetMaxSubMonsterCount(arg)
  self.iMaxSubMonsterCount = arg
end
function GameDataManager:GetMaxSubMonsterCount()
  return self.iMaxSubMonsterCount
end
function GameDataManager:SetMaxMonsterCount(arg)
  self.iMaxMonsterCount = arg
end
function GameDataManager:GetMaxMonsterCount()
  return self.iMaxMonsterCount
end
function GameDataManager:SetSingleCreateAll(bCreateAll)
  self.bCreateAll = bCreateAll
end
function GameDataManager:IsSingleCreateAll()
  return self.bCreateAll
end
function GameDataManager:IsPathClear(pathId)
  return self.vClearPath[pathId]
end
function GameDataManager:AddClearPath(vPathId)
  for i, id in ipairs(vPathId) do
    self.vClearPath[id] = true
  end
end
function GameDataManager:IsAllPassBlock(block)
  return self.vAllPassBlock[block]
end
function GameDataManager:AddAllPassBlock(block)
  self.vAllPassBlock[block] = true
  if self.gameMap then
    self.gameMap:AddPassableRoadType(block)
  end
end
function GameDataManager:SetMonsterWave(iMonsterWave)
  self.iMonsterWave = iMonsterWave
end
function GameDataManager:GetMonsterWave()
  return self.iMonsterWave
end
function GameDataManager:SetEndlessGroupId(id)
  self.endlessGroupId = id
end
function GameDataManager:GetEndlessGroupId()
  return self.endlessGroupId
end
function GameDataManager:SetEndlessMaxWave(wave)
  self.iEndlessMaxWave = wave
end
function GameDataManager:GetEndlessMaxWave()
  return self.iEndlessMaxWave or 0
end
function GameDataManager:SetEndlessMaxWaveTime(time)
  self.iEndlessMaxWaveTime = time
end
function GameDataManager:GetEndlessMaxWaveTime()
  return self.iEndlessMaxWaveTime
end
function GameDataManager:SetEndlessReward(reward)
  self.iEndlessReward = reward
end
function GameDataManager:GetEndlessReward()
  return self.iEndlessReward
end
function GameDataManager:SetWaveReward(reward)
  self.iWaveReward = reward
end
function GameDataManager:GetWaveReward()
  return self.iWaveReward
end
function GameDataManager:UpdateCurResCount(arg)
end
function GameDataManager:UpdateNeedResCount(_type, value)
  if not _type or not value then
    return
  end
  if _type == td.ResourceType.ShiYou then
    self.iCurShiYouCount = cc.clampf(self.iCurShiYouCount + value, 0, self.iMaxShiYouCount)
  elseif _type == td.ResourceType.ShuiJing then
    self.iCurShuiJingCount = cc.clampf(self.iCurShuiJingCount + value, 0, self.iMaxShuiJingCount)
  elseif _type == td.ResourceType.DanYao then
    self.iCurDanYaoCount = cc.clampf(self.iCurDanYaoCount + value, 0, self.iMaxDanYaoCount)
  elseif _type == td.ResourceType.Gold then
    self.iCurGoldCount = cc.clampf(self.iCurGoldCount + value, 0, self.iMaxGoldCount)
  elseif _type == td.ResourceType.Exp then
    self.iCurEnergyCount = cc.clampf(self.iCurEnergyCount + value, 0, self.iMaxEnergyCount)
  elseif _type == td.ResourceType.EnergyBall_s then
    self.collectData.items[20105].num = cc.clampf(self.collectData.items[20105].num + value, 0, self.collectData.items[20105].max)
  elseif _type == td.ResourceType.EnergyBall_m then
    self.collectData.items[20112].num = cc.clampf(self.collectData.items[20112].num + value, 0, self.collectData.items[20112].max)
  elseif _type == td.ResourceType.EnergyBall_l then
    self.collectData.items[20106].num = cc.clampf(self.collectData.items[20106].num + value, 0, self.collectData.items[20106].max)
  elseif _type == td.ResourceType.Medal_s then
    self.collectData.items[20102].num = cc.clampf(self.collectData.items[20102].num + value, 0, self.collectData.items[20102].max)
  elseif _type == td.ResourceType.Medal_m then
    self.collectData.items[20103].num = cc.clampf(self.collectData.items[20103].num + value, 0, self.collectData.items[20103].max)
  elseif _type == td.ResourceType.Medal_l then
    self.collectData.items[20104].num = cc.clampf(self.collectData.items[20104].num + value, 0, self.collectData.items[20104].max)
  elseif _type == td.ResourceType.StarStone_s then
    self.collectData.items[20118].num = cc.clampf(self.collectData.items[20118].num + value, 0, self.collectData.items[20118].max)
  elseif _type == td.ResourceType.StarStone_m then
    self.collectData.items[20003].num = cc.clampf(self.collectData.items[20003].num + value, 0, self.collectData.items[20003].max)
  elseif _type == td.ResourceType.StarStone_l then
    self.collectData.items[20113].num = cc.clampf(self.collectData.items[20113].num + value, 0, self.collectData.items[20113].max)
  end
  td.dispatchEvent(td.UPDATE_NEED_RES, {type = _type})
  if self.gameMapInfo.type == td.MapType.ZiYuan or self.gameMapInfo.type == td.MapType.ZhanLing then
    if self.iCurShiYouCount >= self.iMaxShiYouCount and self.iCurShuiJingCount >= self.iMaxShuiJingCount and self.iCurDanYaoCount >= self.iMaxDanYaoCount then
      require("app.trigger.TriggerManager"):GetInstance():SendEvent({
        eType = td.ConditionType.ResourceEnough
      })
    end
  elseif self.gameMapInfo.type == td.MapType.Rob then
    if 0 < self.iMaxGoldCount and self.iCurGoldCount >= self.iMaxGoldCount or 0 < self.iMaxEnergyCount and self.iCurEnergyCount >= self.iMaxEnergyCount then
      require("app.trigger.TriggerManager"):GetInstance():SendEvent({
        eType = td.ConditionType.ResourceEnough
      })
    end
  elseif self.gameMapInfo.type == td.MapType.Collect then
    local bDone = true
    for itemId, var in pairs(self.collectData.items) do
      if var.num < var.max then
        bDone = false
        break
      end
    end
    if bDone then
      require("app.trigger.TriggerManager"):GetInstance():SendEvent({
        eType = td.ConditionType.ResourceEnough
      })
    end
  end
end
function GameDataManager:GetCurNeedCount(type)
  if type == td.ResourceType.ShiYou then
    return self.iCurShiYouCount
  elseif type == td.ResourceType.ShuiJing then
    return self.iCurShuiJingCount
  elseif type == td.ResourceType.DanYao then
    return self.iCurDanYaoCount
  elseif type == td.ResourceType.Gold then
    return self.iCurGoldCount
  elseif type == td.ResourceType.Exp then
    return self.iCurEnergyCount
  elseif self.gameMapInfo.type == td.MapType.Collect then
    if type == td.ResourceType.EnergyBall_s then
      return self.collectData.items[20105].num
    elseif type == td.ResourceType.EnergyBall_m then
      return self.collectData.items[20112].num
    elseif type == td.ResourceType.EnergyBall_l then
      return self.collectData.items[20106].num
    elseif type == td.ResourceType.Medal_s then
      return self.collectData.items[20102].num
    elseif type == td.ResourceType.Medal_m then
      return self.collectData.items[20103].num
    elseif type == td.ResourceType.Medal_l then
      return self.collectData.items[20104].num
    elseif type == td.ResourceType.StarStone_s then
      return self.collectData.items[20118].num
    elseif type == td.ResourceType.StarStone_m then
      return self.collectData.items[20003].num
    elseif type == td.ResourceType.StarStone_l then
      return self.collectData.items[20113].num
    end
  end
  return 0
end
function GameDataManager:SetMaxNeedCount(type, cnt)
  if type == td.ResourceType.ShiYou then
    self.iMaxShiYouCount = cnt
  elseif type == td.ResourceType.ShuiJing then
    self.iMaxShuiJingCount = cnt
  elseif type == td.ResourceType.DanYao then
    self.iMaxDanYaoCount = cnt
  elseif type == td.ResourceType.Gold then
    self.iMaxGoldCount = cnt
  elseif type == td.ResourceType.Exp then
    self.iMaxEnergyCount = cnt
  elseif self.gameMapInfo.type == td.MapType.Collect then
    if type == td.ResourceType.EnergyBall_s then
      self.collectData.items[20105].max = cnt
    elseif type == td.ResourceType.EnergyBall_m then
      self.collectData.items[20112].max = cnt
    elseif type == td.ResourceType.EnergyBall_l then
      self.collectData.items[20106].max = cnt
    elseif type == td.ResourceType.Medal_s then
      self.collectData.items[20102].max = cnt
    elseif type == td.ResourceType.Medal_m then
      self.collectData.items[20103].max = cnt
    elseif type == td.ResourceType.Medal_l then
      self.collectData.items[20104].max = cnt
    elseif type == td.ResourceType.StarStone_s then
      self.collectData.items[20118].max = cnt
    elseif type == td.ResourceType.StarStone_m then
      self.collectData.items[20003].max = cnt
    elseif type == td.ResourceType.StarStone_l then
      self.collectData.items[20113].max = cnt
    end
  end
  return 0
end
function GameDataManager:GetMaxNeedCount(type)
  if type == td.ResourceType.ShiYou then
    return self.iMaxShiYouCount
  elseif type == td.ResourceType.ShuiJing then
    return self.iMaxShuiJingCount
  elseif type == td.ResourceType.DanYao then
    return self.iMaxDanYaoCount
  elseif type == td.ResourceType.Gold then
    return self.iMaxGoldCount
  elseif type == td.ResourceType.Exp then
    return self.iMaxEnergyCount
  elseif self.gameMapInfo.type == td.MapType.Collect then
    if type == td.ResourceType.EnergyBall_s and self.collectData.items[20105] then
      return self.collectData.items[20105].max
    elseif type == td.ResourceType.EnergyBall_m and self.collectData.items[20112] then
      return self.collectData.items[20112].max
    elseif type == td.ResourceType.EnergyBall_l and self.collectData.items[20106] then
      return self.collectData.items[20106].max
    elseif type == td.ResourceType.Medal_s and self.collectData.items[20102] then
      return self.collectData.items[20102].max
    elseif type == td.ResourceType.Medal_m and self.collectData.items[20103] then
      return self.collectData.items[20103].max
    elseif type == td.ResourceType.Medal_l and self.collectData.items[20104] then
      return self.collectData.items[20104].max
    elseif type == td.ResourceType.StarStone_s and self.collectData.items[20118] then
      return self.collectData.items[20118].max
    elseif type == td.ResourceType.StarStone_m and self.collectData.items[20003] then
      return self.collectData.items[20003].max
    elseif type == td.ResourceType.StarStone_l and self.collectData.items[20113] then
      return self.collectData.items[20113].max
    end
  end
  return 0
end
function GameDataManager:UpdateStarCondition(type, value)
  if type == td.StarLevel.UNIT_LIMIT then
    if not self.dicStarCondition[type] then
      self.dicStarCondition[type] = {}
    end
    self.dicStarCondition[type][value] = 1
  else
    local oriValue = self.dicStarCondition[type] or 0
    self.dicStarCondition[type] = oriValue + value
  end
end
function GameDataManager:CheckStarCondition(type, expectValue)
  local bResult, curValue = self.dicStarCondition[type] or false, 0
  local vTypeMore = {
    td.StarLevel.KILL_ENEMY,
    td.StarLevel.HERO_SKILL_KILL,
    td.StarLevel.HERO_SKILL_KILL,
    td.StarLevel.GAIN_SPECIAL_ITEM
  }
  local vTypeLess = {
    td.StarLevel.HERO_DEATH,
    td.StarLevel.ONLY_PRIMITIVE,
    td.StarLevel.UNIT_DEATH,
    td.StarLevel.FORCE_LIMIT,
    td.StarLevel.FULL_HP_BASE,
    td.StarLevel.BARRACK_LIMIT,
    td.StarLevel.TIME_LIMIT
  }
  if table.indexof(vTypeMore, type) then
    if expectValue <= curValue then
      bResult = true
    end
  elseif table.indexof(vTypeLess, type) then
    if expectValue >= curValue then
      bResult = true
    end
  elseif type == td.StarLevel.UNIT_LIMIT then
    local careerTypes = {
      td.CareerType.Saber,
      td.CareerType.Archer,
      td.CareerType.Caster
    }
    bResult = true
    for i, career in ipairs(careerTypes) do
      local tmp = self.dicStarCondition[type] or {}
      local tmpVar = tmp[career] or 0
      if career ~= expectValue and tmpVar ~= 0 then
        bResult = false
        break
      end
    end
  end
  return bResult, curValue
end
function GameDataManager:UpdateUnitNum(roleId, num)
  if self.selUnitNum[roleId] then
    self.selUnitNum[roleId] = self.selUnitNum[roleId] + num
  end
end
function GameDataManager:UpdateDeadUnit(roleId, num)
  if self.deadUnit[roleId] then
    self.deadUnit[roleId] = self.deadUnit[roleId] + num
  else
    self.deadUnit[roleId] = num
  end
  if self.gameMapInfo.type ~= td.MapType.PVP and self.gameMapInfo.type ~= td.MapType.PVPGuild and require("app.GuideManager"):GetInstance():IsForceGuideOver() then
    UnitDataManager:GetInstance():ConsumeSoldierRequest(roleId, num)
  end
end
function GameDataManager:GetDeadUnit()
  return self.deadUnit
end
function GameDataManager:UpdateMaxPopulation(arg)
  self.iMaxPopulation = self.iMaxPopulation + arg
  td.dispatchEvent(td.UPDATE_POPULATION)
end
function GameDataManager:GetMaxPopulation()
  return self.iMaxPopulation
end
function GameDataManager:UpdateCurPopulation(arg)
  self.iCurPopulation = self.iCurPopulation + arg
  td.dispatchEvent(td.UPDATE_POPULATION, arg)
  return self.iCurPopulation
end
function GameDataManager:GetCurPopulation()
  return self.iCurPopulation
end
function GameDataManager:GetMaxCampNum()
  return self.iMaxCampNum or 0
end
function GameDataManager:IsCampForbidden(campId)
  if self.vForbidCamps[campId] then
    return true
  end
  if self.bIsTraining then
    return false
  end
  return false
end
function GameDataManager:AddNewMonsterTip(id)
  if table.indexof(self.vNewMonsterIds, id) then
    return
  end
  if #self.vNewMonsterIds == 0 then
    td.dispatchEvent(td.NEW_MONSTER_TIP)
  end
  table.insert(self.vNewMonsterIds, id)
end
function GameDataManager:GetNewMonsterTips()
  return self.vNewMonsterIds
end
function GameDataManager:ClearNewMonsterTips()
  self.vNewMonsterIds = {}
end
function GameDataManager:AddPokedex(_type, id)
  if self.gameMapInfo.id < 1000 or self.gameMapInfo.id >= 6000 then
    return
  end
  if not PokedexInfoManager:GetInstance():CanUnlock(_type, id) then
    return
  end
  if self.vToSendPokedex[_type] and table.indexof(self.vToSendPokedex[_type], id) then
    return
  end
  self.vToSendPokedex[_type] = self.vToSendPokedex[_type] or {}
  table.insert(self.vToSendPokedex[_type], id)
  if _type == td.PokedexType.Monster then
    self:AddNewMonsterTip(id)
  end
end
function GameDataManager:SetSkillTarget(arg)
  self.ptSkillTarget = arg
end
function GameDataManager:GetSkillTarget()
  return self.ptSkillTarget
end
function GameDataManager:SetFocusNode(arg)
  g_MC:UpdateOpTime()
  if self.pFocusNode == arg then
    return
  end
  if self.pFocusNode then
    self.pFocusNode:InactiveFocus()
  end
  if arg then
    self.pFocusNode = arg
    self.pFocusNode:ActiveFocus()
  else
    local ActorManager = require("app.actor.ActorManager")
    local curHero = ActorManager:GetInstance():FindActorByTag(ActorManager.KEY_HERO, false)
    if curHero and self.pFocusNode ~= curHero and not curHero:IsDead() then
      self.pFocusNode = curHero
      self.pFocusNode:ActiveFocus()
    else
      self.pFocusNode = nil
    end
  end
end
function GameDataManager:GetFocusNode()
  return self.pFocusNode
end
function GameDataManager:SetActorCanTouch(arg)
  if arg then
    self.iActorCanTouch = self.iActorCanTouch + 1
  else
    self.iActorCanTouch = self.iActorCanTouch - 1
  end
end
function GameDataManager:GetActorCanTouch()
  return self.iActorCanTouch >= 0
end
function GameDataManager:SetActorInTile(lastTile, curTile, actor)
  if lastTile and self.ActorTiles[lastTile] then
    for i, v in ipairs(self.ActorTiles[lastTile]) do
      if v == actor then
        table.remove(self.ActorTiles[lastTile], i)
        break
      end
    end
    if #self.ActorTiles[lastTile] == 0 then
      self.ActorTiles[lastTile] = nil
    end
  end
  if curTile and actor then
    if not self.ActorTiles[curTile] then
      self.ActorTiles[curTile] = {}
    end
    table.insert(self.ActorTiles[curTile], actor)
  end
end
function GameDataManager:GetInTileActors(tilePos)
  return self.ActorTiles[tilePos]
end
function GameDataManager:IsGameOver()
  return self.bFightOver
end
function GameDataManager:GameWin()
  if not self.gameMapInfo then
    return
  end
  if self.bFightOver then
    return
  end
  cc.Director:getInstance():getScheduler():setTimeScale(1)
  local data = {}
  local Msg = {}
  self.fightWin = true
  if self.gameMapInfo.type == td.MapType.PVP then
    local info = self.curPVPInfo
    if info.isFriend then
      data.fid = info.id
      data.state = 1
      Msg.msgType = td.RequestID.FriendFight
      td.dispatchEvent(td.FIGHT_WIN)
    else
      data.state = 1
      data.log_id = info.logId
      Msg.msgType = td.RequestID.ArenaFightAfter
    end
    Msg.sendData = data
    TDHttpRequest:getInstance():Send(Msg)
  elseif self.gameMapInfo.type == td.MapType.PVPGuild then
    local pvpData = UserDataManager:GetInstance():GetGuildManager():GetGuildPVPData()
    data.result = 1
    data.team_id = pvpData:GetValue("battleId")
    data.index = pvpData:GetValue("fightingIndex")
    data.log_id = pvpData:GetValue("logId")
    Msg.msgType = td.RequestID.GuildPVPAfter
    Msg.sendData = data
    TDHttpRequest:getInstance():Send(Msg)
  elseif self.gameMapInfo.type == td.MapType.Rob then
    td.dispatchEvent(td.FIGHT_WIN)
  elseif self.gameMapInfo.type == td.MapType.Collect then
    local _items = {}
    for itemId, var in pairs(self.collectData.items) do
      table.insert(_items, {
        item_id = itemId,
        item_num = var.num
      })
    end
    Msg.msgType = td.RequestID.GetCollectReward
    Msg.sendData = {
      type = self.collectData.type,
      difficulty = self.collectData.mode,
      items = _items
    }
    TDHttpRequest:getInstance():Send(Msg)
  elseif self.iMissionId < 6000 or self.iMissionId == td.TRAIN_ID then
    local stars = {}
    if self.iMissionId == self.gameMapInfo.id then
      for i, var in ipairs(self.gameMapInfo.star_level) do
        if self:CheckStarCondition(var[1], var[2]) then
          table.insert(stars, i)
        end
      end
    end
    local bIsDF = self.iMapId ~= self.iMissionId
    MissionInfoManager:GetInstance():SendAddMissionRequest(self.iMissionId, stars, bIsDF)
  else
    td.dispatchEvent(td.FIGHT_WIN)
  end
  display.getRunningScene():SetPause(true)
  self.bFightOver = true
  if self.vToSendPokedex[td.PokedexType.Monster] and self.iMissionId ~= 8010 then
    require("app.info.PokedexInfoManager"):GetInstance():SendAddCardRequest(self.vToSendPokedex)
    UserDataManager:GetInstance():GetCards({
      monsters = self.vToSendPokedex[td.PokedexType.Monster]
    })
  end
end
function GameDataManager:GameLose()
  if self.bFightOver then
    return
  end
  cc.Director:getInstance():getScheduler():setTimeScale(1)
  local data = {}
  local Msg = {}
  self.fightWin = false
  if self.gameMapInfo.type == td.MapType.PVP then
    local info = self.curPVPInfo
    if info.isFriend then
      data.fid = info.id
      data.state = 0
      Msg.msgType = td.RequestID.FriendFight
      td.dispatchEvent(td.FIGHT_LOSE)
    else
      data.state = 0
      data.log_id = info.logId
      Msg.msgType = td.RequestID.ArenaFightAfter
    end
    Msg.sendData = data
    TDHttpRequest:getInstance():Send(Msg)
  elseif self.gameMapInfo.type == td.MapType.PVPGuild then
    local pvpData = UserDataManager:GetInstance():GetGuildManager():GetGuildPVPData()
    data.result = 0
    data.team_id = pvpData:GetValue("battleId")
    data.index = pvpData:GetValue("fightingIndex")
    data.log_id = pvpData:GetValue("logId")
    Msg.msgType = td.RequestID.GuildPVPAfter
    Msg.sendData = data
    TDHttpRequest:getInstance():Send(Msg)
  elseif self.iMissionId < 6000 then
  end
  display.getRunningScene():SetPause(true)
  self.bFightOver = true
  td.dispatchEvent(td.FIGHT_LOSE)
  G_SoundUtil:StopMusic()
  G_SoundUtil:StopAllSounds()
  G_SoundUtil:PlaySound(52, false)
end
function GameDataManager:IsFightWin()
  return self.fightWin
end
function GameDataManager:ReplayGame()
  local mapID = self:GetGameMapInfo().id
  local missionID = self:GetMissionId()
  local soldiers = self.selUnit
  GameControl.ClearValueForType(td.GameControlType.EnterMap)
  self:SetGameMap(mapID, missionID)
  self:SetCampRole(soldiers)
  local battleScene = require("app.scenes.BattleScene").new()
  cc.Director:getInstance():replaceScene(battleScene)
end
function GameDataManager:ExitGame(uiModule, sceneType)
  sceneType = sceneType or td.SceneType.Main
  local backScene
  if sceneType == td.SceneType.Guild then
    backScene = require("app.scenes.GuildScene").new()
  elseif sceneType == td.SceneType.GuildPVP then
    backScene = require("app.scenes.GuildPVPScene").new()
  else
    backScene = require("app.scenes.MainMenuScene").new()
  end
  if uiModule then
    backScene:SetEnterModule(uiModule)
  end
  cc.Director:getInstance():replaceScene(backScene)
  GameControl.ClearValueForType(td.GameControlType.SwichScene)
end
function GameDataManager:GetWaveType()
  if self.gameMapInfo then
    return tonumber(self.gameMapInfo.wave_type)
  end
  return 0
end
function GameDataManager:SetDeadBoss(args)
  self.iDeadBoss = args
end
function GameDataManager:GetDeadBoss()
  return self.iDeadBoss
end
function GameDataManager:SetPause(bPause)
  self.bPause = bPause
end
function GameDataManager:IsPause()
  return self.bPause
end
function GameDataManager:SetPauseUI(bPause)
  self.bPauseUI = bPause
end
function GameDataManager:IsPauseUI()
  return self.bPauseUI
end
function GameDataManager:SetTrialData(mode, level)
  self.trialData = {}
  self.trialData.mode = mode
  self.trialData.level = level
end
function GameDataManager:GetTrialData()
  return self.trialData
end
function GameDataManager:SetRobData(data)
  self.robData = {}
  self.robData.level = data.level
  self.robData.name = data.name
  self.robData.num = data.num
  self.robData.type = data.type
  local vGuildSkill = {}
  for j, var in ipairs(data.guildSkill) do
    local guildSkill = {
      id = var.id,
      level = var.level
    }
    vGuildSkill[guildSkill.id] = guildSkill
  end
  self.robData.boostData = require("app.data.BoostData").new(vGuildSkill)
  local SkillInfoManager = require("app.info.SkillInfoManager")
  self.robData.skills = {}
  for j, var in ipairs(data.skillProto) do
    local skillData = SkillInfoManager:GetInstance():MakeSkillData(var, true, self.robData.boostData)
    self.robData.skills[skillData.id] = skillData
  end
  local siMng = require("app.info.StrongInfoManager"):GetInstance()
  self.robData.weapons = {}
  for j, var in ipairs(data.weapons) do
    local weaponData = siMng:MakeWeaponData(var)
    self.robData.weapons[weaponData.id] = weaponData
  end
  self.robData.heros = {}
  for j, var in ipairs(data.heros) do
    local heroData = siMng:MakeHeroData(var, self.robData.boostData)
    self.robData.heros[heroData.hid] = heroData
  end
  self:SetMaxNeedCount(self.robData.type, self.robData.num)
end
function GameDataManager:GetRobData()
  return self.robData
end
function GameDataManager:AddBattleLog(id, num)
  if self.mBattleLog[id] then
    self.mBattleLog[id] = self.mBattleLog[id] + num
  else
    self.mBattleLog[id] = num
  end
end
function GameDataManager:GetBattleLog()
  return self.mBattleLog
end
function GameDataManager:SetCollectData(mode, type)
  self.collectData = {}
  self.collectData.mode = mode
  self.collectData.type = type
  self.collectData.items = {}
  local items = require("app.config.collect_config").Items[type][mode]
  for i, var in ipairs(items) do
    self.collectData.items[var.itemId] = {}
    self.collectData.items[var.itemId].num = 0
    self.collectData.items[var.itemId].max = var.max
  end
end
function GameDataManager:GetCollectData()
  return self.collectData
end
function GameDataManager:SetBombData(data)
  self.bombData = data
end
function GameDataManager:GetBombData()
  return self.bombData
end
function GameDataManager:SetGuildBossData(bossId, hp)
  self.guildBossData = {}
  self.guildBossData.bossId = bossId
  self.guildBossData.hp = hp
end
function GameDataManager:GetGuildBossData()
  return self.guildBossData
end
return GameDataManager
