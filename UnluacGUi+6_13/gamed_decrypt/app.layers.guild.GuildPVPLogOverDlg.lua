local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local GuildDataManager = require("app.GuildDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local GuildPVPLogOverDlg = class("GuildPVPLogOverDlg", BaseDlg)
local ITEM_SIZE = cc.size(815, 80)
function GuildPVPLogOverDlg:ctor(resData)
  GuildPVPLogOverDlg.super.ctor(self, 200)
  self.m_gdMng = GuildDataManager:GetInstance()
  self.m_pvpData = self.m_gdMng:GetGuildPVPData()
  self.m_vResData = resData
  self:InitUI()
end
function GuildPVPLogOverDlg:onEnter()
  GuildPVPLogOverDlg.super.onEnter(self)
  self:AddEvents()
  self:PlayEnterAni(function()
    self:RefreshList()
  end)
end
function GuildPVPLogOverDlg:onExit()
  GuildPVPLogOverDlg.super.onExit(self)
end
function GuildPVPLogOverDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/guild/GuildPVPLogDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local closeBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_close")
  td.BtnSetTitle(closeBtn, g_LM:getBy("a00164"))
  self:setCloseBtn(closeBtn)
  local label1 = td.CreateLabel(g_LM:getBy("g00023"), td.BLUE, 20)
  label1:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self.m_bg, label1, 1, cc.p(0.12, 1.05))
  local label2 = td.CreateLabel(g_LM:getBy("g00040"), td.BLUE, 20)
  label2:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self.m_bg, label2, 1, cc.p(0.44, 1.05))
  local label3 = td.CreateLabel(g_LM:getBy("g00041"), td.BLUE, 20)
  label3:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self.m_bg, label3, 1, cc.p(0.74, 1.05))
  self:CreateList()
end
function GuildPVPLogOverDlg:PlayEnterAni(cb)
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
function GuildPVPLogOverDlg:CreateList()
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
function GuildPVPLogOverDlg:RefreshList()
  self.m_UIListView:removeAllItems()
  for i, var in ipairs(self.m_vResData) do
    local listItem = self:CreateItem(var, i == 1)
    self.m_UIListView:addItem(listItem)
  end
  self.m_UIListView:reload()
end
function GuildPVPLogOverDlg:CreateItem(data, bMvp)
  local itemNode = display.newNode()
  itemNode:setContentSize(ITEM_SIZE)
  itemNode:scale(self.m_scale)
  local imageHead = display.newSprite(td.GetPortrait(data.image_id))
  imageHead:scale(0.3)
  td.AddRelaPos(itemNode, imageHead, 1, cc.p(0.1, 0.5))
  local conSize = imageHead:getContentSize()
  local headBg = display.newScale9Sprite("UI/scale9/touxiangkuang5.png", 0, 0, cc.size(conSize.width + 10, conSize.height + 10))
  td.AddRelaPos(imageHead, headBg, -1)
  local labelName = td.CreateLabel(data.uname, td.LIGHT_BLUE)
  labelName:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itemNode, labelName, 1, cc.p(0.15, 0.5))
  local resLabel = td.RichText({
    {
      type = 2,
      file = "UI/icon/yuanli1_wupin.png",
      scale = 1
    },
    {
      type = 1,
      str = "" .. data.res,
      size = 20,
      color = td.WHITE
    }
  })
  td.AddRelaPos(itemNode, resLabel, 1, cc.p(0.5, 0.5))
  local conLabel = td.CreateLabel("" .. math.floor(data.res / 20), td.YELLOW)
  td.AddRelaPos(itemNode, conLabel, 1, cc.p(0.8, 0.5))
  if bMvp then
    local mvpSpr = display.newSprite("UI/guild/MVP_icon.png")
    mvpSpr:setRotation(-30)
    mvpSpr:opacity(0):scale(3)
    td.AddRelaPos(itemNode, mvpSpr, 1, cc.p(0.92, 0.5))
    mvpSpr:runAction(cca.spawn({
      cca.fadeIn(0.3),
      cca.scaleTo(0.3, 1, 1)
    }))
    local bg = display.newScale9Sprite("UI/scale9/touxiangdi1.png", 0, 0, ITEM_SIZE)
    td.AddRelaPos(itemNode, bg, -1)
  else
    local lineSpr = display.newSprite("UI/common/fengexian_shu.png")
    lineSpr:setScaleX(ITEM_SIZE.width / lineSpr:getContentSize().width)
    td.AddRelaPos(itemNode, lineSpr, 1, cc.p(0.5, 0))
  end
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize(ITEM_SIZE.width * self.m_scale, (ITEM_SIZE.height + 5) * self.m_scale)
  return item
end
function GuildPVPLogOverDlg:AddEvents()
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
return GuildPVPLogOverDlg
