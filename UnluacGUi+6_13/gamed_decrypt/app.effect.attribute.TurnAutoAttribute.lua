local AttributeBase = import(".AttributeBase")
local TurnAutoAttribute = class("TurnAutoAttribute", AttributeBase)
local ACTIONTAG = 2121
function TurnAutoAttribute:ctor(pEffect, fNextAttributeTime, data)
  TurnAutoAttribute.super.ctor(self, td.AttributeType.TurnAuto, pEffect, fNextAttributeTime)
  self.m_minDelay = data.minTime or 5
  self.m_maxTime = data.maxTime or 10
  self.m_scale = 1
  self.m_moveAnim = data.moveAnim
  self.m_moveXOffset = data.xOffset or 10
  self.m_speed = data.speed or 200
  self.m_action = nil
end
function TurnAutoAttribute:Active()
  TurnAutoAttribute.super.Active(self)
  local v = math.random(1, 2)
  if 1 == v then
    self.m_scale = self.m_scale * -1
    self.m_moveXOffset = self.m_moveXOffset * -1
  end
  local contentNode = self.m_pEffect:GetContentNode()
  if contentNode then
    contentNode:setScaleX(self.m_scale)
    local delay = math.random(self.m_minDelay, self.m_maxTime)
    contentNode:schedule(function()
      if not self:IsRemove() then
        self.m_scale = self.m_scale * -1
        contentNode:setScaleX(self.m_scale)
        contentNode:stopActionByTag(ACTIONTAG)
      end
    end, delay)
  end
  if nil ~= self.m_moveAnim then
    contentNode:registerSpineEventHandler(function(event)
      if event.animation == self.m_moveAnim and not self:IsRemove() and self.m_moveXOffset * contentNode:getScaleX() > 0 then
        local yOff = 0
        local normal = cc.p(self.m_moveXOffset, yOff)
        contentNode:stopActionByTag(ACTIONTAG)
        self.m_action = cca.moveBy(math.abs(self.m_moveXOffset / self.m_speed), normal.x, normal.y)
        self.m_action:setTag(ACTIONTAG)
        contentNode:runAction(self.m_action)
        self.m_moveXOffset = self.m_moveXOffset * -1
      end
    end, sp.EventType.ANIMATION_START)
  end
end
function TurnAutoAttribute:Update(dt)
  TurnAutoAttribute.super.Update(self, dt)
  if self.m_bExecuteNextAttribute then
    self:SetOver()
  end
end
return TurnAutoAttribute
