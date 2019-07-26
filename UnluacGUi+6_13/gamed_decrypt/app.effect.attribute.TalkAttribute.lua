local AttributeBase = import(".AttributeBase")
local TalkAtrribute = class("TalkAtrribute", AttributeBase)
function TalkAtrribute:ctor(pEffect, fNextAttributeTime, data)
  TalkAtrribute.super.ctor(self, td.AttributeType.Talk, pEffect, fNextAttributeTime)
  self.m_touchAnim = data.touchAnim
  self.m_defAnim = data.defAnim
  self.m_word = data.word
  self.m_dir = data.isLeft and -1 or 1
  self.m_autoTime = data.time
  self.m_autoOver = data.autoOver
  self.m_clickOver = data.clickOver
  self.m_isMove = false
  self.m_bIsTalking = false
end
function TalkAtrribute:Active()
  TalkAtrribute.super.Active(self)
  if self.m_autoTime then
    self.m_pEffect:runAction(cca.seq({
      cca.delay(self.m_autoTime),
      cca.cb(function()
        self:StartTalking()
      end)
    }))
  else
    self:AddTouch()
  end
  if self.m_autoOver then
    self:SetOver()
  end
end
function TalkAtrribute:AddTouch()
  local pTouchListener = cc.EventListenerTouchOneByOne:create()
  pTouchListener:setSwallowTouches(true)
  pTouchListener:registerScriptHandler(function(_touch, _event)
    local rect = self.m_pEffect:GetBoundingBox()
    local pos = _touch:getLocation()
    pos = self.m_pEffect:convertToNodeSpace(cc.p(pos.x, pos.y))
    if cc.rectContainsPoint(rect, pos) then
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  pTouchListener:registerScriptHandler(function(touch, event)
    local newPos = cc.p(touch:getLocation())
    local prePos = cc.p(touch:getPreviousLocation())
    if cc.pGetDistance(newPos, prePos) > 5 then
      self.m_isMove = true
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  pTouchListener:registerScriptHandler(function(_touch, _event)
    if not self.m_isMove then
      self:StartTalking()
    end
    self.m_isMove = false
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self.m_pEffect:getEventDispatcher():addEventListenerWithSceneGraphPriority(pTouchListener, self.m_pEffect)
end
function TalkAtrribute:StartTalking()
  if self.m_bIsTalking then
    return
  end
  self.m_bIsTalking = true
  if self.m_clickOver then
    self:SetOver()
  end
  if self.m_touchAnim and td.EffectType.Spine == self.m_pEffect:GetType() then
    self.m_pEffect:GetContentNode():PlayAni(self.m_touchAnim, true)
  end
  local width = 140
  local wordLabel = td.CreateLabel(g_LM:getBy(self.m_word), display.COLOR_BLACK, 14, nil, nil, cc.size(width, 0))
  local height = wordLabel:getContentSize().height
  height = cc.clampf(50 + height, 90, 500)
  wordLabel:setAnchorPoint(0, 0.5)
  wordLabel:setScaleX(self.m_dir)
  wordLabel:setVisible(false)
  if self.m_dir == 1 then
    wordLabel:pos(10, 30 + (height - 30) / 2)
  else
    wordLabel:pos(width + 10, 30 + (height - 30) / 2)
  end
  local talkBubble = display.newScale9Sprite("UI/common/duihuakuang.png", 0, 0, cc.size(165, height), cc.rect(75, 40, 10, 10))
  wordLabel:addTo(talkBubble)
  talkBubble:setAnchorPoint(0, 0)
  talkBubble:pos(0, self.m_pEffect:GetContentSize().height):opacity(0):scale(0.01):addTo(self.m_pEffect)
  talkBubble:runAction(cca.seq({
    cca.spawn({
      cca.scaleTo(0.1, 2.7 * self.m_dir, 2.7),
      cca.fadeIn(0.1)
    }),
    cca.scaleTo(0.05, 2.5 * self.m_dir, 2.5),
    cca.cb(function()
      wordLabel:setVisible(true)
    end),
    cca.delay(5),
    cca.cb(function()
      talkBubble:removeAllChildren()
    end),
    cca.fadeOut(0.5),
    cca.cb(function()
      self:ClickAnimEnd()
    end),
    cca.removeSelf()
  }))
end
function TalkAtrribute:ClickAnimEnd()
  self.m_bIsTalking = false
  if self.m_defAnim and td.EffectType.Spine == self.m_pEffect:GetType() then
    self.m_pEffect:GetContentNode():PlayAni(self.m_defAnim, true)
  end
  self:SetOver()
end
return TalkAtrribute
