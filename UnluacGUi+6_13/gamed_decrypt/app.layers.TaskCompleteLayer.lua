local BaseDlg = require("app.layers.BaseDlg")
local TaskCompleteLayer = class("TaskCompleteLayer", function()
  return display.newLayer()
end)
function TaskCompleteLayer:ctor()
  self.m_bActionOver = false
  self:InitUI()
end
function TaskCompleteLayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  td.SetAutoScale(self.m_uiRoot, td.UIPosVertical.Center, td.UIPosHorizontal.Center)
  self.m_panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_panelSize = self.m_panel:getContentSize()
  self.m_spine = SkeletonUnit:create("Spine/UI_effect/UI_renwuwancheng_01")
  self.m_spine:registerSpineEventHandler(function(event)
    if event.animation == "animation" then
      self:Close()
      self.m_bActionOver = true
    end
  end, sp.EventType.ANIMATION_COMPLETE)
  self.m_spine:PlayAni("animation", false)
  self.m_spine:scale(1.5)
  td.AddRelaPos(self.m_panel, self.m_spine, 1, cc.p(0.5, 0.7))
end
function TaskCompleteLayer:Close()
  self.m_spine:runAction(cca.seq({
    cca.fadeOut(0.5),
    cca.cb(function()
      self:removeFromParent()
    end)
  }))
end
return TaskCompleteLayer
