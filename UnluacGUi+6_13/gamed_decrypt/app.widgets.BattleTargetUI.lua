local GameDataManager = require("app.GameDataManager")
local UserDataManager = require("app.UserDataManager")
local BattleTargetUI = class("BattleTargetUI", function()
  return display.newNode()
end)
function BattleTargetUI:ctor(data)
  self.m_data = data
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function BattleTargetUI:InitUI()
  for i, var in ipairs(self.m_data.items) do
    local icon = display.newSprite("#UI/battle/mubiao_icon.png")
    local tLabel = td.CreateLabel(g_LM:getBy(var.title), td.YELLOW, 22, td.OL_BROWN, 2, nil, nil, nil, true)
    local cLabel = td.CreateLabel(g_LM:getBy(var.content), td.WHITE, 22, nil, nil, nil, true)
    local children = {
      icon,
      tLabel,
      cLabel
    }
    local width = 20 + icon:getContentSize().width + tLabel:getContentSize().width + cLabel:getContentSize().width
    local height = 50
    self.m_bg = display.newScale9Sprite("UI/scale9/mubiaodikuang.png", 0, 0, cc.size(width, height))
    self.m_bg:setAnchorPoint(0, 0.5)
    self.m_bg:setPosition(-800, -(i - 1) * (height + 10))
    self:addChild(self.m_bg)
    local posX = 5
    for i, var in ipairs(children) do
      var:setAnchorPoint(0, 0.5)
      var:pos(posX, height / 2):addTo(self.m_bg)
      posX = posX + var:getContentSize().width
    end
  end
end
function BattleTargetUI:Show()
  local children = self:getChildren()
  for i, var in ipairs(children) do
    var:runAction(cca.seq({
      cca.delay((i - 1) * 0.3),
      cc.EaseBackOut:create(cca.moveBy(0.5, 800, 0))
    }))
  end
  if self.m_data.autoHide then
    self:runAction(cca.seq({
      cca.delay(20),
      cca.cb(handler(self, self.Hide))
    }))
  end
end
function BattleTargetUI:Hide()
  local children = self:getChildren()
  local count = #children
  for i, var in ipairs(children) do
    var:runAction(cca.seq({
      cca.delay((i - 1) * 0.3),
      cc.EaseBackIn:create(cca.moveBy(0.5, -800, 0)),
      cca.cb(function()
        if i == count then
          self:removeFromParent()
        end
      end)
    }))
  end
end
function BattleTargetUI:onEnter()
  local missionId = GameDataManager:GetInstance():GetGameMapInfo().id
  if self.m_data.autoShow or UserDataManager:GetInstance():GetCityData(missionId) then
    self:performWithDelay(function()
      self:Show()
      self:AddEvent()
    end, 2)
  else
    self.m_showListener = cc.EventListenerCustom:create(td.SHOW_MISSON_TARGET, handler(self, self.Show))
    self:getEventDispatcher():addEventListenerWithFixedPriority(self.m_showListener, 1)
    self:AddEvent()
  end
end
function BattleTargetUI:AddEvent()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    for key, val in ipairs(self:getChildren()) do
      local tmpPos = val:convertToNodeSpace(touch:getLocation())
      if isTouchInNode(val, tmpPos) then
        self:performWithDelay(function()
          self:Hide()
        end, 0.1)
        break
      end
    end
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function BattleTargetUI:onExit()
  if self.m_showListener then
    self:getEventDispatcher():removeEventListener(self.m_showListener)
    self.m_showListener = nil
  end
end
return BattleTargetUI
