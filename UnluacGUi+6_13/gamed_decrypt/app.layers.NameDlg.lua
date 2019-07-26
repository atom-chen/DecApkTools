local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local NameDlg = class("NameDlg", BaseDlg)
local RENAME_COST = 200
function NameDlg:ctor()
  NameDlg.super.ctor(self)
  self.m_uiId = td.UIModule.Name
  self.m_editbox = nil
  local name, bNamed = UserDataManager:GetInstance():GetNickname()
  self.bHaveName = bNamed
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function NameDlg:onEnter()
  NameDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.ModifyUserDetails, handler(self, self.SendNameCallback))
  if self.bHaveName then
    self:AddEvents()
  end
end
function NameDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.ModifyUserDetails)
  td.dispatchEvent(td.CHECK_FIRST_ENTER)
  NameDlg.super.onExit(self)
end
function NameDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  local panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  local bgSize = cc.size(430, 260)
  self.m_bg = display.newScale9Sprite("UI/scale9/yijitankuang2.png", 0, 0, bgSize, cc.rect(110, 80, 5, 2))
  td.AddRelaPos(panel, self.m_bg)
  if self.bHaveName then
    local label = td.RichText({
      {
        type = 1,
        str = "\230\152\175\229\144\166\232\138\177\232\180\185",
        color = td.WHITE,
        size = 18
      },
      {
        type = 2,
        file = td.DIAMOND_ICON,
        scale = 0.6
      },
      {
        type = 1,
        str = "x" .. RENAME_COST,
        color = td.YELLOW,
        size = 18
      },
      {
        type = 1,
        str = "\233\135\141\230\150\176\229\143\150\229\144\141\239\188\159",
        color = td.WHITE,
        size = 18
      }
    })
    td.AddRelaPos(self.m_bg, label, 1, cc.p(0.5, 0.8))
  else
    local label = td.CreateLabel(g_LM:getBy("a00034"), td.LIGHT_BLUE, 18)
    td.AddRelaPos(self.m_bg, label, 1, cc.p(0.5, 0.8))
  end
  self.m_editbox = ccui.EditBox:create(cc.size(340, 50), "UI/scale9/wenzineirongbiankuang.png")
  self.m_editbox:setFontSize(20)
  self.m_editbox:setMaxLength(18)
  self.m_editbox:setText(self.m_searchStr)
  td.AddRelaPos(self.m_bg, self.m_editbox)
  self.m_randomBtn = ccui.Button:create("UI/button/touzi_icon.png", "UI/button/touzi_icon.png")
  self.m_randomBtn:setPressedActionEnabled(true)
  self.m_randomBtn:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.ended == eventType then
      local name = require("app.info.CommanderInfoManager"):GetInstance():GetRandomName()
      self.m_editbox:setText(name)
    end
  end)
  td.AddRelaPos(self.m_bg, self.m_randomBtn, 1, cc.p(0.82, 0.5))
  self.m_btn = td.CreateBtn(td.BtnType.BlueShort)
  self.m_btn:setName("Button_1")
  self.m_btn:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.ended == eventType then
      self:SendNameReq()
    end
  end)
  td.BtnSetTitle(self.m_btn, g_LM:getBy("a00009"))
  td.AddRelaPos(self.m_bg, self.m_btn, 1, cc.p(0.5, 0.22))
end
function NameDlg:SendNameReq()
  local text = self.m_editbox:getText()
  if nil == text or text == "" then
    td.alert(g_LM:getBy("a00302"))
    return
  end
  if td.CheckSensitive(text) then
    td.alert(g_LM:getBy("a00352"))
    return
  end
  if self.bHaveName and UserDataManager:GetInstance():GetDiamond() < RENAME_COST then
    td.alertErrorMsg(td.ErrorCode.DIAMOND_NOT_ENOUGH)
    self:close()
    return
  end
  local Msg = {}
  Msg.msgType = td.RequestID.ModifyUserDetails
  Msg.sendData = {nickname = text}
  Msg.cbData = {nickname = text}
  TDHttpRequest:getInstance():Send(Msg)
end
function NameDlg:SendNameCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    UserDataManager:GetInstance():UpdateNickname(cbData.nickname)
    self:close()
  end
end
function NameDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function(times)
        self:close()
      end, 0.1)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
return NameDlg
