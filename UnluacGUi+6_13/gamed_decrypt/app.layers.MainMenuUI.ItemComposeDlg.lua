local ItemInfoManager = require("app.info.ItemInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local scheduler = require("framework.scheduler")
local BaseDlg = require("app.layers.BaseDlg")
local AddOrMinus = {Add = 1, Minus = -1}
local ItemComposeDlg = class("ItemComposeDlg", BaseDlg)
function ItemComposeDlg:ctor(data)
  ItemComposeDlg.super.ctor(self)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_uiId = td.UIModule.Compose
  self.itemId = nil
  self.gainItemId = nil
  self.quantity = 1
  self.maxQuantity = 0
  self.costNum = 0
  self.costRate = 0
  self.m_adding = 0
  self:InitUI()
  self:SetData(data.itemId)
end
function ItemComposeDlg:onEnter()
  ItemComposeDlg.super.onEnter(self)
  self.m_addingScheduler = scheduler.scheduleGlobal(handler(self, self.AddingItems), 0.1)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.ComposeGem, handler(self, self.ComposeCallback))
  self:AddBtnEvents()
  self:AddTouch()
end
function ItemComposeDlg:onExit()
  if self.m_addingScheduler then
    scheduler.unscheduleGlobal(self.m_addingScheduler)
    self.m_addingScheduler = nil
  end
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.ComposeGem)
  ItemComposeDlg.super.onExit(self)
end
function ItemComposeDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/ComposeDlg.csb")
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
  labelQuan:setString(g_LM:getBy("a00236"))
  self.quanTxt = td.CreateLabel(self.quantity, td.YELLOW)
  td.AddRelaPos(self.quan_bg, self.quanTxt)
  self.costLabel = td.CreateLabel("0/0", td.WHITE)
  td.AddRelaPos(self.m_bg, self.costLabel, 1, cc.p(0.2, 0.6))
  self.gainLabel = td.CreateLabel("0", td.WHITE)
  td.AddRelaPos(self.m_bg, self.gainLabel, 1, cc.p(0.8, 0.6))
end
function ItemComposeDlg:SetData(itemId)
  self.itemId = itemId
  self.haveNum = self.m_udMng:GetItemNum(itemId)
  local gainInfo = ItemInfoManager:GetInstance():GetComposeInfo(itemId)
  self.gainItemId = gainInfo.gain_id
  self.costRate = gainInfo.cost_num
  self.costNum = self.costRate * self.quantity
  self.maxQuantity = math.floor(self.haveNum / self.costRate)
  self:RefreshUI()
end
function ItemComposeDlg:RefreshUI()
  local costItemInfo = td.GetItemInfo(self.itemId)
  self.iconSpr = td.CreateItemIcon(self.itemId, true)
  td.AddRelaPos(self.m_bg, self.iconSpr, 1, cc.p(0.2, 0.76))
  local gainItemInfo = td.GetItemInfo(self.gainItemId)
  local gainIconSpr = td.CreateItemIcon(self.gainItemId, true)
  td.AddRelaPos(self.m_bg, gainIconSpr, 1, cc.p(0.8, 0.76))
  local count = 0
  for propType, value in pairs(gainItemInfo.property) do
    local propLabel = td.RichText({
      {
        type = 1,
        str = g_LM:getMode("prop", propType) .. ":",
        color = td.YELLOW,
        size = 18
      },
      {
        type = 1,
        str = td.GetPropValue(propType, costItemInfo.property[propType]),
        color = td.WHITE,
        size = 18
      },
      {
        type = 2,
        file = "UI/common/jiantou_zhuangshi.png",
        scale = 1
      },
      {
        type = 1,
        str = td.GetPropValue(propType, gainItemInfo.property[propType]),
        color = td.WHITE,
        size = 18
      }
    })
    td.AddRelaPos(self.m_bg, propLabel, 1, cc.p(0.5, 0.7 - count * 0.05))
    count = count + 1
  end
  self:RefreshLabel()
end
function ItemComposeDlg:RefreshLabel()
  self.quanTxt:setString(self.quantity)
  self.gainLabel:setString(self.quantity)
  self.costLabel:setString(self.haveNum .. "/" .. self.costNum)
  if self.haveNum >= self.costNum then
    self.costLabel:setColor(td.WHITE)
  else
    self.costLabel:setColor(td.RED)
  end
end
function ItemComposeDlg:AddTouch()
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
function ItemComposeDlg:AddBtnEvents()
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
    if self.haveNum >= self.costNum then
      local vCostGemUid = self.m_udMng:GetCostGemUid(self.itemId, self.quantity * self.costRate)
      self:ComposeRequest(self.itemId, vCostGemUid)
    else
      td.alertErrorMsg(td.ErrorCode.MATERIAL_NOT_ENOUGH)
    end
  end, nil, td.ButtonEffectType.Long)
  td.BtnAddTouch(self.btn_cancel, function()
    self:close()
  end)
end
function ItemComposeDlg:AddingItems()
  if self.m_adding ~= 0 and self:CheckQuantity(self.m_adding) then
    self:ModifyQuantity(self.m_adding)
  end
end
function ItemComposeDlg:ModifyQuantity(variation)
  self.quantity = self.quantity + variation
  self.costNum = self.costRate * self.quantity
  self:RefreshLabel()
end
function ItemComposeDlg:CheckQuantity(addOrMinus)
  local canClick = false
  if addOrMinus == AddOrMinus.Add then
    if self.maxQuantity > self.quantity then
      canClick = true
    end
  elseif addOrMinus == AddOrMinus.Minus and self.quantity > 1 then
    canClick = true
  end
  return canClick
end
function ItemComposeDlg:ComposeRequest(targetId, vUid)
  self.m_bIsSending = true
  local Msg = {}
  Msg.msgType = td.RequestID.ComposeGem
  Msg.sendData = {gemstoneId = targetId, id = vUid}
  Msg.cbData = {gemstoneId = targetId}
  TDHttpRequest:getInstance():Send(Msg)
end
function ItemComposeDlg:ComposeCallback(data, cbData)
  self.m_bIsSending = false
  if td.ResponseState.Success == data.state then
    td.CreateUIEffect(self.iconSpr, "Spine/UI_effect/UI_fenjie_01", {
      cb = function()
        local _items = {
          [self.gainItemId] = self.quantity
        }
        InformationManager:GetInstance():ShowInfoDlg({
          type = td.ShowInfo.Item,
          items = _items
        })
        self:close()
      end
    })
  else
    td.alert(g_LM:getBy("a00323"), true)
  end
end
return ItemComposeDlg
