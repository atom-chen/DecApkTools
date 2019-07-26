local StrongInfoManager = require("app.info.StrongInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local ActorInfoManager = require("app.info.ActorInfoManager")
local UserDataManager = require("app.UserDataManager")
local UnitDataManager = require("app.UnitDataManager")
local scheduler = require("framework.scheduler")
local BaseDlg = require("app.layers.BaseDlg")
local AddOrMinus = {Add = 1, Minus = -1}
local UpgradeDlg = class("UpgradeDlg", BaseDlg)
function UpgradeDlg:ctor(data)
  UpgradeDlg.super.ctor(self)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_uiId = td.UIModule.UpgradeHeroOrSoldier
  self.upgradeType = 1
  self.id = nil
  self.data = nil
  self.bIsOriMax = false
  self.bIsMax = false
  self.quantity = 0
  self.quanTxt = nil
  self.choseIndex = nil
  self.m_vExpItem = {}
  self.m_adding = 0
  self:InitUI()
  self:SetData(data.type, data.id)
  self:setNodeEventEnabled(true)
end
function UpgradeDlg:onEnter()
  UpgradeDlg.super.onEnter(self)
  self.m_addingScheduler = scheduler.scheduleGlobal(handler(self, self.AddingItems), 0.1)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UpSoldiers, handler(self, self.SoldierUpgradeCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UpgradeHero_req, handler(self, self.HeroUpgradeCallback))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  self:CreateForgroundMask()
  self:performWithDelay(function()
    self:CheckGuide()
    self:AddBtnEvents()
    self:AddTouch()
    self:RemoveForgroundMask()
  end, 0.1)
end
function UpgradeDlg:onExit()
  if self.m_addingScheduler then
    scheduler.unscheduleGlobal(self.m_addingScheduler)
    self.m_addingScheduler = nil
  end
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.UpSoldiers)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.UpgradeHero_req)
  UpgradeDlg.super.onExit(self)
end
function UpgradeDlg:LoadItemData()
  local expItems = {}
  local quantities = {}
  if self.upgradeType == 1 then
    expItems = ItemInfoManager:GetInstance():GetExpItemInfos(1)
  else
    expItems = ItemInfoManager:GetInstance():GetExpItemInfos(3)
  end
  for i, var in ipairs(expItems) do
    local haveNum = self.m_udMng:GetItemNum(var.id)
    local material = {
      itemId = var.id,
      num = haveNum,
      exp = var.quantity
    }
    table.insert(quantities, var.quantity)
    table.insert(self.m_vExpItem, material)
  end
  table.sort(self.m_vExpItem, function(a, b)
    return a.exp < b.exp
  end)
  return quantities
end
function UpgradeDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/UpgradeDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local titleSpr = display.newSprite(td.Word_Path .. "wenzi_xuanzheshengjidaoju.png")
  td.AddRelaPos(self.m_bg, titleSpr, 1, cc.p(0.5, 0.9))
  self.btn_cancel = cc.uiloader:seekNodeByName(self.m_bg, "Button_cancel")
  td.BtnSetTitle(self.btn_cancel, g_LM:getBy("a00116"))
  self.btn_confirm = cc.uiloader:seekNodeByName(self.m_bg, "Button_confirm")
  td.BtnSetTitle(self.btn_confirm, g_LM:getBy("a00009"))
  self.quan_bg = cc.uiloader:seekNodeByName(self.m_bg, "Image_quantity_bg")
  self.btn_add = cc.uiloader:seekNodeByName(self.m_bg, "Button_add")
  td.CreateUIEffect(self.btn_add, "Spine/UI_effect/UI_kezhitishi_01")
  self.btn_minus = cc.uiloader:seekNodeByName(self.m_bg, "Button_minus")
  self.quanTxt = td.CreateLabel(self.quantity, td.YELLOW)
  self.expTxt = cc.uiloader:seekNodeByName(self.m_bg, "Text_exp_data")
  td.AddRelaPos(self.quan_bg, self.quanTxt)
  self.nextLevelLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_after_lvl")
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_quantity")
  label:setString(g_LM:getBy("a00392"))
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_exp")
  label:setString(g_LM:getBy("a00260") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_lvlup")
  label:setString(g_LM:getBy("a00394"))
end
function UpgradeDlg:SetData(type, id)
  self.upgradeType = type
  self.id = id
  if self.upgradeType == 1 then
    self.data = self.m_udMng:GetHeroData(self.id)
    self.bIsOriMax = self.data.level >= self.data.star * 10
  else
    self.data = UnitDataManager:GetInstance():GetSoldierData(self.id)
    self.bIsOriMax = self.data.level >= self.data.star * 10
  end
  self.bIsMax = self.bIsOriMax
  self:RefreshUI()
end
function UpgradeDlg:RefreshUI()
  local curlevelLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_curr_lvl")
  if self.bIsMax then
    curlevelLabel:setString("Max")
    self.nextLevelLabel:setString("Max")
  else
    curlevelLabel:setString(self.data.level)
    self.nextLevelLabel:setString(self.data.level)
  end
  local items = self:LoadItemData()
  local initIndex
  for i = #items, 1, -1 do
    if items[i] > 0 then
      initIndex = i
    end
  end
  self:CreateItemListView()
  if initIndex then
    self.quantity = 1
    self:OnListItemClicked(initIndex)
  end
end
function UpgradeDlg:ShowItemSource()
end
function UpgradeDlg:CreateItemListView()
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
    viewRect = cc.rect(0, 0, 342, 90),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_UIListView:setName("ListView")
  self.m_UIListView:pos(80, 270.5):addTo(self.m_bg)
  self.m_UIListView:onTouch(function(event)
    if "clicked" == event.name and event.item then
      self:OnListItemClicked(event.itemPos)
    end
  end)
  self:RefreshList()
end
function UpgradeDlg:RefreshList()
  self.m_UIListView:removeAllItems()
  for i, var in ipairs(self.m_vExpItem) do
    local item = self:CreateItem(var)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function UpgradeDlg:CreateItem(var)
  local bgSize = cc.size(85, 85)
  local itembg = display.newScale9Sprite("UI/scale9/bantoumingkuang.png", 0, 0, bgSize, cc.rect(15, 11, 15, 11))
  itembg:setName("bg")
  itembg:setScale(self.m_scale)
  local itemIcon = display.newSprite(td.GetItemIcon(var.itemId))
  td.AddRelaPos(itembg, itemIcon, 1, cc.p(0.5, 0.5))
  if 0 < var.num then
    local labelNum = cc.ui.UILabel.new({
      text = "x" .. var.num,
      font = td.DEFAULT_FONT,
      size = 18,
      color = td.WHITE
    })
    labelNum:setAnchorPoint(0.5, 0.5)
    td.AddRelaPos(itembg, labelNum, 1, cc.p(0.7, 0.2))
  else
    itemIcon:setOpacity(100)
  end
  local selSpr = display.newScale9Sprite("UI/scale9/huangse_xuanzhongkuang.png", 0, 0, cc.size(86, 86))
  selSpr:setVisible(false)
  td.AddRelaPos(itembg, selSpr)
  local item = self.m_UIListView:newItem(itembg)
  item:setItemSize((bgSize.width + 30) * self.m_scale, (bgSize.height + 5) * self.m_scale)
  item.selSpr = selSpr
  return item
end
function UpgradeDlg:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
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
    else
      local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
      if not isTouchInNode(self.m_bg, tmpPos) then
        self:performWithDelay(function()
          self:close()
        end, 0.1)
        bResult = false
      end
      self.m_bIsTouchInList = false
    end
    return bResult
  end, cc.Handler.EVENT_TOUCH_BEGAN)
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
function UpgradeDlg:OnListItemClicked(index)
  if self.choseIndex == index then
    return
  end
  if self.choseIndex then
    local lastItem = self.m_UIListView:getItemByPos(self.choseIndex)
    lastItem.selSpr:setVisible(false)
  end
  self.choseIndex = index
  self:ModifyQuantity(-self.quantity)
  local choseItem = self.m_vExpItem[index]
  if choseItem.num > 0 and not self.bIsMax then
    self:ModifyQuantity(1)
  end
  local pItem = self.m_UIListView:getItemByPos(index)
  pItem.selSpr:setVisible(true)
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
end
function UpgradeDlg:AddBtnEvents()
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
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    if self.quantity > 0 then
      local choseItem = self.m_vExpItem[self.choseIndex]
      if self.upgradeType == 1 then
        local data = {
          id = self.id,
          item_id = choseItem.itemId,
          item_num = self.quantity
        }
        self:SendUpgradeRequest(td.RequestID.UpgradeHero_req, data)
      else
        local data = {
          role_id = self.id,
          item_id = choseItem.itemId,
          item_num = self.quantity
        }
        self:SendUpgradeRequest(td.RequestID.UpSoldiers, data)
      end
    end
  end, nil, td.ButtonEffectType.Long)
  td.BtnAddTouch(self.btn_cancel, function()
    self:close()
  end)
end
function UpgradeDlg:AddingItems()
  if self.choseIndex and self.m_adding ~= 0 and self:CheckQuantity(self.m_adding) then
    self:ModifyQuantity(self.m_adding)
  end
end
function UpgradeDlg:ModifyQuantity(variation)
  self.quantity = self.quantity + variation
  self.quanTxt:setString(self.quantity)
  self.expTxt:setString(self.m_vExpItem[self.choseIndex].exp * self.quantity)
  local nextLevel, bMax = self:CalNextLevel()
  self.bIsMax = bMax
  if self.bIsMax then
    self.nextLevelLabel:setString("Max")
  else
    self.nextLevelLabel:setString(nextLevel)
  end
end
function UpgradeDlg:CheckQuantity(addOrMinus)
  local canClick = false
  local choseItem = self.m_vExpItem[self.choseIndex]
  if addOrMinus == AddOrMinus.Add then
    if choseItem.num > self.quantity and not self.bIsMax then
      canClick = true
    end
  elseif addOrMinus == AddOrMinus.Minus and self.quantity >= 1 then
    canClick = true
  end
  return canClick
end
function UpgradeDlg:CalNextLevel()
  local nextLevel, bIsMax = self.data.level, false
  if self.bIsOriMax then
    return nextLevel, true
  end
  local totalExp = self.m_vExpItem[self.choseIndex].exp * self.quantity + self.data.exp
  if self.upgradeType == 1 then
    local needExp = td.CalHeroExp(nextLevel)
    repeat
      while totalExp >= needExp do
        totalExp = totalExp - needExp
        nextLevel = nextLevel + 1
        needExp = td.CalHeroExp(nextLevel)
        bIsMax = true
        break
      end
    until nextLevel >= self.data.star * 10
  else
    local needExp = td.CalSoldierExp(self.data.star, nextLevel, self.data.quality)
    while totalExp >= needExp do
      totalExp = totalExp - needExp
      nextLevel = nextLevel + 1
      needExp = td.CalSoldierExp(self.data.star, nextLevel, self.data.quality)
      if nextLevel >= self.data.star * 10 then
        bIsMax = true
        break
      end
    end
  end
  return nextLevel, bIsMax
end
function UpgradeDlg:SendUpgradeRequest(msgType, data)
  local Msg = {}
  Msg.msgType = msgType
  Msg.sendData = data
  Msg.cbData = {
    id = self.id,
    exp = self.m_vExpItem[self.choseIndex].exp * self.quantity
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function UpgradeDlg:SoldierUpgradeCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    local soldierData = UnitDataManager:GetInstance():GetSoldierData(cbData.id)
    StrongInfoManager:GetInstance():UpdateSoldierData(cbData.id, cbData.exp)
    td.dispatchEvent(td.SOLDIER_UPGRADE, 1)
    self:close()
  end
end
function UpgradeDlg:HeroUpgradeCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    UserDataManager:GetInstance():UpdateHeroLevelOrStar(cbData.id, cbData.exp)
    td.dispatchEvent(td.HERO_UPGRADE)
    self:close()
  end
end
return UpgradeDlg
