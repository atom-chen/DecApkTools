local GuildContentBase = class("GuildContentBase", function()
  return display.newNode()
end)
function GuildContentBase:ctor(height)
  self.m_bgHeight = height - 50
  self.m_scale = td.GetAutoScale()
  self.m_uiRoot = nil
  self.m_vCustomListeners = {}
  self:setNodeEventEnabled(true)
end
function GuildContentBase:onEnter()
end
function GuildContentBase:onExit()
  local eventDsp = self:getEventDispatcher()
  for i, listener in ipairs(self.m_vCustomListeners) do
    eventDsp:removeEventListener(listener)
  end
  self.m_vCustomListeners = {}
end
function GuildContentBase:AddCustomEvent(name, func)
  local eventDsp = self:getEventDispatcher()
  local customListener = cc.EventListenerCustom:create(name, func)
  eventDsp:addEventListenerWithFixedPriority(customListener, 1)
  table.insert(self.m_vCustomListeners, customListener)
end
function GuildContentBase:LoadUI(csb)
  self.m_uiRoot = cc.uiloader:load(csb)
  self.m_uiRoot:setContentSize(display.width, display.height)
  self:addChild(self.m_uiRoot, 1)
  local bgPanel = self.m_uiRoot:getChildren()[1]
  local oriSize = bgPanel:getContentSize()
  bgPanel:setContentSize(oriSize.width, self.m_bgHeight)
  ccui.Helper:doLayout(self.m_uiRoot)
  local allUIItems = bgPanel:getChildren()
  for i, var in ipairs(allUIItems) do
    local oriY = var:getPositionY()
    var:setPositionY(oriY + self.m_bgHeight - oriSize.height)
  end
end
return GuildContentBase
