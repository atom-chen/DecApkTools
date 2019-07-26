local GuildContentBase = require("app.layers.guild.GuildContentBase")
local TDHttpRequest = require("app.net.TDHttpRequest")
local GuildReport = class("GuildReport", GuildContentBase)
function GuildReport:ctor(height)
  GuildReport.super.ctor(self, height)
  self.m_vLogs = {}
  self:InitUI()
end
function GuildReport:onEnter()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetGuildLog, handler(self, self.GetGuildLogCallback))
  self:AddTouch()
  self:SendGetLog()
end
function GuildReport:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetGuildLog)
  GuildReport.super.onExit(self)
end
function GuildReport:InitUI()
  self:LoadUI("CCS/guild/GuildInfo.csb")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_bg:removeAllChildren()
  self:CreateList()
end
function GuildReport:CreateList()
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(30, 20, 860, self.m_bgHeight - 50),
    touchOnContent = false,
    scale = td.GetAutoScale()
  })
  self.m_bg:addChild(self.m_UIListView, 1)
end
function GuildReport:RefreshList()
  self.m_UIListView:removeAllItems()
  for i, var in ipairs(self.m_vLogs) do
    local item = self:CreateItem(var)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function GuildReport:CreateItem(data)
  local bgSize = cc.size(860, 80)
  local itemNode = display.newNode()
  itemNode:setContentSize(bgSize)
  itemNode:scale(self.m_scale)
  local label = self:CreateSysMsg(data)
  label:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itemNode, label, 1, cc.p(0.1, 0.5))
  local timeLabel = td.CreateLabel(td.GetSimpleTime(data.time))
  td.AddRelaPos(itemNode, timeLabel, 1, cc.p(0.85, 0.5))
  local lineSpr = display.newSprite("UI/common/fengexian_shu.png")
  lineSpr:setScaleX(bgSize.width / lineSpr:getContentSize().width)
  td.AddRelaPos(itemNode, lineSpr, 1, cc.p(0.5, 0))
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize(bgSize.width * self.m_scale, bgSize.height * self.m_scale)
  return item
end
function GuildReport:CreateSysMsg(data)
  local tmp = td.GetSysMsg(data)
  local param = {}
  for i, var in ipairs(tmp) do
    local _color = td.WHITE
    if i % 2 == 0 then
      _color = td.YELLOW
    end
    table.insert(param, {
      type = 1,
      str = var,
      color = _color,
      size = 20
    })
  end
  return td.RichText(param)
end
function GuildReport:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if not self:isVisible() then
      return false
    end
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
      return true
    end
    return false
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
function GuildReport:SendGetLog()
  local Msg = {}
  Msg.msgType = td.RequestID.GetGuildLog
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildReport:GetGuildLogCallback(data)
  self.m_vLogs = data.guildLogProto
  table.sort(self.m_vLogs, function(a, b)
    return a.time > b.time
  end)
  self:RefreshList()
end
return GuildReport
