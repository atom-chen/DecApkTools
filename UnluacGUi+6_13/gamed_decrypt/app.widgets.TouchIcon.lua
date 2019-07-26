local GuideManager = require("app.GuideManager")
local TouchIcon = class("TouchIcon", function(itemId, bHaveStar, bShowSource)
  local file = td.GetItemIcon(itemId)
  if bHaveStar then
    return td.CreateItemIcon(itemId, bHaveStar)
  else
    return display.newSprite(file)
  end
end)
function TouchIcon:ctor(itemId, bHaveStar, bShowSource)
  self.itemId = itemId
  if bShowSource == nil then
    bShowSource = true
  end
  self.bShowSource = bShowSource
  self.m_moveDis = 0
  self:setNodeEventEnabled(true)
end
function TouchIcon:onEnter()
  self:AddTouch()
end
function TouchIcon:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    if not td.IsVisible(self) or not GuideManager:GetInstance():IsForceGuideOver() then
      return false
    end
    local rect = _event:getCurrentTarget():getBoundingBox()
    local pos = _touch:getLocation()
    pos = self:getParent():convertToNodeSpace(cc.p(pos.x, pos.y))
    if cc.rectContainsPoint(rect, pos) then
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self.m_moveDis = self.m_moveDis + math.abs(_touch:getPreviousLocation().y - _touch:getLocation().y)
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(_touch, _event)
    if self.m_moveDis < 20 then
      self:onTouchEnded()
    end
    self.m_moveDis = 0
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function TouchIcon:onTouchEnded()
  td.ShowRP(self, false)
  if self.itemId >= 20000 then
    if self.bShowSource then
      local tmpNode = require("app.layers.MainMenuUI.ItemSourceDlg").new(self.itemId)
      td.popView(tmpNode)
    else
      local data = {
        itemId = self.itemId,
        showType = 2
      }
      g_MC:OpenModule(td.UIModule.ItemDetail, data)
    end
  else
    g_MC:OpenModule(td.UIModule.WeaponUpgrade, {
      weaponId = self.itemId,
      infoOnly = true
    })
  end
end
return TouchIcon
