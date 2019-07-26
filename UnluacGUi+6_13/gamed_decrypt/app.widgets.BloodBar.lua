local GameDataManager = require("app.GameDataManager")
local BarType = {
  Actor = 0,
  Tower = 1,
  Home = 2,
  Boss = 3
}
local BloodBar = class("BloodBar", function(eType, groupType)
  if eType == BarType.Home then
    return display.newSprite("#UI/battle/jidixuetiaodi.png")
  elseif eType == BarType.Tower then
    return display.newSprite("#UI/battle/taxuetiaodi.png")
  elseif eType == BarType.Boss then
    return display.newSprite("#UI/battle/bossxuetiaodi.png")
  end
  return display.newSprite("#UI/battle/xuetiaodi.png")
end)
BloodBar.HIDE_TIME = 5
function BloodBar:ctor(eType, groupType)
  eType = eType or BloodBar.Type.Self
  self.m_timeInterval = BloodBar.HIDE_TIME
  self.m_isVisible = false
  self.m_iCurPer = 100
  local conSize = self:getContentSize()
  local relaPos, timerSpr = cc.p(0.5, 0.55), nil
  if eType == BarType.Home then
    if groupType == td.GroupType.Self then
      timerSpr = display.newSprite("#UI/battle/jidixuetiaotiao2.png")
    else
      timerSpr = display.newSprite("#UI/battle/jidixuetiaotiao.png")
    end
  elseif eType == BarType.Tower then
    if groupType == td.GroupType.Self then
      timerSpr = display.newSprite("#UI/battle/xiaobingxuetiao.png")
    else
      timerSpr = display.newSprite("#UI/battle/difangxuetiao.png")
    end
    self:setScale(1.5)
  elseif eType == BarType.Boss then
    timerSpr = display.newSprite("#UI/battle/bossxuetiao.png")
    relaPos = cc.p(0.7, 0.5)
  elseif groupType == td.GroupType.Self then
    timerSpr = display.newSprite("#UI/battle/xiaobingxuetiao.png")
  else
    timerSpr = display.newSprite("#UI/battle/difangxuetiao.png")
  end
  self.m_pHpBar = cc.ProgressTimer:create(timerSpr)
  self.m_pHpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  self.m_pHpBar:setMidpoint(cc.p(0, 0))
  self.m_pHpBar:setBarChangeRate(cc.p(1, 0))
  self.m_pHpBar:setPercentage(self.m_iCurPer)
  td.AddRelaPos(self, self.m_pHpBar, 2, relaPos)
  self:setOpacity(0)
  self.m_pHpBar:setOpacity(0)
  self:setNodeEventEnabled(true)
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
    self:Update(dt)
  end)
end
function BloodBar:onEnter()
  self:scheduleUpdate()
end
function BloodBar:onExit()
  self:unscheduleUpdate()
end
function BloodBar:Update(dt)
  self.m_timeInterval = self.m_timeInterval + dt
  if self.m_timeInterval >= BloodBar.HIDE_TIME then
    self.m_timeInterval = BloodBar.HIDE_TIME
    if self.m_isVisible then
      self:runAction(cca.fadeOut(0.1))
      self.m_pHpBar:runAction(cca.fadeOut(0.1))
      self.m_isVisible = false
    end
  end
end
function BloodBar:SetPercentage(per)
  if self.m_iCurPer == per then
    return
  else
    self.m_iCurPer = per
  end
  self.m_pHpBar:setPercentage(per)
  if not self.m_isVisible then
    if per <= 0 then
      self:runAction(cca.seq({
        cca.fadeIn(0.1),
        cca.fadeOut(0.1)
      }))
      self.m_pHpBar:runAction(cca.seq({
        cca.delay(0.1),
        cca.fadeOut(0.1)
      }))
    else
      self:runAction(cca.fadeIn(0.1))
      self.m_pHpBar:runAction(cca.fadeIn(0.1))
      self.m_isVisible = true
    end
  elseif per <= 0 then
    self:runAction(cca.fadeOut(0.1))
    self.m_pHpBar:runAction(cca.fadeOut(0.1))
    self.m_isVisible = false
  end
  self.m_timeInterval = 0
end
return BloodBar
