local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local GuideWeakLayer = class("GuideWeakLayer", function()
  return display.newLayer()
end)
local UIGuideType = {Arrow = 1}
function GuideWeakLayer:ctor(uiRoot, info)
  self.m_scale = td.GetAutoScale()
  self.m_guideUiRoot = uiRoot
  self.m_guideInfo = info
  self.m_eType = info.style
  if info.needCallback == false then
    self.m_bNeedCallback = false
  else
    self.m_bNeedCallback = true
  end
  self.m_bIsDone = false
  self.m_bIsInitSuccess = true
  self:setContentSize(display.width, display.height)
  self:setNodeEventEnabled(true)
  self:InitUI()
end
function GuideWeakLayer:onEnter()
  self:AddEvents()
end
function GuideWeakLayer:onExit()
  if self.m_customListener then
    local eventDsp = self:getEventDispatcher()
    eventDsp:removeEventListener(self.m_customListener)
    self.m_customListener = nil
  end
end
function GuideWeakLayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  td.SetAutoScale(self.m_uiRoot, td.UIPosVertical.Center, td.UIPosHorizontal.Center)
  self.m_panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_panelSize = self.m_panel:getContentSize()
  self:InitClickArea()
end
function GuideWeakLayer:IsInitSuccess()
  return self.m_bIsInitSuccess
end
function GuideWeakLayer:InitClickArea()
  self.m_pos, self.m_size, self.m_bIsInitSuccess = td.GetGuideArea(self.m_guideInfo, self.m_guideUiRoot)
  self.m_pos = self.m_panel:convertToNodeSpace(self.m_pos)
  if not self.m_bIsInitSuccess then
    return
  end
  local pos = self.m_pos or cc.p(display.width * 0.5, display.height * 0.5)
  local size = self.m_size or cc.size(100, 100)
  local fileName = "UI/scale9/transparent1x1.png"
  local pScale9Spri = display.newScale9Sprite(fileName, 0, 0, size)
  pScale9Spri:setPosition(pos)
  self.m_panel:addChild(pScale9Spri)
  self.m_scale9Spri = pScale9Spri
  local pArrow = SkeletonUnit:create("Spine/UI_effect/UI_ruoyindao_01")
  self.m_panel:addChild(pArrow)
  self.m_arrow = pArrow
  pArrow:setPosition(pos)
  pArrow:PlayAni("animation", true)
end
function GuideWeakLayer:IsInScene(pos)
  if pos.x < 0 or pos.x > display.width or 0 > pos.y or pos.y > display.height then
    return false
  end
  return true
end
function GuideWeakLayer:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(false)
  listener:registerScriptHandler(function(touch, event)
    self:Close()
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function GuideWeakLayer:Close()
  if self.m_bIsDone then
    return
  end
  self.m_bIsDone = true
  if self.m_guideInfo.delay and self.m_guideInfo.delay > 0 then
    self:removeAllChildren()
    self:performWithDelay(function()
      self:removeFromParent(true)
      local GuideManager = require("app.GuideManager")
      GuideManager:GetInstance():UpdateGuide()
    end, self.m_guideInfo.delay)
  else
    self:removeFromParent(true)
    local GuideManager = require("app.GuideManager")
    GuideManager:GetInstance():UpdateGuide()
  end
end
function GuideWeakLayer.AddToNode(uiRoot, info)
  local pLayer = GuideWeakLayer.new(uiRoot, info)
  if pLayer:IsInitSuccess() then
    local runScene = cc.Director:getInstance():getRunningScene()
    runScene:addChild(pLayer)
    pLayer:setLocalZOrder(td.ZORDER.Guide)
    return true
  end
  return false
end
return GuideWeakLayer
