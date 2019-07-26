local SpineProgressBar = class("SpineProgressBar", function(file, size, bgFile)
  return cc.ClippingNode:create()
end)
function SpineProgressBar:ctor(file, size, bgFile)
  self.m_size = size
  self.m_stencil = display.newRect(cc.rect(0, 0, size.width, size.height))
  self.m_stencil:setPosition(0, 0)
  self:setStencil(self.m_stencil)
  self.m_progress = SkeletonUnit:create(file)
  self.m_progress:setScaleX(size.width / self.m_progress:GetContentSize().width)
  self.m_progress:setScaleY(size.height / self.m_progress:GetContentSize().height)
  self.m_progress:setPosition(-self.m_size.width, 0)
  self.m_progress:PlayAni("animation")
  self:addChild(self.m_progress)
  if bgFile then
    local bgSpr = display.newSprite(bgFile)
    bgSpr:setAnchorPoint(0, 0)
    bgSpr:pos(3, 0):scale(size.width / (bgSpr:getContentSize().width * self.m_progress:getScaleX())):addTo(self.m_progress, -1)
  end
  self.m_percent = 0
  self.m_pLockEffect = nil
end
function SpineProgressBar:SetPercent(per)
  self.m_percent = per
  local posX = -self.m_size.width * (1 - per / 100)
  local posY = self.m_progress:getPositionY()
  self.m_progress:runAction(cca.moveTo(0.8, posX, posY))
end
function SpineProgressBar:GetPercent()
  return self.m_percent
end
return SpineProgressBar
