local ItemInfoManager = require("app.info.ItemInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local scheduler = require("framework.scheduler")
local BaseDlg = require("app.layers.BaseDlg")
local InformationManager = require("app.layers.InformationManager")
local AddOrMinus = {Add = 1, Minus = -1}
local ItemSellDlg = class("ItemSellDlg", BaseDlg)
function ItemSellDlg:ctor(data)
  ItemSellDlg.super.ctor(self)
  self.m_uiId = td.UIModule.ItemSell
  self.m_udMng = UserDataManager:GetInstance()
  self.itemId = data.itemId
  self.itemInfo = ItemInfoManager:GetInstance():GetItemInfo(data.itemId)
  self.maxNum = self.m_udMng:GetItemNum(data.itemId)
  self.quantity = 0
  self.m_adding = 0
  self.quanTxt = nil
  self.iconSpr = nil
  self:InitUI()
  self:RefreshUI()
end
function ItemSellDlg:onEnter()
  ItemSellDlg.super.onEnter(self)
  self.m_addingScheduler = scheduler.scheduleGlobal(handler(self, self.AddingItems), 0.1)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.SellItem, handler(self, self.SellItemCallback))
  self:AddBtnEvents()
  self:AddTouch()
end
function ItemSellDlg:onExit()
  if self.m_addingScheduler then
    scheduler.unscheduleGlobal(self.m_addingScheduler)
    self.m_addingScheduler = nil
  end
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.SellItem)
  ItemSellDlg.super.onExit(self)
end
function ItemSellDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/ItemSellDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.btn_cancel = cc.uiloader:seekNodeByName(self.m_bg, "Button_cancel")
  td.BtnSetTitle(self.btn_cancel, g_LM:getBy("a00116"))
  self.btn_confirm = cc.uiloader:seekNodeByName(self.m_bg, "Button_confirm")
  td.BtnSetTitle(self.btn_confirm, g_LM:getBy("a00009"))
  self.quan_bg = cc.uiloader:seekNodeByName(self.m_bg, "Image_quantity_bg")
  self.btn_add = cc.uiloader:seekNodeByName(self.m_bg, "Button_add")
  td.CreateUIEffect(self.btn_add, "Spine/UI_effect/UI_kezhitishi_01")
  self.btn_minus = cc.uiloader:seekNodeByName(self.m_bg, "Button_minus")
  self.quanTxt = td.CreateLabel(self.quantity, td.YELLOW)
  self.goldTxt = cc.uiloader:seekNodeByName(self.m_bg, "Text_exp_data")
  td.AddRelaPos(self.quan_bg, self.quanTxt)
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_quantity")
  label:setString(g_LM:getBy("a00231") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_exp")
  label:setString(g_LM:getBy("a00234") .. ":")
end
function ItemSellDlg:RefreshUI()
  if self.iconSpr then
    self.iconSpr:removeFromParent()
    self.iconSpr = nil
  end
  self.iconSpr = td.CreateItemIcon(self.itemId, true)
  td.AddRelaPos(self.m_bg, self.iconSpr, 1, cc.p(0.5, 0.75))
  self:ModifyQuantity(1)
end
function ItemSellDlg:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function()
        self:close()
      end, 0.1)
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function ItemSellDlg:AddBtnEvents()
  self.btn_add:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.began == eventType then
      self.m_adding = 1
    elseif ccui.TouchEventType.ended == eventType then
      self.m_adding = 0
    end
  end)
  self.btn_minus:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.began == eventType then
      self.m_adding = -1
    elseif ccui.TouchEventType.ended == eventType then
      self.m_adding = 0
    end
  end)
  td.BtnAddTouch(self.btn_confirm, function()
    if self.quantity > 0 then
      self:SendSellRequest()
    end
  end, nil, td.ButtonEffectType.Long)
  td.BtnAddTouch(self.btn_cancel, function()
    self:close()
  end)
end
function ItemSellDlg:AddingItems()
  if self.m_adding ~= 0 and self:CheckQuantity(self.m_adding) then
    self:ModifyQuantity(self.m_adding)
  end
end
function ItemSellDlg:ModifyQuantity(variation)
  self.quantity = self.quantity + variation
  self.quanTxt:setString(self.quantity)
  self.goldTxt:setString("x" .. self.itemInfo.sale * self.quantity)
end
function ItemSellDlg:CheckQuantity(addOrMinus)
  local canClick = false
  if addOrMinus == AddOrMinus.Add then
    if self.maxNum > self.quantity then
      canClick = true
    end
  elseif addOrMinus == AddOrMinus.Minus and self.quantity >= 1 then
    canClick = true
  end
  return canClick
end
function ItemSellDlg:SendSellRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.SellItem
  Msg.sendData = {
    item_id = self.itemId,
    item_num = self.quantity
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function ItemSellDlg:SellItemCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    local price = self.itemInfo.sale * self.quantity
    InformationManager:GetInstance():ShowInfoDlg({
      type = td.ShowInfo.Item,
      items = {
        [td.ItemID_Gold] = price
      }
    })
    self:close()
  end
end
return ItemSellDlg
