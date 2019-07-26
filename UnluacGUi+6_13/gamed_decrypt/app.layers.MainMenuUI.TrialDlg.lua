local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local GuideManager = require("app.GuideManager")
local MissionInfoManager = require("app.info.MissionInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local InformationManager = require("app.layers.InformationManager")
local UserDataManager = require("app.UserDataManager")
local RuleInfoDlg = require("app.layers.RuleInfoDlg")
local TabButton = require("app.widgets.TabButton")
local CommonInfoManager = require("app.info.CommonInfoManager")
local TrialDlg = class("TrialDlg", BaseDlg)
local ItemSize = cc.size(150, 380)
local POS_Y = {
  0.45,
  0.6,
  0.7,
  0.55,
  0.4,
  0.6,
  0.45,
  0.55,
  0.7,
  0.55
}
local STAMINA_COST = {
  10,
  15,
  20
}
function TrialDlg:ctor()
  TrialDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Trial
  self.m_udMng = UserDataManager:GetInstance()
  self.m_myCampLevel = self.m_udMng:GetBaseCampLevel()
  self.m_trialData = {}
  self.m_curLevel = 0
  self.m_bIsMax = false
  self.m_items = {}
  self.m_lines = {}
  self.m_mode = 0
  self.m_tabs = {}
  self:InitUI()
end
function TrialDlg:onEnter()
  TrialDlg.super.onEnter(self)
  self:AddEvents()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetTrial, handler(self, self.GetTrialCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetTrialReward, handler(self, self.GetRewardCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.MallBuy, handler(self, self.BuyCallback))
  self:SendGetTrialRequest()
end
function TrialDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetTrial)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetTrialReward)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.MallBuy)
  TrialDlg.super.onExit(self)
end
function TrialDlg:InitUI()
  self:LoadUI("CCS/TrialDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_shilianchang.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_startBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_start")
  td.BtnAddTouch(self.m_startBtn, handler(self, self.StartGame))
  self.m_ruleBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_rule")
  td.BtnAddTouch(self.m_ruleBtn, handler(self, self.ViewRule))
  self.m_textTime = cc.uiloader:seekNodeByName(self.m_bg, "Text_times")
  local btnAdd = cc.uiloader:seekNodeByName(self.m_bg, "Button_add_chance")
  td.BtnAddTouch(btnAdd, handler(self, self.OnAddBtnClicked))
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_times_left")
  label:setString(g_LM:getBy("a00188"))
end
function TrialDlg:StartGame()
  if self.m_bIsMax then
    td.alert(g_LM:getBy("a00301"), true)
  elseif not self:CheckCanStart() then
    td.alertErrorMsg(td.ErrorCode.MISSION_TIME_NOT_ENOUGH)
  else
    local trialLevelInfo = MissionInfoManager:GetInstance():GetTrialLevelInfo(self.m_mode, self.m_curLevel + 1)
    self:SendStartTrialRequest(trialLevelInfo.id)
    UserDataManager:GetInstance():UpdateDungeonTime(td.UIModule.Trial, -1)
    GameDataManager:GetInstance():SetTrialData(self.m_mode, self.m_curLevel + 1)
    local loadingScene = require("app.scenes.LoadingScene").new(7010, 7010)
    cc.Director:getInstance():replaceScene(loadingScene)
  end
end
function TrialDlg:CheckCanStart()
  if self.m_udMng:GetDungeonTime(self.m_uiId) <= 0 then
    return false
  end
  return true
end
function TrialDlg:CreateTabs(mode)
  self.m_tabs = {}
  local tabs = {}
  for i = 1, 3 do
    local _tab = cc.uiloader:seekNodeByName(self.m_bg, "Tab" .. i)
    table.insert(self.m_tabs, _tab)
    if i == 2 and self.m_myCampLevel < 20 or i == 3 and self.m_myCampLevel < 30 then
      local grayIcon = display.newGraySprite("UI/button/nandu" .. i .. "_icon2.png")
      local parent = _tab:getParent()
      local x, y = _tab:getPosition()
      grayIcon:pos(x, y):addTo(parent)
    elseif i == 2 and self.m_myCampLevel >= 20 or i == 3 and self.m_myCampLevel >= 30 then
      _tab:setOpacity(255)
    end
    local tab = {
      tab = _tab,
      callfunc = handler(self, self.UpdatePanels),
      normalImageFile = "UI/button/nandu" .. i .. "_icon2.png",
      highImageFile = "UI/button/nandu" .. i .. "_icon1.png"
    }
    table.insert(tabs, tab)
  end
  local tabButtons = TabButton.new(tabs, {autoSelectIndex = mode})
end
function TrialDlg:UpdatePanels(index)
  if self.m_mode == index then
    return
  end
  if index == 2 and self.m_myCampLevel < 20 then
    td.alert(g_LM:getBy("a00341"))
    return false
  elseif index == 3 and self.m_myCampLevel < 30 then
    td.alert(g_LM:getBy("a00342"))
    return false
  end
  self.m_mode = index
  self.m_curLevel, self.m_bIsMax = self:GetCurLevel(index)
  self:RefreshList(index)
  g_MC:SetRecentTrialDiff(self.m_mode)
  self:RefreshUI()
  return true
end
function TrialDlg:RefreshUI()
  local remainTimes = self.m_udMng:GetDungeonTime(self.m_uiId)
  self.m_textTime:setString(remainTimes)
  if remainTimes <= 0 then
    self.m_textTime:setColor(td.RED)
  else
    self.m_textTime:setColor(td.WHITE)
  end
end
function TrialDlg:CreateList()
  local listSize = cc.size(1000, 380)
  self.m_listContainer = display.newNode()
  self.m_listContainer:setContentSize(ItemSize.width * table.nums(self.m_trialData), ItemSize.height)
  self.m_listContainer:setPosition(listSize.width / 2, listSize.height / 2)
  self.m_list = cc.ui.UIScrollView.new({
    direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
    viewRect = cc.rect(0, 0, listSize.width, listSize.height),
    scale = self.m_scale
  }):addScrollNode(self.m_listContainer)
  self.m_list:pos(0, 0):addTo(self.m_bg)
  self.m_list:scrollTo(0, 0)
end
function TrialDlg:RefreshList(mode)
  self:RemoveItems()
  local trialLevels = MissionInfoManager:GetInstance():GetTrialLevelInfo(mode)
  for i, var in ipairs(trialLevels) do
    local item = self:CreateItem(i, var)
    item:pos((i - 1) * item:getContentSize().width, 0):addTo(self.m_listContainer)
    table.insert(self.m_items, item)
  end
  local item = self.m_items[self.m_curLevel] or self.m_items[1]
  local curPos = cc.p(item:getPosition()) or cc.p(0, 0)
  self.m_list:scrollTo(-curPos.x, 0)
  self:DrawLines()
end
function TrialDlg:CreateItem(levelNum, info)
  local itemNode = display.newNode()
  itemNode:setContentSize(ItemSize.width * self.m_scale, ItemSize.height * self.m_scale)
  local pedestal = SkeletonUnit:create("Spine/UI_effect/UI_jingjichangxuanzhong_01")
  pedestal:setName("pedestal")
  pedestal:setScale(0.35 * self.m_scale)
  local y = math.random(3, 7) / 10
  td.AddRelaPos(itemNode, pedestal, 0, cc.p(0.5, POS_Y[levelNum]))
  if levelNum == self.m_curLevel + 1 then
    pedestal:PlayAni("animation_02", true)
  else
    pedestal:PlayAni("animation_01", true)
  end
  local str = string.format("\231\172\172%d\229\133\179", levelNum)
  local label = td.CreateLabel(str, td.WHITE, 22, td.OL_BLACK)
  label:pos(pedestal:getPositionX(), pedestal:getPositionY() - 45):scale(self.m_scale):addTo(itemNode)
  local function Hover(rewardSpr)
    local min, max = 0, 20
    local speed = 25
    local initPos = math.random(min, max)
    rewardSpr:setName("reward")
    rewardSpr:setScale(0.7)
    rewardSpr:pos(pedestal:getPositionX(), pedestal:getPositionY() + initPos):addTo(itemNode)
    rewardSpr:runAction(cca.loop(cca.seq({
      cca.moveBy((max - initPos) / speed, 0, max - initPos),
      cca.moveBy((max - min) / speed, 0, min - max),
      cca.moveBy((initPos - min) / speed, 0, initPos - min)
    })))
  end
  local trialData = self.m_trialData[info.id]
  local rewardSpr
  if trialData then
    if trialData.type == 0 then
      rewardSpr = display.newSprite(td.GetItemIcon(tonumber(trialData.item_id)))
      rewardSpr:pos(pedestal:getPositionX(), pedestal:getPositionY() + 10):addTo(itemNode)
    else
      rewardSpr = display.newSprite("UI/icon/item/00000.png")
      do
        local spine1 = SkeletonUnit:create("Spine/UI_effect/EFT_dedaojineng_02")
        td.AddRelaPos(rewardSpr, spine1)
        spine1:setLocalZOrder(-1)
        spine1:PlayAni("animation", true)
        local rewardSize = rewardSpr:getContentSize()
        local btn = ccui.Button:create("UI/scale9/transparent1x1.png")
        btn:setScale(rewardSize.width / btn:getContentSize().width, rewardSize.height / btn:getContentSize().height)
        td.AddRelaPos(rewardSpr, btn)
        td.BtnAddTouch(btn, function()
          self:GetReward(levelNum)
          self.m_rewardSpine = spine1
        end)
        Hover(rewardSpr)
      end
    end
  else
    rewardSpr = display.newGraySprite("UI/icon/item/00000.png")
    Hover(rewardSpr)
  end
  rewardSpr:setScale(self.m_scale)
  rewardSpr:setAnchorPoint(0.5, 0)
  rewardSpr:setName("reward")
  return itemNode
end
function TrialDlg:RemoveItems()
  for key, val in ipairs(self.m_items) do
    val:removeFromParent()
  end
  self.m_items = {}
  for key, val in ipairs(self.m_lines) do
    val:removeFromParent()
  end
  self.m_lines = {}
end
function TrialDlg:DrawLines()
  local length = #self.m_items
  for i = 1, length - 1 do
    local line = display.newSprite("UI/trial/lanse_xuxian.png")
    line:setScale(self.m_scale)
    local item = cc.uiloader:seekNodeByName(self.m_items[i], "pedestal")
    local nextItem = cc.uiloader:seekNodeByName(self.m_items[i + 1], "pedestal")
    local itemWorldPos = item:getParent():convertToWorldSpace(cc.p(item:getPosition()))
    local itemPos = self.m_listContainer:convertToNodeSpace(itemWorldPos)
    local nextItemWorldPos = nextItem:getParent():convertToWorldSpace(cc.p(nextItem:getPosition()))
    local nextItemPos = self.m_listContainer:convertToNodeSpace(nextItemWorldPos)
    local x = nextItemPos.x - itemPos.x
    local y = nextItemPos.y - itemPos.y
    local rot = math.round(math.radian2angle(-math.atan(y / x)))
    local linePos = cc.p(x / 2 + itemPos.x, y / 2 + itemPos.y)
    line:setRotation(rot)
    line:pos(linePos.x, linePos.y):addTo(self.m_listContainer)
    table.insert(self.m_lines, line)
  end
end
function TrialDlg:Progress(line)
  line:runAction(cca.seq({
    cca.progressTo(0.8, 100),
    cca.cb(function()
      line:setPercentage(0)
      self:Progress(line)
    end)
  }))
end
function TrialDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_list then
      if self.m_list:isTouchInViewRect({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.m_list:onTouch_({
          name = "began",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
        return true
      end
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    self.m_list:onTouch_({
      name = "moved",
      x = touch:getLocation().x,
      y = touch:getLocation().y,
      prevX = touch:getPreviousLocation().x,
      prevY = touch:getPreviousLocation().y
    })
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
function TrialDlg:OnAddBtnClicked()
  td.ShowBuyTimeDlg(self.m_uiId, handler(self, self.SendBuyRequest))
end
function TrialDlg:GetCurLevel(mode)
  local trialLevels = MissionInfoManager:GetInstance():GetTrialLevelInfo(mode)
  for i, var in ipairs(trialLevels) do
    if not self.m_trialData[var.id] then
      return i - 1, false
    end
  end
  return #trialLevels, true
end
function TrialDlg:GetReward(index)
  local trialLevels = MissionInfoManager:GetInstance():GetTrialLevelInfo(self.m_mode)
  local trialLevelData = self.m_trialData[trialLevels[index].id]
  if trialLevelData and trialLevelData.type == 1 then
    self:SendGetRewardRequest(trialLevelData, index)
  end
end
function TrialDlg:ViewRule()
  local str = g_LM:getBy("a00284")
  local data = {
    title = "\232\167\132\229\136\153\232\175\180\230\152\142",
    text = str
  }
  local ruleDlg = RuleInfoDlg.new(data)
  td.popView(ruleDlg)
end
function TrialDlg:SendGetTrialRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetTrial
  TDHttpRequest:getInstance():Send(Msg)
end
function TrialDlg:GetTrialCallback(data)
  local mode = 1
  for i, var in ipairs(data.placticeProto) do
    self.m_trialData[var.id] = {
      id = var.id,
      type = var.type,
      item_id = tonumber(var.item_id)
    }
    mode = math.floor(var.id / 100)
  end
  mode = g_MC:GetRecentTrialDiff() or mode
  if #self.m_tabs <= 0 then
    self:CreateTabs(mode)
    self:CreateList()
  end
  self:UpdatePanels(mode)
end
function TrialDlg:SendGetRewardRequest(trialLevelData, _index)
  local Msg = {}
  Msg.msgType = td.RequestID.GetTrialReward
  Msg.sendData = {
    id = trialLevelData.id
  }
  Msg.cbData = {
    itemId = trialLevelData.item_id,
    index = _index
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function TrialDlg:GetRewardCallback(data, cbData)
  if data.state ~= td.ResponseState.Success then
    return
  end
  InformationManager:GetInstance():ShowInfoDlg({
    type = td.ShowInfo.Item,
    items = {
      [cbData.itemId] = 1
    }
  })
  self:SendGetTrialRequest()
  self.m_rewardSpine:removeFromParent()
  self.m_rewardSpine = nil
  local rewardSpr = self.m_items[cbData.index]:getChildByName("reward")
  rewardSpr:stopAllActions()
  td.setTexture(rewardSpr, td.GetItemIcon(cbData.itemId))
end
function TrialDlg:SendStartTrialRequest(trialId)
  local Msg = {}
  Msg.msgType = td.RequestID.TrialBefore
  Msg.sendData = {id = trialId}
  TDHttpRequest:getInstance():SendPrivate(Msg)
end
function TrialDlg:SendBuyRequest()
  if self.m_bIsRequsting then
    return
  end
  self.m_bIsRequsting = true
  local Msg = {}
  Msg.msgType = td.RequestID.MallBuy
  Msg.sendData = {
    id = td.BuyTrialId,
    num = 1
  }
  Msg.cbData = {
    id = td.BuyTrialId
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function TrialDlg:BuyCallback(data, cbData)
  if data.state == td.ResponseState.Success and cbData.id == td.BuyTrialId then
    self.m_udMng:UpdateDungeonTime(self.m_uiId, 1)
    self.m_udMng:UpdateDungeonBuyTime(self.m_uiId, -1)
    self:RefreshUI()
  end
  self.m_bIsRequsting = false
end
return TrialDlg
