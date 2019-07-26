local GuildContentBase = require("app.layers.guild.GuildContentBase")
local UserDataManager = require("app.UserDataManager")
local GuildDataManager = require("app.GuildDataManager")
local ChooseGuildType = require("app.widgets.ChooseGuildType")
local CommanderInfoManager = require("app.info.CommanderInfoManager")
local DropdownList = require("app.widgets.DropdownList")
local TDHttpRequest = require("app.net.TDHttpRequest")
local GuildInfo = class("GuildInfo", GuildContentBase)
function GuildInfo:ctor(height)
  GuildInfo.super.ctor(self, height)
  self.m_gdm = GuildDataManager:GetInstance()
  self.guildMemberList = self.m_gdm:GetGuildMemberList()
  self.guildData = self.m_gdm:GetGuildData()
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function GuildInfo:onEnter()
  self:AddTouch()
  self:AddListeners()
  self:AddButtonEvents()
end
function GuildInfo:onExit()
  self:RemoveListeners()
  GuildInfo.super.onExit(self)
end
function GuildInfo:AddListeners()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.ApplyGuild, handler(self, self.LeaveCallback))
  self:AddCustomEvent(td.GUILD_RANK_CHANGED, handler(self, self.RefreshList))
  self:AddCustomEvent(td.GUILD_LISTS_REFRESH, handler(self, self.RefreshList))
end
function GuildInfo:RemoveListeners()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.ApplyGuild)
end
function GuildInfo:InitUI()
  self:InitUIRoot()
  self:DisplayData()
  self:CreateList()
  self:RefreshList()
end
function GuildInfo:InitUIRoot()
  self:LoadUI("CCS/guild/GuildInfo.csb")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_deco = cc.uiloader:seekNodeByName(self.m_bg, "Image_decoration")
  self.m_nickname = cc.uiloader:seekNodeByName(self.m_deco, "Text_nickname")
  self.m_nickname:setString(g_LM:getBy("g00023"))
  self.m_lvl = cc.uiloader:seekNodeByName(self.m_deco, "Text_lvl")
  self.m_lvl:setString(g_LM:getBy("a00064"))
  self.m_contri = cc.uiloader:seekNodeByName(self.m_deco, "Text_contribution")
  self.m_contri:setString(g_LM:getBy("g00025"))
  self.m_position = cc.uiloader:seekNodeByName(self.m_deco, "Text_position")
  self.m_position:setString(g_LM:getBy("g00026"))
  self.m_buttonLeave = cc.uiloader:seekNodeByName(self.m_bg, "Button_leave")
  td.BtnSetTitle(self.m_buttonLeave, g_LM:getBy("g00033"))
  self.m_buttonApp = cc.uiloader:seekNodeByName(self.m_bg, "Button_applications")
  td.BtnSetTitle(self.m_buttonApp, g_LM:getBy("g00032"))
  self:GuildTypeInfo()
end
function GuildInfo:AddButtonEvents()
  td.BtnAddTouch(self.m_buttonLeave, function()
    if self.m_gdm:GetSelfData().type ~= td.GuildPos.Master then
      local data = {
        guild_id = self.guildData.id,
        type = td.GuildAction.Quit
      }
      self:SendLeaveRequest(data)
    else
      td.alert(g_LM:getBy("a00332"))
    end
  end)
  if self.m_gdm:GetSelfData().type == td.GuildPos.Pending or self.m_gdm:GetSelfData().type == td.GuildPos.Member then
    self.m_buttonApp:setVisible(false)
  else
    td.BtnAddTouch(self.m_buttonApp, function()
      local tmpNode = require("app.layers.guild.GuildApplyAdmitDlg").new()
      td.popView(tmpNode, true)
    end)
  end
end
function GuildInfo:GuildTypeInfo()
  local myPosition = self.m_gdm:GetSelfData().type
  local guildType = self.guildData.audit
  local node = cc.uiloader:seekNodeByName(self.m_bg, "Node_choose_type")
  local posX, posY = node:getPosition()
  if myPosition == td.GuildPos.Master then
    local node1 = {
      normalBg = "UI/guild/leixingdikuang.png",
      callfunc = handler(self, self.UpdateGuildType),
      str = g_LM:getBy("g00016")
    }
    local node2 = {
      normalBg = "UI/guild/leixingdikuang.png",
      callfunc = handler(self, self.UpdateGuildType),
      str = g_LM:getBy("g00017")
    }
    local dropdownConfig = {node1, node2}
    local chooseGuildType = DropdownList.new(dropdownConfig, {
      initIndex = guildType + 1,
      fontSize = 20
    })
    chooseGuildType:addTo(self.m_bg)
    chooseGuildType:setPosition(posX, posY)
  else
    local guildTypeSpr = display.newSprite("UI/guild/leixingdikuang.png")
    local typeString = td.CreateLabel(g_LM:getBy("g0001" .. 6 + guildType), td.WHITE, 20)
    td.AddRelaPos(guildTypeSpr, typeString)
    guildTypeSpr:addTo(self.m_bg)
    guildTypeSpr:pos(posX, posY)
  end
end
function GuildInfo:DisplayData()
  self.m_emblem = cc.uiloader:seekNodeByName(self.m_bg, "Image_emblem")
  self.m_name = cc.uiloader:seekNodeByName(self.m_bg, "Text_name")
  self.m_size = cc.uiloader:seekNodeByName(self.m_bg, "Text_number")
  self.m_size:setString(g_LM:getBy("g00029") .. ": ")
  local pos = cc.p(self.m_size:getPosition())
  local size = self.m_size:getContentSize()
  self.m_sizeData = td.CreateLabel(" ", td.WHITE, 20)
  self.m_sizeData:setAnchorPoint(0, 0.5)
  self.m_sizeData:pos(pos.x + size.width + 5, pos.y):addTo(self.m_bg)
  self.m_myRank = cc.uiloader:seekNodeByName(self.m_bg, "Text_my_rank")
  self.m_myRank:setString(g_LM:getBy("g00014") .. ": ")
  pos = cc.p(self.m_myRank:getPosition())
  size = self.m_myRank:getContentSize()
  self.m_myRankData = td.CreateLabel(" ")
  self.m_myRankData:setAnchorPoint(0, 0.5)
  self.m_myRankData:pos(pos.x + size.width + 5, pos.y):addTo(self.m_bg)
  self.m_rank = cc.uiloader:seekNodeByName(self.m_bg, "Text_guild_rank")
  self.m_rank:setString(g_LM:getBy("g00012") .. ": ")
  pos = cc.p(self.m_rank:getPosition())
  size = self.m_rank:getContentSize()
  self.m_rankData = td.CreateLabel(" ", td.WHITE, 20)
  self.m_rankData:setAnchorPoint(0, 0.5)
  self.m_rankData:pos(pos.x + size.width + 5, pos.y):addTo(self.m_bg)
  self.m_type = cc.uiloader:seekNodeByName(self.m_bg, "Text_guild_type")
  self.m_type:setString(g_LM:getBy("g00015"))
  self.m_level = cc.uiloader:seekNodeByName(self.m_bg, "Text_lvl")
  self.m_level:setString(g_LM:getBy("a00064") .. ": ")
  pos = cc.p(self.m_level:getPosition())
  size = self.m_level:getContentSize()
  self.m_levelData = td.CreateLabel(" ", td.WHITE, 20)
  self.m_levelData:setAnchorPoint(0, 0.5)
  self.m_levelData:pos(pos.x + size.width + 5, pos.y):addTo(self.m_bg)
  self.m_id = cc.uiloader:seekNodeByName(self.m_bg, "Text_guild_id")
  self.m_id:setString(g_LM:getBy("g00013") .. ": ")
  pos = cc.p(self.m_id:getPosition())
  size = self.m_id:getContentSize()
  self.m_idData = td.CreateLabel(" ", td.WHITE, 20)
  self.m_idData:setAnchorPoint(0, 0.5)
  self.m_idData:pos(pos.x + size.width + 5, pos.y):addTo(self.m_bg)
  self:RefreshGuildInfo()
end
function GuildInfo:RefreshGuildInfo()
  self.m_emblem:loadTexture("UI/icon/guild/" .. self.guildData.guild_emblem .. ".png")
  self.m_name:setString(self.guildData.guild_name)
  self.m_sizeData:setString(string.format("%d/%d", self.guildData.size, self.guildData.level * 2 + 20))
  self.m_myRankData:setString(self:GetMyRankInGuild())
  self.m_rankData:setString(self.guildData.rank)
  self.m_levelData:setString("LV." .. self.guildData.level)
  self.m_idData:setString(self.guildData.id)
end
function GuildInfo:GetMyRankInGuild()
  local guildList = clone(self.m_gdm:GetGuildMemberList())
  table.sort(guildList, function(a, b)
    return a.contribute > b.contribute
  end)
  for key, val in ipairs(guildList) do
    if val.uid == UserDataManager:GetInstance():GetUId() then
      return key or 0
    end
  end
end
function GuildInfo:CreateList()
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 860, self.m_bgHeight - 235),
    touchOnContent = false,
    scale = td.GetAutoScale()
  })
  self.m_UIListView:onTouch(function(event)
    local myId = UserDataManager:GetInstance():GetUId()
    if "clicked" == event.name and event.item and myId ~= self.guildMemberList[event.itemPos].uid then
      local uid = self.guildMemberList[event.itemPos].uid
      for key, value in ipairs(self.guildMemberList) do
        if value.uid == UserDataManager:GetInstance():GetUId() then
          local tmpNode = require("app.layers.guild.GuildClickInfoDlg").new(uid)
          td.popView(tmpNode, true)
        end
      end
    end
  end)
  self.m_UIListView:setAnchorPoint(cc.p(0, 0))
  self.m_UIListView:pos(30, 20)
  self.m_bg:addChild(self.m_UIListView, 1)
end
function GuildInfo:RefreshList()
  self.m_UIListView:removeAllItems()
  table.sort(self.guildMemberList, function(a, b)
    return a.type < b.type
  end)
  self:RefreshGuildInfo()
  self.guildMemberList = self.m_gdm:GetGuildMemberList()
  local list = self.m_gdm:GetRPMembers()
  if #self.m_gdm:GetPendingMembers() > 0 then
    td.ShowRP(self.m_buttonApp, true)
  else
    td.ShowRP(self.m_buttonApp, false)
  end
  for key, var in ipairs(self.guildMemberList) do
    if var.type <= td.GuildPos.Member then
      local item = self:CreateItem(var)
      self.m_UIListView:addItem(item)
    end
  end
  self.m_UIListView:reload()
end
function GuildInfo:ShowRPonMembers()
  for key, val in ipairs(clone(self.m_gdm:GetRPMembers())) do
    for i, member in ipairs(self.m_gdm:GetGuildMemberList()) do
      if val == member.uid then
        local itemHead = cc.uiloader:seekNodeByName(self.m_UIListView:getItemByPos(i):getContent(), "head")
        td.ShowRP(itemHead, true, cc.p(0.5, 0.5))
        self.m_gdm:RemoveRPMember(val)
      end
    end
  end
end
function GuildInfo:CreateItem(itemData)
  local itemNode = cc.uiloader:load("CCS/guild/MemberListItem.csb")
  local itemBg = cc.uiloader:seekNodeByName(itemNode, "Panel_content")
  if itemData.uid == UserDataManager:GetInstance():GetUId() then
    local bg = itemBg:getChildByName("Image_bg")
    bg:loadTexture("UI/scale9/juntuan_dikuang.png")
  else
    local timeLabel = cc.uiloader:seekNodeByName(itemBg, "Text_time")
    timeLabel:setString(td.GetSimpleTime(itemData.login_time))
  end
  local avatar = cc.uiloader:seekNodeByName(itemBg, "Image_avatar")
  avatar:setName("head")
  local portraitInfo = CommanderInfoManager:GetInstance():GetPortraitInfo(itemData.u_image)
  avatar:loadTexture(portraitInfo.file .. td.PNG_Suffix)
  local username = cc.uiloader:seekNodeByName(itemBg, "Text_nickname")
  username:setString(itemData.u_name)
  local level = cc.uiloader:seekNodeByName(itemBg, "Text_lvl")
  level:setString(itemData.u_level)
  local position = cc.uiloader:seekNodeByName(itemBg, "Text_position")
  position:setString(g_LM:getMode("guildPos", itemData.type))
  local contribution = cc.uiloader:seekNodeByName(itemBg, "Text_contribution")
  contribution:setString(itemData.max_con)
  local ITEM_SIZE = cc.size(860, 80)
  local item = self.m_UIListView:newItem(itemNode)
  item:setAnchorPoint(cc.p(0.5, 0.5))
  item:setItemSize(ITEM_SIZE.width * self.m_scale, ITEM_SIZE.height * self.m_scale)
  item:setScale(self.m_scale)
  return item
end
function GuildInfo:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if not self:isVisible() then
      return false
    end
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
      return true
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
end
function GuildInfo:UpdateGuildType(currType)
  GuildDataManager:SendModifyGuildRequest({
    guild_type = currType - 1
  })
end
function GuildInfo:SendLeaveRequest(data)
  local Msg = {}
  Msg.msgType = td.RequestID.ApplyGuild
  Msg.sendData = data
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildInfo:LeaveCallback(data)
  if data.state == td.ResponseState.Success then
    self.m_gdm:UpdateData(nil, {})
    td.dispatchEvent(td.GUILD_UPDATE)
  end
end
return GuildInfo
