local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local ServerDlg = class("ServerDlg", BaseDlg)
function ServerDlg:ctor(servers)
  ServerDlg.super.ctor(self)
  self.m_vServers = servers
  self:InitUI()
end
function ServerDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/ServerLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local bgSize = self.m_bg:getContentSize()
  local label1 = td.CreateLabel(g_LM:getBy("a00303"))
  label1:setAnchorPoint(0, 0.5)
  label1:pos(50, bgSize.height - 52):addTo(self.m_bg)
  local label2 = td.CreateLabel(g_LM:getBy("a00304"))
  label2:setAnchorPoint(0, 0.5)
  label2:pos(50, bgSize.height - 105):addTo(self.m_bg)
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_1_1")
  label:setString(g_LM:getBy("a00395"))
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_1")
  label:setString(g_LM:getBy("a00396"))
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_1_0")
  label:setString(g_LM:getBy("a00397"))
  self.m_btnLast = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_last")
  local lastServerId = g_LD:GetInt("lastServer")
  if lastServerId and lastServerId ~= 0 then
    do
      local serverInfo
      for i, var in ipairs(self.m_vServers) do
        if var.id == lastServerId then
          serverInfo = var
          break
        end
      end
      if serverInfo then
        local nameLabel = td.CreateLabel(serverInfo.name, td.LIGHT_BLUE, 18)
        td.AddRelaPos(self.m_btnLast, nameLabel, 1, cc.p(0.4, 0.52))
        local stateIcon = display.newSprite("UI/login/state_icon" .. serverInfo.open .. ".png")
        stateIcon = stateIcon or display.newSprite("UI/login/state_icon1.png")
        td.AddRelaPos(self.m_btnLast, stateIcon, 1, cc.p(0.926, 0.554))
        td.BtnAddTouch(self.m_btnLast, function()
          display.getRunningScene():UpdateServer(serverInfo)
          self:close()
        end)
      else
        local nameLabel = td.CreateLabel(g_LM:getBy("a00151"), td.LIGHT_BLUE, 18)
        td.AddRelaPos(self.m_btnLast, nameLabel, 1, cc.p(0.4, 0.52))
      end
    end
  end
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 560, 210),
    touchOnContent = true,
    scale = self.m_scale
  })
  self.m_UIListView:setPosition(35, 65)
  self.m_bg:addChild(self.m_UIListView)
  self:AddTouch()
  local lineCount = math.ceil(#self.m_vServers / 3)
  for i = 1, lineCount do
    local item = self:CreateItem(i)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function ServerDlg:CreateItem(lineIndex)
  local itemNode = cc.uiloader:load("CCS/ServerItem.csb")
  itemNode:setScale(self.m_scale)
  for i = 1, 3 do
    do
      local btn = cc.uiloader:seekNodeByName(itemNode, "Button_" .. i)
      local serverInfo = self.m_vServers[(lineIndex - 1) * 3 + i]
      if serverInfo then
        local nameLabel = td.CreateLabel(serverInfo.name, td.LIGHT_BLUE, 18)
        td.AddRelaPos(btn, nameLabel)
        local stateIcon = display.newSprite("UI/login/state_icon" .. serverInfo.open .. ".png")
        td.AddRelaPos(btn, stateIcon, 1, cc.p(0.895, 0.52))
        td.BtnAddTouch(btn, function()
          display.getRunningScene():UpdateServer(serverInfo)
          self:close()
        end)
        if lineIndex == 1 and i == 1 then
          local newLabel = td.CreateLabel(g_LM:getBy("a00408"), td.GREEN, 18)
          newLabel:setRotation(-30)
          td.AddRelaPos(btn, newLabel, 1, cc.p(0.1, 0.8))
        end
      else
        btn:setVisible(false)
      end
    end
  end
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize(550 * self.m_scale, 53 * self.m_scale)
  return item
end
function ServerDlg:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener1 = cc.EventListenerTouchOneByOne:create()
  listener1:setSwallowTouches(true)
  listener1:registerScriptHandler(function(touch, event)
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
      return false
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener1:registerScriptHandler(function(touch, event)
    self.m_UIListView:onTouch_({
      name = "moved",
      x = touch:getLocation().x,
      y = touch:getLocation().y,
      prevX = touch:getPreviousLocation().x,
      prevY = touch:getPreviousLocation().y
    })
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener1:registerScriptHandler(function(touch, event)
    self.m_UIListView:onTouch_({
      name = "ended",
      x = touch:getLocation().x,
      y = touch:getLocation().y,
      prevX = touch:getPreviousLocation().x,
      prevY = touch:getPreviousLocation().y
    })
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener1, self.m_UIListView)
end
return ServerDlg
