local BattleScene = require("app.scenes.BattleScene")
local ActorManager = require("app.actor.ActorManager")
local TriggerManager = require("app.trigger.TriggerManager")
local UserDataManager = require("app.UserDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local ActorInfoManager = require("app.info.ActorInfoManager")
local GameDataManager = require("app.GameDataManager")
local GuildDataManager = require("app.GuildDataManager")
local scheduler = require("framework.scheduler")
local BattleBossGuildScene = class("BattleBossGuildScene", BattleScene)
function BattleBossGuildScene:ctor()
  BattleBossGuildScene.super.ctor(self)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_gdMng = GameDataManager:GetInstance()
  self.m_guildMng = GuildDataManager:GetInstance()
  self.m_bossTag = 0
  self.m_accHarm = 0
  self.m_totalHarm = 0
end
function BattleBossGuildScene:onEnter()
  BattleBossGuildScene.super.onEnter(self)
  self.m_timeScheduler = scheduler.scheduleGlobal(handler(self, self.OnTimer), 0.2)
end
function BattleBossGuildScene:onExit()
  BattleBossGuildScene.super.onExit(self)
  self:StopTimer()
end
function BattleBossGuildScene:InitGame()
  self.m_uiLayer = require("app.layers.battle.BattleUILayer").new()
  self:addChild(self.m_uiLayer, 101)
  local herosData = StrongInfoManager:GetInstance():GetBattleHeros()
  self.m_gdMng:InitHeros(herosData)
  self:CreateHero()
  self:SaveMonsterPlan()
  self:InitActor()
end
function BattleBossGuildScene:InitActor()
  local pMap = self.m_gdMng:GetGameMap()
  local bossData = self.m_gdMng:GetGuildBossData()
  local pBoss = ActorManager:GetInstance():CreateActor(td.ActorType.Monster, bossData.bossId, true)
  pBoss:SetCurHp(bossData.hp)
  ActorManager:GetInstance():CreateActorPathById(pBoss, 1)
  pMap:addChild(pBoss, pMap:GetPiexlSize().height - pBoss:getPositionY(), pBoss:getTag())
  self.m_bossTag = pBoss:getTag()
end
function BattleBossGuildScene:FightOver()
  local PVPFightOverDlg = require("app.layers.battle.GuildBossFightOverDlg")
  local layer = PVPFightOverDlg.new({
    isWin = self.m_gdMng:IsFightWin(),
    harm = self.m_totalHarm
  })
  self:addChild(layer, 102)
end
function BattleBossGuildScene:AddListeners()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GuildBossAfter, handler(self, self.BossAfterCallback))
  self:AddCustomEvent(td.ADD_SOLDIER_EVENT, handler(self, self.AddSoldier))
  self:AddCustomEvent(td.CHANGE_HERO, handler(self, self.ChangeHero))
  self:AddCustomEvent(td.FIGHT_WIN, handler(self, self.FightOver))
  self:AddCustomEvent(td.FIGHT_LOSE, handler(self, self.FightOver))
  self:AddCustomEvent(td.GUILD_BOSS_HP, handler(self, self.ChangeBossHP))
end
function BattleBossGuildScene:RemoveListeners()
  BattleBossGuildScene.super.RemoveListeners(self)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GuildBossAfter)
end
function BattleBossGuildScene:AddSoldier(_event)
  local data = string.toTable(_event:getDataString())
  local pMap = self.m_gdMng:GetGameMap()
  local pos = cc.p(data.x, data.y)
  local cost, soldier = 0, nil
  local soldier = ActorManager:GetInstance():CreateActor(td.ActorType.Soldier, data.id, false)
  if soldier then
    soldier:setPosition(pos)
    pMap:addChild(soldier, pMap:GetPiexlSize().height - soldier:getPositionY(), soldier:getTag())
  end
end
function BattleBossGuildScene:ChangeBossHP(_event)
  local hp = tonumber(_event:getDataString()) or 0
  if math.abs(hp) > 10000 then
    local debug = 1
  end
  self.m_accHarm = self.m_accHarm + math.abs(hp)
  self.m_totalHarm = self.m_totalHarm + math.abs(hp)
end
function BattleBossGuildScene:OnTimer()
  self:BossAfterReq(self.m_accHarm)
  print(self.m_accHarm)
  self.m_accHarm = 0
end
function BattleBossGuildScene:StopTimer()
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
    self.m_timeScheduler = nil
  end
end
function BattleBossGuildScene:BossAfterReq(hurtHp)
  local Msg = {}
  Msg.msgType = td.RequestID.GuildBossAfter
  Msg.sendData = {
    guild_id = self.m_guildMng:GetGuildData().id,
    harm = hurtHp
  }
  TDHttpRequest:getInstance():SendPrivate(Msg, true)
end
function BattleBossGuildScene:BossAfterCallback(data)
  if data.state == td.ResponseState.Success then
    local pBoss = ActorManager:GetInstance():FindActorByTag(self.m_bossTag, true)
    if not pBoss then
      return
    end
    if pBoss:GetCurHp() ~= data.hp then
      pBoss:SetCurHp(data.hp)
      if pBoss:IsDead() then
        pBoss:OnDead()
        self:StopTimer()
      end
    end
  end
end
return BattleBossGuildScene
