local RightButton = class("RightButton", function()
  return display.newScale9Sprite("UI/scale9/transparent1x1.png", 0, 0, cc.size(90, 90))
end)
function RightButton:ctor(effectFile, cb)
  self.callback = cb
  self.radiusSQ = 2025
  self:InitUI(effectFile)
  self:setNodeEventEnabled(true)
end
function RightButton:onEnter()
  self:AddTouch()
end
function RightButton:onExit()
end
function RightButton:InitUI(effectFile)
  self.effect = SkeletonUnit:create(effectFile)
  self.effect:PlayAni("animation_01", true)
  self.effect:setTimeScale(0.5)
  td.AddRelaPos(self, self.effect)
  self.effect:registerSpineEventHandler(function(event)
    if event.animation == "animation_02" then
      if self.callback then
        self.callback()
      end
      self.effect:setTimeScale(0.5)
      self.effect:PlayAni("animation_01", true)
      self:performWithDelay(function()
        g_MC:SetEnableUI(true)
      end, 0.3)
    end
  end, sp.EventType.ANIMATION_COMPLETE)
end
function RightButton:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    if not g_MC:GetEnableUI() then
      return false
    end
    local pos = _touch:getLocation()
    pos = self:getParent():convertToNodeSpace({
      x = pos.x,
      y = pos.y
    })
    if self:_CheckTouchIn(pos) then
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function RightButton:_CheckTouchIn(pos)
  return cc.pDistanceSQ(cc.p(self:getPosition()), pos) <= self.radiusSQ
end
function RightButton:onTouchEnded()
  g_MC:UpdateOpTime()
  local onlyName = g_MC:GetOnlyEnableName()
  if onlyName and onlyName ~= "" and onlyName ~= self:getName() then
    return
  end
  g_MC:SetEnableUI(false)
  self.effect:setTimeScale(1)
  self.effect:PlayAni("animation_02", false)
  G_SoundUtil:PlaySound(54, false)
end
function RightButton:UpdateEffect(spFile)
  if self.effect then
    self.effect:removeFromParent()
    self.effect = nil
  end
  self:InitUI(spFile)
end
return RightButton
