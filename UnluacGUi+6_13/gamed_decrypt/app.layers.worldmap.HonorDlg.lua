local TDHttpRequest = require("app.net.TDHttpRequest")
local MissionItemUI = require("app.widgets.MissionItemUI")
local BaseDlg = require("app.layers.BaseDlg")
local HonorDlg = class("HonorDlg", BaseDlg)
local PUSH_BUTTON_IMAGES_1 = {
  normal = "UI/mainmenu_new/player_info/duobianxingkuang1.png",
  pressed = "UI/mainmenu_new/player_info/duobianxingkuang1.png",
  disabled = "UI/mainmenu_new/player_info/duobianxingkuang1.png"
}
local PUSH_BUTTON_IMAGES_2 = {
  normal = "UI/mainmenu_new/player_info/duobianxingkuang2.png",
  pressed = "UI/mainmenu_new/player_info/duobianxingkuang2.png",
  disabled = "UI/mainmenu_new/player_info/duobianxingkuang2.png"
}
local SELECT_BORDER_LIGHT = "UI/mainmenu_new/player_info/duobianxingkuang3.png"
local SELECT_LINE_1 = "UI/mainmenu_new/player_info/jiangexian.png"
local SELECT_LINE_2 = "UI/mainmenu_new/player_info/jiangexian2.png"
function HonorDlg:ctor()
  HonorDlg.super.ctor(self, 245)
  self:setNodeEventEnabled(true)
  self.m_curHonorIndex = -1
  self.m_HonorBtns = {}
  self.m_tmpNodes = {}
  self.m_CommanderInfoManager = require("app.info.CommanderInfoManager").GetInstance()
  self:AddEvents()
end
function HonorDlg:onEnter()
  HonorDlg.super.onEnter(self)
end
function HonorDlg:onExit()
  HonorDlg.super.onExit(self)
end
function HonorDlg:InitUI(shenwang)
  self.m_uiRoot = cc.uiloader:load("CCS/HonorDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self:SetTitle(td.Word_Path .. "wenzi_junxian.png")
  shenwang = shenwang or 0
  self.m_shenwang = shenwang
  self.m_pPanelBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  local inFunc = function(data)
    local parent = data.parent
    local node = data.node
    parent:addChild(node)
    node:setPosition(data.pos)
    if data.ancPos then
      node:setAnchorPoint(data.ancPos)
    end
  end
  local pTempParent = self.m_pPanelBg
  local xOffset = 100
  local yOffset = -110
  local honorInfos = self.m_CommanderInfoManager:GetAllHonorInfo()
  local startPos = cc.p(-xOffset + 30, 150)
  local index = 1
  for k, value in pairs(honorInfos) do
    value.showLineStyle = 1
    if shenwang >= value.honor_need then
      value.hasFull = true
    else
      value.hasFull = false
    end
    if index <= 6 then
      startPos.x = startPos.x + xOffset
    elseif index > 7 then
      startPos.x = startPos.x - xOffset
    end
    if index == 7 then
      startPos.y = startPos.y + yOffset
      value.showLineStyle = 2
    elseif index == 6 then
      value.showLineStyle = 0
    end
    index = index + 1
    local pTmpNode = self:CreateHonorItem(value)
    pTmpNode:setTag(index - 1)
    inFunc({
      parent = pTempParent,
      node = pTmpNode,
      pos = startPos,
      ancPos = cc.p(0, 0)
    })
  end
  self:SetHonorItemSelect()
end
function HonorDlg:AddEvents()
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
    local isClickInHonor, item = self:IsHonorClicked(touch)
    if isClickInHonor then
      item:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    local isClickInHonor, item = self:IsHonorClicked(touch)
    if isClickInHonor then
      item:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function HonorDlg:CreateHonorItem(data)
  local btnFile = PUSH_BUTTON_IMAGES_1
  local lineFile = SELECT_LINE_1
  if data.hasFull then
    btnFile = PUSH_BUTTON_IMAGES_2
    lineFile = SELECT_LINE_2
  end
  local pHonorItem = cc.ui.UIPushButton.new(btnFile, {scale9 = true}):setButtonSize(60, 52.5):onButtonClicked(function(event)
    local button = event.target
    self:SetHonorItemSelect(button:getTag())
  end):align(display.LEFT_CENTER, data.x, data.y)
  local pSpri = display.newSprite(SELECT_BORDER_LIGHT)
  pHonorItem:addChild(pSpri)
  pSpri:setPosition(cc.p(30, 26.5))
  pSpri:setTag(1)
  pSpri:setVisible(false)
  local pIcon = display.newSprite(data.image .. td.PNG_Suffix)
  pHonorItem:addChild(pIcon)
  pIcon:scale(0.6)
  pIcon:setPosition(cc.p(30, 26.5))
  local pLabel = td.CreateLabel(data.military_rank, td.BLUE, 18, nil, nil, nil, true)
  pLabel:setAnchorPoint(cc.p(0.5, 0.5))
  pHonorItem:addChild(pLabel)
  pLabel:setPosition(cc.p(33, -15))
  if data.showLineStyle ~= 0 then
    local line = display.newSprite(lineFile)
    pHonorItem:addChild(line)
    if data.showLineStyle == 1 then
      line:setPosition(cc.p(79, 26.5))
    elseif data.showLineStyle == 2 then
      line:setPosition(cc.p(33, 72))
      line:setRotation(90)
    end
  end
  pHonorItem:setAnchorPoint(cc.p(0, 0))
  pHonorItem:setContentSize(60.5, 52.5)
  table.insert(self.m_HonorBtns, pHonorItem)
  return pHonorItem
end
function HonorDlg:IsHonorClicked(touch)
  for k, value in pairs(self.m_HonorBtns) do
    local tmpPos = value:convertToNodeSpace(touch:getLocation())
    if isTouchInNode(value, tmpPos) then
      return true, value
    end
  end
  return false
end
function HonorDlg:SetHonorItemSelect(index)
  local pHonorInfo
  if nil == index then
    local shenwang = self.m_shenwang
    pHonorInfo = self.m_CommanderInfoManager:GetHonorInfoByRepu(shenwang)
    index = pHonorInfo.level
  else
    pHonorInfo = self.m_CommanderInfoManager:GetHonorInfo(index)
  end
  if self.m_curHonorIndex ~= -1 then
    self.m_HonorBtns[self.m_curHonorIndex]:getChildByTag(1):setVisible(false)
  end
  self.m_curHonorIndex = index
  self.m_HonorBtns[self.m_curHonorIndex]:getChildByTag(1):setVisible(true)
  self:RefreshInfoArea(pHonorInfo)
end
function HonorDlg:RefreshInfoArea(pHonorInfo)
  self:ClearTmpNode()
  local function inFunc2(data)
    local parent = data.parent
    local node = data.node
    parent:addChild(node)
    node:setPosition(data.pos)
    if data.ancPos then
      node:setAnchorPoint(data.ancPos)
    end
    table.insert(self.m_tmpNodes, node)
  end
  local shenwang = pHonorInfo.honor_need
  local pCommanderInfoManager = require("app.info.CommanderInfoManager").GetInstance()
  local pHonorInfo = pCommanderInfoManager:GetHonorInfoByRepu(shenwang)
  local pTmpNode = td.RichText({
    {
      type = 2,
      file = pHonorInfo.image .. td.PNG_Suffix,
      scale = 0.7
    },
    {
      type = 1,
      color = td.YELLOW,
      size = 20,
      str = pHonorInfo.military_rank
    }
  })
  local pTempParent = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_info_bg")
  local size = pTempParent:getContentSize()
  inFunc2({
    parent = pTempParent,
    node = pTmpNode,
    pos = cc.p(20, 90),
    ancPos = cc.p(0, 0.5)
  })
  pTmpNode = td.RichText({
    {
      type = 1,
      color = td.LIGHT_GREEN,
      size = 20,
      str = g_LM:getBy("it00003") .. ":"
    },
    {
      type = 1,
      color = cc.c3b(58, 255, 255),
      size = 20,
      str = shenwang
    }
  })
  inFunc2({
    parent = pTempParent,
    node = pTmpNode,
    pos = cc.p(370, 90),
    ancPos = cc.p(0, 0.5)
  })
  local vKeys, vValue = {"a00141", "a00144"}, {
    pHonorInfo.limit,
    pHonorInfo.atk_increase
  }
  local vPos = {
    cc.p(40, 40),
    cc.p(370, 40)
  }
  for i = 1, 2 do
    pTmpNode = td.RichText({
      {
        type = 1,
        color = td.LIGHT_BLUE,
        size = 16,
        str = g_LM:getBy(vKeys[i]) .. ":"
      },
      {
        type = 1,
        color = cc.c3b(58, 255, 255),
        size = 18,
        str = vValue[i]
      }
    })
    inFunc2({
      parent = pTempParent,
      node = pTmpNode,
      pos = vPos[i],
      ancPos = cc.p(0, 0.5)
    })
  end
end
function HonorDlg:ClearTmpNode()
  for _, value in ipairs(self.m_tmpNodes) do
    value:removeFromParent(trues)
  end
  self.m_tmpNodes = {}
end
return HonorDlg
