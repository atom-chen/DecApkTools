local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local GameDataManager = require("app.GameDataManager")
local CommanderInfoManager = require("app.info.CommanderInfoManager")
local CommonInfoManager = require("app.info.CommonInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local GuideManager = require("app.GuideManager")
local TabButton = require("app.widgets.TabButton")
local MissionInfoManager = require("app.info.MissionInfoManager")
local ArenaDlg = class("ArenaDlg", BaseDlg)
local ITEM_SIZE = cc.size(840, 80)
local tabConfig = {
  "UI/arena/tiaozhan%d_icon.png",
  "UI/arena/zhandourizhi%d_icon.png",
  "UI/arena/jianglishuoming%d_icon.png"
}
local listType = {
  Rival = 1,
  Log = 2,
  Reward = 3
}
function ArenaDlg:ctor()
  ArenaDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.PVP
  self.m_udMng = UserDataManager:GetInstance()
  self.m_data = {
    myData = {},
    rivals = {},
    log = {}
  }
  self.m_tabs = {}
  self.m_panels = {}
  self.m_lists = {}
  self.m_currIndex = 0
  self.m_tabIndex = 1
  local info = MissionInfoManager:GetInstance():GetMissionInfo(td.ARENA_ID)
  self.m_staminaCost = info.vit
  self:InitUI()
end
function ArenaDlg:onEnter()
  ArenaDlg.super.onEnter(self)
  self:AddButtonEvents()
  self:AddEvents()
  self.m_udMng:SendGetPVPDataRequest()
  if self.m_udMng:GetItemNum(td.ItemID_Check) > 0 then
    require("app.GuideManager").H_StartGuideGroup(102)
  end
end
function ArenaDlg:onExit()
  ArenaDlg.super.onExit(self)
end
function ArenaDlg:InitUI()
  self:LoadUI("CCS/ArenaDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_jingjichang.png")
  self.m_panelMid = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_mid")
  self.m_panelBottom = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bottom")
  self.m_panelLists = cc.uiloader:seekNodeByName(self.m_panelMid, "Panel_lists")
  self.m_panelStart = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_start")
  self.m_stamLabel = cc.uiloader:seekNodeByName(self.m_panelBottom, "Text_stam_data")
  self.m_stamLabel:setString("x" .. self.m_staminaCost)
  if self.m_udMng:GetStamina() < self.m_staminaCost then
    self.m_stamLabel:setColor(td.RED)
  end
  local myName = cc.uiloader:seekNodeByName(self.m_panelBottom, "Text_name")
  local nickname, bNamed = self.m_udMng:GetNickname()
  myName:setString(nickname)
  local avatar = cc.uiloader:seekNodeByName(self.m_panelBottom, "Image_avatar")
  local avatarPath = CommanderInfoManager:GetInstance():GetPortraitInfo(self.m_udMng:GetPortrait()).file .. td.PNG_Suffix
  avatar:loadTexture(avatarPath)
  local textPower = cc.uiloader:seekNodeByName(self.m_panelBottom, "Text_power")
  textPower:setString(g_LM:getBy("a00032") .. self.m_udMng:GetTotalPower())
  self.m_textGoldNote = cc.uiloader:seekNodeByName(self.m_panelBottom, "Text_ticket")
  self.m_textGoldNote:setString(g_LM:getBy("it00075") .. ":" .. self.m_udMng:GetItemNum(td.ItemID_Check))
  local label = cc.uiloader:seekNodeByName(self.m_panelBottom, "Text_goldnote")
  label:setString(g_LM:getBy("a00242"))
  label = cc.uiloader:seekNodeByName(self.m_panelBottom, "Text_leaderboard")
  label:setString(g_LM:getBy("a00046"))
  label = cc.uiloader:seekNodeByName(self.m_panelBottom, "Text_rank")
  label:setString(g_LM:getBy("a00163") .. ":")
  self.m_btnLeaderboard = cc.uiloader:seekNodeByName(self.m_panelBottom, "Image_leaderboard")
  self.m_btnLeaderboard:setPressedActionEnabled(true)
  self.m_btnGoldNote = cc.uiloader:seekNodeByName(self.m_panelBottom, "Image_goldnote")
  self.m_btnGoldNote:setPressedActionEnabled(true)
  self.m_btnStart = cc.uiloader:seekNodeByName(self.m_panelBottom, "Button_start_4")
  td.BtnSetTitle(self.m_btnStart, g_LM:getBy("a00160"))
  self.m_rewardInfo = cc.uiloader:seekNodeByName(self.m_panelLists, "Text_rewardInfo")
  self.m_rewardInfo:setString(g_LM:getBy("a00243"))
  self:GetListPanels()
end
function ArenaDlg:AddButtonEvents()
  td.BtnAddTouch(self.m_btnLeaderboard, handler(self, self.GoToLeaderboard))
  td.BtnAddTouch(self.m_btnGoldNote, handler(self, self.GoToArenaStore))
  td.BtnAddTouch(self.m_btnStart, handler(self, self.StartBattle), nil, td.ButtonEffectType.Long)
end
function ArenaDlg:GoToLeaderboard()
  g_MC:OpenModule(td.UIModule.Rank, nil, {3})
end
function ArenaDlg:GoToArenaStore()
  g_MC:OpenModule(td.UIModule.Store, {type = 2})
end
function ArenaDlg:StartBattle()
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  if self.m_currIndex == 0 then
    td.alert(g_LM:getBy("a00339"))
  elseif self.m_udMng:GetStamina() < self.m_staminaCost then
    td.alertErrorMsg(td.ErrorCode.STAMINA_NOT_ENOUGH)
  else
    local uName = self.m_udMng:GetNickname()
    GameDataManager:GetInstance():SetCurPVPInfo({
      myRank = self.m_data.selfData.rank,
      id = self.m_data.rivals[self.m_currIndex].uid,
      enemyName = self.m_data.rivals[self.m_currIndex].name,
      enemyRank = self.m_data.rivals[self.m_currIndex].rank,
      enemyZhanli = self.m_data.rivals[self.m_currIndex].max_attack,
      enemyHeadId = self.m_data.rivals[self.m_currIndex].image_id
    })
    local loadingScene = require("app.scenes.LoadingScene").new(td.ARENA_ID)
    cc.Director:getInstance():replaceScene(loadingScene)
  end
end
function ArenaDlg:GetListPanels()
  for i = 1, 3 do
    local listPanel = cc.uiloader:seekNodeByName(self.m_panelLists, "List_" .. i)
    table.insert(self.m_panels, listPanel)
  end
end
function ArenaDlg:UpdatePanels(index)
  self.m_selectedSpine = nil
  self.m_pedestal = nil
  self.m_tabIndex = index
  self.m_currIndex = 0
  for i = 1, #self.m_panels do
    if i == index then
      self.m_panels[i]:setVisible(true)
    else
      self.m_panels[i]:setVisible(false)
    end
  end
  if index == listType.Rival then
    self.m_panelStart:setVisible(true)
  else
    self.m_panelStart:setVisible(false)
    td.EnableButton(self.m_btnStart, false)
  end
  self:CreateList(index)
end
function ArenaDlg:CreateTabs()
  local paneltabs = cc.uiloader:seekNodeByName(self.m_panelMid, "Panel_tabs")
  local buttons = {}
  local tabTitles = {
    "\230\140\145\230\136\152",
    "\230\136\152\230\150\151\230\151\165\229\191\151",
    "\229\165\150\229\138\177\232\175\180\230\152\142"
  }
  for i = 1, 3 do
    local _tab = cc.uiloader:seekNodeByName(paneltabs, "Tab_" .. i)
    table.insert(self.m_tabs, _tab)
    local tabButton = {
      tab = _tab,
      text = tabTitles[i],
      callfunc = handler(self, self.UpdatePanels),
      normalImageFile = string.format(tabConfig[i], 2),
      highImageFile = string.format(tabConfig[i], 1)
    }
    table.insert(buttons, tabButton)
  end
  local tabButtons = TabButton.new(buttons, {
    textSize = 24,
    normalTextColor = td.LIGHT_BLUE,
    highTextColor = td.YELLOW,
    textPos = cc.p(0.5, -0.4)
  })
end
function ArenaDlg:CreateList(index)
  if self.m_UIListView then
    self.m_UIListView:removeFromParent()
    self.m_UIListView = nil
  end
  if index == listType.Rival then
    self.m_UIListView = cc.ui.UIListView.new({
      direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
      viewRect = cc.rect(50, 0, 840, 400),
      touchOnContent = true,
      scale = td.GetAutoScale()
    })
    self.m_UIListView:pos(-10, 0):addTo(self.m_panelLists)
    self.m_UIListView:onTouch(function(event)
      if "clicked" == event.name and event.item then
        self:OnRivalClicked(event.itemPos)
      end
    end)
  elseif index == listType.Log then
    self.m_UIListView = cc.ui.UIListView.new({
      direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
      viewRect = cc.rect(20, 10, 860, 380),
      touchOnContent = false,
      scale = td.GetAutoScale()
    })
    self.m_UIListView:addTo(self.m_panelLists)
  elseif index == listType.Reward then
    self.m_UIListView = cc.ui.UIListView.new({
      direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
      viewRect = cc.rect(20, 10, 860, 320),
      touchOnContent = false,
      scale = td.GetAutoScale()
    })
    self.m_UIListView:addTo(self.m_panelLists)
  end
  self.m_UIListView:setName("ListView")
  self:RefreshList(index)
end
function ArenaDlg:OnRivalClicked(index)
  self.m_currIndex = index
  if self.m_selectedSpine then
    self.m_selectedSpine:removeFromParent()
    self.m_selectedSpine = nil
  end
  self.m_selectedSpine = SkeletonUnit:create("Spine/UI_effect/UI_jingjichangxuanzhong_02")
  self.m_selectedSpine:PlayAni("animation", true)
  local item = self.m_UIListView:getItemByPos(index)
  local currItem = cc.uiloader:seekNodeByName(item:getContent(), "Image_bg")
  td.AddRelaPos(currItem, self.m_selectedSpine)
  if self.m_pedestal then
    self.m_pedestal:PlayAni("animation_01", true)
  end
  self.m_pedestal = cc.uiloader:seekNodeByName(item:getContent(), "pedestal")
  self.m_pedestal:PlayAni("animation_02", true)
  td.EnableButton(self.m_btnStart, true)
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
end
function ArenaDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_UIListView then
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
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_tabIndex == 1 then
      return
    end
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      return self.m_UIListView:onTouch_({
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
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  self:AddCustomEvent(td.ARENA_UPDATE, handler(self, self.SetData))
  self:AddCustomEvent(td.RANK_UPDATE, handler(self, self.PlayRankAni))
  self:AddCustomEvent(td.ITEM_UPDATE, function()
    self.m_textGoldNote:setString(g_LM:getBy("it00075") .. ":" .. self.m_udMng:GetItemNum(td.ItemID_Check))
  end)
end
function ArenaDlg:RefreshList(type)
  self.m_UIListView:removeAllItems(true)
  if type == listType.Rival then
    for key, val in ipairs(self.m_data.rivals) do
      if val.uid ~= self.m_udMng:GetUId() then
        local item = self:CreateRivalItem(val)
        self.m_UIListView:addItem(item)
      end
    end
  elseif type == listType.Log then
    for key, val in ipairs(self.m_data.log) do
      local item = self:CreateLogItem(val)
      self.m_UIListView:addItem(item)
    end
  elseif type == listType.Reward then
    local rewardInfos = CommonInfoManager:GetInstance():GetArenaAwardInfo()
    for key, val in pairs(rewardInfos) do
      local item = self:CreateAwardInfoItem(val)
      self.m_UIListView:addItem(item)
    end
  end
  self.m_UIListView:reload()
end
function ArenaDlg:CreateRivalItem(itemData)
  local itemNode = cc.uiloader:load("CCS/ArenaRivalItem.csb")
  local itemBg = cc.uiloader:seekNodeByName(itemNode, "Panel_content")
  local rank = itemData.rank or 1
  local rankNode = cc.uiloader:seekNodeByName(itemBg, "Node_rank")
  if rank <= 3 then
    local fileName = string.format("UI/words/no%02d.png", rank)
    local rankText = display.newSprite(fileName)
    rankText:setAnchorPoint(0, 0)
    rankText:pos(0, -2):addTo(rankNode)
  else
    local rankLabel = display.newBMFontLabel({
      text = rank .. "",
      font = "Fonts/RankNumber.fnt",
      align = cc.TEXT_ALIGNMENT_LEFT
    })
    rankLabel:setAnchorPoint(0, 0)
    rankLabel:pos(0, 0):addTo(rankNode)
  end
  local textPowerLabel = cc.uiloader:seekNodeByName(itemBg, "Text_power_label")
  local textPowerData = cc.uiloader:seekNodeByName(itemBg, "Text_power_data")
  textPowerLabel:setString(g_LM:getBy("a00032") .. ": ")
  textPowerData:setString(itemData.max_attack)
  local pedestalNode = cc.uiloader:seekNodeByName(itemBg, "Node_pedestal")
  local pedestal = SkeletonUnit:create("Spine/UI_effect/UI_jingjichangxuanzhong_01")
  pedestal:setName("pedestal")
  pedestal:setScale(0.35, 0.35)
  pedestal:PlayAni("animation_01", true)
  td.AddRelaPos(pedestalNode, pedestal)
  local avatar = cc.uiloader:seekNodeByName(itemBg, "Image_avatar")
  avatar:loadTexture(td.GetPortrait(itemData.image_id))
  local textName = cc.uiloader:seekNodeByName(itemBg, "Text_name")
  textName:setString(itemData.name)
  local vipIcon = cc.uiloader:seekNodeByName(itemBg, "Image_vip")
  vipIcon:loadTexture(td.GetVIPIcon(itemData.vip_level))
  local size = itemBg:getContentSize()
  local item = self.m_UIListView:newItem(itemNode)
  item:setAnchorPoint(cc.p(0.5, 0.5))
  item:setItemSize(size.width * self.m_scale, size.height * self.m_scale)
  item:setScale(self.m_scale)
  return item
end
function ArenaDlg:CreateLogItem(itemData)
  local itemNode = display.newNode()
  itemNode:setContentSize(ITEM_SIZE)
  itemNode:scale(self.m_scale)
  local stateSpr
  if itemData.result == 1 or itemData.result == 2 then
    stateSpr = display.newSprite("UI/arena/shengli_icon.png")
  else
    stateSpr = display.newSprite("UI/arena/shibai_icon.png")
  end
  stateSpr:pos(50, 40):addTo(itemNode)
  local infoText = self:GetLogText(itemData.result, itemData.other_name)
  infoText:align(display.LEFT_CENTER, 150, 40):addTo(itemNode)
  local rankVar = itemData.erank - itemData.srank
  if rankVar > 0 then
    local rankLabel = td.RichText({
      {
        type = 2,
        file = "UI/common/xiajiang_jiantou.png",
        scale = 1
      },
      {
        type = 1,
        str = "" .. math.abs(rankVar) .. "\229\144\141",
        color = td.GREEN,
        size = 18
      }
    })
    rankLabel:pos(480, 40):addTo(itemNode)
  elseif rankVar < 0 then
    local rankLabel = td.RichText({
      {
        type = 2,
        file = "UI/common/shangsheng_jiantou.png",
        scale = 1
      },
      {
        type = 1,
        str = "" .. math.abs(rankVar) .. "\229\144\141",
        color = td.YELLOW,
        size = 18
      }
    })
    rankLabel:pos(480, 40):addTo(itemNode)
  end
  local textTime = td.CreateLabel(td.GetSimpleTime(itemData.time))
  textTime:pos(650, 40):addTo(itemNode)
  local infoBtn = ccui.Button:create("UI/arena/duishouxiangqing.png", "UI/arena/duishouxiangqing.png")
  infoBtn:pos(765, 40):addTo(itemNode)
  infoBtn:setPressedActionEnabled(true)
  td.BtnAddTouch(infoBtn, function()
    local fid = itemData.other_id
    local tmpNode = require("app.layers.MainMenuUI.FriendInfoDlg").new()
    tmpNode:SetData(fid)
    td.popView(tmpNode, true)
  end)
  local lineSpr = display.newSprite("UI/common/fengexian_shu.png")
  lineSpr:setScaleX(ITEM_SIZE.width / lineSpr:getContentSize().width)
  td.AddRelaPos(itemNode, lineSpr, 1, cc.p(0.5, 0))
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize(ITEM_SIZE.width * self.m_scale, ITEM_SIZE.height * self.m_scale)
  return item
end
function ArenaDlg:CreateAwardInfoItem(itemData)
  local itemNode = display.newNode()
  itemNode:setContentSize(ITEM_SIZE)
  itemNode:scale(self.m_scale)
  local rank = itemData.level
  local str
  if rank[1] < 4 then
    str = string.format("\231\172\172%d\229\144\141", rank[1])
  else
    str = string.format("\231\172\172%d-%d\229\144\141", rank[1], rank[2])
  end
  local textRank = td.CreateLabel(str, td.GREEN, 24)
  textRank:setAnchorPoint(0.5, 0.5)
  td.AddRelaPos(itemNode, textRank, 1, cc.p(0.27, 0.5))
  local itemId = itemData.award.itemId
  local icon = td.CreateItemIcon(itemId)
  icon:scale(0.7)
  td.AddRelaPos(itemNode, icon, 1, cc.p(0.5, 0.5))
  local itemName = ItemInfoManager:GetInstance():GetItemInfo(itemId).name
  local itemNum = tostring(itemData.award.num)
  local strNum = string.format(itemName .. "x" .. itemNum)
  local textNum = td.CreateLabel(strNum, td.WHITE, 24)
  textNum:setAnchorPoint(0.5, 0.5)
  td.AddRelaPos(itemNode, textNum, 1, cc.p(0.7, 0.5))
  local lineSpr = display.newSprite("UI/common/fengexian_shu.png")
  lineSpr:setScaleX(ITEM_SIZE.width / lineSpr:getContentSize().width)
  td.AddRelaPos(itemNode, lineSpr, 1, cc.p(0.5, 0))
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize(ITEM_SIZE.width * self.m_scale, ITEM_SIZE.height * self.m_scale)
  return item
end
function ArenaDlg:GetLogText(result, name)
  local textData = {}
  if result == 0 or result == 1 then
    table.insert(textData, {
      type = 1,
      str = "\230\130\168\230\140\145\230\136\152\228\186\134",
      color = td.BLUE,
      size = 20
    })
    table.insert(textData, {
      type = 1,
      str = name,
      color = td.WHITE,
      size = 20
    })
  elseif result == 2 or result == 3 then
    table.insert(textData, {
      type = 1,
      str = name,
      color = td.WHITE,
      size = 20
    })
    table.insert(textData, {
      type = 1,
      str = "\230\140\145\230\136\152\228\186\134\230\130\168",
      color = td.BLUE,
      size = 20
    })
  end
  return td.RichText(textData)
end
function ArenaDlg:SetData()
  self.m_data = self.m_udMng:GetPVPData()
  self:CreateTabs()
  if not self.m_rankRollLabel then
    local bg = cc.uiloader:seekNodeByName(self.m_panelBottom, "Image_info_bg")
    self.m_rankRollLabel = require("app.widgets.RollNumberLabel").new({
      num = self.m_data.selfData.rank,
      color = td.WHITE,
      size = 20
    })
    self.m_rankRollLabel:pos(300, 64):addTo(bg)
  end
  if self.m_data.selfData.rank ~= self.m_data.selfData.next_rank then
    local dlg = require("app.layers.PowerUpLayer").new(self.m_data.selfData.rank, 1)
    dlg:RollTo(self.m_data.selfData.next_rank)
    td.popView(dlg)
  end
end
function ArenaDlg:PlayRankAni()
  if self.m_data then
    self.m_data.selfData.rank = self.m_data.selfData.next_rank
    self.m_rankRollLabel:SetNumber(self.m_data.selfData.rank)
  end
end
return ArenaDlg
