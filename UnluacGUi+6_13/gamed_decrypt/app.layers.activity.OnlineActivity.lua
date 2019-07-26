local CommonActivity = require("app.layers.activity.CommonActivity")
local ItemInfoManager = require("app.info.ItemInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local TouchIcon = require("app.widgets.TouchIcon")
local OnlineActivity = class("OnlineActivity", CommonActivity)
local GetTimeStr = function(time)
  local m, s = math.floor(time / 60), time % 60
  return string.format("%02d:%02d\229\144\142\229\143\175\233\162\134\229\143\150", m, s)
end
function OnlineActivity:ctor(data)
  self.super.ctor(self, data)
  self.m_time = 0
  self.m_curItem = nil
  self.m_lastTime = self.m_udMng:GetOnlineAwardTime()
  self:InitUI()
end
function OnlineActivity:onEnter()
  self.super.onEnter(self)
  self:AddTouch()
  local eventDsp = self:getEventDispatcher()
  self.customListener = cc.EventListenerCustom:create(td.GET_ACTIVITY_AWARD, function()
    self.m_udMng:UpdateOnlineAwardTime()
    self.m_lastTime = self.m_udMng:GetOnlineAwardTime()
    self:CheckTime()
  end)
  eventDsp:addEventListenerWithFixedPriority(self.customListener, 1)
end
function OnlineActivity:onExit()
  self.super.onExit(self)
  if self.customListener then
    local eventDsp = self:getEventDispatcher()
    eventDsp:removeEventListener(self.customListener)
    self.customListener = nil
  end
end
function OnlineActivity:InitUI()
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
function OnlineActivity:RefreshList()
  self.m_UIListView:removeAllItems()
  for i, var in ipairs(self.m_data.items) do
    local item = self:CreateItem(var)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
  self:CheckTime()
end
function OnlineActivity:CheckTime()
  for i, info in ipairs(self.m_data.items) do
    if info.result ~= 1 then
      self.m_curItem = self.m_UIListView:getItemByPos(i)
      if i > 3 then
        self.m_UIListView:scrollTo(self.m_curItem:getPositionX(), -self.m_curItem:getPositionY())
      end
      local serverTime = self.m_udMng:GetServerTime()
      if serverTime >= self.m_lastTime + info.condition.value then
        self.m_curItem.condLabel:setString("")
        self.m_curItem.btn:setDisable(false)
        break
      end
      do
        local pEffect = SkeletonUnit:create("Spine/UI_effect/EFT_haoyouzhiyuan_01")
        pEffect:PlayAni("animation", false)
        td.AddRelaPos(self.m_curItem:getContent():getChildByName("bg"), pEffect)
        self.m_time = self.m_lastTime + info.condition.value - serverTime
      end
      break
    end
  end
end
function OnlineActivity:OnTimer()
  self.super.OnTimer(self)
  if self.m_time >= 0 and self.m_curItem then
    self.m_time = self.m_time - 1
    if self.m_time < 0 then
      self.m_curItem.condLabel:setString("")
      self.m_curItem.btn:setDisable(false)
    else
      self.m_curItem.condLabel:setString(GetTimeStr(self.m_time))
    end
  end
end
function OnlineActivity:CreateItem(info)
  local itemNode = display.newNode()
  local item = self.m_UIListView:newItem(itemNode)
  local autoScale = td.GetAutoScale()
  local bgSize = cc.size(580, 85)
  local itembg = display.newScale9Sprite("UI/scale9/jianglidikuang.png", 0, 0, bgSize, cc.rect(11, 26, 5, 25))
  itembg:setAnchorPoint(cc.p(0, 0))
  itembg:setName("bg")
  itemNode:setScale(autoScale)
  itemNode:setContentSize(bgSize)
  itembg:addTo(itemNode)
  local itemInfo = td.GetItemInfo(info.award[1].itemId)
  local iconBg = display.newScale9Sprite("UI/scale9/bantouming4.png", 0, 0, cc.size(75, 75))
  td.AddRelaPos(itembg, iconBg, 1, cc.p(0.1, 0.5))
  local iconSpr = TouchIcon.new(info.award[1].itemId, true, false)
  iconSpr:scale(0.55)
  td.AddRelaPos(iconBg, iconSpr)
  local nameLabel = td.CreateLabel(itemInfo.name .. "x" .. info.award[1].num, td.WHITE, 18)
  nameLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itembg, nameLabel, 1, cc.p(0.2, 0.7))
  local condLabel = td.CreateLabel(GetTimeStr(info.condition.value), td.GREEN, 18)
  condLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itembg, condLabel, 1, cc.p(0.2, 0.3))
  item.condLabel = condLabel
  if info.result == 1 then
    local spr = display.newSprite("UI/words/yilingqu_icon.png")
    td.AddRelaPos(itembg, spr, 1, cc.p(0.85, 0.5))
    condLabel:setString("")
  else
    do
      local btn = td.CreateBtn(td.BtnType.GreenShort)
      td.BtnAddTouch(btn, function()
        td.AfterReceive(btn)
        self.m_adMng:GetActivityAwardRequest(self.m_data.id, info.id)
      end, nil, td.ButtonEffectType.Short)
      td.AddRelaPos(itembg, btn, 1, cc.p(0.85, 0.5))
      btn:setDisable(true)
      item.btn = btn
      td.BtnSetTitle(btn, g_LM:getBy("a00052"))
    end
  end
  item:setItemSize((bgSize.width + 5) * autoScale, (bgSize.height + 3) * autoScale)
  return item
end
function OnlineActivity:AddTouch()
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
return OnlineActivity
