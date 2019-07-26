local GameSceneBase = require("app.scenes.GameSceneBase")
local UserDataManager = require("app.UserDataManager")
local UnitDataManager = require("app.UnitDataManager")
local MissionInfoManager = require("app.info.MissionInfoManager")
local TaskInfoManager = require("app.info.TaskInfoManager")
local CommanderInfoManager = require("app.info.CommanderInfoManager")
local scheduler = require("framework.scheduler")
local GuideManager = require("app.GuideManager")
local TriggerManager = require("app.trigger.TriggerManager")
local InformationManager = require("app.layers.InformationManager")
local RollNumberLabel = require("app.widgets.RollNumberLabel")
local RightButton = require("app.widgets.RightButton")
local NetManager = require("app.net.NetManager")
local GuildDataManager = require("app.GuildDataManager")
local ActivityDataManager = require("app.ActivityDataManager")
local MessageBoxDlg = require("app.layers.MessageBoxDlg")
local MainMenuScene = class("MainMenuScene", GameSceneBase)
local touchHelpTag = 0
local BtmMenuType = {Left = 1, Right = 2}
function MainMenuScene:ctor()
  MainMenuScene.super.ctor(self)
  self.m_uiId = td.UIModule.MainMenu
  self.m_eType = td.SceneType.Main
  self.m_bars_show = true
  self.m_barAnimIsRun = false
  self.m_isScaled = false
  self.m_isPanelBgScaleing = false
  self.m_ScaleX = 0
  self.m_ScaleY = 0
  self.m_iPanelBgMoving = false
  self.m_missionItems = {}
  self.m_showDatas = {}
  self.m_vLockedBtn = {}
  self.m_vBtmMenu = {}
  self.m_vProfitBtns = {}
  self.m_curProfitBtnIndex = 0
  self.m_currTime = 0
  self.m_nextTime = 0
  self.m_nextIndex = 0
  self.m_unstoredCities = {}
  self.m_udMng = UserDataManager:GetInstance()
  self:InitUI()
end
function MainMenuScene:onEnter()
  MainMenuScene.super.onEnter(self)
  self:CreateForgroundMask()
  self:AddListeners()
  G_SoundUtil:PlayMusic(2, true)
  if self.m_eEnterModuleId and GuideManager:GetInstance():IsForceGuideOver() then
    self:didEneter()
    g_MC:OpenModule(self.m_eEnterModuleId)
    self:PlayEnterAnim()
  else
    self:PlayEnterAnim(function()
      self:CheckFirstEnter()
      self:performWithDelay(handler(self, self.didEneter), 0.1)
    end)
  end
end
function MainMenuScene:didEneter()
  g_NetManager:startHeartBeat()
  self:AddBtnEvents()
  self:AddTouch()
  self:CheckAll()
  self.m_vSchedulers = {}
  table.insert(self.m_vSchedulers, scheduler.scheduleGlobal(handler(self, self.UpdateTimer), 60))
  table.insert(self.m_vSchedulers, scheduler.scheduleGlobal(handler(self, self.StoreCoins), 5))
  table.insert(self.m_vSchedulers, scheduler.scheduleGlobal(handler(self, self.WeakGuide), 5))
  self:RemoveForgroundMask()
end
function MainMenuScene:onExit()
  for i, var in ipairs(self.m_vSchedulers) do
    scheduler.unscheduleGlobal(var)
  end
  self.m_vSchedulers = {}
  MainMenuScene.super.onExit(self)
end
function MainMenuScene:InitUI()
  self.m_whRatio = display.width / display.height
  self.m_uiRoot = cc.uiloader:load("CCS/MainMenuUILayer.csb")
  self.m_scale = math.min(display.size.width / 1136, display.size.height / 640)
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_PanelBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  local panel_bg_size = self.m_PanelBg:getContentSize()
  self.m_ScaleX = display.width / panel_bg_size.width
  self.m_ScaleY = self.m_ScaleX
  self.m_PanelBg:setScaleX(self.m_ScaleX)
  self.m_PanelBg:setScaleY(self.m_ScaleY)
  self.m_panelBattleBtns = cc.uiloader:seekNodeByName(self.m_PanelBg, "Panel_battle_buttons")
  self.m_pPanelTop = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_top")
  td.SetAutoScale(self.m_pPanelTop, td.UIPosHorizontal.Center, td.UIPosVertical.Top)
  self.m_pPanelBottom = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bottom")
  td.SetAutoScale(self.m_pPanelBottom, td.UIPosHorizontal.Left, td.UIPosVertical.Bottom)
  self.m_panelBtmBtns = cc.uiloader:seekNodeByName(self.m_pPanelBottom, "Panel_btm_btns")
  self.m_pPanelLeft = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_left")
  td.SetAutoScale(self.m_pPanelLeft, td.UIPosHorizontal.Left, td.UIPosVertical.Center)
  self.m_pPanelRight = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_right")
  td.SetAutoScale(self.m_pPanelRight, td.UIPosHorizontal.Right, td.UIPosVertical.Center)
  self.m_Map = cc.uiloader:seekNodeByName(self.m_PanelBg, "Image_map1")
  self.m_commanderInfo = {}
  self.m_commanderInfo.icon = self.m_pPanelTop:getChildByTag(2):getChildByTag(2)
  self.m_commanderInfo.vip = cc.uiloader:seekNodeByName(self.m_pPanelTop, "Image_vip")
  self.m_commanderInfo.homeName = td.CreateLabel("", td.YELLOW, 22, td.OL_BROWN, 2)
  self.m_commanderInfo.homeName:align(display.LEFT_CENTER, 155, 98):addTo(self.m_pPanelTop:getChildByTag(2))
  local powerLabel = td.CreateLabel(g_LM:getBy("a00032") .. ":", td.LIGHT_BLUE, 20)
  powerLabel:align(display.LEFT_CENTER, 155, 67):addTo(self.m_pPanelTop:getChildByTag(2))
  self.m_commanderInfo.power = td.CreateLabel("", td.LIGHT_BLUE, 20, nil, nil, nil, true)
  self.m_commanderInfo.power:align(display.LEFT_CENTER, 205, 66):addTo(self.m_pPanelTop:getChildByTag(2))
  self.m_commanderInfo.level = td.CreateLabel("", td.LIGHT_BLUE, 20)
  self.m_commanderInfo.level:align(display.LEFT_CENTER, 155, 37):addTo(self.m_pPanelTop:getChildByTag(2))
  self.m_diamondBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_diamond")
  self.m_goldBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_gold")
  self.m_forceBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_force")
  self.m_staminaBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_strength")
  self.m_commanderInfo.stamina = td.CreateLabel("0", td.WHITE, 18)
  self.m_commanderInfo.stamina:align(display.LEFT_CENTER, 48, 20):addTo(self.m_staminaBtn)
  self.m_commanderInfo.force = RollNumberLabel.new({
    num = 0,
    color = td.WHITE,
    size = 18
  })
  self.m_commanderInfo.force:align(display.LEFT_CENTER, 48, 20):addTo(self.m_forceBtn)
  self.m_commanderInfo.gold = RollNumberLabel.new({
    num = 0,
    color = td.WHITE,
    size = 18
  })
  self.m_commanderInfo.gold:align(display.LEFT_CENTER, 48, 20):addTo(self.m_goldBtn)
  self.m_commanderInfo.diamond = RollNumberLabel.new({
    num = 0,
    color = td.WHITE,
    size = 18
  })
  self.m_commanderInfo.diamond:align(display.LEFT_CENTER, 48, 20):addTo(self.m_diamondBtn)
  local cityInfoBg = require("app.widgets.IncomeButton").new()
  cityInfoBg:setAnchorPoint(0, 0)
  local cityInfoNode = cc.uiloader:seekNodeByName(self.m_pPanelLeft, "Node_cityBg")
  cityInfoBg:pos(cityInfoNode:getPosition()):addTo(self.m_pPanelLeft)
  local cityLabel = td.CreateLabel(string.format(g_LM:getBy("a00017") .. ":%d/32", MissionInfoManager:GetInstance():GetCityNumByState(td.MissionState.Occupieded)))
  cityLabel:align(display.LEFT_CENTER, 45, 18):addTo(cityInfoBg)
  self.m_chatDlg = require("app.layers.chat.ChatDlg").new(3)
  self:addChild(self.m_chatDlg, 500)
  self:InitBtns()
  self:UpdateCommanderInfo()
  self:UpdateTask()
  self:InitMissionsBtn()
  self:InitProfitsBar()
  self:AddUIEffect()
  self:PrepareEnterAnim()
end
function MainMenuScene:PrepareEnterAnim()
  self.m_Map:setScale(1.8)
  self.m_pPanelTop:setPositionY(200)
  self.m_pPanelRight:setPositionX(200)
  self.m_panelBtmBtns:setOpacity(0)
end
function MainMenuScene:PlayEnterAnim(cb)
  self.m_Map:runAction(cca.seq({
    cca.delay(0.2),
    cca.scaleTo(0.2, 1)
  }))
  local x, y = self:SetAutoScale(nil, td.UIPosHorizontal.Center, td.UIPosVertical.Top)
  self.m_pPanelTop:runAction(cca.seq({
    cca.delay(0.4),
    cca.moveTo(0.1, x, y - 30),
    cc.EaseBounceOut:create(cca.moveTo(0.6, x, y))
  }))
  local x, y = self:SetAutoScale(nil, td.UIPosHorizontal.Right, td.UIPosVertical.Center)
  self.m_pPanelRight:runAction(cca.seq({
    cca.delay(0.5),
    cc.EaseBackOut:create(cca.moveTo(0.3, x, y))
  }))
  local x, y = self:SetAutoScale(nil, td.UIPosHorizontal.Center, td.UIPosVertical.Bottom)
  self.m_panelBtmBtns:runAction(cca.seq({
    cca.delay(0.6),
    cca.fadeIn(0.5, 1),
    cca.cb(cb)
  }))
end
function MainMenuScene:InitBtns()
  local infos = {
    {
      index = 1,
      id = td.UIModule.BaseCamp
    },
    {
      index = 2,
      id = td.UIModule.Hero
    },
    {
      index = 3,
      id = td.UIModule.Camp
    },
    {
      index = 4,
      id = td.UIModule.Task
    },
    {
      index = 5,
      id = td.UIModule.Guild
    },
    {
      index = 6,
      id = td.UIModule.Friend
    },
    {
      index = 7,
      id = td.UIModule.Pokedex
    },
    {
      index = 8,
      id = td.UIModule.Rank
    }
  }
  for i, v in ipairs(infos) do
    local btn
    if g_MC:IsModuleUnlock(v.id) then
      btn = ccui.Button:create(td.Word_Path .. v.index .. "-1.png", td.Word_Path .. v.index .. "-2.png")
    else
      btn = ccui.Button:create(td.Word_Path .. v.index .. "-3.png", td.Word_Path .. v.index .. "-3.png")
      btn.isBottom = true
      self.m_vLockedBtn[v.id] = btn
    end
    btn:setTag(v.index)
    btn:pos(280 + i * 100, 50):addTo(self.m_panelBtmBtns)
    table.insert(self.m_vBtmMenu, btn)
  end
  self.m_vRightMenu = {}
  local vBtnEffect = {
    "UI_chuzhenganniu_01",
    "UI_chuzhenganniu_02",
    "UI_chuzhenganniu_03",
    "UI_chuzhenganniu_04"
  }
  for i = 1, 4 do
    do
      local btn = cc.uiloader:seekNodeByName(self.m_pPanelRight, "Node_" .. i)
      local rightBtn
      if i == 2 and not g_MC:IsModuleUnlock(td.UIModule.Dungeon) then
        rightBtn = RightButton.new("Spine/UI_effect/UI_chuzhenganniu_06", function()
          self:RightBtnClicked(i)
        end)
        rightBtn.isRight = true
        self.m_vLockedBtn[td.UIModule.Dungeon] = rightBtn
      else
        rightBtn = RightButton.new("Spine/UI_effect/" .. vBtnEffect[i], function()
          self:RightBtnClicked(i)
        end)
      end
      rightBtn:setPosition(btn:getPosition())
      rightBtn:setName("Button_right" .. i)
      btn:getParent():addChild(rightBtn)
      btn:removeFromParent()
      table.insert(self.m_vRightMenu, rightBtn)
    end
  end
  self.m_headBtn = cc.uiloader:seekNodeByName(self.m_pPanelTop, "Button_head")
  self.m_pArenaBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_arena")
  self.m_mailBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_mailbox")
  self.m_pActivityBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_activity")
  self.m_pChargeBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_charge")
  self.m_pNewSignInBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_signin")
  self.m_pRobLogBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_roblog")
  self.m_pRobLogBtn:setVisible(false)
  local giftPackBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_gift")
  self.m_pGiftPackBtn = require("app.widgets.GiftPackButton").new()
  self.m_pGiftPackBtn:pos(giftPackBtn:getPosition()):addTo(giftPackBtn:getParent())
  giftPackBtn:removeFromParent()
  self:UpdateLeftBtns()
end
function MainMenuScene:UpdateLeftBtns()
  local bGuideOver = GuideManager:GetInstance():IsForceGuideOver()
  self.m_pActivityBtn:setVisible(bGuideOver)
  if bGuideOver then
    if self.m_udMng:DidGetFirstChargeGift() then
      self.m_pChargeBtn:setVisible(false)
      self.m_pNewSignInBtn:setPosition(self.m_pChargeBtn:getPosition())
    else
      self.m_pChargeBtn:setVisible(true)
    end
    self.m_pNewSignInBtn:setVisible(self.m_udMng:GetSignInDay() < 7)
    if ActivityDataManager:GetInstance():GetSoldierBagActivityData() then
      self.m_pGiftPackBtn:setVisible(true)
    else
      self.m_pGiftPackBtn:setVisible(false)
    end
  else
    self.m_pChargeBtn:setVisible(false)
    self.m_pNewSignInBtn:setVisible(false)
    self.m_pGiftPackBtn:setVisible(false)
  end
end
function MainMenuScene:InitProfitsBar()
  local ProfitIds = {20001, 20132}
  for i, id in ipairs(ProfitIds) do
    local btn = require("app.widgets.ProfitBar").new(i, self)
    btn:setName("Bar" .. i)
    local nodeBar = cc.uiloader:seekNodeByName(self.m_pPanelLeft, "Node_bar" .. i)
    btn:setAnchorPoint(0, 0.5)
    btn:setPosition(nodeBar:getPosition())
    btn:addTo(self.m_pPanelLeft)
    self.m_vProfitBtns[i] = btn
    self.m_vProfitBtns[i]:Update()
  end
end
function MainMenuScene:UpdateProfitsBar()
  for i, var in ipairs(self.m_vProfitBtns) do
    var:Update()
  end
end
function MainMenuScene:AddUIEffect()
  local nodeNames = {
    "icon_strength",
    "icon_gold",
    "icon_diamond"
  }
  local files = {
    "Spine/UI_effect/UI_zuanshishanguang_01",
    "Spine/UI_effect/UI_jinbishanguang_01",
    "Spine/UI_effect/UI_zuanshishanguang_01"
  }
  for i, var in ipairs(nodeNames) do
    local tmpIcon = cc.uiloader:seekNodeByName(self.m_uiRoot, var)
    td.CreateUIEffect(tmpIcon, files[i], {scale = 0.55, random = true})
  end
  local infos = {
    {
      index = 1,
      id = td.UIModule.PVP,
      nodeName = "Button_arena"
    }
  }
  for i, info in ipairs(infos) do
    local btn = cc.uiloader:seekNodeByName(self.m_uiRoot, info.nodeName)
    if g_MC:IsModuleUnlock(info.id) then
      td.CreateUIEffect(btn, "Spine/UI_effect/UI_jinjichang_01", {scale = 0.6, loop = true})
    else
      local lockSpr = display.newSprite("UI/mainmenu_new/locked_entry.png")
      lockSpr:setName("lock")
      lockSpr:setScale(0.8)
      td.AddRelaPos(btn, lockSpr)
      self.m_vLockedBtn[info.id] = btn
    end
  end
end
function MainMenuScene:SetAutoScale(root, uiPosHorizontal, uiPosVertical)
  self.m_scale = td.GetAutoScale()
  if root then
    root:setScale(self.m_scale * root:getScale())
  end
  local x, y
  if uiPosHorizontal == td.UIPosHorizontal.Left then
    x = 0
  elseif uiPosHorizontal == td.UIPosHorizontal.Right then
    x = display.size.width - 1136 * self.m_scale
  else
    x = (display.size.width - 1136 * self.m_scale) / 2
  end
  local displayHeight = display.size.height
  if uiPosVertical == td.UIPosVertical.Top then
    y = displayHeight - 640 * self.m_scale
  elseif uiPosVertical == td.UIPosVertical.Bottom then
    y = 0
  else
    y = (displayHeight - 640 * self.m_scale) / 2
  end
  if root then
    root:setPositionX(x)
    root:setPositionY(y)
  end
  return x, y
end
function MainMenuScene:UpdateTimer()
  self:UpdateProfitsBar()
  self:CheckActivities()
  self:CheckGuildActivities()
end
function MainMenuScene:WeakGuide()
  if not GuideManager:GetInstance():IsForceGuideOver() then
    return
  end
  if GuideManager:GetInstance():IsGuiding() then
    return
  end
  if not g_MC:IsAllModuleClose() then
    return
  end
  local nowTime = self.m_udMng:GetServerTime()
  local weakGuideGroups = {
    51,
    52,
    53,
    53
  }
  if nowTime - g_MC:GetOpTime() > 10 then
    local randomNum = math.random(#weakGuideGroups)
    require("app.GuideManager").H_StartGuideGroup(weakGuideGroups[randomNum], 1)
  end
end
function MainMenuScene:IsTouchInTaskUI(touch)
  if self.m_pTaskBar then
    local nodePos = self.m_pTaskBar:convertToNodeSpace(touch:getLocation())
    if isTouchInNode(self.m_pTaskBar, nodePos) then
      self.m_pTaskBar:OnClicked()
      return true
    end
  end
  return false
end
function MainMenuScene:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(false)
  self.m_listener = listener
  listener:registerScriptHandler(function(touch, event)
    if self.m_isPanelBgScaleing then
      return false
    end
    if self:IsTouchInTaskUI(touch) then
      return true
    end
    local nodePos = touch:getLocation()
    nodePos = cc.p(self.m_commanderInfo.icon:convertToNodeSpace(nodePos))
    if isTouchInNode(self.m_commanderInfo.icon, nodePos) then
      return true
    end
    nodePos = touch:getLocation()
    nodePos = cc.p(self.m_PanelBg:convertToNodeSpace(nodePos))
    if isTouchInNode(self.m_PanelBg, nodePos) and not self:CheckTouchInTouchableChild(touch) and not self:IsTouchInMissionItems(touch) then
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if not GuideManager:GetInstance():IsForceGuideOver() then
      return
    end
    local newPos = cc.p(touch:getLocation())
    local prePos = cc.p(touch:getPreviousLocation())
    if cc.pGetDistance(newPos, prePos) > 5 then
      self.m_iPanelBgMoving = true
    end
    self:PanelScroll(touch)
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    g_MC:UpdateOpTime()
    local nodePos = touch:getLocation()
    nodePos = cc.p(self.m_commanderInfo.icon:convertToNodeSpace(nodePos))
    nodePos = touch:getLocation()
    nodePos = cc.p(self.m_PanelBg:convertToNodeSpace(nodePos))
    if isTouchInNode(self.m_PanelBg, nodePos) then
      if not self.m_iPanelBgMoving then
        td.CreateUIEffect(self, "Spine/UI_effect/UI_dianjiguang_01", {
          pos = touch:getLocation()
        })
      end
      self.m_iPanelBgMoving = false
      return
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self.m_pPanelRight)
end
function MainMenuScene:AddListeners()
  self:AddCustomEvent(td.USERWEALTH_CHANGED, handler(self, self.UpdateCommanderInfo))
  self:AddCustomEvent(td.TOTAL_POWER_CHANGE, handler(self, self.UpdateCommanderInfo))
  self:AddCustomEvent(td.HEART_BEAT, handler(self, self.HeartBeatCallback))
  self:AddCustomEvent(td.OPEN_CHAT, handler(self, self.ShowChatDlg))
  self:AddCustomEvent(td.MODIFY_PORTRAIT, handler(self, self.ModifyPortrait))
  self:AddCustomEvent(td.UPDATE_PROFIT, handler(self, self.UpdateProfitsBar))
  self:AddCustomEvent(td.TASK_UPDATE, handler(self, self.UpdateTask))
  self:AddCustomEvent(td.UPDATE_NAME, handler(self, self.OnNameUpdate))
  self:AddCustomEvent(td.CHECK_FIRST_ENTER, handler(self, self.CheckFirstEnter))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  self:AddCustomEvent(td.ON_All_DLG_CLOSE, function()
    if GuideManager:GetInstance():IsForceGuideOver() then
      self:CheckSignIn()
    end
    self:CheckGuide()
  end)
  self:AddCustomEvent(td.CHECK_UNLOCK, handler(self, self.CheckUnlock))
  self:AddCustomEvent(td.FORCE_GUIDE_OVER, function()
    self:CheckAll()
  end)
  self:AddCustomEvent(td.TOTAL_CHARGE_CHANGE, function()
    self.m_commanderInfo.vip:loadTexture(td.GetVIPIcon(self.m_udMng:GetVipLevel()))
    self:UpdateLeftBtns()
    self:UpdateProfitsBar()
  end)
  self:AddCustomEvent(td.CLOSE_GIFT_PACK, function()
    self.m_pGiftPackBtn:setVisible(false)
  end)
  if device.platform == "android" then
    self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
      if event.key == "back" then
        pu.ShowExitDlg()
      end
    end)
    self:setKeypadEnabled(true)
  end
end
function MainMenuScene:AddBtnEvents()
  td.BtnAddTouch(self.m_staminaBtn, function()
    g_MC:OpenModule(td.UIModule.BuyStamina)
  end)
  td.BtnAddTouch(self.m_goldBtn, function()
    g_MC:OpenModule(td.UIModule.BuyGold)
  end)
  td.BtnAddTouch(self.m_forceBtn, function()
    g_MC:OpenModule(td.UIModule.BuyForce)
  end)
  td.BtnAddTouch(self.m_diamondBtn, function()
    g_MC:OpenModule(td.UIModule.Topup)
  end)
  td.BtnAddTouch(self.m_headBtn, function()
    g_MC:OpenModule(td.UIModule.PlayerInfo)
  end)
  self.m_mailBtn:setPressedActionEnabled(true)
  td.BtnAddTouch(self.m_mailBtn, function()
    g_MC:OpenModule(td.UIModule.Mail)
  end)
  self:AddTitleInBtn(self.m_pArenaBtn, g_LM:getBy("a00119"))
  td.BtnAddTouch(self.m_pArenaBtn, function()
    g_MC:OpenModule(td.UIModule.PVP)
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  end)
  self.m_pActivityBtn:setPressedActionEnabled(true)
  td.BtnAddTouch(self.m_pActivityBtn, function()
    local spine = self.m_pActivityBtn:getChildByName("spine")
    if spine then
      spine:removeFromParent()
    end
    g_MC:OpenModule(td.UIModule.Activity)
  end)
  self.m_pChargeBtn:setPressedActionEnabled(true)
  td.BtnAddTouch(self.m_pChargeBtn, function()
    local pDlg = require("app.layers.MainMenuUI.FirstChargeDlg").new()
    td.popView(pDlg)
  end)
  self.m_pNewSignInBtn:setPressedActionEnabled(true)
  td.BtnAddTouch(self.m_pNewSignInBtn, function()
    g_MC:OpenModule(td.UIModule.NewSignIn)
  end)
  self.m_pGiftPackBtn:setPressedActionEnabled(true)
  td.BtnAddTouch(self.m_pGiftPackBtn, function()
    local pDlg = require("app.layers.MainMenuUI.SoldierRewardBagDlg").new()
    td.popView(pDlg)
  end)
  self.m_pRobLogBtn:setPressedActionEnabled(true)
  td.BtnAddTouch(self.m_pRobLogBtn, function()
    self.m_pRobLogBtn:setVisible(false)
    local infoMng = InformationManager:GetInstance()
    for i, msg in ipairs(self.m_hbMsgs) do
      infoMng:ShowBeRobed(msg)
    end
    self.m_hbMsgs = {}
  end)
  for i, btn in ipairs(self.m_vBtmMenu) do
    td.BtnAddTouch(btn, function()
      self:BottomBtnClicked(i, btn)
    end)
  end
end
function MainMenuScene:PanelScroll(touch)
  if not self.m_isScaled then
    return
  end
  local newPos = cc.p(touch:getLocation())
  local prePos = cc.p(touch:getPreviousLocation())
  local posNormal = cc.pSub(newPos, prePos)
  local pos = cc.p(self.m_PanelBg:getPosition())
  self.m_PanelBg:setPosition(cc.pAdd(pos, posNormal))
  self:PanelScrollBoundCheck()
end
function MainMenuScene:PanelScrollBoundCheck()
  local pos = cc.p(self.m_PanelBg:getPosition())
  local ancPos = cc.p(self.m_PanelBg:getAnchorPoint())
  local ancInPos = cc.p(self.m_PanelBg:getAnchorPointInPoints())
  local scaleX = self.m_PanelBg:getScaleX()
  local scaleY = self.m_PanelBg:getScaleY()
  local newPos = cc.p(pos.x, pos.y)
  local bgSize = self.m_PanelBg:getBoundingBox()
  ancInPos.x = ancInPos.x * scaleX
  ancInPos.y = ancInPos.y * scaleY
  local posNew = cc.pSub(pos, ancInPos)
  if posNew.x > 0 then
    newPos.x = 0 + ancInPos.x
  elseif posNew.x + bgSize.width < display.width then
    newPos.x = display.width - bgSize.width + ancInPos.x
  end
  if posNew.y > 0 then
    newPos.y = 0 + ancInPos.y
  elseif posNew.y + bgSize.height < display.height then
    newPos.y = display.height - bgSize.height + ancInPos.y
  end
  self.m_PanelBg:setPosition(newPos)
end
function MainMenuScene:BottomBtnClicked(tag, sender)
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  td.ShowRP(sender, false)
  if tag == 1 then
    g_MC:OpenModule(td.UIModule.BaseCamp)
  elseif tag == 2 then
    g_MC:OpenModule(td.UIModule.Hero)
  elseif tag == 3 then
    g_MC:OpenModule(td.UIModule.Camp)
  elseif tag == 4 then
    g_MC:OpenModule(td.UIModule.Task)
  elseif tag == 5 then
    g_MC:OpenModule(td.UIModule.Guild)
  elseif tag == 6 then
    g_MC:OpenModule(td.UIModule.Friend)
  elseif tag == 7 then
    g_MC:OpenModule(td.UIModule.Pokedex)
  elseif tag == 8 then
    g_MC:OpenModule(td.UIModule.Rank)
  end
end
function MainMenuScene:RightBtnClicked(index)
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  td.ShowRP(self.m_vRightMenu[index], false)
  if index == 1 then
    g_MC:OpenModule(td.UIModule.Mission)
  elseif index == 2 then
    g_MC:OpenModule(td.UIModule.Dungeon)
  elseif index == 3 then
    g_MC:OpenModule(td.UIModule.Pack)
  elseif index == 4 then
    g_MC:OpenModule(td.UIModule.Supply)
    self.m_udMng:GetStoreManager():UpdateOpenStoreDate()
  end
end
function MainMenuScene:UpdateCommanderInfo()
  if self.m_commanderInfo then
    self.m_commanderInfo.power:setString(self.m_udMng:GetTotalPower())
    self.m_commanderInfo.level:setString("LV." .. self.m_udMng:GetBaseCampLevel())
    local nickName = self.m_udMng:GetNickname()
    self.m_commanderInfo.homeName:setString(nickName)
    self.m_commanderInfo.stamina:setString(string.format("%d/%d", self.m_udMng:GetItemNum(td.ItemID_Stamina), self.m_udMng:GetMaxStamina()))
    self.m_commanderInfo.force:SetNumber(self.m_udMng:GetItemNum(td.ItemID_Force))
    self.m_commanderInfo.gold:SetNumber(self.m_udMng:GetItemNum(td.ItemID_Gold))
    self.m_commanderInfo.diamond:SetNumber(self.m_udMng:GetItemNum(td.ItemID_Diamond))
    local portraitInfo = CommanderInfoManager:GetInstance():GetPortraitInfo(self.m_udMng:GetPortrait())
    self.m_commanderInfo.icon:loadTexture(portraitInfo.file .. td.PNG_Suffix)
    self.m_commanderInfo.vip:loadTexture(td.GetVIPIcon(self.m_udMng:GetVipLevel()))
    self:CheckBase()
  end
end
function MainMenuScene:UpdateTask()
  local taskDatas = self.m_udMng:GetTaskData()
  local mainTaskId
  for i, task in ipairs(taskDatas[td.TaskType.MainLine]) do
    if task.state ~= td.TaskState.Received then
      local taskInfo = TaskInfoManager:GetInstance():GetTaskInfo(task.tid)
      if taskInfo then
        mainTaskId = taskInfo.id
        break
      end
      dump(task)
      td.alertDebug("MainMenuScene:UpdateTask, task Id error:" .. task.tid)
      break
    end
  end
  if mainTaskId == nil then
    if self.m_pTaskBar then
      self.m_pTaskBar:removeFromParent()
      self.m_pTaskBar = nil
    end
  else
    if not self.m_pTaskBar then
      local taskBarNode = cc.uiloader:seekNodeByName(self.m_uiRoot, "Node_taskBg")
      self.m_pTaskBar = require("app.widgets.TaskBar").new()
      self.m_pTaskBar:setName("TaskBar")
      self.m_pTaskBar:align(display.LEFT_CENTER, taskBarNode:getPosition()):addTo(self.m_pPanelTop)
    end
    self.m_pTaskBar:SetData(mainTaskId)
  end
  self:CheckTask()
end
function MainMenuScene:HeartBeatCallback(event)
  local data = string.toTable(event:getDataString())
  if data.type == td.HBType.Occupying then
    for i, id in ipairs(data.items) do
      self.m_udMng:UpdateCityState({
        missionId = tonumber(id),
        occupation = td.OccupState.Occupieding
      })
      local missionId = math.floor(tonumber(id) % 1000)
      local missionItem = self.m_PanelBg:getChildByName("mi" .. missionId)
      if not missionItem then
        td.alertDebug(string.format("\229\143\141\230\148\187\229\191\131\232\183\179\233\148\153\232\175\175\239\188\140id=%d", tonumber(id)))
      else
        missionItem:CheckState()
      end
    end
    local text = g_LM:getBy("a00199")
    local button1 = {
      text = g_LM:getBy("a00009"),
      bIsClose = true
    }
    local messageBoxDlg = MessageBoxDlg.new({
      size = cc.size(454, 300),
      content = text,
      noModal = true,
      buttons = {button1}
    })
    messageBoxDlg:Show()
  elseif data.type == td.HBType.Occupyed then
    for i, id in ipairs(data.items) do
      self.m_udMng:UpdateCityState({
        missionId = tonumber(id),
        occupation = td.OccupState.Occupieded
      })
      local missionId = math.floor(tonumber(id) % 1000)
      local missionItem = self.m_PanelBg:getChildByName("mi" .. missionId)
      if not missionItem then
        td.alertDebug(string.format("\229\143\141\230\148\187\229\191\131\232\183\179\233\148\153\232\175\175\239\188\140id=%d", tonumber(id)))
      else
        missionItem:CheckState()
      end
    end
  elseif data.type == td.HBType.Task then
    local tmp = string.split(data.num, "|")
    local vType = {}
    for i, var in ipairs(tmp) do
      vType[tonumber(var)] = 1
    end
    for key, var in pairs(vType) do
      self.m_udMng:SendTaskRequest(key)
    end
    self:CheckTask()
  elseif data.type == td.HBType.BeRobed then
    if data.num then
      self:HeartBeatRob(data.num)
    end
  else
    if data.type == td.HBType.Chat then
      self.m_chatDlg:SetChannelUpdate(tonumber(data.num))
    elseif data.type == td.HBType.Assisted then
      for i, var in ipairs(data.items) do
        local tmp = string.split(var, "#")
        self.m_udMng:UpdateAssist(tmp[1], tonumber(tmp[2]))
      end
      td.dispatchEvent(td.UPDATE_ASSIST)
    end
    self:ShowRedPoint(data.type)
  end
end
function MainMenuScene:ShowRedPoint(_type)
  local moduleId, btn, rp
  local relaPos = cc.p(0.95, 0.95)
  if _type == td.HBType.Mail then
    moduleId = td.UIModule.Mail
    btn = self.m_mailBtn
    g_MC:SetModuleUpdate(td.UIModule.Mail, true)
  elseif _type == td.HBType.Chat then
    moduleId = td.UIModule.Chat
    btn = self.m_chatDlg:GetBg()
    rp = SkeletonUnit:create("Spine/UI_effect/UI_kezhitishi_01")
    rp:PlayAni("animation", true)
    relaPos = cc.p(0.5, 0.5)
  elseif _type == td.HBType.Friend then
    moduleId = td.UIModule.Friend
    btn = self.m_vBtmMenu[6]
    self.m_udMng:SendFriendRequest(td.FriendType.Mine)
  elseif _type == td.HBType.Assist then
    if g_MC:IsModuleUnlock(td.UIModule.FriendAssist) then
      moduleId = td.UIModule.Friend
      btn = self.m_vBtmMenu[6]
      self.m_udMng:SendFriendRequest(td.FriendType.Mine)
    end
  elseif _type == td.HBType.Assisted then
    moduleId = td.UIModule.Friend
    btn = self.m_vBtmMenu[6]
  elseif _type == td.HBType.Achieve then
    moduleId = td.UIModule.Achievement
    btn = self.m_headBtn
  elseif _type == td.HBType.Backpack then
    moduleId = td.UIModule.Pack
    btn = self.m_vRightMenu[3]
    relaPos = cc.p(0.7, 0.7)
  elseif table.indexof({
    td.HBType.Kick,
    td.HBType.Promote,
    td.HBType.Reject,
    td.HBType.Recruit,
    td.HBType.Apply,
    td.HBType.Quit
  }, _type) then
    btn = self.m_vBtmMenu[5]
  end
  if btn and not g_MC:IsModuleShowing(moduleId) then
    td.ShowRP(btn, true, relaPos, rp)
  end
end
function MainMenuScene:HeartBeatRob(data)
  local tmp = string.split(data, "|")
  self.m_hbMsgs = self.m_hbMsgs or {}
  local tmpMsgs = {}
  for i, var in ipairs(tmp) do
    local tmp1 = string.split(var, ",")
    local msg = {}
    if #tmp1 == 2 then
      msg.type = 0
      msg.name = tmp1[1]
      msg.itemId = tonumber(tmp1[2])
      table.insert(tmpMsgs, msg)
    elseif #tmp1 > 2 then
      msg.type = 1
      msg.name = tmp1[1]
      msg.itemId = tonumber(tmp1[2])
      msg.count = tonumber(tmp1[3])
      msg.report = tmp1[4]
      msg.already = false
      for j, preMsg in ipairs(tmpMsgs) do
        if preMsg.type == 0 and preMsg.name == msg.name then
          msg.already = true
          table.remove(tmpMsgs, j)
          break
        end
      end
      table.insert(self.m_hbMsgs, msg)
    end
  end
  if #self.m_hbMsgs > 0 then
    self.m_pRobLogBtn:setVisible(true)
  end
  local infoMng = InformationManager:GetInstance()
  for i, msg in ipairs(tmpMsgs) do
    infoMng:ShowBeRobed(msg)
  end
end
function MainMenuScene:ShowChatDlg(event)
  self.m_chatDlg:showOrHideDlg()
  if event then
    local eventData = string.toTable(event:getDataString())
    local msgData = {
      uid = eventData.uid,
      uname = eventData.uname,
      reputation = eventData.reputation
    }
    self.m_chatDlg:OpenPrivateChat(msgData)
  end
end
function MainMenuScene:ModifyPortrait(event)
  local id = tonumber(event:getDataString())
  local portraitInfo = CommanderInfoManager:GetInstance():GetPortraitInfo(id)
  self.m_commanderInfo.icon:loadTexture(portraitInfo.file .. td.PNG_Suffix)
end
function MainMenuScene:loadAnim()
  local timeLine = cc.CSLoader:createTimeline("CCS/MainMenuUILayer.csb")
  self.m_uiRoot:runAction(timeLine)
  timeLine:gotoFrameAndPlay(0, 20, false)
end
function MainMenuScene:InitMissionsBtn()
  if self.m_missionItems and #self.m_missionItems > 0 then
    for _, value in ipairs(self.m_missionItems) do
      value:removeFromParent()
    end
  end
  self.m_missionItems = {}
  self:initMap()
end
function MainMenuScene:initMap()
  self.m_showDatas = self.m_udMng:GetAllCitiesData()
  local configData = require("app.config.mission_pos_config")
  for missionId, pos in pairs(configData) do
    if self.m_showDatas[missionId] ~= nil then
      local missionItem = require("app.widgets.MissionItemUI"):new()
      if missionItem then
        missionItem:initMissonItem(self.m_showDatas[missionId], handler(self, self.missionClickCallback), pos[3])
        self.m_PanelBg:addChild(missionItem)
        missionItem:setPosition(cc.p(pos[1], pos[2]))
        missionItem:setLocalZOrder(5000 - pos[2])
        missionItem:setName("mi" .. missionId % 1000)
        table.insert(self.m_missionItems, missionItem)
      end
    end
  end
end
function MainMenuScene:StoreCoins()
  if not self.m_missionItems or #self.m_missionItems == 0 then
    return
  end
  if #self.m_unstoredCities == 0 then
    self.m_unstoredCities = clone(self.m_missionItems)
  end
  if self.m_nextTime == 0 then
    self.m_nextTime = math.random(2, 3)
    self.m_nextIndex = math.random(1, #self.m_unstoredCities)
  end
  if self.m_currTime == self.m_nextTime then
    self.m_currTime = 0
    do
      local iconFile = td.GetItemIcon(td.ItemID_Gold)
      local destNodeName = "Node_bar1"
      local randNum = math.random(10)
      if randNum <= 5 then
        iconFile = td.GetItemIcon(td.ItemID_Force)
        destNodeName = "Node_bar2"
      end
      local coin = display.newSprite(iconFile)
      local coinPos = cc.p(self.m_unstoredCities[self.m_nextIndex]:getPositionX(), self.m_unstoredCities[self.m_nextIndex]:getPositionY())
      coinPos = self.m_PanelBg:convertToWorldSpace(coinPos)
      coin:setScale(0.1)
      coin:pos(coinPos.x, coinPos.y):addTo(self.m_uiRoot)
      coin:setLocalZOrder(td.ZORDER.Min)
      local coinParticle = ParticleManager:GetInstance():CreateParticle("Effect/shouji.plist")
      td.AddRelaPos(coin, coinParticle, -1)
      local goldBar = cc.uiloader:seekNodeByName(self.m_pPanelLeft, destNodeName)
      local destPos = cc.p(goldBar:getPositionX() + 20, goldBar:getPositionY())
      destPos = self.m_pPanelLeft:convertToWorldSpace(destPos)
      local bezierConfig = {}
      if coinPos.y > destPos.y then
        bezierConfig = {
          cc.p((coinPos.x - destPos.x) * 9 / 11 + destPos.x, coinPos.y / 6 + coinPos.y),
          cc.p((coinPos.x - destPos.x) * 6 / 11 + destPos.x, coinPos.y / 3 + coinPos.y),
          cc.p(destPos.x, destPos.y)
        }
      else
        bezierConfig = {
          cc.p((coinPos.x - destPos.x) * 9 / 11 + destPos.x, destPos.y / 6 + destPos.y),
          cc.p((coinPos.x - destPos.x) * 6 / 11 + destPos.x, destPos.y / 3 + destPos.y),
          cc.p(destPos.x, destPos.y)
        }
      end
      coin:runAction(cca.seq({
        cca.spawn({
          cc.EaseBackOut:create(cca.moveTo(0.8, coinPos.x, coinPos.y + 40)),
          cc.EaseBounceOut:create(cca.scaleTo(0.5, 0.3 * self.m_scale, 0.3 * self.m_scale))
        }),
        cca.delay(0.1),
        cc.BezierTo:create(1, bezierConfig),
        cca.cb(function()
          coin:removeFromParent()
          local storedEffect = SkeletonUnit:create("Spine/UI_effect/EFT_shoujiguang_01")
          storedEffect:setScale(0.5 * self.m_scale, 0.5 * self.m_scale)
          storedEffect:pos(destPos.x, destPos.y):addTo(self.m_uiRoot)
          storedEffect:registerSpineEventHandler(function(event)
            self.m_uiRoot:performWithDelay(function()
              storedEffect:removeFromParent()
            end, 0.05)
          end, sp.EventType.ANIMATION_COMPLETE)
          storedEffect:PlayAni("animation", false)
        end)
      }))
      table.remove(self.m_unstoredCities, self.m_nextIndex)
      self.m_nextTime = math.random(2, 3)
      if #self.m_unstoredCities == 0 then
        self.m_unstoredCities = clone(self.m_missionItems)
      end
      self.m_nextIndex = math.random(1, #self.m_unstoredCities)
    end
  end
  self.m_currTime = self.m_currTime + 1
end
function MainMenuScene:missionClickCallback(sender, eventType)
  if eventType == ccui.TouchEventType.began then
    touchHelpTag = 1
  elseif eventType == ccui.TouchEventType.moved then
    touchHelpTag = touchHelpTag + 1
  elseif eventType == ccui.TouchEventType.ended and touchHelpTag < 5 then
    if not self.m_isScaled then
      return false
    end
    local missionId = sender:getTag()
    local missionData
    for k, value in pairs(self.m_showDatas) do
      if k == missionId then
        missionData = value
        break
      end
    end
    if missionData.state == td.MissionState.Locked then
      td.alertErrorMsg(td.ErrorCode.MISSION_LOCKED)
    else
      td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
      local detailUI = g_MC:OpenModule(td.UIModule.Mission)
      detailUI:SetMissionData(missionData)
    end
    touchHelpTag = 0
  end
end
function MainMenuScene:setMenuBarVisible(visible)
  if self.m_pPanelBottom.m_locPos == nil then
    self.m_pPanelBottom.m_locPos = cc.p(self.m_pPanelBottom:getPosition())
    self.m_pPanelTop.m_locPos = cc.p(self.m_pPanelTop:getPosition())
    self.m_pPanelRight.m_locPos = cc.p(self.m_pPanelRight:getPosition())
    self.m_pPanelLeft.m_locPos = cc.p(self.m_pPanelLeft:getPosition())
  end
  local duration = 0.5
  if self.m_barAnimIsRun == true then
    return
  end
  visible = not visible
  self.m_bars_show = visible
  self.m_barAnimIsRun = true
  local callfunc = cc.CallFunc:create(function()
    self.m_barAnimIsRun = false
  end)
  if visible == true then
    local action = cc.MoveTo:create(duration, self.m_pPanelBottom.m_locPos)
    self.m_pPanelBottom:runAction(action)
    action = cc.MoveTo:create(duration, self.m_pPanelTop.m_locPos)
    self.m_pPanelTop:runAction(action)
    action = cc.MoveTo:create(duration, self.m_pPanelRight.m_locPos)
    self.m_pPanelRight:runAction(cc.Sequence:create(action, callfunc))
    action = cc.MoveTo:create(duration, self.m_pPanelLeft.m_locPos)
    self.m_pPanelLeft:runAction(cc.Sequence:create(action, callfunc))
  elseif visible == false then
    local action = cc.MoveBy:create(duration, cc.p(0, -150 * self.m_scale))
    self.m_pPanelBottom:runAction(action)
    action = cc.MoveBy:create(duration, cc.p(0, 250 * self.m_scale))
    self.m_pPanelTop:runAction(action)
    action = cc.MoveBy:create(duration, cc.p(150 * self.m_scale, 0))
    self.m_pPanelRight:runAction(cc.Sequence:create(action, callfunc))
    action = cc.MoveBy:create(duration, cc.p(-150 * self.m_scale, 0))
    self.m_pPanelLeft:runAction(cc.Sequence:create(action, callfunc))
  end
end
function MainMenuScene:CheckTouchInTouchableChild(touch)
  local btns = {
    self.m_pArenaBtn,
    self.m_vProfitBtns[1]
  }
  for k, value in pairs(btns) do
    local nodePos = value:convertToNodeSpace(touch:getLocation())
    if isTouchInNode(value, nodePos) and value:isVisible() then
      return true
    end
  end
  return false
end
function MainMenuScene:IsTouchInMissionItems(touch)
  if not self.m_isScaled then
    return false
  end
  for k, value in ipairs(self.m_missionItems) do
    local touchNode = value
    touchNode = value:GetTouchNode()
    local nodePos = touchNode:convertToNodeSpace(touch:getLocation())
    if isTouchInNode(touchNode, nodePos) then
      return true
    end
  end
  return false
end
function MainMenuScene:ShowCityName(isShow)
  for k, value in ipairs(self.m_missionItems) do
    value:ShowCityName(isShow)
  end
end
function MainMenuScene:AddTitleInBtn(pBtn, title)
  local pTitle = display.newBMFontLabel({
    text = title,
    font = "Fonts/ModeName.fnt"
  })
  pBtn:addChild(pTitle)
  pTitle:setAnchorPoint(cc.p(0.5, 0.5))
  pTitle:setPosition(cc.p(35, 10))
  pTitle:setScale(0.8)
end
function MainMenuScene:CheckFirstEnter()
  if self:CheckNickname() then
    return
  end
  TriggerManager:GetInstance():AddTriggerByType(td.TriggerType.TaskGuide)
  if not GuideManager:GetInstance():IsForceGuideOver() then
    return
  end
  if self.m_udMng:HadEnteredMainMenu() then
    return
  end
  if self:CheckSignIn() then
    return
  end
  g_MC:OpenModule(td.UIModule.Activity)
  self.m_udMng:SetEnteredMainMenu()
end
function MainMenuScene:CheckNickname()
  local name, bNamed = self.m_udMng:GetNickname()
  if not bNamed then
    g_MC:OpenModule(td.UIModule.Name)
    return true
  end
  return false
end
function MainMenuScene:CheckSignIn()
  local udMng = self.m_udMng
  local signDays = udMng:GetSignInDay()
  local serverTime = udMng:GetServerTime()
  local lastSignTime = udMng:GetSignInTime()
  if signDays == 0 or signDays < 7 and td.TimeCompare(serverTime, lastSignTime) then
    g_MC:OpenModule(td.UIModule.NewSignIn)
    return true
  elseif td.TimeCompare(serverTime, lastSignTime) then
    g_MC:OpenModule(td.UIModule.SignInBox)
    return true
  end
  return false
end
function MainMenuScene:CheckGuide()
  if g_MC:IsAllModuleClose() then
    if self:CheckUnlock() then
      return
    end
    self:CheckLevelUp()
    GuideManager.H_GuideUI(td.UIModule.MainMenu, self.m_uiRoot)
  end
end
function MainMenuScene:CheckLevelUp()
  local guideLevel = GuideManager:GetInstance():GetGuideLevelUp()
  if guideLevel then
    local config = require("app.config.base_upgrade_tip")
    if config[guideLevel] then
      require("app.GuideManager").H_StartGuideGroup(config[guideLevel])
    end
    GuideManager:GetInstance():SetGuideLevelUp(nil)
  end
end
function MainMenuScene:CheckUnlock(event)
  for id, btn in pairs(self.m_vLockedBtn) do
    local bUnlock = false
    if g_MC:IsModuleUnlock(id, true) then
      bUnlock = true
    end
    if bUnlock then
      local spine
      if btn.isBottom then
        local tag = btn:getTag()
        if tag == 4 then
          spine = "Spine/UI_effect/UI_gonghuijiesuo_01"
        else
          spine = "Spine/UI_effect/UI_haoyoujiesuo_01"
        end
        btn:loadTextureNormal(td.Word_Path .. tag .. "-1.png")
        btn:loadTexturePressed(td.Word_Path .. tag .. "-2.png")
      elseif btn.isRight then
        spine = "Spine/UI_effect/UI_fubenjiesuo_01"
        btn:UpdateEffect("Spine/UI_effect/UI_chuzhenganniu_02")
      else
        spine = "Spine/UI_effect/UI_jjcjiesuo_01"
        btn:getChildByName("lock"):removeFromParent()
        local tmpSke = SkeletonUnit:create("Spine/UI_effect/UI_jinjichang_01")
        tmpSke:setScale(0.6)
        td.AddRelaPos(btn, tmpSke)
        tmpSke:PlayAni("animation", true)
      end
      td.CreateUIEffect(btn, spine, {
        cb = function()
          self:CheckGuide()
        end
      })
      self.m_vLockedBtn[id] = nil
      return true
    end
  end
  return false
end
function MainMenuScene:OnNameUpdate(event)
  local nickName = self.m_udMng:GetNickname()
  self.m_commanderInfo.homeName:setString(nickName)
end
function MainMenuScene:CheckAll()
  self:UpdateLeftBtns()
  self:CheckTask()
  self:CheckBase()
  self:CheckHero()
  self:CheckSoldier()
  self:CheckActivities()
  self:CheckStore()
  self:CheckMail()
end
function MainMenuScene:CheckTask()
  local taskDatas = self.m_udMng:GetTaskData()
  local bShow = false
  local taskTypes = {
    td.TaskType.MainLine,
    td.TaskType.Common,
    td.TaskType.Daily
  }
  for j, taskType in ipairs(taskTypes) do
    for i, task in ipairs(taskDatas[taskType]) do
      local taskState = TaskInfoManager:GetInstance():CheckTaskState(task)
      if taskState == td.TaskState.Complete then
        bShow = true
        break
      end
    end
  end
  for i, var in ipairs(td.AwardLiveness) do
    if self.m_udMng:CheckLivenessReward(i) then
      bShow = true
      break
    end
  end
  td.ShowRP(self.m_vBtmMenu[4], bShow)
end
function MainMenuScene:CheckBase()
  if self.m_udMng:IsBaseCanUpgrade() then
    td.ShowRP(self.m_vBtmMenu[1], true)
  else
    td.ShowRP(self.m_vBtmMenu[1], false)
  end
end
function MainMenuScene:CheckHero()
  local bShow = false
  if self.m_udMng:IsHeroCanUpgrade() then
    bShow = true
  elseif self.m_udMng:CanEquipNewWeapon() then
    bShow = true
  elseif self.m_udMng:CanEquipNewSkill() then
    bShow = true
  end
  td.ShowRP(self.m_vBtmMenu[2], bShow)
end
function MainMenuScene:CheckSoldier()
  td.ShowRP(self.m_vBtmMenu[3], UnitDataManager:GetInstance():IsSoldierCanUpgrade())
end
function MainMenuScene:CheckActivities()
  if not g_MC:IsModuleShowing(td.UIModule.Activity) and ActivityDataManager:GetInstance():CheckRP() then
    td.ShowRP(self.m_pActivityBtn, true, cc.p(0.95, 0.95))
    if not self.m_pActivityBtn:getChildByName("spine") then
      local spine = SkeletonUnit:create("Spine/UI_effect/UI_huodongtishi_01")
      spine:setName("spine")
      td.AddRelaPos(self.m_pActivityBtn, spine, -1)
      spine:PlayAni("animation", true)
    end
  end
end
function MainMenuScene:CheckGuildActivities()
  if self.m_udMng:GetBaseCampLevel() < 15 then
    return
  end
  local guildMng = GuildDataManager:GetInstance()
  if not guildMng:GetGuildData() then
    return
  end
  local function showMsg()
    local text = g_LM:getBy("a00229")
    local button1 = {
      text = g_LM:getBy("a00116"),
      bIsClose = true
    }
    local button2 = {
      text = g_LM:getBy("a00051"),
      callFunc = function()
        local pScene = require("app.scenes.GuildScene").new()
        pScene:SetEnterModule(3)
        cc.Director:getInstance():replaceScene(pScene)
      end
    }
    local messageBoxDlg = MessageBoxDlg.new({
      size = cc.size(454, 300),
      content = text,
      buttons = {button2, button1}
    })
    messageBoxDlg:Show()
  end
  local bStart, cdTime = guildMng:IsGuildPVPStart()
  if bStart and cdTime == 0 then
    local lastNoticeTime = g_LD:GetInt("guild_pvp", 0)
    local serverTime = self.m_udMng:GetServerTime()
    if math.abs(serverTime - lastNoticeTime) > 86400 then
      g_LD:SetInt("guild_pvp", serverTime)
      showMsg()
    end
  end
end
function MainMenuScene:CheckStore()
  local storeMng = self.m_udMng:GetStoreManager()
  if not g_MC:IsModuleShowing(td.UIModule.Supply) and storeMng:CheckRP() then
    td.ShowRP(self.m_vRightMenu[4], true, cc.p(0.7, 0.7))
  end
end
function MainMenuScene:CheckMail()
  if not g_MC:IsModuleShowing(td.UIModule.Mail) then
    local bShow = false
    local mailData = self.m_udMng:GetMailsData()
    for i, var in ipairs(mailData) do
      if var.type == 1 then
        bShow = true
        break
      end
    end
    if bShow then
      td.ShowRP(self.m_mailBtn, true, cc.p(0.95, 0.95))
    end
  end
end
return MainMenuScene
