local SpineEffect = import(".SpineEffect")
local EffectManager = import(".EffectManager")
local ClickBombEffect = class("ClickBombEffect", SpineEffect)
ClickBombEffect.CanClickTime = 5
ClickBombEffect.State = {
  CannotClick = 0,
  CanClick = 1,
  Clicked = 2,
  TimeOver = 3
}
function ClickBombEffect:ctor(pActorBase, pTargetActor, pEffectInfo)
  ClickBombEffect.super.ctor(self, pActorBase, pTargetActor, pEffectInfo)
  self.m_iState = ClickBombEffect.State.CannotClick
  self.m_iTimeInterval = 0
  self.m_pProgress = nil
  self.m_pTouchListener = nil
  self:AddMembers(pEffectInfo.members)
end
function ClickBombEffect:onEnter()
  ClickBombEffect.super.onEnter(self)
  self:AddTouch()
end
function ClickBombEffect:onExit()
  ClickBombEffect.super.onExit(self)
  if self.m_pTouchListener then
    self:getEventDispatcher():removeEventListener(self.m_pTouchListener)
    self.m_pTouchListener = nil
  end
end
function ClickBombEffect:Update(dt)
  ClickBombEffect.super.Update(self, dt)
  if self:IsRemove() then
    return
  end
  if self.m_iState == ClickBombEffect.State.CannotClick then
    if self:IsAllAttributeOver() then
      self:CreateTimer()
      self.m_iState = ClickBombEffect.State.CanClick
    end
  elseif self.m_iState == ClickBombEffect.State.CanClick then
    self.m_iTimeInterval = self.m_iTimeInterval + dt
    if self.m_iTimeInterval >= ClickBombEffect.CanClickTime then
      self:OnTimeOver()
      self.m_iTimeInterval = 0
    end
  end
end
function ClickBombEffect:AddTouch()
  self.m_pTouchListener = cc.EventListenerTouchOneByOne:create()
  self.m_pTouchListener:setSwallowTouches(true)
  self.m_pTouchListener:registerScriptHandler(function(_touch, _event)
    if self.m_iState == ClickBombEffect.State.CanClick then
      local x, y = self:getPosition()
      local size = self:GetContentSize()
      size.width = size.width * self:getScaleX()
      size.height = size.height * self:getScaleY()
      local rect = cc.rect(x - size.width / 2, y, size.width, size.height)
      local pos = _touch:getLocation()
      pos = self:getParent():convertToNodeSpace(cc.p(pos.x, pos.y))
      if cc.rectContainsPoint(rect, pos) then
        return true
      end
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  self.m_pTouchListener:registerScriptHandler(function(_touch, _event)
    if self.m_iState == ClickBombEffect.State.CanClick then
      self:DidClick()
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithFixedPriority(self.m_pTouchListener, -1)
end
function ClickBombEffect:CreateTimer()
  self.m_pProgress = cc.ProgressTimer:create(display.newSprite("Effect/bombtime/bombtime_02.png"))
  self.m_pProgress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
  self.m_pProgress:setReverseDirection(true)
  self.m_pProgress:setPercentage(0)
  self.m_pProgress:setRotation(120)
  self.m_pProgress:setSkewY(-45)
  self.m_pProgress:runAction(cca.seq({
    cca.progressTo(ClickBombEffect.CanClickTime, 100),
    cca.removeSelf()
  }))
  self:addChild(self.m_pProgress, -1)
  local bg = display.newSprite("Effect/bombtime_01.png")
  local contentSize = bg:getContentSize()
  bg:setPosition(contentSize.width / 2, contentSize.height / 2)
  self.m_pProgress:addChild(bg, -1)
  local pointer = display.newSprite("Effect/bombtime_03.png")
  pointer:setPosition(contentSize.width / 2, contentSize.height / 2)
  pointer:runAction(cca.rotateBy(ClickBombEffect.CanClickTime, -360))
  self.m_pProgress:addChild(pointer, 1)
end
function ClickBombEffect:DidClick()
  if self.m_iState == ClickBombEffect.State.CanClick then
    self.m_iState = ClickBombEffect.State.Clicked
  end
  self:SetRemove()
end
function ClickBombEffect:OnTimeOver()
  self.m_iState = ClickBombEffect.State.TimeOver
  self.m_iTargetActorTag = self:FindTarget()
  self:ClearAllAttribute()
  self.m_bAttrOverRemoveSelf = true
  local effectInfo = {
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation_03",
        loop = false
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation_04",
        loop = true
      },
      {
        type = 20,
        timeNext = -1,
        speed = 200,
        rotate = false,
        refind = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = 0,
        newID = 115
      },
      {type = 2, timeNext = -1}
    }
  }
  EffectManager:GetInstance():CreateAttribute(self, effectInfo)
end
function ClickBombEffect:FindTarget()
  local actorManager = require("app.actor.ActorManager"):GetInstance()
  local pMap = require("app.GameDataManager"):GetInstance():GetGameMap()
  local selfPos = cc.p(self:getPosition())
  local vec = {}
  if self:GetSelfActorParams().group == td.GroupType.Enemy then
    vec = actorManager:GetSelfVec()
  elseif self:GetSelfActorParams().group == td.GroupType.Self then
    vec = actorManager:GetEnemyVec()
  end
  local targetTag
  local shortDisSQ = -1
  for tag, actor in pairs(vec) do
    if not actor:IsDead() then
      local pos = cc.p(actor:getPosition())
      local disSQ = cc.pDistanceSQ(selfPos, pos)
      if (shortDisSQ == -1 or shortDisSQ > disSQ) and pMap:IsLineWalkable(selfPos, pos) then
        shortDisSQ = disSQ
        targetTag = tag
      end
    end
  end
  return targetTag
end
return ClickBombEffect
