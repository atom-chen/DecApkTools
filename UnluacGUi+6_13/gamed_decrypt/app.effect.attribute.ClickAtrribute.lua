local AttributeBase = import(".AttributeBase")
local BuffManager = require("app.buff.BuffManager")
local ClickAtrribute = class("ClickAtrribute", AttributeBase)
function ClickAtrribute:ctor(pEffect, fNextAttributeTime, data)
  ClickAtrribute.super.ctor(self, td.AttributeType.Click, pEffect, fNextAttributeTime)
  self.m_pTouchListener = nil
  self.m_iClick = data.click
  self.m_iCurClick = 0
  self.m_bIsClicking = false
  self.m_isMove = false
  self.m_touchAnim = data.touchAnim
  self.m_defAnim = data.defAnim
  self.m_scaleAnim = true
  if false == data.scaleAnim then
    self.m_scaleAnim = false
  end
  self.m_isLoop = false
  if true == data.isLoop then
    self.m_isLoop = true
  end
  self.m_overRemove = false
  if data.overRemove == true then
    self.m_overRemove = true
  end
  self.m_bSwallow = true
  if data.isSwallow == false then
    self.m_bSwallow = false
  end
end
function ClickAtrribute:Active()
  ClickAtrribute.super.Active(self)
  self:AddTouch()
  if self.m_iClick == -1 then
    self:SetOver()
  end
  self:AddClickCallback()
end
function ClickAtrribute:Update(dt)
  ClickAtrribute.super.Update(self, dt)
  if self.m_overRemove and self:IsOver() then
    self.m_pEffect:SetRemove()
  end
end
function ClickAtrribute:AddClickCallback()
  if self.m_touchAnim and td.EffectType.Spine == self.m_pEffect:GetType() then
    self.m_pEffect:SetClickCallback(function()
      self.m_pEffect:GetContentNode():PlayAni(self.m_touchAnim, false, false)
      self.m_pEffect:GetContentNode():registerSpineEventHandler(function(event)
        if event.animation == self.m_touchAnim then
          self:ClickAnimEnd()
        end
      end, sp.EventType.ANIMATION_END)
    end)
  end
end
function ClickAtrribute:AddTouch()
  self.m_pTouchListener = cc.EventListenerTouchOneByOne:create()
  self.m_pTouchListener:setSwallowTouches(self.m_bSwallow)
  self.m_pTouchListener:registerScriptHandler(function(_touch, _event)
    if self.m_iClick == -1 or self.m_iCurClick < self.m_iClick then
      local rect = self.m_pEffect:GetBoundingBox()
      local pos = _touch:getLocation()
      pos = self.m_pEffect:convertToNodeSpace(cc.p(pos.x, pos.y))
      if cc.rectContainsPoint(rect, pos) then
        return true
      end
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  self.m_pTouchListener:registerScriptHandler(function(touch, event)
    local newPos = cc.p(touch:getLocation())
    local prePos = cc.p(touch:getPreviousLocation())
    if cc.pGetDistance(newPos, prePos) > 5 then
      self.m_isMove = true
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  self.m_pTouchListener:registerScriptHandler(function(_touch, _event)
    if (self.m_iClick == -1 or self.m_iCurClick < self.m_iClick) and not self.m_isMove then
      self:DidClick()
    end
    self.m_isMove = false
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self.m_pEffect:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_pTouchListener, self.m_pEffect)
end
function ClickAtrribute:DidClick()
  if self.m_bIsClicking then
    return
  end
  self.m_bIsClicking = true
  self.m_iCurClick = self.m_iCurClick + 1
  if self.m_iClick == -1 or self.m_iCurClick <= self.m_iClick then
    if self.m_scaleAnim then
      local duration = 0.1
      local scaleX, scaleY = self.m_pEffect:getScaleX(), self.m_pEffect:getScaleY()
      local action = cca.seq({
        cca.scaleTo(duration, scaleX * 1.1, scaleY * 1.1),
        cca.scaleTo(duration, scaleX * 0.95, scaleY * 0.95),
        cca.scaleTo(duration, scaleX, scaleY),
        cca.cb(function()
          if self.m_touchAnim and td.EffectType.Spine == self.m_pEffect:GetType() then
            self.m_pEffect:OnClicked()
          else
            self:ClickAnimEnd()
          end
        end)
      })
      self.m_pEffect:runAction(action)
    elseif self.m_touchAnim and td.EffectType.Spine == self.m_pEffect:GetType() then
      self.m_pEffect:OnClicked()
    else
      self:ClickAnimEnd()
    end
    if self.m_iCurClick == self.m_iClick or -1 == self.m_iClick then
      self:SetOver()
    end
  end
end
function ClickAtrribute:ClickAnimEnd()
  self.m_bIsClicking = false
  if self.m_touchAnim and td.EffectType.Spine == self.m_pEffect:GetType() then
    if self.m_isLoop then
      self.m_pEffect:performWithDelay(function()
        self.m_pEffect:GetContentNode():PlayAni(self.m_touchAnim, true, false)
      end, 0.016666666666666666)
    elseif self.m_defAnim then
      self.m_pEffect:performWithDelay(function()
        self.m_pEffect:GetContentNode():PlayAni(self.m_defAnim, true, false)
      end, 0.016666666666666666)
    end
  end
end
return ClickAtrribute
