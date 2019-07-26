local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local GuildInfoManager = require("app.info.GuildInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local RoundProgressBar = require("app.widgets.RoundProgressBar")
local GuildDonateDlg = class("GuildDonateDlg", BaseDlg)
function GuildDonateDlg:ctor(id)
  GuildDonateDlg.super.ctor(self)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_gdMng = self.m_udMng:GetGuildManager()
  self.m_id = id
  self.m_data = self.m_gdMng:GetBuildData(id)
  self.m_time = self.m_gdMng:GetSelfData().num[id]
  self.m_info = GuildInfoManager:GetInstance():GetBuildingInfo(id)
  self.m_itemId = self.m_info.donate[1]
  self.m_donateCnt = math.floor(self.m_info.donate[2] + self.m_udMng:GetBaseCampLevel() * self.m_info.donate[3])
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function GuildDonateDlg:onEnter()
  GuildDonateDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.ContributeToGuild, handler(self, self.ContributeCallback))
  self:AddEvents()
end
function GuildDonateDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.ContributeToGuild)
  GuildDonateDlg.super.onExit(self)
end
function GuildDonateDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  local panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  local bgSize = cc.size(500, 330)
  self.m_bg = display.newScale9Sprite("UI/scale9/yijitankuang2.png", 0, 0, bgSize, cc.rect(110, 80, 5, 2))
  td.AddRelaPos(panel, self.m_bg)
  local spineBg = display.newSprite("UI/guild/zhuangshidikuang.png")
  td.AddRelaPos(self.m_bg, spineBg, 1, cc.p(0.28, 0.5))
  local rank = math.floor((self.m_data.level - 1) / 3) + 1
  self.m_spine = SkeletonUnit:create(self.m_info.image .. string.format("%02d", rank))
  self.m_spine:scale(math.min(bgSize.width * 0.3 / self.m_spine:GetContentSize().width, bgSize.height * 0.5 / self.m_spine:GetContentSize().height))
  self.m_spine:PlayAni("animation", true)
  td.AddRelaPos(spineBg, self.m_spine, 1, cc.p(0.5, 0.22))
  self.m_nameLabel = td.CreateLabel(self.m_info.name .. " LV." .. self.m_data.level, td.WHITE, 18, td.OL_BLACK, 2)
  td.AddRelaPos(spineBg, self.m_nameLabel, 1, cc.p(0.5, 0.85))
  local tmpLabel = td.CreateLabel(g_LM:getBy("a00059") .. ":", td.BLUE)
  tmpLabel:setAnchorPoint(0, 0.5)
  tmpLabel:pos(250, 280):addTo(self.m_bg)
  local pgBg = display.newSprite("UI/guild/jindutiao_di.png")
  pgBg:pos(350, 250):addTo(self.m_bg)
  local pgFg = display.newSprite("UI/guild/jindutiao_biankuang.png")
  td.AddRelaPos(pgBg, pgFg, 2)
  self.m_pgBar = RoundProgressBar.new("UI/guild/jindutiao.png")
  self.m_pgBar:SetPercent(self.m_data.num / self.m_info.need[self.m_data.level] * 100)
  td.AddRelaPos(pgBg, self.m_pgBar, 1)
  self.m_pgLabel = td.CreateLabel(string.format("%d/%d", self.m_data.num, self.m_info.need[self.m_data.level]))
  self.m_pgLabel:pos(350, 220):addTo(self.m_bg)
  self.m_btn = td.CreateBtn(td.BtnType.BlueLong)
  self.m_btn:setName("Button_6")
  td.BtnAddTouch(self.m_btn, function()
    local bEnable, errorCode = self:CheckDonate()
    if bEnable then
      self:SendContributeReq()
    else
      td.alertErrorMsg(errorCode)
    end
  end, nil, td.ButtonEffectType.Long)
  td.BtnSetTitle(self.m_btn, g_LM:getBy("a00308"))
  self.m_btn:pos(350, 60):addTo(self.m_bg)
  local bEnable = self:CheckDonate()
  td.EnableButton(self.m_btn, bEnable)
  self:ShowDonateUI()
end
function GuildDonateDlg:RefreshUI()
  self.m_data = self.m_gdMng:GetBuildData(self.m_id)
  self.m_time = self.m_gdMng:GetSelfData().num[self.m_id]
  self.m_pgBar:SetPercent(self.m_data.num / self.m_info.need[self.m_data.level] * 100)
  self.m_nameLabel:setString(self.m_info.name .. " LV." .. self.m_data.level)
  self.m_pgLabel:setString(string.format("%d/%d", self.m_data.num, self.m_info.need[self.m_data.level]))
  self.m_timeLabel:setString(string.format("%d/20", self.m_time))
end
function GuildDonateDlg:ShowDonateUI()
  local tmp = {
    {
      str = g_LM:getBy("a00082") .. ":",
      y = 175
    },
    {
      str = g_LM:getBy("a00161") .. ":",
      y = 115
    }
  }
  for i, var in ipairs(tmp) do
    local tmpLabel = td.CreateLabel(var.str, td.BLUE, 20)
    tmpLabel:setAnchorPoint(0, 0.5)
    tmpLabel:pos(250, var.y):addTo(self.m_bg)
  end
  local icon = td.CreateItemIcon(self.m_info.donate[1])
  icon:pos(330, 175):scale(0.5):addTo(self.m_bg)
  local numLabel = td.CreateLabel("x" .. self.m_donateCnt)
  numLabel:setAnchorPoint(0, 0.5)
  numLabel:pos(350, 175):addTo(self.m_bg)
  self.m_timeLabel = td.CreateLabel(string.format("%d/20", self.m_time))
  self.m_timeLabel:setAnchorPoint(0, 0.5)
  self.m_timeLabel:pos(350, 115):addTo(self.m_bg)
end
function GuildDonateDlg:CheckDonate()
  local guildLevel = self.m_gdMng:GetGuildLevel()
  if self.m_data.id == 1 and self.m_data.level >= td.MaxGuildBuildingLevel then
    return false, td.ErrorCode.LEVEL_MAX
  end
  if self.m_data.id ~= 1 and guildLevel <= self.m_data.level then
    if self.m_data.level < td.MaxGuildBuildingLevel then
      return false, td.ErrorCode.BASE_LEVEL_LOW
    else
      return false, td.ErrorCode.LEVEL_MAX
    end
  end
  if self.m_time <= 0 then
    return false, td.ErrorCode.TIME_NOT_ENOUGH
  end
  local haveNum = self.m_udMng:GetItemNum(self.m_itemId)
  if haveNum < self.m_donateCnt then
    return false, td.ErrorCode.MATERIAL_NOT_ENOUGH
  end
  return true, td.ErrorCode.SUCCESS
end
function GuildDonateDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function()
        self:close()
      end, 0.1)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.CONTRIBUTION_CHANGED, function()
    self:RefreshUI()
  end)
end
function GuildDonateDlg:SendContributeReq()
  local Msg = {}
  Msg.msgType = td.RequestID.ContributeToGuild
  Msg.sendData = {
    type = self.m_data.id
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildDonateDlg:ContributeCallback(data)
  if data.state == td.ResponseState.Success then
    if data.level > self.m_gdMng:GetBuildingLevel(self.m_id) then
      self.m_gdMng:SetBuildLevel(self.m_id, data.level)
      td.dispatchEvent(td.BUILDING_UPGRADE, self.m_id)
    end
    self.m_gdMng:DonateBuild(self.m_id, data.num)
    local addContri = self.m_gdMng:CalContribution(self.m_itemId, self.m_donateCnt)
    self.m_gdMng:UpdateContribution(math.floor(addContri))
    local bgSize = self.m_bg:getContentSize()
    td.CreateUIEffect(self.m_bg, "Spine/UI_effect/UI_shengji_01", {
      pos = cc.p(bgSize.width * 0.28, bgSize.height * 0.4),
      scale = 1
    })
    td.alert(g_LM:getBy("g00025") .. " +" .. math.floor(addContri))
    G_SoundUtil:PlaySound(55, false)
  else
    td.alert(g_LM:getBy("a00323"))
  end
  self:RefreshUI()
end
return GuildDonateDlg
