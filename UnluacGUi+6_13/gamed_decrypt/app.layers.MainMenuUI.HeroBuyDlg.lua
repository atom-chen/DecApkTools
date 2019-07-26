local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local InformationManager = require("app.layers.InformationManager")
local RoundProgressBar = require("app.widgets.RoundProgressBar")
local BaseDlg = require("app.layers.BaseDlg")
local HeroBuyDlg = class("HeroBuyDlg", BaseDlg)
HeroBuyDlg.BuyType = {DIAMOND = 1, GOLD = 2}
function HeroBuyDlg:ctor(heroId)
  HeroBuyDlg.super.ctor(self)
  self.m_heroId = heroId
  self.m_showingHero = false
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function HeroBuyDlg:onEnter()
  HeroBuyDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.MallBuy, handler(self, self.MallBuyCallback))
  self:AddEvents()
end
function HeroBuyDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.MallBuy)
  HeroBuyDlg.super.onExit(self)
end
function HeroBuyDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/HeroBuyDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_panelBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_bg2 = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg2")
  local heroProfiles = require("app.config.hero_profile")
  local heroInfo = require("app.info.ActorInfoManager"):GetInstance():GetHeroInfo(self.m_heroId)
  local spine = SkeletonUnit:create(heroInfo.image)
  spine:setName("spine")
  spine:PlayAni("stand", true)
  td.AddRelaPos(self.m_bg, spine, 1, cc.p(0.5, 0.31))
  local ratingIcon = td.CreateRatingIcon(heroInfo.rate)
  ratingIcon:pos(255, 317):addTo(self.m_bg)
  local itemName = heroInfo.name
  local nameLabel = td.CreateLabel(itemName, td.WHITE, 22, td.OL_BLACK)
  td.AddRelaPos(self.m_bg, nameLabel, 1, cc.p(0.5, 0.885))
  local careerIcon = td.CreateCareerIcon(heroInfo.career)
  careerIcon:pos(43, 318):addTo(self.m_bg)
  self.heroProfile = heroProfiles[self.m_heroId]
  local descLabel = td.CreateLabel(self.heroProfile.desc, td.LIGHT_BLUE, 18, td.OL_BLACK, nil, cc.size(170, 70))
  td.AddRelaPos(self.m_bg2, descLabel, 1, cc.p(0.55, 0.32))
  for i = 1, 4 do
    local pgBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_barbg" .. i)
    local pgBar = RoundProgressBar.new("UI/mall/jindutiao.png")
    pgBar:SetPercent(self.heroProfile.property[i] * 10)
    td.AddRelaPos(pgBg, pgBar)
  end
  local labelPrice = cc.uiloader:seekNodeByName(self.m_uiRoot, "Label_price")
  local costIcon = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_diamond")
  self.m_pBtnBuy = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_buy_4")
  td.BtnAddTouch(self.m_pBtnBuy, handler(self, self.DoCallback))
  td.BtnSetTitle(self.m_pBtnBuy, self:GetSourceText(self.heroProfile.source))
  if self.heroProfile.source == 3 then
    local storeItemInfo = require("app.info.CommonInfoManager"):GetInstance():GetHeroMallItem(self.m_heroId)
    self.m_price = storeItemInfo.price
    self.m_id = storeItemInfo.id
    self.m_itemId = storeItemInfo.item
    local iconFile
    if storeItemInfo.consume_type == HeroBuyDlg.BuyType.GOLD then
      self.m_maxCnt = UserDataManager:GetInstance():GetGold()
      iconFile = td.GOLD_ICON
      self.m_buyType = td.BuyType.Gold
    else
      self.m_maxCnt = UserDataManager:GetInstance():GetDiamond()
      iconFile = td.DIAMOND_ICON
      self.m_buyType = td.BuyType.Diamond
    end
    labelPrice:setString(tostring(self.m_price))
    if self.m_maxCnt < self.m_price then
      td.EnableButton(self.m_pBtnBuy, false)
    end
  else
    td.EnableButton(self.m_pBtnBuy, false)
    labelPrice:setVisible(false)
    costIcon:setVisible(false)
  end
end
function HeroBuyDlg:GetSourceText(sourceType)
  if sourceType == 1 then
    return "\233\166\150\229\133\133\229\165\150\229\138\177"
  elseif sourceType == 2 then
    return "VIP\231\173\137\231\186\167\229\165\150\229\138\177"
  else
    return g_LM:getBy("a00115")
  end
end
function HeroBuyDlg:DoCallback()
  if self.heroProfile.source ~= 3 then
    td.alert(self:GetSourceText(self.heroProfile.source), true)
  elseif self.m_maxCnt < self.m_price then
    local errorCode = self.m_buyType == HeroBuyDlg.BuyType.GOLD and td.ErrorCode.GOLD_NOT_ENOUGH or td.ErrorCode.DIAMOND_NOT_ENOUGH
    td.alertErrorMsg(errorCode)
  else
    self:SendBuyRequest()
  end
end
function HeroBuyDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) and not self.m_showingHero then
      self:performWithDelay(function(times)
        self:close()
      end, 0.1)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function HeroBuyDlg:SendBuyRequest()
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.MallBuy
  Msg.sendData = {
    id = self.m_id,
    num = 1
  }
  tdRequest:Send(Msg)
end
function HeroBuyDlg:MallBuyCallback(data)
  if data.state == td.ResponseState.Success then
    self:ShowHeroAnim()
    UserDataManager:GetInstance():SendGetHeroRequest()
    UserDataManager:GetInstance():SendGetSkillsRequest()
  else
    td.alert(g_LM:getBy("a00323"), true)
  end
end
function HeroBuyDlg:ShowHeroAnim()
  self.m_showingHero = true
  local spine = self.m_bg:getChildByName("spine")
  spine:setOpacity(0)
  self.m_panelBg:runAction(cca.seq({
    cca.scaleTo(0.2, 0, 0),
    cca.cb(function()
      self.m_bg2:setScale(0)
      self.m_bg:setScale(0)
    end)
  }))
  self.m_bg:runAction(cca.seq({
    cca.delay(0.2),
    cca.cb(function()
      self.m_panelBg:setScale(1)
    end),
    cca.scaleTo(0.2, 0, 0),
    cca.moveTo(0.2, 568, 320),
    cca.scaleTo(0.2, 1, 1),
    cca.cb(function()
      local pos = spine:getPosition()
      td.CreateUIEffect(self.m_bg, "Spine/UI_effect/UI_goumaiyingxiong_01")
    end),
    cca.delay(0.25),
    cca.cb(function()
      spine:runAction(cca.seq({
        cca.fadeIn(0.2),
        cca.cb(function()
          local heroProfiles = require("app.config.hero_profile")
          spine:PlayAni(heroProfiles[self.m_heroId].anim, false)
          spine:PlayAni("stand", true, true)
          self.m_showingHero = false
        end),
        cca.delay(1),
        cca.cb(function()
          self.m_showingHero = false
          self:close()
        end)
      }))
    end)
  }))
end
return HeroBuyDlg
