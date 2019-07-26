local TDHttpRequest = require("app.net.TDHttpRequest")
local MissionItemUI = require("app.widgets.MissionItemUI")
local BaseDlg = require("app.layers.BaseDlg")
local SettingDlg = class("SettingDlg", BaseDlg)
local CHECKBOX_BUTTON_IMAGES = {
  off = "UI/button/off_button.png",
  off_pressed = "UI/button/off_button.png",
  off_disabled = "UI/button/off_button.png",
  on = "UI/button/on_button.png",
  on_pressed = "UI/button/on_button.png",
  on_disabled = "UI/button/on_button.png"
}
function SettingDlg:ctor()
  SettingDlg.super.ctor(self)
  self:setNodeEventEnabled(true)
  self.m_checkBoxBtns = {}
  self:InitUI()
  self:AddEvents()
  self.m_uiId = td.UIModule.System
end
function SettingDlg:onEnter()
  SettingDlg.super.onEnter(self)
end
function SettingDlg:onExit()
  SettingDlg.super.onExit(self)
end
function SettingDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/SettingDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_pPanelBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local titleSpr = display.newSprite(td.Word_Path .. "wenzi_shezhi.png")
  td.AddRelaPos(self.m_pPanelBg, titleSpr, 1, cc.p(0.5, 0.9))
  local inFunc = function(data)
    local parent = data.parent
    local node = data.node
    parent:addChild(node)
    node:setPosition(data.pos)
    if data.ancPos then
      node:setAnchorPoint(data.ancPos)
    end
  end
  local function inFunc2(data)
    local pTmpNode = td.CreateLabel(g_LM:getBy(data.key) .. ":", td.LIGHT_GREEN, 18)
    local pTempParent = self.m_pPanelBg
    inFunc({
      parent = pTempParent,
      node = pTmpNode,
      pos = data.pos,
      ancPos = cc.p(1, 0.5)
    })
    local checkBoxBtn = cc.ui.UICheckBoxButton.new(CHECKBOX_BUTTON_IMAGES):setButtonSelected(data.selected):setButtonLabel(cc.ui.UILabel.new({
      text = "",
      size = 22,
      color = cc.c3b(255, 96, 255)
    })):setButtonLabelAlignment(display.CENTER):onButtonStateChanged(function(event)
      self:UpdateCheckBoxButtonLabel(event.target)
    end):align(display.LEFT_CENTER, display.left, display.top)
    self.m_pPanelBg:addChild(checkBoxBtn)
    checkBoxBtn:setPosition(data.pos2)
    table.insert(self.m_checkBoxBtns, checkBoxBtn)
    checkBoxBtn:setContentSize(169, 36)
    checkBoxBtn:setAnchorPoint(cc.p(0, 0))
    return checkBoxBtn
  end
  local pos01 = cc.p(110, 230)
  local pos02 = cc.p(130, 205)
  local yOffset = 80
  local bSelected = cc.UserDefault:getInstance():getBoolForKey("music", true)
  self.checkBoxBtn_Sound = inFunc2({
    key = "a00108",
    pos = pos01,
    pos2 = pos02,
    selected = bSelected
  })
  self:UpdateCheckBoxButtonLabel(self.checkBoxBtn_Sound)
  pos01.y = pos01.y - yOffset
  pos02.y = pos02.y - yOffset
  bSelected = cc.UserDefault:getInstance():getBoolForKey("sound", true)
  self.checkBoxBtn_SoundEffect = inFunc2({
    key = "a00109",
    pos = pos01,
    pos2 = pos02,
    selected = bSelected
  })
  self:UpdateCheckBoxButtonLabel(self.checkBoxBtn_SoundEffect)
  pos01.y = pos01.y - yOffset
  pos02.y = pos02.y - yOffset
  bSelected = cc.UserDefault:getInstance():getBoolForKey("push", true)
  self.checkBoxBtn_PushMsg = inFunc2({
    key = "a00110",
    pos = pos01,
    pos2 = pos02,
    selected = bSelected
  })
  self:UpdateCheckBoxButtonLabel(self.checkBoxBtn_PushMsg)
end
function SettingDlg:UpdateCheckBoxButtonLabel(checkbox)
  if checkbox == self.checkBoxBtn_Sound then
    local bPlay = checkbox:isButtonSelected()
    G_SoundUtil:SwitchMusic(bPlay)
  elseif checkbox == self.checkBoxBtn_SoundEffect then
    local bPlay = checkbox:isButtonSelected()
    G_SoundUtil:SwitchSound(bPlay)
  elseif checkbox == self.checkBoxBtn_PushMsg then
    if checkbox:isButtonSelected() then
    else
    end
    cc.UserDefault:getInstance():setBoolForKey("push", checkbox:isButtonSelected())
  end
end
function SettingDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_pPanelBg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_pPanelBg, tmpPos) then
      self:performWithDelay(function(times)
        self:close()
      end, 0.016666666666666666)
      return true
    end
    for k, value in pairs(self.m_checkBoxBtns) do
      local tmpPos = value:convertToNodeSpace(touch:getLocation())
      if isTouchInNode(value, tmpPos) then
        value:onTouch_({
          name = "began",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
        return true
      end
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    for k, value in pairs(self.m_checkBoxBtns) do
      local tmpPos = value:convertToNodeSpace(touch:getLocation())
      if isTouchInNode(value, tmpPos) then
        value:onTouch_({
          name = "ended",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
        break
      end
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
return SettingDlg
