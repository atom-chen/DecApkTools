local BattleScene = require("app.scenes.BattleScene")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local TriggerManager = require("app.trigger.TriggerManager")
local UserDataManager = require("app.UserDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local MissionInfoManager = require("app.info.MissionInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local CommonInfoManager = require("app.info.CommonInfoManager")
local BattleTrialScene = class("BattleTrialScene", BattleScene)
local BuyResID = {
  9002,
  9003,
  9004
}
function BattleTrialScene:ctor()
  BattleTrialScene.super.ctor(self)
end
function BattleTrialScene:InitGame()
  local pMap = self.m_gdMng:GetGameMap()
  pMap:HighlightPos(cc.p(0, pMap:GetPiexlSize().height / 2), -1)
  local infoDlg = require("app.layers.battle.TrialInfoDlg").new()
  infoDlg:SetCallback(handler(self, self.InitPaibingUI))
  td.popView(infoDlg, true)
end
function BattleTrialScene:InitPaibingUI()
  self.m_uiLayer = require("app.layers.battle.PaibingUILayer").new()
  self.m_uiLayer:SetStartCb(handler(self, self.StartFight))
  self.m_uiLayer:SetLeaveCb(function()
    self.m_gdMng:ExitGame()
  end)
  self.m_uiLayer:SetLackResCb(handler(self, self.OnLackRes))
  self.m_uiLayer:HideTopTab()
  self:addChild(self.m_uiLayer, 101)
end
function BattleTrialScene:StartFight()
  self.m_uiLayer:Close()
  local pMap = self.m_gdMng:GetGameMap()
  local layer = pMap:GetTileMap():getLayer("shade_1")
  if layer then
    layer:setVisible(false)
  end
  self.m_uiLayer = require("app.layers.battle.TrialBattleUILayer").new()
  self:addChild(self.m_uiLayer, 101)
  self.m_gdMng:AddAllPassBlock(11)
  self:SaveMonsterPlan()
  local vec = ActorManager:GetInstance():GetSelfVec()
  for i, v in pairs(vec) do
    local pos = cc.p(v:getPosition())
    ActorManager:GetInstance():CreateActorPath(v, pos, pos)
  end
end
function BattleTrialScene:OnLackRes()
  local goodInfo = CommonInfoManager:GetInstance():GetMallItemInfo(BuyResID[self.m_gdMng:GetTrialData().mode])
  local messageLabel = td.RichText({
    {
      type = 1,
      str = "\230\152\175\229\144\166\232\138\177\232\180\185",
      size = 18,
      color = td.WHITE
    },
    {
      type = 1,
      str = tostring(goodInfo.price),
      size = 18,
      color = td.GREEN
    },
    {
      type = 2,
      file = td.DIAMOND_ICON,
      scale = 0.6
    },
    {
      type = 1,
      str = "\232\189\172\230\141\162" .. goodInfo.quantity,
      size = 18,
      color = td.WHITE
    },
    {
      type = 2,
      file = td.FORCE_ICON,
      scale = 0.6
    }
  })
  local button1 = {
    text = g_LM:getBy("a00009"),
    callFunc = handler(self, self.BuyRes)
  }
  local button2 = {
    text = g_LM:getBy("a00116")
  }
  local data = {
    size = cc.size(454, 300),
    title = "\229\142\159\229\138\155\228\184\141\232\182\179",
    content = messageLabel,
    buttons = {button1, button2}
  }
  local messageBox = require("app.layers.MessageBoxDlg").new(data)
  messageBox:Show()
end
function BattleTrialScene:FightWin()
  self:TrialWinReq()
end
function BattleTrialScene:FightLose()
  local TrialOverLayer = require("app.layers.battle.TrialOverLayer")
  local layer = TrialOverLayer.new(false)
  self:addChild(layer, 102)
end
function BattleTrialScene:AddListeners()
  self:AddCustomEvent(td.FIGHT_WIN, handler(self, self.FightWin))
  self:AddCustomEvent(td.FIGHT_LOSE, handler(self, self.FightLose))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.TrialWin, handler(self, self.TrialWinCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.MallBuy, handler(self, self.BuyResCallback))
end
function BattleTrialScene:RemoveListeners()
  BattleTrialScene.super.RemoveListeners(self)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.TrialWin)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.MallBuy)
end
function BattleTrialScene:UpdateMonster(dt)
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
        local pActor = ActorManager:GetInstance():CreateActor(td.ActorType.Monster, info.id, true)
        local iRandom = 1 < #info.paths and math.random(#info.paths) or 1
        local pathID = info.paths[iRandom].pathID
        local bInverted = info.paths[iRandom].bInverted
        ActorManager:GetInstance():CreateActorPathById(pActor, pathID, bInverted, info.pos)
        pMap:addChild(pActor, pMap:GetPiexlSize().height - pActor:getPositionY(), pActor:getTag())
      end
    end
    self.m_gdMng:SetSingleCreateAll(bAllCreate)
    if bAllCreate then
      self.m_gdMng:SetCurMonsterCount(iCurMonsterCount + 1)
      self.m_fTimeInterval = 0
    end
  end
end
function BattleTrialScene:SaveMonsterPlan()
  self.m_vMonsterPlans = {}
  local plan = {}
  local pMap = self.m_gdMng:GetGameMap()
  local planStr = self.m_gdMng:GetGameMapInfo().monster_plan
  planStr = string.split(planStr, ";")
  for i, v in ipairs(planStr) do
    local t1 = string.split(v, ":")
    local info = {}
    info.count = 0
    info.paths = {}
    info.enemy = true
    info.id = tonumber(t1[1])
    info.num = 1
    info.pos = cc.p(tonumber(t1[2]), tonumber(t1[3]))
    local tilePos = pMap:GetTilePosFromPixelPos(info.pos)
    local iPathID = pMap:GetPathID(tilePos, "0")
    table.insert(info.paths, {pathID = iPathID, bInverted = true})
    table.insert(plan, info)
  end
  table.insert(self.m_vMonsterPlans, plan)
  self.m_gdMng:SetMaxMonsterCount(#self.m_vMonsterPlans)
  self.m_gdMng:SetMaxSubMonsterCount(1)
  self.m_bFightStart = true
end
function BattleTrialScene:BuyRes()
  local Msg = {}
  Msg.msgType = td.RequestID.MallBuy
  Msg.sendData = {
    id = BuyResID[self.m_gdMng:GetTrialData().mode],
    num = 1
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function BattleTrialScene:BuyResCallback(data)
  if data.state == td.ResponseState.Success then
    local mode = self.m_gdMng:GetTrialData().mode
    local goodInfo = CommonInfoManager:GetInstance():GetMallItemInfo(BuyResID[mode])
    UserDataManager:GetInstance():GetTrialData():UpdateInitRes(goodInfo.quantity, mode)
    self.m_gdMng:UpdateCurResCount(goodInfo.quantity)
    td.alert(g_LM:getBy("a00355"))
  end
end
function BattleTrialScene:TrialWinReq(data)
  local trialData = self.m_gdMng:GetTrialData()
  local trialLevelInfo = MissionInfoManager:GetInstance():GetTrialLevelInfo(trialData.mode, trialData.level)
  local Msg = {}
  Msg.msgType = td.RequestID.TrialWin
  Msg.sendData = {
    id = trialLevelInfo.id,
    num = self.m_gdMng:GetCostRes()
  }
  Msg.cbData = {
    num = self.m_gdMng:GetCostRes()
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function BattleTrialScene:TrialWinCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    local TrialOverLayer = require("app.layers.battle.TrialOverLayer")
    layer = TrialOverLayer.new(true)
    self:addChild(layer, 102)
    UserDataManager:GetInstance():GetTrialData():UpdateInitRes(-cbData.num, self.m_gdMng:GetTrialData().mode)
  end
end
return BattleTrialScene
