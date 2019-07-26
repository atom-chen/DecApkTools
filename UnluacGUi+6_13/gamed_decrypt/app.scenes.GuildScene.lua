local UserDataManager = require("app.UserDataManager")
local GameSceneBase = require("app.scenes.GameSceneBase")
local TDHttpRequest = require("app.net.TDHttpRequest")
local NetManager = require("app.net.NetManager")
local GuildScene = class("GuildScene", GameSceneBase)
local GuildTabs = {
  [1] = {
    {
      name = g_LM:getBy("g00001"),
      contentNode = "SearchGuild"
    },
    {
      name = g_LM:getBy("g00002"),
      contentNode = "CreateGuild"
    }
  },
  [2] = {
    {
      name = g_LM:getBy("g00003"),
      contentNode = "GuildBuildings"
    },
    {
      name = g_LM:getBy("g00004"),
      contentNode = "GuildInfo"
    },
    {
      name = g_LM:getBy("g00005"),
      contentNode = "GuildActivity"
    },
    {
      name = g_LM:getBy("g00006"),
      contentNode = "GuildReport"
    }
  }
}
function GuildScene:ctor()
  GuildScene.super.ctor(self)
  self.m_scale = td.GetAutoScale()
  self.m_eType = td.SceneType.Guild
  self.m_bgHeight = 0
  self.m_curSelectIndex = -1
  self.m_curContentNode = nil
  self.m_vContentNode = {}
  self.m_vCustomListeners = {}
  self.m_gdMng = UserDataManager:GetInstance():GetGuildManager()
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function GuildScene:onEnter()
  GuildScene.super.onEnter(self)
  self:PlayEnterAni()
  self:AddListeners()
  self:AddTouch()
  self.m_gdMng:SendGetGuildRequest()
  G_SoundUtil:PlayMusic(13, true)
end
function GuildScene:onExit()
  GuildScene.super.onExit(self)
end
function GuildScene:PlayEnterAni(cb)
  self.m_titleBg:runAction(cca.seq({
    cca.delay(0.2),
    cc.EaseBackOut:create((cca.moveTo(0.3, 180, 603.5))),
    cca.cb(cb)
  }))
end
function GuildScene:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/guild/GuildBackground.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_bgImage = display.newSprite("UI/common/uibg.png")
  self.m_bgImage:scale(display.width / self.m_bgImage:getContentSize().width):addTo(self)
  self.m_bgImage:pos(display.width / 2, display.height / 2)
  self.m_pPanelTop = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_top")
  td.SetAutoScale(self.m_pPanelTop, td.UIPosHorizontal.Center, td.UIPosVertical.Top)
  self.m_pPanelCenter = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_center")
  td.SetAutoScale(self.m_pPanelCenter, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_pPanelCenter, "Image_panel_bg")
  local oriBgSize = self.m_bg:getContentSize()
  self.m_bgHeight = 565
  local listBg = cc.uiloader:seekNodeByName(self.m_pPanelCenter, "Image_selection_bg")
  oriBgSize = listBg:getContentSize()
  self:InitTopBar()
  self:CreateList()
end
function GuildScene:InitTopBar()
  local staminaBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_strength")
  td.BtnAddTouch(staminaBtn, function()
    g_MC:OpenModule(td.UIModule.BuyStamina)
  end)
  local goldBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_gold")
  td.BtnAddTouch(goldBtn, function()
    g_MC:OpenModule(td.UIModule.BuyGold)
  end)
  local diamondBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_diamond")
  td.BtnAddTouch(diamondBtn, function()
    g_MC:OpenModule(td.UIModule.Topup)
  end)
  local udMng = UserDataManager:GetInstance()
  local userDetail = udMng:GetUserDetail()
  local RollNumberLabel = require("app.widgets.RollNumberLabel")
  self.m_labelStamina = td.CreateLabel(string.format("%d/%d", userDetail.stamina, udMng:GetMaxStamina()), td.WHITE, 20)
  td.AddRelaPos(staminaBtn, self.m_labelStamina)
  self.m_labelGold = RollNumberLabel.new({
    num = userDetail.gold,
    color = td.WHITE,
    size = 20
  })
  td.AddRelaPos(goldBtn, self.m_labelGold)
  self.m_labelDiamond = RollNumberLabel.new({
    num = userDetail.diamond,
    color = td.WHITE,
    size = 20
  })
  td.AddRelaPos(diamondBtn, self.m_labelDiamond)
  self.m_titleBg = cc.uiloader:seekNodeByName(self, "Image_title")
  local titleSpr = display.newSprite(td.Word_Path .. "wenzi_juntuan.png")
  td.AddRelaPos(self.m_titleBg, titleSpr)
  self.m_pBackBtn = cc.uiloader:seekNodeByName(self.m_pPanelTop, "Button_back")
  td.BtnAddTouch(self.m_pBackBtn, function()
    local scene = require("app.scenes.MainMenuScene").new()
    display.replaceScene(scene)
  end)
end
function GuildScene:AddChat()
  if not self.m_chatDlg then
    self.m_chatDlg = require("app.layers.chat.ChatDlg").new(2)
    self:addChild(self.m_chatDlg, 500)
  end
end
function GuildScene:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local bResult = false
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_UIListView:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
      bResult = true
      self.m_bIsTouchInList = true
    else
      self.m_bIsTouchInList = false
    end
    return bResult
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bIsTouchInList then
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
end
function GuildScene:CreateItem(data)
  local itemNode = display.newNode()
  local bgSize = cc.size(171, 68)
  local itembg = display.newSprite("UI/guild/juntuan2_button.png")
  itembg:setAnchorPoint(cc.p(0, 0))
  itembg:setName("bg")
  itembg:addTo(itemNode)
  local titleLabel = td.CreateLabel(data.name, td.WHITE, 22)
  td.AddRelaPos(itembg, titleLabel)
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize((bgSize.width + 5) * self.m_scale, bgSize.height * self.m_scale)
  item:setScale(self.m_scale)
  item:setAnchorPoint(cc.p(0.5, 0.5))
  return item
end
function GuildScene:CreateList()
  local listHieght = 460
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 171, listHieght),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_UIListView:setAnchorPoint(cc.p(0, 0))
  self.m_UIListView:pos(18, 70)
  self.m_UIListView:onTouch(function(event)
    if "clicked" == event.name and event.item then
      self:OnListItemClicked(event.itemPos)
    end
  end)
  self.m_bg:addChild(self.m_UIListView, 1)
end
function GuildScene:RefreshList()
  local guideData = self.m_gdMng:GetGuildData()
  if guideData then
    self.m_tabData = GuildTabs[2]
    self:AddChat()
  else
    self.m_tabData = GuildTabs[1]
  end
  self.m_UIListView:removeAllItems()
  for i, var in ipairs(self.m_tabData) do
    local item = self:CreateItem(var)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function GuildScene:OnListItemClicked(index)
  if self.m_curSelectIndex > 0 then
    local item = self.m_UIListView:getItemByPos(self.m_curSelectIndex)
    if item then
      local itemBg = item:getContent():getChildByName("bg")
      itemBg:setTexture("UI/guild/juntuan2_button.png")
    end
  end
  self.m_curSelectIndex = index
  local nodeName = self.m_tabData[index].contentNode
  local item = self.m_UIListView:getItemByPos(self.m_curSelectIndex)
  local itemBg = item:getContent():getChildByName("bg")
  itemBg:setTexture("UI/guild/juntuan1_button.png")
  self:RefreshContent(nodeName)
end
function GuildScene:RefreshContent(nodeName)
  if self.m_curContentNode then
    self.m_curContentNode:setVisible(false)
    self.m_curContentNode = nil
  end
  local contentNode = self.m_vContentNode[nodeName]
  if contentNode then
    contentNode:setVisible(true)
  else
    contentNode = require("app.layers.guild." .. nodeName).new(self.m_bgHeight)
    self.m_vContentNode[nodeName] = contentNode
    local conSize = self.m_bg:getContentSize()
    contentNode:pos(conSize.width * 0.58, conSize.height - 7):addTo(self.m_bg, -1)
  end
  self.m_curContentNode = contentNode
end
function GuildScene:AddListeners()
  self:AddCustomEvent(td.HEART_BEAT, handler(self, self.HeartBeatCallback))
  self:AddCustomEvent(td.GUILD_UPDATE, handler(self, self.OnGuildUpdate))
  self:AddCustomEvent(td.USERWEALTH_CHANGED, handler(self, self.OnWealthChanged))
end
function GuildScene:OnGuildUpdate()
  self.m_curSelectIndex = -1
  self.m_curContentNode = nil
  for key, var in pairs(self.m_vContentNode) do
    var:removeFromParent()
  end
  self.m_vContentNode = {}
  self:RefreshList()
  if self.m_eEnterModuleId then
    self:OnListItemClicked(self.m_eEnterModuleId)
    self.m_eEnterModuleId = nil
  else
    self:OnListItemClicked(1)
  end
end
function GuildScene:OnWealthChanged()
  local udMng = UserDataManager:GetInstance()
  local userDetail = udMng:GetUserDetail()
  self.m_labelStamina:setString(string.format("%d/%d", userDetail.stamina, udMng:GetMaxStamina()))
  self.m_labelGold:SetNumber(userDetail.gold)
  self.m_labelDiamond:SetNumber(userDetail.diamond)
end
function GuildScene:HeartBeatCallback(event)
  local str = event:getDataString()
  local data = string.toTable(str)
  local items = string.split(data.num, "|")
  if data.type == td.HBType.Kick then
    td.alertDebug("\232\184\162\229\135\186\231\142\169\229\174\182")
    for key, item in ipairs(items) do
      if item == UserDataManager:GetInstance():GetUId() then
        self.m_gdMng:UpdateData(nil, {})
        td.alert(g_LM:getBy("a00358"))
        td.dispatchEvent(td.GUILD_UPDATE)
        break
      else
        self.m_gdMng:RemoveMember(item)
      end
    end
    if self.m_gdMng:GetGuildData() then
      td.dispatchEvent(td.GUILD_LISTS_REFRESH)
    end
  elseif data.type == td.HBType.Promote then
    td.alertDebug("\230\148\185\229\143\152\231\142\169\229\174\182\232\129\140\228\189\141")
    for key, item in ipairs(items) do
      local tmp = string.split(item, "#")
      local initiator = tmp[1]
      local target = tmp[2]
      local position = tonumber(tmp[3])
      if position == td.GuildPos.Master then
        self.m_gdMng:SendGetGuildRequest(true)
      end
      self.m_gdMng:AddRPMember(target)
      if target == UserDataManager:GetInstance():GetUId() then
        local initiatorName = self.m_gdMng:GetMemberData(initiator).u_name
        td.alert(string.format(g_LM:getBy("a00359"), initiatorName, g_LM:getMode("guildPos", position)))
        self.m_gdMng:GetMemberData(target).type = position
        td.dispatchEvent(td.GUILD_RANK_CHANGED)
        td.dispatchEvent(td.GUILD_LISTS_REFRESH)
      end
    end
  elseif data.type == td.HBType.Recruit then
    td.alertDebug("\229\144\140\230\132\143\229\133\165\228\188\154")
    if self.m_gdMng:GetGuildData() then
      self.m_gdMng:SendGetGuildRequest(true)
    else
      self.m_gdMng:SendGetGuildRequest()
    end
  elseif data.type == td.HBType.Reject then
    td.alertDebug("\230\139\146\231\187\157\231\142\169\229\174\182\229\133\165\228\188\154")
    self.m_gdMng:SendGetGuildRequest(true)
  elseif data.type == td.HBType.Apply then
    td.alertDebug("\231\148\179\232\175\183\229\133\165\228\188\154")
    self.m_gdMng:SendGetGuildRequest(true)
  elseif data.type == td.HBType.Quit then
    for key, item in ipairs(items) do
      for i, val in ipairs(clone(self.m_gdMng:GetGuildMemberList())) do
        if item == val.uid then
          table.remove(self.m_gdMng:GetGuildMemberList(), i)
        end
      end
    end
    td.dispatchEvent(td.GUILD_LISTS_REFRESH)
  elseif data.type == td.HBType.BUpgrade then
    for key, item in ipairs(items) do
      local tmp = string.split(item, "#")
      local buildingId = tonumber(tmp[1])
      local buildingLvl = tonumber(tmp[2])
      local buildingNum = tonumber(tmp[3])
      if buildingLvl > self.m_gdMng:GetBuildingLevel(buildingId) then
        self.m_gdMng:UpdateBuilding(buildingId, buildingNum, buildingLvl)
        self.m_gdMng:SetBuildingRP(buildingId, true)
        td.dispatchEvent(td.BUILDING_UPGRADE, buildingId)
      end
      td.alert(g_LM:getBy("a00360") .. buildingId .. g_LM:getBy("a00361") .. buildingLvl .. g_LM:getBy("a00362") .. buildingNum)
    end
  elseif data.type == td.HBType.Chat then
    self.m_chatDlg:SetChannelUpdate(tonumber(data.num))
    local rp = SkeletonUnit:create("Spine/UI_effect/UI_kezhitishi_01")
    rp:PlayAni("animation", true)
    if not g_MC:IsModuleShowing(td.UIModule.Chat) then
      td.ShowRP(self.m_chatDlg:GetBg(), true, cc.p(0.5, 0.5), rp)
    end
  end
end
return GuildScene
