local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local PokedexInfoManager = require("app.info.PokedexInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local TabButton = require("app.widgets.TabButton")
local scheduler = require("framework.scheduler")
local TujianDlg = class("TujianDlg", BaseDlg)
local PageItemCount = 15
local PageColumn = 5
local PageRow = 3
local tabTexts = {
  g_LM:getBy("a00413"),
  "BOSS",
  g_LM:getBy("a00118"),
  g_LM:getBy("a00086")
}
function TujianDlg:ctor()
  TujianDlg.super.ctor(self, 255, true)
  self:setNodeEventEnabled(true)
  self.m_vMonsterInfo = {}
  self.m_vBossInfo = {}
  self.m_vWeaponInfo = {}
  self.m_vSkillInfo = {}
  self.m_infos = {
    [1] = self.m_vMonsterInfo,
    [3] = self.m_vSkillInfo,
    [4] = self.m_vWeaponInfo
  }
  self.m_vSkillLabel = {}
  self.m_iTabIndex = 1
  self.m_iLoadCount = 0
  self.m_lastPageIndex = 1
  self.m_totalPageCnt = 0
  self.m_uiItems = {}
  self.m_curSelectItemIndex = 1
  self.m_targetId = 0
  self.m_bossLaserEffects = {}
  self.m_uiId = td.UIModule.Pokedex
  self:InitData()
  self:InitUI()
end
function TujianDlg:onEnter()
  TujianDlg.super.onEnter(self)
end
function TujianDlg:onExit()
  TujianDlg.super.onExit(self)
  cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
function TujianDlg:PlayEnterAnim()
  local panelDeco = cc.uiloader:seekNodeByName(self.m_bg, "Panel_decorations")
  local btmLight = cc.uiloader:seekNodeByName(panelDeco, "Image_btmLight")
  self.itemCount = 0
  local function bgFadeIn()
    self.m_list_bg:runAction(cca.seq({
      cca.cb(function()
        self:CreateTabs()
        self:InitMonsterUI()
        self:InitBossUI()
        self:AddEvents()
      end),
      cca.fadeIn(0.2, 1)
    }))
  end
  btmLight:runAction(cca.seq({
    cc.EaseBackOut:create(cca.moveTo(0.4, 450, 9)),
    cca.cb(handler(self, bgFadeIn))
  }))
  self.pedestal = SkeletonUnit:create("Spine/UI_effect/UI_tujian_01")
  self.pedestal:pos(300, 240):addTo(self.m_panel_boss)
  self.pedestal:setLocalZOrder(-1)
  self.pedestal:PlayAni("animation", true)
  local clipNode = cc.ClippingNode:create()
  clipNode:setInverted(false)
  clipNode:addTo(self.m_panel_boss)
  local stencil = display.newNode()
  local sprStencil = display.newRect(cc.rect(190, 55, 400, 400))
  stencil:addChild(sprStencil)
  stencil:pos(0, 0)
  clipNode:setStencil(stencil)
  local transforms = {
    {
      x = 310,
      y = 110,
      scaleX = 1,
      scaleY = 1
    },
    {
      x = 390,
      y = 160,
      scaleX = 1,
      scaleY = 1
    },
    {
      x = 350,
      y = 360,
      scaleX = 1,
      scaleY = -1
    }
  }
  for i = 1, 3 do
    local laser = SkeletonUnit:create("Spine/UI_effect/UI_tujian_02")
    laser:setScale(transforms[i].scaleX, transforms[i].scaleY)
    laser:pos(transforms[i].x, transforms[i].y):addTo(clipNode)
    table.insert(self.m_bossLaserEffects, laser)
  end
end
function TujianDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    self.m_moveDis = 0
    if self.m_iTabIndex == 2 then
      if self.m_bossPage:isTouchInViewRect_({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        return self.m_bossPage:onTouch_({
          name = "began",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
      end
    elseif 0 < self.m_page:getPageCount() then
      if self.m_page:isTouchInViewRect_({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        return self.m_page:onTouch_({
          name = "began",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
      end
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    self.m_moveDis = self.m_moveDis + math.abs(touch:getPreviousLocation().x - touch:getLocation().x)
    if self.m_moveDis < 20 then
      return
    end
    if self.m_iTabIndex == 2 then
      if self.m_bossPage:isTouchInViewRect_({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.m_bossPage:onTouch_({
          name = "moved",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
      end
    elseif self.m_page:getPageCount() > 0 then
      if self.m_page:isTouchInViewRect_({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.m_page:onTouch_({
          name = "moved",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
      end
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    self.m_moveDis = 0
    if self.m_iTabIndex == 2 then
      self.m_bossPage:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    elseif 0 < self.m_page:getPageCount() then
      self.m_page:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function TujianDlg:InitData()
  local allMonsterInfo = ActorInfoManager:GetInstance():GetMonsterInfos()
  local key_table = {}
  for key, _ in pairs(allMonsterInfo) do
    table.insert(key_table, key)
  end
  table.sort(key_table)
  for i, key in ipairs(key_table) do
    local info = allMonsterInfo[key]
    if info.show == 1 then
      if info.monster_type == td.MonsterType.BOSS or info.monster_type == td.MonsterType.DeputyBoss then
        table.insert(self.m_vBossInfo, info)
      else
        table.insert(self.m_vMonsterInfo, info)
      end
    end
  end
  local allWeaponInfo = StrongInfoManager:GetInstance():GetWeaponInfo()
  for key, var in pairs(allWeaponInfo) do
    table.insert(self.m_vWeaponInfo, var)
  end
  table.sort(self.m_vWeaponInfo, function(a, b)
    if a.quality == b.quality then
      return a.id < b.id
    end
    return a.quality < b.quality
  end)
  local allSkillInfo = SkillInfoManager:GetInstance():GetHeroSkillInfo()
  for key, var in pairs(allSkillInfo) do
    table.insert(self.m_vSkillInfo, var)
  end
  table.sort(self.m_vSkillInfo, function(a, b)
    if a.quality == b.quality then
      return a.id < b.id
    end
    return a.quality < b.quality
  end)
end
function TujianDlg:InitUI()
  self:LoadUI("CCS/TuJianDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_guaiwutujian.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_list_bg = cc.uiloader:seekNodeByName(self.m_bg, "list_bg")
  self.m_panelLeft = cc.uiloader:seekNodeByName(self.m_bg, "Panel_left")
  self.m_panels = {}
  self.m_panel_monster = cc.uiloader:seekNodeByName(self.m_list_bg, "Panel_monster")
  table.insert(self.m_panels, self.m_panel_monster)
  self.m_panel_boss = cc.uiloader:seekNodeByName(self.m_list_bg, "Panel_boss")
  table.insert(self.m_panels, self.m_panel_boss)
  self.m_leftArrow = cc.uiloader:seekNodeByName(self.m_panel_monster, "Arrow_left")
  self.m_rightArrow = cc.uiloader:seekNodeByName(self.m_panel_monster, "Arrow_right")
  self.m_pageTextLabel = td.CreateLabel("0/0", td.WHITE, 20)
  local tmpNode = cc.uiloader:seekNodeByName(self.m_panel_monster, "Image_page")
  self.m_pageTextLabel:setAnchorPoint(cc.p(0.5, 0.5))
  td.AddRelaPos(tmpNode, self.m_pageTextLabel)
  self:PlayEnterAnim()
end
function TujianDlg:CreateTabs()
  local tabButtons = {}
  for i = 1, 4 do
    local _tab = cc.uiloader:seekNodeByName(self.m_panelLeft, "tab" .. i)
    local tabSpine = SkeletonUnit:create("Spine/UI_effect/UI_tujiananniu_01")
    tabSpine:pos(_tab:getPositionX() - 1, _tab:getPositionY() + 37)
    tabSpine:addTo(self.m_panelLeft)
    tabSpine:setLocalZOrder(-1)
    local tabButton = {
      tab = _tab,
      callfunc = handler(self, self.UpdatePanels),
      normalImageSize = cc.size(162, 74),
      highImageSize = cc.size(210, 74),
      spine = tabSpine,
      text = tabTexts[i]
    }
    table.insert(tabButtons, tabButton)
  end
  local _spineInfo = {
    normalInit = "animation_01",
    focusInit = "animation_02",
    toFocus = "animation_03",
    toNormal = "animation_04",
    initTime = 0.5
  }
  local tabs = TabButton.new(tabButtons, {
    textSize = 24,
    normalTextColor = td.LIGHT_BLUE,
    highTextColor = td.YELLOW,
    spineInfo = _spineInfo
  })
end
function TujianDlg:UpdatePanels(index)
  if index == 2 then
    self.m_panels[1]:setVisible(false)
    self.m_panels[2]:setVisible(true)
    self.m_detailUI = cc.uiloader:seekNodeByName(self.m_panels[2], "detail_bg")
    self.pedestal:setOpacity(0)
    self.pedestal:runAction(cca.fadeIn(1, 1))
    for key, val in ipairs(self.m_bossLaserEffects) do
      val:PlayAni("animation", false)
    end
  else
    self.m_panels[1]:setVisible(true)
    self.m_panels[2]:setVisible(false)
    self.m_detailUI = cc.uiloader:seekNodeByName(self.m_panels[1], "detail_bg")
  end
  self.m_iTabIndex = index
  self.m_lastPageIndex = 1
  self.m_curSelectItemIndex = 1
  self:RefreshPageView(index)
end
function TujianDlg:InitMonsterUI()
  self.m_page = cc.ui.UIPageView.new({
    viewRect = cc.rect(0, 0, 600, 420),
    column = PageColumn,
    row = PageRow,
    columnSpace = 50,
    rowSpace = 6,
    padding = {
      left = 0,
      right = 40,
      top = 0,
      bottom = 40
    },
    scale = self.m_scale
  })
  self.m_page:setPosition(21, 25)
  self.m_panel_monster:addChild(self.m_page)
  self.m_page:onTouch(function(event)
    if event.name == "clicked" then
      self:setItemSelect(event.itemIdx)
    elseif event.name == "pageChange" then
      local curIndex = event.pageIdx
      if self.m_lastPageIndex and self.m_lastPageIndex ~= curIndex then
        self:setItemSelect((curIndex - 1) * PageItemCount + 1)
        self.m_pageTextLabel:setString(event.pageIdx .. "/" .. self.m_totalPageCnt)
        td.UpdatePageArrow({
          leftArrow = self.m_leftArrow,
          rightArrow = self.m_rightArrow,
          curPage = event.pageIdx,
          totalPage = self.m_totalPageCnt
        })
        self.m_lastPageIndex = event.pageIdx
        self:LoadItems()
      end
    end
  end)
end
function TujianDlg:InitBossUI()
  local wordSpr = td.CreateLabel(g_LM:getBy("a00118") .. ":", td.LIGHT_BLUE, 20)
  wordSpr:setAnchorPoint(0, 0.5)
  wordSpr:pos(610, 270):addTo(self.m_panel_boss)
  self.m_bossPage = cc.ui.UIPageView.new({
    viewRect = cc.rect(90, 30, 385, 370),
    column = 1,
    row = 1,
    columnSpace = 50,
    rowSpace = 0,
    padding = {
      left = 0,
      right = 40,
      top = 0,
      bottom = 40
    },
    scale = self.m_scale
  })
  self.m_panel_boss:addChild(self.m_bossPage)
  local lArrow = cc.uiloader:seekNodeByName(self.m_panel_boss, "Boss_arrowLeft")
  local rArrow = cc.uiloader:seekNodeByName(self.m_panel_boss, "Boss_arrowRight")
  self.m_bossPage:onTouch(function(event)
    if event.name == "pageChange" then
      self.m_pageTextLabel:setString(event.pageIdx .. "/" .. self.m_totalPageCnt)
      td.UpdatePageArrow({
        leftArrow = lArrow,
        rightArrow = rArrow,
        curPage = event.pageIdx,
        totalPage = self.m_totalPageCnt,
        activeSpr = "UI/button/jiantou2_icon.png",
        inactiveSpr = "UI/button/jiantou1_icon.png",
        playAni = true
      })
      self:RefreshBossDetailUI(event.pageIdx)
    end
  end)
end
function TujianDlg:RefreshPageView(index)
  self:ClearPageView(index)
  if index == 2 then
    self.m_totalPageCnt = #self.m_vBossInfo
    self:CreateBossItems()
    self:RefreshBossDetailUI(1)
    self.m_pageTextLabel:setString(tostring(self.m_bossPage:getCurPageIdx()) .. "/" .. self.m_totalPageCnt)
  else
    self.m_uiItems = {}
    self.m_iLoadCount = 0
    self.m_totalPageCnt = math.ceil(#self.m_infos[index] / PageItemCount)
    if index == 1 then
      self:CreateItems(2)
    elseif index == 3 then
      self:CreateSkillItems()
    elseif index == 4 then
      self:CreateWeaponItems()
    end
    self:setItemSelect(self.m_curSelectItemIndex)
    self.m_pageTextLabel:setString(tostring(self.m_page:getCurPageIdx()) .. "/" .. self.m_totalPageCnt)
  end
end
function TujianDlg:ClearPageView(index)
  if index == 2 then
    self.m_bossPage:removeAllItems()
  else
    self.m_iLoadCount = 0
    self.m_page:removeAllItems()
    self.m_uiItems = {}
    self.m_ItemCount = 1
  end
end
function TujianDlg:LoadItems()
  if self.m_iLoadCount < self.m_totalPageCnt and self.m_iTabIndex == 1 then
    self:CreateItems(1)
  end
end
function TujianDlg:CreateItems(pageCount)
  pageCount = cc.clampf(pageCount, 0, self.m_totalPageCnt - self.m_iLoadCount)
  for i = 1, PageItemCount * pageCount do
    local item = self.m_page:newItem()
    local listItem
    local info = self.m_vMonsterInfo[self.m_iLoadCount * PageItemCount + i]
    if info then
      local bIsUnlocked = PokedexInfoManager:GetInstance():IsUnlocked(td.PokedexType.Monster, info.id)
      listItem = self:MakeItem(info, bIsUnlocked)
    else
      listItem = self:MakeItem()
    end
    item:addChild(listItem)
    self.m_page:addItem(item)
    table.insert(self.m_uiItems, item)
  end
  self.m_iLoadCount = self.m_iLoadCount + pageCount
  self.m_page:reload(self.m_lastPageIndex)
end
function TujianDlg:CreateWeaponItems()
  for i = 1, PageItemCount * self.m_totalPageCnt do
    local item = self.m_page:newItem()
    local info = self.m_vWeaponInfo[self.m_iLoadCount * PageItemCount + i]
    local listItem = self:MakeWeaponItem(info)
    item:addChild(listItem)
    self.m_page:addItem(item)
    table.insert(self.m_uiItems, item)
  end
  self.m_iLoadCount = self.m_totalPageCnt
  self.m_page:reload(self.m_lastPageIndex)
end
function TujianDlg:CreateSkillItems()
  for i = 1, PageItemCount * self.m_totalPageCnt do
    local item = self.m_page:newItem()
    local info = self.m_vSkillInfo[self.m_iLoadCount * PageItemCount + i]
    local listItem = self:MakeSkillItem(info)
    item:addChild(listItem)
    self.m_page:addItem(item)
    table.insert(self.m_uiItems, item)
  end
  self.m_iLoadCount = self.m_totalPageCnt
  self.m_page:reload(self.m_lastPageIndex)
end
function TujianDlg:changePage(count, num, bLeftToRight)
  self.m_page:gotoPage(count, true, bLeftToRight)
end
function TujianDlg:MakeItem(info, bIsUnlocked)
  local listItembg
  if info and bIsUnlocked then
    listItembg = display.newSprite("UI/tujian/tujiankuang1.png")
    local skeleton = SkeletonUnit:create(info.image)
    skeleton:PlayAni("stand", true)
    skeleton:setScale(0.4 * info.scale)
    local ufoIds = {
      5400,
      5401,
      5402
    }
    if table.indexof(ufoIds, info.id) then
      td.AddRelaPos(listItembg, skeleton, 1, cc.p(0.5, 0.55))
      local bones = {"bone_eft", "bone_eft1"}
      for i = 1, 2 do
        local fire = SkeletonUnit:create("Spine/skill/EFT_penshe_01")
        skeleton:FindBoneNode(bones[i]):addChild(fire)
        fire:PlayAni("animation", true, false)
      end
      local shadow = display.newSprite("Effect/shadow.png")
      shadow:scale(1.5)
      td.AddRelaPos(listItembg, shadow, 1, cc.p(0.5, 0.2))
    else
      td.AddRelaPos(listItembg, skeleton, 1, cc.p(0.5, 0.2))
    end
  else
    listItembg = display.newGraySprite("UI/tujian/tujiankuang1.png")
    if info then
      local skeleton = display.newSprite("UI/common/suo_icon.png")
      td.AddRelaPos(listItembg, skeleton, 1, cc.p(0.5, 0.55))
    end
  end
  listItembg:setAnchorPoint(0, 0)
  listItembg:setName("item_bg")
  if self.itemCount <= PageColumn * PageRow then
    self.itemCount = self.itemCount + 1
  end
  return listItembg
end
function TujianDlg:MakeWeaponItem(info)
  local listItembg
  if info then
    listItembg = display.newSprite("UI/tujian/tujiankuang1.png")
    local icon = td.CreateWeaponIcon(info.id, info.quality, -20)
    icon:scale(0.6)
    td.AddRelaPos(listItembg, icon, 1, cc.p(0.5, 0.6))
  else
    listItembg = display.newGraySprite("UI/tujian/tujiankuang1.png")
  end
  listItembg:setAnchorPoint(0, 0)
  listItembg:setName("item_bg")
  if self.itemCount <= PageColumn * PageRow then
    self.itemCount = self.itemCount + 1
  end
  return listItembg
end
function TujianDlg:MakeSkillItem(info)
  local listItembg
  if info then
    listItembg = display.newSprite("UI/tujian/tujiankuang1.png")
    local icon = td.CreateSkillIcon(info.id, info.quality, info.quality, -20)
    icon:scale(0.6)
    td.AddRelaPos(listItembg, icon, 1, cc.p(0.5, 0.6))
  else
    listItembg = display.newGraySprite("UI/tujian/tujiankuang1.png")
  end
  listItembg:setAnchorPoint(0, 0)
  listItembg:setName("item_bg")
  if self.itemCount <= PageColumn * PageRow then
    self.itemCount = self.itemCount + 1
  end
  return listItembg
end
function TujianDlg:setItemSelect(index)
  if not self.m_infos[self.m_iTabIndex][index] then
    return
  end
  if self.m_curSelectItemIndex > 0 then
    self:setLightVisible(self.m_uiItems[self.m_curSelectItemIndex], false)
    self.m_curSelectItemIndex = 0
  end
  if index <= #self.m_uiItems then
    self.m_curSelectItemIndex = index
    self:setLightVisible(self.m_uiItems[self.m_curSelectItemIndex], true)
  end
  self:RefreshDetailUI(index)
end
function TujianDlg:setLightVisible(item, visible)
  if item then
    local bg = cc.uiloader:seekNodeByName(item, "item_bg")
    if visible then
      bg:setTexture("UI/tujian/tujiankuang2.png")
    else
      bg:setTexture("UI/tujian/tujiankuang1.png")
    end
  end
end
function TujianDlg:RefreshDetailUI(index)
  if self.m_iTabIndex == 1 then
    self:RefreshMonsterDetail(index)
  elseif self.m_iTabIndex == 3 then
    self:RefreshSkillDetail(index)
  elseif self.m_iTabIndex == 4 then
    self:RefreshWeaponDetail(index)
  end
end
function TujianDlg:RefreshMonsterDetail(index)
  self.m_detailUI:removeAllChildren()
  local titleStr, descStr, skillStr = "???", "???", "???"
  local proValues = {
    -1,
    -1,
    -1,
    -1
  }
  if self.m_vMonsterInfo and self.m_vMonsterInfo[index] then
    local info = self.m_vMonsterInfo[index]
    if PokedexInfoManager:GetInstance():IsUnlocked(td.PokedexType.Monster, info.id) then
      local iconImg = td.CreateCareerIcon(info.career)
      iconImg:scale(0.6)
      td.AddRelaPos(self.m_detailUI, iconImg, 1, cc.p(0.85, 0.92))
      titleStr = info.name
      descStr = info.desc
      skillStr = self:GetSkillStr(info.skill)
      proValues = {
        info.attack,
        info.hp,
        info.def,
        info.attack_speed
      }
    end
  end
  local labelTitle = td.CreateLabel(titleStr, td.YELLOW, 22, nil, nil, nil, true)
  labelTitle:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self.m_detailUI, labelTitle, 1, cc.p(0.1, 0.92))
  local labelDiscribe = td.CreateLabel(descStr, td.DARK_BLUE, 18, nil, nil, cc.size(230, 115))
  labelDiscribe:setPosition(20, 380)
  labelDiscribe:setAnchorPoint(cc.p(0, 1))
  self.m_detailUI:addChild(labelDiscribe)
  local vPos = {
    cc.p(20, 245),
    cc.p(150, 245),
    cc.p(20, 205),
    cc.p(150, 205)
  }
  for i, var in ipairs(proValues) do
    local label = td.GetPropertyStr(i, var)
    label:setAnchorPoint(0, 0.5)
    label:pos(vPos[i].x, vPos[i].y):addTo(self.m_detailUI)
  end
  local sLabel = td.CreateLabel(g_LM:getBy("a00118") .. ":", td.BLUE, 18, nil, nil)
  sLabel:setAnchorPoint(0, 1)
  sLabel:pos(20, 95):addTo(self.m_detailUI)
  local skillLabel = td.CreateLabel(skillStr, td.WHITE, 18, nil, nil, cc.size(140, 80))
  skillLabel:setAnchorPoint(0, 1)
  skillLabel:pos(80, 95):addTo(self.m_detailUI)
  local lineSpr = display.newSprite("UI/common/fengexian2.png")
  td.AddRelaPos(self.m_detailUI, lineSpr, 1, cc.p(0.5, 0.62))
end
function TujianDlg:RefreshSkillDetail(index)
  self.m_detailUI:removeAllChildren()
  local info = self.m_vSkillInfo[index]
  local skillData = SkillInfoManager:GetInstance():MakeSkillData({
    skill_id = info.id,
    star = info.quality
  }, true)
  local skillInfo = skillData.skillInfo
  local labelTitle = td.CreateLabel(skillInfo.name, td.YELLOW, 22, nil, nil, nil, true)
  labelTitle:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self.m_detailUI, labelTitle, 1, cc.p(0.07, 0.92))
  local typeStr = g_LM:getBy("a00071")
  if skillInfo.type == td.SkillType.FixedMagic or skillInfo.type == td.SkillType.RandomMagic then
    typeStr = g_LM:getBy("a00072")
    local cdLabel = td.CreateLabel("CD:" .. skillInfo.cd .. "\231\167\146", td.WHITE, 18)
    cdLabel:align(display.LEFT_CENTER, 150, 380):addTo(self.m_detailUI)
  end
  local sTypeLabel = td.CreateLabel(typeStr, td.WHITE, 18)
  sTypeLabel:align(display.LEFT_CENTER, 20, 380):addTo(self.m_detailUI)
  local lineSpr = display.newSprite("UI/common/fengexian2.png")
  td.AddRelaPos(self.m_detailUI, lineSpr, 1, cc.p(0.5, 0.8))
  local labelDiscribe = self:_GetSkillLabel(skillData)
  labelDiscribe:setPosition(20, 350)
  labelDiscribe:setAnchorPoint(cc.p(0, 1))
  self.m_detailUI:addChild(labelDiscribe)
end
function TujianDlg:_GetSkillLabel(skillData)
  local skillInfo = skillData.skillInfo
  local skillLevelInfo = SkillInfoManager:GetInstance():GetHeroSkillInfo(skillInfo.id)
  if skillLevelInfo then
    local skillContent = skillInfo.desc
    local variables = skillLevelInfo.variable[cc.clampf(skillData.star, 1, skillLevelInfo.quality)]
    for i, var in ipairs(variables) do
      skillContent = string.gsub(skillContent, "{" .. i .. "}", "#" .. var .. "#")
    end
    local textData = {}
    local vStr = string.split(skillContent, "#")
    for i, var in ipairs(vStr) do
      if i % 2 == 1 then
        table.insert(textData, {
          type = 1,
          color = td.BLUE,
          size = 18,
          str = var
        })
      else
        table.insert(textData, {
          type = 1,
          color = td.YELLOW,
          size = 18,
          str = var
        })
      end
    end
    return td.RichText(textData, cc.size(215, 115))
  else
    return td.CreateLabel(skillInfo.desc, td.BLUE, 18, nil, nil, cc.size(215, 115))
  end
end
function TujianDlg:RefreshWeaponDetail(index)
  self.m_detailUI:removeAllChildren()
  local info = self.m_vWeaponInfo[index]
  local labelTitle = td.CreateLabel(info.name, td.YELLOW, 22, nil, nil, nil, true)
  labelTitle:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self.m_detailUI, labelTitle, 1, cc.p(0.1, 0.92))
  local iconImg = td.CreateCareerIcon(info.career)
  iconImg:scale(0.6)
  td.AddRelaPos(self.m_detailUI, iconImg, 1, cc.p(0.85, 0.92))
  local labelDiscribe = td.CreateLabel(info.desc, td.DARK_BLUE, 18, nil, nil, cc.size(215, 115))
  labelDiscribe:setPosition(20, 380)
  labelDiscribe:setAnchorPoint(cc.p(0, 1))
  self.m_detailUI:addChild(labelDiscribe)
  local lineSpr = display.newSprite("UI/common/fengexian2.png")
  td.AddRelaPos(self.m_detailUI, lineSpr, 1, cc.p(0.5, 0.62))
  local weaponData = StrongInfoManager:GetInstance():MakeWeaponData({
    weaponId = info.id,
    level = info.quality * 5,
    star = info.quality
  })
  local vPos = {
    cc.p(20, 245),
    cc.p(150, 245),
    cc.p(20, 205),
    cc.p(150, 205)
  }
  local i = 1
  for type, value in pairs(weaponData.property) do
    local typeLabel, valLabel = td.GetWeaponPropLabel(type, value)
    typeLabel:setAnchorPoint(0, 0.5)
    typeLabel:pos(vPos[i].x, vPos[i].y):addTo(self.m_detailUI)
    valLabel:setAnchorPoint(0, 0.5)
    valLabel:pos(vPos[i].x + typeLabel:getContentSize().width + 5, vPos[i].y):addTo(self.m_detailUI)
    i = i + 1
  end
  local skillInfo = SkillInfoManager:GetInstance():GetInfo(info.skill)
  if skillInfo then
    local lineSpr = display.newSprite("UI/common/fengexian2.png")
    td.AddRelaPos(self.m_detailUI, lineSpr, 1, cc.p(0.5, 0.35))
    local sLabel = td.CreateLabel(g_LM:getBy("a00118") .. ":", td.BLUE, 18, nil, nil)
    sLabel:setAnchorPoint(0, 1)
    sLabel:pos(20, 190):addTo(self.m_detailUI)
    local icon = display.newSprite(skillInfo.icon .. td.PNG_Suffix)
    icon:align(display.LEFT_CENTER, 20, 120):scale(0.5):addTo(self.m_detailUI)
    local sNameLabel = td.CreateLabel(skillInfo.name, td.YELLOW, 18)
    sNameLabel:align(display.LEFT_CENTER, 85, 130):addTo(self.m_detailUI)
    local typeStr = g_LM:getBy("a00071")
    if skillInfo.type == td.SkillType.FixedMagic or skillInfo.type == td.SkillType.RandomMagic then
      typeStr = g_LM:getBy("a00072")
      local cdLabel = td.CreateLabel("CD:" .. skillInfo.cd .. "\231\167\146", td.WHITE, 16)
      cdLabel:align(display.LEFT_CENTER, 150, 105):addTo(self.m_detailUI)
    end
    local sTypeLabel = td.CreateLabel(typeStr, td.WHITE, 16)
    sTypeLabel:align(display.LEFT_CENTER, 85, 105):addTo(self.m_detailUI)
    local sDescLabel = td.CreateLabel(skillInfo.desc, td.DARK_BLUE, 16, nil, nil, cc.size(215, 120))
    sDescLabel:align(display.LEFT_TOP, 20, 90):addTo(self.m_detailUI)
  end
end
function TujianDlg:GetSkillStr(vSkill)
  local mng = SkillInfoManager:GetInstance()
  local str, count = "", 0
  for i, id in ipairs(vSkill) do
    local sInfo = mng:GetInfo(id)
    if sInfo.type ~= 0 then
      if count == 0 then
        str = str .. sInfo.name
      else
        str = str .. "," .. sInfo.name
      end
      count = count + 1
    end
  end
  if count == 0 then
    str = g_LM:getBy("a00151")
  end
  return str
end
function TujianDlg:CreateBossItems()
  for i, info in ipairs(self.m_vBossInfo) do
    local item = self.m_bossPage:newItem()
    local skeleton = SkeletonUnit:create(info.image)
    skeleton:PlayAni("stand", true)
    skeleton:scale(0.6 * info.scale):pos(210, 100)
    item:addChild(skeleton)
    self.m_bossPage:addItem(item)
  end
  self.m_bossPage:reload()
end
function TujianDlg:RefreshBossDetailUI(index)
  if not self.m_vBossInfo then
    self.m_detailUI:setVisible(false)
    return
  end
  local info = self.m_vBossInfo[index]
  self.m_detailUI:setVisible(true)
  if self.m_title then
    self.m_title:removeFromParent()
    self.m_title = nil
  end
  self.m_title = td.CreateLabel(info.name, td.YELLOW, 22, td.OL_BROWN, nil, nil, nil, true)
  self.m_title:setAnchorPoint(0.5, 0.5)
  td.AddRelaPos(self.m_detailUI, self.m_title, 1, cc.p(0.5, 0.93))
  if self.m_discribe then
    self.m_discribe:removeFromParent()
    self.m_discribe = nil
  end
  local discribe = td.CreateLabel(info.desc, cc.c3b(7, 168, 197), 18, nil, nil, cc.size(250, 115))
  self.m_discribe = discribe
  discribe:setPosition(25, 360)
  discribe:setAnchorPoint(cc.p(0, 1))
  self.m_detailUI:addChild(discribe)
  self:RefreshBossSkill(info.skill)
  local propertyBg = cc.uiloader:seekNodeByName(self.m_panel_boss, "property_bg")
  if self.m_properties then
    for i, var in ipairs(self.m_properties) do
      var:removeFromParent()
    end
  end
  self.m_properties = {}
  local values = {
    info.attack,
    info.hp,
    info.def,
    info.attack_speed
  }
  for i, var in ipairs(values) do
    local label = td.GetPropertyStr(i, var)
    label:setAnchorPoint(0, 0.5)
    td.AddRelaPos(propertyBg, label, 1, cc.p(-0.03 + (i - 1) * 0.28, 0.5))
    table.insert(self.m_properties, label)
  end
end
function TujianDlg:RefreshBossSkill(vSkill)
  local scrollView = cc.uiloader:seekNodeByName(self.m_panel_boss, "ScrollView")
  for i, var in ipairs(self.m_vSkillLabel) do
    var:removeFromParent()
  end
  self.m_vSkillLabel = {}
  local mng = SkillInfoManager:GetInstance()
  local height = 0
  for i, id in ipairs(vSkill) do
    local sInfo = mng:GetInfo(id)
    if sInfo.type ~= 0 then
      local namelabel = td.CreateLabel(sInfo.name, td.GREEN, 18)
      namelabel:setAnchorPoint(0, 1)
      height = height + namelabel:getContentSize().height
      table.insert(self.m_vSkillLabel, namelabel)
      local descLabel = td.CreateLabel(sInfo.desc, cc.c3b(7, 168, 197), 18, nil, nil, cc.size(250, 0))
      descLabel:setAnchorPoint(0, 1)
      height = height + descLabel:getContentSize().height
      table.insert(self.m_vSkillLabel, descLabel)
    end
  end
  if #self.m_vSkillLabel == 0 then
    table.insert(self.m_vSkillLabel, td.CreateLabel(g_LM:getBy("a00151"), td.LIGHT_GREEN, 18))
  end
  height = math.max(160, height)
  local y = height
  for i, var in ipairs(self.m_vSkillLabel) do
    var:pos(0, y):addTo(scrollView)
    y = y - var:getContentSize().height
  end
  scrollView:setInnerContainerSize(cc.size(250, height))
end
return TujianDlg
