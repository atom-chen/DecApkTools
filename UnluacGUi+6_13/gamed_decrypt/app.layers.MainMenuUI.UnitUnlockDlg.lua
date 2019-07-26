local StrongInfoManager = require("app.info.StrongInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local ActorInfoManager = require("app.info.ActorInfoManager")
local UserDataManager = require("app.UserDataManager")
local UnitDataManager = require("app.UnitDataManager")
local BaseDlg = require("app.layers.BaseDlg")
local TouchIcon = require("app.widgets.TouchIcon")
local UnitUnlockDlg = class("UnitUnlockDlg", BaseDlg)
function UnitUnlockDlg:ctor(soldierId, iconPos)
  UnitUnlockDlg.super.ctor(self)
  self.m_uiId = td.UIModule.SoldierUnlock
  self.m_udMng = UserDataManager:GetInstance()
  self.soldierId = soldierId
  self.soldierInfo = ActorInfoManager:GetInstance():GetSoldierInfo(self.soldierId)
  self.soldierData = StrongInfoManager:GetInstance():GetSoldierStrongInfo(self.soldierId)
  self.m_canUnlock = false
  self.m_canClick = true
  self.m_errorCode = nil
  self.m_changableNodes = {}
  self.m_lackIcon = nil
  self.m_iconPos = iconPos
  self:InitUI()
end
function UnitUnlockDlg:onEnter()
  UnitUnlockDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UnlockSoldier, handler(self, self.UnlockCallback))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  self:AddBtnEvents()
  self:AddTouch()
  self:CheckGuide()
end
function UnitUnlockDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.UnlockSoldier)
  UnitUnlockDlg.super.onExit(self)
end
function UnitUnlockDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/UnitUnlockDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_iconBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_iconBg")
  self.btn_cancel = cc.uiloader:seekNodeByName(self.m_bg, "Button_cancel")
  td.BtnSetTitle(self.btn_cancel, g_LM:getBy("a00116"))
  self.btn_confirm = cc.uiloader:seekNodeByName(self.m_bg, "Button_confirm")
  td.BtnSetTitle(self.btn_confirm, g_LM:getBy("a00009"))
  self:InitSoldier()
end
function UnitUnlockDlg:InitSoldier()
  local soldierInfo = self.soldierInfo
  if soldierInfo.career == td.CareerType.Saber then
    self.m_iconBg:loadTexture("UI/camp/xiaobing_dikuanghuangse.png")
  elseif soldierInfo.career == td.CareerType.Archer then
    self.m_iconBg:loadTexture("UI/camp/xiaobing_dikuanglvse.png")
  end
  self.sk = SkeletonUnit:create(soldierInfo.image)
  self.sk:setScale(0.8)
  self.sk:PlayAni("stand")
  td.AddRelaPos(self.m_bg, self.sk, 1, cc.p(0.5, 0.62))
  local starLevel = self.soldierData.quality
  for i = 1, starLevel do
    local starFile
    if i == 1 then
      starFile = "UI/icon/xingxing_icon.png"
    else
      starFile = "UI/icon/xingxing2_icon.png"
    end
    local star = display.newSprite(starFile)
    star:pos(367, 399 - 25 * (i - 1)):addTo(self.m_bg)
  end
  local ratingIcon = td.CreateRatingIcon(soldierInfo.rate)
  td.AddRelaPos(self.m_iconBg, ratingIcon, 1, cc.p(0.1, 0.9))
  local nameLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_name")
  nameLabel:setString(soldierInfo.name)
  local data = {
    soldierInfo.property[td.Property.Atk].value,
    soldierInfo.property[td.Property.HP].value,
    soldierInfo.property[td.Property.Def].value,
    soldierInfo.property[td.Property.Speed].value,
    60 / soldierInfo.property[td.Property.AtkSp].value,
    string.format("%d%%", soldierInfo.property[td.Property.Crit].value)
  }
  for i = 1, 6 do
    local numLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_prop_" .. i)
    numLabel:setString(data[i])
  end
  local itemBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_itemBg")
  local unlockTitle = td.CreateLabel(g_LM:getBy("a00412"), td.WHITE, 22, td.OL_BLACK)
  unlockTitle:pos(240, 100):addTo(itemBg)
  self:RefreshUI()
end
function UnitUnlockDlg:RefreshUI()
  for i, var in ipairs(self.m_changableNodes) do
    var:removeFromParent()
  end
  self.m_changableNodes = {}
  self.m_lackIcon = nil
  local preSoldierId = self.soldierData.unlock.soldierId
  local lvlRequired = self.soldierData.unlock.level
  local preSoldierInfo = ActorInfoManager:GetInstance():GetSoldierInfo(preSoldierId)
  local soldierIcon = display.newSprite(preSoldierInfo.head .. td.PNG_Suffix)
  local iconFrame = display.newScale9Sprite("UI/scale9/bantouming4.png", 0, 0, cc.size(90, 90))
  td.AddRelaPos(soldierIcon, iconFrame, -1, cc.p(0.5, 0.5))
  soldierIcon:setScale(0.6, 0.6)
  soldierIcon:pos(100, 160):addTo(self.m_bg)
  table.insert(self.m_changableNodes, soldierIcon)
  local canUnlock = true
  local levelLabel = td.CreateLabel("Lv." .. lvlRequired, td.WHITE, 34)
  local preSoldierData = UnitDataManager:GetInstance():GetSoldierData(preSoldierId)
  if not preSoldierData or lvlRequired > preSoldierData.level then
    levelLabel:setColor(td.RED)
    canUnlock = false
    self.m_errorCode = td.ErrorCode.LEVEL_LOW
  end
  levelLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(soldierIcon, levelLabel, 0, cc.p(1.1, 0.5))
  local items = self.soldierData.unlock.item
  for i = 1, #items do
    local frame = display.newScale9Sprite("UI/scale9/bantouming4.png", 0, 0, cc.size(90, 90))
    frame:scale(0.6):pos(100 + 160 * i, 160):addTo(self.m_bg)
    local itemSprite = TouchIcon.new(items[i].itemId, true)
    itemSprite:setScale(0.7)
    td.AddRelaPos(frame, itemSprite, 1, cc.p(0.5, 0.5))
    table.insert(self.m_changableNodes, itemSprite)
    local numLabel
    if items[i].itemId == td.ItemID_Gold then
      numLabel = td.CreateLabel("X " .. items[i].num, td.WHITE, 30)
      if self.m_udMng:GetGold() < items[i].num then
        numLabel:setColor(td.RED)
        canUnlock = false
        self.m_errorCode = td.ErrorCode.GOLD_NOT_ENOUGH
      end
    else
      numLabel = td.CreateLabel(self.m_udMng:GetItemNum(items[i].itemId) .. "/" .. items[i].num, td.WHITE, 30)
      if self.m_udMng:GetItemNum(items[i].itemId) < items[i].num then
        numLabel:setColor(td.RED)
        canUnlock = false
        self.m_errorCode = td.ErrorCode.MATERIAL_NOT_ENOUGH
        self.m_lackIcon = itemSprite
      end
    end
    numLabel:setAnchorPoint(0, 0.5)
    td.AddRelaPos(frame, numLabel, 0, cc.p(1.1, 0.5))
    table.insert(self.m_changableNodes, numLabel)
    td.CreateUIEffect(frame, "Spine/UI_effect/UI_kezhitishi_01", {scale = 2})
  end
  self.m_canUnlock = canUnlock
end
function UnitUnlockDlg:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) and self.m_canClick then
      self:performWithDelay(function()
        self:close()
      end, 0.05)
      return false
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function UnitUnlockDlg:AddBtnEvents()
  td.BtnAddTouch(self.btn_confirm, handler(self, self.OnButtonClicked), nil, td.ButtonEffectType.Long)
  td.BtnAddTouch(self.btn_cancel, handler(self, function()
    self:close()
  end))
end
function UnitUnlockDlg:OnButtonClicked()
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  if self.m_canUnlock and self.m_canClick then
    self.m_canClick = false
    self:SendUnlockRequest()
  else
    td.alertErrorMsg(self.m_errorCode)
    if self.m_lackIcon then
      local spine = SkeletonUnit:create("Spine/UI_effect/UI_shouzhi_01")
      spine:scale(1.2)
      spine:PlayAni("animation_02", true)
      td.ShowRP(self.m_lackIcon, true, cc.p(0.5, 0.5), spine)
    end
  end
end
function UnitUnlockDlg:OnWealthChanged()
  UnitUnlockDlg.super.OnWealthChanged(self)
  self:RefreshUI()
end
function UnitUnlockDlg:OnItemUpdate()
  UnitUnlockDlg.super.OnItemUpdate(self)
  self:RefreshUI()
end
function UnitUnlockDlg:SendUnlockRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.UnlockSoldier
  Msg.sendData = {
    role_id = self.soldierId
  }
  Msg.cbData = {
    id = self.soldierId
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function UnitUnlockDlg:UnlockCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    UnitDataManager:GetInstance():UnlockSoldier(cbData.id)
    self:PlayUnlockAnim(cbData)
  else
    self.m_canClick = true
  end
end
function UnitUnlockDlg:PlayUnlockAnim(cbData)
  self:CreateForgroundMask()
  local effect = td.CreateUIEffect(self.sk, "Spine/UI_effect/UI_iconxishou_01", {
    scale = 1.5,
    pos = cc.p(self.sk:getContentSize().width / 2, self.sk:getContentSize().height / 2 + 110)
  })
  local particle = ParticleManager:GetInstance():CreateParticle("Effect/tuowei_06.plist")
  td.AddRelaPos(self.sk, particle, 1, cc.p(0.5, 0.65))
  local x = particle:getPositionX()
  local y = particle:getPositionY()
  local dest = self.sk:convertToNodeSpace(self.m_iconPos)
  particle:setLocalZOrder(99999)
  particle:runAction(cca.seq({
    cca.delay(0.3),
    cc.BezierTo:create(0.5, {
      cc.p(x, y),
      cc.p(x - 400, y + 400),
      cc.p(x + 300, y + 150)
    }),
    cc.BezierTo:create(0.5, {
      cc.p(x + 300, y + 150),
      cc.p(x - 150, y - 150),
      dest
    }),
    cca.cb(function()
      td.dispatchEvent(td.SOLDIER_UNLOCK, cbData.id)
      self:close()
    end)
  }))
  self.m_bg:performWithDelay(function()
    self.m_bg:runAction(cca.fadeOut(0.5, 0))
  end, 0.5)
  G_SoundUtil:PlaySound(69)
end
return UnitUnlockDlg
