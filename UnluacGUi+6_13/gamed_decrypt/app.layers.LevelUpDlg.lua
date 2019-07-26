local BaseDlg = require("app.layers.BaseDlg")
local BaseInfoManager = require("app.info.BaseInfoManager")
local UserDataManager = require("app.UserDataManager")
local LevelUpDlg = class("LevelUpDlg", BaseDlg)
function LevelUpDlg:ctor(cb)
  LevelUpDlg.super.ctor(self)
  self.m_bActionOver = false
  self.m_bExit = false
  self.m_cb = cb
  self:InitUI()
end
function LevelUpDlg:onEnter()
  LevelUpDlg.super.onEnter(self)
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function LevelUpDlg:onExit()
  LevelUpDlg.super.onExit(self)
end
function LevelUpDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/LevelUpDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.m_bg:setVisible(false)
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_4")
  label:setString(g_LM:getBy("a00165") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_4_0")
  label:setString(g_LM:getBy("a00166") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_4_1")
  label:setString(g_LM:getBy("a00167") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_4_2")
  label:setString(g_LM:getBy("a00168") .. ":")
  local effectNode = cc.uiloader:seekNodeByName(self.m_uiRoot, "Node_effect")
  local spine = SkeletonUnit:create("Spine/UI_effect/UI_dabenying_01")
  td.AddRelaPos(effectNode, spine)
  spine:PlayAni("animation_01", false)
  spine:registerSpineEventHandler(function(event)
    if event.animation == "animation_01" then
      spine:PlayAni("animation_02", true)
    end
  end, sp.EventType.ANIMATION_COMPLETE)
  self:performWithDelay(handler(self, self.ShowLevelUp), 0.5)
end
function LevelUpDlg:ShowLevelUp()
  local curLevel = UserDataManager:GetInstance():GetBaseCampLevel()
  local biMng = BaseInfoManager:GetInstance()
  local curInfo, lastInfo = biMng:GetBaseInfo(curLevel), biMng:GetBaseInfo(curLevel - 1)
  local vValue = {
    curInfo.hp - lastInfo.hp,
    curInfo.vit - lastInfo.vit,
    td.CalculateTowerHp(curLevel) - td.CalculateTowerHp(curLevel - 1),
    td.CalculateTowerAttack(curLevel) - td.CalculateTowerAttack(curLevel - 1)
  }
  for i = 1, 4 do
    local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_num" .. i)
    label:setString("+" .. vValue[i])
  end
  self.m_bg:setVisible(true)
  self.m_bActionOver = true
end
function LevelUpDlg:onTouchEnded()
  if self.m_bActionOver and not self.m_bExit then
    if self.m_cb then
      self.m_cb()
      self.m_cb = nil
    end
    self.m_bExit = true
    self:removeFromParent()
  end
end
return LevelUpDlg
