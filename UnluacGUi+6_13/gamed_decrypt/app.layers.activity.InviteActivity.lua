local ItemInfoManager = require("app.info.ItemInfoManager")
local UserDataManager = require("app.UserDataManager")
local ActivityInfoManager = require("app.info.ActivityInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local InviteActivity = class("InviteActivity", function()
  return display.newNode()
end)
function InviteActivity:ctor(data)
  self.m_bIsRequesting = false
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function InviteActivity:onEnter()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.OnlineReward, handler(self, self.GetRewardCallback))
  self:AddTouch()
end
function InviteActivity:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.OnlineReward)
end
function InviteActivity:InitUI()
  self.m_bg = display.newScale9Sprite("UI/scale9/bantouming4.png", 0, 0, cc.size(590, 405))
  self:addChild(self.m_bg)
  local titleBg = display.newScale9Sprite("UI/scale9/huisejianbianchangtiao.png", 0, 0, cc.size(583, 34))
  td.AddRelaPos(self.m_bg, titleBg, 1, cc.p(0.5, 0.95))
  local titleLabel = td.CreateLabel("\233\130\128\232\175\183\229\165\189\229\143\139\233\162\134\229\165\189\231\164\188", td.LIGHT_BLUE, 18)
  td.AddRelaPos(titleBg, titleLabel)
  local label = td.CreateLabel(g_LM:getBy("a00105"), td.LIGHT_BLUE, 18)
  td.AddRelaPos(self.m_bg, label, 1, cc.p(0.1, 0.8))
  self.m_editbox = ccui.EditBox:create(cc.size(380, 40), "UI/scale9/bantouming2.png")
  self.m_editbox:setFontSize(20)
  self.m_editbox:setMaxLength(18)
  td.AddRelaPos(self.m_bg, self.m_editbox, 1, cc.p(0.5, 0.8))
  local btn = td.CreateBtn(td.BtnType.BlueShort)
  btn:scale(0.7)
  td.AddRelaPos(self.m_bg, btn, 1, cc.p(0.9, 0.8))
  td.BtnAddTouch(btn, function()
    local str = self.m_editbox:getText()
    if self.m_bIsRequsting or str == "" then
      return
    end
    self.m_bIsRequsting = true
    self:SendRedeemReq(str)
  end)
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 580, 265),
    touchOnContent = false,
    scale = td.GetAutoScale()
  })
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:setPosition(5, 5)
  self.m_bg:addChild(self.m_UIListView, 1)
  self:RefreshList()
end
function InviteActivity:RefreshList()
  local vActInfos = ActivityInfoManager:GetInstance():GetInviteInfos()
  self.m_UIListView:removeAllItems()
  for i, var in ipairs(vActInfos) do
    local item = self:CreateItem(var)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function InviteActivity:CreateItem(info)
  local itemNode = display.newNode()
  local item = self.m_UIListView:newItem(itemNode)
  local autoScale = td.GetAutoScale()
  local bgSize = cc.size(580, 85)
  local itembg = display.newScale9Sprite("UI/scale9/jianglidikuang.png", 0, 0, bgSize, cc.rect(11, 26, 5, 25))
  itembg:setAnchorPoint(cc.p(0, 0))
  itembg:setName("bg")
  itemNode:setScale(autoScale)
  itemNode:setContentSize(bgSize)
  itembg:addTo(itemNode)
  local itemInfo = ItemInfoManager:GetInstance():GetItemInfo(info.itemId)
  local iconBg = display.newScale9Sprite("UI/scale9/bantouming4.png", 0, 0, cc.size(75, 75))
  td.AddRelaPos(itembg, iconBg, 1, cc.p(0.1, 0.5))
  local iconSpr = display.newSprite(itemInfo.icon .. td.PNG_Suffix)
  iconSpr:scale(0.7)
  td.AddRelaPos(iconBg, iconSpr)
  local numLabel = td.CreateLabel("x" .. info.num, td.WHITE, 16, td.OL_BLACK)
  td.AddRelaPos(iconBg, numLabel, 1, cc.p(0.5, 0.2))
  local nameLabel = td.CreateLabel(self:GetDesc(info.type, info.value), td.WHITE, 18)
  nameLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itembg, nameLabel, 1, cc.p(0.2, 0.7))
  local label = td.CreateBMF(g_LM:getBy("a00059") .. ":", "Fonts/BlackWhite18.fnt", 1, true)
  label:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itembg, label, 1, cc.p(0.2, 0.2))
  local jdLabel = td.CreateLabel("0/" .. info.value, td.LIGHT_GREEN, 16, td.OL_BLACK)
  jdLabel:setAnchorPoint(cc.p(0, 0.5))
  jdLabel:setPosition(cc.p(label:getPositionX() + label:getBoundingBox().width, bgSize.height * 0.2))
  itembg:addChild(jdLabel)
  local btn = td.CreateBtn(td.BtnType.GreenShort)
  td.AddRelaPos(itembg, btn, 1, cc.p(0.85, 0.5))
  td.BtnAddTouch(btn, function()
    if self.m_bIsRequsting or str == "" then
      return
    end
    self.m_bIsRequsting = true
    self:SendRedeemReq(str)
  end)
  item:setItemSize((bgSize.width + 5) * autoScale, (bgSize.height + 3) * autoScale)
  return item
end
function InviteActivity:GetDesc(type, value)
  local str = ""
  if type == 1 then
    str = "\233\130\128\232\175\183%d\228\184\170\229\165\189\229\143\139"
  elseif type == 2 then
    str = "\233\130\128\232\175\183\231\154\132\229\165\189\229\143\139\232\190\190\229\136\176%d\231\186\167"
  elseif type == 3 then
    str = "\233\130\128\232\175\183\231\154\132\229\165\189\229\143\139\229\133\133\229\128\188\232\190\190\229\136\176%d\229\133\131"
  end
  return string.format(str, value)
end
function InviteActivity:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if not self:isVisible() then
      return false
    end
    local bResult = false
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_UIListView:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
      bResult = true
      self.m_bIsTouchInList = true
    end
    return bResult
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_UIListView:onTouch_({
        name = "moved",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bIsTouchInList then
      self.m_UIListView:onTouch_({
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
function InviteActivity:SendGetRewardReq(index)
  self.m_bIsRequesting = true
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.OnlineReward
  Msg.sendData = {id = index}
  tdRequest:Send(Msg)
end
function InviteActivity:GetRewardCallback(data)
  if data.state == td.ResponseState.Success then
  end
  self.m_bIsRequesting = false
end
return InviteActivity
