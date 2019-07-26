local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local CommonInfoManager = require("app.info.CommonInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local InformationManager = require("app.layers.InformationManager")
local TabButton = require("app.widgets.TabButton")
local TouchIcon = require("app.widgets.TouchIcon")
local TopupDlg = class("TopupDlg", BaseDlg)
TopupDlg.Types = {Topup = 1, Bonus = 2}
function TopupDlg:ctor()
  TopupDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Topup
  self.m_currTab = nil
  self.m_currIndex = nil
  self.m_udMng = UserDataManager:GetInstance()
  self:InitData()
  self:InitUI()
end
function TopupDlg:InitData()
  self.m_vChargeInfo = {}
  local vChargeInfo = CommonInfoManager:GetInstance():GetChargeInfo(td.PayType.Charge)
  for key, var in pairs(vChargeInfo) do
    table.insert(self.m_vChargeInfo, var)
  end
end
function TopupDlg:InitUI()
  self:LoadUI("CCS/TopupDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_chongzhi.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_btmBar = cc.uiloader:seekNodeByName(self.m_bg, "Image_btmBar")
  self.m_btmBar:setPositionY(320)
  self.m_topBar = cc.uiloader:seekNodeByName(self.m_bg, "Image_topBar")
  self.m_topBar:setPositionY(320)
  self.m_btnPurchase = cc.uiloader:seekNodeByName(self.m_bg, "Button_purchase")
  self.m_textBought = cc.uiloader:seekNodeByName(self.m_bg, "Text_boughtDiamond")
  self.m_textBought:setString(g_LM:getBy("a00248") .. ": ")
  self.m_numBought = cc.uiloader:seekNodeByName(self.m_bg, "Text_boughtNum")
  self.m_numBought:setString(tostring(self.m_udMng:GetTotalCharge()))
end
function TopupDlg:onEnter()
  TopupDlg.super.onEnter(self)
  self:PlayEnterAni(function()
    self:CreateList()
    self:CreateTabs()
    self:AddEvents()
  end)
end
function TopupDlg:onExit()
  TopupDlg.super.onExit(self)
end
function TopupDlg:PlayEnterAni(cb)
  self.m_btmBar:runAction(cc.EaseBackOut:create(cca.moveTo(0.4, 568, 160)))
  self.m_topBar:runAction(cca.spawn({
    cc.EaseBackOut:create(cca.moveTo(0.4, 568, 510)),
    cca.seq({
      cca.delay(0.3),
      cca.cb(cb)
    })
  }))
end
function TopupDlg:CreateList()
  local listBg = cc.uiloader:seekNodeByName(self.m_bg, "Panel_listBg")
  self.m_UIListView = require("app.widgets.EnhanceListView").new({
    direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
    viewRect = cc.rect(50, 165, 1030, 340),
    touchOnContent = false,
    scale = td.GetAutoScale()
  }, self.m_bg)
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:addTo(self.m_bg)
  self.m_UIListView:onTouch(function(event)
    if event.name == "clicked" and self.m_currTab == TopupDlg.Types.Topup then
      self:OnChargeItemClicked(event.itemPos)
    end
  end)
end
function TopupDlg:OnChargeItemClicked(index)
  if self.m_currIndex == index then
    return
  end
  local function ChangeItemBg(index, bShow)
    local clickedItem = self.m_UIListView:getItemByPos(index):getContent()
    local pBg = clickedItem:getChildByName("Image_bg")
    local seleSpr = pBg:getChildByName("seleSpt")
    if bShow then
      if not seleSpr then
        local bgSize = pBg:getContentSize()
        local seleSpr = display.newScale9Sprite("UI/scale9/lanse_xuanzhongkuang.png", 0, 0, cc.size(bgSize.width + 15, bgSize.height + 15))
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
function TopupDlg:CreateTabs()
  self.m_tabs = {}
  local tabButtons = {}
  local tabTitles = {
    g_LM:getBy("a00227"),
    g_LM:getBy("a00228")
  }
  for i = 1, 2 do
    local _tab = ccui.ImageView:create("UI/button/shangcheng2_button.png")
    _tab:pos(138 + (i - 1) * 200, 550):addTo(self.m_bg)
    table.insert(self.m_tabs, _tab)
    local tabButton = {
      tab = _tab,
      text = tabTitles[i],
      callfunc = handler(self, self.UpdatePanels),
      normalImageFile = "UI/button/shangcheng2_button.png",
      highImageFile = "UI/button/shangcheng1_button.png"
    }
    table.insert(tabButtons, tabButton)
  end
  local initIndex = self.m_vEnterSubIndex[1] or 1
  self.m_tabButtons = TabButton.new(tabButtons, {
    textSize = 22,
    normalTextColor = td.WHITE,
    highTextColor = td.WHITE,
    autoSelectIndex = initIndex
  })
end
function TopupDlg:AddEvents()
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
  self:AddBtnEvent()
  self:AddCustomEvent(td.TOTAL_CHARGE_CHANGE, function()
    self:RefreshList()
  end)
end
function TopupDlg:AddBtnEvent()
  td.BtnAddTouch(self.m_btnPurchase, function()
    if self.m_currIndex then
      self.m_udMng:GetTradeIdRequest(self.m_vChargeInfo[self.m_currIndex].id, td.PayType.Charge)
    end
  end, nil, td.ButtonEffectType.Long)
end
function TopupDlg:UpdatePanels(tabIndex)
  self.m_currTab = tabIndex
  self:RefreshList()
end
function TopupDlg:RefreshList()
  self.m_UIListView:removeAllItems()
  if self.m_currTab == TopupDlg.Types.Topup then
    self.m_btnPurchase:setVisible(true)
    self.m_textBought:setVisible(false)
    self.m_numBought:setVisible(false)
    for key, var in ipairs(self.m_vChargeInfo) do
      local item = self:CreateTopupItem(var)
      self.m_UIListView:addItem(item)
    end
  elseif self.m_currTab == TopupDlg.Types.Bonus then
    self.m_btnPurchase:setVisible(false)
    self.m_numBought:setString(tostring(self.m_udMng:GetTotalCharge()))
    self.m_textBought:setVisible(true)
    self.m_numBought:setVisible(true)
    local data = CommonInfoManager:GetInstance():GetVipInfo()
    for key, var in ipairs(data) do
      local item = self:CreateBonusItem(var)
      self.m_UIListView:addItem(item)
    end
  end
  self.m_UIListView:reload()
end
function TopupDlg:CreateTopupItem(itemData)
  local itemNode = cc.uiloader:load("CCS/TopupChargeItem.csb")
  local itemBg = cc.uiloader:seekNodeByName(itemNode, "Image_bg")
  local itemSize = itemBg:getContentSize()
  itemNode:setContentSize(itemSize)
  itemNode:setScale(self.m_scale)
  local diamondIcon = cc.uiloader:seekNodeByName(itemBg, "Image_diamondPile")
  diamondIcon:loadTexture("UI/supply/zuanshi_icon" .. itemData.id .. td.PNG_Suffix)
  if self.m_udMng:IsFirstCharge(itemData.id) then
    local iconType = cc.uiloader:seekNodeByName(itemBg, "Image_type")
    iconType:loadTexture("UI/supply/icon_times" .. itemData.first_time .. ".png")
    local extraNum = itemData.diamond * (itemData.first_time - 1)
    local addText = td.CreateLabel(string.format(g_LM:getBy("a00414"), extraNum), td.GREEN, 18)
    td.AddRelaPos(itemBg, addText, 1, cc.p(0.5, 0.45))
  end
  local textPrice = cc.uiloader:seekNodeByName(itemBg, "Text_price")
  textPrice:setString("\239\191\165" .. itemData.value)
  local textNum = td.RichText({
    {
      type = 2,
      file = td.DIAMOND_ICON,
      scale = 0.6
    },
    {
      type = 1,
      str = "x" .. itemData.diamond,
      size = 18,
      color = td.WHITE
    }
  })
  td.AddRelaPos(itemBg, textNum, 1, cc.p(0.5, 0.26))
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize((itemSize.width + 30) * self.m_scale, itemSize.height * self.m_scale)
  return item
end
function TopupDlg:CreateBonusItem(info)
  local itemNode = cc.uiloader:load("CCS/TopupBonusItem.csb")
  local itemBg = cc.uiloader:seekNodeByName(itemNode, "Image_bg")
  local itemSize = itemBg:getContentSize()
  itemNode:setContentSize(itemSize.width, itemSize.height)
  itemNode:setScale(self.m_scale)
  local btnInfo = cc.uiloader:seekNodeByName(itemBg, "Button_vipInfo")
  btnInfo:setPressedActionEnabled(true)
  td.BtnAddTouch(btnInfo, function()
    g_MC:OpenModule(td.UIModule.VIP, {
      level = info.vip
    })
  end)
  btnInfo:getChildByName("Text_vip"):setString("" .. info.vip)
  local label1 = td.RichText({
    {
      type = 1,
      str = "\231\180\175\232\174\161\232\180\173\228\185\176",
      color = td.WHITE,
      size = 18
    },
    {
      type = 1,
      str = "" .. info.diamond_demand .. "\233\146\187\231\159\179",
      color = td.GREEN,
      size = 18
    },
    {
      type = 1,
      str = "\229\141\179\229\143\175\232\142\183\230\173\164\229\165\150\229\138\177",
      color = td.WHITE,
      size = 18
    }
  }, cc.size(160, 100))
  label1:align(display.LEFT_TOP, 75, 300):addTo(itemBg)
  self:_CreateAwards(itemBg, info.award_vip)
  local label2 = td.RichText({
    {
      type = 1,
      str = "\232\191\152\233\156\128\232\180\173\228\185\176",
      color = td.WHITE,
      size = 18
    },
    {
      type = 2,
      file = td.DIAMOND_ICON,
      scale = 0.6
    },
    {
      type = 1,
      str = "x" .. math.max(0, info.diamond_demand - self.m_udMng:GetTotalCharge()),
      color = td.GREEN,
      size = 18
    }
  })
  label2:align(display.CENTER_TOP, itemSize.width * 0.5, 60):addTo(itemBg)
  local sprProgress = cc.uiloader:seekNodeByName(itemBg, "spr_progress")
  sprProgress:setScaleX(cc.clampf(self.m_udMng:GetTotalCharge() / info.diamond_demand, 0, 1))
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize((itemSize.width + 12) * self.m_scale, itemSize.height * self.m_scale)
  return item
end
function TopupDlg:_CreateAwards(itemBg, itemData)
  local length = #itemData
  for key, item in ipairs(itemData) do
    local itemIcon = TouchIcon.new(item.itemId, true)
    local width = itemIcon:getContentSize().width
    local offset = (165 - width * (length - 1)) / (length - 1 + 2)
    local posX = (key - 1) * width + key * offset + 40
    itemIcon:pos(posX, 180):addTo(itemBg)
    local numLabel = td.CreateLabel("x" .. item.num, td.WHITE, 24)
    td.AddRelaPos(itemIcon, numLabel, 1, cc.p(0.5, -0.2))
  end
end
return TopupDlg
