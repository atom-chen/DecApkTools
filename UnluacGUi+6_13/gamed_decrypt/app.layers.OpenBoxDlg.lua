local BaseDlg = require("app.layers.BaseDlg")
local ItemInfoManager = require("app.info.ItemInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local UserDataManager = require("app.UserDataManager")
local OpenBoxDlg = class("OpenBoxDlg", BaseDlg)
function OpenBoxDlg:ctor(items)
  OpenBoxDlg.super.ctor(self, false, 255)
  self.m_allItemsShow = false
  self.m_showingAll = false
  self.m_curIndex = 1
  self.m_items = items
  self.m_shownItems = {}
  self.bWeapon = false
  self.bGem = false
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function OpenBoxDlg:onEnter()
  OpenBoxDlg.super.onEnter(self)
  self:AddTouch()
  if self.bWeapon then
    UserDataManager:GetInstance():SendGetWeaponRequest()
  end
  if self.bGem then
    UserDataManager:GetInstance():SendGetGemRequest()
  end
end
function OpenBoxDlg:onExit()
  OpenBoxDlg.super.onExit(self)
end
function OpenBoxDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/OpenBoxDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.m_itemsBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_items")
  self:GenerateItems()
  self:ShowItems()
end
function OpenBoxDlg:GenerateItems()
  for key, item in ipairs(self.m_items) do
    local itemInfoMng = ItemInfoManager:GetInstance()
    local strongInfoMng = StrongInfoManager:GetInstance()
    local itemId = item.itemId
    local num = item.num
    local info, iconSpr
    if itemId > 80000 then
      self.bGem = true
      info = strongInfoMng:GetGemInfo(itemId)
      iconSpr = td.CreateItemIcon(itemId, true)
    elseif itemId < 20000 then
      self.bWeapon = true
      info = strongInfoMng:GetWeaponInfo(itemId)
      iconSpr = td.CreateWeaponIcon(itemId, 1)
    else
      info = itemInfoMng:GetItemInfo(itemId)
      iconSpr = td.CreateItemIcon(itemId, true)
    end
    item.info = info
    iconSpr:scale(0.01)
    td.AddRelaPos(self.m_itemsBg, iconSpr)
    local labelName = td.CreateLabel(info.name, td.WHITE, 20)
    labelName:setAnchorPoint(0.5, 0.5)
    td.AddRelaPos(iconSpr, labelName, 1, cc.p(0.5, 1.2))
    local labelNum = td.CreateLabel("x" .. num, td.WHITE, 20)
    labelNum:setAnchorPoint(0.5, 0.5)
    td.AddRelaPos(iconSpr, labelNum, 1, cc.p(0.5, -0.2))
    table.insert(self.m_shownItems, {
      itemId = item.itemId,
      quality = info.quality,
      icon = iconSpr
    })
  end
end
function OpenBoxDlg:ShowItems()
  if self.m_curIndex <= #self.m_items and #self.m_items > 1 then
    G_SoundUtil:PlaySound(68)
    do
      local item = self.m_shownItems[self.m_curIndex]
      local iconSpr = item.icon
      local effect
      if item.quality == 2 then
        effect = td.CreateUIEffect(iconSpr, "Spine/UI_effect/UI_iconchuxian_lv", {scale = 2})
      elseif item.quality == 3 then
        effect = td.CreateUIEffect(iconSpr, "Spine/UI_effect/UI_iconchuxian_lan", {scale = 2})
      elseif item.quality == 4 then
        effect = td.CreateUIEffect(iconSpr, "Spine/UI_effect/UI_iconchuxian_zi", {scale = 2})
      elseif item.quality == 5 then
        effect = td.CreateUIEffect(iconSpr, "Spine/UI_effect/UI_iconchuxian_huang", {scale = 2})
      end
      iconSpr:runAction(cca.seq({
        cc.EaseBackOut:create(cca.scaleTo(0.4, 1)),
        cca.delay(0.6),
        cca.cb(function()
          iconSpr:setScale(0)
          self.m_curIndex = self.m_curIndex + 1
          self:ShowItems()
        end)
      }))
    end
  else
    self:ShowAllItems()
  end
end
function OpenBoxDlg:ShowAllItems()
  table.sort(self.m_shownItems, function(a, b)
    return a.quality > b.quality
  end)
  self.m_showingAll = true
  self:performWithDelay(function()
    self.m_allItemsShow = true
  end, 0.2 + 0.15 * #self.m_items)
  G_SoundUtil:PlaySound(68)
  for key, item in ipairs(self.m_shownItems) do
    local num = #self.m_shownItems >= 5 and 5 or #self.m_shownItems
    local width = item.icon:getContentSize().width
    local offset = (700 - width * (num - 1)) / (num - 1 + 2)
    local constEffect
    if item.quality == 2 then
      constEffect = SkeletonUnit:create("Spine/UI_effect/UI_iconbeijing_lv")
      constEffect:PlayAni("animation", true)
    elseif item.quality == 3 then
      constEffect = SkeletonUnit:create("Spine/UI_effect/UI_iconbeijing_lan")
      constEffect:PlayAni("animation", true)
    elseif item.quality == 4 then
      constEffect = SkeletonUnit:create("Spine/UI_effect/UI_iconbeijing_zi")
      constEffect:PlayAni("animation", true)
    elseif item.quality == 5 then
      constEffect = SkeletonUnit:create("Spine/UI_effect/UI_iconbeijing_huang")
      constEffect:PlayAni("animation", true)
    end
    if constEffect then
      constEffect:setScale(0.8)
      td.AddRelaPos(item.icon, constEffect, -10)
    end
    if key <= 5 then
      local posX = (key - 1) * width + key * offset + 50
      item.icon:pos(posX, 250)
      item.icon:runAction(cca.seq({
        cca.delay(key * 0.15),
        cc.EaseBackOut:create(cca.scaleTo(0.2, 1))
      }))
    else
      local posX = (key - 6) * width + (key - 5) * offset + 50
      item.icon:pos(posX, 50)
      item.icon:runAction(cca.seq({
        cca.delay(key * 0.1),
        cc.EaseBackOut:create(cca.scaleTo(0.15, 1))
      }))
    end
  end
end
function OpenBoxDlg:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_allItemsShow then
      self:performWithDelay(function()
        self:close()
      end, 0.1)
      return true
    elseif not self.m_showingAll and self.m_curIndex < #self.m_items then
      self.m_shownItems[self.m_curIndex].icon:stopAllActions()
      self.m_shownItems[self.m_curIndex].icon:scale(0)
      self.m_curIndex = self.m_curIndex + 1
      self:ShowItems()
    elseif not self.m_showingAll and self.m_curIndex >= #self.m_items then
      self.m_shownItems[self.m_curIndex].icon:stopAllActions()
      self.m_shownItems[self.m_curIndex].icon:scale(0)
      self:ShowAllItems()
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
return OpenBoxDlg
