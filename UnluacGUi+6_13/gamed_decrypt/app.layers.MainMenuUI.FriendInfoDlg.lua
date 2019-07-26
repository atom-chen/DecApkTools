local TDHttpRequest = require("app.net.TDHttpRequest")
local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local FriendInfoDlg = class("FriendInfoDlg", BaseDlg)
function FriendInfoDlg:ctor()
  FriendInfoDlg.super.ctor(self)
  self.m_useData = nil
  self.m_userId = nil
end
function FriendInfoDlg:onEnter()
  FriendInfoDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.PlayerDetail, handler(self, self.GetPlayerInfoCallback))
  if self.m_useData then
    self:InitUI()
    self:AddEvents()
  else
    self:SendGetPlayerInfoReq(self.m_userId)
  end
end
function FriendInfoDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.PlayerDetail)
  FriendInfoDlg.super.onExit(self)
end
function FriendInfoDlg:SetData(userId)
  self.m_userId = userId
  self.m_useData = UserDataManager:GetInstance():GetOtherData(userId)
end
function FriendInfoDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/PlayerInfoDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  local inFunc = function(data)
    local parent = data.parent
    local node = data.node
    parent:addChild(node)
    node:setPosition(data.pos)
    if data.ancPos then
      node:setAnchorPoint(data.ancPos)
    end
  end
  local portraitInfo = require("app.info.CommanderInfoManager"):GetInstance():GetPortraitInfo(self.m_useData.image_id)
  local pTmpNode = cc.uiloader:seekNodeByName(self.m_bg, "Image_head")
  pTmpNode:loadTexture(portraitInfo.file .. td.PNG_Suffix)
  if self.m_useData.uname == "" then
    self.m_useData.uname = "NO." .. self.m_userId
  end
  local palyerName = self.m_useData.uname
  pTmpNode = td.CreateLabel(palyerName, td.WHITE, 20)
  inFunc({
    parent = self.m_bg,
    node = pTmpNode,
    pos = cc.p(170, 250),
    ancPos = cc.p(0, 0.5)
  })
  local shenwang = self.m_useData.reputation
  local pCommanderInfoManager = require("app.info.CommanderInfoManager").GetInstance()
  local pHonorInfo = pCommanderInfoManager:GetHonorInfoByRepu(shenwang)
  local iconSpr = display.newSprite(pHonorInfo.image .. td.PNG_Suffix)
  iconSpr:scale(0.6)
  inFunc({
    parent = self.m_bg,
    node = iconSpr,
    pos = cc.p(170, 200),
    ancPos = cc.p(0, 0.5)
  })
  pTmpNode = td.CreateLabel(pHonorInfo.military_rank, td.YELLOW)
  inFunc({
    parent = self.m_bg,
    node = pTmpNode,
    pos = cc.p(170 + iconSpr:getBoundingBox().width, 200),
    ancPos = cc.p(0, 0.5)
  })
  local label = td.CreateLabel(g_LM:getBy("a00105"), td.LIGHT_BLUE)
  inFunc({
    parent = self.m_bg,
    node = label,
    pos = cc.p(60, 140),
    ancPos = cc.p(0, 0.5)
  })
  pTmpNode = td.CreateLabel(self.m_userId, td.WHITE, 18)
  inFunc({
    parent = self.m_bg,
    node = pTmpNode,
    pos = cc.p(60 + label:getContentSize().width, 140),
    ancPos = cc.p(0, 0.5)
  })
  label = td.CreateLabel(g_LM:getBy("a00032") .. ":", td.LIGHT_GREEN)
  inFunc({
    parent = self.m_bg,
    node = label,
    pos = cc.p(60, 80),
    ancPos = cc.p(0, 0.5)
  })
  local zhanli = self.m_useData.attack
  pTmpNode = td.CreateLabel(zhanli)
  inFunc({
    parent = self.m_bg,
    node = pTmpNode,
    pos = cc.p(60 + label:getContentSize().width, 80),
    ancPos = cc.p(0, 0.5)
  })
  label = td.CreateLabel(g_LM:getBy("it00003") .. ":", td.LIGHT_GREEN)
  inFunc({
    parent = self.m_bg,
    node = label,
    pos = cc.p(245, 80),
    ancPos = cc.p(0, 0.5)
  })
  pTmpNode = td.CreateLabel(shenwang)
  inFunc({
    parent = self.m_bg,
    node = pTmpNode,
    pos = cc.p(245 + label:getContentSize().width, 80),
    ancPos = cc.p(0, 0.5)
  })
  cc.uiloader:seekNodeByName(self.m_bg, "Button_honor"):setVisible(false)
  local bIsFriend = UserDataManager:GetInstance():CheckIsFriend(self.m_userId)
  if not bIsFriend then
    local addBtn = ccui.Button:create("UI/button/jiaweihaoyou1_button.png", "UI/button/jiaweihaoyou2_button.png")
    addBtn:addTouchEventListener(function(sender, eventType)
      if ccui.TouchEventType.ended == eventType then
        UserDataManager:GetInstance():SendAddFriendReq(self.m_userId)
      end
    end)
    td.AddRelaPos(self.m_bg, addBtn, 1, cc.p(0.5, 0))
  end
  local renameBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_name")
  renameBtn:setVisible(false)
end
function FriendInfoDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function(times)
        self:close()
      end, 0.016666666666666666)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function FriendInfoDlg:SendGetPlayerInfoReq(id)
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.PlayerDetail
  Msg.sendData = {fid = id}
  tdRequest:Send(Msg)
end
function FriendInfoDlg:GetPlayerInfoCallback(data)
  self.m_useData = data
  UserDataManager:GetInstance():AddOtherData(data)
  self:InitUI()
  self:AddEvents()
end
return FriendInfoDlg
