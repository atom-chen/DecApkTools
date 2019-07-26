local TDHttpRequest = require("app.net.TDHttpRequest")
local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local GuildInfo = require("app.layers.guild.GuildInfo")
local GuildClickInfoDlg = class("GuildClickInfoDlg", BaseDlg)
function GuildClickInfoDlg:ctor(uid)
  GuildClickInfoDlg.super.ctor(self)
  self.m_gdm = UserDataManager:GetInstance():GetGuildManager()
  self.m_type = self.m_gdm:GetSelfData().type
  self.m_targetType = nil
  self.m_btns = {}
  self:SetData(uid)
  self:setNodeEventEnabled(true)
end
function GuildClickInfoDlg:onEnter()
  GuildClickInfoDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.PlayerDetail, handler(self, self.GetPlayerInfoCallback))
  if self.m_useData then
    self:InitUI()
    self:AddEvents()
  else
    self:SendGetPlayerInfoReq(self.m_userId)
  end
end
function GuildClickInfoDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.PlayerDetail)
  GuildClickInfoDlg.super.onExit(self)
end
function GuildClickInfoDlg:SetData(userId)
  self.m_userId = userId
  self.m_useData = UserDataManager:GetInstance():GetOtherData(userId)
  self.m_gdm:RemoveRPMember(self.m_userId)
end
function GuildClickInfoDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/guild/GuildClickInfo.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_pPanelBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local inFunc = function(data)
    local parent = data.parent
    local node = data.node
    parent:addChild(node)
    node:setPosition(data.pos)
    if data.ancPos then
      node:setAnchorPoint(data.ancPos)
    end
  end
  local portraitInfo = require("app.info.CommanderInfoManager"):GetInstance():GetPortraitInfo(self.m_useData.image_id)
  local pTmpNode = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Image_head")
  pTmpNode:loadTexture(portraitInfo.file .. td.PNG_Suffix)
  local nameLabel = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_name")
  nameLabel:setString(self.m_useData.uname)
  local idLabel = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_id")
  idLabel:setString(g_LM:getBy("a00105") .. ":")
  local idData = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_idData")
  idData:setString(self.m_useData.fid)
  local lvlLabel = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_lvl")
  lvlLabel:setString(g_LM:getBy("a00064") .. ":")
  self.m_lvlData = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_lvlData")
  local posLabel = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_position")
  posLabel:setString(g_LM:getBy("g00038") .. ":")
  self.m_posData = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_posData")
  local contriLabel = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_contri")
  contriLabel:setString(g_LM:getBy("g00025") .. ":")
  local contriData = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_contriData")
  contriData:setString(self.m_gdm:GetMemberData(self.m_useData.fid).contribute)
  local powerLabel = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_power")
  powerLabel:setString(g_LM:getBy("a00032") .. ":")
  local powerData = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_powerData")
  powerData:setString(self.m_useData.attack)
  local honorLabel = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_honor")
  honorLabel:setString(g_LM:getBy("a00037") .. ": ")
  local honorInfo = require("app.info.CommanderInfoManager"):GetInstance():GetHonorInfoByRepu(self.m_useData.reputation)
  local image = honorInfo.image .. td.PNG_Suffix
  local pHonorLabel = td.RichText({
    {
      type = 2,
      file = image,
      scale = 0.45
    },
    {
      type = 1,
      color = td.WHITE,
      size = 20,
      str = honorInfo.military_rank
    }
  })
  local honorPos = cc.p(honorLabel:getPosition())
  local honorSize = honorLabel:getContentSize()
  pHonorLabel:pos(honorPos.x + honorSize.width + 50, honorPos.y):addTo(self.m_pPanelBg)
  self:RefreshUI()
end
function GuildClickInfoDlg:AddButtons()
  if self.m_type == td.GuildPos.Master or self.m_type == td.GuildPos.ViceMaster then
    self.btnPromote = td.CreateBtn(td.BtnType.GreenShort)
    self.btnPromote:addTo(self.m_pPanelBg)
    self.btnPromote:pos(125, 120)
    self.btnPromote:setName("promote")
    table.insert(self.m_btns, self.btnPromote)
    td.BtnSetTitle(self.btnPromote, g_LM:getBy("g00034"))
    self.btnDemote = td.CreateBtn(td.BtnType.GreenShort)
    self.btnDemote:addTo(self.m_pPanelBg)
    self.btnDemote:pos(305, 120)
    table.insert(self.m_btns, self.btnDemote)
    self.btnDemote:setName("demote")
    td.BtnSetTitle(self.btnDemote, g_LM:getBy("g00035"))
    self.btnKick = td.CreateBtn(td.BtnType.BlueShort)
    self.btnKick:addTo(self.m_pPanelBg)
    self.btnKick:pos(125, 60)
    table.insert(self.m_btns, self.btnKick)
    self.btnKick:setName("kick")
    td.BtnSetTitle(self.btnKick, g_LM:getBy("g00036"))
    self.btnAddFrnd = td.CreateBtn(td.BtnType.BlueShort)
    self.btnAddFrnd:addTo(self.m_pPanelBg)
    self.btnAddFrnd:pos(305, 60)
    table.insert(self.m_btns, self.btnAddFrnd)
    self.btnAddFrnd:setName("addFriend")
    td.BtnSetTitle(self.btnAddFrnd, g_LM:getBy("g00037"))
    for i = 1, 3 do
      td.BtnAddTouch(self.m_btns[i], handler(self, function()
        self:OnBtnClicked(self.m_btns[i]:getName())
      end))
    end
    td.BtnAddTouch(self.btnAddFrnd, handler(self, function()
      UserDataManager:GetInstance():SendAddFriendReq(self.m_userId)
    end))
  else
    self.btnAddFrnd = td.CreateBtn(td.BtnType.BlueShort)
    self.btnAddFrnd:addTo(self.m_pPanelBg)
    self.btnAddFrnd:pos(215, 90)
    table.insert(self.m_btns, self.btnAddFrnd)
    self.btnAddFrnd:setName("addFriend")
    td.BtnSetTitle(self.btnAddFrnd, g_LM:getBy("g00037"))
    td.BtnAddTouch(self.btnAddFrnd, handler(self, function()
      UserDataManager:GetInstance():SendAddFriendReq(self.m_userId)
    end))
  end
end
function GuildClickInfoDlg:OnBtnClicked(name)
  local strs = {
    promote = "\229\141\135\232\129\140",
    demote = "\233\153\141\232\129\140",
    kick = "\232\184\162\229\135\186\229\134\155\229\155\162"
  }
  local conStr
  local c_type = self.m_gdm:GetMemberData(self.m_userId).type
  if name == "promote" and c_type - 1 == td.GuildPos.Master then
    conStr = "\231\161\174\229\174\154\232\166\129\229\176\134\228\187\150\230\153\139\229\141\135\228\184\186\228\188\154\233\149\191\229\144\151\239\188\159\239\188\136\232\135\170\229\183\177\229\176\134\233\153\141\228\184\186\229\137\175\228\188\154\233\149\191\239\188\137"
  else
    conStr = string.format("\231\161\174\229\174\154\232\166\129\229\176\134\228\187\150%s\229\144\151\239\188\159", strs[name])
  end
  local function cb()
    self:DisableAllBtns()
    local c_type = self.m_gdm:GetMemberData(self.m_userId).type
    if name == "promote" then
      if c_type > self.m_type then
        local data = {
          uid = self.m_userId,
          type = c_type - 1
        }
        self.m_targetType = c_type - 1
        self.m_gdm:SendRequest(data, td.RequestID.ModifyMemberPosition)
      end
    elseif name == "demote" then
      if c_type > self.m_type then
        local data = {
          uid = self.m_userId,
          type = c_type + 1
        }
        self.m_targetType = c_type + 1
        self.m_gdm:SendRequest(data, td.RequestID.ModifyMemberPosition)
      end
    elseif name == "kick" and c_type > self.m_type then
      local data = {
        uid = self.m_userId,
        type = 0
      }
      self.m_targetType = 0
      self.m_gdm:SendRequest(data, td.RequestID.ModifyMemberPosition)
    end
  end
  local button1 = {
    text = g_LM:getBy("a00009"),
    callFunc = cb
  }
  local button2 = {
    text = g_LM:getBy("a00116")
  }
  local data = {
    size = cc.size(454, 300),
    content = conStr,
    buttons = {button1, button2}
  }
  local messageBox = require("app.layers.MessageBoxDlg").new(data)
  messageBox:Show()
end
function GuildClickInfoDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_pPanelBg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_pPanelBg, tmpPos) then
      self:performWithDelay(function(times)
        self:close()
      end, 0.016666666666666666)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.GUILD_RANK_CHANGED, handler(self, self.RefreshUI))
end
function GuildClickInfoDlg:RefreshUI()
  if self.m_targetType == 0 then
    self:close()
    return
  end
  self:RefreshDetail()
  self.m_type = self.m_gdm:GetSelfData().type
  local c_type = self.m_gdm:GetMemberData(self.m_userId).type
  for key, value in ipairs(self.m_btns) do
    value:removeFromParent()
  end
  self.m_btns = {}
  self:AddButtons()
  if self.m_type < td.GuildPos.Administrator then
    if c_type <= self.m_type then
      self.btnPromote:setDisable(true)
      self.btnDemote:setDisable(true)
      self.btnKick:setDisable(true)
    elseif self.m_type > td.GuildPos.Master then
      if c_type == td.GuildPos.Member then
        self.btnPromote:setDisable(false)
        self.btnDemote:setDisable(true)
      else
        self.btnPromote:setDisable(true)
        self.btnDemote:setDisable(false)
      end
      self.btnKick:setDisable(false)
    elseif self.m_type == td.GuildPos.Master then
      self.btnPromote:setDisable(false)
      if c_type == td.GuildPos.Member then
        self.btnDemote:setDisable(true)
      else
        self.btnDemote:setDisable(false)
      end
      self.btnKick:setDisable(false)
    end
  end
end
function GuildClickInfoDlg:RefreshDetail()
  self.m_lvlData = cc.uiloader:seekNodeByName(self.m_pPanelBg, "Text_lvlData")
  self.m_lvlData:setString(self.m_useData.level)
  local pos = self.m_gdm:GetMemberData(self.m_useData.fid).type
  self.m_posData:setString(g_LM:getMode("guildPos", pos))
end
function GuildClickInfoDlg:SendGetPlayerInfoReq(id)
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.PlayerDetail
  Msg.sendData = {fid = id}
  tdRequest:Send(Msg)
end
function GuildClickInfoDlg:GetPlayerInfoCallback(data)
  self.m_useData = data
  UserDataManager:GetInstance():AddOtherData(data)
  self:InitUI()
  self:AddEvents()
end
function GuildClickInfoDlg:DisableAllBtns()
  for key, btn in ipairs(self.m_btns) do
    btn:setDisable(true)
  end
end
return GuildClickInfoDlg
