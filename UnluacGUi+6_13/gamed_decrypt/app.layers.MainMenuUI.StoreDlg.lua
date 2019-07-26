local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local CommonInfoManager = require("app.info.CommonInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local InformationManager = require("app.layers.InformationManager")
local TabButton = require("app.widgets.TabButton")
local scheduler = require("framework.scheduler")
local StoreDlg = class("StoreDlg", BaseDlg)
local REFRESH_COST = 30
local ItemSize = cc.size(155, 320)
StoreDlg.Types = {
  {
    td.BuyType.Normal,
    td.BuyType.Friend,
    td.BuyType.Skill,
    td.BuyType.Weapon,
    td.BuyType.Gem
  },
  {
    td.BuyType.Arena
  }
}
function StoreDlg:ctor(data)
  StoreDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Store
  self.m_currIndex = nil
  self.m_curStoreType = td.BuyType.Normal
  self.vStoreConfig = {
    [td.BuyType.Normal] = {name = "a00384"},
    [td.BuyType.Friend] = {
      name = "a00383",
      item = td.ItemId_FriendNote
    },
    [td.BuyType.Skill] = {name = "a00385", item = 20129},
    [td.BuyType.Weapon] = {name = "a00386", item = 20130},
    [td.BuyType.Gem] = {name = "a00387", item = 20131},
    [td.BuyType.Arena] = {
      name = "a00242",
      item = td.ItemID_Check
    }
  }
  if data and data.type then
    self.vShowStoreTypes = StoreDlg.Types[data.type]
  else
    self.vShowStoreTypes = StoreDlg.Types[1]
  end
  self.m_storeItems = {}
  for i, var in ipairs(self.vShowStoreTypes) do
    self.m_storeItems[var] = {}
  end
  self.clicked = 0
  self:InitUI()
end
function StoreDlg:InitUI()
  self:LoadUI("CCS/StoreDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_shangcheng.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_textFreeRefresh = cc.uiloader:seekNodeByName(self.m_bg, "Text_times_left")
  self.m_textRefreshTimes = cc.uiloader:seekNodeByName(self.m_bg, "Text_times_left_data")
  self.m_buttonRefresh = cc.uiloader:seekNodeByName(self.m_bg, "Button_refresh")
  self.m_buttonRefresh:setPressedActionEnabled(true)
  self.m_refreshPrice = self.m_buttonRefresh:getChildByName("Text_12")
  self.m_buttonPurchase = cc.uiloader:seekNodeByName(self.m_bg, "Button_purchase")
  self.m_iconNote = cc.uiloader:seekNodeByName(self.m_bg, "Icon_note")
  self.m_numNote = cc.uiloader:seekNodeByName(self.m_iconNote, "Text_note")
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_countdown")
  label:setString(g_LM:getBy("a00382") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_purchase")
  label:setString(g_LM:getBy("a00115"))
end
function StoreDlg:onEnter()
  StoreDlg.super.onEnter(self)
  self:PlayEnterAni(function()
    self:CreateTabs()
    self:CreateList()
    self:InitCountDown()
    self:AddButtonEvents()
    self:AddEvents()
  end)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetArenaShops, handler(self, self.SendGetListResponce))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.ArenaExchange, handler(self, self.PurchaseCallback))
end
function StoreDlg:onExit()
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
  end
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetArenaShops)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.ArenaExchange)
  StoreDlg.super.onExit(self)
end
function StoreDlg:PlayEnterAni(cb)
  local btmBar = cc.uiloader:seekNodeByName(self.m_bg, "Image_btmBar")
  btmBar:runAction(cc.EaseBackOut:create(cca.moveTo(0.4, 568, 160)))
  local topBar = cc.uiloader:seekNodeByName(self.m_bg, "Image_topBar")
  topBar:runAction(cca.spawn({
    cc.EaseBackOut:create(cca.moveTo(0.4, 568, 510)),
    cca.seq({
      cca.delay(0.3),
      cca.cb(cb)
    })
  }))
end
function StoreDlg:AddEvents()
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
      return true
    end
    return false
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
  self:AddCustomEvent(td.ITEM_UPDATE, handler(self, self.UpdateItems))
end
function StoreDlg:UpdateItems(event)
  local storeConfig = self:_GetStoreConfig(self.m_curStoreType)
  if storeConfig.item then
    local num = UserDataManager:GetInstance():GetItemNum(storeConfig.item)
    self.m_numNote:setString(num)
  end
end
function StoreDlg:AddButtonEvents()
  td.BtnAddTouch(self.m_buttonPurchase, handler(self, self.Purchase), nil, 1)
  td.BtnAddTouch(self.m_buttonRefresh, handler(self, self.RefreshStore))
end
function StoreDlg:CreateTabs()
  self.m_tabs = {}
  local tabButtons = {}
  for i, storeType in ipairs(self.vShowStoreTypes) do
    local _tab = ccui.ImageView:create("UI/button/shangcheng2_button.png")
    _tab:pos(-30 + i * 160, 550):addTo(self.m_bg)
    table.insert(self.m_tabs, _tab)
    local title = g_LM:getBy(self:_GetStoreConfig(storeType).name)
    local tabButton = {
      tab = _tab,
      text = title,
      callfunc = handler(self, self.UpdatePanels),
      normalImageFile = "UI/button/shangcheng2_button.png",
      highImageFile = "UI/button/shangcheng1_button.png"
    }
    table.insert(tabButtons, tabButton)
  end
  local initIndex = self.m_vEnterSubIndex[1] or 1
  self.m_tabButtons = TabButton.new(tabButtons, {
    textSize = 20,
    normalTextColor = td.WHITE,
    highTextColor = td.WHITE,
    autoSelectIndex = initIndex
  })
end
function StoreDlg:_GetStoreConfig(storeType)
  return self.vStoreConfig[storeType]
end
function StoreDlg:UpdatePanels(tabIndex)
  self.m_currIndex = nil
  self.m_curStoreType = self.vShowStoreTypes[tabIndex]
  if #self.m_storeItems[self.m_curStoreType] > 0 then
    self:RefreshList()
  else
    self:SendGetListRequest(self.m_curStoreType, false)
  end
  local storeConfig = self:_GetStoreConfig(self.m_curStoreType)
  if storeConfig.item then
    local icon = td.GetItemIcon(storeConfig.item)
    self.m_iconNote:loadTexture(icon)
    self.m_iconNote:setVisible(true)
    local num = UserDataManager:GetInstance():GetItemNum(storeConfig.item)
    self.m_numNote:setString(num)
  else
    self.m_iconNote:setVisible(false)
  end
end
function StoreDlg:CreateList()
  local listBg = cc.uiloader:seekNodeByName(self.m_bg, "Panel_listBg")
  self.m_UIListView = require("app.widgets.EnhanceListView").new({
    direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
    viewRect = cc.rect(55, 200, 1040, 330),
    touchOnContent = false,
    scale = td.GetAutoScale()
  }, self.m_bg)
  self.m_UIListView:onTouch(function(event)
    if event.name == "clicked" then
      self:OnStoreItemClicked(event.itemPos)
    end
  end)
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:addTo(self.m_bg)
end
function StoreDlg:OnStoreItemClicked(index)
  if self.m_currIndex == index then
    return
  end
  if self.m_itemInfo then
    self.m_itemInfo:removeFromParent()
    self.m_itemInfo = nil
  end
  local itemData = self.m_storeItems[self.m_curStoreType][index]
  local storeItemInfo = CommonInfoManager:GetInstance():GetMallItemInfo(itemData.item_id)
  if storeItemInfo then
    local nameStr
    if storeItemInfo.item < 20000 then
      local info = StrongInfoManager:GetInstance():GetWeaponInfo(storeItemInfo.item)
      nameStr = info.name
    elseif storeItemInfo.item > 80000 then
      local info = StrongInfoManager:GetInstance():GetGemInfo(storeItemInfo.item)
      nameStr = info.name
    else
      local info = ItemInfoManager:GetInstance():GetItemInfo(storeItemInfo.item)
      nameStr = info.name
    end
    self.m_itemInfo = td.RichText({
      {
        type = 1,
        str = "\231\161\174\232\174\164\232\180\173\228\185\176",
        color = td.WHITE,
        size = 24
      },
      {
        type = 1,
        str = nameStr,
        color = td.LIGHT_GREEN,
        size = 24
      },
      {
        type = 1,
        str = "\229\144\151\239\188\159",
        color = td.WHITE,
        size = 24
      },
      {
        type = 1,
        str = "(\228\184\139\230\172\161\229\136\183\230\150\176\229\137\141\232\191\152\229\143\175\232\180\173\228\185\176",
        color = td.WHITE,
        size = 24
      },
      {
        type = 1,
        str = itemData.remain,
        color = td.LIGHT_GREEN,
        size = 24
      },
      {
        type = 1,
        str = "\230\172\161)",
        color = td.WHITE,
        size = 24
      }
    })
    self.m_itemInfo:setAnchorPoint(0, 0.5)
    self.m_itemInfo:pos(35, 95):addTo(self.m_bg)
  end
  local function ChangeItemBg(index, bShow)
    local clickedItem = self.m_UIListView:getItemByPos(index):getContent()
    local pBg = clickedItem:getChildByName("Image_bg")
    local seleSpr = pBg:getChildByName("seleSpt")
    if bShow then
      if not seleSpr then
        local seleSpr = display.newScale9Sprite("UI/scale9/lanse_xuanzhongkuang.png", 0, 0, cc.size(170, 300))
        seleSpr:setName("seleSpt")
        td.AddRelaPos(pBg, seleSpr)
      end
    elseif seleSpr then
      seleSpr:removeFromParent()
    end
  end
  if self.m_currIndex then
    ChangeItemBg(self.m_currIndex, false)
  end
  self.m_currIndex = index
  ChangeItemBg(self.m_currIndex, true)
end
function StoreDlg:RefreshList()
  self.m_currIndex = nil
  if self.m_itemInfo then
    self.m_itemInfo:removeFromParent()
    self.m_itemInfo = nil
    print(self.m_itemInfo)
  end
  self.m_UIListView:removeAllItems()
  for i, value in ipairs(self.m_storeItems[self.m_curStoreType]) do
    local item = self:CreateItem(value, i)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
  local buyTime = UserDataManager:GetInstance():GetStoreRefreshTimes()
  if buyTime <= 0 then
    self.m_textFreeRefresh:setVisible(false)
    self.m_textRefreshTimes:setVisible(false)
    self.m_refreshPrice:setString(30)
  else
    local vipLevel = UserDataManager:GetInstance():GetVipLevel()
    local totalTime = CommonInfoManager:GetInstance():GetVipInfo(vipLevel).store_refresh
    local str = string.format("%d/%d", buyTime, totalTime)
    self.m_textRefreshTimes:setString(str)
    self.m_refreshPrice:setString(0)
    self.m_textFreeRefresh:setVisible(true)
    self.m_textRefreshTimes:setVisible(true)
  end
end
function StoreDlg:CreateItem(value, index)
  local pItem = cc.uiloader:load("CCS/StoreItem.csb")
  pItem:setContentSize(ItemSize)
  pItem:setScale(self.m_scale)
  local pBg = cc.uiloader:seekNodeByName(pItem, "Image_bg")
  local opacity = 255
  local scale = 1
  if value.remain <= 0 then
    pBg:pos(10, 4)
    opacity = 130
    scale = 0.96
  end
  pBg:setAnchorPoint(0, 0)
  pBg:setScale(0)
  pBg:setOpacity(0)
  pBg:runAction(cca.seq({
    cca.delay((index - 1) * 0.05),
    cca.spawn({
      cc.EaseBackOut:create(cca.scaleTo(0.2, scale)),
      cca.fadeTo(0.2, opacity / 255)
    })
  }))
  local bgSize = pBg:getContentSize()
  local storeItemInfo = CommonInfoManager:GetInstance():GetMallItemInfo(value.item_id)
  if storeItemInfo then
    do
      local info
      local curStar = 1
      if storeItemInfo.item < 20000 then
        info = StrongInfoManager:GetInstance():GetWeaponInfo(storeItemInfo.item)
      elseif storeItemInfo.item > 80000 then
        info = StrongInfoManager:GetInstance():GetGemInfo(storeItemInfo.item)
        curStar = info.quality
      else
        info = ItemInfoManager:GetInstance():GetItemInfo(storeItemInfo.item)
        curStar = info.quality
      end
      local iconSpr = td.IconWithStar(info.icon .. td.PNG_Suffix, curStar, info.quality, -27)
      iconSpr:setName("icon")
      local iconBg = cc.uiloader:seekNodeByName(pBg, "Image_item_bg")
      td.AddRelaPos(iconBg, iconSpr)
      local infoIcon = cc.uiloader:seekNodeByName(pBg, "Button_info")
      td.BtnAddTouch(infoIcon, function()
        if storeItemInfo.item < 20000 then
          g_MC:OpenModule(td.UIModule.WeaponUpgrade, {
            weaponId = info.id,
            infoOnly = true
          })
        else
          g_MC:OpenModule(td.UIModule.ItemDetail, {
            itemId = info.id,
            showType = 2
          })
        end
      end)
      local timeLabel = td.CreateLabel(string.format("%d/%d", value.remain, value.max), td.LIGHT_BLUE, 18)
      timeLabel:setName("timeLabel")
      td.AddRelaPos(pBg, timeLabel, 1, cc.p(0.5, 0.23))
      local costLabel
      if value.remain <= 0 then
        iconSpr:removeAllChildren()
        costLabel = td.CreateLabel(". . .", td.WHITE, 22)
      else
        costLabel = td.RichText({
          {
            type = 2,
            file = td.GetItemIcon(self:GetCostItemId(storeItemInfo.consume_type)),
            scale = 0.4
          },
          {
            type = 1,
            str = "x" .. storeItemInfo.price,
            color = td.WHITE,
            size = 18
          }
        })
      end
      costLabel:setName("cost")
      local costBg = cc.uiloader:seekNodeByName(pBg, "Image_cost_bg")
      td.AddRelaPos(costBg, costLabel)
    end
  else
    print("not found", value.item_id)
  end
  local item = self.m_UIListView:newItem(pItem)
  item:setItemSize((ItemSize.width + 20) * self.m_scale, ItemSize.height * self.m_scale)
  return item
end
function StoreDlg:Purchase()
  local storeItem = self.m_storeItems[self.m_curStoreType][self.m_currIndex]
  local bEnable, errorCode = self:CheckCanBuy(storeItem)
  if bEnable then
    local storeItemId = storeItem.item_id
    print("storeItemId :", storeItemId)
    self:SendPurchaseRequest(self.m_curStoreType, storeItemId)
  else
    td.alertErrorMsg(errorCode)
  end
end
function StoreDlg:CheckCanBuy(storeItem)
  if storeItem then
    if storeItem.remain <= 0 then
      return false, td.ErrorCode.TIME_NOT_ENOUGH
    else
      local storeItemInfo = CommonInfoManager:GetInstance():GetMallItemInfo(storeItem.item_id)
      local costItemId = self:GetCostItemId(storeItemInfo.consume_type)
      if storeItemInfo.price > UserDataManager:GetInstance():GetItemNum(costItemId) then
        return false, td.ErrorCode.MATERIAL_NOT_ENOUGH
      end
    end
    return true
  end
  return false, td.ErrorCode.NO_ITEM_SELECTED
end
function StoreDlg:RefreshStore()
  local function cb()
    self:SendGetListRequest(self.m_curStoreType, true)
  end
  local udMng = UserDataManager:GetInstance()
  local buyTime = udMng:GetStoreRefreshTimes()
  if buyTime > 0 then
    cb()
  elseif udMng:GetDiamond() >= REFRESH_COST then
    local conStr = string.format("\231\161\174\229\174\154\232\138\177\232\180\185%d\233\146\187\231\159\179\229\136\183\230\150\176\229\144\151\239\188\159", REFRESH_COST)
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
    local messageBox = require("app.layers.MessageBoxDlg").new(data)
    messageBox:Show()
  else
    td.alertErrorMsg(td.ErrorCode.DIAMOND_NOT_ENOUGH)
  end
end
function StoreDlg:InitCountDown()
  self.m_countDownLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_countdown_data")
  local serverTime = math.floor(UserDataManager:GetInstance():GetServerTime())
  local refreshTime = td.GetFutureTimeStamp(serverTime, 1, 0)
  self.m_countDown = refreshTime - serverTime
  local hour, min, sec = math.floor(self.m_countDown / 3600), math.floor(self.m_countDown % 3600 / 60), math.floor(self.m_countDown % 60)
  self.m_countDownLabel:setString(string.format("%02d", hour) .. ":" .. string.format("%02d", min) .. ":" .. string.format("%02d", sec))
  self.m_timeScheduler = scheduler.scheduleGlobal(function()
    self.m_countDown = cc.clampf(self.m_countDown - 1, 0, 86400)
    local hour, min, sec = math.floor(self.m_countDown / 3600), math.floor(self.m_countDown % 3600 / 60), math.floor(self.m_countDown % 60)
    self.m_countDownLabel:setString(string.format("%02d", hour) .. ":" .. string.format("%02d", min) .. ":" .. string.format("%02d", sec))
    if self.m_countDown == 0 then
      self:SendGetListRequest(self.m_curStoreType, false)
      self.m_countDown = 86400
    end
  end, 1)
end
function StoreDlg:GetCostItemId(type)
  if type == 1 then
    return td.ItemID_Diamond
  elseif type == 2 then
    return td.ItemID_Gold
  elseif type == 3 then
    return td.ItemID_Check
  elseif type == 4 then
    return td.ItemId_FriendNote
  elseif type == 5 then
    return 20129
  elseif type == 6 then
    return 20130
  elseif type == 7 then
    return 20131
  end
end
function StoreDlg:DisableItem(itemIndex)
  local itemBg = cc.uiloader:seekNodeByName(self.m_UIListView:getItemByPos(itemIndex):getContent(), "Image_bg")
  local icon = cc.uiloader:seekNodeByName(itemBg, "icon")
  local cost = cc.uiloader:seekNodeByName(itemBg, "cost")
  icon:removeAllChildren()
  cost:removeFromParent()
  cost = nil
  local costLabel = td.CreateLabel(". . .", td.WHITE, 22)
  local costBg = cc.uiloader:seekNodeByName(itemBg, "Image_cost_bg")
  td.AddRelaPos(costBg, costLabel)
  itemBg:setScale(0.96)
  itemBg:setPosition(10, 4)
  itemBg:setOpacity(130)
  local selSpr = itemBg:getChildByName("seleSpt")
  if selSpr then
    selSpr:removeFromParent()
  end
end
function StoreDlg:SendGetListRequest(storeType, bRefresh)
  local data = {}
  data.store_id = storeType
  data.type = bRefresh and 1 or 0
  local Msg = {}
  Msg.msgType = td.RequestID.GetArenaShops
  Msg.sendData = data
  Msg.cbData = data
  TDHttpRequest:getInstance():Send(Msg)
end
function StoreDlg:SendGetListResponce(data, cbData)
  self.m_storeItems[cbData.store_id] = {}
  for i, var in ipairs(data.areanShop) do
    local storeItemInfo = CommonInfoManager:GetInstance():GetMallItemInfo(var.item_id)
    var.max = storeItemInfo.max
    var.remain = storeItemInfo.max - var.item_num
    self.m_storeItems[cbData.store_id][var.item_index] = var
  end
  if cbData.type == 1 then
    UserDataManager:GetInstance():UpdateStoreRefreshTimes()
  end
  self:RefreshList()
end
function StoreDlg:SendPurchaseRequest(storeType, storeItemId)
  local data = {}
  data.store_id = storeType
  data.id = storeItemId
  local msg = {}
  msg.msgType = td.RequestID.ArenaExchange
  msg.sendData = data
  msg.cbData = data
  TDHttpRequest:getInstance():Send(msg)
end
function StoreDlg:PurchaseCallback(data, cbData)
  if data.state ~= td.ResponseState.Success then
    return
  end
  local storeItem = self.m_storeItems[self.m_curStoreType][self.m_currIndex]
  storeItem.remain = storeItem.remain - 1
  if storeItem.remain == 0 then
    self:DisableItem(self.m_currIndex)
  end
  local storeItemInfo = CommonInfoManager:GetInstance():GetMallItemInfo(cbData.id)
  local pItem = self.m_UIListView:getItemByPos(self.m_currIndex):getContent()
  local timeLabel = cc.uiloader:seekNodeByName(pItem, "timeLabel")
  timeLabel:setString(string.format("%d/%d", storeItem.remain, storeItemInfo.max))
  InformationManager:GetInstance():ShowInfoDlg({
    type = td.ShowInfo.Item,
    items = {
      [storeItemInfo.item] = 1
    }
  })
end
return StoreDlg
