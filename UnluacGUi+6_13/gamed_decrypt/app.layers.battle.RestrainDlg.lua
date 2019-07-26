local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local RestrainDlg = class("RestrainDlg", BaseDlg)
function RestrainDlg:ctor()
  RestrainDlg.super.ctor(self)
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function RestrainDlg:onEnter()
  RestrainDlg.super.onEnter(self)
  if display.getRunningScene():GetType() == td.SceneType.Battle then
    display.getRunningScene():SetPause(true)
  end
  self.m_bg:runAction(cca.seq({
    cc.EaseBackOut:create(cca.scaleTo(0.3, 1)),
    cca.cb(function()
      self:AddEvents()
    end)
  }))
end
function RestrainDlg:onExit()
  RestrainDlg.super.onExit(self)
  if display.getRunningScene():GetType() == td.SceneType.Battle then
    display.getRunningScene():SetPause(false)
    if GameDataManager:GetInstance():GetGameMapInfo().id == 1001 then
      td.dispatchEvent(td.GUIDE_CONTINUE)
    end
  end
end
function RestrainDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosVertical.Center, td.UIPosHorizontal.Center)
  self.m_panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_panelSize = self.m_panel:getContentSize()
  self.m_bg = display.newSprite("UI/tips/kezhiguanxi_bg.png")
  self.m_bg:pos(self.m_panelSize.width * 0.5, self.m_panelSize.height * 0.5):scale(0.01):addTo(self.m_panel)
end
function RestrainDlg:close()
  self.m_bg:runAction(cca.seq({
    cc.EaseBackIn:create(cca.scaleTo(0.3, 0)),
    cca.cb(function()
      RestrainDlg.super.close(self)
    end)
  }))
end
function RestrainDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:close()
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
return RestrainDlg
