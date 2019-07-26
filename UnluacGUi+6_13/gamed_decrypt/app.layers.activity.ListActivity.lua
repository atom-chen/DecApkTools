local CommonActivity = require("app.layers.activity.CommonActivity")
local ItemInfoManager = require("app.info.ItemInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local ListActivity = class("ListActivity", CommonActivity)
function ListActivity:ctor(data)
  self.super.ctor(self, data)
  self.m_time = 0
  self.m_curItem = nil
  self:InitUI()
end
function ListActivity:onEnter()
  self.super.onEnter(self)
  self:AddTouch()
end
function ListActivity:onExit()
  self.super.onExit(self)
end
function ListActivity:InitUI()
  self.super.InitUI(self)
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 580, 265),
    touchOnContent = false,
    scale = td.GetAutoScale()
  })
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:setPosition(5, 5)
  self.m_bg:addChild(self.m_UIListView, 1)
  self:RefreshList()
end
function ListActivity:RefreshList()
  self.m_UIListView:removeAllItems()
  for i, var in ipairs(self.m_data.items) do
    local item = self:CreateItem(var)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function ListActivity:AddTouch()
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
return ListActivity
