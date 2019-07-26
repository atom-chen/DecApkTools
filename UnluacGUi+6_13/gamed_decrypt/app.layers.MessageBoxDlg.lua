local BaseDlg = require("app.layers.BaseDlg")
local MessageBoxDlg = class("MessageBoxDlg", BaseDlg)
function MessageBoxDlg:ctor(params)
  MessageBoxDlg.super.ctor(self)
  self.m_info = params
  self.m_size = params.size or {width = 454, height = 292}
  self.m_bShowing = false
  self.bPauseGame = params.pause
  self:InitUI()
end
function MessageBoxDlg:onEnter()
  MessageBoxDlg.super.onEnter(self)
  if self.bPauseGame then
    cc.Director:getInstance():pause()
    cc.Director:getInstance():setOwenPause(true)
    G_SoundUtil:Pause(true)
  end
end
function MessageBoxDlg:onExit()
  if self.bPauseGame then
    cc.Director:getInstance():resume()
    cc.Director:getInstance():setOwenPause(false)
    G_SoundUtil:Resume(true)
  end
  MessageBoxDlg.super.onExit(self)
end
function MessageBoxDlg:InitUI()
  self.m_bg = display.newScale9Sprite("UI/scale9/yijitankuang2.png", display.size.width / 2, display.size.height / 2, self.m_size, cc.rect(110, 80, 5, 2))
  self.m_bg:setScale(td.GetAutoScale())
  self:addChild(self.m_bg)
  local bgWidth = self.m_bg:getContentSize().width
  local bgHeight = self.m_bg:getContentSize().height - 20
  if self.m_info.title and self.m_info.title ~= "" then
    local label = td.CreateLabel(self.m_info.title, td.LIGHT_BLUE, 20)
    local labelSize = label:getContentSize()
    label:setAnchorPoint(cc.p(0.5, 1))
    label:setPosition(cc.p(bgWidth / 2, bgHeight))
    self.m_bg:addChild(label)
    bgHeight = bgHeight - labelSize.height
  end
  if self.m_info.content then
    local label
    if type(self.m_info.content) == "string" then
      label = td.CreateLabel(self.m_info.content, td.WHITE, 20, nil, nil, cc.size(bgWidth - 80, 0))
    else
      label = self.m_info.content
    end
    label:setAnchorPoint(cc.p(0.5, 1))
    label:setPosition(cc.p(bgWidth / 2, bgHeight - 50))
    self.m_bg:addChild(label)
    bgHeight = bgHeight - label:getContentSize().height
  end
  if self.m_info.noPromptCallFunc then
    bgHeight = bgHeight - 15
    local checkBox = ccui.CheckBox:create("UI/common/gouxuankuang.png", "UI/common/gouxuan.png")
    local checkBoxSize = checkBox:getContentSize()
    checkBox:setPosition(cc.p(80, 120))
    self.m_bg:addChild(checkBox)
    td.BtnAddTouch(checkBox, function()
      self.m_info.noPromptCallFunc(self)
    end)
    local label = td.CreateLabel(g_LM:getBy("a00198"), td.LIGHT_BLUE, 16)
    label:setAnchorPoint(cc.p(0, 0.5))
    label:setPosition(checkBox:getPositionX() + 15, checkBox:getPositionY())
    self.m_bg:addChild(label)
    bgHeight = bgHeight - checkBoxSize.height
  end
  local buttonNum = #self.m_info.buttons
  if buttonNum > 0 then
    local function CreateButton(text, callFunc, index)
      local button
      if index == 1 then
        button = td.CreateBtn(td.BtnType.GreenShort)
      else
        button = td.CreateBtn(td.BtnType.BlueShort)
      end
      self.m_bg:addChild(button)
      local function cb()
        if callFunc then
          handler(self, callFunc)
        end
        self:removeFromParent()
      end
      td.BtnAddTouch(button, function()
        if callFunc then
          callFunc(self)
        end
        self:removeFromParent()
      end)
      if text and text ~= "" then
        td.BtnSetTitle(button, text)
      end
      return button
    end
    if buttonNum == 1 then
      local button = CreateButton(self.m_info.buttons[1].text, self.m_info.buttons[1].callFunc, 1)
      button:setAnchorPoint(cc.p(0.5, 1))
      button:setPosition(cc.p(self.m_size.width / 2, 110))
      buttonSize = button:getContentSize()
    elseif buttonNum == 2 then
      button = CreateButton(self.m_info.buttons[2].text, self.m_info.buttons[2].callFunc, 2)
      button:setAnchorPoint(cc.p(0.5, 1))
      button:setPosition(cc.p(self.m_size.width / 4, 110))
      buttonSize = button:getContentSize()
      local button = CreateButton(self.m_info.buttons[1].text, self.m_info.buttons[1].callFunc, 1)
      button:setAnchorPoint(cc.p(0.5, 1))
      button:setPosition(cc.p(self.m_size.width / 4 * 3, 110))
    end
  end
  if self.m_info.noModal then
    self:AddTouch()
  end
end
function MessageBoxDlg:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function()
        self:close()
      end, 0.1)
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function MessageBoxDlg:Show()
  if self.m_bShowing then
    return
  end
  self.m_bShowing = true
  local pRunScene = display.getRunningScene()
  pRunScene:addChild(self, td.ZORDER.Disconnect)
end
return MessageBoxDlg
