local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local TabButton = require("app.widgets.TabButton")
local UserDataManager = require("app.UserDataManager")
local CommanderInfoManager = require("app.info.CommanderInfoManager")
local GameDataManager = require("app.GameDataManager")
local MessageBoxDlg = require("app.layers.MessageBoxDlg")
local ItemInfoManager = require("app.info.ItemInfoManager")
local FriendDlg = class("FriendDlg", BaseDlg)
local TabIndex = {
  MyFriend = 1,
  Recommend = 2,
  Application = 3,
  Donation = 4
}
function FriendDlg:ctor()
  FriendDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Friend
  self.m_udMng = UserDataManager:GetInstance()
  self.m_friendData = self.m_udMng:GetFriendData()
  self.m_donationId = nil
  self.m_currPanelIndex = TabIndex.MyFriend
  self.m_refreshIndex = TabIndex.MyFriend
  self.m_panels = {}
  self.m_panelLists = {}
  self.m_tabs = {}
  self.m_isPanelsInit = {
    false,
    false,
    false,
    false
  }
  self.m_isAskingDonation = false
  self:InitUI()
end
function FriendDlg:onEnter()
  FriendDlg.super.onEnter(self)
  self:AddHttpListeners()
  self:AddEvents()
  self:CheckGuide()
  self:CheckAssisted()
end
function FriendDlg:onExit()
  self:RemoveHttpListeners()
  FriendDlg.super.onExit(self)
end
function FriendDlg:AddHttpListeners()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.MFriend_req, handler(self, self.UpdateFriendCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.SearchPlayer, handler(self, self.SearchFriendCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetPlayerAreanaInfo, handler(self, self.FriendFightCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.DoAssist, handler(self, self.DonateCallback))
end
function FriendDlg:RemoveHttpListeners()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.MFriend_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.SearchPlayer)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetPlayerAreanaInfo)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.DoAssist)
end
function FriendDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  for i = 1, #self.m_panelLists do
    do
      local listener = cc.EventListenerTouchOneByOne:create()
      listener:setSwallowTouches(true)
      listener:registerScriptHandler(function(touch, event)
        if td.IsVisible(self.m_panelLists[i]) then
          if self.m_panelLists[i]:isTouchInViewRect({
            x = touch:getLocation().x,
            y = touch:getLocation().y
          }) then
            return self.m_panelLists[i]:onTouch_({
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
        if self.m_panelLists[i]:isTouchInViewRect({
          x = touch:getLocation().x,
          y = touch:getLocation().y
        }) then
          self.m_panelLists[i]:onTouch_({
            name = "moved",
            x = touch:getLocation().x,
            y = touch:getLocation().y,
            prevX = touch:getPreviousLocation().x,
            prevY = touch:getPreviousLocation().y
          })
        end
      end, cc.Handler.EVENT_TOUCH_MOVED)
      listener:registerScriptHandler(function(touch, event)
        self.m_panelLists[i]:onTouch_({
          name = "ended",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
      end, cc.Handler.EVENT_TOUCH_ENDED)
      eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
    end
  end
  self:AddCustomEvent(td.FRIEND_DATA_INITED, function(event)
    self.m_friendData = self.m_udMng:GetFriendData()
    self:UpdatePanels(self.m_currPanelIndex)
  end)
  self:AddCustomEvent(td.SEARCH_FRIEND, handler(self, self.SendSearchRequest))
  self:AddCustomEvent(td.DONATE_FRIEND, handler(self, self.RequestDonationCallback))
  self:AddCustomEvent(td.UPDATE_ASSIST, handler(self, self.UpdateMyQuest))
  self:AddCustomEvent(td.CHOSE_DONATE_ITEM, function()
    local myInfo = cc.uiloader:seekNodeByName(self.m_panels[TabIndex.Donation], "Image_my_info_bg")
    td.CreateUIEffect(myInfo, "Spine/UI_effect/EFT_haoyouzhiyuan_01")
    self:UpdatePanels(self.m_currPanelIndex)
  end)
end
function FriendDlg:InitUI()
  self:LoadUI("CCS/FriendDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_haoyou.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_panelLeft = cc.uiloader:seekNodeByName(self.m_bg, "Panel_left")
  self:GetPanels()
  self.m_buttonRefresh = cc.uiloader:seekNodeByName(self.m_panels[TabIndex.Recommend], "Button_refresh")
  td.BtnSetTitle(self.m_buttonRefresh, g_LM:getBy("a00264"))
  td.BtnAddTouch(self.m_buttonRefresh, handler(self, self.RefreshRcmdList), nil, 1)
  self.m_buttonSearch = cc.uiloader:seekNodeByName(self.m_panels[TabIndex.Recommend], "Button_search")
  td.BtnSetTitle(self.m_buttonSearch, g_LM:getBy("a00259"))
  td.BtnAddTouch(self.m_buttonSearch, handler(self, self.Search), nil, 1)
  self.m_btnStore = cc.uiloader:seekNodeByName(self.m_bg, "Button_store")
  td.BtnAddTouch(self.m_btnStore, function()
    g_MC:OpenModule(td.UIModule.Store, {type = 1}, {2})
  end)
  self.m_btnStore:setPressedActionEnabled(true)
  self.m_noteIcon = cc.uiloader:seekNodeByName(self.m_bg, "Image_frndNote")
  self.m_noteNum = cc.uiloader:seekNodeByName(self.m_bg, "Text_noteNum")
  self.m_frndLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_friend")
  self.m_frndLabel:setString(g_LM:getBy("a00190") .. ": ")
  self.m_frndNum = cc.uiloader:seekNodeByName(self.m_bg, "Text_frndNum")
  self:CreateLists()
  self:CreateTabs()
end
function FriendDlg:GetPanels()
  for i = 1, 4 do
    table.insert(self.m_panels, cc.uiloader:seekNodeByName(self.m_bg, "Panel_" .. i))
  end
end
function FriendDlg:PlayEnterAnim(index)
  local btmLight = self.m_panels[index]:getChildByName("Image_btmLight")
  local panelBg = self.m_panels[index]:getChildByName("bg")
  if index == 4 and not g_MC:IsModuleUnlock(td.UIModule.FriendAssist) then
    panelBg = self.m_panels[index]:getChildByName("bg_lock")
  end
  btmLight:runAction(cca.seq({
    cc.EaseBackOut:create(cca.moveTo(0.3, 440, 13)),
    cca.cb(function()
      panelBg:runAction(cca.fadeIn(0.2, 1))
    end)
  }))
end
function FriendDlg:CreateTabs()
  local tabButtons = {}
  local iconConfig = {
    "UI/friend/haoyou%d_icon.png",
    "UI/friend/tuijian%d_icon.png",
    "UI/friend/shenqing%d_icon.png",
    "UI/friend/zhiyuan%d_icon.png"
  }
  local tabTexts = {
    g_LM:getBy("a00190"),
    g_LM:getBy("a00265"),
    g_LM:getBy("a00266"),
    g_LM:getBy("a00267")
  }
  for i = 1, 4 do
    local _tab = cc.uiloader:seekNodeByName(self.m_panelLeft, "Tab_" .. i)
    table.insert(self.m_tabs, _tab)
    local tabSpine = SkeletonUnit:create("Spine/UI_effect/UI_tujiananniu_01")
    tabSpine:pos(_tab:getPositionX() - 1, _tab:getPositionY() + 37)
    tabSpine:addTo(self.m_panelLeft)
    tabSpine:setLocalZOrder(-1)
    local tabButton = {
      tab = _tab,
      callfunc = handler(self, self.UpdatePanels),
      normalImageSize = cc.size(162, 74),
      highImageSize = cc.size(210, 74),
      normalIconFile = string.format(iconConfig[i], 2),
      highIconFile = string.format(iconConfig[i], 1),
      spine = tabSpine,
      text = tabTexts[i]
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
  local tabs = TabButton.new(tabButtons, {
    textSize = 24,
    normalTextColor = td.LIGHT_BLUE,
    highTextColor = td.YELLOW,
    spineInfo = _spineInfo
  })
  local length = table.nums(self.m_friendData[td.FriendType.Apply])
  if length > 0 then
    td.ShowRP(self.m_tabs[TabIndex.Application], true)
  end
end
function FriendDlg:UpdateFrndNum()
  local num
  if self.m_friendData[td.FriendType.Mine] then
    local data = self.m_friendData[td.FriendType.Mine]
    num = table.nums(data)
  else
    num = 0
  end
  self.m_frndNum:setString(string.format("%d/%d", num, td.MAX_FRIEND_NUM))
end
function FriendDlg:CreateLists()
  local listRects = {
    cc.rect(0, 0, 880, 495),
    cc.rect(0, 0, 880, 435),
    cc.rect(0, 0, 880, 495),
    cc.rect(0, 0, 880, 395)
  }
  for i = 1, 4 do
    local panelList = cc.ui.UIListView.new({
      direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
      viewRect = listRects[i],
      touchOnContent = false,
      scale = td.GetAutoScale()
    })
    local panelBg = self.m_panels[i]:getChildByName("bg")
    panelList:pos(0, 2):addTo(panelBg)
    table.insert(self.m_panelLists, panelList)
  end
end
function FriendDlg:UpdatePanels(index)
  td.ShowRP(self.m_tabs[index], false)
  self.m_currPanelIndex = index
  if index == TabIndex.Recommend and not self.m_friendData[td.FriendType.Recommend] then
    self.m_udMng:SendFriendRequest(td.FriendType.Recommend)
    return
  end
  if index == TabIndex.Donation then
    self.m_noteNum:setString("x" .. UserDataManager:GetInstance():GetItemNum(td.ItemId_FriendNote))
    self.m_btnStore:setVisible(true)
  else
    self.m_btnStore:setVisible(false)
  end
  for i = 1, #self.m_panels do
    if i == index then
      if self.m_isPanelsInit[index] == false then
        self.m_isPanelsInit[index] = true
        self:PlayEnterAnim(index)
      end
      self.m_panels[i]:setVisible(true)
      if i ~= TabIndex.Donation or i == TabIndex.Donation and g_MC:IsModuleUnlock(td.UIModule.FriendAssist) then
        self:RefreshList(index)
      end
    else
      self.m_panels[i]:setVisible(false)
    end
  end
  self:UpdateFrndNum()
end
function FriendDlg:RefreshList(panelIndex, data)
  self.m_panelLists[panelIndex]:removeAllItems()
  if panelIndex == TabIndex.MyFriend then
    for key, val in pairs(self.m_friendData[td.FriendType.Mine]) do
      local item = self:CreateItem(val, panelIndex, key)
      self.m_panelLists[panelIndex]:addItem(item)
    end
  elseif panelIndex == TabIndex.Recommend then
    if data then
      for key, val in pairs(data) do
        local item = self:CreateItem(val, panelIndex, key)
        self.m_panelLists[panelIndex]:addItem(item)
      end
    else
      for key, val in pairs(self.m_friendData[td.FriendType.Recommend]) do
        local item = self:CreateItem(val, panelIndex, key)
        self.m_panelLists[panelIndex]:addItem(item)
      end
    end
  elseif panelIndex == TabIndex.Application then
    for key, val in pairs(self.m_friendData[td.FriendType.Apply]) do
      local item = self:CreateItem(val, panelIndex, key)
      self.m_panelLists[panelIndex]:addItem(item)
    end
  else
    self:RefreshDonateList()
  end
  self.m_panelLists[panelIndex]:reload()
end
function FriendDlg:RefreshDonateList()
  local myDetail = self.m_udMng:GetUserDetail()
  local bg = cc.uiloader:seekNodeByName(self.m_panels[TabIndex.Donation], "bg")
  local textName = cc.uiloader:seekNodeByName(self.m_panels[TabIndex.Donation], "Text_name")
  local name, bnamed = self.m_udMng:GetNickname()
  textName:setString(name)
  local avatarBg = cc.uiloader:seekNodeByName(self.m_panels[TabIndex.Donation], "Image_avatar_bg")
  local avatarPath = CommanderInfoManager:GetInstance():GetPortraitInfo(self.m_udMng:GetPortrait()).file .. td.PNG_Suffix
  local avatar = display.newSprite(avatarPath)
  avatar:setScale(0.4)
  td.AddRelaPos(avatarBg, avatar)
  local nameSize = textName:getContentSize()
  local namePos = cc.p(textName:getPosition())
  local textLvl = td.CreateLabel("LV." .. self.m_udMng:GetUserDetail().camp, td.LIGHT_GREEN, 20)
  textLvl:setAnchorPoint(0, 0.5)
  textLvl:pos(namePos.x + nameSize.width + 40, namePos.y):addTo(bg)
  local lvlSize = textLvl:getContentSize()
  local lvlPos = cc.p(textLvl:getPosition())
  local textPower = td.CreateLabel(g_LM:getBy("a00032") .. ": " .. self.m_udMng:GetTotalPower(), td.WHITE, 20)
  textPower:setAnchorPoint(0, 0.5)
  textPower:pos(lvlPos.x + lvlSize.width + 40, lvlPos.y):addTo(bg)
  local btnRule = cc.uiloader:seekNodeByName(self.m_panels[TabIndex.Donation], "Button_rule")
  local btnAskHelp = cc.uiloader:seekNodeByName(self.m_panels[TabIndex.Donation], "Button_askHelp")
  local iconBg = cc.uiloader:seekNodeByName(self.m_panels[TabIndex.Donation], "Icon_bg")
  if not myDetail.gift or myDetail.gift == 0 then
    iconBg:setVisible(false)
    btnAskHelp:setVisible(true)
    btnRule:setVisible(true)
    td.BtnAddTouch(btnAskHelp, function()
      local popView = require("app.layers.MainMenuUI.FriendChooseItem").new()
      td.popView(popView)
    end)
    td.BtnAddTouch(btnRule, function()
      local data = {
        title = g_LM:getBy("a00092"),
        text = g_LM:getBy("a00230")
      }
      local ruleInfo = require("app.layers.RuleInfoDlg").new(data)
      td.popView(ruleInfo)
    end)
  else
    btnAskHelp:setVisible(false)
    btnRule:setVisible(false)
    local itemIcon = cc.uiloader:seekNodeByName(iconBg, "Icon_item")
    local itemNum = cc.uiloader:seekNodeByName(iconBg, "Text_num")
    local spr = ItemInfoManager:GetInstance():GetItemInfo(myDetail.gift).icon
    itemIcon:loadTexture(spr .. td.PNG_Suffix)
    local textNum = string.format("%d/%d", table.nums(myDetail.friend_name), 2)
    itemNum:setString(textNum)
    iconBg:setVisible(true)
  end
  for key, val in pairs(self.m_friendData[td.FriendType.Mine]) do
    local itemInfo = ItemInfoManager:GetInstance():GetItemInfo(val.gift_id)
    local itemNum = val.gift_num
    if itemInfo and itemNum < 1 and 2 > val.num then
      local item = self:CreateItem(val, TabIndex.Donation, key)
      self.m_panelLists[TabIndex.Donation]:addItem(item)
    end
  end
end
function FriendDlg:CreateItem(itemData, panelIndex, itemPos)
  local itemNode = cc.uiloader:load("CCS/FriendItem.csb")
  local itemBg = cc.uiloader:seekNodeByName(itemNode, "Panel_content")
  itemBg:setPosition(0, 600)
  itemBg:runAction(cc.EaseBackOut:create(cca.moveTo(0.3, 0, 0)))
  local textName = cc.uiloader:seekNodeByName(itemBg, "Text_name")
  textName:setString(itemData.uname)
  local idLabel = cc.uiloader:seekNodeByName(itemBg, "Text_id_label")
  idLabel:setString(g_LM:getBy("g00013") .. ":")
  local avatar = cc.uiloader:seekNodeByName(itemBg, "Image_avatar")
  local avatarPath = CommanderInfoManager:GetInstance():GetPortraitInfo(itemData.image_id).file .. td.PNG_Suffix
  avatar:loadTexture(avatarPath)
  local id = cc.uiloader:seekNodeByName(itemBg, "Text_id_data")
  idLabel:setString(itemData.fid)
  local levelLabel = cc.uiloader:seekNodeByName(itemBg, "Text_level_label")
  levelLabel:setString(g_LM:getBy("a00064") .. ":")
  local level = cc.uiloader:seekNodeByName(itemBg, "Text_level_data")
  level:setString(tostring(itemData.level))
  local powerLabel = cc.uiloader:seekNodeByName(itemBg, "Text_power_label")
  powerLabel:setString(g_LM:getBy("a00032") .. ":")
  local power = cc.uiloader:seekNodeByName(itemBg, "Text_power_data")
  power:setString(tostring(itemData.attack))
  if panelIndex == TabIndex.MyFriend then
    self:CreateMyFriendButtons(itemBg, itemData)
  elseif panelIndex == TabIndex.Recommend then
    self:CreateRecommendButtons(itemBg, itemData)
  elseif panelIndex == TabIndex.Application then
    self:CreateApplicationButtons(itemBg, itemData)
  else
    self:CreateDonationButtons(itemBg, itemData)
  end
  local bgSize = itemBg:getContentSize()
  local item = self.m_panelLists[panelIndex]:newItem(itemNode)
  item:setAnchorPoint(cc.p(0.5, 0.5))
  item:setItemSize(bgSize.width * self.m_scale, bgSize.height * self.m_scale)
  item:setScale(self.m_scale)
  return item
end
function FriendDlg:CreateMyFriendButtons(itemBg, itemData)
  local buttonDelete = ccui.Button:create("UI/friend/cha_icon.png")
  buttonDelete:setPressedActionEnabled(true)
  td.AddRelaPos(itemBg, buttonDelete, 0, cc.p(0.73, 0.5))
  td.BtnAddTouch(buttonDelete, function()
    local function cb()
      local data = {
        fid = itemData.fid,
        type = 0
      }
      self:SendRequest(data, td.RequestID.MFriend_req)
    end
    local conStr = g_LM:getBy("a00368")
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
  end)
  local buttonFight = ccui.Button:create("UI/friend/qiecuo_icon.png")
  buttonFight:setPressedActionEnabled(true)
  td.AddRelaPos(itemBg, buttonFight, 0, cc.p(0.83, 0.5))
  td.BtnAddTouch(buttonFight, function()
    local function cb()
      self:FriendFight(itemData)
    end
    local conStr = g_LM:getBy("a00369")
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
  end)
  local buttonChat = ccui.Button:create("UI/friend/siliao_icon.png")
  buttonChat:setPressedActionEnabled(true)
  td.AddRelaPos(itemBg, buttonChat, 0, cc.p(0.93, 0.5))
  td.BtnAddTouch(buttonChat, function()
    td.dispatchEvent(td.OPEN_CHAT, {
      uid = itemData.fid,
      uname = itemData.uname,
      reputation = itemData.reputation
    })
    self:close()
  end)
end
function FriendDlg:CreateRecommendButtons(itemBg, itemData)
  local buttonAdd = ccui.Button:create("UI/friend/jiahaoyou_icon.png")
  buttonAdd:setPressedActionEnabled(true)
  td.AddRelaPos(itemBg, buttonAdd, 0, cc.p(0.93, 0.5))
  td.BtnAddTouch(buttonAdd, function()
    if self:IsFriendNumMax() then
      td.alertErrorMsg(td.ErrorCode.FRIEND_NUM_MAX)
      return
    end
    self.m_udMng:SendAddFriendReq(itemData.fid)
    self:RefreshList(TabIndex.MyFriend)
  end)
end
function FriendDlg:CreateApplicationButtons(itemBg, itemData)
  local buttonConfirm = ccui.Button:create("UI/friend/gou_icon.png")
  buttonConfirm:setPressedActionEnabled(true)
  td.AddRelaPos(itemBg, buttonConfirm, 0, cc.p(0.83, 0.5))
  local buttonRefuse = ccui.Button:create("UI/friend/cha_icon.png")
  buttonRefuse:setPressedActionEnabled(true)
  td.AddRelaPos(itemBg, buttonRefuse, 0, cc.p(0.93, 0.5))
  td.BtnAddTouch(buttonConfirm, function()
    if self:IsFriendNumMax() then
      td.alertErrorMsg(td.ErrorCode.FRIEND_NUM_MAX)
      return
    end
    local data = {
      fid = itemData.fid,
      type = 1
    }
    self:SendRequest(data, td.RequestID.MFriend_req)
  end)
  td.BtnAddTouch(buttonRefuse, function()
    local data = {
      fid = itemData.fid,
      type = 0
    }
    self:SendRequest(data, td.RequestID.MFriend_req)
  end)
end
function FriendDlg:CreateDonationButtons(itemBg, itemData)
  local itemInfo = ItemInfoManager:GetInstance():GetItemInfo(itemData.gift_id)
  local itemName = td.CreateLabel(itemInfo.name .. ":", td.BLUE, 20)
  itemName:setAnchorPoint(1, 0.5)
  td.AddRelaPos(itemBg, itemName, 1, cc.p(0.79, 0.5))
  local textNum = string.format("%d/%d", itemData.gift_num, 1)
  local itemNum = td.CreateLabel(textNum, td.WHITE, 20)
  itemNum:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itemBg, itemNum, 1, cc.p(0.8, 0.5))
  local buttonDonate = ccui.Button:create("UI/friend/duobianxing.png")
  buttonDonate:setPressedActionEnabled(true)
  local donateItem = td.CreateItemIcon(itemData.gift_id)
  donateItem:setScale(0.6)
  td.AddRelaPos(buttonDonate, donateItem)
  td.AddRelaPos(itemBg, buttonDonate, 1, cc.p(0.93, 0.5))
  td.BtnAddTouch(buttonDonate, function()
    local data = {
      fid = itemData.fid
    }
    local itemID = itemData.gift_id
    self.m_donationId = itemID
    local myItemNum = UserDataManager:GetInstance():GetItemNum(itemID)
    if myItemNum > 0 then
      self:SendRequest(data, td.RequestID.DoAssist)
      td.CreateUIEffect(itemBg, "Spine/UI_effect/EFT_haoyouzhiyuan_01")
    else
      td.alertErrorMsg(td.ErrorCode.MATERIAL_NOT_ENOUGH)
    end
  end)
end
function FriendDlg:IsFriendNumMax()
  local num = 0
  if self.m_friendData[td.FriendType.Mine] then
    local data = self.m_friendData[td.FriendType.Mine]
    num = table.nums(data)
  end
  return num >= td.MAX_FRIEND_NUM
end
function FriendDlg:FriendFight(data)
  local limitLevel = require("app.info.BaseInfoManager"):GetInstance():GetOpenInfo(td.UIModule.PVP).baseLevel or 1
  if limitLevel > UserDataManager:GetInstance():GetBaseCampLevel() then
    td.alertErrorMsg(td.ErrorCode.BASE_LEVEL_LOW)
  elseif limitLevel > data.level then
    td.alert(g_LM:getBy("a00190") .. g_LM:getMode("errormsg", td.ErrorCode.BASE_LEVEL_LOW), true)
  else
    self:SendRequest({
      uid = data.fid,
      type = 1
    }, td.RequestID.GetPlayerAreanaInfo)
  end
end
function FriendDlg:Search()
  local searchPanel = require("app.layers.MainMenuUI.FriendSearchDlg").new()
  td.popView(searchPanel)
end
function FriendDlg:SendSearchRequest(event)
  local data = {}
  if type(event:getDataString()) == "string" then
    data = {
      nickname = event:getDataString()
    }
  else
    data = {
      fid = tonumber(event:getDataString())
    }
  end
  self:SendRequest(data, td.RequestID.SearchPlayer)
end
function FriendDlg:RequestDonationCallback(event)
  self:UpdatePanels(TabIndex.Donation)
end
function FriendDlg:RefreshRcmdList()
  self.m_udMng:SendFriendRequest(td.FriendType.Recommend)
end
function FriendDlg:SendRequest(data, reqId)
  local Msg = {}
  Msg.msgType = reqId
  Msg.sendData = data
  Msg.cbData = clone(data)
  TDHttpRequest:getInstance():Send(Msg)
end
function FriendDlg:FriendFightCallback(data)
  UserDataManager:GetInstance():SetSelfPVPData(data.arenaProto)
  UserDataManager:GetInstance():SetEnemyPVPData(data.otherArena, true)
  local v = data.otherArena
  local uName = UserDataManager:GetInstance():GetUserData().name
  local power = UserDataManager:GetInstance():GetTotalPower()
  local rank = UserDataManager:GetInstance():GetArenaRank()
  GameDataManager:GetInstance():SetCurPVPInfo({
    id = v.uid,
    enemyName = v.name,
    enemyRank = v.rank,
    enemyZhanli = v.max_attack,
    enemyHeadId = v.image_id,
    myRank = rank,
    isFriend = true
  })
  local loadingScene = require("app.scenes.LoadingScene").new(td.ARENA_ID)
  cc.Director:getInstance():replaceScene(loadingScene)
end
function FriendDlg:UpdateFriendCallback(data)
  if data.type == 1 then
    self.m_udMng:AddFriendData(data.fid)
  else
    self.m_udMng:DeleteFriendData(data.fid)
  end
  td.dispatchEvent(td.FRIEND_DATA_INITED, td.FriendType.Mine)
end
function FriendDlg:SearchFriendCallback(data)
  self:RefreshList(TabIndex.Recommend, data.friendProto)
end
function FriendDlg:UpdateMyQuest()
  self:UpdatePanels(self.m_currPanelIndex)
  self:CheckAssisted()
end
function FriendDlg:DonateCallback(data, cbData)
  local friendData = self.m_friendData[td.FriendType.Mine][cbData.fid]
  if data.state ~= td.ResponseState.Success then
    td.alert(g_LM:getBy("a00343"))
  else
    local rewardInfo = ItemInfoManager:GetInstance():GetDonateInfo(self.m_donationId).reward
    local reward = rewardInfo.num
    local str = string.format(g_LM:getBy("a00091"), reward)
    td.alert(str)
    if friendData then
      friendData.gift_num = friendData.gift_num + 1
    end
  end
  self:UpdatePanels(TabIndex.Donation)
end
function FriendDlg:CheckAssisted()
  local bShow = false
  local assistFriends = self.m_udMng:GetAssistMsg()
  for key, var in pairs(assistFriends) do
    if var.bNew == true then
      bShow = true
      var.bNew = false
    end
  end
  if bShow then
    local dlg = require("app.layers.MainMenuUI.AssistTipDlg").new()
    td.popView(dlg)
  end
end
return FriendDlg
