local UnitDataManager = require("app.UnitDataManager")
local PipeSoldierButton = require("app.widgets.PipeSoldierButton")
local scheduler = require("framework.scheduler")
local PatternCount = 5
local PatternGap = 175
local BG_SIZE = cc.size(623, 108)
local Pipeline = class("Pipeline", function()
  return display.newScale9Sprite("#UI/battle/di.png", 0, 0, BG_SIZE)
end)
function Pipeline:ctor()
  self.m_timeGap = 2
  self.m_pipeScheduler = nil
  self.m_vUnlockSoldierId = self:GetSoldierIds()
  self.m_vCustomListeners = {}
  self:Init()
  self:setNodeEventEnabled(true)
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
    self:Update(dt)
  end)
end
function Pipeline:GetSoldierIds()
  local unlockedIds = UnitDataManager:GetInstance():GetUnlockedRoleIds()
  for i, val1 in ipairs(clone(unlockedIds)) do
    local campIndex = math.round(val1 / 100)
    local roleIndex = val1 % 100
    if roleIndex >= 2 then
      for j, val2 in ipairs(clone(unlockedIds)) do
        if val2 == tonumber(campIndex .. "01") then
          table.remove(unlockedIds, j)
        end
      end
      if roleIndex > 2 then
        for p, val3 in ipairs(clone(unlockedIds)) do
          if val3 == tonumber(campIndex .. "02") then
            table.remove(unlockedIds, p)
          end
        end
      end
    end
  end
  return unlockedIds
end
function Pipeline:onEnter()
  local eventDispatcher = self:getEventDispatcher()
  local fightWinListener = cc.EventListenerCustom:create(td.FIGHT_WIN, handler(self, self.Stop))
  eventDispatcher:addEventListenerWithFixedPriority(fightWinListener, 1)
  table.insert(self.m_vCustomListeners, fightWinListener)
  local fightLoseListener = cc.EventListenerCustom:create(td.FIGHT_LOSE, handler(self, self.Stop))
  eventDispatcher:addEventListenerWithFixedPriority(fightLoseListener, 1)
  table.insert(self.m_vCustomListeners, fightLoseListener)
  self:scheduleUpdate()
end
function Pipeline:onExit()
  self:Stop()
  local eventDispatcher = self:getEventDispatcher()
  for i, var in ipairs(self.m_vCustomListeners) do
    eventDispatcher:removeEventListener(var)
  end
  self.m_vCustomListeners = {}
end
function Pipeline:Update(dt)
  for i, var in ipairs(self.m_vPattern) do
    local x = var:getPositionX()
    if x >= 100 + (PatternCount - 1) * PatternGap then
      local nextIndex = i + 1 <= 5 and i + 1 or 1
      var:setPositionX(self.m_vPattern[nextIndex]:getPositionX() - PatternGap + dt * 70)
    else
      var:setPositionX(x + dt * 70)
    end
  end
end
function Pipeline:Init()
  local conSize = self:getContentSize()
  local frame = display.newScale9Sprite("#UI/battle/biankuang.png", 0, 0, BG_SIZE)
  frame:setPosition(conSize.width * 0.5, conSize.height * 0.5)
  self:addChild(frame, 10)
  self.m_clipNode = display.newClippingRegionNode(cc.rect(0, 0, conSize.width - 15, conSize.height))
  self.m_clipNode:setAnchorPoint(0, 0)
  self.m_clipNode:addTo(self)
  self.m_vPattern = {}
  for i = 1, PatternCount do
    local pattern = display.newSprite("#UI/battle/diwen.png")
    pattern:setAnchorPoint(cc.p(1, 0.5))
    pattern:pos(100 + (i - 1) * PatternGap, self:getContentSize().height * 0.5):addTo(self.m_clipNode)
    table.insert(self.m_vPattern, pattern)
  end
end
function Pipeline:SetTimeGap(gap)
  self.m_timeGap = gap
end
function Pipeline:Start()
  self.m_pipeScheduler = scheduler.scheduleGlobal(function()
    local roleId = self.m_vUnlockSoldierId[math.random(#self.m_vUnlockSoldierId)]
    self:AddPipeSoldierBtn(roleId)
  end, self.m_timeGap)
end
function Pipeline:Stop()
  if self.m_pipeScheduler then
    scheduler.unscheduleGlobal(self.m_pipeScheduler)
    self.m_pipeScheduler = nil
  end
end
function Pipeline:AddPipeSoldierBtn(roleId)
  local soldierBtn = PipeSoldierButton.new(roleId)
  soldierBtn:setPosition(-40, self:getContentSize().height * 0.5)
  self.m_clipNode:addChild(soldierBtn)
  soldierBtn:runAction(cca.seq({
    cca.moveBy(10, 700, 0),
    cca.cb(function()
      soldierBtn:Disappear()
    end)
  }))
end
function Pipeline:SetUILayer(layer)
  self.m_uiLayer = layer
end
return Pipeline
