local BattleScene = require("app.scenes.BattleScene")
local ActorManager = require("app.actor.ActorManager")
local TriggerManager = require("app.trigger.TriggerManager")
local UserDataManager = require("app.UserDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local ActorInfoManager = require("app.info.ActorInfoManager")
local BattlePVPScene = class("BattlePVPScene", BattleScene)
function BattlePVPScene:ctor()
  BattlePVPScene.super.ctor(self)
end
function BattlePVPScene:InitGame()
  self.m_uiLayer = require("app.layers.battle.PaibingUILayer").new()
  self.m_uiLayer:SetStartCb(handler(self, self.StartFight))
  self.m_uiLayer:SetLeaveCb(function()
    if self.m_gdMng:GetCurPVPInfo().isFriend then
      self.m_gdMng:ExitGame()
    else
      self.m_gdMng:ExitGame(td.UIModule.PVP)
    end
  end)
  local heroItems, soldierItems = {}, {}
  local pvpData = UserDataManager:GetInstance():GetPVPData()
  heroItems, soldierItems = pvpData.selfData.hero_item, pvpData.selfData.soldier_item
  self.m_uiLayer:SetInitData(heroItems, soldierItems)
  self:addChild(self.m_uiLayer, 101)
end
function BattlePVPScene:StartFight(heroStr, soldierStr)
  if self.m_uiLayer:HadChanged() then
    local msg = {}
    local data = {}
    data.hero_item = heroStr
    data.soldier_item = soldierStr
    data.type = 1
    msg.msgType = td.RequestID.SetFormation
    msg.sendData = data
    TDHttpRequest:getInstance():Send(msg)
  end
  self.m_uiLayer:Close()
  local info = self.m_gdMng:GetCurPVPInfo()
  local msg = {}
  msg.sendData = {}
  if info.isFriend then
    msg.sendData.fid = info.id
    msg.msgType = td.RequestID.FriendFightBefore
    td.dispatchEvent(td.FRIEND_FIGHT_START)
  else
    msg.sendData.otherId = info.id
    msg.msgType = td.RequestID.ArenaFightBefore
  end
  TDHttpRequest:getInstance():Send(msg)
end
function BattlePVPScene:didEnter()
  BattlePVPScene.super.didEnter(self)
  require("app.GuideManager").H_StartGuideGroup(6000)
end
function BattlePVPScene:FightWin()
  if self.m_gdMng:GetCurPVPInfo().isFriend then
    local layer = require("app.layers.battle.FightWinLayer").new()
    self:addChild(layer, 102)
  end
end
function BattlePVPScene:FightLose()
  if self.m_gdMng:GetCurPVPInfo().isFriend then
    local layer = require("app.layers.battle.FightLoseLayer").new()
    self:addChild(layer, 102)
  end
end
function BattlePVPScene:PVPStartData(data)
  self.m_gdMng:GetCurPVPInfo().logId = data.log_id
  self:SendGetRivalArenaRequest()
  local missionInfo = require("app.info.MissionInfoManager"):GetInstance():GetMissionInfo(td.ARENA_ID)
  UserDataManager:GetInstance():PublicConsume(td.WealthType.STAMINA, missionInfo.vit)
end
function BattlePVPScene:PVPFriendStartData(data)
  self:PVPStart()
end
function BattlePVPScene:PVPStart()
  self.m_uiLayer = require("app.layers.battle.PVPBattleUILayer").new()
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
function BattlePVPScene:PVPFightOverData(data)
  if self.m_mapInfo.type ~= td.MapType.PVP or self:getChildByTag(102) then
    return
  end
  local PVPFightOverDlg = require("app.layers.battle.PVPFightOverDlg")
  local layer = PVPFightOverDlg.new({
    maxRank = data.max_rank,
    curRank = data.rank_num,
    ticket = data.ticket,
    isWin = self.m_gdMng:IsFightWin()
  })
  self:addChild(layer, 102)
end
function BattlePVPScene:AddListeners()
  self:AddCustomEvent(td.FIGHT_WIN, handler(self, self.FightWin))
  self:AddCustomEvent(td.FIGHT_LOSE, handler(self, self.FightLose))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  self:AddCustomEvent(td.FRIEND_FIGHT_START, handler(self, self.PVPFriendStartData))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.ArenaFightBefore, handler(self, self.PVPStartData))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.ArenaFightAfter, handler(self, self.PVPFightOverData))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetPlayerAreanaInfo, handler(self, self.GetRivalArenaCallback))
end
function BattlePVPScene:RemoveListeners()
  BattlePVPScene.super.RemoveListeners(self)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.ArenaFightBefore)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.ArenaFightAfter)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetPlayerAreanaInfo)
end
function BattlePVPScene:UpdateMonster(dt)
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
            tempInfo = StrongInfoManager:GetInstance():GetHeroFinalInfo(heroData, self.m_PVPWeaponDatas, self.m_PVPSkillDatas, self.m_PVPGemDatas)
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
function BattlePVPScene:SendGetRivalArenaRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetPlayerAreanaInfo
  Msg.sendData = {
    type = 1,
    uid = self.m_gdMng:GetCurPVPInfo().id
  }
  Msg.cbData = clone(data)
  TDHttpRequest:getInstance():Send(Msg)
end
function BattlePVPScene:GetRivalArenaCallback(data)
  UserDataManager:GetInstance():SetEnemyPVPData(data.otherArena)
  self:PVPStart()
end
function BattlePVPScene:SaveMonsterPlan()
  self.m_vMonsterPlans = {}
  local data = UserDataManager:GetInstance():GetPVPData()
  local selfData = data.selfData
  local enemyData = data.otherDatas[self.m_gdMng:GetCurPVPInfo().id]
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
return BattlePVPScene
