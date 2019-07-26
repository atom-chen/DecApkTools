local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local CommanderInfoManager = require("app.info.CommanderInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local GuildInfo = require("app.layers.guild.GuildInfo")
local NormalItemSize = cc.size(505, 75)
local GuildApplyAdmitDlg = class("GuildApplyAdmitDlg", BaseDlg)
function GuildApplyAdmitDlg:ctor()
  GuildApplyAdmitDlg.super.ctor(self)
  self.m_gdm = UserDataManager:GetInstance():GetGuildManager()
  self.aList = self.m_gdm:GetPendingMembers()
  self.m_clickedId = nil
  self.m_isReject = false
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function GuildApplyAdmitDlg:onEnter()
  GuildApplyAdmitDlg.super.onEnter(self)
  self:AddEvents()
end
function GuildApplyAdmitDlg:onExit()
  GuildApplyAdmitDlg.super.onExit(self)
end
function GuildApplyAdmitDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  local panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  local bgSize = cc.size(560, 390)
  self.m_bg = display.newScale9Sprite("UI/scale9/yijitankuang2.png", 0, 0, bgSize, cc.rect(110, 80, 5, 2))
  td.AddRelaPos(panel, self.m_bg)
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 510, 325),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:setPosition(25, 30)
  self.m_UIListView:setAlignment(3)
  self.m_bg:addChild(self.m_UIListView)
  self:RefreshList()
end
function GuildApplyAdmitDlg:ModifyCallBack()
  if self.m_clickedId then
    self.m_gdm:RemovePendingMember(self.m_clickedId, self.m_isReject)
    self.aList = self.m_gdm:GetPendingMembers()
  end
  self:RefreshList()
end
function GuildApplyAdmitDlg:RefreshList()
  self.m_UIListView:removeAllItems()
  for key, value in pairs(self.aList) do
    local item = self:CreateItem(value)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function GuildApplyAdmitDlg:CreateItem(data)
  local commanderInfoMng = CommanderInfoManager:GetInstance()
  local itemUI = display.newNode()
  local itemBg = display.newScale9Sprite("UI/scale9/juntuan_dikuang.png", 0, 0, NormalItemSize)
  itemBg:setAnchorPoint(0, 0)
  itemBg:addTo(itemUI)
  local btnAccept = td.CreateBtn(td.BtnType.GreenShort)
  td.BtnAddTouch(btnAccept, function()
    sdata = {
      uid = data.uid,
      type = td.GuildPos.Member
    }
    self.m_clickedId = data.uid
    self.m_isReject = false
    self.m_gdm:SendRequest(sdata, td.RequestID.ModifyMemberPosition)
  end)
  btnAccept:setName("Button_3")
  td.BtnSetTitle(btnAccept, g_LM:getBy("a00183"))
  td.AddRelaPos(itemBg, btnAccept, 1, cc.p(0.6, 0.5))
  local btnReject = td.CreateBtn(td.BtnType.BlueShort)
  btnReject:setName("Button_1")
  td.BtnAddTouch(btnReject, function()
    sdata = {
      uid = data.uid,
      type = 0
    }
    self.m_clickedId = data.uid
    self.m_isReject = true
    self.m_gdm:SendRequest(sdata, td.RequestID.ModifyMemberPosition)
  end)
  td.BtnSetTitle(btnReject, g_LM:getBy("a00184"))
  td.AddRelaPos(itemBg, btnReject, 1, cc.p(0.87, 0.5))
  local headBtn = ccui.Button:create("UI/scale9/bantoumingdikuang2.png", "UI/scale9/bantoumingdikuang2.png")
  headBtn:setScale9Enabled(true)
  headBtn:setContentSize(cc.size(65, 65))
  td.BtnAddTouch(headBtn, function()
    local fid = data.uid
    local tmpNode = require("app.layers.MainMenuUI.FriendInfoDlg").new()
    tmpNode:SetData(fid)
    td.popView(tmpNode, true)
  end)
  td.AddRelaPos(itemBg, headBtn, 1, cc.p(0.08, 0.5))
  local headFile = commanderInfoMng:GetPortraitInfo(data.u_image).file .. td.PNG_Suffix
  local headSpr = display.newSprite(headFile)
  headSpr:scale(headBtn:getContentSize().width * 0.9 / headSpr:getContentSize().width)
  td.AddRelaPos(headBtn, headSpr)
  local nameLabel = td.RichText({
    {
      type = 2,
      file = honorFile,
      scale = 0.6
    },
    {
      type = 1,
      color = td.WHITE,
      size = 20,
      str = data.u_name
    }
  })
  nameLabel:setAnchorPoint(0, 0.5)
  nameLabel:pos(80, NormalItemSize.height * 0.5):addTo(itemBg)
  local item = self.m_UIListView:newItem(itemUI)
  item:setItemSize(NormalItemSize.width * self.m_scale, (NormalItemSize.height + 5) * self.m_scale)
  item:setScale(self.m_scale)
  item:setAnchorPoint(cc.p(0.5, 0.5))
  return item
end
function GuildApplyAdmitDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
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
    else
      local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
      if not isTouchInNode(self.m_bg, tmpPos) then
        self:close()
        bResult = true
      end
      self.m_bIsTouchInList = false
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
  self:AddCustomEvent(td.GUILD_RANK_CHANGED, handler(self, self.ModifyCallBack))
end
return GuildApplyAdmitDlg
