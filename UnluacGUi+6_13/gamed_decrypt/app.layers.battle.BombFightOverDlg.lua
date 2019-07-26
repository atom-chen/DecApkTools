local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local TouchIcon = require("app.widgets.TouchIcon")
local BombFightOverDlg = class("BombFightOverDlg", BaseDlg)
function BombFightOverDlg:ctor(awards)
  BombFightOverDlg.super.ctor(self)
  self.m_vAwrads = awards
  self.m_iTimeInterval = 0
  self.m_bExit = false
  self:InitUI()
end
function BombFightOverDlg:onEnter()
  BombFightOverDlg.super.onEnter(self)
  self:AddEvents()
  self:AddEffect()
  G_SoundUtil:StopMusic()
  G_SoundUtil:StopAllSounds()
  G_SoundUtil:PlaySound(60, false)
end
function BombFightOverDlg:onExit()
  BombFightOverDlg.super.onExit(self)
end
function BombFightOverDlg:AddEvents()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function BombFightOverDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/PVPFightOverDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "BgNode")
  local bgSize = self.m_bg:getContentSize()
  local lightSpr = display.newSprite("UI/common/lanse_guangxian.png")
  lightSpr:align(display.RIGHT_CENTER, bgSize.width / 2, -150):addTo(self.m_bg)
  lightSpr = display.newSprite("UI/common/lanse_guangxian.png")
  lightSpr:scale(-1, 1):align(display.RIGHT_CENTER, bgSize.width / 2, -150):addTo(self.m_bg)
  local label = td.CreateLabel(g_LM:getBy("a00315"), td.WHITE, 24, td.OL_BLACK)
  label:pos(bgSize.width / 2, -150):addTo(self.m_bg)
  local count = 0
  local startX, gapX
  for itemId, var in pairs(self.m_vAwrads) do
    local itemIcon = TouchIcon.new(itemId, true, false)
    if itemIcon then
      if not startX or not gapX then
        local iconSize = itemIcon:getContentSize()
        gapX = iconSize.width * 0.6 + 10
        startX = (bgSize.width - gapX * (table.nums(self.m_vAwrads) - 1)) * 0.5
      end
      itemIcon:scale(0)
      itemIcon:runAction(cca.seq({
        cca.delay(count * 0.2),
        cca.scaleTo(0.4, 0.6, 0.6)
      }))
      itemIcon:pos(startX + count * gapX, -220):addTo(self.m_bg)
      local numLabel = td.CreateLabel(var, td.WHITE, 26, td.OL_BLACK, 2)
      numLabel:setAnchorPoint(0, 0.5)
      td.AddRelaPos(itemIcon, numLabel, 1, cc.p(0.05, 0.8))
      count = count + 1
    end
  end
end
function BombFightOverDlg:onTouchEnded()
  if self.m_bActionOver and not self.m_bExit then
    self.m_bExit = true
    GameDataManager:GetInstance():ExitGame(td.UIModule.Bombard)
  end
end
function BombFightOverDlg:AddEffect()
  local file = "Spine/UI_effect/UI_shilianshengli_01"
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
return BombFightOverDlg
