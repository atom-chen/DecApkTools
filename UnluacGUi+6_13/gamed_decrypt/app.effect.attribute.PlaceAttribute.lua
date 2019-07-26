local AttributeBase = import(".AttributeBase")
local PlaceAttribute = class("PlaceAttribute", AttributeBase)
PlaceAttribute.PlaceType = {
  Relative = 0,
  Absolute = 1,
  Actor = 2
}
function PlaceAttribute:ctor(pEffect, fNextAttributeTime, ePlaceType, pos, range)
  PlaceAttribute.super.ctor(self, td.AttributeType.Place, pEffect, fNextAttributeTime)
  self.m_ePlaceType = ePlaceType
  if pos then
    self.m_pos = pos
  else
    self.m_pos = cc.p(self.m_pEffect:getPosition())
  end
  self.m_range = range
end
function PlaceAttribute:Active()
  PlaceAttribute.super.Active(self)
  if self.m_range then
    local randx = self.m_range.x > 1 and math.random(self.m_range.x) - self.m_range.x / 2 or 0
    local randy = 1 < self.m_range.y and math.random(self.m_range.y) - self.m_range.y / 2 or 0
    self.m_iRandomPos = cc.p(randx, randy)
  end
  if self.m_ePlaceType == PlaceAttribute.PlaceType.Actor then
    self.m_pos = self.m_pEffect:UpdateTargetPos()
  elseif self.m_iRandomPos then
    self.m_pos = cc.pAdd(self.m_iRandomPos, self.m_pos)
  end
  if self.m_ePlaceType == PlaceAttribute.PlaceType.Relative then
    local effPos = cc.p(self.m_pEffect:getPosition())
    self.m_pEffect:setPosition(cc.pAdd(self.m_pos, effPos))
  else
    self.m_pEffect:setPosition(self.m_pos)
  end
  self:SetOver()
end
return PlaceAttribute
