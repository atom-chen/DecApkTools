local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local GuildDataManager = require("app.GuildDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local ActorInfoManager = require("app.info.ActorInfoManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local MissionInfoManager = require("app.info.MissionInfoManager")
local GuildInfoManager = require("app.info.GuildInfoManager")
local scheduler = require("framework.scheduler")
local GuildBossDlg = class("GuildBossDlg", BaseDlg)
local ITEM_SIZE = cc.size(285, 40)
function GuildBossDlg:ctor()
  GuildBossDlg.super.ctor(self, 200)
  self.m_gdMng = GuildDataManager:GetInstance()
  self.m_missionId = nil
  self.m_bInit = false
  self.m_times = 0
  self.m_curHp = 0
  self.m_myRank = nil
  self:InitUI()
end
function GuildBossDlg:onEnter()
  GuildBossDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetGuildBoss, handler(self, self.GetBossDateResponse))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GuildBossBefore, handler(self, self.BossBeforeResponse))
  self:AddEvents()
  self:GetBossDateReq()
end
function GuildBossDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetGuildBoss)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GuildBossBefore)
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
    self.m_timeScheduler = nil
  end
  GuildBossDlg.super.onExit(self)
end
function GuildBossDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/guild/GuildBossDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self:SetTitle(td.Word_Path .. "wenzi_benzhouboss.png")
  self.m_nameLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_name")
  self.m_timeLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_time")
  self.m_hpBar = cc.uiloader:seekNodeByName(self.m_bg, "LoadingBar_1")
  self.m_hpLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_hp")
  local btnSkill = cc.uiloader:seekNodeByName(self.m_bg, "Button_skill")
  td.BtnSetTitle(btnSkill, g_LM:getBy("a00118"))
  td.BtnAddTouch(btnSkill, handler(self, self.ShowSkill))
  local btnAward = cc.uiloader:seekNodeByName(self.m_bg, "Button_award")
  td.BtnSetTitle(btnAward, g_LM:getBy("a00424"))
  td.BtnAddTouch(btnAward, handler(self, self.ShowAward))
  self.m_btnStart = cc.uiloader:seekNodeByName(self.m_bg, "Button_start")
  td.BtnSetTitle(self.m_btnStart, g_LM:getBy("a00102"))
  td.BtnAddTouch(self.m_btnStart, handler(self, self.Start))
  self:CreateList()
end
function GuildBossDlg:UpdateUI(data)
  local bossInfo = GuildInfoManager:GetInstance():GetBossInfo(data.id)
  if not self.m_bInit then
    self.m_bInit = true
    self.m_missionId = bossInfo.mission_id
    self.m_bossId = bossInfo.monster_id
    self.m_maxHp = bossInfo.hp
    local monsterInfo = ActorInfoManager:GetInstance():GetMonsterInfo(self.m_bossId)
    self.m_nameLabel:setString(monsterInfo.name)
    local skeleton = SkeletonUnit:create(monsterInfo.image)
    skeleton:PlayAni("stand")
    td.AddRelaPos(self.m_bg, skeleton, 1, cc.p(0.28, 0.45))
  end
  self.m_times = data.num
  self.m_curHp = data.hp
  self.m_timeLabel:setString(self.m_times)
  self.m_hpLabel:setString(string.format("%d/%d", data.hp, self.m_maxHp))
  self.m_hpBar:setPercent(data.hp / self.m_maxHp * 100)
  table.sort(data.memberProto, function(a, b)
    return a.harm > b.harm
  end)
  local selfId = UserDataManager:GetInstance():GetUId()
  for i, var in ipairs(data.memberProto) do
    if selfId == var.uid then
      self.m_myRank = i
      break
    end
  end
  self:RefreshList(data.memberProto)
end
function GuildBossDlg:CreateList()
  local listView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 285, 245),
    touchOnContent = false,
    scale = self.m_scale
  })
  listView:setAnchorPoint(cc.p(0, 0))
  listView:pos(435, 145):addTo(self.m_bg)
  self.m_UIListView = listView
end
function GuildBossDlg:RefreshList(memberProto)
  self.m_UIListView:removeAllItems()
  for i, var in ipairs(memberProto) do
    local userData = self.m_gdMng:GetMemberData(var.uid)
    if userData then
      local data = {
        name = userData.u_name,
        harm = var.harm,
        range = i
      }
      local listItem = self:CreateItem(data)
      self.m_UIListView:addItem(listItem)
    end
  end
  self.m_UIListView:reload()
end
function GuildBossDlg:CreateItem(data)
  local itemNode = display.newNode()
  itemNode:setContentSize(ITEM_SIZE)
  itemNode:scale(self.m_scale)
  local labelRange = td.CreateLabel(data.range, td.LIGHT_BLUE)
  td.AddRelaPos(itemNode, labelRange, 1, cc.p(0.1, 0.5))
  local labelName = td.CreateLabel(data.name, td.WHITE, 18)
  td.AddRelaPos(itemNode, labelName, 1, cc.p(0.4, 0.5))
  local harmStr = tostring(data.harm)
  if data.harm > 10000 then
    harmStr = string.format("%.2fW", data.harm / 10000)
  end
  local labelHarm = td.CreateLabel(harmStr, td.WHITE, 18)
  td.AddRelaPos(itemNode, labelHarm, 1, cc.p(0.85, 0.5))
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize(ITEM_SIZE.width * self.m_scale, (ITEM_SIZE.height + 5) * self.m_scale)
  return item
end
function GuildBossDlg:ShowSkill()
  local dlg = require("app.layers.guild.GuildBossSkillDlg").new(self.m_bossId)
  td.popView(dlg)
end
function GuildBossDlg:ShowAward()
  local dlg = require("app.layers.guild.GuildBossAwardDlg").new(self.m_myRank)
  td.popView(dlg)
end
function GuildBossDlg:Start()
  if self.m_times < 1 then
    td.alertErrorMsg(td.ErrorCode.TIME_NOT_ENOUGH)
  elseif self.m_curHp <= 0 then
    td.alert(g_LM:getBy("a00331"), true)
  else
    self:BossBeforeReq()
  end
end
function GuildBossDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_UIListView:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    else
      local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
      if not isTouchInNode(self.m_bg, tmpPos) then
        self:performWithDelay(function()
          self:close()
        end, 0.1)
      end
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_UIListView:onTouch_({
        name = "moved",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    self.m_UIListView:onTouch_({
      name = "ended",
      x = touch:getLocation().x,
      y = touch:getLocation().y,
      prevX = touch:getPreviousLocation().x,
      prevY = touch:getPreviousLocation().y
    })
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function GuildBossDlg:OnTimer()
end
function GuildBossDlg:GetBossDateReq()
  local Msg = {}
  Msg.msgType = td.RequestID.GetGuildBoss
  Msg.sendData = {
    guild_id = self.m_gdMng:GetGuildData().id
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildBossDlg:GetBossDateResponse(data)
  self:UpdateUI(data)
end
function GuildBossDlg:BossBeforeReq()
  local Msg = {}
  Msg.msgType = td.RequestID.GuildBossBefore
  Msg.sendData = {
    guild_id = self.m_gdMng:GetGuildData().id
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildBossDlg:BossBeforeResponse(data)
  if data.state == td.ResponseState.Success then
    require("app.GameDataManager"):GetInstance():SetGuildBossData(self.m_bossId, self.m_curHp)
    g_MC:OpenModule(td.UIModule.MissionReady, self.m_missionId)
  end
end
return GuildBossDlg
