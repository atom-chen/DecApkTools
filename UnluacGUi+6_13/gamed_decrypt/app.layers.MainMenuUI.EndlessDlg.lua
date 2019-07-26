local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local BattleScene = require("app.scenes.BattleScene")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local GuideManager = require("app.GuideManager")
local RuleInfoDlg = require("app.layers.RuleInfoDlg")
local scheduler = require("framework.scheduler")
local MissionInfoManager = require("app.info.MissionInfoManager")
local CommonInfoManager = require("app.info.CommonInfoManager")
local EndlessDlg = class("EndlessDlg", BaseDlg)
function EndlessDlg:ctor()
  EndlessDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Endless
  self.m_remainTime = 0
  self.m_listData = {}
  self.m_hasRewarded = false
  self.m_udMng = UserDataManager:GetInstance()
  self:InitUI()
end
function EndlessDlg:onEnter()
  EndlessDlg.super.onEnter(self)
  self:InitCountDown()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetEndless, handler(self, self.SetData))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.MallBuy, handler(self, self.BuyCallback))
  TDHttpRequest:getInstance():Send({
    msgType = td.RequestID.GetEndless
  })
end
function EndlessDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetEndless)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.MallBuy)
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
  end
  EndlessDlg.super.onExit(self)
end
function EndlessDlg:InitUI()
  self:LoadUI("CCS/EndlessDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_wujinmoshi.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_textBestRec = cc.uiloader:seekNodeByName(self.m_bg, "Text_best_record")
  self.m_textMyRank = cc.uiloader:seekNodeByName(self.m_bg, "Text_my_rank")
  self.m_buttonRule = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_rule")
  td.BtnAddTouch(self.m_buttonRule, handler(self, self.ViewRule))
  self.m_buttonStart = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_start")
  td.BtnAddTouch(self.m_buttonStart, handler(self, self.BattleStart))
  self.m_textTime = cc.uiloader:seekNodeByName(self.m_bg, "Text_times")
  local btnAdd = cc.uiloader:seekNodeByName(self.m_bg, "Button_add_chance")
  td.BtnAddTouch(btnAdd, handler(self, self.OnAddBtnClicked))
  self.m_reward = cc.uiloader:seekNodeByName(self.m_bg, "Image_award")
  self.m_nonReward = cc.uiloader:seekNodeByName(self.m_bg, "Image_no_award")
  local labelReward = cc.uiloader:seekNodeByName(self.m_bg, "Text_award_data")
  labelReward:setString("100")
end
function EndlessDlg:RefreshUI()
  local remainTimes = self.m_udMng:GetDungeonTime(self.m_uiId)
  self.m_textTime:setString(remainTimes)
  if remainTimes <= 0 then
    self.m_textTime:setColor(td.RED)
  else
    self.m_textTime:setColor(td.WHITE)
  end
end
function EndlessDlg:CreateLists()
  self.m_list = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 440, 290),
    touchOnContent = true,
    scale = td.GetAutoScale()
  })
  self.m_list:setAnchorPoint(0, 1)
  self.m_list:pos(0, -295):addTo(self.m_reward)
  self:AddEvents()
end
function EndlessDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_list:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      return self.m_list:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_list:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_list:onTouch_({
        name = "moved",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    self.m_list:onTouch_({
      name = "ended",
      x = touch:getLocation().x,
      y = touch:getLocation().y,
      prevX = touch:getPreviousLocation().x,
      prevY = touch:getPreviousLocation().y
    })
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
function EndlessDlg:RefreshLists()
  self.m_list:removeAllItems()
  local rewardListLength
  if #self.m_listData <= 5 then
    rewardListLength = #self.m_listData
  else
    rewardListLength = 5
  end
  local zeroWave = {}
  for i = 1, #self.m_listData do
    local item = self:CreateItem(self.m_listData[i], i)
    if self.m_listData[i].max_wave ~= 0 then
      self.m_list:addItem(item)
    else
      rewardListLength = rewardListLength - 1
      table.insert(zeroWave, item)
    end
  end
  if not self.m_hasRewarded then
    local itemBg = display.newSprite("UI/endless/lvse_changtiao.png")
    itemBg:setScale(self.m_scale)
    local size = itemBg:getContentSize()
    local arrow = display.newSprite("UI/endless/jiantou1_icon.png")
    arrow:pos(40, 20.5):addTo(itemBg)
    local textSpr = display.newSprite("UI/words/wenzi_weijiangliqu.png")
    textSpr:pos(110, 20.5):addTo(itemBg)
    local item = self.m_list:newItem(itemBg)
    item:setItemSize(size.width * self.m_scale, (size.height + 5) * self.m_scale)
    self.m_list:addItem(item, rewardListLength + 1)
    self.m_hasRewarded = true
  end
  for k, item in ipairs(zeroWave) do
    self.m_list:addItem(item)
  end
  self.m_list:reload()
end
function EndlessDlg:CreateItem(itemData, index)
  local itemNode = display.newNode()
  local itemBg = display.newScale9Sprite("UI/scale9/transparent1x1.png", 0, 0, cc.size(440, 50))
  local size = cc.size(440, 50)
  itemBg:setAnchorPoint(0, 0)
  itemBg:pos(0, 0):addTo(itemNode)
  local label1 = td.CreateLabel(index .. ". " .. itemData.nickname, td.LIGHT_BLUE)
  label1:setAnchorPoint(0, 0)
  td.AddRelaPos(itemBg, label1, 0, cc.p(0.1, 0.5))
  local label2 = td.CreateLabel(itemData.max_wave, td.LIGHT_BLUE)
  label2:setAnchorPoint(0, 0)
  td.AddRelaPos(itemBg, label2, 0, cc.p(0.8, 0.5))
  local item = self.m_list:newItem(itemNode)
  item:setAnchorPoint(cc.p(0.5, 0.5))
  item:setItemSize(size.width * self.m_scale, size.height * self.m_scale)
  item:setScale(self.m_scale)
  return item
end
function EndlessDlg:OnAddBtnClicked()
  td.ShowBuyTimeDlg(self.m_uiId, handler(self, self.SendBuyRequest))
end
function EndlessDlg:BattleStart()
  local bResult, errorCode = self:CheckCanStart()
  if bResult then
    g_MC:OpenModule(td.UIModule.MissionReady, td.ENDLESS_ID)
  else
    td.alertErrorMsg(errorCode)
  end
end
function EndlessDlg:CheckCanStart()
  local bResult, errorCode = true, td.ErrorCode.SUCCESS
  if self.m_udMng:GetDungeonTime(self.m_uiId) <= 0 then
    bResult, errorCode = false, td.ErrorCode.MISSION_TIME_NOT_ENOUGH
  end
  return bResult, errorCode
end
function EndlessDlg:ViewRule()
  local str = g_LM:getBy("a00156")
  local data = {
    title = g_LM:getBy("a00317"),
    text = str
  }
  print(str)
  local ruleInfo = RuleInfoDlg.new(data)
  td.popView(ruleInfo)
end
function EndlessDlg:InitCountDown()
  local serverTime = math.floor(UserDataManager:GetInstance():GetServerTime())
  local settleTime = td.GetFutureTimeStamp(serverTime, 1, 0)
  self.m_countDown = settleTime - serverTime
  local hour, min, sec = math.floor(self.m_countDown / 3600), math.floor(self.m_countDown % 3600 / 60), math.floor(self.m_countDown % 60)
  self.m_countDownLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_time_data")
  self.m_timeScheduler = scheduler.scheduleGlobal(function()
    self.m_countDown = cc.clampf(self.m_countDown - 1, 0, 86400)
    local hour, min, sec = math.floor(self.m_countDown / 3600), math.floor(self.m_countDown % 3600 / 60), math.floor(self.m_countDown % 60)
    self.m_countDownLabel:setString(string.format("%02d", hour) .. " : " .. string.format("%02d", min) .. " : " .. string.format("%02d", sec))
  end, 1)
end
function EndlessDlg:SetData(data)
  local bestRecBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_best_record")
  local myRankBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_my_rank")
  local textBestRec = td.CreateBMF(tostring(data.endlessProto.max_wave), td.UI_yellow_outline)
  td.AddRelaPos(bestRecBg, textBestRec, 0, cc.p(0.5, 0.75))
  local textMyRank = td.CreateBMF(tostring(data.endlessProto.myrank), td.UI_yellow_outline)
  td.AddRelaPos(myRankBg, textMyRank, 0, cc.p(0.5, 0.75))
  self.m_listData = clone(data.otherEndlessProto)
  table.sort(self.m_listData, function(a, b)
    return a.max_wave > b.max_wave
  end)
  if 0 >= #self.m_listData then
    self.m_nonReward:setVisible(true)
  else
    self:CreateLists()
    self:RefreshLists()
  end
  GameDataManager:GetInstance():SetEndlessGroupId(data.endlessProto.team)
  GameDataManager:GetInstance():SetEndlessMaxWave(data.endlessProto.max_wave)
  GameDataManager:GetInstance():SetEndlessMaxWaveTime(data.endlessProto.ctime)
  GameDataManager:GetInstance():SetEndlessReward(data.endlessProto.items)
  self:RefreshUI()
end
function EndlessDlg:SendBuyRequest()
  if self.m_bIsRequsting then
    return
  end
  self.m_bIsRequsting = true
  local Msg = {}
  Msg.msgType = td.RequestID.MallBuy
  Msg.sendData = {
    id = td.BuyEndlessId,
    num = 1
  }
  Msg.cbData = {
    id = td.BuyEndlessId
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function EndlessDlg:BuyCallback(data, cbData)
  if data.state == td.ResponseState.Success and cbData.id == td.BuyEndlessId then
    self.m_udMng:UpdateDungeonTime(self.m_uiId, 1)
    self.m_udMng:UpdateDungeonBuyTime(self.m_uiId, -1)
    self:RefreshUI()
  end
  self.m_bIsRequsting = false
end
return EndlessDlg
