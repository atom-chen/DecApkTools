local TabButton = require("app.widgets.TabButton")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local scheduler = require("framework.scheduler")
local BaseDlg = require("app.layers.BaseDlg")
local ChatManager = require("app.chat.ChatManager")
local CommanderInfoManager = require("app.info.CommanderInfoManager")
local ChatDlg = class("ChatDlg", function()
  return display.newLayer()
end)
local touchHelpTag = 0
local DlgState = {
  show = 1,
  animation = 2,
  hide = 3
}
local ChannelType = {
  friend = 1,
  guild = 2,
  world = 3
}
function ChatDlg:ctor(channel)
  self.m_chatManager = ChatManager:GetInstance()
  self.m_bIsShownIMEUI = false
  self.m_bIsScrollingIMEUI = false
  self.m_IMEScrollTime = 0.2
  self.m_isShow = false
  self.m_dlgState = DlgState.hide
  self.m_vContentViews = {}
  self.m_curMsgData = nil
  self.m_initChannel = channel or ChannelType.world
  self.m_cur_Channel = self.m_initChannel
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function ChatDlg:onEnter()
  self.m_chatManager:setChatDlg(self)
  self:initMsgs()
  self:AddEvent()
  self:startSchedule()
end
function ChatDlg:onExit()
  self:stopSchedule()
  self.m_chatManager:setChatDlg(nil)
end
function ChatDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/ChatDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  td.SetAutoScale(self.m_uiRoot, td.UIPosHorizontal.Left, td.UIPosVertical.Bottom)
  self.m_panelBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_bg:setScale(1, 0.12)
  self.m_inputBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg_input")
  self.m_panelTab = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_tab")
  self.m_panelTab:setVisible(false)
  self.m_panelScrollMini = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_scroll_mini")
  self.m_panelScroll = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_scroll")
  self.m_panelScroll:setVisible(false)
  self.m_textField = ccui.EditBox:create(cc.size(240, 45), "UI/scale9/transparent1x1.png")
  self.m_textField:setPosition(cc.p(165, 20))
  self.m_textField:setFont("Microsoft YaHei", 20)
  self.m_textField:setPlaceholderFont("Microsoft YaHei", 20)
  self.m_textField:setPlaceHolder(g_LM:getBy("a00097"))
  self.m_textField:setMaxLength(200)
  self.m_panelBg:addChild(self.m_textField)
  self.m_textField:setEnabled(false)
  self.m_btnSend = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_input")
  self.m_btnSend:setPressedActionEnabled(true)
  self.m_btnSend:setEnabled(false)
  td.BtnAddTouch(self.m_btnSend, handler(self, self.OnSendBtnClicked))
  self.m_bt_show = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_show")
  self.m_bt_show:setPressedActionEnabled(true)
  td.BtnAddTouch(self.m_bt_show, handler(self, self.showOrHideDlg))
  self:CreateContentViews()
  self:CreateTabs()
end
function ChatDlg:CreateTabs()
  local tab1 = ccui.ImageView:create("UI/button/liaotian2_button.png"):pos(50, 20):addTo(self.m_panelTab, -1)
  local tab2 = ccui.ImageView:create("UI/button/liaotian2_button.png"):pos(160, 20):addTo(self.m_panelTab, -1)
  local tab3 = ccui.ImageView:create("UI/button/liaotian2_button.png"):pos(270, 20):addTo(self.m_panelTab, -1)
  self.m_vTabs = {
    tab3,
    tab2,
    tab1
  }
  local t1 = {
    tab = tab1,
    callfunc = handler(self, self.changeChannel),
    text = "\228\184\150\231\149\140",
    normalImageFile = "UI/button/liaotian2_button.png",
    highImageFile = "UI/button/liaotian1_button.png"
  }
  local t2 = {
    tab = tab2,
    callfunc = handler(self, self.changeChannel),
    text = "\229\134\155\229\155\162",
    normalImageFile = "UI/button/liaotian2_button.png",
    highImageFile = "UI/button/liaotian1_button.png"
  }
  local t3 = {
    tab = tab3,
    callfunc = handler(self, self.changeChannel),
    text = "\231\167\129\232\129\138",
    normalImageFile = "UI/button/liaotian2_button.png",
    highImageFile = "UI/button/liaotian1_button.png"
  }
  self.m_TabButton = TabButton.new({
    t1,
    t2,
    t3
  }, {
    textSize = 18,
    normalTextColor = td.WHITE,
    autoSelectIndex = self:GetTabIndex(self.m_initChannel)
  })
end
function ChatDlg:CreateContentViews()
  local scrollSize = self.m_panelScroll:getContentSize()
  self.m_vContentViews[ChannelType.world] = require("app.widgets.ChatScrollView"):Create(self.m_panelScroll, cc.size(scrollSize.width, scrollSize.height), cc.p(scrollSize.width / 2, 0), ChatManager.MAX_MSG_CNT)
  self:appendWorldInitStr()
  self.m_vContentViews[ChannelType.world]:setVisible(false)
  self.m_vContentViews[ChannelType.guild] = require("app.widgets.ChatScrollView"):Create(self.m_panelScroll, cc.size(scrollSize.width, scrollSize.height), cc.p(scrollSize.width / 2, 0), ChatManager.MAX_MSG_CNT)
  self.m_vContentViews[ChannelType.guild]:setVisible(false)
  self.m_vContentViews[ChannelType.friend] = require("app.widgets.ChatScrollView"):Create(self.m_panelScroll, cc.size(scrollSize.width, scrollSize.height), cc.p(scrollSize.width / 2, 0), ChatManager.MAX_MSG_CNT)
  self.m_vContentViews[ChannelType.friend]:setVisible(false)
end
function ChatDlg:OnSendBtnClicked()
  if not self:checkCanSend() then
    return
  end
  local str = self.m_textField:getText()
  str = td.ReplaceSensitive(str)
  local msgData
  local sendData = {
    type = self.m_cur_Channel,
    messages = str
  }
  if self.m_cur_Channel == ChannelType.friend then
    local friendId = self.m_curMsgData and self.m_curMsgData.uid or nil
    local toFriName = self.m_curMsgData and self.m_curMsgData.uname or nil
    msgData = self.m_chatManager:createSelfMsgData(str, toFriName)
    sendData.fid = friendId
  else
    msgData = self.m_chatManager:createSelfMsgData(str)
    if self.m_cur_Channel == ChannelType.guild then
      local guidData = UserDataManager:GetInstance():GetGuildManager():GetGuildData()
      if guidData then
        sendData.familyId = guidData.id
      else
        td.alertDebug("\230\178\161\230\156\137\229\134\155\229\155\162")
        return
      end
    end
  end
  self:appendContent(msgData, self.m_cur_Channel)
  self.m_chatManager:addSelfMsg(self.m_cur_Channel, msgData)
  self.m_chatManager:sendChatMsgRequest(sendData)
  self.m_textField:setText("")
end
function ChatDlg:GetTabIndex(channel)
  if channel == ChannelType.friend then
    return 3
  elseif channel == ChannelType.guild then
    return 2
  end
  return 1
end
function ChatDlg:changeChannel(index)
  local channel
  if index == 1 then
    channel = ChannelType.world
  elseif index == 2 then
    channel = ChannelType.guild
    if not UserDataManager:GetInstance():GetGuildManager():GetGuildData() then
      td.alert(g_LM:getBy("a00327"), true)
      return false
    end
  else
    channel = ChannelType.friend
  end
  if self.m_cur_Channel == channel then
    return
  end
  if self.m_cur_Channel then
    self.m_vContentViews[self.m_cur_Channel]:setVisible(false)
  end
  self.m_cur_Channel = channel
  self.m_vContentViews[self.m_cur_Channel]:setVisible(true)
  if ChannelType.world == self.m_cur_Channel or ChannelType.guild == self.m_cur_Channel then
    self.m_curMsgData = nil
    self.m_textField:setPlaceHolder(g_LM:getBy("a00097"))
  end
  td.ShowRP(self.m_vTabs[self.m_cur_Channel], false)
end
function ChatDlg:showOrHideDlg()
  if DlgState.animation == self.m_dlgState then
    return
  end
  self.m_dlgState = DlgState.animation
  local action
  if self.m_isShow then
    action = cca.seq({
      cca.cb(function()
        self.m_panelTab:setVisible(false)
        self.m_vContentViews[self.m_cur_Channel]:setVisible(false)
        self.m_panelScroll:setVisible(false)
      end),
      cca.scaleTo(0.3, 1, 0.12),
      cca.cb(function()
        self.m_isShow = not self.m_isShow
        self.m_dlgState = DlgState.hide
        g_MC:CloseModule(td.UIModule.Chat)
        self.m_textField:setEnabled(false)
        self.m_btnSend:setEnabled(false)
      end)
    })
  else
    td.ShowRP(self.m_bt_show, false)
    action = cca.seq({
      cca.scaleTo(0.3, 1, 1),
      cca.cb(function()
        self.m_isShow = not self.m_isShow
        self.m_dlgState = DlgState.show
        g_MC:AddShowingModule(td.UIModule.Chat)
        self.m_textField:setEnabled(true)
        self.m_btnSend:setEnabled(true)
        self.m_panelTab:setVisible(true)
        self.m_vContentViews[self.m_cur_Channel]:setVisible(true)
        self.m_panelScroll:setVisible(true)
        self.m_panelScrollMini:removeAllChildren()
      end)
    })
  end
  self.m_bg:runAction(action)
end
function ChatDlg:GetBg()
  return self.m_bt_show
end
function ChatDlg:appendContent(data, channelType)
  data = data or {}
  channelType = channelType or ChannelType.world
  self.m_vContentViews[channelType]:append(self:CreateMsgContent(data, channelType))
  if DlgState.hide == self.m_dlgState then
    self.m_panelScrollMini:removeAllChildren()
    self.m_panelScrollMini:addChild(self:CreateMsgContent(data, channelType))
  end
end
function ChatDlg:CreateMsgContent(data, channelType)
  local msg = self:makeMessage(data, channelType)
  local parent = display.newLayer()
  local labelMsg = RichLabel:create(msg, cc.size(300, 0), 0, 1)
  local delegate = RichEventDelegate:create(handler(self, self.onTouchEvent))
  labelMsg:setTouchDelegat(delegate)
  labelMsg:setTag(data.index)
  local labelMsgSize = labelMsg:getContentSize()
  local size = cc.size(labelMsgSize.width, labelMsgSize.height + 15)
  parent:setContentSize(size.width, size.height)
  parent:addChild(labelMsg)
  labelMsg:setPosition(cc.p(0, size.height))
  labelMsg:setAnchorPoint(cc.p(0, 1))
  local splitSpr = display.newSprite("UI/common/fengexian1.png")
  splitSpr:setScaleX(size.width / splitSpr:getContentSize().width)
  td.AddRelaPos(parent, splitSpr, 1, cc.p(0.5, 1.05))
  return parent
end
function ChatDlg:appendWorldInitStr()
  local parent = display.newLayer()
  parent:setAnchorPoint(cc.p(0, 0))
  local label = RichLabel:create("#color[0x66eeff]#size[20]" .. g_LM:getBy("a00042"), cc.size(0, 0), 1, 1)
  local size = cc.size(self.m_vContentViews[ChannelType.world]:getContentSize().width, label:getContentSize().height)
  parent:addChild(label)
  parent:setContentSize(size.width, size.height)
  label:setPosition(cc.p(size.width * 0.5, self.m_vContentViews[ChannelType.world]:getContentSize().height * 0.8))
  label:setAnchorPoint(cc.p(0.5, 0.5))
  self.m_vContentViews[ChannelType.world]:append(parent)
end
function ChatDlg:makeNameStr_inFriend(data)
  if data.isSelfSend then
    return "#color[0x8aff66]#size[16]" .. g_LM:getBy("a00043") .. "\227\128\144" .. data.uname .. "\227\128\145" .. g_LM:getBy("a00044")
  else
    return "#b##color[0xffffff]#size[16]\227\128\144" .. data.uname .. "\227\128\145#e#" .. g_LM:getBy("a00045")
  end
end
function ChatDlg:makeNameStr_inWorld(data)
  if data.isSelfSend then
    return "#color[0x8aff66]#size[16]\227\128\144" .. data.uname .. "\227\128\145"
  else
    local uid = tonumber(data.uid)
    if uid and uid < 100 then
      return "#color[0xff0000]#size[16]\227\128\144\231\179\187\231\187\159\227\128\145"
    else
      return "#b##color[0xffffff]#size[16]\227\128\144" .. data.uname .. "\227\128\145#e#"
    end
  end
end
function ChatDlg:makeMessage(data, channelType)
  local name = ""
  if ChannelType.friend == channelType then
    name = self:makeNameStr_inFriend(data)
  else
    name = self:makeNameStr_inWorld(data)
  end
  local uid = tonumber(data.uid)
  if uid and uid < 100 then
    return name .. ": " .. self:MakeSystemMessage(uid, data.messages)
  end
  local honorInfo = CommanderInfoManager:GetInstance():GetHonorInfoByRepu(data.reputation or 0)
  local fileName = honorInfo.image .. td.PNG_Suffix
  return "#image[" .. fileName .. ", 0.5]" .. name .. ": " .. "#color[0x66eeff]#size[16]" .. data.messages
end
function ChatDlg:MakeSystemMessage(_type, _msg)
  local tmp = td.GetSysMsg({type = _type, msg = _msg})
  local richStr = ""
  for i, var in ipairs(tmp) do
    local _colorStr = "#color[0x66eeff]#size[16]"
    if i % 2 == 0 then
      _colorStr = "#color[0xfff153]#size[16]"
    end
    richStr = richStr .. _colorStr .. var
  end
  return richStr
end
function ChatDlg:toggleIMEUI()
  if self.m_bIsShownIMEUI then
    self:hideIMEUI()
  else
    self:showIMEUI()
  end
end
function ChatDlg:showIME(state)
  cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(state)
end
function ChatDlg:hideIMEUI()
  if not self.m_bIsShownIMEUI or self.m_bIsScrollingIMEUI then
    return
  end
  self.m_bIsShownIMEUI = false
  self.m_bIsScrollingIMEUI = true
  if self.m_originPos == nil then
    return
  end
  local action = cc.Sequence:create(cc.MoveTo:create(self.m_IMEScrollTime, self.m_originPos), cc.CallFunc:create(function()
    self.m_bIsScrollingIMEUI = false
  end))
  self:stopAllActions()
  self:runAction(action)
end
function ChatDlg:showIMEUI()
  if self.m_bIsShownIMEUI or self.m_bIsScrollingIMEUI then
    return
  end
  self.m_bIsShownIMEUI = true
  self.m_bIsScrollingIMEUI = true
  if self.m_originPos == nil then
    self.m_originPos = cc.p(self:getPosition())
  end
  local yOffset = self:getIMEOffset()
  local action = cc.Sequence:create(cc.MoveBy:create(self.m_IMEScrollTime, cc.p(0, yOffset)), cc.CallFunc:create(function()
    self.m_bIsScrollingIMEUI = false
  end))
  self:stopAllActions()
  self:runAction(action)
end
function ChatDlg:getIMEOffset()
  return 150
end
function ChatDlg:onTouchEvent(eventType, sender)
  if "touchOn" == eventType then
    scheduler.performWithDelayGlobal(function()
      local index = sender:getParent():getTag()
      local msgData = self.m_chatManager:getMsgData(self.m_cur_Channel, index)
      self:OpenPrivateChat(msgData)
    end, 0.1)
  end
end
function ChatDlg:OpenPrivateChat(msgData)
  self.m_curMsgData = msgData
  if self.m_curMsgData then
    self.m_textField:setPlaceHolder(g_LM:getBy("a00043") .. msgData.uname .. g_LM:getBy("a00044"))
  end
  self:changeChannel(3)
  self.m_TabButton:changeCount(3)
end
function ChatDlg:startSchedule()
  self:stopSchedule()
  self.m_msgScheduler = scheduler.scheduleGlobal(function()
    self:GetChatMsg()
  end, 2)
  self:GetChatMsg()
end
function ChatDlg:GetChatMsg()
  local data = {
    type = self.m_cur_Channel
  }
  if self.m_cur_Channel == ChannelType.guild then
    local guidData = UserDataManager:GetInstance():GetGuildManager():GetGuildData()
    if guidData then
      data.familyId = guidData.id
    end
  end
  self.m_chatManager:sendGetChatRequest(data)
end
function ChatDlg:stopSchedule()
  if self.m_msgScheduler then
    scheduler.unscheduleGlobal(self.m_msgScheduler)
    self.m_msgScheduler = nil
  end
end
function ChatDlg:checkCanSend()
  if self.m_cur_Channel == ChannelType.friend and self.m_curMsgData == nil then
    td.alertDebug("\232\175\183\229\133\136\233\128\137\230\139\169\232\129\138\229\164\169\229\175\185\232\177\161")
    return false
  end
  local str = self.m_textField:getText()
  if str == "" then
    return false
  end
  return true
end
function ChatDlg:initMsgs()
  self:performWithDelay(function()
    local datas = self.m_chatManager:getMsgData()
    for k1, value1 in pairs(datas) do
      for k2, value2 in ipairs(value1) do
        self:appendContent(value2, k1, false)
      end
    end
  end, 0.1)
end
function ChatDlg:SetChannelUpdate(channel)
  if self.m_cur_Channel ~= channel then
    td.ShowRP(self.m_vTabs[channel], true)
  end
end
function ChatDlg:AddEvent()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local bg = self.m_isShow and self.m_panelBg or self.m_inputBg
    local tmpPos = bg:convertToNodeSpace(touch:getLocation())
    if isTouchInNode(bg, tmpPos) then
      if not self.m_isShow then
        self:showOrHideDlg()
      end
      return true
    elseif self.m_isShow then
      self:showOrHideDlg()
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
return ChatDlg
