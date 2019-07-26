local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local ActivityInfoManager = require("app.info.ActivityInfoManager")
local InformationManager = require("app.layers.InformationManager")
local TouchIcon = require("app.widgets.TouchIcon")
local NewSignActivity = class("NewSignActivity", function()
  return display.newNode()
end)
function NewSignActivity:ctor()
  self.m_bCanSignIn = false
  self.m_tmpNodes = {}
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function NewSignActivity:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/activities/NewSignIn.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_btn = cc.uiloader:seekNodeByName(self.m_bg, "Button_get_3")
  td.BtnAddTouch(self.m_btn, function()
    if self.m_bCanSignIn then
      self:SendSignRequest()
      self.m_bCanSignIn = false
    else
      td.alert(g_LM:getMode("errormsg", td.ErrorCode.RECEIVED_ALREADY))
    end
  end)
  td.BtnSetTitle(self.m_btn, g_LM:getBy("a00052"))
end
function NewSignActivity:InFunc1(data)
  local parent = data.parent
  local node = data.node
  node:setPosition(data.pos)
  local zorder = data.zorder or 1
  parent:addChild(node, zorder)
  table.insert(self.m_tmpNodes, node)
end
function NewSignActivity:ClearTmp()
  for i, var in ipairs(self.m_tmpNodes) do
    var:removeFromParent()
  end
  self.m_tmpNodes = {}
end
function NewSignActivity:RefreshUI()
  self:ClearTmp()
  self.m_signDays = UserDataManager:GetInstance():GetSignInDay()
  local serverTime = UserDataManager:GetInstance():GetServerTime()
  self.m_lastSignTime = UserDataManager:GetInstance():GetSignInTime()
  if self.m_signDays == 0 or self.m_signDays < 7 and td.TimeCompare(serverTime, self.m_lastSignTime) then
    self.m_bCanSignIn = true
  else
    self.m_bCanSignIn = false
    td.BtnSetTitle(self.m_btn, g_LM:getBy("a00053"))
    local btnBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_" .. 8)
    btnBg:loadTexture("UI/activity/anniubantoumingdi_huise.png")
  end
  td.EnableButton(self.m_btn, self.m_bCanSignIn)
  for i = 1, 7 do
    local dayLabel = cc.uiloader:seekNodeByName(self.m_bg, "label" .. i)
    local posx, posy = dayLabel:getPosition()
    local info = ActivityInfoManager:GetInstance():GetSignInfo(i)
    if info.itemId == 1 then
      info.itemId = info.num
      info.num = 1
    end
    local bSigned = true
    if i > self.m_signDays then
      bSigned = false
    end
    local bgSpr
    if bSigned then
      local signSpr = display.newSprite("UI/common/gouxuan.png")
      self:InFunc1({
        parent = self.m_bg,
        node = signSpr,
        pos = cc.p(posx + 30, posy - 100)
      })
      if i == 7 then
        bgSpr = display.newSprite("UI/activity/diqitiandikuang_huise.png")
      else
        bgSpr = display.newScale9Sprite("UI/scale9/dikuang8.png", 0, 0, cc.size(95, 109))
      end
    elseif i == 7 then
      bgSpr = display.newSprite("UI/activity/diqitiandikuang.png")
    else
      bgSpr = display.newScale9Sprite("UI/scale9/dikuang7.png", 0, 0, cc.size(95, 109))
    end
    self:InFunc1({
      parent = self.m_bg,
      node = bgSpr,
      zorder = -1,
      pos = cc.p(posx, posy - 65)
    })
    local iconSpr = TouchIcon.new(info.itemId, true, false)
    iconSpr:scale(0.55)
    self:InFunc1({
      parent = self.m_bg,
      node = iconSpr,
      pos = cc.p(posx, posy - 55)
    })
    local numLabel = td.CreateLabel("x" .. info.num, td.WHITE, 18)
    self:InFunc1({
      parent = self.m_bg,
      node = numLabel,
      pos = cc.p(posx, posy - 100)
    })
    local itemInfo = td.GetItemInfo(info.itemId)
    local nameLabel = td.CreateLabel(itemInfo.name, td.GRAY, 18)
    self:InFunc1({
      parent = self.m_bg,
      node = nameLabel,
      pos = cc.p(posx, posy - 130)
    })
    if self.m_bCanSignIn and i == self.m_signDays + 1 then
      local spine1 = SkeletonUnit:create("Spine/UI_effect/EFT_dedaojineng_02")
      spine1:setScale(0.7)
      self:InFunc1({
        parent = self.m_bg,
        node = spine1,
        zorder = 0,
        pos = cc.p(posx, posy - 55)
      })
      spine1:PlayAni("animation", true)
    end
  end
end
function NewSignActivity:onEnter()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.NewSignIn, handler(self, self.SignInCallback))
  self:RefreshUI()
end
function NewSignActivity:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.NewSignIn)
end
function NewSignActivity:SendSignRequest()
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.NewSignIn
  Msg.sendData = nil
  tdRequest:Send(Msg)
end
function NewSignActivity:SignInCallback(data)
  if data.state == td.ResponseState.Success then
    UserDataManager:GetInstance():UpdateSignInDay()
    UserDataManager:GetInstance():UpdateSignInTime()
    self:RefreshUI()
    local info = ActivityInfoManager:GetInstance():GetSignInfo(self.m_signDays)
    local itemHero = require("app.config.shop_item_hero")
    if itemHero[info.itemId] then
      UserDataManager:GetInstance():SendGetHeroRequest()
      UserDataManager:GetInstance():SendGetSkillsRequest()
    end
    InformationManager:GetInstance():ShowInfoDlg({
      type = td.ShowInfo.Item,
      items = {
        [info.itemId] = info.num
      }
    })
  else
    td.alert(g_LM:getBy("a00323"), true)
  end
end
return NewSignActivity
