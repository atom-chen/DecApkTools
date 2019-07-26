local BaseUILayer = require("app.layers.BaseUILayer")
local GameDataManager = require("app.GameDataManager")
local UserDataManager = require("app.UserDataManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local ActorManager = require("app.actor.ActorManager")
local scheduler = require("framework.scheduler")
local GuideManager = require("app.GuideManager")
local SoldierButton = require("app.widgets.SoldierButton")
local SkillButton = require("app.widgets.SkillButton")
local CircleMenu = require("app.widgets.CircleMenu")
local ActorDetailDlg = require("app.widgets.ActorDetailDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local BattleUILayer = class("BattleUILayer", BaseUILayer)
local WARN_TIME = 60
function BattleUILayer:ctor()
  BattleUILayer.super.ctor(self)
  self.m_uiId = td.UIModule.BattleUI
  self.m_uiRoot = nil
  self.m_soldierBtns = {}
  self.m_skillBtns = {}
  self.m_circleMenu = nil
  self.m_actorDetailDlg = nil
  self.m_heroBtn = nil
  self.m_heroHPBar = nil
  self.m_vListeners = {}
  self.m_showHitEffectTime = 0
  self.m_bIsAcc = false
  self:InitUI()
end
function BattleUILayer:onEnter()
  self:AddListeners()
  self:AddBtnEvent()
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
  self:scheduleUpdate()
  self:performWithDelay(function()
    if GuideManager:GetInstance():ShouldWeakGuide() then
      self.m_weakGuideScheduler = scheduler.scheduleGlobal(handler(self, self.WeakGuide), 3)
      td.CreateUIEffect(self.m_btnRestrain, "Spine/UI_effect/UI_zuanshishanguang_01", {scale = 0.7, random = true})
    end
  end, 5)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.BuyBattleItem, handler(self, self.BuyBattleItemCallback))
end
function BattleUILayer:onExit()
  BattleUILayer.super.onExit(self)
  cc.Director:getInstance():getScheduler():setTimeScale(1)
  self:removeNodeEventListener(handler(self, self.update))
  self:unscheduleUpdate()
  if self.m_weakGuideScheduler then
    scheduler.unscheduleGlobal(self.m_weakGuideScheduler)
    self.m_weakGuideScheduler = nil
  end
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.BuyBattleItem)
end
function BattleUILayer:WeakGuide()
  if GuideManager:GetInstance():IsGuiding() or GameDataManager:GetInstance():IsGameOver() then
    return
  end
  local nowTime = UserDataManager:GetInstance():GetServerTime()
  if nowTime - g_MC:GetOpTime() > 3 then
    local guideGroups = {}
    for i = 1, 6 do
      if self.m_soldierBtns[i] and self.m_soldierBtns[i]:isEnable() then
        table.insert(guideGroups, 60 + i)
      end
    end
    for i = 1, 4 do
      if self.m_skillBtns[i] and self.m_skillBtns[i]:isEnable() then
        table.insert(guideGroups, 66 + i)
      end
    end
    local guideGroup
    if #guideGroups > 1 then
      guideGroup = guideGroups[math.random(#guideGroups)]
    elseif #guideGroups == 1 then
      guideGroup = guideGroups[1]
    else
      return
    end
    require("app.GuideManager").H_StartGuideGroup(guideGroup, 1)
  end
end
function BattleUILayer:update(dt)
  if self.m_showHitEffectTime > 0 then
    self.m_showHitEffectTime = cc.clampf(self.m_showHitEffectTime - dt, 0, 3)
  end
  if self.m_hitEffect:isVisible() then
    if self.m_showHitEffectTime <= 0 then
      self.m_hitEffect:setVisible(false)
      self.m_hitEffect:stopAllActions()
    end
  elseif self.m_showHitEffectTime > 0 then
    self.m_hitEffect:setOpacity(0)
    self.m_hitEffect:setVisible(true)
    self.m_hitEffect:runAction(cca.repeatForever(cca.seq({
      cca.fadeIn(1),
      cca.fadeOut(1)
    })))
    td.alert(g_LM:getBy("a00325"), true)
  end
end
function BattleUILayer:InitUI()
  local gdMng = GameDataManager:GetInstance()
  local mapInfo = gdMng:GetGameMapInfo()
  self.m_uiRoot = cc.uiloader:load("CCS/BattleUILayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_pPanel_bottom_right = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bottom_right")
  td.SetAutoScale(self.m_pPanel_bottom_right, td.UIPosHorizontal.Center, td.UIPosVertical.Bottom)
  self.m_pPanel_top = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_top")
  td.SetAutoScale(self.m_pPanel_top, td.UIPosHorizontal.Center, td.UIPosVertical.Top)
  self.m_pPanel_bottom_left = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bottom_left")
  td.SetAutoScale(self.m_pPanel_bottom_left, td.UIPosHorizontal.Left, td.UIPosVertical.Bottom)
  self.m_popuIcon = cc.uiloader:seekNodeByName(self.m_uiRoot, "PopuIcon")
  local PopuLabelNode = cc.uiloader:seekNodeByName(self.m_uiRoot, "PopuLabelNode")
  self.m_popuLabel = td.CreateLabel(tostring(gdMng:GetCurPopulation() .. "/" .. gdMng:GetMaxPopulation()), td.WHITE, 18, td.OL_BLACK)
  self.m_popuLabel:setAnchorPoint(0, 0.5)
  self.m_popuLabel:addTo(PopuLabelNode)
  self.m_msgBg = display.newScale9Sprite("UI/scale9/tipskuang.png", 0, 0, cc.size(300, 50))
  self.m_msgBg:setVisible(false)
  self.m_msgBg:pos(self.m_pPanel_top:getContentSize().width / 2, self.m_pPanel_top:getContentSize().height - 35):addTo(self.m_pPanel_top)
  self.m_msgLabel = td.CreateLabel("", td.YELLOW, 20)
  td.AddRelaPos(self.m_msgBg, self.m_msgLabel)
  if mapInfo.type ~= td.MapType.Bomb then
    for i = 1, 6 do
      local soldierBtnNode = cc.uiloader:seekNodeByName(self.m_uiRoot, "SoldierBtn_" .. i)
      local soldierBtn = SoldierButton.new(i)
      soldierBtn:setTag(1)
      soldierBtn:addTo(soldierBtnNode)
      soldierBtn:UpdateSelf()
      self.m_soldierBtns[i] = soldierBtn
    end
  end
  self:CreateHeroUI(mapInfo.type)
  if mapInfo.type == td.MapType.ZiYuan or mapInfo.type == td.MapType.Rob or mapInfo.type == td.MapType.Collect then
    local ResourceMeter = require("app.widgets.ResourceMeter")
    local resourceMeter = ResourceMeter.new()
    resourceMeter:setName("ResNode")
    resourceMeter:setScale(td.GetAutoScale())
    resourceMeter:setPosition(display.width, 0)
    resourceMeter:addTo(self.m_uiRoot)
  end
  local roundNode = cc.uiloader:seekNodeByName(self.m_uiRoot, "RoundNode")
  self.m_roundIcon = roundNode:getChildByTag(1)
  if mapInfo.type == td.MapType.FangShou or mapInfo.type == td.MapType.Endless then
    self.m_RoundLabel = td.CreateLabel("0", td.WHITE, 18, td.OL_BLACK)
    self.m_RoundLabel:setAnchorPoint(0.5, 0.5)
    self.m_RoundLabel:addTo(roundNode)
  else
    self.m_roundIcon:loadTexture("UI/icon/shijian_icon.png")
    local str = td.GetStrForTime(mapInfo.max_time)
    self.m_timeLabel = td.CreateLabel(str, td.WHITE, 18, td.OL_BLACK)
    self.m_timeLabel:setAnchorPoint(0.5, 0.5)
    self.m_timeLabel:addTo(roundNode)
  end
  local autoScale = td.GetAutoScale()
  self.m_hitEffect = display.newScale9Sprite("#UI/battle/hongsezhezhao.png", 0, 0, cc.size(display.width / autoScale, display.height / autoScale))
  self.m_hitEffect:scale(autoScale)
  self.m_hitEffect:pos(display.width / 2, display.height / 2):addTo(self)
  local configs = require("app.config.mission_target")
  local targetData = configs[mapInfo.id]
  if targetData then
    local posNode = cc.uiloader:seekNodeByName(self.m_uiRoot, "TargetNode")
    local battleTarget = require("app.widgets.BattleTargetUI").new(targetData)
    battleTarget:addTo(posNode)
  end
  self.m_tipButton = cc.uiloader:seekNodeByName(self.m_pPanel_top, "EnemyTip")
  self.m_btnRestrain = cc.uiloader:seekNodeByName(self.m_pPanel_top, "Button_kezhi")
end
function BattleUILayer:CreateHeroUI(mapType)
  local heroSlotBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "HeroSlotBg")
  if mapType ~= td.MapType.ZiYuan and mapType ~= td.MapType.Rob and mapType ~= td.MapType.Collect then
    heroSlotBg:setVisible(false)
  end
  self.m_changeBtn = ccui.Button:create("UI/battle/qiehuan_icon.png", "UI/battle/qiehuan1_icon.png", "UI/battle/qiehuan1_icon.png")
  td.BtnAddTouch(self.m_changeBtn, function()
    self:showChangeHero()
  end)
  self.m_changeBtn:setPosition(45, 45)
  self.m_changeBtn:addTo(cc.uiloader:seekNodeByName(self.m_uiRoot, "HeroNode"), 10)
  if GameDataManager:GetInstance():GetHeroCount() > 1 then
    self.m_changeBtn:setVisible(true)
  else
    self.m_changeBtn:setVisible(false)
  end
  local heroData = GameDataManager:GetInstance():GetCurHeroData()
  if heroData then
    self:InitHeroUI(heroData)
  else
    heroSlotBg:setVisible(false)
  end
end
function BattleUILayer:InitHeroUI(heroData)
  self:initHeroSkillUI(heroData)
  self.m_heroBtn = require("app.widgets.HeroButton").new(heroData.heroInfo)
  self.m_heroBtn:setName("Button_hero")
  self.m_heroBtn:SetSelected(true)
  self.m_heroBtn:addTo(cc.uiloader:seekNodeByName(self.m_uiRoot, "HeroNode"))
  local bloodBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "BloodBarBg")
  local hpSpr = display.newSprite("#UI/battle/yingxiongxuetiao.png")
  self.m_heroHPBar = cc.ProgressTimer:create(hpSpr)
  self.m_heroHPBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  self.m_heroHPBar:setMidpoint(cc.p(1, 0))
  self.m_heroHPBar:setBarChangeRate(cc.p(1, 0))
  self.m_heroHPBar:setPosition(bloodBg:getContentSize().width / 2, bloodBg:getContentSize().height / 2)
  self.m_heroHPBar:addTo(bloodBg)
  if heroData.bDead then
    self.m_heroHPBar:setPercentage(0)
  else
    self.m_heroHPBar:setPercentage(100)
  end
  local LVNode = cc.uiloader:seekNodeByName(self.m_uiRoot, "LVNode")
  local levelLabel = LVNode:getChildByTag(11)
  if levelLabel then
    levelLabel:setString("LV." .. heroData.level)
  else
    levelLabel = td.CreateLabel("LV." .. heroData.level, td.LIGHT_GREEN, 16, td.OL_BLACK)
    levelLabel:setTag(11)
    levelLabel:setAnchorPoint(0.5, 0.5)
    levelLabel:addTo(LVNode)
  end
end
function BattleUILayer:initHeroSkillUI(heroData)
  local hero = GameDataManager:GetInstance():GetCurHero()
  if not hero then
    return
  end
  local key, wskey = 1, 3
  for i, skill in ipairs(hero.m_pSkillManager.m_vActiveSkills) do
    if skill:GetType() == td.SkillType.FixedMagic or skill:GetType() == td.SkillType.RandomMagic then
      local skillBtn
      if table.indexof(heroData.weaponSkills, skill:GetID()) then
        skillBtn = SkillButton.new(skill, true)
        skillBtn:setName("Button_skill" .. wskey)
        skillBtn:addTo(cc.uiloader:seekNodeByName(self.m_uiRoot, "SkillNode" .. wskey))
        self.m_skillBtns[wskey] = skillBtn
        wskey = wskey + 1
      else
        skillBtn = SkillButton.new(skill)
        skillBtn:setName("Button_skill" .. key)
        skillBtn:addTo(cc.uiloader:seekNodeByName(self.m_uiRoot, "SkillNode" .. key))
        self.m_skillBtns[key] = skillBtn
        key = key + 1
      end
      if heroData.bDead then
        skillBtn:setEnable(false)
      end
    end
  end
end
function BattleUILayer:UpdatePopu(_event)
  local num = tonumber(_event:getDataString())
  if num then
    local numStr = ""
    if num >= 0 then
      numStr = "+" .. num
    else
      numStr = "" .. num
    end
    local label = td.CreateLabel(numStr, td.WHITE, 18, td.OL_BLACK)
    label:setAnchorPoint(0.5, 0.5)
    label:pos(0, -20):addTo(self.m_popuLabel:getParent()):runAction(cca.seq({
      cca.spawn({
        cca.fadeTo(0.5, 50),
        cca.scaleBy(0.5, 2)
      }),
      cca.removeSelf()
    }))
  end
  local gdMng = GameDataManager:GetInstance()
  self.m_popuLabel:setString(gdMng:GetCurPopulation() .. "/" .. gdMng:GetMaxPopulation())
  self.m_popuIcon:runAction(cca.seq({
    cca.scaleTo(0.1, 1.3),
    cca.scaleTo(0.1, 0.8),
    cca.scaleTo(0.05, 1)
  }))
end
function BattleUILayer:UpdateHeroUI()
  for i, v in pairs(self.m_skillBtns) do
    v:removeFromParent()
  end
  self.m_skillBtns = {}
  if self.m_heroBtn then
    self.m_heroBtn:removeFromParent()
    self.m_heroBtn = nil
  end
  if self.m_heroHPBar then
    self.m_heroHPBar:removeFromParent()
    self.m_heroHPBar = nil
  end
  if GameDataManager:GetInstance():GetHeroCount() > 1 then
    self.m_changeBtn:setVisible(true)
  else
    self.m_changeBtn:setVisible(false)
  end
  local heroData = GameDataManager:GetInstance():GetCurHeroData()
  if heroData then
    local heroSlotBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "HeroSlotBg")
    heroSlotBg:setVisible(true)
    self:InitHeroUI(heroData)
  end
end
function BattleUILayer:PlayHeroCD(total, cur)
  cur = cur or total
  local gdMng = GameDataManager:GetInstance()
  self.m_heroBtn:PlayCD(total, cur)
end
function BattleUILayer:UpdateHeroSkillUI()
  for i, v in pairs(self.m_skillBtns) do
    v:removeFromParent()
  end
  self.m_skillBtns = {}
  self:initHeroSkillUI()
end
function BattleUILayer:ShowCircleMenu(_event)
  local data = string.toTable(_event:getDataString())
  if data.hide then
    self.m_soldierBtns[data.index]:SetSelected(false)
  else
    self.m_circleMenu = CircleMenu.new(data.index, data.bType, data.level, data.branch)
    local conSize = self.m_circleMenu:GetContentSize()
    data.x = cc.clampf(data.x, conSize.width, display.width - conSize.width)
    data.y = cc.clampf(data.y, conSize.height, display.height - conSize.height)
    self.m_circleMenu:setPosition(data.x, data.y)
    self.m_circleMenu:addTo(self.m_uiRoot, 2)
    self.m_soldierBtns[data.index]:SetSelected(true)
  end
end
function BattleUILayer:ShowActorDetail(_event)
  local data = string.toTable(_event:getDataString())
  if self.m_actorDetailDlg then
    self.m_actorDetailDlg:removeFromParent()
    self.m_actorDetailDlg = nil
  end
  if tonumber(data.tag) ~= -1 then
    self.m_actorDetailDlg = ActorDetailDlg.new()
    self.m_actorDetailDlg:SetData(data.tag)
    self.m_actorDetailDlg:setScale(td.GetAutoScale())
    self.m_uiRoot:addChild(self.m_actorDetailDlg, 2)
  end
end
function BattleUILayer:UpdateSoldierBtn(_event)
  local data = string.toTable(_event:getDataString())
  self.m_soldierBtns[data.index]:UpdateSelf()
end
function BattleUILayer:pause()
  local pauseLayer = require("app.layers.battle.PauseDlg").new()
  td.popView(pauseLayer)
end
function BattleUILayer:SetTime(time)
  if not self.m_timeLabel then
    return
  end
  local str = td.GetStrForTime(time)
  self.m_timeLabel:setString(str)
  if time <= WARN_TIME then
    self.m_timeLabel:setScale(1.5)
    self.m_timeLabel:runAction(cca.scaleTo(0.5, 1, 1))
    if not self.m_bIsWarning then
      local pos = cc.p(self.m_roundIcon:getPosition())
      local shakeAction = cca.seq({
        cca.moveTo(0.05, pos.x + 5, pos.y + 3),
        cca.moveTo(0.05, pos.x - 3, pos.y + 5),
        cca.moveTo(0.05, pos.x + 3, pos.y - 3),
        cca.moveTo(0.05, pos.x - 3, pos.y + 5),
        cca.moveTo(0.05, pos.x - 5, pos.y - 5),
        cca.moveTo(0.05, pos.x, pos.y)
      })
      self.m_roundIcon:runAction(cca.rep(shakeAction, 10))
      self.m_timeLabel:setColor(td.RED)
      self.m_bIsWarning = true
    end
  end
end
function BattleUILayer:StartPipe()
  if self.m_pPipeline then
    self.m_pPipeline:Start()
  end
end
function BattleUILayer:StopPipe()
  if self.m_pPipeline then
    self.m_pPipeline:Stop()
  end
end
function BattleUILayer:UpdateHome(_event)
  self.m_showHitEffectTime = 3
end
function BattleUILayer:UpdateHero(_event)
  local data = _event:getDataString()
  if data and data ~= "" then
    data = string.toTable(data)
    if data.hide == 1 then
      self.m_heroBtn:SetSelected(false)
    elseif data.hide == 0 then
      self.m_heroBtn:SetSelected(true)
    end
  else
    local hero = GameDataManager:GetInstance():GetCurHero()
    local per = hero:GetCurHp() / hero:GetMaxHp() * 100
    self.m_heroHPBar:setPercentage(per)
    if per < 50 and per > 0 then
      local rp = SkeletonUnit:create("Spine/UI_effect/UI_yingxiongxuetiao_01")
      rp:PlayAni("animation", true)
      td.ShowRP(self.m_heroHPBar, true, cc.p(0.5, 0.5), rp)
    else
      td.ShowRP(self.m_heroHPBar, false)
    end
  end
end
function BattleUILayer:ChangeHero(index)
  local gdMng = GameDataManager:GetInstance()
  gdMng:SetChangeHeroIndex(index)
  local curHero = gdMng:GetCurHero()
  if curHero then
    gdMng:SetChangeHeroPos(cc.p(curHero:getPosition()))
    curHero:SetRemove(true)
  else
    td.dispatchEvent(td.CHANGE_HERO)
  end
end
function BattleUILayer:UpdateBossBar(_event)
  local percent = tonumber(_event:getDataString())
  if not self.m_bossHpBar then
    local bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "BossBg")
    bg:setVisible(true)
    local hpSpr = display.newSprite("#UI/battle/boss_jindutiao2.png")
    self.m_bossHpBar = cc.ProgressTimer:create(hpSpr)
    self.m_bossHpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.m_bossHpBar:setMidpoint(cc.p(1, 0))
    self.m_bossHpBar:setBarChangeRate(cc.p(1, 0))
    self.m_bossHpBar:setPosition(bg:getContentSize().width * 0.618, bg:getContentSize().height * 0.4)
    self.m_bossHpBar:addTo(bg)
  end
  self.m_bossHpBar:setPercentage(percent)
end
function BattleUILayer:ShowMonsterTip(event)
  self.m_tipButton:setScale(0.1)
  self.m_tipButton:setVisible(true)
  self.m_tipButton:runAction(cca.seq({
    cca.scaleTo(0.3, 1.2),
    cca.scaleTo(0.3, 0.9),
    cca.scaleTo(0.2, 1)
  }))
end
function BattleUILayer:showChangeHero(_event)
  self.m_heroMenu = require("app.widgets.ChangeHeroMenu").new()
  local pos = self.m_heroBtn:getParent():convertToWorldSpace(cc.p(self.m_heroBtn:getPosition()))
  self.m_heroMenu:setPosition(pos.x, pos.y)
  self.m_heroMenu:addTo(self.m_uiRoot, 2)
end
function BattleUILayer:ShowUIMessage(msg)
  if msg then
    self.m_msgBg:setVisible(true)
    self.m_msgLabel:setString(msg)
  else
    self.m_msgBg:setVisible(false)
    self.m_msgLabel:setString("")
  end
end
function BattleUILayer:ShowRestrain()
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  local restrainDlg = require("app.layers.battle.RestrainDlg").new()
  td.popView(restrainDlg)
end
function BattleUILayer:AddBtnEvent()
  local pauseBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "PauseBtn")
  td.BtnAddTouch(pauseBtn, handler(self, self.pause))
  local buttonscale = cc.uiloader:seekNodeByName(self.m_pPanel_top, "AccBtn")
  buttonscale:addTouchEventListener(function(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      self.m_bIsAcc = not self.m_bIsAcc
      if self.m_bIsAcc then
        buttonscale:setColor(td.BTN_PRESSED_COLOR)
        cc.Director:getInstance():getScheduler():setTimeScale(2)
      else
        buttonscale:setColor(td.WHITE)
        cc.Director:getInstance():getScheduler():setTimeScale(1)
      end
    end
  end)
  td.BtnAddTouch(self.m_btnRestrain, handler(self, self.ShowRestrain))
  td.BtnAddTouch(self.m_tipButton, function()
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    self.m_tipButton:setVisible(false)
    local pDlg = require("app.layers.battle.EnemyDescDlg").new()
    pDlg:Show()
  end)
end
function BattleUILayer:AddListeners()
  self:AddCustomEvent(td.ADD_BUIDING_EVENT, handler(self, self.UpdateSoldierBtn))
  self:AddCustomEvent(td.UPDATE_HERO, handler(self, self.UpdateHero))
  self:AddCustomEvent(td.UPDATE_HOME_HP, handler(self, self.UpdateHome))
  self:AddCustomEvent(td.BUIDING_MENU_EVENT, handler(self, self.ShowCircleMenu))
  self:AddCustomEvent(td.SHOW_ACTOR_DETAIL, handler(self, self.ShowActorDetail))
  self:AddCustomEvent(td.UPDATE_HERO_SKILL, handler(self, self.UpdateHeroSkillUI))
  self:AddCustomEvent(td.UPDATE_POPULATION, handler(self, self.UpdatePopu))
  self:AddCustomEvent(td.UPDATE_BOSS_HP, handler(self, self.UpdateBossBar))
  self:AddCustomEvent(td.NEW_MONSTER_TIP, handler(self, self.ShowMonsterTip))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  self:AddCustomEvent(td.ENABLE_SKILL_BTN, function(_event)
    local tag = tonumber(_event:getDataString())
    if tag == 0 then
      for i, v in pairs(self.m_skillBtns) do
        v:setEnable(false)
      end
    elseif tag == 1 then
      for i, v in pairs(self.m_skillBtns) do
        v:setEnable(true)
      end
    end
  end)
  self:AddCustomEvent(td.ACTOR_DIED, function(_event)
    local tag = tonumber(_event:getDataString())
    if tag == ActorManager.KEY_HERO then
      self.m_heroBtn:setEnable(false)
      for i, v in pairs(self.m_skillBtns) do
        v:setEnable(false)
      end
    end
  end)
  self:AddCustomEvent(td.HERO_GET_HURT, function(_event)
    local isHurt = tonumber(_event:getDataString())
    if self.m_changeBtn then
      if isHurt == 0 then
        self.m_changeBtn:setDisable(false)
      else
        self.m_changeBtn:setDisable(true)
      end
    end
  end)
  local gdMng = GameDataManager:GetInstance()
  local mapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  if mapInfo.type == td.MapType.Endless or mapInfo.type == td.MapType.FangShou then
    self:AddCustomEvent(td.ADD_WAVE, function(_event)
      local data = string.toTable(_event:getDataString())
      if mapInfo.type == td.MapType.Endless then
        self.m_RoundLabel:setString(tostring(data.curCount))
      else
        self.m_RoundLabel:setString(tostring(data.curCount) .. "/" .. data.maxWave)
      end
    end)
  end
end
function BattleUILayer:ShowRebornMsg(index)
  local boughtTime = GameDataManager:GetInstance():GetRebornTime()
  local productInfo = require("app.info.CommonInfoManager"):GetInstance():GetMallItemInfo(td.BuyRebornId)
  local costNum, remainTime = (boughtTime + 1) * productInfo.price, td.GetConst("hero_reborn_time") - boughtTime
  local conStr = ""
  local vButtons = {}
  if remainTime < 1 then
    conStr = "\230\172\161\230\149\176\229\183\178\231\148\168\229\174\140"
    local button1 = {
      text = g_LM:getBy("a00009")
    }
    table.insert(vButtons, button1)
  else
    conStr = string.format("\231\161\174\229\174\154\232\138\177\232\180\185%d\233\146\187\231\159\179\229\164\141\230\180\187\232\139\177\233\155\132\229\144\151\239\188\159\239\188\136\232\191\152\229\143\175\229\164\141\230\180\187%d\230\172\161\239\188\137", costNum, remainTime)
    local button1 = {
      text = g_LM:getBy("a00009"),
      callFunc = function()
        if UserDataManager:GetInstance():GetDiamond() < costNum then
          local pString = g_LM:getMode("errormsg", td.ErrorCode.DIAMOND_NOT_ENOUGH)
          td.alert(pString, true)
        else
          self:BuyBattleItem(9006, boughtTime + 1, index)
        end
      end
    }
    local button2 = {
      text = g_LM:getBy("a00116")
    }
    table.insert(vButtons, button1)
    table.insert(vButtons, button2)
  end
  local messageBoxDlg = require("app.layers.MessageBoxDlg").new({
    size = cc.size(454, 300),
    title = "",
    content = conStr,
    buttons = vButtons,
    pause = true
  })
  messageBoxDlg:Show()
end
function BattleUILayer:ShowClearCDMsg(skillId)
  local boughtTime = GameDataManager:GetInstance():GetClearCDTime()
  local productInfo = require("app.info.CommonInfoManager"):GetInstance():GetMallItemInfo(td.BuySkillCDId)
  local costNum, remainTime = (boughtTime + 1) * productInfo.price, td.GetConst("skill_cd_max_time") - boughtTime
  local conStr = ""
  local vButtons = {}
  if remainTime < 1 then
    conStr = "\230\172\161\230\149\176\229\183\178\231\148\168\229\174\140"
    local button1 = {
      text = g_LM:getBy("a00009")
    }
    table.insert(vButtons, button1)
  else
    conStr = string.format("\231\161\174\229\174\154\232\138\177\232\180\185%d\233\146\187\231\159\179\230\184\133\233\153\164\230\138\128\232\131\189CD\229\144\151\239\188\159\239\188\136\232\191\152\229\143\175\230\184\133\233\153\164%d\230\172\161\239\188\137", costNum, remainTime)
    local button1 = {
      text = g_LM:getBy("a00009"),
      callFunc = function()
        if UserDataManager:GetInstance():GetDiamond() < costNum then
          local pString = g_LM:getMode("errormsg", td.ErrorCode.DIAMOND_NOT_ENOUGH)
          td.alert(pString, true)
        else
          self:BuyBattleItem(9005, boughtTime + 1, skillId)
        end
      end
    }
    local button2 = {
      text = g_LM:getBy("a00116")
    }
    table.insert(vButtons, button1)
    table.insert(vButtons, button2)
  end
  local messageBoxDlg = require("app.layers.MessageBoxDlg").new({
    size = cc.size(454, 300),
    title = "",
    content = conStr,
    buttons = vButtons,
    pause = true
  })
  messageBoxDlg:Show()
end
function BattleUILayer:BuyBattleItem(itemId, time, _customData)
  local Msg = {}
  Msg.msgType = td.RequestID.BuyBattleItem
  Msg.sendData = {type = itemId, num = time}
  Msg.cbData = {type = itemId, customData = _customData}
  TDHttpRequest:getInstance():Send(Msg)
end
function BattleUILayer:BuyBattleItemCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    local gdMng = GameDataManager:GetInstance()
    if cbData.type == 9006 then
      local index = cbData.customData
      gdMng:RebornHero(index)
      self:ChangeHero(index)
    elseif cbData.type == 9005 then
      gdMng:ClearSkillCD(cbData.customData)
    end
  else
    print("\229\164\177\232\180\165")
  end
end
return BattleUILayer
