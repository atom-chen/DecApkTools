local BattleScene = require("app.scenes.BattleScene")
local ActorManager = require("app.actor.ActorManager")
local TriggerManager = require("app.trigger.TriggerManager")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local GameDataManager = require("app.GameDataManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local scheduler = require("framework.scheduler")
local bomb_config = require("app.config.bomb_config")
local BattleBombScene = class("BattleBombScene", BattleScene)
function BattleBombScene:ctor()
  BattleBombScene.super.ctor(self)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_gdMng = GameDataManager:GetInstance()
  self.m_bombData = self.m_gdMng:GetBombData()
  self.m_tagIdDic = {}
  self.m_awards = {}
  self.m_bombIdToSend = {}
end
function BattleBombScene:onEnter()
  BattleBombScene.super.onEnter(self)
  self.m_timeScheduler = scheduler.scheduleGlobal(handler(self, self.OnTimer), 0.2)
end
function BattleBombScene:onExit()
  BattleBombScene.super.onExit(self)
  self:StopTimer()
end
function BattleBombScene:InitGame()
  self.m_uiLayer = require("app.layers.battle.BattleUILayer").new()
  self:addChild(self.m_uiLayer, 101)
  self:InitHeroData()
  self:CreateHero()
  self:SaveMonsterPlan()
  self.m_gdMng:SetMonsterWave(1)
end
function BattleBombScene:InitHeroData()
  local heroData = clone(self.m_udMng:GetHeroData(self.m_bombData.hero))
  self.m_gdMng:InitHeros({heroData})
end
function BattleBombScene:UpdateMonster(dt)
  if not self.m_bFightStart then
    return
  end
  if not self.m_vMonsterPlans or #self.m_vMonsterPlans == 0 then
    self.m_gdMng:SetSingleCreateAll(true)
    return
  end
  local endTime = self.m_gdMng:GetEndTime()
  if endTime == -1 then
    return
  end
  self.m_fTimeInterval = self.m_fTimeInterval + dt
  if endTime > self.m_fTimeInterval then
    return
  end
  if self.m_bWaitForNextWave then
    local curCount = (self.m_gdMng:GetMonsterWave() - 1) * #self.m_vMonsterPlans + self.m_gdMng:GetCurMonsterCount()
    self.m_bWaitForNextWave = false
  end
  local pMap = self.m_gdMng:GetGameMap()
  local iCurMonsterCount = self.m_gdMng:GetCurMonsterCount()
  local iCurSubMonsterCount = self.m_gdMng:GetCurSubMonsterCount()
  if iCurSubMonsterCount <= self.m_gdMng:GetMaxSubMonsterCount() then
    local subAllCreate = true
    local pPlan = self.m_vMonsterPlans[iCurMonsterCount].monstInfos[iCurSubMonsterCount].subMonstInfos
    local didCreate = false
    self.m_iSubWaveIndex = self.m_iSubWaveIndex + 1
    if self.m_iSubWaveIndex > #pPlan then
      self.m_iSubWaveIndex = 1
    end
    local totalCount, count, index = #pPlan, 1, self.m_iSubWaveIndex
    while true do
      if not (totalCount >= count) or didCreate then
        break
      end
      local info = pPlan[index]
      if info.count < info.num then
        info.count = info.count + 1
        subAllCreate = false
        didCreate = true
        if not self.m_bWaveStart then
          TriggerManager:GetInstance():SendEvent({
            eType = td.ConditionType.BeforeRefreshMonster,
            waveCnt = iCurMonsterCount
          })
          if iCurMonsterCount <= #self.m_vMonsterPlans then
            local reward = self.m_vMonsterPlans[iCurMonsterCount].reward
            if reward then
              self.m_gdMng:UpdateCurResCount(reward)
            end
          end
          self.m_bWaveStart = true
        end
        local pathID = pMap:GetRandomPathID()
        local bInverted = math.random(2) == 1
        local pActor = ActorManager:GetInstance():CreateActor(info.type, info.id, info.enemy)
        ActorManager:GetInstance():CreateActorPathById(pActor, pathID, bInverted, info.pos)
        pMap:addChild(pActor, pMap:GetPiexlSize().height - pActor:getPositionY(), pActor:getTag())
        self.m_tagIdDic[pActor:getTag()] = info.index
        local monsterData = self.m_bombData.monsters[info.index]
        pActor:SetCollectionRes(monsterData.item_id)
      end
      count = count + 1
      index = totalCount >= index + 1 and index + 1 or 1
    end
    self.m_fTimeInterval = 0
    if subAllCreate then
      self.m_iSubWaveIndex = 0
      local iNextSubCount = iCurSubMonsterCount + 1
      if iNextSubCount <= self.m_gdMng:GetMaxSubMonsterCount() then
        self.m_gdMng:SetCurSubMonsterCount(iNextSubCount)
        local nextWaitTime = self.m_vMonsterPlans[iCurMonsterCount].monstInfos[iCurSubMonsterCount].nextWait or 0
        self.m_gdMng:SetEndTime(nextWaitTime)
      else
        self.m_bWaveStart = false
        local iNextCount = iCurMonsterCount + 1
        if iNextCount <= #self.m_vMonsterPlans then
          self.m_gdMng:SetCurMonsterCount(iNextCount)
          self.m_gdMng:SetCurSubMonsterCount(1)
          self.m_gdMng:SetMaxSubMonsterCount(#self.m_vMonsterPlans[iNextCount].monstInfos)
          local nextWaitTime = self.m_vMonsterPlans[iNextCount].monstInfos[1].nextWait or 0
          self.m_gdMng:SetEndTime(nextWaitTime)
          self.m_bWaitForNextWave = true
        else
          self.m_gdMng:SetSingleCreateAll(true)
        end
        TriggerManager:GetInstance():SendEvent({
          eType = td.ConditionType.AfterRefreshMonster,
          isAdd = false,
          waveCnt = iCurMonsterCount
        })
        if iCurMonsterCount == #self.m_vMonsterPlans then
          self:ResetMonsterPlanCount()
          self.m_gdMng:SetCurMonsterCount(1)
          self.m_gdMng:SetCurSubMonsterCount(1)
          self.m_gdMng:SetMaxSubMonsterCount(#self.m_vMonsterPlans[1].monstInfos)
          self.m_gdMng:SetMonsterWave(self.m_gdMng:GetMonsterWave() + 1)
          self.m_bWaitForNextWave = true
        end
      end
    else
      self.m_gdMng:SetEndTime(td.NewActorGap)
    end
  end
end
function BattleBombScene:SaveMonsterPlan()
  self.m_vMonsterPlans = {}
  for i, var in ipairs(self.m_bombData.monsters) do
    local plan = {}
    plan.reward = 0
    plan.monstInfos = {}
    table.insert(self.m_vMonsterPlans, plan)
    local info = {}
    info.nextWait = bomb_config.troop_gap
    info.subMonstInfos = {}
    table.insert(plan.monstInfos, info)
    local subinfo = {}
    subinfo.count = 0
    subinfo.type = td.ActorType.Monster
    subinfo.enemy = true
    subinfo.id = var.monster_id
    subinfo.index = i
    subinfo.num = 1
    table.insert(info.subMonstInfos, subinfo)
  end
  self.m_gdMng:SetMaxMonsterCount(#self.m_vMonsterPlans)
  if #self.m_vMonsterPlans > 0 then
    self.m_gdMng:SetMaxSubMonsterCount(#self.m_vMonsterPlans[1].monstInfos)
    local nextWaitTime = self.m_vMonsterPlans[1].monstInfos[1].nextWait
    self.m_gdMng:SetEndTime(nextWaitTime)
    self.m_bWaitForNextWave = true
  end
  self.m_bFightStart = true
end
function BattleBombScene:DropAward(_tag)
  local monsterData = self.m_bombData.monsters[self.m_tagIdDic[_tag]]
  if not self.m_awards[monsterData.item_id] then
    self.m_awards[monsterData.item_id] = monsterData.item_num
  else
    self.m_awards[monsterData.item_id] = self.m_awards[monsterData.item_id] + monsterData.item_num
  end
end
function BattleBombScene:FightOver()
  local PVPFightOverDlg = require("app.layers.battle.BombFightOverDlg")
  local layer = PVPFightOverDlg.new(self.m_awards)
  self:addChild(layer, 102)
end
function BattleBombScene:AddListeners()
  self:AddCustomEvent(td.FIGHT_WIN, handler(self, self.FightOver))
  self:AddCustomEvent(td.ACTOR_DIED, handler(self, self.OnMonsterDied))
end
function BattleBombScene:RemoveListeners()
  BattleBombScene.super.RemoveListeners(self)
end
function BattleBombScene:OnMonsterDied(event)
  local _tag = tonumber(event:getDataString())
  local index = self.m_tagIdDic[_tag]
  if not index then
    return
  end
  table.insert(self.m_bombIdToSend, self.m_bombData.monsters[self.m_tagIdDic[_tag]].id)
  self:DropAward(_tag)
end
function BattleBombScene:OnTimer()
  if #self.m_bombIdToSend > 0 then
    self:BombMonsterReq()
    self.m_bombIdToSend = {}
  end
end
function BattleBombScene:StopTimer()
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
    self.m_timeScheduler = nil
  end
end
function BattleBombScene:BombMonsterReq()
  local Msg = {}
  Msg.msgType = td.RequestID.BombMonster
  Msg.sendData = {
    id = self.m_bombIdToSend
  }
  Msg.cbData = {tag = _tag}
  TDHttpRequest:getInstance():SendPrivate(Msg, true)
end
return BattleBombScene
