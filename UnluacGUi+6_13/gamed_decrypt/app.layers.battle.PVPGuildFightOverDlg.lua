local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local PVPGuildFightOverDlg = class("PVPGuildFightOverDlg", BaseDlg)
function PVPGuildFightOverDlg:ctor(info)
  PVPGuildFightOverDlg.super.ctor(self)
  self.m_bIsWin = info.isWin
  self.m_iTimeInterval = 0
  self.m_bExit = false
  self:setNodeEventEnabled(true)
  self:InitUI()
end
function PVPGuildFightOverDlg:onEnter()
  PVPGuildFightOverDlg.super.onEnter(self)
  self:AddEvents()
  self:AddEffect()
  G_SoundUtil:StopMusic()
  G_SoundUtil:StopAllSounds()
  G_SoundUtil:PlaySound(60, false)
end
function PVPGuildFightOverDlg:onExit()
  PVPGuildFightOverDlg.super.onExit(self)
end
function PVPGuildFightOverDlg:AddEvents()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function PVPGuildFightOverDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/PVPFightOverDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "BgNode")
end
function PVPGuildFightOverDlg:onTouchEnded()
  if self.m_bActionOver and not self.m_bExit then
    self.m_bExit = true
    GameDataManager:GetInstance():ExitGame(3, td.SceneType.GuildPVP)
  end
end
function PVPGuildFightOverDlg:AddEffect()
  local file = self.m_bIsWin and "Spine/UI_effect/UI_shilianshengli_01" or "Spine/UI_effect/UI_shilianshibai_01"
  local spine = SkeletonUnit:create(file)
  spine:setPosition(self.m_bg:getPosition())
  spine:addTo(self.m_bg:getParent())
  spine:PlayAni("animation_01", false)
  spine:registerSpineEventHandler(function(event)
    if event.animation == "animation_01" then
      spine:PlayAni("animation_02", true)
      self.m_bg:setVisible(true)
      self.m_bActionOver = true
    end
  end, sp.EventType.ANIMATION_COMPLETE)
end
return PVPGuildFightOverDlg
