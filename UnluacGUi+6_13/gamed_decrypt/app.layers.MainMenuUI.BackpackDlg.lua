local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local TabButton = require("app.widgets.TabButton")
local GuideManager = require("app.GuideManager")
local BackpackDlg = class("BackpackDlg", BaseDlg)
local PageItemCount = 10
local BackPackType = {
  None = 0,
  Normal = 1,
  Skill = 2,
  Weapon = 3,
  Soldier = 4,
  Gem = 5
}
function BackpackDlg:ctor()
  BackpackDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Pack
  self.m_items = {}
  self.m_uiItems = {}
  self.udMng = UserDataManager:GetInstance()
  self.m_iLoadCount = 0
  self.m_lastPageIndex = 1
  self.m_curItemType = -1
  self.m_curSelectItemIndex = nil
  self.m_totalPageCnt = 0
  self.m_isInit = false
  self:InitData()
  self:InitUI()
end
function BackpackDlg:onEnter()
  BackpackDlg.super.onEnter(self)
  self:CreateForgroundMask()
  self:AddEvents()
  self:PlayEnterAni(function()
    if GuideManager:GetInstance():IsForceGuideOver() then
      GuideManager.H_StartGuideGroup(114)
    end
    self:CheckGuide()
    self:RemoveForgroundMask()
  end)
end
function BackpackDlg:onExit()
  BackpackDlg.super.onExit(self)
end
function BackpackDlg:AddEvents()
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
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  self:AddCustomEvent(td.WEAPON_UPDATE, handler(self, self.OnItemUpdate))
  self:AddCustomEvent(td.GEM_UPDATE, handler(self, self.OnItemUpdate))
end
function BackpackDlg:InitUI()
  self:LoadUI("CCS/BackpackDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_beibao.png")
  self.m_panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_panelLeft = cc.uiloader:seekNodeByName(self.m_panel, "Panel_left")
  self.m_list_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_pageTextLabel = td.CreateLabel("0/0", td.WHITE, 18)
  self.m_pageTextLabel:setAnchorPoint(cc.p(0.5, 0.5))
  local tmpNode = self.m_list_bg:getChildByName("Image_page")
  td.AddRelaPos(tmpNode, self.m_pageTextLabel)
  local list_bg_size = self.m_list_bg:getContentSize()
  self.m_page = cc.ui.UIPageView.new({
    viewRect = cc.rect(50, 80, 800, 400),
    column = 5,
    row = 2,
    scale = self.m_scale
  })
  self.m_page:setTag(100)
  self.m_page:pos(15, 10)
  self.m_list_bg:addChild(self.m_page)
  self.m_page:onTouch(function(event)
    if event.name == "clicked" then
      td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
      self:SetItemSelect(event.itemIdx)
      td.ShowRP(cc.uiloader:seekNodeByName(event.item, "item_bg"), false)
    elseif event.name == "pageChange" then
      local curIndex = event.pageIdx
      if self.m_lastPageIndex and self.m_lastPageIndex ~= curIndex then
        self.m_pageTextLabel:setString(event.pageIdx .. "/" .. self.m_totalPageCnt)
        td.UpdatePageArrow({
          leftArrow = self.m_leftArrow,
          rightArrow = self.m_rightArrow,
          curPage = event.pageIdx,
          totalPage = self.m_totalPageCnt
        })
        self.m_lastPageIndex = event.pageIdx
      end
    end
  end)
  self.m_btmLight = cc.uiloader:seekNodeByName(self.m_panel, "Image_btmLight")
  self.m_leftArrow = cc.uiloader:seekNodeByName(self.m_uiRoot, "Arrow_left")
  self.m_rightArrow = cc.uiloader:seekNodeByName(self.m_uiRoot, "Arrow_right")
end
function BackpackDlg:PlayEnterAni(cb)
  self.m_btmLight:pos(658, 530)
  self.m_list_bg:setVisible(false)
  self.m_list_bg:setOpacity(0)
  self.m_list_bg:setVisible(true)
  self.m_list_bg:runAction(cca.fadeIn(0.3, 1))
  self.m_btmLight:runAction(cca.seq({
    cc.EaseBackOut:create(cca.moveBy(0.3, 0, -490)),
    cca.cb(function()
      self:CreateTabs()
      if cb then
        cb()
      end
    end)
  }))
end
function BackpackDlg:CreateTabs()
  local config = {
    {
      text = "\230\157\144\230\150\153",
      icon = "UI/backpack/cailiao%d_icon.png"
    },
    {
      text = "\230\138\128\232\131\189",
      icon = "UI/backpack/jineng%d_icon.png"
    },
    {
      text = "\232\163\133\229\164\135",
      icon = "UI/backpack/zhuangbei%d_icon.png"
    },
    {
      text = "\231\162\142\231\137\135",
      icon = "UI/backpack/suipian%d_icon.png"
    },
    {
      text = "\229\174\157\231\159\179",
      icon = "UI/backpack/suipian%d_icon.png"
    }
  }
  local function pressItemBtn(index)
    self.m_lastPageIndex = 1
    self.m_curSelectItemIndex = 0
    self:RefreshList(index)
    if index == 2 then
      td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    end
    td.ShowRP(self.m_tabs[index], false)
  end
  self.m_tabs = {}
  local tabButtons = {}
  for i, var in ipairs(config) do
    local _tab = ccui.ImageView:create("UI/scale9/transparent1x1.png")
    _tab:setScale9Enabled(true)
    _tab:setContentSize(cc.size(162, 74))
    _tab:align(display.LEFT_CENTER, 0, 440 - i * 85):addTo(self.m_panelLeft)
    table.insert(self.m_tabs, _tab)
    if self:CheckNewItem(i) then
      td.ShowRP(_tab, true)
    end
    local tabSpine = SkeletonUnit:create("Spine/UI_effect/UI_tujiananniu_01")
    tabSpine:pos(_tab:getPositionX() - 1, _tab:getPositionY())
    tabSpine:addTo(self.m_panelLeft)
    tabSpine:setLocalZOrder(-1)
    local tabButton = {
      tab = _tab,
      text = var.text,
      callfunc = pressItemBtn,
      normalImageSize = cc.size(162, 74),
      highImageSize = cc.size(210, 74),
      normalIconFile = string.format(var.icon, 2),
      highIconFile = string.format(var.icon, 1),
      spine = tabSpine
    }
    table.insert(tabButtons, tabButton)
  end
  local _spineInfo = {
    normalInit = "animation_01",
    focusInit = "animation_02",
    toFocus = "animation_03",
    toNormal = "animation_04",
    initTime = 1
  }
  self.m_TabButton = TabButton.new(tabButtons, {
    textSize = 24,
    normalTextColor = td.LIGHT_BLUE,
    highTextColor = td.YELLOW,
    spineInfo = _spineInfo
  })
end
function BackpackDlg:CheckNewItem(index)
  if index == BackPackType.Weapon or index == BackPackType.Gem then
    return false
  else
    for i, var in ipairs(self.m_items[index]) do
      if var.bNew then
        return true
      end
    end
  end
end
function BackpackDlg:RefreshListData(itemType)
  if self.m_curSelectItemIndex then
    if self.m_items[self.m_curItemType] and self.m_curSelectItemIndex > 0 then
      if #self.m_items[self.m_curItemType] < self.m_curSelectItemIndex then
        self.m_curSelectItemIndex = #self.m_items[self.m_curItemType]
      end
    else
      self.m_curSelectItemIndex = 0
    end
  else
    self.m_curSelectItemIndex = 0
  end
  local count = math.ceil(#self.m_items[self.m_curItemType] / PageItemCount)
  self.m_totalPageCnt = math.max(count, 1)
  td.UpdatePageArrow({
    leftArrow = self.m_leftArrow,
    rightArrow = self.m_rightArrow,
    curPage = self.m_lastPageIndex,
    totalPage = self.m_totalPageCnt
  })
end
function BackpackDlg:RefreshList(itemType)
  self:clearPageView()
  self.m_curItemType = itemType
  self:RefreshListData(itemType)
  self:CreateItems(self.m_totalPageCnt)
  self.m_pageTextLabel:setString(self.m_page:getCurPageIdx() .. "/" .. self.m_totalPageCnt)
end
function BackpackDlg:CreateItems(pageCount)
  for i = 1, PageItemCount * self.m_totalPageCnt do
    local data = self.m_items[self.m_curItemType]
    local value = data[i]
    local item = self.m_page:newItem()
    local listItem = self:MakeItem(value, self.m_curItemType)
    item:addChild(listItem)
    self.m_page:addItem(item)
    table.insert(self.m_uiItems, item)
  end
  self.m_page:reload(self.m_lastPageIndex)
end
function BackpackDlg:clearPageView()
  self.m_page:removeAllItems()
  self.m_uiItems = {}
  self.m_ItemCount = 1
  self.m_iLoadCount = 0
end
function BackpackDlg:changePage(count, num, bLeftToRight)
  self.m_page:gotoPage(count, true, bLeftToRight)
end
function BackpackDlg:MakeItem(data, type)
  local itemNode = display.newNode()
  itemNode:setContentSize(135, 165)
  itemNode:pos(67.5, 82.5)
  itemNode:setTag(11)
  local listItembg = display.newScale9Sprite("UI/backpack/wupinkuang.png", 0, 0, cc.size(135, 165), cc.rect(17, 20, 100, 4))
  listItembg:setName("item_bg")
  listItembg:setOpacity(0)
  listItembg:setScale(0.01)
  listItembg:addTo(itemNode)
  listItembg:runAction(cca.spawn({
    cc.EaseBackOut:create(cca.scaleTo(0.3, 1)),
    cca.fadeIn(0.3, 1)
  }))
  if data then
    local iconSpr, numStr
    if type == BackPackType.Weapon then
      local info = data.weaponInfo
      iconSpr = td.IconWithStar(info.icon .. td.PNG_Suffix, data.star, info.quality)
      numStr = "LV." .. data.level
    else
      iconSpr = td.CreateItemIcon(data.itemId, true)
      numStr = "x" .. data.num
      if data.bNew then
        td.ShowRP(listItembg, true)
      end
    end
    td.AddRelaPos(listItembg, iconSpr, 1, cc.p(0.5, 0.62))
    local Text_2 = td.CreateLabel(numStr, td.BLUE, 18)
    Text_2:setName("Text_num")
    td.AddRelaPos(listItembg, Text_2, 1, cc.p(0.5, 0.15))
  end
  return itemNode
end
function BackpackDlg:InitData()
  self.m_items = {
    [BackPackType.Normal] = {},
    [BackPackType.Skill] = {},
    [BackPackType.Weapon] = {},
    [BackPackType.Soldier] = {},
    [BackPackType.Gem] = {}
  }
  local allItems = self.udMng:GetAllItem()
  local key_table = {}
  for key, _ in pairs(allItems) do
    table.insert(key_table, key)
  end
  table.sort(key_table)
  for _, key in pairs(key_table) do
    local value = allItems[key]
    if value.num > 0 and 0 < value.bag_type then
      table.insert(self.m_items[value.bag_type], value)
    end
  end
  local weapons = self.udMng:GetWeaponData()
  for key, weapon in pairs(weapons) do
    if weapon.hero_id == 0 then
      table.insert(self.m_items[BackPackType.Weapon], weapon)
    end
  end
  self.m_items[BackPackType.Gem] = self.udMng:GetIdleGems()
  for key, items in pairs(self.m_items) do
    if key == BackPackType.Weapon then
      table.sort(items, function(a, b)
        return a.weaponInfo.quality * 1000 + a.star * 100 + a.level > b.weaponInfo.quality * 1000 + b.star * 100 + b.level
      end)
    else
      table.sort(items, function(a, b)
        return a.quality > b.quality
      end)
    end
  end
end
function BackpackDlg:SetItemSelect(index)
  if index <= #self.m_uiItems and self.m_items[self.m_curItemType][index] then
    if self.m_curItemType == BackPackType.Weapon then
      g_MC:OpenModule(td.UIModule.WeaponUpgrade, {
        weaponId = self.m_items[self.m_curItemType][index].id
      })
    else
      if self.m_curItemType ~= BackPackType.Gem then
        self.m_items[self.m_curItemType][index].bNew = false
        self.udMng:SetItemNew(self.m_items[self.m_curItemType][index].itemId, false)
      end
      local data = {
        itemId = self.m_items[self.m_curItemType][index].itemId,
        showType = 1
      }
      g_MC:OpenModule(td.UIModule.ItemDetail, data)
    end
  end
end
function BackpackDlg:OnItemUpdate(event)
  self:InitData()
  self:RefreshList(self.m_curItemType)
end
return BackpackDlg
