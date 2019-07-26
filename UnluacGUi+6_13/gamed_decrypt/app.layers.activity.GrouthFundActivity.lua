local CommonActivity = require("app.layers.activity.CommonActivity")
local ItemInfoManager = require("app.info.ItemInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local GrouthFundActivity = class("GrouthFundActivity", CommonActivity)
local GrouthFundId = 9001
function GrouthFundActivity:ctor(data)
  self.super.ctor(self, data)
  self.m_receiveTime = self.m_udMng:GetVIPData().fund
  self:InitUI()
end
function GrouthFundActivity:onEnter()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.MallBuy, handler(self, self.BuyCallback))
  self:AddTouch()
end
function GrouthFundActivity:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.MallBuy)
end
function GrouthFundActivity:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/activities/GrowthFund.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_bg = cc.uiloader:seekNodeByName(self, "Image_bg")
  self.m_buyBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_buy")
  td.BtnAddTouch(self.m_buyBtn, handler(self, self.Buy))
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 580, 250),
    touchOnContent = false,
    scale = td.GetAutoScale()
  })
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:setPosition(5, 5)
  self.m_bg:addChild(self.m_UIListView, 1)
  self:RefreshUI()
end
function GrouthFundActivity:DidBuy()
  return self.m_receiveTime >= 0 or self.m_data.bBuy
end
function GrouthFundActivity:RefreshUI()
  if self:DidBuy() and self.m_buyBtn then
    local label = td.CreateLabel(g_LM:getBy("a00401"), td.WHITE, 18, td.OL_BLUE)
    label:setPosition(self.m_buyBtn:getPosition())
    label:addTo(self.m_bg)
    self.m_buyBtn:removeFromParent()
    self.m_buyBtn = nil
  end
  self:RefreshList()
end
function GrouthFundActivity:RefreshList()
  self.m_UIListView:removeAllItems()
  for i, var in ipairs(self.m_data.items) do
    local item = self:CreateItem(var)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function GrouthFundActivity:CheckCondition(info, startTime, endTime)
  return self:DidBuy() and self.m_adMng:CheckCondition(info.condition, startTime, endTime)
end
function GrouthFundActivity:Buy()
  self.m_buyBtn:setDisable(true)
  local Msg = {}
  Msg.msgType = td.RequestID.MallBuy
  Msg.sendData = {id = GrouthFundId, num = 1}
  TDHttpRequest:getInstance():Send(Msg)
end
function GrouthFundActivity:BuyCallback(data)
  if data.state == td.ResponseState.Success then
    self.m_data.bBuy = true
    self:RefreshUI()
  end
end
function GrouthFundActivity:AddTouch()
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
return GrouthFundActivity
