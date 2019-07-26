local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local ActivityDataManager = require("app.ActivityDataManager")
local scheduler = require("framework.scheduler")
local ActivityDlg = class("ActivityDlg", BaseDlg)
function ActivityDlg:ctor()
  ActivityDlg.super.ctor(self)
  self.m_uiId = td.UIModule.Activity
  self.m_udMng = UserDataManager:GetInstance()
  self.m_adMng = ActivityDataManager:GetInstance()
  self.m_activityData = self.m_adMng:GetActivityData()
  self.m_vContentNode = {
    {},
    {}
  }
  self.m_curContentNode = nil
  self.m_bIsTouchInList = false
  self.m_curType = 1
  self.m_curSelectIndex = -1
  self.m_enterSelectIndex = nil
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function ActivityDlg:onEnter()
  ActivityDlg.super.onEnter(self)
  self:AddListeners()
  self:AddTouch()
  if self.m_adMng:GetActivityData() then
    self.m_activityData = self.m_adMng:GetActivityData()
    self:InitTab(self.m_curType)
  else
    self.m_adMng:GetActivityListRequest()
  end
  self.m_enterSelectIndex = nil
end
function ActivityDlg:onExit()
  ActivityDlg.super.onExit(self)
end
function ActivityDlg:SetEnterSubIndex(vSubIndex)
  if not vSubIndex then
    return
  end
  self.m_curType = vSubIndex[1]
  self.m_enterSelectIndex = vSubIndex[2]
end
function ActivityDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/ActivityDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_btnType1 = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_tab1")
  td.BtnAddTouch(self.m_btnType1, function()
    td.ShowRP(self.m_btnType1, false)
    self.m_curSelectIndex = 1
    self:InitTab(1)
  end)
  self.m_btnType2 = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_tab2")
  td.BtnAddTouch(self.m_btnType2, function()
    td.ShowRP(self.m_btnType2, false)
    self.m_curSelectIndex = 1
    self:InitTab(2)
  end)
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 220, 380),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:setPosition(30, 40)
  self.m_bg:addChild(self.m_UIListView, 1)
  self.m_UIListView:onTouch(function(event)
    if "clicked" == event.name and event.item then
      self:OnListItemClicked(event.itemPos)
    end
  end)
end
function ActivityDlg:InitTab(index)
  self.m_curType = index or self.m_curType
  self.m_btnType1:setDisable(self.m_curType == 1)
  self.m_btnType1:getChildByName("title"):setColor(self.m_curType == 1 and cc.c3b(255, 255, 0) or td.LIGHT_BLUE)
  self.m_btnType2:setDisable(self.m_curType == 2)
  self.m_btnType2:getChildByName("title"):setColor(self.m_curType == 2 and cc.c3b(255, 255, 0) or td.LIGHT_BLUE)
  if index == 1 then
    local bShow = self.m_adMng:CheckRP(2)
    td.ShowRP(self.m_btnType2, bShow)
  else
    local bShow = self.m_adMng:CheckRP(1)
    td.ShowRP(self.m_btnType1, bShow)
  end
  self:RefreshList()
end
function ActivityDlg:RefreshList()
  local vActivity = self.m_activityData[self.m_curType]
  self.m_UIListView:removeAllItems()
  for i, var in ipairs(vActivity) do
    local item = self:CreateItem(var, i)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
  self.m_curSelectIndex = -1
  self:OnListItemClicked(self.m_enterSelectIndex or 1)
end
function ActivityDlg:OnListItemClicked(index)
  if index == self.m_curSelectIndex then
    return
  end
  if self.m_curSelectIndex > 0 then
    local item = self.m_UIListView:getItemByPos(self.m_curSelectIndex)
    local itemBg = item:getContent():getChildByName("bg")
    itemBg:setTexture("UI/scale9/huodong_button2.png")
    itemBg:getChildByName("arrow"):setVisible(false)
  end
  self.m_curSelectIndex = index
  local item = self.m_UIListView:getItemByPos(self.m_curSelectIndex)
  if item then
    local itemBg = item:getContent():getChildByName("bg")
    itemBg:setTexture("UI/scale9/huodong_button1.png")
    itemBg:getChildByName("arrow"):setVisible(true)
    td.ShowRP(itemBg, false)
  end
  local activityData = self.m_activityData[self.m_curType][index]
  self:RefreshContent(activityData, index)
end
function ActivityDlg:RefreshContent(activityData, index)
  if self.m_curContentNode then
    self.m_curContentNode:setVisible(false)
    self.m_curContentNode = nil
  end
  if activityData then
    local contentNode = self.m_vContentNode[self.m_curType][index]
    if contentNode then
      contentNode:setVisible(true)
    else
      contentNode = self:CreateContentNode(activityData)
      self.m_vContentNode[self.m_curType][index] = contentNode
      td.AddRelaPos(self.m_bg, contentNode, 0, cc.p(0.62, 0.44))
    end
    self.m_curContentNode = contentNode
  end
end
function ActivityDlg:CreateItem(info, index)
  local itemNode = display.newNode()
  local item = self.m_UIListView:newItem(itemNode)
  local bgSize = cc.size(170, 70)
  local itembg = display.newSprite("UI/scale9/huodong_button2.png")
  itembg:setAnchorPoint(cc.p(0, 0))
  itembg:pos(-20, 0)
  itembg:setName("bg")
  itemNode:scale(self.m_scale)
  itemNode:setContentSize(bgSize)
  itembg:addTo(itemNode)
  local bResult, vIndexes = self.m_adMng:CheckRP(self.m_curType)
  if table.indexof(vIndexes, index) then
    td.ShowRP(itembg, true)
  end
  local titleLabel = td.CreateLabel(info.name, td.WHITE, 20)
  td.AddRelaPos(itembg, titleLabel)
  if info.icon then
    local iconSpr = display.newSprite(string.format("UI/activity/icon%d.png", info.icon))
    iconSpr:setAnchorPoint(0, 1)
    td.AddRelaPos(itembg, iconSpr, 1, cc.p(0, 1))
  end
  local arrowSpr = display.newSprite("UI/common/jiantou_icon2.png")
  arrowSpr:setAnchorPoint(0, 0.5)
  arrowSpr:setName("arrow")
  td.AddRelaPos(itembg, arrowSpr, 1, cc.p(1, 0.5))
  arrowSpr:setVisible(false)
  item:setItemSize((bgSize.width + 5) * self.m_scale, bgSize.height * self.m_scale)
  return item
end
function ActivityDlg:CreateContentNode(data)
  local contentNode
  if data.type == td.ActType.Redeem then
    contentNode = require("app.layers.activity.RedeemActivity").new(data)
  elseif data.type == td.ActType.NewSignIn then
    contentNode = require("app.layers.activity.NewSignActivity").new(data)
  elseif data.type == td.ActType.OnlineTime then
    contentNode = require("app.layers.activity.OnlineActivity").new(data)
  elseif data.type == td.ActType.Invite then
    contentNode = require("app.layers.activity.InviteActivity").new(data)
  elseif data.type == td.ActType.MonthSignIn then
    contentNode = require("app.layers.activity.MonthSignInActivity").new(data)
  elseif data.type == td.ActType.Fund then
    contentNode = require("app.layers.activity.GrouthFundActivity").new(data)
  elseif data.type == td.ActType.Charge then
    contentNode = require("app.layers.activity.ChargeActivity").new(data)
  elseif data.type == td.ActType.MonthCard then
    contentNode = require("app.layers.activity.MonthCardActivity").new(data)
  elseif data.type == td.ActType.Notice then
    contentNode = require("app.layers.activity.NoticeActivity").new(data)
  else
    contentNode = require("app.layers.activity.ListActivity").new(data)
  end
  return contentNode
end
function ActivityDlg:AddTouch()
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
        self:performWithDelay(function(times)
          self:close()
        end, 0.1)
        bResult = false
      end
      self.m_bIsTouchInList = false
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
function ActivityDlg:AddListeners()
  self:AddCustomEvent(td.ACTIVITY_INITED, function(event)
    self.m_activityData = self.m_adMng:GetActivityData()
    self:InitTab(self.m_curType)
  end)
end
return ActivityDlg
