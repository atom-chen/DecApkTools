local MaskLayer = class("MaskLayer", function(alpha)
  return cc.LayerColor:create(cc.c4b(td.WIN_COLOR.r, td.WIN_COLOR.g, td.WIN_COLOR.b, alpha))
end)
function MaskLayer:ctor(alpha, bHaveBg)
  self.m_yOffset = 800
  self.m_xOffset = 800
  self:changeWidthAndHeight(display.width + self.m_xOffset * 2, display.height + self.m_yOffset * 2)
  self:BlockTouch()
  if bHaveBg then
    self.bg = display.newSprite("UI/common/uibg.png")
    self.bg:scale(display.width / self.bg:getContentSize().width):addTo(self)
    self.bg:pos(display.width / 2 + self.m_xOffset, display.height / 2 + self.m_yOffset)
  end
end
function MaskLayer:BlockTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(touch, event)
    print("MaskLayer Worked! ")
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:setSwallowTouches(true)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function MaskLayer:SetBg(file)
  if self.bg then
    td.setTexture(self.bg, file)
  end
end
function MaskLayer:onEnter()
end
function MaskLayer:onExit()
end
return MaskLayer
