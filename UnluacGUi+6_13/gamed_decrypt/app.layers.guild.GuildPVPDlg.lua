local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local GuildPVPDlg = class("GuildPVPDlg", BaseDlg)
function GuildPVPDlg:ctor()
  GuildPVPDlg.super.ctor(self, 200)
  self.m_gdMng = UserDataManager:GetInstance():GetGuildManager()
  self.m_pvpData = self.m_gdMng:GetGuildPVPData()
  self.m_bOver = false
  self:InitUI()
end
function GuildPVPDlg:onEnter()
  GuildPVPDlg.super.onEnter(self)
  self:AddEvents()
  self:UpdateUI()
end
function GuildPVPDlg:onExit()
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
    self.m_timeScheduler = nil
  end
  GuildPVPDlg.super.onExit(self)
end
function GuildPVPDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/guild/GuildPVPDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_panelWait = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_wait")
  self.m_panelStart = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_start")
  for i = 1, 2 do
    local headBg1 = cc.uiloader:seekNodeByName(self.m_bg, "Image_headBg" .. i)
    local spineFire = SkeletonUnit:create("Spine/UI_effect/UI_juntuanzhan_01")
    spineFire:PlayAni("animation")
    td.AddRelaPos(headBg1, spineFire, -1)
    local spineLight = SkeletonUnit:create("Spine/UI_effect/UI_juntuanzhan_03")
    spineLight:PlayAni("animation")
    td.AddRelaPos(headBg1, spineLight, -1, cc.p(2 - i, 0.5))
  end
  local spineVS = SkeletonUnit:create("Spine/UI_effect/UI_juntuanzhan_02")
  spineVS:PlayAni("animation")
  td.AddRelaPos(self.m_bg, spineVS, 1, cc.p(0.5, 0.7))
  local selfGuildData = self.m_gdMng:GetGuildData()
  local headBg1 = cc.uiloader:seekNodeByName(self.m_bg, "Image_headBg1")
  local imageHead = cc.uiloader:seekNodeByName(headBg1, "Image_head")
  imageHead:loadTexture("UI/icon/guild/" .. selfGuildData.guild_emblem .. ".png")
  local nameLabel = cc.uiloader:seekNodeByName(headBg1, "Text_name")
  nameLabel:setString(selfGuildData.guild_name)
  self.m_btnLeft = cc.uiloader:seekNodeByName(self.m_bg, "Button_left_6")
  self.m_btnStart = cc.uiloader:seekNodeByName(self.m_bg, "Button_right_4")
  self.m_countDownLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_count_down")
end
function GuildPVPDlg:UpdateUI()
  self.m_pvpData = self.m_gdMng:GetGuildPVPData()
  local enemyData = self.m_pvpData:GetValue("enemyGuild")
  local headBg1 = cc.uiloader:seekNodeByName(self.m_bg, "Image_headBg2")
  local imageHead = cc.uiloader:seekNodeByName(headBg1, "Image_head")
  imageHead:loadTexture("UI/icon/guild/" .. enemyData.head .. ".png")
  local nameLabel = cc.uiloader:seekNodeByName(headBg1, "Text_name")
  nameLabel:setString(enemyData.name)
  self:ShowFightUI()
end
function GuildPVPDlg:ShowFightUI()
  local bStart, cdTime = self.m_gdMng:IsGuildPVPStart()
  self.m_countDown = cdTime
  if self.m_countDown > 0 then
    self.m_timeScheduler = scheduler.scheduleGlobal(function()
      self:OnTimer()
    end, 1)
  end
  if self.m_countDown > 0 then
    td.EnableButton(self.m_btnStart, false)
  end
  td.BtnSetTitle(self.m_btnLeft, g_LM:getBy("a00320"))
  td.BtnAddTouch(self.m_btnLeft, handler(self, self.Prepare))
  td.BtnSetTitle(self.m_btnStart, g_LM:getBy("a00319"))
  td.BtnAddTouch(self.m_btnStart, handler(self, self.Start))
end
function GuildPVPDlg:Prepare()
  local loadingScene = require("app.scenes.LoadingScene").new(td.PVP_GUILD_ID)
  cc.Director:getInstance():replaceScene(loadingScene)
end
function GuildPVPDlg:Start()
  if self.m_countDown <= 0 then
    local pvpData = self.m_gdMng:GetGuildPVPData()
    local soldiers, heros = pvpData:GetValue("hero_item"), pvpData:GetValue("soldier_item")
    if #soldiers == 0 and #heros == 0 then
      self:Prepare()
    else
      local pScene = require("app.scenes.GuildPVPScene").new()
      cc.Director:getInstance():replaceScene(pScene)
    end
  else
    td.alert(g_LM:getBy("a00333"))
  end
end
function GuildPVPDlg:AddEvents()
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
end
function GuildPVPDlg:OnTimer()
  self.m_countDown = cc.clampf(self.m_countDown - 1, 0, 99999999)
  local countDownStr = self:GetTimeDownStr(self.m_countDown)
  self.m_countDownLabel:setString(countDownStr)
  if self.m_countDown <= 0 then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
    self.m_timeScheduler = nil
    td.EnableButton(self.m_btnStart, true)
  end
end
function GuildPVPDlg:GetTimeDownStr(time)
  if time <= 0 then
    return ""
  end
  local str = "\232\183\157\231\166\187\229\188\128\230\136\152\232\191\152\230\156\137"
  local hour, min, sec = math.floor(time % 86400 / 3600), math.floor(time % 3600 / 60), math.floor(time % 60)
  str = str .. string.format("%02d:%02d:%02d", hour, min, sec)
  return str
end
return GuildPVPDlg
