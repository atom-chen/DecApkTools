local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local ActivityInfoManager = require("app.info.ActivityInfoManager")
local InformationManager = require("app.layers.InformationManager")
local TouchIcon = require("app.widgets.TouchIcon")
local MonthSignInActivity = class("MonthSignInActivity", function()
  return cc.uiloader:load("CCS/activities/MonthSignIn.csb")
end)
local Item_Size = cc.size(580, 105)
function MonthSignInActivity:ctor()
  self.m_vData = {}
  self.m_udMng = UserDataManager:GetInstance()
  self.m_canResignTime = self.m_udMng:GetResignTime()
  self.m_signedInTime = self.m_udMng:GetSignInDay(true)
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function MonthSignInActivity:onEnter()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetMonthSignList, handler(self, self.GetSignInCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.MonthSignIn, handler(self, self.SignInCallback))
  self:SendGetSignReq()
  self:AddTouch()
end
function MonthSignInActivity:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetMonthSignList)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.MonthSignIn)
end
function MonthSignInActivity:InitUI()
  self:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self)
  self.m_bg = cc.uiloader:seekNodeByName(self, "Image_bg")
  self.m_signLabel = cc.uiloader:seekNodeByName(self, "Text_sign")
  self.m_resignLabel = cc.uiloader:seekNodeByName(self, "Text_resign")
  self.m_resignBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_resign_3")
  td.BtnAddTouch(self.m_resignBtn, function()
    local bResult, errorCode = self:CheckCanSignIn(true)
    if bResult then
      UserDataManager:GetInstance():UpdateResignTime()
      self:SendSignRequest()
    else
      td.alertErrorMsg(errorCode)
    end
  end)
  local label = td.CreateLabel(g_LM:getBy("a00402"), td.WHITE, 16)
  td.AddRelaPos(self.m_resignBtn, label, 1, cc.p(0.5, 0.7))
  local costLabel = td.RichText({
    {
      type = 1,
      str = "50 ",
      color = td.WHITE,
      size = 16
    },
    {
      type = 2,
      file = td.DIAMOND_ICON,
      scale = 0.4
    }
  })
  td.AddRelaPos(self.m_resignBtn, costLabel, 1, cc.p(0.5, 0.3))
  self.m_btn = cc.uiloader:seekNodeByName(self.m_bg, "Button_sign_5")
  td.BtnAddTouch(self.m_btn, function()
    local bResult, errorCode = self:CheckCanSignIn()
    if bResult then
      self:SendSignRequest()
    else
      td.alertErrorMsg(errorCode)
    end
  end)
  td.BtnSetTitle(self.m_btn, g_LM:getBy("a00422"))
  self:CreateList()
end
function MonthSignInActivity:RefreshUI()
  self.m_resignLabel:setString("" .. self.m_canResignTime)
  self.m_signLabel:setString("" .. self.m_signedInTime)
  if self:CheckCanSignIn() then
    td.EnableButton(self.m_resignBtn, false)
  else
    td.EnableButton(self.m_btn, false)
    td.BtnSetTitle(self.m_btn, g_LM:getBy("a00423"))
    td.EnableButton(self.m_resignBtn, self:CheckCanSignIn(true))
  end
  self:RefreshList()
end
function MonthSignInActivity:CheckCanSignIn(bResign)
  local userDetail = self.m_udMng:GetUserDetail()
  local serverTime = self.m_udMng:GetServerTime()
  if bResign then
    if self:CheckCanSignIn() then
      return false, td.ErrorCode.NOT_SIGNIN
    end
    local day = tonumber(os.date("%d", serverTime))
    if day <= self.m_signedInTime then
      return false, td.ErrorCode.RECEIVED_ALREADY
    end
    if self.m_canResignTime <= 0 then
      return false, td.ErrorCode.TIME_NOT_ENOUGH
    end
  else
    local lastSignTime = self.m_udMng:GetSignInTime(true)
    if self.m_signedInTime ~= 0 and not td.TimeCompare(serverTime, lastSignTime) then
      return false, td.ErrorCode.RECEIVED_ALREADY
    end
  end
  return true, td.ErrorCode.SUCCESS
end
function MonthSignInActivity:CreateList()
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 70, 580, 290),
    touchOnContent = false,
    scale = td.GetAutoScale()
  })
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:setPosition(5, 5)
  self.m_bg:addChild(self.m_UIListView, 1)
end
function MonthSignInActivity:RefreshList()
  self.m_UIListView:removeAllItems()
  local rowCount = math.ceil(#self.m_vData / 5)
  for i = 1, rowCount do
    local item = self:CreateItem(i)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function MonthSignInActivity:CreateItem(pos)
  local content = display.newNode()
  content:setScale(td.GetAutoScale())
  content:setContentSize(Item_Size)
  for i = 1, 5 do
    local index = (pos - 1) * 5 + i
    local data = self.m_vData[index]
    if not data then
      break
    end
    local itemBg
    if index <= self.m_signedInTime then
      itemBg = display.newScale9Sprite("UI/scale9/dikuang8.png", 0, 0, cc.size(100, 105))
      local signSpr = display.newSprite("UI/common/gouxuan.png")
      td.AddRelaPos(itemBg, signSpr, 10, cc.p(0.8, 0.8))
    else
      itemBg = display.newScale9Sprite("UI/scale9/dikuang7.png", 0, 0, cc.size(100, 105))
    end
    itemBg:align(display.LEFT_BOTTOM, 10 + (i - 1) * 115, 0):addTo(content)
    local iconSpr = TouchIcon.new(data.itemId, true, false)
    iconSpr:setScale(0.6)
    td.AddRelaPos(itemBg, iconSpr, 1, cc.p(0.5, 0.6))
    local numLabel = td.CreateLabel("x" .. data.num)
    td.AddRelaPos(itemBg, numLabel, 1, cc.p(0.5, 0.2))
  end
  local autoScale = td.GetAutoScale()
  local item = self.m_UIListView:newItem(content)
  item:setItemSize(Item_Size.width * autoScale, (Item_Size.height + 5) * autoScale)
  return item
end
function MonthSignInActivity:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if not self:isVisible() then
      return false
    end
    local bResult = false
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
      bResult = true
      self.m_bIsTouchInList = true
    end
    return bResult
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
    if self.m_bIsTouchInList then
      self.m_UIListView:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function MonthSignInActivity:SendGetSignReq()
  local Msg = {}
  Msg.msgType = td.RequestID.GetMonthSignList
  TDHttpRequest:getInstance():Send(Msg)
end
function MonthSignInActivity:GetSignInCallback(data)
  self.m_vData = {}
  for i, var in ipairs(data.item) do
    local tmp = string.split(var, "#")
    table.insert(self.m_vData, {
      itemId = tonumber(tmp[1]),
      num = tonumber(tmp[2])
    })
  end
  self:RefreshUI()
end
function MonthSignInActivity:SendSignRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.MonthSignIn
  Msg.sendData = nil
  TDHttpRequest:getInstance():Send(Msg)
end
function MonthSignInActivity:SignInCallback(data)
  if data.state == td.ResponseState.Success then
    UserDataManager:GetInstance():UpdateSignInDay(true)
    UserDataManager:GetInstance():UpdateSignInTime(true)
    self.m_signedInTime = self.m_udMng:GetSignInDay(true)
    self.m_canResignTime = self.m_udMng:GetResignTime()
    self:RefreshUI()
    local signInData = self.m_vData[self.m_signedInTime]
    InformationManager:GetInstance():ShowInfoDlg({
      type = td.ShowInfo.Item,
      items = {
        [signInData.itemId] = signInData.num
      }
    })
  else
    td.alert(g_LM:getBy("a00323"), true)
  end
end
return MonthSignInActivity
