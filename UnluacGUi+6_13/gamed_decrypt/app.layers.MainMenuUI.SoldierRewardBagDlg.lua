local TDHttpRequest = require("app.net.TDHttpRequest")
local BaseDlg = require("app.layers.BaseDlg")
local TouchIcon = require("app.widgets.TouchIcon")
local UserDataManager = require("app.UserDataManager")
local ActivityDataManager = require("app.ActivityDataManager")
local CommonInfoManager = require("app.info.CommonInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local StoreDataManager = require("app.StoreDataManager")
local scheduler = require("framework.scheduler")
local SoldierRewardBagDlg = class("SoldierRewardBagDlg", BaseDlg)
function SoldierRewardBagDlg:ctor(eType)
  SoldierRewardBagDlg.super.ctor(self)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_activityData = nil
  self.packId = nil
  self.vTmpNodes = {}
  self:InitUI()
end
function SoldierRewardBagDlg:onEnter()
  SoldierRewardBagDlg.super.onEnter(self)
  self:AddEvents()
  self.m_activityData = ActivityDataManager:GetInstance():GetSoldierBagActivityData()
  if self.m_activityData and self.m_activityData.items then
    self.packId = tonumber(self.m_activityData.items[1].award[1].itemId)
    self.m_time = self.m_activityData.to - self.m_udMng:GetServerTime()
    self.m_timeScheduler = scheduler.scheduleGlobal(function()
      self:OnTimer()
    end, 1)
    self:RefreshUI()
  end
end
function SoldierRewardBagDlg:onExit()
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
    self.m_timeScheduler = nil
  end
  SoldierRewardBagDlg.super.onExit(self)
end
function SoldierRewardBagDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/SoldierRewardBagDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_buyBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_go")
  self.m_priceLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_price")
  self.m_nameLabel = td.CreateLabel("", td.YELLOW, 20)
  td.AddRelaPos(self.m_bg, self.m_nameLabel, 1, cc.p(0.59, 0.855))
  self.m_timeLabel = td.CreateLabel("", td.WHITE, 18)
  self.m_timeLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self.m_bg, self.m_timeLabel, 1, cc.p(0.34, 0.172))
end
function SoldierRewardBagDlg:RefreshUI()
  if not self.m_activityData then
    return
  end
  for i, var in ipairs(self.vTmpNodes) do
    var:removeFromParent()
  end
  self.vTmpNodes = {}
  local packInfo = CommonInfoManager:GetInstance():GetChargeInfo(td.PayType.RewardBag, self.packId)
  local soldierInfo = require("app.info.ActorInfoManager"):GetInstance():GetSoldierInfo(tonumber(packInfo.custom_data))
  self.m_priceLabel:setString(packInfo.value)
  self.m_nameLabel:setString(soldierInfo.name)
  local skeleton = SkeletonUnit:create(soldierInfo.image)
  skeleton:scale(0.8)
  skeleton:PlayAni("stand")
  td.AddRelaPos(self.m_bg, skeleton, 1, cc.p(0.32, 0.5))
  table.insert(self.vTmpNodes, skeleton)
  for i, var in ipairs(packInfo.reward) do
    local itemInfo = ItemInfoManager:GetInstance():GetItemInfo(var.itemId)
    local label = td.RichText({
      {
        type = 1,
        str = itemInfo.name,
        color = td.YELLOW,
        size = 18
      },
      {
        type = 1,
        str = " x" .. var.num,
        color = td.WHITE,
        size = 18
      }
    })
    label:align(display.LEFT_CENTER, 330, 345 - 30 * i):addTo(self.m_bg)
    table.insert(self.vTmpNodes, label)
    local posNode = cc.uiloader:seekNodeByName(self.m_uiRoot, "Node_" .. i)
    if posNode then
      local iconSpr = TouchIcon.new(var.itemId, true)
      td.AddRelaPos(posNode, iconSpr)
      table.insert(self.vTmpNodes, iconSpr)
    end
  end
end
function SoldierRewardBagDlg:OnTimer()
  self.m_time = math.max(self.m_time - 1, 0)
  local countDownStr = self:GetTimeDownStr(self.m_time)
  self.m_timeLabel:setString(countDownStr)
  if self.m_time <= 0 then
    td.dispatchEvent(td.CLOSE_GIFT_PACK)
  end
end
function SoldierRewardBagDlg:GetTimeDownStr(time)
  if time <= 0 then
    return ""
  end
  local day, hour, min, sec = math.floor(time / 86400), math.floor(time % 86400 / 3600), math.floor(time % 3600 / 60), math.floor(time % 60)
  local str = string.format("%d\229\164\169 %02d:%02d:%02d", day, hour, min, sec)
  return str
end
function SoldierRewardBagDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function(times)
        self:close()
      end, 0.1)
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  td.BtnAddTouch(self.m_buyBtn, function()
    self.m_udMng:GetTradeIdRequest(self.packId, td.PayType.RewardBag)
  end, nil, td.ButtonEffectType.Long)
  self:AddCustomEvent(td.CLOSE_GIFT_PACK, function()
    self:close()
  end)
end
return SoldierRewardBagDlg
