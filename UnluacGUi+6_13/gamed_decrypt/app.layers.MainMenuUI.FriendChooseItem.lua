local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local UnitDataManager = require("app.UnitDataManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local MessageBoxDlg = require("app.layers.MessageBoxDlg")
local ItemsConfig = require("app.config.donationItem")
local FriendChooseItem = class("FriendChooseItem", BaseDlg)
function FriendChooseItem:ctor()
  FriendChooseItem.super.ctor(self)
  self.m_data = {}
  self.itemInfoMng = ItemInfoManager:GetInstance()
  local unitMng = UnitDataManager:GetInstance()
  for key, val in pairs(ItemsConfig) do
    if unitMng:IsRoleUnlock(key) then
      local item = self.itemInfoMng:GetItemInfo(val)
      table.insert(self.m_data, item)
    end
  end
  self:InitUI()
end
function FriendChooseItem:onEnter()
  FriendChooseItem.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.AskForAssist, handler(self, self.DonationRequestCallback))
  self:AddEvents()
end
function FriendChooseItem:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.AskForAssist)
  FriendChooseItem.super.onExit(self)
end
function FriendChooseItem:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    self.m_moveDis = 0
    if 0 < self.m_page:getPageCount() then
      if self.m_page:isTouchInViewRect_({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        return self.m_page:onTouch_({
          name = "began",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
      end
    end
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function()
        self:close()
      end, 0.1)
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    self.m_moveDis = self.m_moveDis + math.abs(touch:getPreviousLocation().x - touch:getLocation().x)
    if self.m_moveDis < 20 then
      return
    end
    if self.m_page:getPageCount() > 0 then
      if self.m_page:isTouchInViewRect_({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.m_page:onTouch_({
          name = "moved",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
      end
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    self.m_moveDis = 0
    if 0 < self.m_page:getPageCount() then
      self.m_page:onTouch_({
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
function FriendChooseItem:SetData(data)
  self.m_data = data
end
function FriendChooseItem:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/FriendChooseItem.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self:CreatePages()
end
function FriendChooseItem:CreatePages()
  self.m_page = cc.ui.UIPageView.new({
    viewRect = cc.rect(0, 0, 800, 360),
    column = 6,
    row = 2,
    columnSpace = 50,
    rowSpace = 6,
    padding = {
      left = 0,
      right = 40,
      top = 0,
      bottom = 40
    },
    scale = self.m_scale
  })
  self.m_page:pos(168, 20):addTo(self.m_bg)
  self.m_page:onTouch(handler(self, self.PageTouchListener))
  self:RefreshPages()
end
function FriendChooseItem:RefreshPages()
  self.m_page:removeAllItems()
  for key, val in ipairs(self.m_data) do
    local item = self:CreateItem(val)
    self.m_page:addItem(item)
  end
  self.m_page:reload()
end
function FriendChooseItem:CreateItem(itemData)
  local itemNode = display.newSprite("UI/common/zhuangshi_guangquan.png")
  itemNode:setAnchorPoint(0, 0)
  itemNode:setScale(0.7)
  local itemIcon = td.CreateItemIcon(itemData.id)
  td.AddRelaPos(itemNode, itemIcon)
  local item = self.m_page:newItem()
  item:addChild(itemNode)
  item:setTag(itemData.id)
  return item
end
function FriendChooseItem:PageTouchListener(event)
  if event.name == "clicked" and event.item then
    do
      local itemId = event.item:getTag()
      local function cb()
        self:SendDonationRequest(itemId)
      end
      local itemName = self.itemInfoMng:GetItemInfo(itemId).name
      local conStr = string.format("\231\161\174\229\174\154\232\166\129\232\175\183\230\177\130%s\229\144\151?", itemName)
      local button1 = {
        text = g_LM:getBy("a00009"),
        callFunc = cb
      }
      local button2 = {
        text = g_LM:getBy("a00116")
      }
      local data = {
        size = cc.size(454, 300),
        content = conStr,
        buttons = {button1, button2}
      }
      local subWindow = MessageBoxDlg.new(data)
      subWindow:Show()
    end
  end
end
function FriendChooseItem:SendDonationRequest(itemId)
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.AskForAssist
  Msg.sendData = {item_id = itemId}
  Msg.cbData = clone(Msg.sendData)
  tdRequest:Send(Msg)
end
function FriendChooseItem:DonationRequestCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    UserDataManager:GetInstance():UpdateAssistItem(cbData.item_id)
    td.dispatchEvent(td.CHOSE_DONATE_ITEM)
    self:close()
  else
    td.alert(g_LM:getBy("a00323"))
  end
end
return FriendChooseItem
