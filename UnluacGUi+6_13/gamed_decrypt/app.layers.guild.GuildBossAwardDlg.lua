local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local GuildInfoManager = require("app.info.GuildInfoManager")
local TouchIcon = require("app.widgets.TouchIcon")
local GuildBossAwardDlg = class("GuildBossAwardDlg", BaseDlg)
local ITEM_SIZE = cc.size(815, 80)
function GuildBossAwardDlg:ctor(myRange)
  GuildBossAwardDlg.super.ctor(self, 200)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_myRange = myRange
  self:InitUI()
end
function GuildBossAwardDlg:onEnter()
  GuildBossAwardDlg.super.onEnter(self)
  self:AddEvents()
  self:PlayEnterAni(handler(self, self.RefreshList))
end
function GuildBossAwardDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/guild/GuildPVPLogDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local closeBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_close")
  td.BtnSetTitle(closeBtn, g_LM:getBy("a00164"))
  self:setCloseBtn(closeBtn)
  local label = td.CreateLabel(g_LM:getBy("a00417") .. ":", td.BLUE)
  label:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self.m_bg, label, 1, cc.p(0, -0.1))
  local rangeLabel = td.CreateLabel(self.m_myRange or g_LM:getBy("a00419"), td.WHITE)
  rangeLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self.m_bg, rangeLabel, 1, cc.p(0.13, -0.1))
  self:CreateListHeader()
  self:CreateList()
end
function GuildBossAwardDlg:PlayEnterAni(cb)
  local lightImg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_btmLight")
  lightImg:runAction(cca.seq({
    cca.moveBy(0.3, 0, -360),
    cca.cb(function()
      self.m_bg:runAction(cca.seq({
        cca.fadeIn(0.3),
        cca.cb(cb)
      }))
    end)
  }))
end
function GuildBossAwardDlg:CreateList()
  local listView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 815, 400),
    touchOnContent = false,
    scale = self.m_scale
  })
  listView:setAnchorPoint(cc.p(0, 0))
  listView:pos(0, 0):addTo(self.m_bg)
  self.m_UIListView = listView
end
function GuildBossAwardDlg:RefreshList()
  local bossAwards = GuildInfoManager:GetInstance():GetBossAwardInfo()
  self.m_UIListView:removeAllItems()
  for i, info in ipairs(bossAwards) do
    local item = self:CreateItem(info)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function GuildBossAwardDlg:CreateItem(info)
  local itemNode = display.newNode()
  itemNode:setContentSize(ITEM_SIZE)
  itemNode:scale(self.m_scale)
  local rangeStr = ""
  if #info.level == 1 then
    rangeStr = string.format("%d", info.level[1])
  else
    rangeStr = string.format("%d-%d", info.level[1], info.level[2])
  end
  local nameLabel = td.CreateLabel(rangeStr, td.WHITE, 18)
  td.AddRelaPos(itemNode, nameLabel, 1, cc.p(0.25, 0.5))
  for i, var in ipairs(info.award) do
    local icon = TouchIcon.new(var.itemId, true, false)
    icon:setScale(0.6)
    td.AddRelaPos(itemNode, icon, 1, cc.p(0.5 + i * 0.08, 0.5))
    local numLabel = td.CreateLabel(var.num, td.WHITE, 26, td.OL_BLACK)
    numLabel:setAnchorPoint(0, 0.5)
    td.AddRelaPos(icon, numLabel, 1, cc.p(0.05, 0.8))
  end
  local lineSpr = display.newSprite("UI/common/fengexian_shu.png")
  lineSpr:setScaleX(ITEM_SIZE.width / lineSpr:getContentSize().width)
  td.AddRelaPos(itemNode, lineSpr, 1, cc.p(0.5, 0))
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize(ITEM_SIZE.width * self.m_scale, (ITEM_SIZE.height + 5) * self.m_scale)
  return item
end
function GuildBossAwardDlg:CreateListHeader()
  local headerConfig = {
    {
      str = g_LM:getBy("a00163"),
      x = 0.22
    },
    {
      str = g_LM:getBy("a00268"),
      x = 0.55
    }
  }
  for i, var in ipairs(headerConfig) do
    local label = td.CreateLabel(var.str, td.BLUE, 20)
    label:setAnchorPoint(0, 0.5)
    td.AddRelaPos(self.m_bg, label, 1, cc.p(var.x, 1.05))
  end
end
function GuildBossAwardDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
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
    else
      local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
      if not isTouchInNode(self.m_bg, tmpPos) then
        self:performWithDelay(function()
          self:close()
        end, 0.1)
      end
    end
    return true
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
return GuildBossAwardDlg
