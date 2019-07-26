local GuildContentBase = require("app.layers.guild.GuildContentBase")
local UserDataManager = require("app.UserDataManager")
local GuildEmblemConfig = require("app.config.GuildEmblem")
local CreateGuild = class("CreateGuild", GuildContentBase)
local TypeButtonGroup = {
  off = "UI/guild/yuan_aocao.png",
  on = "UI/guild/yuan_xuanzhong.png"
}
function CreateGuild:ctor(height)
  CreateGuild.super.ctor(self, height)
  self.m_guildEmblem = 1
  self.m_guildType = 0
  self.m_gdm = UserDataManager:GetInstance():GetGuildManager()
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function CreateGuild:onEnter()
  self:AddBtnEvents()
end
function CreateGuild:onExit()
  CreateGuild.super.onExit(self)
end
function CreateGuild:InitUI()
  self:InitUIRoot()
  self:InitInputGuildName()
  self:InitChooseEmblem()
  self:InitChooseType()
end
function CreateGuild:InitUIRoot()
  self:LoadUI("CCS/guild/CreateGuild.csb")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.txtGuildName = cc.uiloader:seekNodeByName(self.m_bg, "FNTText_name")
  self.txtGuildName:setString(g_LM:getBy("g00019"))
  self.txtGuildEmblem = cc.uiloader:seekNodeByName(self.m_bg, "FNTText_emblem")
  self.txtGuildEmblem:setString(g_LM:getBy("g00020"))
  self.txtGuildType = cc.uiloader:seekNodeByName(self.m_bg, "FNTText_type")
  self.txtGuildType:setString(g_LM:getBy("g00015"))
  self.m_pSend = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_create")
  td.BtnSetTitle(self.m_pSend, g_LM:getBy("g00022"))
end
function CreateGuild:InitInputGuildName()
  self.m_tf_input = ccui.EditBox:create(cc.size(400, 42), "UI/scale9/wenzishurukuang.png")
  self.m_tf_input:setPosition(cc.p(490, self.txtGuildName:getPositionY()))
  self.m_tf_input:setFontSize(20)
  self.m_tf_input:setMaxLength(10)
  self.m_tf_input:setPlaceHolder("\232\175\183\232\190\147\229\133\165\229\134\155\229\155\162\229\144\141\231\167\176")
  self.m_bg:addChild(self.m_tf_input)
end
function CreateGuild:InitChooseEmblem()
  self.m_emblemPageview = cc.ui.UIPageView.new({
    viewRect = cc.rect(397, self.txtGuildEmblem:getPositionY() - 70, 145, 140),
    column = 1,
    row = 1,
    scale = self.m_scale
  })
  self.m_emblemPageview:addTo(self.m_bg)
  for i = 1, table.getn(GuildEmblemConfig) do
    local item = self.m_emblemPageview:newItem()
    local content = display.newSprite(GuildEmblemConfig[i])
    content:setTouchEnabled(true)
    content:setAnchorPoint(0, 0)
    content:setContentSize(145, 140)
    content:setPosition(0, 0)
    item:addChild(content)
    self.m_emblemPageview:addItem(item)
  end
  self.m_emblemPageview:setTouchEnabled(true)
  self.m_emblemPageview:reload()
  self.m_btnLeft = cc.uiloader:seekNodeByName(self.m_bg, "Button_left")
  td.BtnAddTouch(self.m_btnLeft, function()
    if self.m_guildEmblem > 1 then
      self.m_guildEmblem = self.m_guildEmblem - 1
    end
    self.m_emblemPageview:gotoPage(self.m_guildEmblem)
  end)
  self.m_btnRight = cc.uiloader:seekNodeByName(self.m_bg, "Button_right")
  td.BtnAddTouch(self.m_btnRight, function()
    if self.m_guildEmblem < table.getn(GuildEmblemConfig) then
      self.m_guildEmblem = self.m_guildEmblem + 1
    end
    self.m_emblemPageview:gotoPage(self.m_guildEmblem)
  end)
end
function CreateGuild:InitChooseType()
  local label = cc.ui.UILabel.new({
    text = g_LM:getBy("a00156"),
    font = td.DEFAULT_FONT,
    size = 18,
    color = cc.c3b(102, 238, 255),
    align = cc.ui.TEXT_ALIGN_LEFT,
    valign = cc.ui.TEXT_VALIGN_TOP,
    dimensions = cc.size(540, 200)
  })
  local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT):addButton(cc.ui.UICheckBoxButton.new(TypeButtonGroup):setButtonLabel(cc.ui.UILabel.new({
    text = g_LM:getBy("g00016"),
    size = 18,
    font = td.DEFAULT_FONT,
    color = td.WHITE
  })):setButtonLabelOffset(20, 2):align(display.LEFT_CENTER)):addButton(cc.ui.UICheckBoxButton.new(TypeButtonGroup):setButtonLabel(cc.ui.UILabel.new({
    text = g_LM:getBy("g00017"),
    size = 18,
    font = td.DEFAULT_FONT,
    color = td.WHITE
  })):setButtonLabelOffset(20, 2):align(display.LEFT_CENTER)):setButtonsLayoutMargin(10, 10, 10, 10):onButtonSelectChanged(function(event)
    self.m_guildType = event.selected - 1
  end):addTo(self.m_bg)
  group:setPosition(310, self.txtGuildType:getPositionY() - 25)
  group:getButtonAtIndex(1):setButtonSelected(true)
end
function CreateGuild:AddListeners()
end
function CreateGuild:AddBtnEvents()
  td.BtnAddTouch(self.m_pSend, function()
    self:CheckCanSend()
  end)
end
function CreateGuild:CheckCanSend()
  local str = self.m_tf_input:getText()
  if str == "" then
    td.alert(g_LM:getBy("a00328"))
  elseif not td.CheckStringLength(str, 10) then
    td.alert(g_LM:getBy("a00329"))
  else
    self:SendCreateGuildReq(str)
  end
end
function CreateGuild:SendCreateGuildReq(name)
  self.m_gdm:SendRequest({
    guild_name = name,
    guild_emblem = self.m_guildEmblem,
    guild_type = self.m_guildType
  }, td.RequestID.CreateGuild)
end
return CreateGuild
