local c = cc
local UIScrollView = c.ui.UIScrollView
local EnhanceListView = class("EnhanceListView", c.ui.UIListView)
function EnhanceListView:ctor(params, root)
  EnhanceListView.super.ctor(self, params)
  self.root = root
  self.bShowArrow = false
  EnhanceListView.super.onTouch(self, function(event)
    if self.bShowArrow then
      if event.name == "nextPage" then
        self.fArrow:setVisible(false)
        self.bArrow:setVisible(true)
      elseif event.name == "perPage" then
        self.fArrow:setVisible(true)
        self.bArrow:setVisible(false)
      elseif event.name == "moved" then
        self.fArrow:setVisible(true)
        self.bArrow:setVisible(true)
      end
    end
    if self.subTouchListener then
      self.subTouchListener(event)
    end
  end)
end
function EnhanceListView:getFirstVisibleItem()
  for i = 1, #self.items_ do
    if self:isItemInViewRect(self.items_[i]) then
      return self.items_[i], i
    end
  end
end
function EnhanceListView:createArrow()
  self.fArrow = display.newSprite("UI/endless/jiantou2_icon.png"):addTo(self.root)
  self.bArrow = display.newSprite("UI/endless/jiantou2_icon.png"):addTo(self.root)
  local offset = 20
  local scalex, scaley = self:getScaleX(), self:getScaleY()
  if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
    self.fArrow:setRotation(-90)
    self.bArrow:setRotation(90)
    self.fArrow:setPosition(self.viewRect_.x - offset * scalex, self.viewRect_.y + self.viewRect_.height / 2 * scaley)
    self.bArrow:setPosition(self.viewRect_.x + (self.viewRect_.width + offset) * scalex, self.viewRect_.y + self.viewRect_.height / 2 * scaley)
  else
    self.bArrow:setFlippedY(true)
    self.fArrow:setPosition(self.viewRect_.x + self.viewRect_.width / 2 * scalex, self.viewRect_.y + (self.viewRect_.height + offset) * scaley)
    self.bArrow:setPosition(self.viewRect_.x + self.viewRect_.width / 2 * scalex, self.viewRect_.y - offset * scaley)
  end
  self.fArrow:setVisible(false)
  self.bArrow:setVisible(true)
  self.bShowArrow = true
end
function EnhanceListView:removeArrow()
  if self.bArrow and self.fArrow then
    self.fArrow:removeFromParent()
    self.bArrow:removeFromParent()
    self.fArrow = nil
    self.bArrow = nil
  end
  self.bShowArrow = false
end
function EnhanceListView:reload()
  EnhanceListView.super.reload(self)
  self:removeArrow()
  if self.direction == UIScrollView.DIRECTION_VERTICAL and self.size.height > self.viewRect_.height or self.direction == UIScrollView.DIRECTION_HORIZONTAL and self.size.width > self.viewRect_.width then
    self:createArrow()
  end
end
function EnhanceListView:onTouch(listener)
  self.subTouchListener = listener
end
function EnhanceListView:checkArrowStatus()
  if #self.items_ == 0 or not self.fArrow or not self.bArrow then
    return
  end
  local fNeed, bNeed = self:isNeedArrow()
  if fNeed then
    self.fArrow:setVisible(true)
  else
    self.fArrow:setVisible(false)
  end
  if bNeed then
    self.bArrow:setVisible(true)
  else
    self.bArrow:setVisible(false)
  end
end
function EnhanceListView:isNeedArrow()
  local nodePoint
  local viewRectPos = self.container:convertToWorldSpace(cc.p(self.viewRect_.x, self.viewRect_.y))
  local viewRect = cc.rect(viewRectPos.x, viewRectPos.y, self.viewRect_.width, self.viewRect_.height)
  local fItem = self.items_[1]
  local bound = fItem:getBoundingBox()
  if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
    nodePoint = self.container:convertToWorldSpace(c.p(bound.x, bound.y))
  else
    nodePoint = self.container:convertToWorldSpace(c.p(bound.x, bound.y + bound.height))
  end
  local fNeed = not c.rectContainsPoint(viewRect, nodePoint)
  local bItem = self.items_[#self.items_]
  bound = bItem:getBoundingBox()
  if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
    nodePoint = self.container:convertToWorldSpace(c.p(bound.x + bound.width, bound.y))
  else
    nodePoint = self.container:convertToWorldSpace(c.p(bound.x, bound.y))
  end
  local bNeed = not c.rectContainsPoint(viewRect, nodePoint)
  return fNeed, bNeed
end
function EnhanceListView:getAllItem()
  return self.items_
end
function EnhanceListView:getFirstItem()
  return self.items_[1]
end
function EnhanceListView:getLastItem()
  return self.items_[#self.items_]
end
return EnhanceListView
