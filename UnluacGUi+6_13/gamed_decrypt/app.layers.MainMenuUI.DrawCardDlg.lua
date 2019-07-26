local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local StoreDataManager = require("app.StoreDataManager")
local CommonInfoManager = require("app.info.CommonInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local InformationManager = require("app.layers.InformationManager")
local TabButton = require("app.widgets.TabButton")
local scheduler = require("framework.scheduler")
local DrawCardDlg = class("DrawCardDlg", BaseDlg)
DrawCardDlg.Config = {
  {
    label = "\232\142\183\229\143\150\228\184\128\230\172\161",
    type = 1,
    num = 1
  },
  {
    label = "\232\142\183\229\143\150\229\141\129\230\172\161",
    type = 1,
    num = 10
  },
  {
    label = "\232\142\183\229\143\150\228\184\128\230\172\161",
    type = 2,
    num = 1
  },
  {
    label = "\232\142\183\229\143\150\229\141\129\230\172\161",
    type = 2,
    num = 10
  }
}
function DrawCardDlg:ctor()
  DrawCardDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.DrawCard
  self.m_ifPlayingAnim = false
  self.m_items = {}
  self.m_btnIndex = nil
  self:InitUI()
end
function DrawCardDlg:InitUI()
  self:LoadUI("CCS/DrawCardDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self:SetBg("UI/supply/card_bg.png")
  self:SetTitle(td.Word_Path .. "wenzi_buji.png")
  self.m_backBtn = cc.uiloader:seekNodeByName(self, "Button_back")
  self.m_mainPortal = SkeletonUnit:create("Spine/UI_effect/UI_choujiang_02")
  self.m_mainPortal:setScale(0.5)
  self.m_mainPortal:PlayAni("animation_01", true)
  self.m_mainPortal:pos(568, 700):addTo(self.m_bg)
  local bone = self.m_mainPortal:FindBoneNode("bone_zong")
  self.m_light = SkeletonUnit:create("Spine/UI_effect/UI_choujiang_01")
  self.m_light:setScale(0.75)
  self.m_light:PlayAni("animation_01", true)
  td.AddRelaPos(self.m_mainPortal, self.m_light)
  self.m_leftPedestal = SkeletonUnit:create("Spine/UI_effect/UI_choujiangdizuo_01")
  self.m_leftPedestal:setScale(0.5)
  self.m_leftPedestal:setLocalZOrder(-1)
  self.m_leftPedestal:pos(186, -150):addTo(self.m_bg)
  self.m_rightPedestal = SkeletonUnit:create("Spine/UI_effect/UI_choujiangdizuo_01")
  self.m_rightPedestal:setScaleX(-0.5)
  self.m_rightPedestal:setScaleY(0.5)
  self.m_rightPedestal:setLocalZOrder(-1)
  self.m_rightPedestal:pos(950, -150):addTo(self.m_bg)
  self.m_goldInfo = cc.uiloader:seekNodeByName(self.m_bg, "Text_goldInfo")
  self.m_goldInfo:setString(g_LM:getBy("t00098"))
  self.m_diamondInfo = cc.uiloader:seekNodeByName(self.m_bg, "Text_diamondInfo")
  self.m_diamondInfo:setString(g_LM:getBy("t00099"))
  self.m_whiteScreen = cc.uiloader:seekNodeByName(self.m_bg, "Panel_whiteScreen")
  self.m_whiteScreen:removeFromParent()
  td.AddRelaPos(self, self.m_whiteScreen, 99999999)
  self.m_whiteScreen:setContentSize(display.width, display.height)
  self.m_btns = {}
  for i = 1, 4 do
    local btn = cc.uiloader:seekNodeByName(self.m_bg, "Button_" .. i)
    if i == 1 then
      if StoreDataManager:GetInstance():CheckGoldLottery() then
        btn:getChildByName("Text_price"):setString(g_LM:getBy("a00254"))
      else
        btn:getChildByName("Text_price"):setString(td.GetConst("lottery_normal"))
      end
    elseif i == 2 then
      btn:getChildByName("Text_price"):setString(td.GetConst("lottery_normal") * 9)
    elseif i == 3 then
      if StoreDataManager:GetInstance():CheckDiamondLottery() then
        btn:getChildByName("Text_price"):setString(g_LM:getBy("a00254"))
      else
        btn:getChildByName("Text_price"):setString(td.GetConst("lottery_super"))
      end
    elseif i == 4 then
      btn:getChildByName("Text_price"):setString(td.GetConst("lottery_super") * 9)
    end
    table.insert(self.m_btns, btn)
  end
end
function DrawCardDlg:onEnter()
  DrawCardDlg.super.onEnter(self)
  self:PlayEnterAni(function()
    self:AddEvents()
    self:CheckGuide()
  end)
  self:InitCountDown()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.DrawCard, handler(self, self.DrawCardResponse))
end
function DrawCardDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.DrawCard)
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
  end
  DrawCardDlg.super.onExit(self)
end
function DrawCardDlg:PlayEnterAni(cb)
  self.m_mainPortal:runAction(cca.seq({
    cc.EaseBackOut:create(cca.moveBy(0.3, 0, -270))
  }))
  self.m_leftPedestal:runAction(cca.seq({
    cc.EaseBackOut:create(cca.moveBy(0.3, 0, 237)),
    cca.cb(function()
      self.m_leftPedestal:PlayAni("animation_01", false)
      self.m_leftPedestal:PlayAni("animation_02", true)
      cb()
    end)
  }))
  self.m_rightPedestal:runAction(cca.seq({
    cc.EaseBackOut:create(cca.moveBy(0.3, 0, 237)),
    cca.cb(function()
      self.m_rightPedestal:PlayAni("animation_01", false)
      self.m_rightPedestal:PlayAni("animation_02", true)
    end)
  }))
end
function DrawCardDlg:InitCountDown()
  local serverTime = math.floor(UserDataManager:GetInstance():GetServerTime())
  self.m_goldCD = StoreDataManager:GetInstance():GetFreeLotteryGap(td.LotteryType.GoldOne)
  self.m_diamondCD = StoreDataManager:GetInstance():GetFreeLotteryGap(td.LotteryType.DiamondOne)
  self.m_goldLabel = cc.uiloader:seekNodeByName(self.m_btns[1], "Text_freeNotice")
  self.m_diamondLabel = cc.uiloader:seekNodeByName(self.m_btns[3], "Text_freeNotice")
  self.m_timeScheduler = scheduler.scheduleGlobal(function()
    if StoreDataManager:GetInstance():CheckGoldLottery() then
      self.m_btns[1]:getChildByName("Text_price"):setString(g_LM:getBy("a00254"))
      self.m_goldLabel:setString(" ")
    else
      self.m_btns[1]:getChildByName("Text_price"):setString(tostring(td.GetConst("lottery_normal")))
      self.m_goldCD = cc.clampf(self.m_goldCD - 1, 0, self.m_goldCD)
      local hour, min, sec = math.floor(self.m_goldCD / 3600), math.floor(self.m_goldCD % 3600 / 60), math.floor(self.m_goldCD % 60)
      self.m_goldLabel:setString(g_LM:getBy("a00254") .. string.format(" %02d", hour) .. ":" .. string.format("%02d", min) .. ":" .. string.format("%02d", sec))
    end
    if StoreDataManager:GetInstance():CheckDiamondLottery() then
      self.m_btns[3]:getChildByName("Text_price"):setString(g_LM:getBy("a00254"))
      self.m_diamondLabel:setString(" ")
    else
      self.m_btns[3]:getChildByName("Text_price"):setString(tostring(td.GetConst("lottery_super")))
      self.m_diamondCD = cc.clampf(self.m_diamondCD - 1, 0, self.m_diamondCD)
      local hour, min, sec = math.floor(self.m_diamondCD / 3600), math.floor(self.m_diamondCD % 3600 / 60), math.floor(self.m_diamondCD % 60)
      self.m_diamondLabel:setString(g_LM:getBy("a00254") .. string.format(" %02d", hour) .. ":" .. string.format("%02d", min) .. ":" .. string.format("%02d", sec))
    end
  end, 1)
end
function DrawCardDlg:AddEvents()
  self:AddBtnEvents()
end
function DrawCardDlg:AddBtnEvents()
  for i, val in ipairs(self.m_btns) do
    td.BtnSetTitle(val, DrawCardDlg.Config[i].label, 22, td.WHITE)
    td.BtnAddTouch(val, function()
      td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
      if self:CheckCanDraw(i) then
        local _type, _ifFree = -1, false
        if i == 1 and StoreDataManager:GetInstance():CheckGoldLottery() then
          _type = 1
          _ifFree = true
        end
        if i == 3 and StoreDataManager:GetInstance():CheckDiamondLottery() then
          _type = 3
          _ifFree = true
        end
        self:SendDrawCardRequest(DrawCardDlg.Config[i].type, DrawCardDlg.Config[i].num, {ifFree = _ifFree, type = _type})
        self.m_btnIndex = i
      else
        td.alertErrorMsg(td.ErrorCode.DIAMOND_NOT_ENOUGH)
      end
    end, nil, td.ButtonEffectType.Short)
  end
end
function DrawCardDlg:CheckCanDraw(type)
  if type == 1 then
    if StoreDataManager:GetInstance():CheckGoldLottery() then
      return true
    end
    if UserDataManager:GetInstance():GetDiamond() >= td.GetConst("lottery_normal") then
      return true
    end
  elseif type == 2 then
    if UserDataManager:GetInstance():GetDiamond() >= td.GetConst("lottery_normal") * 10 then
      return true
    end
  elseif type == 3 then
    if StoreDataManager:GetInstance():CheckDiamondLottery() then
      return true
    end
    if UserDataManager:GetInstance():GetDiamond() >= td.GetConst("lottery_super") then
      return true
    end
  elseif UserDataManager:GetInstance():GetDiamond() >= td.GetConst("lottery_super") * 10 then
    return true
  end
  return false
end
function DrawCardDlg:OnBtnClicked(index)
  G_SoundUtil:PlaySound(63)
  self.m_backBtn:setDisable(true)
  for key, val in ipairs(self.m_btns) do
    val:setDisable(true)
  end
  self.m_mainPortal:PlayAni("animation_03", false)
  self.m_mainPortal:registerSpineEventHandler(function(event)
    if event.animation == "animation_03" then
      self.m_light:PlayAni("animation_02", false)
      self.m_light:PlayAni("animation_01", true, true)
    end
  end, sp.EventType.ANIMATION_COMPLETE)
  self.m_mainPortal:PlayAni("animation_02", false, true)
  self.m_mainPortal:PlayAni("animation_01", true, true)
  self.m_btns[index]:performWithDelay(function()
    local particle = ParticleManager:GetInstance():CreateParticle("Effect/baiping_01.plist")
    td.AddRelaPos(self, particle)
    particle:setLocalZOrder(9999999)
    self.m_whiteScreen:runAction(cca.fadeTo(0.6, 1))
  end, 3.5)
  self.m_btns[index]:performWithDelay(function()
    if #self.m_items > 0 then
      self:ShowItems()
    else
      self:RefreshUI()
    end
  end, 4.666666666666667)
end
function DrawCardDlg:SendDrawCardRequest(drawType, drawNum, cbData)
  local Msg = {}
  Msg.msgType = td.RequestID.DrawCard
  Msg.sendData = {type = drawType, num = drawNum}
  Msg.cbData = cbData
  TDHttpRequest:getInstance():Send(Msg)
end
function DrawCardDlg:DrawCardResponse(data, cbData)
  self:OnBtnClicked(self.m_btnIndex)
  self.m_items = {}
  for key, val in ipairs(data.items) do
    local item = {
      itemId = val.item_id,
      num = val.item_num
    }
    table.insert(self.m_items, item)
  end
  if cbData.ifFree == true and cbData.type == 1 then
    local time = UserDataManager:GetInstance():GetServerTime()
    UserDataManager:GetInstance():UpdateGoldDrawTime(time)
    self.m_goldCD = StoreDataManager:GetInstance():GetFreeLotteryGap(td.LotteryType.GoldOne)
    self.m_diamondCD = StoreDataManager:GetInstance():GetFreeLotteryGap(td.LotteryType.DiamondOne)
  end
  if cbData.ifFree == true and cbData.type == 3 then
    local time = UserDataManager:GetInstance():GetServerTime()
    UserDataManager:GetInstance():UpdateDiamondDrawTime(time)
    self.m_goldCD = StoreDataManager:GetInstance():GetFreeLotteryGap(td.LotteryType.GoldOne)
    self.m_diamondCD = StoreDataManager:GetInstance():GetFreeLotteryGap(td.LotteryType.DiamondOne)
  end
end
function DrawCardDlg:RefreshUI()
  self.m_whiteScreen:setOpacity(0)
  self.m_backBtn:setDisable(false)
  for key, val in ipairs(self.m_btns) do
    val:setDisable(false)
  end
  self.m_light:PlayAni("animation_01", true)
  self.m_mainPortal:PlayAni("animation_01", true)
end
function DrawCardDlg:ShowItems()
  self:RefreshUI()
  InformationManager:GetInstance():ShowOpenBox(self.m_items)
end
return DrawCardDlg
