local GuildContentBase = require("app.layers.guild.GuildContentBase")
local TDHttpRequest = require("app.net.TDHttpRequest")
local GuildEmblemConfig = require("app.config.GuildEmblem")
local UserDataManager = require("app.UserDataManager")
local SearchGuild = class("SearchGuild", GuildContentBase)
SearchGuild.PerStr = {
  [td.GuildType.Anyone] = g_LM:getBy("g00016"),
  [td.GuildType.Permission] = g_LM:getBy("g00017")
}
function SearchGuild:ctor(height)
  SearchGuild.super.ctor(self, height)
  self.m_gdm = UserDataManager:GetInstance():GetGuildManager()
  self.guildList = {}
  self.m_applyState = 0
  self.m_scale = td.GetAutoScale()
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function SearchGuild:onEnter()
  self:AddTouch()
  self:AddListeners()
end
function SearchGuild:onExit()
  self:RemoveListeners()
  SearchGuild.super.onExit(self)
end
function SearchGuild:AddListeners()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetGuildList, handler(self, self.GetGuildList))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.ApplyGuild, handler(self, self.ApplyGuildCallback))
end
function SearchGuild:RemoveListeners()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetGuildList)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.ApplyGuild)
end
function SearchGuild:InitUI()
  self:LoadUI("CCS/guild/SearchGuild.csb")
  self.m_pBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local infoPanel = cc.uiloader:seekNodeByName(self.m_pBg, "Image_decoration")
  local nameInfo = td.CreateLabel(g_LM:getBy("g00027"), td.WHITE, 20)
  td.AddRelaPos(infoPanel, nameInfo, 1, cc.p(0.191, 0.5))
  local lvlInfo = td.CreateLabel(g_LM:getBy("a00064"), td.WHITE, 20)
  td.AddRelaPos(infoPanel, lvlInfo, 1, cc.p(0.362, 0.5))
  local numInfo = td.CreateLabel(g_LM:getBy("g00029"), td.WHITE, 20)
  td.AddRelaPos(infoPanel, numInfo, 1, cc.p(0.495, 0.5))
  local typeInfo = td.CreateLabel(g_LM:getBy("g00030"), td.WHITE, 20)
  td.AddRelaPos(infoPanel, typeInfo, 1, cc.p(0.667, 0.5))
  self.m_tf_input = ccui.EditBox:create(cc.size(838, 42), "UI/scale9/wenzishurukuang.png")
  self.m_tf_input:setPlaceHolder(g_LM:getBy("g00043"))
  self.m_tf_input:setFontSize(20)
  self.m_tf_input:setMaxLength(10)
  local inputNode = cc.uiloader:seekNodeByName(self.m_pBg, "Node_input")
  local posX, posY = inputNode:getPosition()
  self.m_tf_input:addTo(self.m_pBg)
  self.m_tf_input:pos(posX, posY)
  self.m_send_btn = ccui.Button:create("UI/guild/sousuo_icon.png", "UI/guild/sousuo_icon.png")
  td.BtnAddTouch(self.m_send_btn, function()
    local data
    if not tonumber(self.m_tf_input:getText()) then
      data = {
        guild_name = self.m_tf_input:getText(),
        guild_id = nil
      }
    else
      data = {
        guild_name = nil,
        guild_id = tonumber(self.m_tf_input:getText())
      }
    end
    self:SendRequest(data, td.RequestID.GetGuildList)
  end)
  td.AddRelaPos(self.m_tf_input, self.m_send_btn, 1, cc.p(0.95, 0.5))
  self:CreateList()
  self:SendRequest(nil, td.RequestID.GetGuildList)
end
function SearchGuild:CreateList()
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 860, self.m_bgHeight - 135),
    touchOnContent = false,
    scale = td.GetAutoScale()
  })
  self.m_UIListView:setAnchorPoint(cc.p(0, 0))
  self.m_UIListView:pos(30, 20)
  self.m_pBg:addChild(self.m_UIListView, 1)
end
function SearchGuild:RefreshList()
  self.m_UIListView:removeAllItems()
  for key, var in ipairs(self.guildList) do
    local item = self:CreateItem(var)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function SearchGuild:CreateItem(itemData)
  local itemNode = cc.uiloader:load("CCS/guild/GuildListItem.csb")
  local itemBg = cc.uiloader:seekNodeByName(itemNode, "Panel_content")
  local bgSize = itemBg:getContentSize()
  local emblem = cc.uiloader:seekNodeByName(itemBg, "Image_emblem")
  emblem:loadTexture(GuildEmblemConfig[itemData.guild_emblem])
  local guildName = cc.uiloader:seekNodeByName(itemBg, "Text_guild_name")
  guildName:setString(itemData.guild_name)
  local guildLvl = cc.uiloader:seekNodeByName(itemBg, "Text_guild_lvl")
  guildLvl:setString(itemData.level)
  local guildNumber = cc.uiloader:seekNodeByName(itemBg, "Text_guild_limit")
  guildNumber:setString(itemData.size .. "/" .. 22 + 2 * (itemData.level - 1))
  local guildPermission = cc.uiloader:seekNodeByName(itemBg, "Text_guild_permission")
  guildPermission:setString(SearchGuild.PerStr[itemData.audit])
  local confirmBtn = cc.uiloader:seekNodeByName(itemBg, "Button_apply")
  td.BtnSetTitle(confirmBtn, g_LM:getBy("g00031"))
  if itemData.size == itemData.level * 2 + 22 then
    td.BtnSetTitle(confirmBtn, g_LM:getBy("g00044"))
    confirmBtn:setDisable(true)
  end
  for key, appliedID in ipairs(self.m_gdm:GetAppliedGuilds()) do
    if appliedID == itemData.id then
      td.BtnSetTitle(confirmBtn, g_LM:getBy("g00045"))
      confirmBtn:setDisable(true)
    end
  end
  td.BtnAddTouch(confirmBtn, function()
    local data = {
      guild_id = itemData.id,
      type = td.GuildAction.Apply
    }
    self:SendRequest(data, td.RequestID.ApplyGuild)
  end)
  local lineSpr = display.newSprite("UI/common/fengexian_shu.png")
  lineSpr:setScaleX(bgSize.width / lineSpr:getContentSize().width)
  td.AddRelaPos(itemBg, lineSpr, 1, cc.p(0.5, 0))
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize(bgSize.width * self.m_scale, (bgSize.height + 20) * self.m_scale)
  item:setScale(self.m_scale)
  item:setAnchorPoint(cc.p(0.5, 0.5))
  return item
end
function SearchGuild:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if not self:isVisible() then
      return
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
function SearchGuild:SendRequest(data, reqID)
  local Msg = {}
  Msg.msgType = reqID
  if data then
    Msg.sendData = data
    Msg.cbData = clone(data)
  end
  TDHttpRequest:getInstance():Send(Msg)
end
function SearchGuild:GetGuildList(data)
  self.guildList = data.guildProtos
  print(#self.guildList)
  for key, val in ipairs(data.guild_id) do
    self.m_gdm:SetAppliedGuilds(val)
  end
  self:RefreshList()
end
function SearchGuild:ApplyGuildCallback(data, cbdata)
  local guildData = data.guildProto
  local guildMemberList = data.guildMemberProto
  if data.state == td.ResponseState.Success then
    if #guildMemberList > 0 then
      self.m_gdm:UpdateData(guildData, guildMemberList)
      td.dispatchEvent(td.GUILD_UPDATE)
    elseif cbdata then
      self.m_gdm:SetAppliedGuilds(cbdata.guild_id)
      td.alert(g_LM:getBy("a00338"))
      self:RefreshList()
    end
  end
end
return SearchGuild
