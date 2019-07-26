local SkillInfoManager = require("app.info.SkillInfoManager")
local UserDataManager = require("app.UserDataManager")
local GameDataManager = require("app.GameDataManager")
local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local TabButton = require("app.widgets.TabButton")
require("app.config.hero_sound_config")
local BombDlg = class("BombDlg", BaseDlg)
local ListItemTag = {SelectBorder = 1, BG = 11}
function BombDlg:ctor()
  BombDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Bombard
  self.m_udMng = UserDataManager:GetInstance()
  self.m_siMng = SkillInfoManager:GetInstance()
  self.m_myCampLevel = self.m_udMng:GetBaseCampLevel()
  self.m_mode = 0
  self.m_bombData = {}
  self.m_vHeroIDs = {}
  self.m_curHeroIndex = nil
  self.m_vHeroItems = {}
  self.m_vChosenSkillIcons = {}
  self:InitData()
  self:InitUI()
end
function BombDlg:onEnter()
  BombDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.BombStart, handler(self, self.BombStartCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.MallBuy, handler(self, self.BuyCallback))
  self:AddEvents()
end
function BombDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.BombStart)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.MallBuy)
  BombDlg.super.onExit(self)
end
function BombDlg:InitData()
  local lastHeorId = g_LD:GetInt("bomb_hero", 0)
  local heroDatas = UserDataManager:GetInstance():GetHeroData()
  for id, value in pairs(heroDatas) do
    if id == lastHeorId then
      table.insert(self.m_vHeroIDs, 1, id)
    else
      table.insert(self.m_vHeroIDs, id)
    end
  end
end
function BombDlg:InitUI()
  self:LoadUI("CCS/BombLayer.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_kuanghongluanzha.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_heroPanel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_hero")
  self.m_nameLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_name")
  self.m_textTime = cc.uiloader:seekNodeByName(self.m_bg, "Text_times")
  self.m_btnStart = cc.uiloader:seekNodeByName(self.m_bg, "Button_start")
  td.BtnAddTouch(self.m_btnStart, handler(self, self.OnStartBtnClicked))
  local btnAdd = cc.uiloader:seekNodeByName(self.m_bg, "Button_add_chance")
  td.BtnAddTouch(btnAdd, handler(self, self.OnAddBtnClicked))
  local label = cc.uiloader:seekNodeByName(self.m_heroPanel, "Text_choose")
  label:setString(g_LM:getBy("a00376"))
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_times_left")
  label:setString(g_LM:getBy("a00188"))
  self:CreateHeroList()
  self:CreateTabs(1)
end
function BombDlg:RefreshUI()
  local remainTimes = self.m_udMng:GetDungeonTime(self.m_uiId)
  self.m_textTime:setString(remainTimes)
  if remainTimes <= 0 then
    self.m_textTime:setColor(td.RED)
  else
    self.m_textTime:setColor(td.WHITE)
  end
end
function BombDlg:CreateTabs(mode)
  self.m_tabs = {}
  local tabs = {}
  for i = 1, 3 do
    local _tab = cc.uiloader:seekNodeByName(self.m_uiRoot, "Tab" .. i)
    table.insert(self.m_tabs, _tab)
    if i == 2 and self.m_myCampLevel < 20 or i == 3 and self.m_myCampLevel < 30 then
      local grayIcon = display.newGraySprite("UI/button/nandu" .. i .. "_icon2.png")
      local parent = _tab:getParent()
      local x, y = _tab:getPosition()
      grayIcon:pos(x, y):addTo(parent)
    elseif i == 2 and self.m_myCampLevel >= 20 or i == 3 and self.m_myCampLevel >= 30 then
      _tab:setOpacity(255)
    end
    local tab = {
      tab = _tab,
      callfunc = handler(self, self.OnModeTabClicked),
      normalImageFile = "UI/button/nandu" .. i .. "_icon2.png",
      highImageFile = "UI/button/nandu" .. i .. "_icon1.png"
    }
    table.insert(tabs, tab)
  end
  local tabButtons = TabButton.new(tabs, {autoSelectIndex = mode})
end
function BombDlg:OnModeTabClicked(index)
  if self.m_mode == index then
    return
  end
  if index == 2 and self.m_myCampLevel < 20 then
    td.alert(g_LM:getBy("a00341"))
    return false
  elseif index == 3 and self.m_myCampLevel < 30 then
    td.alert(g_LM:getBy("a00342"))
    return false
  end
  self.m_mode = index
  self:RefreshUI()
end
function BombDlg:CreateHeroList()
  local listBgSize = self.m_heroPanel:getContentSize()
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    alignment = cc.ui.UIScrollView.ALIGNMENT_TOP,
    viewRect = cc.rect(0, 20, listBgSize.width, listBgSize.height - 80),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_heroPanel:addChild(self.m_UIListView)
  self.m_UIListView:onTouch(function(event)
    if event.name == "clicked" and table.indexof(self.m_vHeroIDs, event.item.id) then
      self:SetHeroItemSelect(event.itemPos)
    end
  end)
  self:InitHeroList()
  self:SetHeroItemSelect(1)
end
function BombDlg:InitHeroList()
  local allHero = {
    1000,
    1100,
    1200,
    1300,
    1400,
    1500
  }
  for k, id in ipairs(self.m_vHeroIDs) do
    local heroData = self.m_udMng:GetHeroData(id)
    local item = self:CreateHeroItem(heroData)
    self.m_UIListView:addItem(item)
    table.insert(self.m_vHeroItems, item)
    local index = table.indexof(allHero, math.floor(heroData.hid / 100) * 100)
    if index then
      table.remove(allHero, index)
    end
  end
  for i, id in ipairs(allHero) do
    local info = require("app.info.ActorInfoManager"):GetInstance():GetHeroInfo(id)
    local item = self:CreateNoHeroItem(info)
    self.m_UIListView:addItem(item)
    table.insert(self.m_vHeroItems, item)
  end
  self.m_UIListView:reload()
end
function BombDlg:CreateHeroItem(heroData)
  local parent = display.newSprite("UI/hero/touxiangkuang2.png")
  parent:setScale(self.m_scale)
  local heroIcon = heroData.heroInfo.head .. td.PNG_Suffix
  local heroSpri = display.newSprite(heroIcon)
  heroSpri:setScale(0.8)
  td.AddRelaPos(parent, heroSpri)
  local borderSpr = display.newSprite("UI/hero/touxiangkuang1.png")
  td.AddRelaPos(parent, borderSpr)
  local borderSize = cc.size(heroSpri:getContentSize().width * 0.95, heroSpri:getContentSize().height * 0.95)
  local selectBorderSpr = display.newScale9Sprite("UI/hero/huangse_xuanzhongkuang.png", 0, 0, borderSize)
  selectBorderSpr:setTag(ListItemTag.SelectBorder)
  selectBorderSpr:setVisible(false)
  td.AddRelaPos(parent, selectBorderSpr, 1, cc.p(0.49, 0.52))
  local item = self.m_UIListView:newItem(parent)
  item.id = heroData.id
  local size = parent:getContentSize()
  item:setItemSize(size.width * self.m_scale, (size.height + 30) * self.m_scale)
  return item
end
function BombDlg:CreateNoHeroItem(info)
  local parent = display.newSprite("UI/hero/touxiangkuang2.png")
  parent:setScale(self.m_scale)
  local heroIcon = info.head .. td.PNG_Suffix
  local heroSpri = display.newGraySprite(heroIcon)
  heroSpri:setScale(0.8)
  td.AddRelaPos(parent, heroSpri)
  local borderSpr = display.newSprite("UI/hero/touxiangkuang1.png")
  td.AddRelaPos(parent, borderSpr)
  local item = self.m_UIListView:newItem(parent)
  item.id = info.id
  local size = parent:getContentSize()
  item:setItemSize(size.width * self.m_scale, (size.height + 30) * self.m_scale)
  return item
end
function BombDlg:SetHeroItemSelect(index)
  if self.m_curHeroIndex and self.m_curHeroIndex == index then
    return
  end
  if index <= 0 or index > #self.m_vHeroItems then
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
function BombDlg:RefreshHeroDetail()
  if self.m_heroSkeleton then
    self.m_heroSkeleton:removeFromParent()
    self.m_heroSkeleton = nil
  end
  local heroData = self.m_udMng:GetHeroData(self.m_vHeroIDs[self.m_curHeroIndex])
  self.m_heroSkeleton = SkeletonUnit:create(heroData.heroInfo.image)
  local skScale = 1.5 * heroData.heroInfo.scale
  self.m_heroSkeleton:scale(skScale)
  self.m_heroSkeleton:PlayAni("skill_01", false)
  self.m_heroSkeleton:PlayAni("stand", true, true)
  td.AddRelaPos(self.m_bg, self.m_heroSkeleton, 1, cc.p(0.5, 0.2))
  self.m_nameLabel:setString(heroData.heroInfo.name)
  local soundConfig = GetHeroSoundConfig(heroData.hid)
  if 1 < #soundConfig.magic then
    local randIndex = 1
    randIndex = math.random(#soundConfig.magic)
    G_SoundUtil:PlaySound(soundConfig.magic[randIndex], false)
  end
  self:RefreshSkill(heroData)
end
function BombDlg:RefreshSkill(heroData)
  local inFunc6 = function(data)
    local parent = data.parent
    local iconSpr = td.CreateSkillIcon(data.id, data.star, data.quality)
    iconSpr:setScale(0.6)
    parent:removeAllChildren()
    td.AddRelaPos(parent, iconSpr)
    if not data.unlock then
      iconSpr:setColor(td.BTN_PRESSED_COLOR)
      local lockSpr = display.newSprite("UI/common/suo_icon2.png")
      td.AddRelaPos(parent, lockSpr)
    end
  end
  local skillsLib = UserDataManager:GetInstance():GetSkillLib()
  for i = 1, 3 do
    local bUnlock, level = td.IsHeroSkillUnlock(heroData.level, false, i)
    local skillBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_skill" .. i)
    local skillData = skillsLib[heroData.passiveSkill[i]]
    local skillInfo = skillData.skillInfo
    inFunc6({
      parent = skillBg,
      id = skillInfo.id,
      star = skillData.star,
      quality = skillData.quality,
      unlock = bUnlock
    })
  end
  for i = 1, 2 do
    local bUnlock, level = td.IsHeroSkillUnlock(heroData.level, true, i)
    local skillBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_skill" .. i + 3)
    local skillData = skillsLib[heroData.activeSkill[i]]
    local skillInfo = skillData.skillInfo
    inFunc6({
      parent = skillBg,
      id = skillInfo.id,
      star = skillData.star,
      quality = skillData.quality,
      unlock = bUnlock
    })
  end
end
function BombDlg:OnStartBtnClicked()
  if self.m_udMng:GetDungeonTime(self.m_uiId) <= 0 then
    td.alertErrorMsg(td.ErrorCode.MISSION_TIME_NOT_ENOUGH)
  else
    self:SendBombStartReq()
  end
end
function BombDlg:OnAddBtnClicked()
  td.ShowBuyTimeDlg(self.m_uiId, handler(self, self.SendBuyRequest))
end
function BombDlg:ShowSkillDetail(skillData, unselectCb)
  self:HideSkillDetail()
  self.m_skillUI = require("app.widgets.BombSkillUI").new(self)
  self.m_skillUI:pos(0, 0):addTo(self.m_bg, -1)
  self.m_skillUI:RefreshUI(skillData, unselectCb)
end
function BombDlg:HideSkillDetail()
  if self.m_skillUI then
    self.m_skillUI:Close()
    self.m_skillUI = nil
  end
  if self.m_selectSpr then
    self.m_selectSpr:removeFromParent()
    self.m_selectSpr = nil
  end
  for i = 1, 5 do
    local skillBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_skill" .. i)
    self:_setSkillSlotActive(skillBg, false)
  end
  self.m_skillSlotClickCb = nil
end
function BombDlg:SaveBombData()
  g_LD:SetInt("bomb_hero", self.m_vHeroIDs[self.m_curHeroIndex])
end
function BombDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    self.m_bTouchInList = false
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_bTouchInList = true
      self.m_UIListView:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bTouchInList then
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
    if self.m_bTouchInList then
      self.m_UIListView:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.HERO_DATA_INITED, function()
    self:close()
    g_MC:OpenModule(self.m_uiId)
  end)
end
function BombDlg:SendBombStartReq()
  local Msg = {}
  Msg.msgType = td.RequestID.BombStart
  Msg.sendData = {
    type = self.m_mode
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function BombDlg:BombStartCallback(data, cbData)
  self.m_udMng:UpdateDungeonTime(self.m_uiId, -1)
  self.m_bombData.mode = self.m_mode
  self.m_bombData.hero = self.m_vHeroIDs[self.m_curHeroIndex]
  self.m_bombData.monsters = data.monsters
  self:SaveBombData()
  GameDataManager:GetInstance():SetBombData(self.m_bombData)
  local loadingScene = require("app.scenes.LoadingScene").new(td.BOMB_ID)
  cc.Director:getInstance():replaceScene(loadingScene)
end
function BombDlg:SendBuyRequest()
  if self.m_bIsRequsting then
    return
  end
  self.m_bIsRequsting = true
  local Msg = {}
  Msg.msgType = td.RequestID.MallBuy
  Msg.sendData = {
    id = td.BuyBombId,
    num = 1
  }
  Msg.cbData = {
    id = td.BuyBombId
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function BombDlg:BuyCallback(data, cbData)
  if data.state == td.ResponseState.Success and cbData.id == td.BuyBombId then
    self.m_udMng:UpdateDungeonTime(self.m_uiId, 1)
    self.m_udMng:UpdateDungeonBuyTime(self.m_uiId, -1)
    self:RefreshUI()
  end
  self.m_bIsRequsting = false
end
return BombDlg
