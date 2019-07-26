local ItemInfoManager = require("app.info.ItemInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local ActorInfoManager = require("app.info.ActorInfoManager")
local UserDataManager = require("app.UserDataManager")
local BaseDlg = require("app.layers.BaseDlg")
local TouchIcon = require("app.widgets.TouchIcon")
local HeroUnlockDlg = class("HeroUnlockDlg", BaseDlg)
function HeroUnlockDlg:ctor(heroId, iconPos)
  HeroUnlockDlg.super.ctor(self)
  self.m_uiId = td.UIModule.HeroUnlock
  self.m_udMng = UserDataManager:GetInstance()
  self.aiMng = ActorInfoManager:GetInstance()
  self.heroId = heroId
  self.heroInfo = self.aiMng:GetHeroInfo(self.heroId)
  self.m_canUnlock = true
  self.m_canClick = true
  self.m_errorCode = nil
  self.m_changableNodes = {}
  self.m_lackIcon = nil
  self.m_iconPos = iconPos
  self:InitUI()
end
function HeroUnlockDlg:onEnter()
  HeroUnlockDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UnlockHero, handler(self, self.UnlockCallback))
  self:AddBtnEvents()
  self:AddTouch()
end
function HeroUnlockDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.UnlockHero)
  HeroUnlockDlg.super.onExit(self)
end
function HeroUnlockDlg:InitUI()
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
  self:InitHero()
end
function HeroUnlockDlg:InitHero()
  local heroInfo = self.aiMng:GetHeroInfo(self.heroId)
  self.sk = SkeletonUnit:create(heroInfo.image)
  self.sk:setScale(0.8)
  self.sk:PlayAni("stand")
  td.AddRelaPos(self.m_bg, self.sk, 1, cc.p(0.5, 0.62))
  local starLevel = self.heroInfo.quality
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
  local ratingIcon = td.CreateRatingIcon(heroInfo.rate)
  td.AddRelaPos(self.m_iconBg, ratingIcon, 1, cc.p(0.1, 0.9))
  local nameLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_name")
  nameLabel:setString(heroInfo.name)
  local data = {
    heroInfo.property[td.Property.Atk].value,
    heroInfo.property[td.Property.HP].value,
    heroInfo.property[td.Property.Def].value,
    heroInfo.property[td.Property.Speed].value,
    math.floor(60 / heroInfo.property[td.Property.AtkSp].value),
    string.format("%d%%", heroInfo.property[td.Property.Crit].value)
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
function HeroUnlockDlg:RefreshUI()
  for i, var in ipairs(self.m_changableNodes) do
    var:removeFromParent()
  end
  self.m_changableNodes = {}
  self.m_lackIcon = nil
  local items = self.heroInfo.unlock
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
        self.m_canUnlock = false
        self.m_errorCode = td.ErrorCode.GOLD_NOT_ENOUGH
      end
    else
      numLabel = td.CreateLabel(self.m_udMng:GetItemNum(items[i].itemId) .. "/" .. items[i].num, td.WHITE, 30)
      if self.m_udMng:GetItemNum(items[i].itemId) < items[i].num then
        numLabel:setColor(td.RED)
        self.m_canUnlock = false
        self.m_errorCode = td.ErrorCode.MATERIAL_NOT_ENOUGH
        self.m_lackIcon = itemSprite
      end
    end
    numLabel:setAnchorPoint(0, 0.5)
    td.AddRelaPos(frame, numLabel, 0, cc.p(1.1, 0.5))
    table.insert(self.m_changableNodes, numLabel)
    td.CreateUIEffect(frame, "Spine/UI_effect/UI_kezhitishi_01", {scale = 2})
  end
end
function HeroUnlockDlg:AddTouch()
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
function HeroUnlockDlg:AddBtnEvents()
  td.BtnAddTouch(self.btn_confirm, handler(self, self.OnButtonClicked), nil, td.ButtonEffectType.Long)
  td.BtnAddTouch(self.btn_cancel, handler(self, self.close))
end
function HeroUnlockDlg:OnButtonClicked()
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
function HeroUnlockDlg:OnWealthChanged()
  HeroUnlockDlg.super.OnWealthChanged(self)
  self:RefreshUI()
end
function HeroUnlockDlg:OnItemUpdate()
  HeroUnlockDlg.super.OnItemUpdate(self)
  self:RefreshUI()
end
function HeroUnlockDlg:SendUnlockRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.UnlockHero
  Msg.sendData = {
    hid = self.heroId
  }
  Msg.cbData = {
    hid = self.heroId
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function HeroUnlockDlg:UnlockCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    print("\232\167\163\233\148\129\232\139\177\233\155\132" .. cbData.hid)
    self:PlayUnlockAnim(cbData)
  else
    self.m_canClick = true
  end
end
function HeroUnlockDlg:PlayUnlockAnim(cbData)
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
      UserDataManager:GetInstance():SendGetHeroRequest()
      UserDataManager:GetInstance():SendGetSkillsRequest()
      self:close()
    end)
  }))
  self.m_bg:performWithDelay(function()
    self.m_bg:runAction(cca.fadeOut(0.5, 0))
  end, 0.5)
  G_SoundUtil:PlaySound(69)
end
return HeroUnlockDlg
