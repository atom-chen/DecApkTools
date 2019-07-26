local BattleScene = require("app.scenes.BattleScene")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local TriggerManager = require("app.trigger.TriggerManager")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local StrongInfoManager = require("app.info.StrongInfoManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local BattleGuideScene = class("BattleGuideScene", BattleScene)
function BattleGuideScene:ctor()
  BattleGuideScene.super.ctor(self)
end
function BattleGuideScene:AddListeners()
  BattleGuideScene.super.AddListeners(self)
  self:AddCustomEvent(td.GUIDE_REMOVE_MONSTER, handler(self, self.RemoveMonster))
  self:AddCustomEvent(td.GUIDE_CREATE_HERO, handler(self, self.CreateHero))
  self:AddCustomEvent(td.GUIDE_CREATE_MONSTER, function()
    self:CreateMonsters(2)
  end)
  self:AddCustomEvent(td.GUIDE_HERO_WALK, handler(self, self.GuideHero))
end
function BattleGuideScene:InitGame()
  local pMap = self.m_gdMng:GetGameMap()
  if self.m_gdMng:GetGameMapInfo().id == td.TRAIN_ID then
    self:CreateSoldiers(1)
  end
  self.m_pathBatchNode = display.newBatchNode(td.UI_PATH_SIGN)
  pMap:addChild(self.m_pathBatchNode, td.InMapZOrder.PathSign)
  self.m_uiLayer = require("app.layers.battle.BattleUIGuideLayer").new()
  self:addChild(self.m_uiLayer, 101)
  self:SaveMonsterPlan()
end
function BattleGuideScene:CreateHero()
  local herosData = StrongInfoManager:GetInstance():GetGuideHeros()
  self.m_gdMng:InitHeros(herosData)
  BattleGuideScene.super.CreateHero(self)
  local pHero = self.m_gdMng:GetCurHero()
  pHero:PlayAnimations({
    {
      aniName = "skill_01",
      isLoop = false,
      callback = function()
        self:CreateSoldiers(2)
        td.dispatchEvent(td.GUIDE_CONTINUE)
      end
    },
    {aniName = "stand", isLoop = true}
  })
end
function BattleGuideScene:GuideHero()
  local pHero = self.m_gdMng:GetCurHero()
  pHero:PlayAnimation("run", true)
  pHero:runAction(cca.seq({
    cca.moveTo(4, 1250, 600),
    cca.cb(function()
      pHero:PlayAnimation("stand", true)
      td.dispatchEvent(td.GUIDE_CONTINUE)
    end)
  }))
end
function BattleGuideScene:CreateSoldiers(iWave)
  local pMap = self.m_gdMng:GetGameMap()
  local soldiersData = StrongInfoManager:GetInstance():GetGuideSoldiers()
  self.m_gdMng:SetGuideSoldiers(soldiersData)
  local t = require("app.config.guide_soldiers")[iWave]
  if iWave == 1 then
    for i, var in ipairs(t) do
      local tilePos = pMap:GetTilePosFromPixelPos(cc.p(var.x, var.y))
      local iPathID = pMap:GetPathID(tilePos, "0")
      local soldierInfo = soldiersData[var.id].soldierInfo
      local pActor = ActorManager:GetInstance():CreateActor(td.ActorType.Soldier, var.id, false, soldierInfo)
      ActorManager:GetInstance():CreateActorPathById(pActor, iPathID, false, cc.p(var.x, var.y))
      pMap:addChild(pActor, pMap:GetPiexlSize().height - pActor:getPositionY(), pActor:getTag())
    end
  else
    do
      local pEffect = require("app.effect.EffectManager"):GetInstance():CreateEffect(2313)
      pEffect:setPosition(-250, 680)
      pEffect:runAction(cca.seq({
        cc.EaseBackOut:create(cca.moveBy(1, 1300, 0)),
        cca.cb(function()
          pEffect:runAction(cca.repeatForever(cca.seq({
            cca.scaleTo(1, 1.95),
            cca.scaleTo(1, 2.05)
          })))
        end)
      }))
      pEffect:AddToMap(pMap)
      for i, var in ipairs(t) do
        self:performWithDelay(function()
          local tilePos = pMap:GetTilePosFromPixelPos(cc.p(var.x, var.y))
          local iPathID = pMap:GetPathID(tilePos, "0")
          local soldierInfo = soldiersData[var.id].soldierInfo
          local pActor = ActorManager:GetInstance():CreateActor(td.ActorType.Soldier, var.id, false, soldierInfo)
          pActor:SetEnterEffect(2312, 1)
          ActorManager:GetInstance():CreateActorPathById(pActor, iPathID, false, cc.p(var.x, var.y))
          pMap:addChild(pActor, pMap:GetPiexlSize().height - pActor:getPositionY(), pActor:getTag())
        end, 0.5 + i * 0.1)
      end
    end
  end
  self.m_gdMng:UpdateCurPopulation(#t)
end
function BattleGuideScene:CreateMonsters(iWave)
  local t = require("app.config.guide_monsters")
  local vMonster = t[iWave]
  local pMap = self.m_gdMng:GetGameMap()
  for i, var in ipairs(vMonster) do
    local tilePos = pMap:GetTilePosFromPixelPos(cc.p(var.x, var.y))
    local iPathID = pMap:GetPathID(tilePos, "0")
    local pActor = ActorManager:GetInstance():CreateActor(td.ActorType.Monster, var.id, true)
    ActorManager:GetInstance():CreateActorPathById(pActor, iPathID, true, cc.p(var.x, var.y))
    pMap:addChild(pActor, pMap:GetPiexlSize().height - pActor:getPositionY(), pActor:getTag())
  end
end
function BattleGuideScene:RemoveMonster(event)
  local boss = ActorManager:GetInstance():FindActorById(9009)
  boss:FlyOut()
end
return BattleGuideScene
