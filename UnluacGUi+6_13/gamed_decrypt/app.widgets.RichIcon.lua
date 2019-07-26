local GameDataManager = require("app.GameDataManager")
local RichIcon = class("RichIcon", function(file, content, uiScale, bGray)
  if bGray then
    return display.newGraySprite(file)
  else
    return display.newSprite(file)
  end
end)
local Types = {
  GOLD = 1,
  ENERGY = 2,
  DIAMOND = 3,
  OTHER = 4
}
function RichIcon:ctor(file, content, uiScale)
  self.m_uiScale = uiScale or 1
  self.m_content = content or ""
  if type(self.m_content) ~= "string" then
    self.m_content:retain()
  end
  self:setNodeEventEnabled(true)
end
function RichIcon:SetContent(content)
  self.m_content = content
end
function RichIcon:onEnter()
  self:AddTouch()
end
function RichIcon:onExit()
  if type(self.m_content) ~= "string" then
    self.m_content:release()
  end
  self:onTouchEnded()
end
function RichIcon:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    if not td.IsVisible(self) then
      return false
    end
    local rect = _event:getCurrentTarget():getBoundingBox()
    local pos = _touch:getLocation()
    pos = self:getParent():convertToNodeSpace(cc.p(pos.x, pos.y))
    if cc.rectContainsPoint(rect, pos) then
      self:onTouchBegan()
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function RichIcon:onTouchBegan()
  local contentLable
  if type(self.m_content) == "string" then
    contentLable = td.CreateLabel(self.m_content, td.WHITE, 22)
  else
    contentLable = self.m_content
  end
  contentLable:setAnchorPoint(0.5, 0)
  local labelSize = contentLable:getContentSize()
  local pos = self:getParent():convertToWorldSpace(cc.p(self:getPosition()))
  pos.y = pos.y + 60 * self.m_uiScale
  local bubleSize = cc.size(cc.clampf(labelSize.width + 40, 120, 1000), cc.clampf(labelSize.height + 50, 80, 500))
  self.m_bubble = display.newScale9Sprite("UI/scale9/xuanfukuang.png", 0, 0, bubleSize, cc.rect(30, 45, 20, 40))
  self.m_bubble:setAnchorPoint(1 - 60 / bubleSize.width, 0)
  self.m_bubble:setPosition(pos)
  self.m_bubble:scale(self.m_uiScale)
  display.getRunningScene():addChild(self.m_bubble, td.ZORDER.Info)
  td.AddRelaPos(self.m_bubble, contentLable, 1, cc.p(0.5, 32 / bubleSize.height))
end
function RichIcon:onTouchEnded()
  if self.m_bubble then
    self.m_bubble:removeFromParent()
    self.m_bubble = nil
  end
end
return RichIcon
