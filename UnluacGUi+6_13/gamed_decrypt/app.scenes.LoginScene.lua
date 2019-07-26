local UserDataManager = require("app.UserDataManager")
local GameSceneBase = require("app.scenes.GameSceneBase")
local TDHttpRequest = require("app.net.TDHttpRequest")
local LoginScene = class("LoginScene", GameSceneBase)
LoginScene.REQ = {
  td.ITEM_UPDATE,
  td.MISSION_DATA_INITED,
  td.FRIEND_DATA_INITED,
  td.TASK_UPDATE,
  td.SOLDIER_DATA_INITED,
  td.ACTIVITY_INITED
}
local ServerState = {
  Normal = 0,
  Maintain = 1,
  Hot = 2
}
function LoginScene:ctor()
  LoginScene.super.ctor(self)
  self.m_eType = td.SceneType.Login
  self.m_vServers = {}
  self.m_listeners = {}
  self.m_iCompleteCnt = 0
  self.m_serverState = nil
  self.m_noticeStr = ""
  self.m_bLoginSuccess = false
  self.m_bIsLoginShowing = false
end
function LoginScene:onEnter()
  LoginScene.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.Login, handler(self, self.LoginResponseCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetServerList, handler(self, self.GetServerListCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.CheckUpdate, handler(self, self.NeedCheckUpdateCallback))
  local bPlayBefore = cc.UserDefault:getInstance():getBoolForKey("movie", false)
  if not bPlayBefore and ccexp.VideoPlayer then
    self:performWithDelay(function()
      cc.UserDefault:getInstance():setBoolForKey("movie", true)
      self:CreateVideo()
    end, 1)
  else
    self:InitUI()
  end
end
function LoginScene:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.Login)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetServerList)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.CheckUpdate)
  LoginScene.super.onExit(self)
end
function LoginScene:CreateVideo()
  self.m_videoPlayer = ccexp.VideoPlayer:create()
  self.m_videoPlayer:setPosition(cc.p(display.widthInPixels / 2, display.heightInPixels / 2))
  self.m_videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
  self.m_videoPlayer:setContentSize(cc.size(display.widthInPixels, display.heightInPixels))
  self.m_videoPlayer:setFileName("res/story2.mp4")
  self.m_videoPlayer:setKeepAspectRatioEnabled(true)
  self:addChild(self.m_videoPlayer)
  self.m_videoPlayer:play()
  self.m_videoPlayer:addEventListener(function(sender, eventType)
    if (eventType == ccexp.VideoPlayerEvent.COMPLETED or eventType == ccexp.VideoPlayerEvent.STOPPED) and self.m_videoPlayer then
      self.m_videoPlayer:setVisible(false)
      self.m_videoPlayer = nil
      self:InitUI()
    end
  end)
end
function LoginScene:InitUI()
  display.setTexturePixelFormat("UI/login/login_bg.png", cc.TEXTURE2D_PIXEL_FORMAT_RGB565)
  local pBg = display.newSprite("UI/login/login_bg.png")
  self:addChild(pBg)
  self.m_bg = pBg
  local size = pBg:getContentSize()
  local xRate = size.width / display.width
  local yRate = size.height / display.height
  local scale = xRate < yRate and xRate or yRate
  pBg:setScale(1 / scale)
  pBg:setPosition(cc.p(display.width * 0.5, display.height * 0.5))
  self:AddEffects()
  self:AddListeners()
  self:performWithDelay(function()
    local logoSpr = SkeletonUnit:create("Spine/UI_effect/EFT_duliri_01")
    logoSpr:setScale(1.2 * td.GetAutoScale())
    td.AddRelaPos(self, logoSpr, 10, cc.p(0.5, 0.75))
    logoSpr:registerSpineEventHandler(function(event)
      if event.animation == "animation" then
        self:NeedCheckUpdateRequest()
      end
    end, sp.EventType.ANIMATION_COMPLETE)
    logoSpr:PlayAni("animation", false)
    G_SoundUtil:PlaySound(70)
  end, 0.5)
end
function LoginScene:ShowLoginLayer()
  self.m_uiRoot = cc.uiloader:load("CCS/LoginLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_uiRoot:setVisible(false)
  self.m_contentPanel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  td.SetAutoScale(self.m_contentPanel, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_noticePanel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_notice")
  td.SetAutoScale(self.m_noticePanel, td.UIPosHorizontal.Right, td.UIPosVertical.Bottom)
  self.btnEnter = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_enter")
  td.CreateUIEffect(self.btnEnter, "Spine/UI_effect/UI_dengluanniu_01", {loop = true})
  self.btnEnter:addTouchEventListener(function(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      self:EnterGame()
    end
  end)
  local btnServer = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_server")
  btnServer:addTouchEventListener(function(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      self:ShowServers()
    end
  end)
  btnServer:setPressedActionEnabled(true)
  self.m_serverLabel = td.CreateLabel("-", td.WHITE, 28, td.OL_BLACK, 2)
  td.AddRelaPos(btnServer, self.m_serverLabel, 1, cc.p(0.3, 0.45))
  local label = td.CreateLabel(g_LM:getBy("a00407"), td.YELLOW, 28, td.OL_BLACK, 2)
  td.AddRelaPos(btnServer, label, 1, cc.p(0.7, 0.45))
  local btnNotice = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_notice")
  td.BtnAddTouch(btnNotice, function()
    local tmpNode = require("app.layers.NoticeDlg").new(self.m_noticeStr)
    td.popView(tmpNode, true)
  end)
  btnNotice:setPressedActionEnabled(true)
  self.m_bIsLoginShowing = true
  pu.ShowLoginDlg(self)
  self:AddTouch()
  G_SoundUtil:PlayMusic(1, true)
  self:InitInfoManager()
end
function LoginScene:update(dt)
end
function LoginScene:AddEffects()
  local effects = require("app.config.login_effcect_config")
  for i, var in ipairs(effects) do
    local skeleton = SkeletonUnit:create("Spine/UI_effect/" .. var.file)
    skeleton:setPosition(var.pos)
    skeleton:PlayAni("animation")
    self.m_bg:addChild(skeleton, var.zorder)
  end
end
function LoginScene:InitUIForgroud()
  self.m_loginDlg = cc.uiloader:load("CCS/LoginDlg.csb")
  self.m_loginDlg:setPosition(display.width * 0.5, display.height * 0.75 - 200 * td.GetAutoScale())
  self.m_loginDlg:setScale(td.GetAutoScale())
  self:addChild(self.m_loginDlg, 2)
  self.m_Panel_bg = cc.uiloader:seekNodeByName(self.m_loginDlg, "Image_bg")
  local bgSize = self.m_Panel_bg:getContentSize()
  local lastUserName, lastPsw = g_LD:GetAccount()
  local userSpr = display.newSprite(td.Word_Path .. "wenzi_zhanghao.png")
  td.AddRelaPos(self.m_Panel_bg, userSpr, 1, cc.p(0.5, 0.75))
  self.m_username = ccui.EditBox:create(cc.size(300, 40), "UI/scale9/transparent1x1.png")
  self.m_username:setPosition(cc.p(bgSize.width * 0.5, 235))
  self.m_username:setFontSize(24)
  self.m_username:setMaxLength(18)
  self.m_username:setPlaceHolder(g_LM:getBy("a00169"))
  self.m_username:setText(lastUserName)
  self.m_Panel_bg:addChild(self.m_username)
  local pswSpr = display.newSprite(td.Word_Path .. "wenzi_mima.png")
  td.AddRelaPos(self.m_Panel_bg, pswSpr, 1, cc.p(0.5, 0.48))
  self.m_passwd = ccui.EditBox:create(cc.size(300, 40), "UI/scale9/transparent1x1.png")
  self.m_passwd:setPosition(cc.p(bgSize.width * 0.5, 136))
  self.m_passwd:setFontSize(24)
  self.m_passwd:setInputFlag(0)
  self.m_passwd:setMaxLength(18)
  self.m_passwd:setPlaceHolder(g_LM:getBy("a00170"))
  self.m_passwd:setText(lastPsw)
  self.m_Panel_bg:addChild(self.m_passwd)
  self.m_leftBtn = cc.uiloader:seekNodeByName(self.m_Panel_bg, "Button_regist")
  td.BtnAddTouch(self.m_leftBtn, handler(self, self.OnLeftBtnClicked), nil, td.ButtonEffectType.Short)
  self.m_rightBtn = cc.uiloader:seekNodeByName(self.m_Panel_bg, "Button_login")
  td.BtnAddTouch(self.m_rightBtn, handler(self, self.OnRightBtnClicked), nil, td.ButtonEffectType.Short)
  td.BtnSetTitle(self.m_leftBtn, g_LM:getBy("a00172"))
  td.BtnSetTitle(self.m_rightBtn, g_LM:getBy("a00171"))
end
function LoginScene:OnLeftBtnClicked(sender)
  local dlg = require("app.layers.RegisterDlg").new(self)
  td.popView(dlg)
end
function LoginScene:OnRightBtnClicked(sender)
  if not self:inputCheck() then
    return
  end
  if self.m_username and self.m_passwd then
    local username = self.m_username:getText()
    local passwd = self.m_passwd:getText()
    sender:setDisable(true)
    sender:performWithDelay(function()
      sender:setDisable(false)
    end, 1)
    self:SendLoginRequest(username, passwd)
  end
end
function LoginScene:inputCheck()
  local username = self.m_username:getText()
  local passwd = self.m_passwd:getText()
  if username == "" or passwd == "" then
    td.alert(g_LM:getBy("a00194"))
    return false
  end
  return true
end
function LoginScene:EnterGame()
  if self.m_serverState ~= ServerState.Normal and self.m_serverState ~= ServerState.Hot then
    td.alert(g_LM:getBy("a00363"))
    return
  end
  self.btnEnter:setDisable(true)
  self:performWithDelay(function()
    self.btnEnter:setDisable(false)
  end, 1)
  local serverInfo = UserDataManager:GetInstance():GetServerData()
  g_LD:SetServer(serverInfo.id)
  UserDataManager:GetInstance():SendJoinGameRequest()
end
function LoginScene:ShowServers()
  local tmpNode = require("app.layers.ServerDlg").new(self.m_vServers)
  td.popView(tmpNode)
end
function LoginScene:UpdateServer(serverInfo)
  self.m_serverState = serverInfo.open
  TDHttpRequest:getInstance():SetServer(serverInfo)
  UserDataManager:GetInstance():SetServerData(serverInfo)
  self.m_serverLabel:setString(serverInfo.name)
end
function LoginScene:AddListeners()
  self:AddCustomEvent(td.LOGIN_DATA_INITED, handler(self, self.LoginRegisterListener))
  self:AddCustomEvent(td.REGISTERED_DATA_INITED, handler(self, self.LoginRegisterListener))
  for i, evName in ipairs(LoginScene.REQ) do
    self:AddCustomEvent(evName, handler(self, self.OnReqFinshed))
  end
end
function LoginScene:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    if not self.m_bLoginSuccess and not self.m_bIsLoginShowing then
      self.m_bIsLoginShowing = true
      pu.ShowLoginDlg(self)
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function LoginScene:LoginRegisterListener(event)
  local bSuccess = tonumber(event:getDataString())
  if bSuccess == 1 then
    local udMng = UserDataManager:GetInstance()
    udMng:SendPackRequest()
    udMng:SendGetSkillsRequest()
    udMng:SendGetWeaponRequest()
    udMng:SendGetGemRequest()
    udMng:SendGetHeroRequest()
    udMng:SendFriendRequest(td.FriendType.Mine)
    udMng:SendTaskRequest(td.TaskType.All)
    udMng:SendAchieveRequest()
    udMng:SendPokedexRequest()
    udMng:SendGetPVPDataRequest()
    require("app.UnitDataManager"):GetInstance():SendSoldierRequest()
    require("app.GuildDataManager"):GetInstance():SendGetGuildRequest()
    require("app.ActivityDataManager"):GetInstance():GetActivityListRequest()
    require("app.info.MissionInfoManager"):GetInstance():SendGetCityRequest()
  else
    td.alertErrorMsg(td.ErrorCode.SERVER_FULL)
  end
end
function LoginScene:OnReqFinshed(event)
  self.m_iCompleteCnt = self.m_iCompleteCnt + 1
  if self.m_iCompleteCnt >= #LoginScene.REQ then
    self:OnAllReqFinshed()
  end
end
function LoginScene:OnAllReqFinshed()
  g_MC:InitModeState()
  local mainMenuScene = require("app.scenes.MainMenuScene").new()
  cc.Director:getInstance():replaceScene(mainMenuScene)
  pu.SubmitData(0)
end
function LoginScene:InitInfoManager()
  require("app.info.ActorInfoManager"):GetInstance()
  require("app.info.BaseInfoManager"):GetInstance()
  require("app.info.BuffInfoManager"):GetInstance()
  require("app.info.MissionInfoManager"):GetInstance()
  require("app.info.PokedexInfoManager"):GetInstance()
  require("app.info.SkillInfoManager"):GetInstance()
  require("app.info.StrongInfoManager"):GetInstance()
  require("app.info.AchievementInfo"):GetInstance()
  require("app.info.CommonInfoManager"):GetInstance()
  require("app.info.TaskInfoManager"):GetInstance()
end
function LoginScene:NeedCheckUpdateRequest()
  TDHttpRequest:getInstance():SendNoProto("version.html", nil, handler(self, self.NeedCheckUpdateCallback))
end
function LoginScene:NeedCheckUpdateCallback(data)
  if data.version <= td.APP_VERSION then
    if GAME_NEED_UPDATE then
      local updateLayer = require("app.layers.UpdateLayer").new(self)
      self:addChild(updateLayer, 1)
    else
      self:ShowLoginLayer()
    end
  else
    local messageBoxDlg = require("app.layers.MessageBoxDlg").new({
      size = cc.size(454, 300),
      title = "",
      content = "\230\184\184\230\136\143\229\183\178\230\155\180\230\150\176\239\188\140\232\128\129\231\137\136\230\156\172\229\176\134\228\184\141\232\131\189\230\173\163\229\184\184\232\191\155\232\161\140\230\184\184\230\136\143\239\188\140\232\175\183\229\136\176\230\130\168\230\137\128\229\156\168\231\154\132\230\184\160\233\129\147\230\155\180\230\150\176\228\184\139\232\189\189\232\135\179\230\156\128\230\150\176\231\137\136\230\156\172\227\128\130",
      buttons = {
        {
          text = g_LM:getBy("a00009")
        }
      }
    })
    messageBoxDlg:Show()
  end
end
function LoginScene:SendLoginRequest(username, passwd)
  g_LD:SetAccount(username, passwd)
  local sendData = {username = username, pwd = passwd}
  TDHttpRequest:getInstance():SendNoProto("UserServlet", sendData, handler(self, self.LoginResponseCallback))
end
function LoginScene:LoginResponseCallback(data)
  if data.sessionId ~= "" and data.id ~= "" then
    local udMng = UserDataManager:GetInstance()
    udMng:SetSessionId(data.sessionId)
    udMng:SetUId(data.id)
    self:SendGetServersRequest()
    self.m_loginDlg:removeFromParent()
  end
end
function LoginScene:sdkLoginCallback(param)
  self.m_bIsLoginShowing = false
  if param and param ~= "" then
    pu.SetLogoutCallback()
    self.m_bLoginSuccess = true
    local udMng = UserDataManager:GetInstance()
    udMng:SetUId(param)
    self:SendGetServersRequest()
  end
end
function LoginScene:SendGetServersRequest()
  TDHttpRequest:getInstance():SendNoProto("GetServers", {
    version = td.APP_VERSION
  }, handler(self, self.GetServerListCallback))
end
function LoginScene:GetServerListCallback(data)
  if data then
    self.m_vServers = data.servers
    local serverInfo
    local lastServerId = g_LD:GetInt("lastServer", 0)
    for i, var in ipairs(self.m_vServers) do
      if lastServerId and lastServerId ~= 0 and var.id == lastServerId then
        serverInfo = var
      end
    end
    if serverInfo then
      self:UpdateServer(serverInfo)
    else
      self:ShowServers()
    end
    self.m_noticeStr = data.notice
    local tmpNode = require("app.layers.NoticeDlg").new(self.m_noticeStr)
    td.popView(tmpNode, true)
    self.m_uiRoot:setVisible(true)
  end
end
return LoginScene
