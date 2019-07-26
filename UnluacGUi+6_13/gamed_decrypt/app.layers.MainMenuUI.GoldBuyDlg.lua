local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local CommonInfoManager = require("app.info.CommonInfoManager")
local scheduler = require("framework.scheduler")
local BaseDlg = require("app.layers.BaseDlg")
local GoldBuyDlg = class("GoldBuyDlg", BaseDlg)
function GoldBuyDlg:ctor(eType)
  GoldBuyDlg.super.ctor(self)
  self.m_uiId = eType
  self.m_bIsRequsting = false
  self:InitData(eType)
  self:InitUI()
end
function GoldBuyDlg:onEnter()
  GoldBuyDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.MallBuy, handler(self, self.BuyCallback))
  self:AddEvents()
end
function GoldBuyDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.MallBuy)
  GoldBuyDlg.super.onExit(self)
end
function GoldBuyDlg:InitData(eType)
  self.m_buyType = eType
  local vipLevel = UserDataManager:GetInstance():GetVipLevel()
  local vipInfo = CommonInfoManager:GetInstance():GetVipInfo(vipLevel)
  if self.m_buyType == td.UIModule.BuyGold then
    self.m_mallItemId = 8999
    self.totalTime = vipInfo.gold_numbers
  elseif self.m_buyType == td.UIModule.BuyForce then
    self.m_mallItemId = 9012
    self.totalTime = vipInfo.gold_numbers
  else
    self.m_mallItemId = 9000
    self.totalTime = vipInfo.vit_numbers
  end
  self.buyTime = UserDataManager:GetInstance():GetBuyTimes(self.m_buyType)
  local mallItemInfo = CommonInfoManager:GetInstance():GetMallItemInfo(self.m_mallItemId)
  self.m_baseCost = mallItemInfo.price
  self.m_gainQuantity = mallItemInfo.quantity
  self.itemInfo = td.GetItemInfo(mallItemInfo.item)
end
function GoldBuyDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/GoldBuyDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_uiBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "DlgBg")
  self.m_numBg1 = cc.uiloader:seekNodeByName(self.m_uiBg, "Image_di1")
  self.m_numBg2 = cc.uiloader:seekNodeByName(self.m_uiBg, "Image_di2")
  self.m_goldIcon = cc.uiloader:seekNodeByName(self.m_uiBg, "icon2")
  self.m_goldIcon:loadTexture(self.itemInfo.icon .. td.PNG_Suffix)
  self.m_buyBtn = cc.uiloader:seekNodeByName(self.m_uiBg, "Button_buy_6")
  local btnTxt = td.CreateLabel(g_LM:getBy("a00009"))
  btnTxt:setAnchorPoint(0.5, 0.5)
  td.AddRelaPos(self.m_buyBtn, btnTxt)
  local goldNumLabel = td.CreateLabel(self.m_gainQuantity)
  goldNumLabel:setAnchorPoint(0.5, 0.5)
  td.AddRelaPos(self.m_numBg2, goldNumLabel)
  local tipText = td.CreateLabel(string.format(g_LM:getBy("a00145"), self.itemInfo.name), cc.c3b(129, 255, 193))
  tipText:setAnchorPoint(0.5, 0.5)
  td.AddRelaPos(self.m_uiBg, tipText, 1, cc.p(0.5, 0.73))
  self.m_costNumLabel = td.CreateLabel("0")
  self.m_costNumLabel:setAnchorPoint(0.5, 0.5)
  td.AddRelaPos(self.m_numBg1, self.m_costNumLabel)
  self:UpdateUI()
end
function GoldBuyDlg:UpdateUI()
  local vipLevel = UserDataManager:GetInstance():GetVipLevel()
  local remainColor = self.buyTime > 0 and td.LIGHT_GREEN or td.RED
  if self.m_buyTimeLabel then
    self.m_buyTimeLabel:removeFromParent()
    self.m_buyTimeLabel = nil
  end
  self.m_buyTimeLabel = td.RichText({
    {
      type = 1,
      color = td.LIGHT_BLUE,
      size = 20,
      str = g_LM:getBy("a00146")
    },
    {
      type = 1,
      color = remainColor,
      size = 20,
      str = "" .. self.buyTime
    },
    {
      type = 1,
      color = td.LIGHT_BLUE,
      size = 20,
      str = "/" .. self.totalTime
    }
  })
  self.m_buyTimeLabel:setAnchorPoint(0.5, 0.5)
  td.AddRelaPos(self.m_uiBg, self.m_buyTimeLabel, 1, cc.p(0.5, 0.3))
  local costNum = self.m_baseCost + td.GetConst("exchange_add") * (self.totalTime - self.buyTime)
  self.m_costNumLabel:setString(tostring(costNum))
  if self.buyTime > 0 and costNum <= UserDataManager:GetInstance():GetDiamond() then
    td.EnableButton(self.m_buyBtn, true)
  else
    td.EnableButton(self.m_buyBtn, false)
  end
end
function GoldBuyDlg:ShowEffect()
  local pos = cc.p(self.m_goldIcon:getPosition())
  pos = self.m_goldIcon:getParent():convertToWorldSpace(pos)
  for j = 1, 6 do
    local flyIcon = require("app.widgets.FlyIcon").new(self.itemInfo.id, nil, j == 1)
    flyIcon:pos(pos.x, pos.y):scale(0.4 * td.GetAutoScale())
    flyIcon:Fly()
  end
end
function GoldBuyDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_uiBg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_uiBg, tmpPos) then
      self:performWithDelay(function()
        self:close()
      end, 0.1)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  td.BtnAddTouch(self.m_buyBtn, function()
    local bCanBuy, errorCode = self:CheckCanBuy()
    if bCanBuy then
      if not self.m_bIsRequsting then
        self:SendBuyRequest()
      end
    else
      td.alertErrorMsg(errorCode)
    end
  end, nil, td.ButtonEffectType.Long)
end
function GoldBuyDlg:CheckCanBuy()
  if self.buyTime <= 0 then
    return false, td.ErrorCode.TIME_NOT_ENOUGH
  end
  local diamond = UserDataManager:GetInstance():GetDiamond()
  local costNum = self.m_baseCost + td.GetConst("exchange_add") * (self.totalTime - self.buyTime)
  if diamond < costNum then
    return false, td.ErrorCode.DIAMOND_NOT_ENOUGH
  end
  return true
end
function GoldBuyDlg:SendBuyRequest()
  self.m_bIsRequsting = true
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.MallBuy
  Msg.sendData = {
    id = self.m_mallItemId,
    num = 1
  }
  tdRequest:Send(Msg)
end
function GoldBuyDlg:BuyCallback(data)
  if data.state == td.ResponseState.Success then
    local udMng = UserDataManager:GetInstance()
    udMng:UpdateBuyTimes(self.m_buyType)
    self.buyTime = udMng:GetBuyTimes(self.m_buyType)
    if self.m_buyType == td.UIModule.BuyStamina then
      udMng:PublicGain(td.WealthType.STAMINA, self.m_gainQuantity)
    end
    self:ShowEffect()
    self:UpdateUI()
    self.m_bIsRequsting = false
  end
end
return GoldBuyDlg
