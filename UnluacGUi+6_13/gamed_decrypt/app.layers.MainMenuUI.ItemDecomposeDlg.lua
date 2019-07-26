local ItemInfoManager = require("app.info.ItemInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local scheduler = require("framework.scheduler")
local BaseDlg = require("app.layers.BaseDlg")
local AddOrMinus = {Add = 1, Minus = -1}
local ItemDecomposeDlg = class("ItemDecomposeDlg", BaseDlg)
function ItemDecomposeDlg:ctor(data)
  ItemDecomposeDlg.super.ctor(self)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_uiId = td.UIModule.Decompose
  self.itemId = nil
  self.gainItemId = nil
  self.quantity = 1
  self.gainNum = 0
  self.gainRate = 0
  self.m_adding = 0
  self:InitUI()
  self:SetData(data.itemId)
end
function ItemDecomposeDlg:onEnter()
  ItemDecomposeDlg.super.onEnter(self)
  self.m_addingScheduler = scheduler.scheduleGlobal(handler(self, self.AddingItems), 0.1)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.Decompose, handler(self, self.DecomposeCallback))
  self:AddBtnEvents()
  self:AddTouch()
end
function ItemDecomposeDlg:onExit()
  if self.m_addingScheduler then
    scheduler.unscheduleGlobal(self.m_addingScheduler)
    self.m_addingScheduler = nil
  end
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.Decompose)
  ItemDecomposeDlg.super.onExit(self)
end
function ItemDecomposeDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/ItemDecomposeDlg.csb")
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
  local labelQuan = cc.uiloader:seekNodeByName(self.m_bg, "Text_quantity")
  labelQuan:setString(g_LM:getBy("a00233"))
  self.quanTxt = td.CreateLabel(self.quantity, td.YELLOW)
  self.gainTxt = cc.uiloader:seekNodeByName(self.m_bg, "Text_exp_data")
  td.AddRelaPos(self.quan_bg, self.quanTxt)
end
function ItemDecomposeDlg:SetData(itemId)
  self.itemId = itemId
  self.haveNum = self.m_udMng:GetItemNum(itemId)
  local gainInfo = ItemInfoManager:GetInstance():GetDecomposeInfo(itemId)
  self.gainItemId = gainInfo.gain_id
  self.gainRate = gainInfo.gain_num
  self.gainNum = self.quantity * self.gainRate
  self:RefreshUI()
end
function ItemDecomposeDlg:RefreshUI()
  self.iconSpr = td.CreateItemIcon(self.itemId, true)
  td.AddRelaPos(self.m_bg, self.iconSpr, 1, cc.p(0.5, 0.76))
  local labelGain = td.RichText({
    {
      type = 1,
      str = g_LM:getBy("a00234"),
      size = 20,
      color = td.BLUE
    },
    {
      type = 2,
      file = td.GetItemIcon(self.gainItemId),
      scale = 0.4
    },
    {
      type = 1,
      str = ":",
      size = 20,
      color = td.BLUE
    }
  })
  labelGain:align(display.RIGHT_CENTER, 138, 147):addTo(self.m_bg)
  self:RefreshLabel()
end
function ItemDecomposeDlg:RefreshLabel()
  self.quanTxt:setString(self.quantity)
  self.gainTxt:setString(self.gainNum)
end
function ItemDecomposeDlg:AddTouch()
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
function ItemDecomposeDlg:AddBtnEvents()
  self.btn_add:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.began == eventType then
      self.m_adding = 1
    end
    if ccui.TouchEventType.ended == eventType then
      self.m_adding = 0
    end
  end)
  self.btn_minus:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.began == eventType then
      self.m_adding = -1
    end
    if ccui.TouchEventType.ended == eventType then
      self.m_adding = 0
    end
  end)
  td.BtnAddTouch(self.btn_confirm, function()
    if self.m_bIsSending then
      return
    end
    if self.quantity > 0 then
      self:DecomposeRequest(self.itemId, self.quantity)
    end
  end, nil, td.ButtonEffectType.Long)
  td.BtnAddTouch(self.btn_cancel, function()
    self:close()
  end)
end
function ItemDecomposeDlg:AddingItems()
  if self.m_adding ~= 0 and self:CheckQuantity(self.m_adding) then
    self:ModifyQuantity(self.m_adding)
  end
end
function ItemDecomposeDlg:ModifyQuantity(variation)
  self.quantity = self.quantity + variation
  self.gainNum = self.gainRate * self.quantity
  self:RefreshLabel()
end
function ItemDecomposeDlg:CheckQuantity(addOrMinus)
  local canClick = false
  if addOrMinus == AddOrMinus.Add then
    if self.haveNum > self.quantity then
      canClick = true
    end
  elseif addOrMinus == AddOrMinus.Minus and self.quantity > 1 then
    canClick = true
  end
  return canClick
end
function ItemDecomposeDlg:DecomposeRequest(targetId, quantity)
  self.m_bIsSending = true
  local Msg = {}
  Msg.msgType = td.RequestID.Decompose
  local decType = targetId > 80000 and 2 or 3
  Msg.sendData = {
    id = targetId,
    num = quantity,
    type = decType
  }
  Msg.cbData = {
    id = targetId,
    num = quantity,
    type = decType
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function ItemDecomposeDlg:DecomposeCallback(data, cbData)
  self.m_bIsSending = false
  if td.ResponseState.Success == data.state then
    td.CreateUIEffect(self.iconSpr, "Spine/UI_effect/UI_fenjie_01", {
      cb = function()
        local _items = {
          [self.gainItemId] = self.gainNum
        }
        InformationManager:GetInstance():ShowInfoDlg({
          type = td.ShowInfo.Item,
          items = _items
        })
        self:close()
      end
    })
    if cbData.type == 2 then
      self.m_udMng:SendGetGemRequest()
    end
  end
end
return ItemDecomposeDlg
