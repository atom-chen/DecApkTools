local BattleScene = require("app.scenes.BattleScene")
local ActorManager = require("app.actor.ActorManager")
local TriggerManager = require("app.trigger.TriggerManager")
local UserDataManager = require("app.UserDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local ActorInfoManager = require("app.info.ActorInfoManager")
local GameDataManager = require("app.GameDataManager")
local GuildDataManager = require("app.GuildDataManager")
local BattlePVPGuildScene = class("BattlePVPGuildScene", BattleScene)
function BattlePVPGuildScene:ctor()
  BattlePVPGuildScene.super.ctor(self)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_guildMng = GuildDataManager:GetInstance()
  self.m_pvpData = self.m_guildMng:GetGuildPVPData()
end
function BattlePVPGuildScene:InitGame()
  local fightingIndex = self.m_pvpData:GetValue("fightingIndex")
  if fightingIndex then
    self:InitActor()
    local enemyId = self.m_pvpData:GetValue("battlePos")[fightingIndex].id
    local Msg = {}
    Msg.msgType = td.RequestID.GetPlayerAreanaInfo
    Msg.sendData = {type = 2, uid = enemyId}
    TDHttpRequest:getInstance():Send(Msg)
  else
    self.m_uiLayer = require("app.layers.battle.PaibingUILayer").new()
    self.m_uiLayer:SetStartCb(handler(self, self.StartFight))
    self.m_uiLayer:SetLeaveCb(handler(self, self.Leave))
    local heroItems, soldierItems = self.m_pvpData:GetValue("hero_item"), self.m_pvpData:GetValue("soldier_item")
    self.m_uiLayer:SetInitData(heroItems, soldierItems)
    self.m_uiLayer:SetStartBtnTitle(g_LM:getBy("a00223"))
    self:addChild(self.m_uiLayer, 101)
  end
end
function BattlePVPGuildScene:StartFight(heroStr, soldierStr)
  if self.m_uiLayer:HadChanged() then
    local msg = {}
    local data = {}
    data.hero_item = heroStr
    data.soldier_item = soldierStr
    data.type = 2
    msg.msgType = td.RequestID.SetFormation
    msg.sendData = data
    TDHttpRequest:getInstance():Send(msg)
    self.m_pvpData:UpdateTroopData(data)
  end
  local bStart, cdTime = self.m_guildMng:IsGuildPVPStart()
  if bStart and cdTime <= 0 then
    self.m_gdMng:ExitGame(3, td.SceneType.GuildPVP)
  else
    self.m_gdMng:ExitGame(3, td.SceneType.Guild)
  end
end
function BattlePVPGuildScene:Leave()
  self.m_pvpData:UpdateValue("fightingIndex", nil)
  local bStart, cdTime = self.m_guildMng:IsGuildPVPStart()
  if bStart and cdTime <= 0 then
    self.m_gdMng:ExitGame(3, td.SceneType.GuildPVP)
  else
    self.m_gdMng:ExitGame(3, td.SceneType.Guild)
  end
end
function BattlePVPGuildScene:didEnter()
  BattlePVPGuildScene.super.didEnter(self)
end
function BattlePVPGuildScene:InitActor()
  local heroItems, soldierItems = {}, {}
  local mapType = self.m_gdMng:GetGameMapInfo().type
  if mapType == td.MapType.PVP then
    local pvpData = self.m_udMng:GetPVPData()
    heroItems, soldierItems = pvpData.selfData.hero_item, pvpData.selfData.soldier_item
  elseif mapType == td.MapType.PVPGuild then
    local pvpData = self.m_udMng:GetGuildManager():GetGuildPVPData()
    heroItems, soldierItems = pvpData:GetValue("hero_item"), pvpData:GetValue("soldier_item")
  end
  for i, v in ipairs(heroItems) do
    local heroId = v.id
    self:CreateActor(td.ActorType.Hero, heroId, cc.p(v.x, v.y), false)
  end
  for i, v in ipairs(soldierItems) do
    self:CreateActor(td.ActorType.Soldier, v.id, cc.p(v.x, v.y), false)
  end
end
function BattlePVPGuildScene:CreateActor(actorType, id, pos)
  local pMap = self.m_gdMng:GetGameMap()
  local actor, actorData
  if actorType == td.ActorType.Hero then
    local herosData = self.m_udMng:GetHeroData()
    for key, var in pairs(herosData) do
      if var.hid == id then
        actorData = var
        break
      end
    end
    if not actorData then
      td.alertDebug("Hero id error!")
      return
    end
    local info = StrongInfoManager:GetInstance():GetHeroFinalInfo(actorData)
    actor = ActorManager:GetInstance():CreateActor(actorType, id, false, info)
  elseif actorType == td.ActorType.Soldier then
    actor = ActorManager:GetInstance():CreateActor(actorType, id, false)
  end
  actor:setPosition(pos)
  pMap:addChild(actor, pMap:GetPiexlSize().height - actor:getPositionY(), actor:getTag())
  return actor
end
function BattlePVPGuildScene:PVPStart()
  self.m_uiLayer = require("app.layers.battle.PVPGuildBattleUILayer").new()
  self:addChild(self.m_uiLayer, 101)
  self.m_gdMng:AddAllPassBlock(11)
  self:SaveMonsterPlan()
  local vec = ActorManager:GetInstance():GetSelfVec()
  for i, v in pairs(vec) do
    local actorType = v:GetType()
    local pos = cc.p(v:getPosition())
    local id = v:GetData().id
    ActorManager:GetInstance():CreateActorPath(v, pos, pos)
  end
end
function BattlePVPGuildScene:PVPFightOver()
  local PVPFightOverDlg = require("app.layers.battle.PVPGuildFightOverDlg")
  local layer = PVPFightOverDlg.new({
    isWin = self.m_gdMng:IsFightWin()
  })
  self:addChild(layer, 102)
  self.m_pvpData:UpdateValue("fightingIndex", nil)
end
function BattlePVPGuildScene:AddListeners()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GuildPVPAfter, handler(self, self.PVPFightOver))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetPlayerAreanaInfo, handler(self, self.GetRivalArenaCallback))
  self:AddCustomEvent(td.FIGHT_LOSE, handler(self, self.PVPFightOver))
end
function BattlePVPGuildScene:RemoveListeners()
  BattlePVPGuildScene.super.RemoveListeners(self)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GuildPVPAfter)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetPlayerAreanaInfo)
end
function BattlePVPGuildScene:UpdateMonster(dt)
  if not self.m_bFightStart then
    return
  end
  if not self.m_vMonsterPlans then
    return
  end
  local pMap = self.m_gdMng:GetGameMap()
  local iCurMonsterCount = self.m_gdMng:GetCurMonsterCount()
  if iCurMonsterCount <= #self.m_vMonsterPlans then
    local bAllCreate = true
    local pPlan = self.m_vMonsterPlans[iCurMonsterCount]
    for i, info in ipairs(pPlan) do
      if info.count < info.num then
        info.count = info.count + 1
        bAllCreate = false
        local tempInfo
        if info.enemy then
          if info.type == td.ActorType.Soldier then
            local ActorInfoManager = require("app.info.ActorInfoManager")
            tempInfo = self.m_PVPSoldierDatas[info.id].soldierInfo
            local lindex = string.findLast(tempInfo.image, "/")
            local file = string.sub(tempInfo.image, lindex + 1)
            tempInfo.image = "Spine/renwu/bianse/" .. file
          elseif info.type == td.ActorType.Hero then
            local heroData = self.m_PVPHeroDatas[info.id]
            tempInfo = StrongInfoManager:GetInstance():GetHeroFinalInfo(heroData, self.m_PVPWeaponDatas, self.m_PVPSkillDatas)
            local lindex = string.findLast(tempInfo.image, "/")
            local file = string.sub(tempInfo.image, lindex + 1)
            tempInfo.image = "Spine/yingxiong/bianse/" .. file
          end
          local pActor = ActorManager:GetInstance():CreateActor(info.type, info.id, info.enemy, tempInfo)
          local iRandom = 1 < #info.paths and math.random(#info.paths) or 1
          local pathID = info.paths[iRandom].pathID
          local bInverted = info.paths[iRandom].bInverted
          ActorManager:GetInstance():CreateActorPathById(pActor, pathID, bInverted, info.pos)
          pMap:addChild(pActor, pMap:GetPiexlSize().height - pActor:getPositionY(), pActor:getTag())
        end
      end
    end
    self.m_gdMng:SetSingleCreateAll(bAllCreate)
    if bAllCreate then
      self.m_gdMng:SetCurMonsterCount(iCurMonsterCount + 1)
      self.m_fTimeInterval = 0
      if self.m_gdMng:GetWaveType() == td.WaveType.ByTime then
        self.m_gdMng:SetEndTime(self.m_mapInfo.time)
      else
        self.m_gdMng:SetEndTime(0)
      end
    else
      self.m_fTimeInterval = 0
    end
  end
end
function BattlePVPGuildScene:GetRivalArenaCallback(data)
  self.m_pvpData:SetEnemyPVPData(data.otherArena)
  self:PVPStart()
end
function BattlePVPGuildScene:SaveMonsterPlan()
  self.m_vMonsterPlans = {}
  local enemyData = self.m_pvpData:GetValue("enemyData")
  local plan = {}
  local function SinglePlan(t, actorType, bInverted)
    local pMap = self.m_gdMng:GetGameMap()
    local mapSize = pMap:GetPiexlSize()
    for i, var in ipairs(t) do
      local info = {}
      info.count = 0
      info.paths = {}
      info.type = actorType
      info.enemy = bInverted
      info.id = var.id
      info.num = 1
      if bInverted then
        info.pos = cc.p(mapSize.width - var.x, var.y)
      else
        info.pos = cc.p(var.x, var.y)
      end
      info.weaponId = var.weaponId
      info.defenseId = var.defenseId
      if var.activeSkill then
        info.activeSkill = {}
        for j, k in ipairs(var.activeSkill) do
          table.insert(info.activeSkill, k)
        end
      end
      if var.passiveSkill then
        info.passiveSkill = {}
        for j, k in ipairs(var.passiveSkill) do
          table.insert(info.passiveSkill, k)
        end
      end
      local tilePos = pMap:GetTilePosFromPixelPos(cc.p(var.x, var.y))
      local iPathID = pMap:GetPathID(tilePos, "0")
      table.insert(info.paths, {pathID = iPathID, bInverted = bInverted})
      table.insert(plan, info)
    end
  end
  if #enemyData.hero_item == 0 and #enemyData.soldier_item == 0 then
    TriggerManager:GetInstance():SendEvent({
      eType = td.ConditionType.AllSideDead,
      allSideDead = true,
      isEnemy = true
    })
    return
  end
  SinglePlan(enemyData.hero_item, td.ActorType.Hero, true)
  SinglePlan(enemyData.soldier_item, td.ActorType.Soldier, true)
  table.insert(self.m_vMonsterPlans, plan)
  self.m_enemyUserData = {}
  self.m_enemyUserData.reputation = enemyData.reputation
  self.m_PVPWeaponDatas = enemyData.weapons
  self.m_PVPHeroDatas = enemyData.heros
  self.m_PVPSoldierDatas = enemyData.soldiers
  self.m_PVPSkillDatas = enemyData.skills
  self.m_PVPGemDatas = enemyData.gems
  self.m_gdMng:SetMaxMonsterCount(#self.m_vMonsterPlans)
  self.m_gdMng:SetMaxSubMonsterCount(1)
  self.m_gdMng:SetEndTime(0)
  self.m_bFightStart = true
end
return BattlePVPGuildScene
