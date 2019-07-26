local GameSceneBase = require("app.scenes.GameSceneBase")
local HealthyScene = class("HealthyScene", GameSceneBase)
function HealthyScene:ctor()
  HealthyScene.super.ctor(self)
  self.m_eType = td.SceneType.Other
  self.m_timeInterval = 0
  self.m_bDidEnter = false
  self:InitUI()
end
function HealthyScene:onEnter()
  HealthyScene.super.onEnter(self)
  self.m_bDidEnter = true
end
function HealthyScene:onExit()
end
function HealthyScene:update(dt)
  if not self.m_bDidEnter then
    return
  end
  self.m_timeInterval = self.m_timeInterval + dt
  if self.m_timeInterval >= 2 then
    self.m_bDidEnter = false
    local nextScene = require("app.scenes.LoginScene").new()
    local transition = display.wrapSceneWithTransition(nextScene, "fade", 0.5)
    display.replaceScene(transition)
  end
end
function HealthyScene:InitUI()
  local bgLayer = display.newColorLayer(cc.c4b(255, 255, 255, 255))
  self:addChild(bgLayer)
  self.m_uiRoot = cc.uiloader:load("CCS/HealthyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  td.SetAutoScale(self.m_panel, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
end
return HealthyScene
