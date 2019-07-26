local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local RollNumberLabel = require("app.widgets.RollNumberLabel")
local GuildBossFightOverDlg = class("GuildBossFightOverDlg", BaseDlg)
function GuildBossFightOverDlg:ctor(info)
  GuildBossFightOverDlg.super.ctor(self)
  self.m_bIsWin = info.isWin
  self.m_harm = math.floor(info.harm)
  self.m_iTimeInterval = 0
  self.m_bExit = false
  self:InitUI()
end
function GuildBossFightOverDlg:onEnter()
  GuildBossFightOverDlg.super.onEnter(self)
  self:AddEvents()
  self:AddEffect()
  G_SoundUtil:StopMusic()
  G_SoundUtil:StopAllSounds()
  G_SoundUtil:PlaySound(60, false)
end
function GuildBossFightOverDlg:onExit()
  GuildBossFightOverDlg.super.onExit(self)
end
function GuildBossFightOverDlg:AddEvents()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function GuildBossFightOverDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/PVPFightOverDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "BgNode")
  local label = td.RichText({
    {
      type = 1,
      color = td.WHITE,
      size = 24,
      str = "\230\156\172\230\172\161\228\188\164\229\174\179:"
    }
  })
  label:align(display.LEFT_CENTER, -150, -200):addTo(self.m_bg)
end
function GuildBossFightOverDlg:onTouchEnded()
  if self.m_bActionOver and not self.m_bExit then
    self.m_bExit = true
    GameDataManager:GetInstance():ExitGame(3, td.SceneType.Guild)
  end
end
function GuildBossFightOverDlg:AddEffect()
  local spine = SkeletonUnit:create("Spine/UI_effect/UI_shilianshengli_02")
  spine:setPosition(self.m_bg:getPosition())
  spine:addTo(self.m_bg:getParent())
  spine:PlayAni("animation_01", false)
  spine:registerSpineEventHandler(function(event)
    if event.animation == "animation_01" then
      spine:PlayAni("animation_02", true)
      self.m_bg:setVisible(true)
      local rollNumLabel = RollNumberLabel.new({
        num = 0,
        bmpFont = "Fonts/power.fnt",
        cb = function()
          self.m_bActionOver = true
        end
      })
      rollNumLabel:align(display.LEFT_CENTER, -40, -195):addTo(self.m_bg)
      rollNumLabel:SetNumber(self.m_harm)
    end
  end, sp.EventType.ANIMATION_COMPLETE)
end
return GuildBossFightOverDlg
