local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local RegisterDlg = class("RegisterDlg", BaseDlg)
function RegisterDlg:ctor(pLoginScene)
  RegisterDlg.super.ctor(self)
  self.m_loginScene = pLoginScene
  self:InitUI()
end
function RegisterDlg:onEnter()
  RegisterDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.Register_req, handler(self, self.RegistResponseCallback))
  self:AddTouch()
end
function RegisterDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.Register_req)
  RegisterDlg.super.onExit(self)
end
function RegisterDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/RegisterDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local bgSize = self.m_bg:getContentSize()
  self.m_username = ccui.EditBox:create(cc.size(300, 40), "UI/scale9/transparent1x1.png")
  self.m_username:setPosition(cc.p(bgSize.width * 0.6, 360))
  self.m_username:setFontSize(24)
  self.m_username:setMaxLength(18)
  self.m_username:setPlaceHolder(g_LM:getBy("a00169"))
  self.m_bg:addChild(self.m_username)
  self.m_passwd = ccui.EditBox:create(cc.size(300, 40), "UI/scale9/transparent1x1.png")
  self.m_passwd:setPosition(cc.p(bgSize.width * 0.6, 270))
  self.m_passwd:setFontSize(24)
  self.m_passwd:setInputFlag(0)
  self.m_passwd:setMaxLength(18)
  self.m_passwd:setPlaceHolder(g_LM:getBy("a00221"))
  self.m_bg:addChild(self.m_passwd)
  self.m_passwdRe = ccui.EditBox:create(cc.size(300, 40), "UI/scale9/transparent1x1.png")
  self.m_passwdRe:setPosition(cc.p(bgSize.width * 0.6, 180))
  self.m_passwdRe:setFontSize(24)
  self.m_passwdRe:setInputFlag(0)
  self.m_passwdRe:setMaxLength(18)
  self.m_passwdRe:setPlaceHolder(g_LM:getBy("a00221"))
  self.m_bg:addChild(self.m_passwdRe)
  local closeBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_close")
  self:setCloseBtn(closeBtn)
  td.BtnSetTitle(closeBtn, g_LM:getBy("a00116"))
  local regBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_register")
  td.BtnAddTouch(regBtn, function(sender)
    if not self:inputCheck() then
      return
    end
    local username = self.m_username:getText()
    local passwd = self.m_passwd:getText()
    sender:setDisable(true)
    sender:performWithDelay(function()
      sender:setDisable(false)
    end, 1)
    self:SendRegistRequest(username, passwd)
  end, nil, td.ButtonEffectType.Long)
  td.BtnSetTitle(regBtn, g_LM:getBy("a00172"))
end
function RegisterDlg:inputCheck()
  local username = self.m_username:getText()
  local passwd = self.m_passwd:getText()
  local repasswd = self.m_passwdRe:getText()
  if username == "" or passwd == "" or repasswd == "" then
    td.alert(g_LM:getBy("a00194"))
    return false
  elseif string.len(passwd) < 6 or string.len(passwd) > 12 then
    td.alert(g_LM:getBy("a00221"))
    return false
  elseif passwd ~= repasswd then
    td.alert(g_LM:getBy("a00353"))
    return false
  end
  return true
end
function RegisterDlg:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function RegisterDlg:SendRegistRequest(username, passwd)
  g_LD:SetAccount(username, passwd)
  local sendData = {username = username, pwd = passwd}
  TDHttpRequest:getInstance():SendNoProto("AddUserServlet", sendData, handler(self, self.RegistResponseCallback))
end
function RegisterDlg:RegistResponseCallback(data)
  if data.sessionId ~= "" and data.id ~= "" then
    local udMng = UserDataManager:GetInstance()
    udMng:SetSessionId(data.sessionId)
    udMng:SetUId(data.id)
    self.m_loginScene:SendGetServersRequest()
    self.m_loginScene.m_loginDlg:removeFromParent()
    self:removeFromParent()
  end
end
return RegisterDlg
