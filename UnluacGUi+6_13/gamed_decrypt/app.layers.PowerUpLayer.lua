local BaseDlg = require("app.layers.BaseDlg")
local RollNumberLabel = require("app.widgets.RollNumberLabel")
local PowerUpLayer = class("PowerUpLayer", function()
  return display.newLayer()
end)
function PowerUpLayer:ctor(oriPower, type)
  self.m_bActionOver = false
  self.m_upPower = oriPower
  self.type = type or 0
  self:InitUI(oriPower)
end
function PowerUpLayer:InitUI(oriPower)
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  td.SetAutoScale(self.m_uiRoot, td.UIPosVertical.Center, td.UIPosHorizontal.Center)
  self.m_panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_panelSize = self.m_panel:getContentSize()
  local aniFile = self.type == 0 and "Spine/UI_effect/UI_zhandouli_01" or "Spine/UI_effect/UI_paiming_01"
  self.m_spine = SkeletonUnit:create(aniFile)
  self.m_spine:registerSpineEventHandler(function(event)
    if event.animation == "animation" then
      self.m_rollNumLabel:setVisible(true)
      self.m_rollNumLabel:SetNumber(self.m_upPower)
      self.m_bActionOver = true
    end
  end, sp.EventType.ANIMATION_COMPLETE)
  self.m_spine:PlayAni("animation", false)
  self.m_spine:scale(1.5)
  td.AddRelaPos(self.m_panel, self.m_spine, 1, cc.p(0.5, 0.7))
  self.m_rollNumLabel = RollNumberLabel.new({
    num = oriPower,
    bmpFont = "Fonts/power.fnt",
    cb = handler(self, self.Close)
  })
  self.m_rollNumLabel:setVisible(false)
  self.m_rollNumLabel:pos(0, -10):addTo(self.m_spine)
end
function PowerUpLayer:RollTo(upPower)
  self.m_upPower = upPower
  if self.m_bActionOver then
    self.m_rollNumLabel:SetNumber(self.m_upPower)
  end
end
function PowerUpLayer:Close()
  self.m_spine:runAction(cca.seq({
    cca.delay(1.5),
    cca.fadeOut(0.5),
    cca.cb(function()
      self:removeFromParent()
    end)
  }))
  self.m_rollNumLabel:runAction(cca.seq({
    cca.delay(1.5),
    cca.fadeOut(0.5)
  }))
  if self.type == 1 then
    td.dispatchEvent(td.RANK_UPDATE)
  else
    td.dispatchEvent(td.TOTAL_POWER_CHANGE)
  end
end
return PowerUpLayer
