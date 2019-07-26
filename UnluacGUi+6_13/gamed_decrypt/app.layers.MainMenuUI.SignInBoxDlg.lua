local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local ActivityInfoManager = require("app.info.ActivityInfoManager")
local InformationManager = require("app.layers.InformationManager")
local TouchIcon = require("app.widgets.TouchIcon")
local SignInBoxDlg = class("SignInBoxDlg", BaseDlg)
function SignInBoxDlg:ctor()
  SignInBoxDlg.super.ctor(self)
  self.m_uiId = td.UIModule.SignInBox
  self.m_bIsSending = false
  self.m_didReceive = false
  self:InitUI()
end
function SignInBoxDlg:onEnter()
  SignInBoxDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.OpenBox_req, handler(self, self.SignInCallback))
  self:AddTouch()
end
function SignInBoxDlg:onExit()
  SignInBoxDlg.super.onExit(self)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.OpenBox_req)
  td.dispatchEvent(td.CHECK_FIRST_ENTER)
end
function SignInBoxDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/SignInBoxDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_4")
  label:setString(g_LM:getBy("a00381"))
  for i = 1, 3 do
    do
      local btn = cc.uiloader:seekNodeByName(self.m_bg, "Button_box" .. i)
      td.BtnAddTouch(btn, function()
        if self.m_bIsSending or self.m_didReceive then
          return
        end
        btn:setDisable(true)
        local spine = SkeletonUnit:create("Spine/UI_effect/EFT_kaibaoxiang_01")
        spine:scale(0.5)
        td.AddRelaPos(btn, spine, 1, cc.p(0.5, 0.6))
        spine:registerSpineEventHandler(function(event)
          if event.animation == "animation_01" then
            self:SendSignRequest()
          end
        end, sp.EventType.ANIMATION_COMPLETE)
        spine:PlayAni("animation_01", false)
        spine:PlayAni("animation_02", true, true)
      end)
      local label = td.CreateLabel2({
        str = g_LM:getBy("a00416"),
        color = td.YELLOW,
        size = 14,
        olColor = td.OL_BROWN
      })
      td.AddRelaPos(btn, label, 1, cc.p(0.5, 1.3))
    end
  end
end
function SignInBoxDlg:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function(times)
        self:close()
      end, 0.1)
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function SignInBoxDlg:SendSignRequest()
  self.m_bIsSending = true
  local Msg = {}
  Msg.msgType = td.RequestID.OpenBox_req
  Msg.sendData = {itemId = 1}
  TDHttpRequest:getInstance():Send(Msg)
end
function SignInBoxDlg:SignInCallback(data)
  self.m_bIsSending = false
  self.m_didReceive = true
  if td.ResponseState.Success == data.state then
    local items = {}
    if data.itemProto and #data.itemProto > 0 then
      for k, value in pairs(data.itemProto) do
        if 0 < value.num then
          table.insert(items, value)
        end
      end
    end
    UserDataManager:GetInstance():UpdateSignInTime()
    InformationManager:GetInstance():ShowOpenBox(items)
  end
end
return SignInBoxDlg
