local CommanderInfoManager = require("app.info.CommanderInfoManager")
local UserDataManager = require("app.UserDataManager")
local GameDataManager = require("app.GameDataManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local RobSettingDlg = class("RobSettingDlg", BaseDlg)
function RobSettingDlg:ctor()
  RobSettingDlg.super.ctor(self)
  self.m_uiId = td.UIModule.RobSetting
  self.m_udMng = UserDataManager:GetInstance()
  self.m_list = nil
  self.m_robType = td.RobType.Gold
  self.m_itemId = td.ItemID_Gold
  self.m_currIndex = 0
  self.m_currPanel = 0
  self.m_heroPanels = {}
  self.m_heroSpines = {}
  self.m_battleHeroIds = {
    0,
    0,
    0
  }
  self:SetData()
  self:InitUI()
end
function RobSettingDlg:SetData()
  self.m_heroes = {}
  local allHero = table.keys(ActorInfoManager:GetInstance():GetHeroInfos())
  local heroData = clone(UserDataManager:GetInstance():GetHeroData())
  for id, hero in pairs(heroData) do
    local heroInfo = ActorInfoManager:GetInstance():GetHeroInfo(hero.hid)
    local info = {
      hid = hero.hid,
      name = heroInfo.name,
      head = heroInfo.head,
      image = heroInfo.image,
      scale = heroInfo.scale,
      isUnlock = true
    }
    local index = table.indexof(allHero, math.floor(hero.hid / 100) * 100)
    table.remove(allHero, index)
    table.insert(self.m_heroes, info)
  end
  for key, lockedHero in ipairs(allHero) do
    local info = ActorInfoManager:GetInstance():GetHeroInfo(lockedHero)
    local lockedInfo = {
      hid = lockedHero,
      name = info.name,
      head = info.head,
      image = info.image,
      scale = info.scale,
      isUnlock = false
    }
    table.insert(self.m_heroes, lockedInfo)
  end
end
function RobSettingDlg:GetMyHeroes(data)
  for key, val in pairs(data) do
    local panel = val.plunder_battle
    if panel > 0 then
      self.m_battleHeroIds[panel] = val.hid
      for i, heroInfo in ipairs(self.m_heroes) do
        if val.hid == heroInfo.hid then
          self:CreateBattleHero(panel, i)
        end
      end
    end
  end
end
function RobSettingDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/RobDetailDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self:SetTitle(td.Word_Path .. "wenzi_shezhifangshouyingxiong.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  for i = 1, 3 do
    local panel = cc.uiloader:seekNodeByName(self.m_bg, "Panel_hero" .. i)
    local heroNode = panel:getChildByName("Node_hero")
    table.insert(self.m_heroPanels, panel)
    local selText = td.CreateLabel(g_LM:getBy("a00013"), td.WHITE, 22, td.OL_BLACK)
    selText:pos(0, -35):addTo(heroNode)
  end
  self.m_herosBg = SkeletonUnit:create("Spine/UI_effect/UI_bingyingxuanze_01")
  td.AddRelaPos(self.m_bg, self.m_herosBg, 1, cc.p(0.5, -0.11))
  self.m_herosBg:PlayAni("animation", true)
  self.m_herosBg:performWithDelay(function()
    self.m_herosBg:setTimeScale(0)
  end, 1.2)
  self.m_btnStart = cc.uiloader:seekNodeByName(self.m_bg, "Button_yes_2")
  td.BtnSetTitle(self.m_btnStart, g_LM:getBy("a00223"))
  td.BtnAddTouch(self.m_btnStart, handler(self, self.SendBattleHeroRequest), nil, td.ButtonEffectType.Long)
  self:CreateList()
  self:GetMyHeroes(UserDataManager:GetInstance():GetHeroData())
end
function RobSettingDlg:onEnter()
  RobSettingDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.BattleHero_req, handler(self, self.RobConfigerationCallback))
  self:AddEvents()
  self:CheckGuide()
end
function RobSettingDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.BattleHero_req)
  RobSettingDlg.super.onExit(self)
end
function RobSettingDlg:RefreshUI()
  self:SetData()
  self:RefreshList()
end
function RobSettingDlg:CreateList()
  self.m_list = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
    viewRect = cc.rect(0, 0, 860, 90),
    touchOnContent = true,
    scale = self.m_scale
  })
  local x = self.m_bg:getContentSize().width
  local y = self.m_bg:getContentSize().height
  self.m_list:pos(-15, y * -0.21):addTo(self.m_bg)
  self.m_list:setName("ListView")
  self.m_list:onTouch(function(event)
    if "clicked" == event.name and event.item then
      td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
      if not self.m_heroes[event.itemPos].isUnlock then
        return
      end
      if not event.item:getContent():getChildByName("selected") then
        if self.m_selectedFrame then
          self.m_selectedFrame:removeFromParent()
          self.m_selectedFrame = nil
        end
        self.m_currIndex = event.itemPos
        local item = cc.uiloader:seekNodeByName(event.item:getContent(), "icon")
        self.m_selectedFrame = display.newScale9Sprite("UI/camp/touxiangkuang2.png", 0, 0, cc.size(95, 95))
        td.AddRelaPos(item, self.m_selectedFrame, 2)
      end
    end
  end)
  self:RefreshList()
end
function RobSettingDlg:RefreshList()
  self.m_list:removeAllItems()
  for key, val in ipairs(self.m_heroes) do
    local item = self:CreateItem(val)
    self.m_list:addItem(item)
  end
  self.m_list:reload()
end
function RobSettingDlg:CreateItem(info)
  local icon
  if info.isUnlock then
    icon = display.newSprite(info.head .. td.PNG_Suffix)
  else
    icon = display.newGraySprite(info.head .. td.PNG_Suffix)
  end
  icon:setName("icon")
  local itemBg = display.newScale9Sprite("UI/scale9/touxiangdi3.png", 0, 0, cc.size(85, 85))
  td.AddRelaPos(icon, itemBg, -1)
  local frame = display.newScale9Sprite("UI/camp/touxiangkuang.png", 0, 0, cc.size(95, 95))
  td.AddRelaPos(icon, frame, 1)
  icon:setScale(0.9 * self.m_scale)
  local size = icon:getContentSize()
  local item = self.m_list:newItem(icon)
  item:setItemSize((size.width + 20) * self.m_scale, size.height * self.m_scale)
  return item
end
function RobSettingDlg:SetBattleHero()
  self:CreateBattleHero(self.m_currPanel, self.m_currIndex)
  self.m_battleHeroIds[self.m_currPanel] = self.m_heroes[self.m_currIndex].hid
  self.m_currIndex = 0
  self.m_currPanel = 0
  if self.m_selectedFrame then
    self.m_selectedFrame:removeFromParent()
    self.m_selectedFrame = nil
  end
end
function RobSettingDlg:CreateBattleHero(panelIndex, heroIndex)
  local panel = self.m_heroPanels[panelIndex]
  local heroNode = panel:getChildByName("Node_hero")
  heroNode:removeAllChildren()
  local heroSpine = SkeletonUnit:create(self.m_heroes[heroIndex].image)
  td.CreateUIEffect(heroNode, "Spine/UI_effect/UI_yingxiongchuxian_01", {
    pos = cc.p(0, 30)
  })
  heroSpine:setScale(self.m_heroes[heroIndex].scale)
  heroSpine:PlayAni("skill_01", false, true)
  heroSpine:PlayAni("stand", true, true)
  heroSpine:setName("heroSpine")
  td.AddRelaPos(heroNode, heroSpine)
  local heroName = td.CreateLabel(self.m_heroes[heroIndex].name, td.YELLOW, 22, td.OL_BROWN)
  heroName:pos(0, -35):addTo(heroNode)
  local icon = self.m_list:getItemByPos(heroIndex):getContent()
  icon:setOpacity(100)
  local selected = display.newNode()
  td.AddRelaPos(icon, selected)
  selected:setName("selected")
  panel:getChildByName("srp_light"):setVisible(true)
end
function RobSettingDlg:RemoveHero(index)
  local heroNode = self.m_heroPanels[index]:getChildByName("Node_hero")
  heroNode:removeAllChildren()
  local selText = td.CreateLabel(g_LM:getBy("a00013"), td.WHITE, 22, td.OL_BLACK)
  selText:pos(0, -35):addTo(heroNode)
  self.m_heroPanels[index]:getChildByName("srp_light"):setVisible(false)
  self.m_heroSpines[index] = nil
  self.m_currPanel = 0
  for key, val in ipairs(self.m_heroes) do
    if val.hid == self.m_battleHeroIds[index] then
      local icon = self.m_list:getItemByPos(key):getContent()
      icon:getChildByName("selected"):removeFromParent()
      icon:setOpacity(255)
    end
  end
  self.m_battleHeroIds[index] = 0
end
function RobSettingDlg:SendBattleHeroRequest()
  local data = {}
  data.heroIds = {}
  for i, val in ipairs(self.m_battleHeroIds) do
    if val ~= 0 then
      table.insert(data.heroIds, val)
    end
  end
  data.type = 2
  local Msg = {}
  Msg.msgType = td.RequestID.BattleHero_req
  Msg.sendData = data
  Msg.cbData = clone(data)
  TDHttpRequest:getInstance():Send(Msg)
end
function RobSettingDlg:RobConfigerationCallback(data, cbData)
  if data.state then
    UserDataManager:GetInstance():UpdatePlunderHero(cbData.heroIds)
    self.m_bg:runAction(cca.seq({
      cc.EaseBackIn:create(cca.scaleTo(0.3, 0, 0)),
      cca.cb(function()
        self.m_bg:performWithDelay(function()
          self:close()
        end, 0.05)
      end)
    }))
  end
end
function RobSettingDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_list:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_list:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
      self.m_bTouchInList = true
      return true
    else
      self.m_bTouchInList = false
    end
    for i, panel in ipairs(self.m_heroPanels) do
      local tmpPos = panel:convertToNodeSpace(touch:getLocation())
      if isTouchInNode(panel, tmpPos) then
        self.m_currPanel = i
        if panel:getChildByName("Node_hero"):getChildByName("heroSpine") then
          self:RemoveHero(i)
        end
        if self.m_currIndex and self.m_currIndex ~= 0 then
          self.m_currPanel = i
          self:SetBattleHero()
        end
        return true
      end
    end
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function()
        self:close()
      end, 0.1)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bTouchInList then
      if self.m_list:isTouchInViewRect({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.m_list:onTouch_({
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
    if self.m_bTouchInList then
      self.m_list:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.HERO_DATA_INITED, handler(self, self.RefreshUI))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
return RobSettingDlg
