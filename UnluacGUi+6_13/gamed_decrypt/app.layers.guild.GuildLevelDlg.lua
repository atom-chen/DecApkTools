local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local GuildInfoManager = require("app.info.GuildInfoManager")
local NormalItemSize = cc.size(490, 60)
local GuildLevelDlg = class("GuildLevelDlg", BaseDlg)
function GuildLevelDlg:ctor()
  GuildLevelDlg.super.ctor(self)
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function GuildLevelDlg:onEnter()
  GuildLevelDlg.super.onEnter(self)
  self:AddEvents()
end
function GuildLevelDlg:onExit()
  GuildLevelDlg.super.onExit(self)
end
function GuildLevelDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  local panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  local bgSize = cc.size(550, 375)
  self.m_bg = display.newScale9Sprite("UI/scale9/yijitankuang2.png", 0, 0, bgSize, cc.rect(110, 80, 5, 2))
  td.AddRelaPos(panel, self.m_bg)
  local curLevel = UserDataManager:GetInstance():GetGuildManager():GetGuildLevel()
  local levelLabel = td.CreateLabel("LV." .. curLevel, td.GREEN, 24)
  td.AddRelaPos(self.m_bg, levelLabel, 1, cc.p(0.5, 0.85))
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(30, 45, 490, 250),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:setAlignment(3)
  self.m_bg:addChild(self.m_UIListView)
  self:RefreshList()
end
function GuildLevelDlg:RefreshList()
  self.m_UIListView:removeAllItems()
  local giMng = GuildInfoManager:GetInstance()
  for i = 1, 10 do
    local item = self:CreateItem(i)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function GuildLevelDlg:CreateItem(level)
  local itemUI = display.newNode()
  local itemBg = display.newScale9Sprite("UI/scale9/chengjiu_dikuang.png", 0, 0, NormalItemSize, cc.rect(11, 11, 6, 6))
  itemBg:setAnchorPoint(0, 0)
  itemBg:addTo(itemUI)
  local levelLabel = td.CreateLabel(g_LM:getBy("a00080") .. " LV." .. level, td.LIGHT_BLUE, 22)
  levelLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itemBg, levelLabel, 1, cc.p(0.1, 0.5))
  local tmpLabel = td.CreateLabel(g_LM:getBy("g00039") .. ":", td.BLUE, 18)
  tmpLabel:setAnchorPoint(1, 0.5)
  td.AddRelaPos(itemBg, tmpLabel, 1, cc.p(0.8, 0.5))
  local numLabel = td.CreateLabel(tostring(20 + level), td.WHITE, 22)
  numLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itemBg, numLabel, 1, cc.p(0.81, 0.5))
  local item = self.m_UIListView:newItem(itemUI)
  item:setItemSize(NormalItemSize.width * self.m_scale, (NormalItemSize.height + 5) * self.m_scale)
  item:setScale(self.m_scale)
  item:setAnchorPoint(cc.p(0.5, 0.5))
  return item
end
function GuildLevelDlg:AddEvents()
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
        bResult = true
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
return GuildLevelDlg
