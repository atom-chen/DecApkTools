local GameDataManager = require("app.GameDataManager")
local UserDataManager = require("app.UserDataManager")
local BaseUILayer = class("BaseUILayer", function()
  return display.newLayer()
end)
function BaseUILayer:ctor()
  self.m_uiId = nil
  self.m_udMng = UserDataManager:GetInstance()
  self.m_gdMng = GameDataManager:GetInstance()
  self.m_scale = 1
  self.m_vCustomListeners = {}
  self:setContentSize(display.width, display.height)
  self:setNodeEventEnabled(true)
end
function BaseUILayer:onEnter()
end
function BaseUILayer:onExit()
  local eventDsp = self:getEventDispatcher()
  for i, listener in ipairs(self.m_vCustomListeners) do
    eventDsp:removeEventListener(listener)
  end
  self.m_vCustomListeners = {}
  eventDsp:removeEventListenersForTarget(self)
end
function BaseUILayer:AddCustomEvent(name, func)
  local eventDsp = self:getEventDispatcher()
  local customListener = cc.EventListenerCustom:create(name, func)
  eventDsp:addEventListenerWithFixedPriority(customListener, 1)
  table.insert(self.m_vCustomListeners, customListener)
end
function BaseUILayer:LoadUI(file, horType, verType, bAddBar)
  self.m_uiRoot = cc.uiloader:load(file)
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
end
function BaseUILayer:CheckGuide(event)
  local GuideManager = require("app.GuideManager")
  GuideManager.H_GuideUI(self.m_uiId, self)
end
return BaseUILayer
