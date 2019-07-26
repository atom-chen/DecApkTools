local StrongInfoManager = require("app.info.StrongInfoManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local UserDataManager = require("app.UserDataManager")
local GuideManager = require("app.GuideManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local BaseDlg = require("app.layers.BaseDlg")
local RichIcon = require("app.widgets.RichIcon")
local TabButton = require("app.widgets.TabButton")
require("app.config.hero_sound_config")
local HeroInfoNewDlg = class("HeroInfoNewDlg", BaseDlg)
local ListItemTag = {
  SelectBorder = 1,
  SZBorder = 2,
  SZLabel = 3,
  BG = 11
}
function HeroInfoNewDlg:ctor()
  HeroInfoNewDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Hero
  self.m_udMng = UserDataManager:GetInstance()
  self.m_stiMng = StrongInfoManager:GetInstance()
  self.m_skiMng = SkillInfoManager:GetInstance()
  self.m_vHeroData = {}
  self.m_vSkillData = {}
  self.m_vGemData = {}
  self.m_iUpgradeHeroCost = 0
  self.m_curHeroLevel = 0
  self.m_vBattleHeroIndex = {}
  self.m_vOriBattleHeroIndex = {}
  self.m_bIsInBattle = nil
  self.m_bUnlock = true
  self.m_currTabIndex = nil
  self.m_curHeroIndex = nil
  self.m_vHeroItems = {}
  self.m_skillBtns = {}
  self.m_gemBtns = {}
  self.m_stars = {}
  self.m_vTmpNodes = {}
  self:InitData()
  self:InitUI()
  self:InitHeroList()
end
function HeroInfoNewDlg:onEnter()
  HeroInfoNewDlg.super.onEnter(self)
  self:CreateForgroundMask()
  self:InitTab()
  self.m_TabButton:setEnable(false)
  self:PlayEnterAni(function()
    self:CheckGuide()
    self:performWithDelay(function()
      self.m_TabButton:setEnable(true)
      self:InitBtnEvent()
      self:AddEvents()
      self:RemoveForgroundMask()
    end, 0.1)
  end)
end
function HeroInfoNewDlg:onExit()
  self:SendBattleHeroRequest()
  HeroInfoNewDlg.super.onExit(self)
end
function HeroInfoNewDlg:InitData()
  self.m_vHeroData = {}
  local heroDatas = UserDataManager:GetInstance():GetHeroData()
  for id, heroData in pairs(heroDatas) do
    table.insert(self.m_vHeroData, heroData)
  end
  for i = 1, 3 do
    for j, heroData in ipairs(self.m_vHeroData) do
      if i == heroData.battle then
        table.insert(self.m_vOriBattleHeroIndex, j)
        table.insert(self.m_vBattleHeroIndex, j)
      end
    end
  end
  local vAllHeroInfo = ActorInfoManager:GetInstance():GetHeroInfos()
  for heroId, heroInfo in pairs(vAllHeroInfo) do
    local bHeroExist = false
    for j, heroData in ipairs(self.m_vHeroData) do
      if heroId == heroData.hid then
        bHeroExist = true
        break
      end
    end
    if not bHeroExist then
      local heroData = self.m_stiMng:MakeHeroData({
        id = 0,
        exp = 0,
        hid = heroId,
        level = 1,
        attackSite = 0,
        defSite = 0,
        battle = 0,
        gemstone1 = 0,
        gemstone2 = 0,
        gemstone3 = 0,
        gemstone4 = 0
      }, self.m_udMng:GetBoostData())
      table.insert(self.m_vHeroData, heroData)
    end
  end
end
function HeroInfoNewDlg:InitUI()
  self:LoadUI("CCS/HeroInfoNewDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_yingxiong.png")
  self.m_panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_panel, "Panel_bg")
  self.m_Image_part1 = cc.uiloader:seekNodeByName(self.m_bg, "Image_part1")
  self.m_Image_part2 = cc.uiloader:seekNodeByName(self.m_bg, "Image_part2")
  self.m_heroPanel = cc.uiloader:seekNodeByName(self.m_Image_part1, "Panel_hero_skele")
  self.m_list_bg = cc.uiloader:seekNodeByName(self.m_bg, "Panel_list_bg")
  local list_bg_size = self.m_list_bg:getContentSize()
  self.m_panel_attr = cc.uiloader:seekNodeByName(self.m_bg, "Panel_attr")
  self.m_panel_item = cc.uiloader:seekNodeByName(self.m_Image_part2, "Panel_item")
  self.m_panel_skill = cc.uiloader:seekNodeByName(self.m_Image_part2, "Panel_skill")
  self.m_panel_gem = cc.uiloader:seekNodeByName(self.m_Image_part2, "Panel_gem")
  self.m_panel_exp = cc.uiloader:seekNodeByName(self.m_bg, "Panel_exp")
  self.m_hero_name = cc.uiloader:seekNodeByName(self.m_Image_part1, "Text_name")
  self.m_hero_power = cc.uiloader:seekNodeByName(self.m_Image_part1, "Text_power")
  self.m_hero_rating = cc.uiloader:seekNodeByName(self.m_Image_part1, "Image_rating")
  self.m_hero_rating:setLocalZOrder(999)
  self.m_levelLabel = cc.uiloader:seekNodeByName(self.m_panel_exp, "Text_lvl")
  local barBg = cc.uiloader:seekNodeByName(self.m_panel_exp, "Image_exp_bg")
  self.m_expPgBar = cc.ProgressTimer:create(display.newSprite("UI/hero/lvse_jindutiao.png"))
  self.m_expPgBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  self.m_expPgBar:setMidpoint(cc.p(0, 0))
  self.m_expPgBar:setBarChangeRate(cc.p(1, 0))
  self.m_expPgBar:setPercentage(0)
  td.AddRelaPos(barBg, self.m_expPgBar)
  self.m_expLabel = td.CreateLabel("", nil, 16, td.OL_BLACK, 1)
  td.AddRelaPos(self.m_expPgBar, self.m_expLabel)
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    alignment = cc.ui.UIScrollView.ALIGNMENT_TOP,
    viewRect = cc.rect(0, 40, list_bg_size.width, list_bg_size.height - 80),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_list_bg:addChild(self.m_UIListView)
  self.m_UIListView:onTouch(function(event)
    if event.name == "clicked" then
      self:SetHeroItemSelect(event.itemPos)
    end
  end)
  local vStr = {
    td.Property.HP,
    td.Property.Atk,
    td.Property.Def,
    td.Property.AtkSp,
    td.Property.Crit,
    td.Property.Dodge
  }
  local vPos = {
    cc.p(60, 110),
    cc.p(210, 110),
    cc.p(360, 110),
    cc.p(60, 50),
    cc.p(210, 50),
    cc.p(360, 50)
  }
  for i, var in ipairs(vStr) do
    local label = td.CreateLabel(g_LM:getMode("prop", var), td.LIGHT_BLUE, 20)
    label:setAnchorPoint(0.5, 0.5)
    label:setPosition(vPos[i])
    label:addTo(self.m_panel_attr)
  end
  self.m_shangZhenBtn = cc.uiloader:seekNodeByName(self.m_Image_part1, "Button_fight")
  self.m_weaponBtn = cc.uiloader:seekNodeByName(self.m_panel_item, "Button_weapon")
  td.CreateUIEffect(self.m_weaponBtn, "Spine/UI_effect/UI_tishikeyong_01", {loop = true, scale = 0.86})
  self.m_fangjuBtn = cc.uiloader:seekNodeByName(self.m_panel_item, "Button_armor")
  td.CreateUIEffect(self.m_fangjuBtn, "Spine/UI_effect/UI_tishikeyong_01", {loop = true, scale = 0.86})
  self.btnUpgrade = cc.uiloader:seekNodeByName(self.m_panel_exp, "Button_up_3")
  self.btnEvo = cc.uiloader:seekNodeByName(self.m_panel_exp, "Button_evo_1")
  td.BtnSetTitle(self.btnEvo, g_LM:getBy("a00079"))
  local txt = cc.uiloader:seekNodeByName(self.m_panel_skill, "Text_passive")
  txt:setString(g_LM:getBy("a00071"))
  txt = cc.uiloader:seekNodeByName(self.m_panel_skill, "Text_active")
  txt:setString(g_LM:getBy("a00072"))
  txt = cc.uiloader:seekNodeByName(self.m_panel_gem, "Text_atk")
  txt:setString(g_LM:getBy("a00238"))
  txt = cc.uiloader:seekNodeByName(self.m_panel_gem, "Text_def")
  txt:setString(g_LM:getBy("a00239"))
  txt = cc.uiloader:seekNodeByName(self.m_panel_attr, "Text_attr")
  txt:setString(g_LM:getBy("a00247"))
  self:PrepareEnterAni()
end
function HeroInfoNewDlg:PrepareEnterAni()
  self.m_panel_attr:setPositionY(-200)
  self.m_Image_part2:setPositionY(-550)
  self.m_Image_part1:setPositionY(-300)
  self.m_panel_exp:setPositionY(-150)
  self.m_list_bg:setPositionX(-200)
end
function HeroInfoNewDlg:PlayEnterAni(cb)
  self.m_panel_attr:runAction(cca.seq({
    cca.moveTo(0.2, 846, 440),
    cca.moveTo(0.1, 846, 390),
    cca.moveTo(0.1, 846, 420)
  }))
  self.m_Image_part2:runAction(cca.seq({
    cca.delay(0.3),
    cca.moveTo(0.2, 846, 170),
    cca.moveTo(0.1, 846, 120),
    cca.moveTo(0.1, 846, 150)
  }))
  self.m_Image_part1:runAction(cca.seq({
    cca.delay(0.3),
    cc.EaseBackOut:create(cca.moveTo(0.4, 340, 80)),
    cca.cb(function()
      local heroIn = SkeletonUnit:create("Spine/UI_effect/UI_yingxiongchuxian_01")
      heroIn:setScale(0.75, 0.9)
      heroIn:pos(190, 170):addTo(self.m_Image_part1)
      heroIn:setLocalZOrder(99)
      heroIn:PlayAni("animation", false)
    end)
  }))
  local positions = {
    {x = 70, y = 190},
    {x = 275, y = 25},
    {x = 33, y = 230}
  }
  local laserEffects = {}
  self.m_heroPanel:runAction(cca.seq({
    cca.delay(1),
    cca.fadeIn(0.4, 1),
    cca.cb(function()
      for i = 1, 3 do
        local laserEffect = SkeletonUnit:create("Spine/UI_effect/UI_yingxiongtiao_0" .. i + 1)
        if i == 1 then
          laserEffect:pos(positions[i].x, positions[i].y):addTo(self.m_Image_part1)
        else
          laserEffect:pos(positions[i].x, positions[i].y):addTo(laserEffects[1])
        end
        table.insert(laserEffects, laserEffect)
        laserEffect:PlayAni("animation", false)
      end
    end),
    cca.delay(0.85),
    cca.cb(function()
      laserEffects = {}
      for i = 1, 3 do
        local laserEffect = SkeletonUnit:create("Spine/UI_effect/UI_yingxiongtiao_0" .. i + 1)
        if i == 1 then
          laserEffect:pos(positions[i].x, positions[i].y):addTo(self.m_Image_part1)
        else
          laserEffect:pos(positions[i].x, positions[i].y):addTo(laserEffects[1])
        end
        table.insert(laserEffects, laserEffect)
      end
      cb()
    end)
  }))
  self.m_list_bg:runAction(cca.seq({
    cca.delay(0.4),
    cc.EaseExponentialOut:create((cca.moveTo(0.4, 0, 275)))
  }))
  self.m_panel_exp:runAction(cca.seq({
    cca.delay(0.5),
    cc.EaseBackOut:create((cca.moveTo(0.3, 340, 30))),
    cca.cb(function()
      self:SetHeroItemSelect(1)
      self.m_UIListView:scrollAuto()
    end)
  }))
  G_SoundUtil:PlaySound(61)
end
function HeroInfoNewDlg:OnTabClicked(tabIndex)
  self.m_currTabIndex = tabIndex
  td.ShowRP(self.m_tabs[tabIndex], false)
  if tabIndex == 1 then
    self.m_panel_item:setVisible(true)
    self.m_panel_skill:setVisible(false)
    self.m_panel_gem:setVisible(false)
  elseif tabIndex == 2 then
    self.m_panel_item:setVisible(false)
    self.m_panel_skill:setVisible(true)
    self.m_panel_gem:setVisible(false)
  elseif tabIndex == 3 then
    self.m_panel_item:setVisible(false)
    self.m_panel_skill:setVisible(false)
    self.m_panel_gem:setVisible(true)
  end
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  return true
end
function HeroInfoNewDlg:InitTab()
  local tab1 = cc.uiloader:seekNodeByName(self.m_Image_part2, "Tab_item")
  local txtItem = cc.uiloader:seekNodeByName(tab1, "Text_item")
  txtItem:setString(g_LM:getBy("a00086"))
  local tab2 = cc.uiloader:seekNodeByName(self.m_Image_part2, "Tab_skill")
  local txtSkill = cc.uiloader:seekNodeByName(tab2, "Text_skill")
  txtSkill:setString(g_LM:getBy("a00118"))
  local tab3 = cc.uiloader:seekNodeByName(self.m_Image_part2, "Tab_gem")
  local txtGem = cc.uiloader:seekNodeByName(tab3, "Text_gem")
  txtGem:setString(g_LM:getBy("a00237"))
  self.m_tabs = {}
  self.m_tabs[1] = tab1
  self.m_tabs[2] = tab2
  self.m_tabs[3] = tab3
  local t1 = {
    tab = self.m_tabs[1],
    callfunc = handler(self, self.OnTabClicked),
    normalImageFile = "UI/button/tab1.png",
    highImageFile = "UI/button/tab2.png"
  }
  local t2 = {
    tab = self.m_tabs[2],
    callfunc = handler(self, self.OnTabClicked),
    normalImageFile = "UI/button/tab1.png",
    highImageFile = "UI/button/tab2.png"
  }
  local t3 = {
    tab = self.m_tabs[3],
    callfunc = handler(self, self.OnTabClicked),
    normalImageFile = "UI/button/tab1.png",
    highImageFile = "UI/button/tab2.png"
  }
  self.m_TabButton = TabButton.new({
    t1,
    t2,
    t3
  }, {
    autoSelectIndex = self.m_vEnterSubIndex[1]
  })
end
function HeroInfoNewDlg:InitBtnEvent()
  td.BtnAddTouch(self.m_shangZhenBtn, handler(self, self.OnBattleBtnClicked), nil, td.ButtonEffectType.Long)
  td.BtnAddTouch(self.m_weaponBtn, function()
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    local _heroData = self.m_vHeroData[self.m_curHeroIndex]
    g_MC:OpenModule(td.UIModule.WeaponUpgrade, {
      heroData = _heroData,
      type = td.WeaponType.Weapon,
      weaponId = _heroData.attackSite
    })
  end)
  td.BtnAddTouch(self.m_fangjuBtn, function()
    local _heroData = self.m_vHeroData[self.m_curHeroIndex]
    g_MC:OpenModule(td.UIModule.WeaponUpgrade, {
      heroData = _heroData,
      type = td.WeaponType.Armor,
      weaponId = _heroData.defSite
    })
  end)
  td.BtnAddTouch(self.btnUpgrade, function()
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    local uid = self.m_vHeroData[self.m_curHeroIndex].id
    if uid == 0 then
      local curItem = self.m_vHeroItems[self.m_curHeroIndex]
      local iconPos = curItem:getParent():convertToWorldSpace(cc.p(curItem:getPosition()))
      self:ShowBuyHeroDlg(self.m_vHeroData[self.m_curHeroIndex].hid, iconPos)
    else
      g_MC:OpenModule(td.UIModule.UpgradeHeroOrSoldier, {type = 1, id = uid})
    end
  end)
  td.BtnAddTouch(self.btnEvo, function()
    local dlg = require("app.layers.MainMenuUI.HeroEvoDlg").new(self.m_vHeroData[self.m_curHeroIndex])
    td.popView(dlg)
  end)
  for i = 1, 5 do
    do
      local skillButton = cc.uiloader:seekNodeByName(self.m_Image_part2, "Button_skill" .. i)
      table.insert(self.m_skillBtns, skillButton)
      td.BtnAddTouch(skillButton, function()
        td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
        if self.m_currTabIndex == 2 then
          local data = {
            skillData = self.m_vSkillData[i]
          }
          g_MC:OpenModule(td.UIModule.HeroSkill, data)
        end
      end)
    end
  end
  for i = 1, 4 do
    do
      local gemButton = cc.uiloader:seekNodeByName(self.m_Image_part2, "Button_gem" .. i)
      table.insert(self.m_gemBtns, gemButton)
      td.BtnAddTouch(gemButton, function()
        if self.m_currTabIndex == 3 then
          local _heroData = self.m_vHeroData[self.m_curHeroIndex]
          if not _heroData.id then
            return
          end
          if self.m_vGemData[i].unlock then
            g_MC:OpenModule(td.UIModule.Gem, {heroData = _heroData, slotId = i})
          else
            td.alert(string.format(g_LM:getMode("tipmsg", td.ErrorCode.HERO_LEVEL_LOW), self.m_vGemData[i].unlockLevel), true)
          end
        end
      end)
    end
  end
end
function HeroInfoNewDlg:InitHeroList()
  for k, heroData in ipairs(self.m_vHeroData) do
    local item = self:CreateHeroItem(heroData)
    self.m_UIListView:addItem(item)
    table.insert(self.m_vHeroItems, item)
  end
  self.m_UIListView:reload()
end
function HeroInfoNewDlg:CreateHeroItem(heroData)
  local bUnlock = heroData.id ~= 0
  local parent = display.newSprite("UI/hero/touxiangkuang2.png")
  parent:setScale(self.m_scale)
  local heroIcon = heroData.heroInfo.head .. td.PNG_Suffix
  local heroSpri
  if bUnlock then
    heroSpri = display.newSprite(heroIcon)
  else
    heroSpri = display.newGraySprite(heroIcon)
  end
  heroSpri:setScale(0.8)
  td.AddRelaPos(parent, heroSpri)
  local borderSpr = display.newSprite("UI/hero/touxiangkuang1.png")
  td.AddRelaPos(parent, borderSpr)
  local borderSize = cc.size(heroSpri:getContentSize().width * 0.95, heroSpri:getContentSize().height * 0.95)
  local selectBorderSpr = display.newScale9Sprite("UI/hero/huangse_xuanzhongkuang.png", 0, 0, borderSize)
  selectBorderSpr:setTag(ListItemTag.SelectBorder)
  selectBorderSpr:setVisible(false)
  td.AddRelaPos(parent, selectBorderSpr, 1, cc.p(0.49, 0.52))
  local szBorderSpr = display.newSprite("UI/hero/shangzhenbiaoji.png")
  parent:addChild(szBorderSpr, 2)
  szBorderSpr:setTag(ListItemTag.SZBorder)
  szBorderSpr:setPosition(cc.p(15, 10))
  if 0 == heroData.battle then
    szBorderSpr:setVisible(false)
  end
  local szOrderLabel = td.CreateLabel("" .. heroData.battle, nil, 16)
  szOrderLabel:setAnchorPoint(0.5, 0.5)
  szOrderLabel:setTag(ListItemTag.SZLabel)
  td.AddRelaPos(szBorderSpr, szOrderLabel)
  local item = self.m_UIListView:newItem(parent)
  local size = parent:getContentSize()
  item:setItemSize(size.width * self.m_scale, (size.height + 30) * self.m_scale)
  return item
end
function HeroInfoNewDlg:ShowBuyHeroDlg(id, iconPos)
  local pDlg = require("app.layers.MainMenuUI.HeroUnlockDlg").new(id, iconPos)
  td.popView(pDlg, true)
end
function HeroInfoNewDlg:SetHeroItemSelect(index)
  if self.m_curHeroIndex and self.m_curHeroIndex == index then
    return
  end
  if self.m_curHeroIndex then
    local tmpNode = self.m_vHeroItems[self.m_curHeroIndex]:getChildByTag(ListItemTag.BG)
    tmpNode:setScale(self.m_scale)
    tmpNode:getChildByTag(ListItemTag.SelectBorder):setVisible(false)
  end
  self.m_curHeroIndex = index
  local tmpNode = self.m_vHeroItems[self.m_curHeroIndex]:getChildByTag(ListItemTag.BG)
  tmpNode:setScale(1.15 * self.m_scale)
  tmpNode:getChildByTag(ListItemTag.SelectBorder):setVisible(true)
  self:RefreshHeroDetail()
end
function HeroInfoNewDlg:RefreshHeroDetail()
  local heroData = self.m_vHeroData[self.m_curHeroIndex]
  self.m_bUnlock = heroData.id ~= 0
  self:RemoveAllTmpNode()
  self.m_soundConfig = GetHeroSoundConfig(heroData.hid)
  self.m_curHeroLevel = heroData.level
  if self.m_heroSkeleton then
    self.m_heroSkeleton:removeFromParent()
    self.m_heroSkeleton = nil
  end
  self.m_heroSkeleton = SkeletonUnit:create(heroData.heroInfo.image)
  self.m_heroSkeleton:PlayAni("stand")
  local spineScale = heroData.heroInfo.scale * 1.5
  self.m_heroSkeleton:scale(spineScale, spineScale):pos(190, 90):addTo(self.m_heroPanel)
  local heroName = heroData.heroInfo.name
  self.m_hero_name:setString(heroName)
  local heroPower = math.floor(self.m_stiMng:CalculateHeroPower(heroData))
  self.m_hero_power:setString(g_LM:getBy("a00032") .. ": " .. heroPower)
  local heroRating = heroData.heroInfo.rate
  self.m_hero_rating:loadTexture(td.RATING_ICON[heroRating])
  local heroLevel = heroData.level
  self.m_levelLabel:setString("LV." .. heroLevel)
  local curExp, maxExp = heroData.exp, td.CalHeroExp(heroData.level)
  local curPercent = self.m_expPgBar:getPercentage()
  local time = math.abs(curPercent / 100 - curExp / maxExp)
  self.m_expPgBar:runAction(cc.EaseBackOut:create(cca.progressTo(time, curExp / maxExp * 100)))
  self.m_expLabel:setString(string.format("%d/%d", curExp, maxExp))
  if 0 == heroData.battle then
    self.m_shangZhenBtn:loadTextures("UI/button/shangzhen1_button.png", "UI/button/shangzhen2_button.png")
  else
    self.m_shangZhenBtn:loadTextures("UI/button/xiazhen1_button.png", "UI/button/xiazhen2_button.png")
  end
  local heroInfo = self.m_stiMng:GetHeroFinalInfo(heroData)
  local addInfo = self:CalculateSkillAddition(heroInfo)
  local properties = {
    heroInfo.property[td.Property.HP].value + addInfo[td.Property.HP],
    heroInfo.property[td.Property.Atk].value + addInfo[td.Property.Atk],
    heroInfo.property[td.Property.Def].value + addInfo[td.Property.Def],
    math.floor(60 / (heroInfo.property[td.Property.AtkSp].value + addInfo[td.Property.AtkSp])),
    heroInfo.property[td.Property.Crit].value,
    heroInfo.property[td.Property.Dodge].value
  }
  for i, txtValue in ipairs(properties) do
    local str = tostring(math.ceil(txtValue))
    if i > 4 then
      str = str .. "%"
    end
    local pLabelValue = td.CreateLabel(str, td.YELLOW, 20)
    pLabelValue:setAnchorPoint(cc.p(0, 0.5))
    self.m_panel_attr:addChild(pLabelValue)
    pLabelValue:setPosition(90 + (i - 1) % 3 * 150, 110 - math.floor((i - 1) / 3) * 60)
    table.insert(self.m_vTmpNodes, pLabelValue)
  end
  self:RefreshHeroWeapon(heroData)
  self:RefreshHeroSkills(heroData)
  self:RefreshHeroGems(heroData)
  self.m_shangZhenBtn:setDisable(not self.m_bUnlock)
  self.m_weaponBtn:setDisable(not self.m_bUnlock)
  self.m_fangjuBtn:setDisable(not self.m_bUnlock)
  if self.m_bUnlock then
    if heroData.level >= heroData.star * 10 then
      if heroData.star >= heroData.quality then
        td.BtnSetTitle(self.btnUpgrade, g_LM:getBy("a00255"))
      else
        td.BtnSetTitle(self.btnUpgrade, g_LM:getBy("a00257"))
      end
      td.ShowRP(self.btnUpgrade, false)
      self.btnUpgrade:setDisable(true)
    else
      td.BtnSetTitle(self.btnUpgrade, g_LM:getBy("a00025"))
      self.btnUpgrade:setDisable(false)
      if not self.m_bUnlock or self.m_udMng:IsHeroCanUpgrade(heroData.id) then
        local rp = SkeletonUnit:create("Spine/UI_effect/UI_shengjitishi_02")
        rp:PlayAni("animation")
        td.ShowRP(self.btnUpgrade, true, cc.p(0.5, 0.5), rp)
      else
        td.ShowRP(self.btnUpgrade, false)
      end
    end
    self.btnEvo:setDisable(false)
  else
    self.m_heroSkeleton:setColor(td.BTN_PRESSED_COLOR)
    td.BtnSetTitle(self.btnUpgrade, g_LM:getBy("a00256"))
    td.ShowRP(self.btnUpgrade, false)
    self.btnUpgrade:setDisable(false)
    self.btnEvo:setDisable(true)
  end
  self:RefreshStars(heroData, refreshType)
end
function HeroInfoNewDlg:RefreshHeroSkills(heroData)
  local inFunc6 = function(data)
    local parent = data.parent
    local iconSpr = td.CreateSkillIcon(data.id, data.star, data.quality)
    iconSpr:setScale(0.6)
    parent:getChildByTag(1):removeAllChildren()
    parent:getChildByTag(1):addChild(iconSpr)
    if not data.unlock then
      iconSpr:setColor(td.BTN_PRESSED_COLOR)
      local lockSpr = display.newSprite("UI/common/suo_icon2.png")
      parent:getChildByTag(1):addChild(lockSpr)
    end
  end
  local skillsLib = UserDataManager:GetInstance():GetSkillLib()
  self.m_vSkillData = {}
  for i = 1, 3 do
    local bUnlock, level = td.IsHeroSkillUnlock(heroData.level, false, i)
    local skillBtn = cc.uiloader:seekNodeByName(self.m_Image_part2, "Button_skill" .. i)
    local skillData
    if self.m_bUnlock then
      skillData = skillsLib[heroData.passiveSkill[i]]
    else
      skillData = self.m_skiMng:MakeSkillData({
        id = 0,
        skill_id = heroData.heroInfo.basic_skill[i],
        star = 1
      }, true)
      bUnlock = false
    end
    local skillInfo = skillData.skillInfo
    inFunc6({
      parent = skillBtn,
      id = skillInfo.id,
      star = skillData.star,
      quality = skillData.quality,
      unlock = bUnlock
    })
    table.insert(self.m_vSkillData, {
      skillUid = skillData.id,
      skillId = skillInfo.id,
      isActive = false,
      unlock = bUnlock,
      unlockLevel = level
    })
  end
  for i = 1, 2 do
    local bUnlock, level = td.IsHeroSkillUnlock(heroData.level, true, i)
    local skillBtn = cc.uiloader:seekNodeByName(self.m_Image_part2, "Button_skill" .. i + 3)
    local skillData
    if self.m_bUnlock then
      skillData = skillsLib[heroData.activeSkill[i]]
    else
      skillData = self.m_skiMng:MakeSkillData({
        id = 0,
        skill_id = heroData.heroInfo.basic_skill[3 + i],
        star = 1
      }, true)
      bUnlock = false
    end
    local skillInfo = skillData.skillInfo
    inFunc6({
      parent = skillBtn,
      id = skillInfo.id,
      star = skillData.star,
      quality = skillData.quality,
      unlock = bUnlock
    })
    table.insert(self.m_vSkillData, {
      skillUid = skillData.id,
      skillId = skillInfo.id,
      isActive = true,
      unlock = bUnlock,
      unlockLevel = level
    })
  end
end
function HeroInfoNewDlg:RefreshHeroWeapon(heroData)
  if self.m_bUnlock and self.m_udMng:CanEquipNewWeapon(heroData.id) and self.m_currTabIndex ~= 1 then
    td.ShowRP(self.m_tabs[1], true)
  else
    td.ShowRP(self.m_tabs[1], false)
  end
  local function inFunc1(data)
    local btn = data.btn
    btn:removeAllChildren()
    if data.img then
      local spri = td.IconWithStar(data.img, data.star, data.quality)
      spri:setScale(0.8)
      td.AddRelaPos(btn, spri)
      local pTmpLabel = td.CreateLabel("LV." .. data.lv, nil, 18, td.OL_BLACK)
      td.AddRelaPos(spri, pTmpLabel, 1, cc.p(0.5, -0.1))
    else
      local spri = td.IconWithStar("UI/hero/jia_icon.png", 0, 0)
      spri:setScale(0.85)
      td.AddRelaPos(btn, spri)
    end
    if self.m_bUnlock then
      td.CreateUIEffect(btn, "Spine/UI_effect/UI_tishikeyong_01", {
        loop = true,
        scale = 0.76,
        zorder = -1
      })
    end
  end
  local weaponData = self.m_udMng:GetWeaponData(heroData.attackSite)
  if not weaponData then
    inFunc1({
      btn = self.m_weaponBtn
    })
  else
    local weaponInfo = weaponData.weaponInfo
    local weaponFile = weaponInfo.icon .. td.PNG_Suffix
    inFunc1({
      btn = self.m_weaponBtn,
      img = weaponFile,
      lv = weaponData.level,
      star = weaponData.star,
      quality = weaponInfo.quality
    })
  end
  td.ShowRP(self.m_weaponBtn, self.m_udMng:CanEquipNewWeapon(heroData.id, td.WeaponType.Weapon))
  local weaponData = self.m_udMng:GetWeaponData(heroData.defSite)
  if not weaponData then
    inFunc1({
      btn = self.m_fangjuBtn
    })
  else
    local weaponInfo = weaponData.weaponInfo
    local weaponFile = weaponInfo.icon .. td.PNG_Suffix
    inFunc1({
      btn = self.m_fangjuBtn,
      img = weaponFile,
      lv = weaponData.level,
      star = weaponData.star,
      quality = weaponInfo.quality
    })
  end
  td.ShowRP(self.m_fangjuBtn, self.m_udMng:CanEquipNewWeapon(heroData.id, td.WeaponType.Armor))
end
function HeroInfoNewDlg:RefreshHeroGems(heroData)
  if self.m_bUnlock and self.m_udMng:CanEquipNewGem(heroData.id) and self.m_currTabIndex ~= 3 then
    td.ShowRP(self.m_tabs[3], true)
  else
    td.ShowRP(self.m_tabs[3], false)
  end
  local function inFunc(data)
    local iconSpr
    local gemData = self.m_udMng:GetGemData(data.id)
    if gemData then
      iconSpr = td.CreateItemIcon(gemData.gemstoneId, true)
      iconSpr:setScale(0.7)
    elseif data.unlock then
      iconSpr = td.IconWithStar("UI/hero/jia_icon.png", 0, 0)
      iconSpr:setScale(0.7)
    else
      iconSpr = td.IconWithStar("UI/common/suo_icon2.png", 0, 0)
      iconSpr:setScale(0.7)
    end
    local parent = data.parent
    parent:getChildByTag(1):removeAllChildren()
    parent:getChildByTag(1):addChild(iconSpr)
  end
  self.m_vGemData = {}
  for i, var in ipairs(heroData.gems) do
    local bUnlock, level = td.IsHeroGemUnlock(heroData.level, i)
    local gemBtn = cc.uiloader:seekNodeByName(self.m_panel_gem, "Button_gem" .. i)
    inFunc({
      parent = gemBtn,
      id = var,
      unlock = bUnlock
    })
    table.insert(self.m_vGemData, {
      slotIndex = i,
      unlock = bUnlock,
      unlockLevel = level
    })
    td.ShowRP(gemBtn, self.m_udMng:CanEquipNewGem(heroData.id, i), cc.p(1.1, 1.1))
  end
end
function HeroInfoNewDlg:RemoveAllTmpNode()
  for k, value in ipairs(self.m_vTmpNodes) do
    value:removeFromParent()
  end
  self.m_vTmpNodes = {}
end
function HeroInfoNewDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      return self.m_UIListView:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
    return false
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
    self.m_UIListView:onTouch_({
      name = "ended",
      x = touch:getLocation().x,
      y = touch:getLocation().y,
      prevX = touch:getPreviousLocation().x,
      prevY = touch:getPreviousLocation().y
    })
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.HERO_UPGRADE, handler(self, self.UpgradeCallback))
  self:AddCustomEvent(td.HERO_EVO, handler(self, self.EvoCallback))
  self:AddCustomEvent(td.HERO_WEAPON_UPGRADE, handler(self, self.RefreshHeroDetail))
  self:AddCustomEvent(td.HERO_SKILL_UPDATE, handler(self, self.RefreshHeroDetail))
  self:AddCustomEvent(td.HERO_GEM_UPDATE, handler(self, self.RefreshHeroDetail))
  self:AddCustomEvent(td.HERO_DATA_INITED, function()
    self:close()
    g_MC:OpenModule(td.UIModule.Hero)
  end)
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
function HeroInfoNewDlg:OnBattleBtnClicked()
  local heroData = self.m_vHeroData[self.m_curHeroIndex]
  if heroData.battle ~= 0 then
    if 0 < table.removebyvalue(self.m_vBattleHeroIndex, self.m_curHeroIndex) then
      for i, data in ipairs(self.m_vHeroData) do
        if data.battle > heroData.battle then
          data.battle = data.battle - 1
        end
      end
      heroData.battle = 0
      self.m_shangZhenBtn:loadTextures("UI/button/shangzhen1_button.png", "UI/button/shangzhen2_button.png")
    end
  else
    if #self.m_vBattleHeroIndex >= 3 then
      td.alert(g_LM:getBy("a00344"))
      return
    end
    table.insert(self.m_vBattleHeroIndex, self.m_curHeroIndex)
    heroData.battle = #self.m_vBattleHeroIndex
    self.m_shangZhenBtn:loadTextures("UI/button/xiazhen1_button.png", "UI/button/xiazhen2_button.png")
    self.m_heroSkeleton:PlayAni("skill_01", false)
    self.m_heroSkeleton:PlayAni("stand", true, true)
    if 1 < #self.m_soundConfig.magic then
      local randIndex = 1
      randIndex = math.random(#self.m_soundConfig.magic)
      G_SoundUtil:PlaySound(self.m_soundConfig.magic[randIndex], false)
    end
  end
  self:RefreshBattleOrder()
end
function HeroInfoNewDlg:RefreshBattleOrder()
  for i, data in ipairs(self.m_vHeroData) do
    local heroItem = self.m_vHeroItems[i]:getChildByTag(ListItemTag.BG)
    if 0 == data.battle then
      local bg = heroItem:getChildByTag(ListItemTag.SZBorder)
      bg:setVisible(false)
      bg:getChildByTag(ListItemTag.SZLabel):setString("")
    else
      local bg = heroItem:getChildByTag(ListItemTag.SZBorder)
      bg:setVisible(true)
      bg:getChildByTag(ListItemTag.SZLabel):setString(data.battle)
    end
  end
end
function HeroInfoNewDlg:RefreshStars(heroData, refreshType)
  for i, star in ipairs(self.m_stars) do
    star:stopAllActions()
    star:removeFromParent()
  end
  self.m_stars = {}
  for i = 1, 5 do
    do
      local starIcon = cc.uiloader:seekNodeByName(self.m_Image_part1, "Image_star" .. i)
      if i <= heroData.quality then
        starIcon:setVisible(true)
        if not refreshType then
          starIcon:loadTexture("UI/icon/xingxing2_icon.png")
          if i <= heroData.star then
            do
              local star = display.newSprite("UI/icon/xingxing_icon.png")
              star:setScale(3, 3)
              td.AddRelaPos(starIcon, star)
              star:setVisible(false)
              table.insert(self.m_stars, star)
              star:runAction(cca.seq({
                cca.delay((i - 1) * 0.15),
                cca.cb(function()
                  star:setVisible(true)
                end),
                cca.scaleTo(0.1, 1.2)
              }))
            end
          end
        elseif refreshType == RefreshType.Evo then
          starIcon:loadTexture("UI/icon/xingxing2_icon.png")
          if i <= heroData.star - 1 then
            local star = display.newSprite("UI/icon/xingxing_icon.png")
            star:setScale(1.2)
            td.AddRelaPos(starIcon, star)
          elseif i == heroData.star then
            do
              local starEffect = td.CreateUIEffect(starIcon, "Spine/UI_effect/UI_jiesuanxing_01", {scale = 0.5})
              starIcon:performWithDelay(function()
                starEffect:removeFromParent()
                local star = display.newSprite("UI/icon/xingxing_icon.png")
                star:setScale(1.2)
                td.AddRelaPos(starIcon, star)
                table.insert(self.m_stars, star)
              end, 0.7)
            end
          end
        end
      else
        starIcon:setVisible(false)
      end
    end
  end
end
function HeroInfoNewDlg:CalculateSkillAddition(heroInfo)
  local addInfo = {
    [td.Property.HP] = 0,
    [td.Property.Atk] = 0,
    [td.Property.Def] = 0,
    [td.Property.AtkSp] = 0,
    [td.Property.Speed] = 0,
    [td.Property.Crit] = 0,
    [td.Property.Dodge] = 0
  }
  local biMng = require("app.info.BuffInfoManager"):GetInstance()
  for i, skillid in ipairs(heroInfo.skill) do
    local skillInfo = self.m_skiMng:GetInfo(skillid)
    if skillInfo and skillInfo.type == td.SkillType.BuffPassive then
      for j, buffId in ipairs(skillInfo.get_buff_id) do
        local buffInfo = biMng:GetInfo(buffId)
        local propertyType, addValue
        if buffInfo.type == td.BuffType.AtkAdd then
          propertyType = td.Property.Atk
          addValue = heroInfo.property[propertyType].value * math.abs(buffInfo.value[1]) / 100
        elseif buffInfo.type == td.BuffType.HpMaxAdd then
          propertyType = td.Property.HP
          addValue = heroInfo.property[propertyType].value * math.abs(buffInfo.value[1]) / 100
        elseif buffInfo.type == td.BuffType.DefAdd then
          propertyType = td.Property.Def
          addValue = heroInfo.property[propertyType].value * math.abs(buffInfo.value[1]) / 100
        elseif buffInfo.type == td.BuffType.AtkSpVary_P then
          propertyType = td.Property.AtkSp
          addValue = heroInfo.property[propertyType].value * (-buffInfo.value[1] / 100)
        elseif buffInfo.type == td.BuffType.SpVary_P then
          propertyType = td.Property.Speed
          addValue = heroInfo.property[propertyType].value * buffInfo.value[1] / 100
        end
        if propertyType and addValue then
          addInfo[propertyType] = addInfo[propertyType] + addValue
        end
      end
    end
  end
  return addInfo
end
function HeroInfoNewDlg:SendBattleHeroRequest()
  local bChange = false
  if #self.m_vBattleHeroIndex ~= #self.m_vOriBattleHeroIndex then
    bChange = true
  else
    for i, var in ipairs(self.m_vBattleHeroIndex) do
      if var ~= self.m_vOriBattleHeroIndex[i] then
        bChange = true
        break
      end
    end
  end
  if bChange then
    local data = {}
    for i, index in ipairs(self.m_vBattleHeroIndex) do
      table.insert(data, self.m_vHeroData[index].hid)
    end
    self.m_stiMng:SendBattleHeroRequest(data)
  end
end
function HeroInfoNewDlg:UpgradeCallback(event)
  local heroData = self.m_vHeroData[self.m_curHeroIndex]
  local curExp, maxExp = heroData.exp, td.CalHeroExp(heroData.level)
  local curLevel = self.m_curHeroLevel
  td.ProgressTo(self.m_expPgBar, (curExp / maxExp + heroData.level - self.m_curHeroLevel) * 100, function()
    self:RefreshHeroDetail()
  end, function()
    curLevel = curLevel + 1
    self.m_levelLabel:setString("LV." .. curLevel)
    td.CreateUIEffect(self.m_Image_part1, "Spine/UI_effect/UI_shengji_01")
  end)
  G_SoundUtil:PlaySound(55, false)
end
function HeroInfoNewDlg:EvoCallback(event)
  self:RefreshHeroDetail()
end
return HeroInfoNewDlg
