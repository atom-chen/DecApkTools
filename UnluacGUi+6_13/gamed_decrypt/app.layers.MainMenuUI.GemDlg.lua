local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local TouchIcon = require("app.widgets.TouchIcon")
local GemDlg = class("GemDlg", BaseDlg)
local OpType = {Info = 0, Replace = 1}
local Item_Size = cc.size(300, 100)
function GemDlg:ctor(data)
  GemDlg.super.ctor(self)
  self.m_uiId = td.UIModule.Gem
  self.m_siMng = StrongInfoManager:GetInstance()
  self.m_iiMng = ItemInfoManager:GetInstance()
  self.m_udMng = UserDataManager:GetInstance()
  self.m_opType = OpType.Info
  self.m_vProLabel = {}
  self.m_data = nil
  self.m_repData = nil
  self.isAdding = false
  self.m_bActionOver = false
  self:InitUI()
  self:SetData(data)
end
function GemDlg:onEnter()
  GemDlg.super.onEnter(self)
  self:AddHttpListener()
  self:AddEvent()
  if self.m_heroData then
    self:PlayEnterAni(function()
      if self.m_data then
        self:ShowInfo()
      else
        self:ShowWeapons()
      end
    end)
  else
    self:PlayEnterAni(function()
      self:ShowInfo()
    end)
  end
end
function GemDlg:MoveBgs()
  local posX, posY = self.m_bg1:getPosition()
  self.m_bg1:pos(posX - 182.5, posY)
  self.m_bg2:setOpacity(255)
end
function GemDlg:onExit()
  self:RemoveHttpListener()
  GemDlg.super.onExit(self)
end
function GemDlg:PlayEnterAni(cb)
  local t = 0.5
  if not self.m_bg2:isVisible() then
    self.m_bg1:runAction(cca.seq({
      cca.moveBy(t, -182.5, 0),
      cca.cb(function()
        local spineInfo = {
          pos = cc.p(self.m_bg2:getPositionX() + self.m_bg2:getContentSize().width / 2, self.m_bg2:getPositionY())
        }
        local effect = td.CreateUIEffect(self.m_panelBg, "Spine/UI_effect/UI_zhuangbeitanchu_01", spineInfo)
      end)
    }))
    self.m_bg2:setVisible(true)
    self.m_bg2:runAction(cca.seq({
      cca.delay(t),
      cca.fadeIn(t),
      cca.cb(function()
        cb()
        self.m_bActionOver = true
      end)
    }))
  elseif cb then
    cb()
    self.m_bActionOver = true
  end
end
function GemDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/GemDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self:AddCloseTip()
  self.m_panelBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.m_bg1 = cc.uiloader:seekNodeByName(self.m_panelBg, "Image_bg1")
  self.m_weaponBg = cc.uiloader:seekNodeByName(self.m_bg1, "Image_1")
  self.m_bg2 = cc.uiloader:seekNodeByName(self.m_panelBg, "Image_bg2")
  self.m_panelInfo = cc.uiloader:seekNodeByName(self.m_bg2, "Panel_info")
  self.m_panelSkill = cc.uiloader:seekNodeByName(self.m_panelInfo, "Panel_skill")
  self.m_panelRep = cc.uiloader:seekNodeByName(self.m_bg2, "Panel_rep")
  self.m_nameLabel = cc.uiloader:seekNodeByName(self.m_bg1, "Text_name")
  self.m_descLabel = cc.uiloader:seekNodeByName(self.m_bg2, "Text_desc")
  self.m_replaceBtn = cc.uiloader:seekNodeByName(self.m_bg2, "Button_replace")
  td.BtnAddTouch(self.m_replaceBtn, handler(self, self.ShowWeapons))
  td.BtnSetTitle(self.m_replaceBtn, g_LM:getBy("a00235"))
  self.m_btnYes = cc.uiloader:seekNodeByName(self.m_bg2, "Button_yes_4")
  td.BtnAddTouch(self.m_btnYes, handler(self, self.OnYesBtnClicked), nil, td.ButtonEffectType.Short)
  self.m_btnBack = cc.uiloader:seekNodeByName(self.m_bg2, "Button_back")
  td.BtnAddTouch(self.m_btnBack, handler(self, self.ShowInfo))
  td.BtnSetTitle(self.m_btnBack, g_LM:getBy("a00240"))
end
function GemDlg:CreateListView()
  if self.m_UIListView then
    return
  end
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(20, 80, Item_Size.width, 350),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_UIListView:onTouch(function(event)
    if event.name == "clicked" and event.item then
      local itemSize = event.item:getContentSize()
      local insideIndex = math.ceil(event.point.x / (itemSize.width / 3))
      self:OnGemClicked(event.itemPos, insideIndex)
    end
  end)
  self.m_UIListView:setName("ListView")
  self.m_UIListView:addTo(self.m_panelRep)
end
function GemDlg:RefreshUI()
  if self.m_icon and not self.m_info then
    self.m_icon:removeFromParent()
    self.m_icon = nil
  end
  for i, label in ipairs(self.m_vProLabel) do
    label:removeFromParent()
  end
  self.m_vProLabel = {}
  if self.m_data then
    local gemInfo = self.m_siMng:GetGemInfo(self.m_data.gemstoneId)
    self.m_nameLabel:setString(gemInfo.name)
    self.m_descLabel:setString(gemInfo.desc)
    self.m_icon = td.CreateItemIcon(self.m_data.gemstoneId, true)
    self.m_icon:setScale(0.75)
    td.AddRelaPos(self.m_weaponBg, self.m_icon, 1, cc.p(0.5, 0.5))
    local count = 0
    for type, var in pairs(gemInfo.property) do
      local typeLabel, valueLabel = td.GetWeaponPropLabel(type, var)
      typeLabel:align(display.LEFT_CENTER, 40 + count * 265, 120):addTo(self.m_bg1)
      valueLabel:align(display.LEFT_CENTER, 90 + count * 265, 120):addTo(self.m_bg1)
      table.insert(self.m_vProLabel, typeLabel)
      table.insert(self.m_vProLabel, valueLabel)
      count = count + 1
    end
  elseif not self.m_info then
    self.m_icon = display.newSprite("UI/hero/jia_icon.png")
    td.AddRelaPos(self.m_weaponBg, self.m_icon)
    self.m_nameLabel:setString("")
    self.m_descLabel:setString("")
    self.m_panelSkill:setVisible(false)
  end
end
function GemDlg:RefreshReplaceUI(bAni)
  if not self.m_repData then
    return
  end
  self.m_icon:removeFromParent()
  self.m_icon = nil
  for i, label in ipairs(self.m_vProLabel) do
    label:removeFromParent()
  end
  self.m_vProLabel = {}
  local gemInfo = self.m_siMng:GetGemInfo(self.m_repData.itemId)
  self.m_nameLabel:setString(gemInfo.name)
  self.m_descLabel:setString(gemInfo.desc)
  self.m_icon = td.CreateItemIcon(self.m_repData.itemId, true)
  self.m_icon:setScale(0.75)
  td.AddRelaPos(self.m_weaponBg, self.m_icon, 1, cc.p(0.5, 0.5))
  local proTypes = table.keys(gemInfo.property)
  local oriGemInfo
  if self.m_data then
    oriGemInfo = self.m_siMng:GetGemInfo(self.m_data.gemstoneId)
    for key, var in pairs(oriGemInfo.property) do
      table.insert(proTypes, key)
    end
    proTypes = table.unique(proTypes)
  end
  local count = 0
  for i, proType in ipairs(proTypes) do
    local oriValue = 0
    oriValue = oriGemInfo and (oriGemInfo.property[proType] or 0)
    local value = gemInfo.property[proType] or 0
    local typeLabel, valueLabel = td.GetWeaponPropLabel(proType, value, value - oriValue)
    typeLabel:align(display.LEFT_CENTER, 40 + count * 200, 120):addTo(self.m_bg1)
    valueLabel:align(display.LEFT_CENTER, 90 + count * 200, 120):addTo(self.m_bg1)
    table.insert(self.m_vProLabel, typeLabel)
    table.insert(self.m_vProLabel, valueLabel)
    count = count + 1
  end
end
function GemDlg:SetData(data)
  self.m_heroData = data.heroData or self.m_heroData
  self.m_slotId = data.slotId or self.m_slotId
  self.m_type = self.m_slotId % 2 == 1 and td.WeaponType.Weapon or td.WeaponType.Armor
  self.m_data = self.m_udMng:GetGemData(self.m_heroData.gems[self.m_slotId])
  if self.m_data then
    self.m_info = self.m_siMng:GetWeaponInfo(self.m_data.gemstoneId)
  end
end
function GemDlg:ClearRightBg(cb)
  if self.m_UIListView then
    self.m_UIListView:removeFromParent()
    self.m_UIListView = nil
  end
  self.m_panelRep:setVisible(false)
  self.m_panelInfo:setVisible(false)
  self.m_repData = nil
  self:PlayEnterAni(cb)
  self:RefreshUI()
end
function GemDlg:ShowInfo()
  self.m_opType = OpType.Info
  local function showInfo()
    self.m_panelInfo:setVisible(true)
    if self.m_info then
      self.m_nameLabel:setString(self.m_info.name)
      self.m_descLabel:setString(self.m_info.desc)
      self:RefreshSkill(self.m_info.skill)
      self.m_icon = td.CreateItemIcon(self.m_info.id, true)
      self.m_icon:setScale(0.75)
      td.AddRelaPos(self.m_weaponBg, self.m_icon, 1, cc.p(0.5, 0.5))
      local count = 0
      for type, var in pairs(self.m_info.property[1]) do
        local typeLabel, valueLabel = td.GetWeaponPropLabel(type, var)
        typeLabel:align(display.LEFT_CENTER, 40 + count * 200, 120):addTo(self.m_bg1)
        valueLabel:align(display.LEFT_CENTER, 90 + count * 200, 120):addTo(self.m_bg1)
        count = count + 1
      end
    end
  end
  self:ClearRightBg(handler(self, showInfo))
end
function GemDlg:ShowWeapons()
  local function showWeapons()
    self.m_panelInfo:setVisible(false)
    self.m_panelRep:setVisible(true)
    if self.m_data then
      self.m_btnBack:setDisable(false)
    else
      self.m_btnBack:setDisable(true)
    end
    self:CreateListView()
    self:RefreshGemList()
  end
  self:ClearRightBg(handler(self, showWeapons))
end
function GemDlg:RefreshGemList()
  self.m_UIListView:removeAllItems()
  self.m_selIconSpr = nil
  self.m_vGemsData = self.m_udMng:GetIdleGems(self.m_type)
  local itemCount = math.ceil((table.nums(self.m_vGemsData) + 1) / 3)
  for i = 1, itemCount do
    local item = self:CreateItem(self.m_vGemsData, i)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
  self:OnGemClicked(1, 1)
end
function GemDlg:CreateItem(datas, pos)
  local content = display.newNode()
  content:scale(self.m_scale)
  content:setContentSize(Item_Size)
  for i = 1, 3 do
    local iconBg = display.newSprite("UI/scale9/wupingdikuang.png")
    iconBg:setScale(0.8, 0.8)
    iconBg:setTag(i)
    iconBg:align(display.LEFT_BOTTOM, 10 + 95 * (i - 1), 0):addTo(content)
    local idx = (pos - 1) * 3 + i - 1
    local iconSpr
    if pos == 1 and i == 1 then
      if self.m_data then
        local gemInfo = StrongInfoManager:GetInstance():GetGemInfo(self.m_data.gemstoneId)
        iconSpr = td.CreateItemIcon(self.m_data.gemstoneId, true)
        iconSpr:scale(0.8)
      else
        iconSpr = display.newSprite("UI/hero/jia_icon.png")
      end
      iconSpr:setTag(1)
      td.AddRelaPos(iconBg, iconSpr, 1, cc.p(0.5, 0.55))
    elseif datas[idx] then
      local iconSpr = td.CreateItemIcon(datas[idx].itemId, true)
      iconSpr:scale(0.8)
      iconSpr:setTag(1)
      td.AddRelaPos(iconBg, iconSpr, 1, cc.p(0.5, 0.55))
      local numLabel = td.CreateLabel(datas[idx].num)
      td.AddRelaPos(iconBg, numLabel, 1, cc.p(0.5, 0.1))
    end
    local selSpr = display.newSprite("UI/common/huangse_xuanzhongkuang.png")
    selSpr:setVisible(false)
    selSpr:setName("selSpr")
    td.AddRelaPos(iconBg, selSpr)
    selSpr:setLocalZOrder(1)
  end
  local item = self.m_UIListView:newItem(content)
  item:setItemSize(Item_Size.width * self.m_scale, Item_Size.height * self.m_scale)
  return item
end
function GemDlg:OnGemClicked(itemPos, insideIndex)
  td.EnableButton(self.m_btnYes, true)
  local item = self.m_UIListView:getItemByPos(itemPos)
  local clickIndex = insideIndex
  local iconSpr = item:getContent():getChildByTag(clickIndex)
  local cellIndex = (itemPos - 1) * 3 + clickIndex - 1
  if iconSpr then
    if self.m_selIconSpr then
      self.m_selIconSpr:getChildByName("selSpr"):setVisible(false)
    end
    iconSpr:getChildByName("selSpr"):setVisible(true)
    self.m_selIconSpr = iconSpr
    self.m_repData = self.m_vGemsData[cellIndex]
  end
  if cellIndex == 0 then
    td.BtnSetTitle(self.m_btnYes, g_LM:getBy("a00096"))
    if self.m_data then
      self.m_btnYes:setDisable(false)
    else
      self.m_btnYes:setDisable(true)
    end
    self:RefreshUI(self.m_data)
  else
    td.BtnSetTitle(self.m_btnYes, g_LM:getBy("a00086"))
    if self.m_repData then
      self.m_btnYes:setDisable(false)
      self:RefreshReplaceUI()
    else
      self.m_btnYes:setDisable(true)
    end
  end
end
function GemDlg:OnYesBtnClicked()
  if self.m_repData then
    local uid = self.m_udMng:GetCostGemUid(self.m_repData.itemId, 1)[1]
    if uid then
      self:SendEquipRequest(uid, 1)
    else
      td.alertErrorMsg(td.ErrorCode.NOT_EXIST_GEM)
    end
  elseif self.m_data then
    self:SendEquipRequest(self.m_data.id, 0)
  end
end
function GemDlg:AddEvent()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if not self.m_bActionOver then
      return true
    end
    if self.m_UIListView then
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
        self.m_bTouchInList = true
      end
    else
      local tmpPos, bg
      if self.m_bg2:isVisible() then
        bg = self.m_panelBg
      else
        bg = self.m_bg1
      end
      tmpPos = bg:convertToNodeSpace(touch:getLocation())
      if not isTouchInNode(bg, tmpPos) then
        self:performWithDelay(function()
          self:close()
        end, 0.1)
      end
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bTouchInList then
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
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bTouchInList then
      self.m_UIListView:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
      self.m_bTouchInList = false
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function GemDlg:AddHttpListener()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.EquipGem, handler(self, self.EquipCallback))
end
function GemDlg:RemoveHttpListener()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.EquipGem)
end
function GemDlg:SendEquipRequest(wid, _type)
  local Msg = {}
  Msg.msgType = td.RequestID.EquipGem
  Msg.sendData = {
    hero_id = self.m_heroData.id,
    id = wid,
    type = _type,
    index = self.m_slotId
  }
  Msg.cbData = clone(Msg.sendData)
  TDHttpRequest:getInstance():Send(Msg)
end
function GemDlg:EquipCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    if cbData.type == 0 then
      self.m_data.hero_id = 0
      self.m_heroData.gems[self.m_slotId] = 0
      self:SetData({gemstoneId = 0})
    else
      if self.m_data then
        self.m_data.hero_id = 0
      end
      self.m_heroData.gems[self.m_slotId] = cbData.id
      local newData = self.m_udMng:GetGemData(cbData.id)
      newData.hero_id = self.m_heroData.id
      self:SetData({
        gemstoneId = cbData.id
      })
    end
    self:RefreshUI()
    self:RefreshGemList()
    td.dispatchEvent(td.HERO_GEM_UPDATE)
    self.m_udMng:UpdateTotalPower()
  end
end
return GemDlg
