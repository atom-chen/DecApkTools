local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local BaseCampUpgradeDlg = require("app.layers.MainMenuUI.BaseCampUpgradeDlg")
local GuideManager = require("app.GuideManager")
local FightLoseLayer = class("FightLoseLayer", BaseDlg)
function FightLoseLayer:ctor()
  FightLoseLayer.super.ctor(self)
  self.m_uiId = td.UIModule.FightOver
  self.m_uiRoot = nil
  self.m_bActionOver = false
  self.m_bExit = false
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function FightLoseLayer:onEnter()
  FightLoseLayer.super.onEnter(self)
  self:AddEvents()
  if GuideManager:GetInstance():IsForceGuideOver() then
    GuideManager.H_StartGuideGroup(117)
  end
end
function FightLoseLayer:onExit()
  self:unscheduleUpdate()
  FightLoseLayer.super.onExit(self)
end
function FightLoseLayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/FightLoseLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local spine = SkeletonUnit:create("Spine/UI_effect/UI_zhandoujiesuan_02")
  td.AddRelaPos(self.m_bg, spine, 1, cc.p(0.5, 1))
  spine:PlayAni("animation_01", false)
  spine:registerSpineEventHandler(function(event)
    if event.animation == "animation_01" then
      self.m_bActionOver = true
      spine:PlayAni("animation_02", true)
    end
  end, sp.EventType.ANIMATION_COMPLETE)
  local titleStr = {
    "a00296",
    "a00297",
    "a00298"
  }
  for i = 1, 3 do
    do
      local bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "dikuang_" .. i)
      local label = td.CreateLabel(g_LM:getBy(titleStr[i]), td.LIGHT_GREEN, 22, td.OL_BLACK, nil, cc.size(120, 80))
      td.AddRelaPos(bg, label, 1, cc.p(0.5, 0.7))
      local btn = bg:getChildByName("Button_go")
      td.BtnAddTouch(btn, function(sender)
        self:OnBtnClicked(i)
      end)
      td.BtnSetTitle(btn, g_LM:getBy("a00051"))
    end
  end
end
function FightLoseLayer:onTouchEnded()
  if self.m_bActionOver and not self.m_bExit then
    local awardDlg = require("app.layers.battle.FightWinAwardsDlg").new({})
    td.popView(awardDlg)
    self.m_bExit = true
    self:removeFromParent()
  end
end
function FightLoseLayer:OnBtnClicked(index)
  if self.m_bActionOver and not self.m_bExit then
    self.m_bExit = true
    local moduleId = td.UIModule.Hero
    if index == 1 then
      moduleId = td.UIModule.BaseCamp
    elseif index == 2 then
      moduleId = td.UIModule.Camp
    end
    GameDataManager:GetInstance():ExitGame(moduleId)
  end
end
function FightLoseLayer:AddEvents()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
return FightLoseLayer
