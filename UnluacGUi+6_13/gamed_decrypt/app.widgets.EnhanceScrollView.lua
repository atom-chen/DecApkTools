local EnhanceScrollView = class("EnhanceScrollView", function()
  return ccui.ScrollView:create()
end)
local DIRECTION_HORIZONTAL = 0
local DIRECTION_VERTICAL = 1
function EnhanceScrollView:ctor()
  self:setNodeEventEnabled(true)
  self.m_allViews = {}
  self.m_showViews = {}
  self:initAttribute()
  self:setTouchEnabled(true)
  self:addTouch()
end
function EnhanceScrollView:onEnter()
end
function EnhanceScrollView:onExit()
  for k, view in pairs(self.m_allViews) do
    if view ~= nil then
      view:release()
    end
  end
  self:getEventDispatcher():removeEventListenersForTarget(self)
end
function EnhanceScrollView:initAttribute(_row, _col, _leftGap, _rightGap, _bottomGap, _upGap, _gapX, _gapY)
  if _row ~= nil then
    self.m_row = _row
  else
    self.m_row = 1
  end
  if _col ~= nil then
    self.m_col = _col
  else
    self.m_col = 1
  end
  if _leftGap ~= nil then
    self.m_leftGap = _leftGap
  else
    self.m_leftGap = 0
  end
  if _rightGap ~= nil then
    self.m_rightGap = _rightGap
  else
    self.m_rightGap = 0
  end
  if _bottomGap ~= nil then
    self.m_bottomGap = _bottomGap
  else
    self.m_bottomGap = 0
  end
  if _upGap ~= nil then
    self.m_upGap = _upGap
  else
    self.m_upGap = 0
  end
  if _gapX ~= nil then
    self.m_gapX = _gapX
  else
    self.m_gapX = 0
  end
  if _gapY ~= nil then
    self.m_gapY = _gapY
  else
    self.m_gapY = 0
  end
end
function EnhanceScrollView:setDirection(_scrollDir)
  self.m_scrollDir = _scrollDir
end
function EnhanceScrollView:setSize(_width, _height)
  self.m_width = _width
  self.m_height = _height
  self:setContentSize(self.m_width, self.m_height)
end
function EnhanceScrollView:addViews(views)
  for k, view in pairs(views) do
    self:addView(view)
  end
end
function EnhanceScrollView:addView(view)
  local viewItem = ccui.Layout:create()
  local consize = view:getContentSize()
  viewItem:setContentSize(consize.width, consize.height)
  viewItem:addChild(view, 1, 1)
  view:setPosition(consize.width * 0.5, consize.height * 0.5)
  viewItem:setAnchorPoint(cc.p(0.5, 0.5))
  viewItem:retain()
  table.insert(self.m_allViews, viewItem)
  return viewItem
end
function EnhanceScrollView:updateView()
  self:removeAllChildren()
  for k, view in pairs(self.m_showViews) do
    self:addChild(view)
  end
  self:relayer()
end
function EnhanceScrollView:relayer()
  local cellCount = #self.m_showViews
  if cellCount == 0 then
    return
  end
  local cellSize = self.m_showViews[1]:getBoundingBox()
  local innerSize = {}
  if self.m_scrollDir == ccui.ScrollViewDir.horizontal then
    local offset = 0
    if cellCount % self.m_row ~= 0 then
      offset = 1
    end
    self.m_col = cellCount / self.m_row + offset
    innerSize.width = self.m_leftGap * 2 + self.m_col * cellSize.width + (self.m_col - 1) * self.m_gapX
    if innerSize.width < self.m_width then
      innerSize.width = m_width
    end
    innerSize.height = self.m_height
  elseif self.m_scrollDir == ccui.ScrollViewDir.vertical then
    local offset = 0
    self.m_row = cellCount / self.m_col
    if cellCount % self.m_col ~= 0 then
      offset = 1
    end
    self.m_row = self.m_row + offset
    innerSize.width = self.m_width
    innerSize.height = self.m_upGap * 2 + self.m_row * cellSize.height + (self.m_row - 1) * self.m_gapY
    if innerSize.height < self.m_height then
      innerSize.height = self.m_height
    end
    self:getInnerContainer():setPositionY(self.m_height - innerSize.height)
  end
  self:setInnerContainerSize(innerSize)
  local posTmp = {}
  local rowIndex = 0
  local colIndex = 0
  for i = 0, cellCount - 1 do
    if self.m_scrollDir == ccui.ScrollViewDir.horizontal then
      rowIndex = i % self.m_row
      colIndex = math.floor(i / self.m_row)
    elseif self.m_scrollDir == ccui.ScrollViewDir.vertical then
      colIndex = i % self.m_col
      rowIndex = math.floor(i / self.m_col)
    end
    posTmp.x = self.m_leftGap + colIndex * (cellSize.width + self.m_gapX)
    posTmp.y = innerSize.height - (self.m_upGap + rowIndex * (cellSize.height + self.m_gapY))
    posTmp.x = posTmp.x + cellSize.width * 0.5
    posTmp.y = posTmp.y - cellSize.height * 0.5
    self.m_showViews[i + 1]:setPosition(posTmp.x, posTmp.y)
  end
end
function EnhanceScrollView:fiter(func)
  self.m_showViews = {}
  if func == nil then
    self.m_showViews = self.m_allViews
  end
  self:updateView()
end
function EnhanceScrollView:registerItemClickCallback(callback)
  self.m_itemClickCallback = callback
end
function EnhanceScrollView:addTouch()
  if self.m_eventListener == nil then
    local listener = cc.EventListenerTouchOneByOne:create()
    self.m_eventListener = listener
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(function(_touch, _event)
      local rect = _event:getCurrentTarget():getBoundingBox()
      local pos = _touch:getLocation()
      pos = self:getParent():convertToNodeSpace({
        x = pos.x,
        y = pos.y
      })
      if cc.rectContainsPoint(rect, pos) then
        self:onTouchBegan(_touch)
        return true
      end
      return false
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(_touch, _event)
      self:onTouchMoved(_touch)
    end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(_touch, _event)
      self:onTouchEnded(_touch)
    end, cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
  end
end
function EnhanceScrollView.viewContainsPoint(_view, _pos)
  local rect = _view:getBoundingBox()
  pos = _view:getParent():convertToNodeSpace({
    x = _pos.x,
    y = _pos.y
  })
  if cc.rectContainsPoint(rect, pos) then
    return true
  end
  return false
end
function EnhanceScrollView:onTouchBegan(_touch)
  self.m_isTouching = true
  local pos = _touch:getLocation()
  for k, view in pairs(self.m_showViews) do
    if EnhanceScrollView.viewContainsPoint(view, pos) then
      self.m_clickView = view
      break
    end
  end
end
function EnhanceScrollView:onTouchMoved(_touch)
  if self.m_isTouching then
    local distanceSQ = cc.pDistanceSQ(_touch:getLocation(), _touch:getStartLocation())
    if distanceSQ < 100 then
      return
    end
    if self.m_clickView then
      self.m_clickView = nil
    end
  end
end
function EnhanceScrollView:onTouchEnded(_touch)
  local _pos = _touch:getLocation()
  if self.m_isTouching then
    if self.m_clickView and self.m_itemClickCallback then
      self.m_itemClickCallback(self.m_clickView:getChildByTag(1))
    end
    self.m_isTouching = false
  end
  self.m_clickView = nil
end
return EnhanceScrollView
