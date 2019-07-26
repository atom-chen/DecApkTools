local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local ItemInfoManager = require("app.info.ItemInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local UserDataManager = require("app.UserDataManager")
local UnitDataManager = require("app.UnitDataManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local TouchIcon = require("app.widgets.TouchIcon")
local UnitEvoDlg = class("UnitEvoDlg", BaseDlg)
function UnitEvoDlg:ctor(soldierId)
  UnitEvoDlg.super.ctor(self, 220)
  self.udMng = UserDataManager:GetInstance()
  self.unitMng = UnitDataManager:GetInstance()
  self.siMng = StrongInfoManager:GetInstance()
  self.aiMng = ActorInfoManager:GetInstance()
  self.soldierId = soldierId
  self.soldierData = self.unitMng:GetSoldierData(self.soldierId)
  self.bActionOver = true
  self:InitUI()
end
function UnitEvoDlg:onEnter()
  UnitEvoDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.EvoSoldier, handler(self, self.EvoSuccess))
  self:AddEvents()
end
function UnitEvoDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.EvoSoldier)
  UnitEvoDlg.super.onExit(self)
end
function UnitEvoDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/UnitEvoDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:SetTitle(td.Word_Path .. "wenzi_xunlianchang.png")
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.m_upgIcon = cc.uiloader:seekNodeByName(self.m_bg, "Image_icon2")
  self.m_panelItems = cc.uiloader:seekNodeByName(self.m_bg, "Panel_items")
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_item")
  label:setString(g_LM:getBy("a00082") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_levelLabel")
  label:setString(g_LM:getBy("a00390") .. ":")
  self:InitInfo()
  self:InitBtn()
  self:RefreshNeedItems()
  self:PlayEnterAnim()
end
function UnitEvoDlg:PlayEnterAnim()
end
function UnitEvoDlg:InitInfo()
  local soldierInfo = self.soldierData.soldierInfo
  local icon1 = cc.uiloader:seekNodeByName(self.m_bg, "Image_icon1")
  icon1:loadTexture(soldierInfo.head .. td.PNG_Suffix)
  self:AddStars(icon1, self.soldierData.star)
  local icon2 = cc.uiloader:seekNodeByName(self.m_bg, "Image_icon2")
  icon2:loadTexture(soldierInfo.head .. td.PNG_Suffix)
  self:AddStars(icon2, math.min(self.soldierData.star + 1, self.soldierData.quality))
  local textCrit = cc.uiloader:seekNodeByName(self.m_bg, "Text_crit")
  textCrit:setString(g_LM:getBy("a00068"))
  local textCritData = cc.uiloader:seekNodeByName(self.m_bg, "Text_crit_data")
  local soldierData = self.unitMng:GetSoldierData(self.soldierId)
  textCritData:setString(soldierInfo.property[td.Property.Crit].value .. "%")
  local textCritInc = cc.uiloader:seekNodeByName(self.m_bg, "Text_crit_inc")
  textCritInc:setString("+" .. tostring(5) .. "%")
  local textDodge = cc.uiloader:seekNodeByName(self.m_bg, "Text_dodge")
  textDodge:setString(g_LM:getBy("a00069"))
  local textDodgeData = cc.uiloader:seekNodeByName(self.m_bg, "Text_dodge_data")
  textDodgeData:setString(soldierInfo.property[td.Property.Dodge].value .. "%")
  local textDodgeInc = cc.uiloader:seekNodeByName(self.m_bg, "Text_dodge_inc")
  textDodgeInc:setString("+" .. tostring(5) .. "%")
end
function UnitEvoDlg:AddStars(icon, num)
  local iconWidth = icon:getContentSize().width
  for i = 1, num do
    local starSpr = display.newSprite("UI/icon/xingxing_icon.png")
    local starSize = starSpr:getContentSize()
    starSpr:scale(iconWidth / 4 / starSize.width)
    starSpr:align(display.RIGHT_BOTTOM, iconWidth / 5 * i, -25):addTo(icon)
  end
end
function UnitEvoDlg:InitBtn()
  self.evoBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_evo")
  td.BtnAddTouch(self.evoBtn, handler(self, self.OnBtnClicked))
  local evoBtnAnim = SkeletonUnit:create("Spine/UI_effect/UI_jinsheng_01")
  evoBtnAnim:pos(335, 322):addTo(self.m_bg)
  evoBtnAnim:PlayAni("animation_01", true)
  self.evoBtn:addTouchEventListener(function(sender, eventType)
    if eventType == ccui.TouchEventType.began then
      evoBtnAnim:PlayAni("animation_02", false)
    elseif eventType == ccui.TouchEventType.ended then
      evoBtnAnim:PlayAni("animation_01", true, true)
      self:OnBtnClicked()
    end
  end)
  local titleSpr
  local bEnable = self:CheckCanEvo()
  if bEnable then
    titleSpr = display.newSprite(td.Word_Path .. "wenzi_jinsheng.png")
  else
    titleSpr = display.newGraySprite(td.Word_Path .. "wenzi_jinsheng.png")
  end
  td.AddRelaPos(self.evoBtn, titleSpr)
end
function UnitEvoDlg:RefreshNeedItems()
  local starCost = self.siMng:GetSoldierStrongInfo(self.soldierId).star_cost
  local currStar = self.soldierData.star
  local data = starCost[currStar]
  local canEvo, errorCode = self.unitMng:IsRoleCanEvo(self.soldierId)
  if data then
    self.m_panelItems:removeAllChildren()
    for i = 1, #data do
      if data[i].itemId then
        local itemIcon = TouchIcon.new(data[i].itemId)
        itemIcon:setScale(0.7, 0.7)
        local iconSize = itemIcon:getContentSize()
        local itemBg = display.newScale9Sprite("UI/scale9/bantouming4.png", 0, 0, iconSize)
        td.AddRelaPos(itemIcon, itemBg, -1)
        if #data == 1 then
          td.AddRelaPos(self.m_panelItems, itemIcon)
        else
          td.AddRelaPos(self.m_panelItems, itemIcon, 0, cc.p(0.03 + (i - 1) * 0.32, 0.5))
        end
        local isEnough = false
        local myItemNum
        if data[i].itemId ~= 20001 then
          myItemNum = self.udMng:GetItemNum(data[i].itemId)
          if myItemNum >= data[i].num then
            isEnough = true
          end
        else
          myItemNum = self.udMng:GetGold()
          if myItemNum >= data[i].num then
            isEnough = true
          end
        end
        local quantity
        if isEnough then
          if data[i].itemId ~= 20001 then
            quantity = td.CreateLabel(myItemNum .. "/" .. data[i].num, td.WHITE, 28)
          else
            quantity = td.CreateLabel("X" .. data[i].num, td.WHITE, 28)
          end
        elseif data[i].itemId ~= 20001 then
          quantity = td.CreateLabel(myItemNum .. "/" .. data[i].num, td.RED, 28)
        else
          quantity = td.CreateLabel("X" .. data[i].num, td.RED, 28)
        end
        td.AddRelaPos(itemIcon, quantity, 0, cc.p(0.5, -0.3))
      end
    end
  end
  local levelIcon = cc.uiloader:seekNodeByName(self.m_bg, "Icon_level")
  local levelText = cc.uiloader:seekNodeByName(levelIcon, "Text_level")
  levelIcon:loadTexture(self.soldierData.soldierInfo.head .. td.PNG_Suffix)
  levelText:setString("LV." .. self.soldierData.star * 10)
  if self.soldierData.level < self.soldierData.star * 10 then
    levelText:setColor(td.RED)
  end
end
function UnitEvoDlg:CheckCanEvo()
  local bEnable, errorCode = true, td.ErrorCode.SUCCESS
  local soldierData = self.soldierData
  local starCost = self.siMng:GetSoldierStrongInfo(self.soldierId).star_cost
  local currStar = soldierData.star
  local costData = starCost[currStar]
  if soldierData.star >= soldierData.quality then
    bEnable, errorCode = false, td.ErrorCode.LEVEL_MAX
  elseif soldierData.level < soldierData.star * 10 then
    bEnable, errorCode = false, td.ErrorCode.LEVEL_LOW
  else
    for i = 1, #costData do
      local itemId = costData[i].itemId
      local itemNum = costData[i].num
      if itemId ~= 20001 then
        local myItemNum = self.udMng:GetItemNum(itemId)
        if itemNum > myItemNum then
          bEnable, errorCode = false, td.ErrorCode.MATERIAL_NOT_ENOUGH
          break
        end
      else
        local myItemNum = self.udMng:GetGold()
        if itemNum > myItemNum then
          bEnable, errorCode = false, td.ErrorCode.GOLD_NOT_ENOUGH
          break
        end
      end
    end
  end
  return bEnable, errorCode
end
function UnitEvoDlg:OnBtnClicked()
  local bEnable, errorCode = self:CheckCanEvo()
  if bEnable then
    self.evoBtn:setDisable(true)
    self:SendEvoRequest()
  else
    td.alertErrorMsg(errorCode)
  end
end
function UnitEvoDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_panelItems:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_panelItems, tmpPos) and self.bActionOver then
      self:performWithDelay(function()
        self:close()
      end, 0.1)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function UnitEvoDlg:OnWealthChanged()
  UnitEvoDlg.super.OnWealthChanged(self)
  self:RefreshNeedItems()
end
function UnitEvoDlg:OnItemUpdate()
  UnitEvoDlg.super.OnItemUpdate(self)
  self:RefreshNeedItems()
end
function UnitEvoDlg:SendEvoRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.EvoSoldier
  Msg.sendData = {
    role_id = self.soldierId
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function UnitEvoDlg:EvoSuccess(data)
  if data.state == td.ResponseState.Success then
    self.bActionOver = false
    StrongInfoManager:GetInstance():UpdateSoldierData(self.soldierId)
    td.CreateUIEffect(self.m_upgIcon, "Spine/UI_effect/EFT_dedaojineng_01", {
      cb = function()
        self.bActionOver = true
        td.dispatchEvent(td.SOLDIER_UPGRADE, 2)
        self:close()
      end
    })
  end
end
return UnitEvoDlg
