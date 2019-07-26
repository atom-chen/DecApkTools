local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local MissionInfoManager = require("app.info.MissionInfoManager")
local TouchIcon = require("app.widgets.TouchIcon")
local CollectOverDlg = class("CollectOverDlg", BaseDlg)
function CollectOverDlg:ctor(bIsWin)
  CollectOverDlg.super.ctor(self)
  self.m_uiRoot = nil
  self.m_bExit = false
  self.m_bActionOver = false
  self:InitUI()
end
function CollectOverDlg:onEnter()
  CollectOverDlg.super.onEnter(self)
  self:AddEvents()
  self:AddEffect()
  G_SoundUtil:StopMusic()
  G_SoundUtil:StopAllSounds()
  G_SoundUtil:PlaySound(51, false)
end
function CollectOverDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/CollectOverDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "BgNode")
  local labelTitle = td.CreateLabel(g_LM:getBy("a00315"), td.WHITE, 20, td.OL_BLACK)
  labelTitle:pos(0, -100):addTo(self.m_bg)
  local items = GameDataManager:GetInstance():GetCollectData().items
  local startX = -(table.nums(items) - 1) / 2 * 100
  local count = 1
  for itemId, var in pairs(items) do
    local icon = TouchIcon.new(itemId, true)
    icon:scale(0.8):pos(startX + (count - 1) * 100, -175):addTo(self.m_bg)
    local numLabel = td.CreateLabel(var.num, td.WHITE, 20, td.OL_BLACK, 2)
    numLabel:setAnchorPoint(0, 1)
    numLabel:scale(1 / icon:getScale())
    td.AddRelaPos(icon, numLabel, 1, cc.p(0.05, 0.95))
    count = count + 1
  end
end
function CollectOverDlg:AddEffect()
  local spine = SkeletonUnit:create("Spine/UI_effect/UI_shilianshengli_01")
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
function CollectOverDlg:AddEvents()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function CollectOverDlg:onTouchEnded()
  if not self.m_bActionOver then
    return
  end
  if not self.m_bExit then
    self.m_bExit = true
    GameDataManager:GetInstance():ExitGame(td.UIModule.Collect)
  end
end
return CollectOverDlg
