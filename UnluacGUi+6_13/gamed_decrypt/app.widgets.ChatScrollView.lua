local EnhanceScrollView = require("app.widgets.EnhanceScrollView")
local ChatScrollView = class("ChatScrollView", EnhanceScrollView)
function ChatScrollView:ctor()
  ChatScrollView.super.ctor(self)
  self:setNodeEventEnabled(true)
  self.m_showViews = {}
  self.m_maxCount = nil
  self.m_col = 1
  self.m_scrollDir = ccui.ScrollViewDir.vertical
end
function ChatScrollView:Create(parent, size, position, maxCnt)
  local chatSView = require("app.widgets.ChatScrollView"):new()
  chatSView:setDirection(1)
  chatSView:setSize(size.width, size.height)
  chatSView:initAttribute(0, 1, 15, 0, 0, 0, 0, 0)
  chatSView:setBounceEnabled(true)
  parent:addChild(chatSView, 10)
  chatSView:setPosition(position)
  chatSView:setAnchorPoint(cc.p(0.5, 0))
  chatSView:setMax(maxCnt)
  return chatSView
end
function ChatScrollView:onEnter()
  ChatScrollView.super.onEnter(self)
end
function ChatScrollView:onExit()
  ChatScrollView.super.onExit(self)
end
function ChatScrollView:setMax(max)
  self.m_maxCount = max
end
function ChatScrollView:relayer()
  local cellCount = #self.m_showViews
  if cellCount == 0 then
    return
  end
  local innerSize = {}
  local item_height = 0
  for i = 0, cellCount - 1 do
    item_height = item_height + self.m_showViews[i + 1]:getBoundingBox().height
  end
  if self.m_scrollDir == ccui.ScrollViewDir.horizontal then
  elseif self.m_scrollDir == ccui.ScrollViewDir.vertical then
    local offset = 0
    self.m_row = cellCount / self.m_col
    if cellCount % self.m_col ~= 0 then
      offset = 1
    end
    self.m_row = self.m_row + offset
    innerSize.width = self.m_width
    innerSize.height = self.m_upGap * 2 + item_height + (self.m_row - 1) * self.m_gapY
  end
  self:setInnerContainerSize(innerSize)
  self:getInnerContainer():setPositionY(0)
  local posTmp = {}
  local rowIndex = 0
  local colIndex = 0
  local tmpHeight = 0
  for i = 0, cellCount - 1 do
    local cellSize = self.m_showViews[i + 1]:getBoundingBox()
    tmpHeight = tmpHeight + cellSize.height
    if self.m_scrollDir == ccui.ScrollViewDir.horizontal then
      rowIndex = i % self.m_row
      colIndex = math.floor(i / self.m_row)
    elseif self.m_scrollDir == ccui.ScrollViewDir.vertical then
      colIndex = i % self.m_col
      rowIndex = math.floor(i / self.m_col)
    end
    posTmp.x = self.m_leftGap + colIndex * (cellSize.width + self.m_gapX)
    posTmp.y = innerSize.height - (self.m_upGap + tmpHeight)
    self.m_showViews[i + 1]:setPosition(posTmp.x, posTmp.y)
  end
end
function ChatScrollView:append(node)
  if self.m_maxCount and #self.m_showViews >= self.m_maxCount then
    self.m_showViews[1]:removeFromParent()
    table.remove(self.m_showViews, 1)
  end
  local viewItem = self:addView(node)
  table.insert(self.m_showViews, viewItem)
  self:updateView()
end
return ChatScrollView
