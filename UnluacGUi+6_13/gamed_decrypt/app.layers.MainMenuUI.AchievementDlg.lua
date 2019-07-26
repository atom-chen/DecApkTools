local TabButton = require("app.widgets.TabButton")
local AchievementInfo = require("app.info.AchievementInfo")
local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local ItemInfoManager = require("app.info.ItemInfoManager")
local UserDataManager = require("app.UserDataManager")
local TouchIcon = require("app.widgets.TouchIcon")
local scheduler = require("framework.scheduler")
local AchievementDlg = class("AchievementDlg", BaseDlg)
local AwardNodeTag = 122333
local BgTag = 123
local AchiveTypes = {
  td.AchieveType.Mixed,
  td.AchieveType.Mission,
  td.AchieveType.Explore
}
local AchiveStates = {
  td.AchievementState.Complete,
  td.AchievementState.Incomplete,
  td.AchievementState.Received
}
local ItemSize = cc.size(860, 90)
function AchievementDlg:ctor()
  AchievementDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Achievement
  self.m_vData = UserDataManager:GetInstance():GetAchieveData()
  self.m_iIndex = 1
  self.m_iCurItemCount = 0
  self.m_scrollPos = nil
  self.m_allItemCount = self:GetAllItemCount()
  self.m_tabs = {}
  self.m_awards = {}
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function AchievementDlg:GetAllItemCount()
  local count = 0
  for i, state in ipairs(AchiveStates) do
    count = count + #self.m_vData[AchiveTypes[self.m_iIndex]][state]
  end
  return count
end
function AchievementDlg:onEnter()
  AchievementDlg.super.onEnter(self)
  self:RefreshList()
  self:AddEvents()
end
function AchievementDlg:onExit()
  AchievementDlg.super.onExit(self)
end
function AchievementDlg:InitUI()
  self:LoadUI("CCS/AchievementDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_chengjiu.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local list_bg_size = self.m_bg:getContentSize()
  local panelLeft = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_left")
  local tab1 = ccui.ImageView:create(td.Word_Path .. "zonghe1_icon.png"):pos(127, 351):addTo(panelLeft)
  local tab2 = ccui.ImageView:create(td.Word_Path .. "guanqia2_icon.png"):pos(127, 199):addTo(panelLeft)
  local tab3 = ccui.ImageView:create(td.Word_Path .. "tansuo2_icon.png"):pos(127, 47):addTo(panelLeft)
  self.m_tabs = {
    tab1,
    tab2,
    tab3
  }
  for i = 1, 3 do
    if #self.m_vData[AchiveTypes[i]][td.AchievementState.Complete] > 0 then
      td.ShowRP(self.m_tabs[i], true)
    end
  end
  local function pressItemBtn(index)
    td.ShowRP(self.m_tabs[index], false)
    self.m_UIListView:removeAllItems()
    self.m_iIndex = index
    self.m_iCurItemCount = 0
    self.m_allItemCount = self:GetAllItemCount()
    self.m_scrollPos = nil
    self:RefreshList()
  end
  local t1 = {
    tab = tab1,
    callfunc = pressItemBtn,
    normalImageFile = td.Word_Path .. "zonghe2_icon.png",
    highImageFile = td.Word_Path .. "zonghe1_icon.png"
  }
  local t2 = {
    tab = tab2,
    callfunc = pressItemBtn,
    normalImageFile = td.Word_Path .. "guanqia2_icon.png",
    highImageFile = td.Word_Path .. "guanqia1_icon.png"
  }
  local t3 = {
    tab = tab3,
    callfunc = pressItemBtn,
    normalImageFile = td.Word_Path .. "tansuo2_icon.png",
    highImageFile = td.Word_Path .. "tansuo1_icon.png"
  }
  self.m_TabButton = TabButton.new({
    t1,
    t2,
    t3
  })
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 900, 460),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_UIListView:setPosition(cc.p(0, 20))
  self.m_bg:addChild(self.m_UIListView)
  self.m_UIListView:onTouch(function(event)
    if event.name == "nextPage" then
      if self.m_allItemCount > self.m_iCurItemCount then
        self:RefreshList()
      end
    elseif event.name == "ended" then
      self.m_scrollPos = cc.p(self.m_UIListView:getScrollNode():getPosition())
    end
  end)
end
function AchievementDlg:AddEvents()
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
    end
    return bResult
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
end
function AchievementDlg:CreateItem(v)
  local achiveInfo = AchievementInfo:GetInstance():GetInfo(v.id)
  local itemNode = display.newNode()
  itemNode:setScale(self.m_scale)
  itemNode:setContentSize(ItemSize)
  local item = self.m_UIListView:newItem(itemNode)
  local itembg, achieveIcon
  local bGray = false
  local color1, color2, color3, color4
  if v.receive == td.AchievementState.Incomplete then
    itembg = display.newScale9Sprite("UI/scale9/chengjiu_dikuang.png", 0, 0, ItemSize)
    achieveIcon = display.newGraySprite(achiveInfo.image .. td.PNG_Suffix)
    bGray = true
    color1 = cc.c3b(33, 136, 172)
    color2 = cc.c3b(33, 136, 172)
    color3 = cc.c3b(33, 136, 172)
    color4 = cc.c3b(33, 136, 172)
  else
    itembg = display.newScale9Sprite("UI/scale9/chengjiu_dikuang.png", 0, 0, ItemSize)
    achieveIcon = display.newSprite(achiveInfo.image .. td.PNG_Suffix)
    color1 = td.YELLOW
    color2 = td.LIGHT_BLUE
    color3 = td.GREEN
    color4 = td.LIGHT_BLUE
    v.num = achiveInfo.maxNum
  end
  itembg:setAnchorPoint(cc.p(0, 0))
  itembg:setTag(BgTag)
  itembg:addTo(itemNode)
  achieveIcon:setPosition(45, ItemSize.height / 2)
  itembg:addChild(achieveIcon)
  local label = td.CreateLabel(achiveInfo.name, color1, 20)
  label:setAnchorPoint(cc.p(0, 0))
  label:setPosition(85, ItemSize.height * 0.6)
  itembg:addChild(label)
  label = td.CreateLabel(achiveInfo.descrip, color2, 14, nil, nil, cc.size(180, 40))
  label:setAnchorPoint(cc.p(0, 1))
  label:setPosition(85, ItemSize.height * 0.6)
  itembg:addChild(label)
  v.num = cc.clampf(v.num, 0, achiveInfo.maxNum)
  label = td.RichText({
    {
      type = 1,
      color = color3,
      size = 20,
      str = self:GetNumberStr(v.num)
    },
    {
      type = 1,
      color = color4,
      size = 20,
      str = "/" .. self:GetNumberStr(achiveInfo.maxNum)
    }
  })
  label:setAnchorPoint(cc.p(0.5, 0.5))
  label:setPosition(cc.p(320, ItemSize.height / 2))
  itembg:addChild(label)
  if v.receive == td.AchievementState.Received then
    local yihuode = display.newSprite(td.Word_Path .. "yilingqu_icon.png")
    yihuode:setPosition(750, ItemSize.height / 2)
    itembg:addChild(yihuode)
  else
    local button = td.CreateBtn(td.BtnType.GreenShort)
    button:setName("Button_3")
    button:setTag(AwardNodeTag)
    td.BtnAddTouch(button, function()
      if v.receive == td.AchievementState.Complete then
        self:GetReward(item)
      else
        td.alertErrorMsg(td.ErrorCode.INCOMPLETE)
      end
    end)
    button:pos(750, ItemSize.height / 2):addTo(itembg)
    td.BtnSetTitle(button, g_LM:getBy("a00052"))
    if v.receive == td.AchievementState.Complete then
      local spine = SkeletonUnit:create("Spine/UI_effect/EFT_renwuwancheng_01")
      spine:setScaleX(1.32)
      spine:setScaleY(1.13)
      td.AddRelaPos(itembg, spine, 10)
      spine:PlayAni("animation", true)
    else
      td.EnableButton(button, false)
    end
  end
  local awards = {}
  local iconSize = cc.size(60, 60)
  for j, award in ipairs(achiveInfo.award) do
    local tmpSpri = display.newScale9Sprite("UI/scale9/bantoumingkuang.png", 10, 10, iconSize)
    local itemInfo = ItemInfoManager:GetInstance():GetItemInfo(award.id)
    local iconSpri = TouchIcon.new(award.id, true)
    iconSpri:setScale(0.55)
    iconSpri.itemId = award.id
    iconSpri:setPosition(cc.p(iconSize.width * 0.5, iconSize.height * 0.5))
    tmpSpri:addChild(iconSpri)
    local numLabel = td.CreateLabel(award.num, cc.c3b(230, 230, 230), 16, td.OL_BLACK)
    numLabel:setAnchorPoint(cc.p(0, 1))
    td.AddRelaPos(tmpSpri, numLabel, 1, cc.p(0.1, 0.95))
    itembg:addChild(tmpSpri)
    tmpSpri:setPosition(400 + j * (iconSize.width + 3), ItemSize.height / 2)
    table.insert(awards, iconSpri)
    self.m_awards[award.id] = award.num
  end
  item:setItemSize(ItemSize.width * self.m_scale, (ItemSize.height + 7) * self.m_scale)
  item:setName(tostring(v.receive))
  item:setTag(v.id)
  item.awards = awards
  return item
end
function AchievementDlg:RefreshList()
  local eType = AchiveTypes[self.m_iIndex]
  local count, index = 0, 0
  for i, state in ipairs(AchiveStates) do
    for j, var in ipairs(self.m_vData[eType][state]) do
      index = index + 1
      if index > self.m_iCurItemCount and count <= 5 then
        local item = self:CreateItem(var)
        self.m_UIListView:addItem(item)
        count = count + 1
      end
    end
  end
  self.m_iCurItemCount = self.m_iCurItemCount + count
  self.m_UIListView:reload()
  if self.m_scrollPos then
    self.m_scrollPos = cc.p(self.m_scrollPos.x, self.m_scrollPos.y - count * ItemSize.height)
    self.m_UIListView:scrollTo(self.m_scrollPos)
  end
end
function AchievementDlg:GetReward(sender)
  local data = {}
  local msg = {}
  data.id = sender:getTag()
  msg.msgType = td.RequestID.GetAchievementAward
  msg.sendData = data
  TDHttpRequest:getInstance():Send(msg)
  require("app.layers.InformationManager"):GetInstance():ShowInfoDlg({
    type = td.ShowInfo.Item,
    items = self.m_awards
  })
  self:GetRewardSuccess(sender)
end
function AchievementDlg:GetRewardSuccess(sender)
  local id = sender:getTag()
  UserDataManager:GetInstance():UpdateAchieveState(id)
  self.m_vData = UserDataManager:GetInstance():GetAchieveData()
  sender:setName(tostring(td.AchievementState.Received))
  local bg = sender:getChildByTag(11):getChildByTag(BgTag)
  bg:getChildByTag(AwardNodeTag):setVisible(false)
  local yihuode = display.newSprite("UI/words/yilingqu_icon.png")
  yihuode:setPosition(750, ItemSize.height / 2)
  bg:addChild(yihuode)
  yihuode:setOpacity(0)
  yihuode:setScale(3)
  yihuode:runAction(cca.seq({
    cca.spawn({
      cca.scaleTo(0.3, 1),
      cca.fadeIn(0.3)
    }),
    cca.delay(0.5),
    cca.cb(function()
      bg:runAction(cca.seq({
        cc.EaseSineIn:create(cca.moveBy(0.5, 2000, 0)),
        cca.cb(function()
          self.m_UIListView:removeAllItems()
          self.m_iCurItemCount = 0
          self.m_scrollPos = nil
          self:RefreshList()
        end)
      }))
    end)
  }))
end
function AchievementDlg:GetNumberStr(num)
  local str = ""
  if num >= 10000 then
    str = string.format("%dW", num / 10000)
  elseif num >= 1000 then
    str = string.format("%dK", num / 1000)
  else
    str = tostring(num)
  end
  return str
end
return AchievementDlg
