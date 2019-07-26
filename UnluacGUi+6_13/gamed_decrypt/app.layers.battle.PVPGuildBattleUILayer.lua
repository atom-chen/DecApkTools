local GameDataManager = require("app.GameDataManager")
local UserDataManager = require("app.UserDataManager")
local ActorManager = require("app.actor.ActorManager")
local PauseLayer = require("app.layers.battle.PauseDlg")
local CommanderInfoManager = require("app.info.CommanderInfoManager")
local ActorDetailDlg = require("app.widgets.ActorDetailDlg")
local BaseDlg = require("app.layers.BaseDlg")
local PVPGuildBattleUILayer = class("PVPGuildBattleUILayer", function()
  return display.newLayer()
end)
function PVPGuildBattleUILayer:ctor()
  self:initData()
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function PVPGuildBattleUILayer:onEnter()
  self:addListeners()
end
function PVPGuildBattleUILayer:onExit()
  self:removeListeners()
  cc.Director:getInstance():getScheduler():setTimeScale(1)
end
function PVPGuildBattleUILayer:initData()
  local selfVec = ActorManager:GetInstance():GetSelfVec()
  local enemyVec = ActorManager:GetInstance():GetEnemyVec()
  self.m_selfNum = table.nums(selfVec)
  self.m_selfHP = 0
  self.m_enemyNum = table.nums(enemyVec)
  self.m_enemyHP = 0
  for key, var in pairs(selfVec) do
    self.m_selfHP = self.m_selfHP + var:GetCurHp()
  end
  for key, var in pairs(enemyVec) do
    self.m_enemyHP = self.m_enemyHP + var:GetCurHp()
  end
  self.m_curSelfHP = self.m_selfHP
  self.m_curEnemyHP = self.m_enemyHP
end
function PVPGuildBattleUILayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/PVPBattleUILayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 10000)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_pPanel_top = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_top")
  td.SetAutoScale(self.m_pPanel_top, td.UIPosHorizontal.Center, td.UIPosVertical.Top)
  self.m_pPanel_bottom = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bottom")
  self.m_pPanel_bottom:setVisible(false)
  td.SetAutoScale(self.m_pPanel_bottom, td.UIPosHorizontal.Center, td.UIPosVertical.Bottom)
  local timeNode = cc.uiloader:seekNodeByName(self.m_pPanel_top, "TimeNode")
  local str = td.GetStrForTime(GameDataManager:GetInstance():GetGameMapInfo().max_time)
  self.m_timeLabel = td.CreateLabel(str, td.WHITE, 18, td.OL_BLACK)
  self.m_timeLabel:setAnchorPoint(0, 0.5)
  self.m_timeLabel:addTo(timeNode)
  local label1 = td.CreateBMF(g_LM:getBy("a00289"), "Fonts/BlackWhite18.fnt", 1)
  label1:setAnchorPoint(0, 0.5)
  label1:pos(-220, 16):addTo(self.m_bg)
  self.m_selfNumLabel = td.CreateBMF(tostring(self.m_selfNum), "Fonts/BlackWhite18.fnt", 1.2)
  self.m_selfNumLabel:setAnchorPoint(0, 0.5)
  self.m_selfNumLabel:pos(label1:getPositionX() + label1:getBoundingBox().width, label1:getPositionY()):addTo(self.m_bg)
  local label2 = td.CreateBMF(g_LM:getBy("a00290"), "Fonts/BlackWhite18.fnt", 1)
  label2:setAnchorPoint(1, 0.5)
  label2:pos(460, 16):addTo(self.m_bg)
  self.m_enemyNumLabel = td.CreateBMF(tostring(self.m_enemyNum), "Fonts/BlackWhite18.fnt", 1.2)
  self.m_enemyNumLabel:setAnchorPoint(0, 0.5)
  self.m_enemyNumLabel:pos(label2:getPositionX(), label2:getPositionY()):addTo(self.m_bg)
  local hpSpr = display.newSprite("#UI/battle/lvse_jianbiantiao.png")
  self.m_selfProgress = cc.ProgressTimer:create(hpSpr)
  self.m_selfProgress:setAnchorPoint(0, 0.5)
  self.m_selfProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  self.m_selfProgress:setMidpoint(cc.p(1, 0))
  self.m_selfProgress:setBarChangeRate(cc.p(1, 0))
  self.m_selfProgress:setPercentage(100)
  self.m_selfProgress:setPosition(-220, 48)
  self.m_selfProgress:addTo(self.m_bg)
  hpSpr = display.newSprite("#UI/battle/hongse_jianbiantiao.png")
  self.m_enemyProgress = cc.ProgressTimer:create(hpSpr)
  self.m_enemyProgress:setAnchorPoint(1, 0.5)
  self.m_enemyProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  self.m_enemyProgress:setMidpoint(cc.p(0, 0))
  self.m_enemyProgress:setBarChangeRate(cc.p(1, 0))
  self.m_enemyProgress:setPercentage(100)
  self.m_enemyProgress:setPosition(488, 48)
  self.m_enemyProgress:addTo(self.m_bg)
end
function PVPGuildBattleUILayer:addListeners()
  self.m_vListeners = {}
  self:AddCustomEvent(td.SHOW_ACTOR_DETAIL, handler(self, self.showActorDetail))
  self:AddCustomEvent(td.ACTOR_DIED, function(_event)
    local tag = tonumber(_event:getDataString())
    local pActor = ActorManager:GetInstance():FindActorByTag(tag)
    local groupType = pActor:GetRealGroupType()
    if groupType == td.GroupType.Self then
      self.m_selfNum = cc.clampf(self.m_selfNum - 1, 0, 1000)
      self.m_selfNumLabel:setString(tonumber(self.m_selfNum))
    else
      self.m_enemyNum = cc.clampf(self.m_enemyNum - 1, 0, 1000)
      self.m_enemyNumLabel:setString(tonumber(self.m_enemyNum))
    end
  end)
  self:AddCustomEvent(td.ACTOR_BORN, function(_event)
    local tag = tonumber(_event:getDataString())
    local pActor = ActorManager:GetInstance():FindActorByTag(tag)
    local groupType = pActor:GetRealGroupType()
    if groupType == td.GroupType.Self then
      self.m_selfNum = cc.clampf(self.m_selfNum + 1, 0, 1000)
      self.m_selfNumLabel:setString(tonumber(self.m_selfNum))
      self.m_selfHP = self.m_selfHP + pActor:GetCurHp()
      self.m_curSelfHP = self.m_curSelfHP + pActor:GetCurHp()
      self.m_selfProgress:setPercentage(self.m_curSelfHP / self.m_selfHP * 100)
    else
      self.m_enemyNum = cc.clampf(self.m_enemyNum + 1, 0, 1000)
      self.m_enemyNumLabel:setString(tonumber(self.m_enemyNum))
      self.m_enemyHP = self.m_enemyHP + pActor:GetCurHp()
      self.m_curEnemyHP = self.m_curEnemyHP + pActor:GetCurHp()
      self.m_enemyProgress:setPercentage(self.m_curEnemyHP / self.m_enemyHP * 100)
    end
  end)
  self:AddCustomEvent(td.ACTOR_CHANGE_HP, function(_event)
    local data = string.toTable(_event:getDataString())
    if tonumber(data.group) == td.GroupType.Self then
      self.m_curSelfHP = self.m_curSelfHP + tonumber(data.hp)
      self.m_selfProgress:setPercentage(self.m_curSelfHP / self.m_selfHP * 100)
    else
      self.m_curEnemyHP = self.m_curEnemyHP + tonumber(data.hp)
      self.m_enemyProgress:setPercentage(self.m_curEnemyHP / self.m_enemyHP * 100)
    end
  end)
end
function PVPGuildBattleUILayer:AddCustomEvent(name, cb)
  local eventDispatcher = self:getEventDispatcher()
  local listener = cc.EventListenerCustom:create(name, cb)
  eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
  table.insert(self.m_vListeners, listener)
end
function PVPGuildBattleUILayer:removeListeners()
  local eventDispatcher = self:getEventDispatcher()
  for i, listener in ipairs(self.m_vListeners) do
    eventDispatcher:removeEventListener(listener)
  end
  self.m_vListeners = {}
end
function PVPGuildBattleUILayer:SetTime(time)
  local str = td.GetStrForTime(time)
  self.m_timeLabel:setString(str)
end
function PVPGuildBattleUILayer:showActorDetail(_event)
  local data = string.toTable(_event:getDataString())
  if self.m_actorDetailDlg then
    self.m_actorDetailDlg:removeFromParent()
    self.m_actorDetailDlg = nil
  end
  if tonumber(data.tag) ~= -1 then
    self.m_actorDetailDlg = ActorDetailDlg.new()
    self.m_actorDetailDlg:SetData(data.tag)
    self.m_actorDetailDlg:setScale(td.GetAutoScale())
    self.m_uiRoot:addChild(self.m_actorDetailDlg, 2)
  end
end
return PVPGuildBattleUILayer
