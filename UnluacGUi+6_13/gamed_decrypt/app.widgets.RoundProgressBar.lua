local RoundProgressBar = class("RoundProgressBar", function(file)
  return cc.ClippingNode:create()
end)
function RoundProgressBar:ctor(file)
  self:setAlphaThreshold(0.3)
  self.m_stencil = display.newSprite(file)
  self.m_stencil:setPosition(0, 0)
  self:setStencil(self.m_stencil)
  self.m_progress = display.newSprite(file)
  self.m_progress:setPosition(0, 0)
  self:addChild(self.m_progress)
  self.m_size = self.m_stencil:getContentSize()
  self.m_percent = 100
end
function RoundProgressBar:SetPercent(per)
  self.m_percent = per
  self.m_progress:setPositionX(-self.m_size.width * (1 - per / 100))
end
function RoundProgressBar:GetPercent()
  return self.m_percent
end
return RoundProgressBar
