local UnitGizmo = class("UnitGizmo", function()
  return display.newNode()
end)
function UnitGizmo:ctor(unitSpinePath)
  self:CreateSpine(unitSpinePath)
end
function UnitGizmo:CreateSpine(unitSpinePath)
  self.m_unitSpine = SkeletonUnit:create(unitSpinePath)
  self.m_unitSpine:setScale(0.5)
  self.m_unitSpine:PlayAni("stand")
  self.m_unitSpine:addTo(self)
end
function UnitGizmo:AddTouchEvent()
end
return UnitGizmo
