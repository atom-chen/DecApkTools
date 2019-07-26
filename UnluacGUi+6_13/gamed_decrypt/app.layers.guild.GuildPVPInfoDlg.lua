local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local GuildPVPInfoDlg = class("GuildPVPInfoDlg", BaseDlg)
function GuildPVPInfoDlg:ctor(index)
  GuildPVPInfoDlg.super.ctor(self, 200)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_pvpData = self.m_udMng:GetGuildManager():GetGuildPVPData()
  self.m_index = index
  self.m_countDown = 0
  self.m_totalRes = 0
  self:InitUI()
  self:SetData(self.m_pvpData:GetValue("battlePos")[self.m_index])
end
function GuildPVPInfoDlg:onEnter()
  GuildPVPInfoDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GuildPVPBefore, handler(self, self.PVPStartData))
  self:AddEvents()
end
function GuildPVPInfoDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GuildPVPBefore)
  self:StopTimer()
  GuildPVPInfoDlg.super.onExit(self)
end
function GuildPVPInfoDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/guild/GuildPVPInfoDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_imageHead = cc.uiloader:seekNodeByName(self.m_bg, "Image_head")
  self.m_nameLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_name")
  self.m_powerLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_power")
  self.m_resLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_res")
  self.m_winLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_win")
  self.m_stateLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_state")
  self.m_btnStart = cc.uiloader:seekNodeByName(self.m_bg, "Button_yes_6")
  td.BtnSetTitle(self.m_btnStart, g_LM:getBy("a00319"))
  td.BtnAddTouch(self.m_btnStart, handler(self, self.Start))
end
function GuildPVPInfoDlg:UpdateUI()
  local serverTime = self.m_udMng:GetServerTime()
  self.m_totalRes = td.CalGuildPVPRes(self.m_data.startTime)
  self.m_imageHead:loadTexture(td.GetPortrait(self.m_data.head))
  self.m_nameLabel:setString(self.m_data.name)
  self.m_powerLabel:setString(self.m_data.power)
  self.m_winLabel:setString(self.m_data.win)
  self.m_resLabel:setString(tostring(self.m_totalRes))
  if serverTime - self.m_data.atkedTime > 180 then
    td.EnableButton(self.m_btnStart, true)
    self.m_stateLabel:setString(g_LM:getBy("a00251"))
    self.m_stateLabel:setColor(td.YELLOW)
  elseif self.m_data.attack_uid ~= "" then
    td.EnableButton(self.m_btnStart, false)
    local attackerName = self.m_data.attack_uid
    if self.m_pvpData:GetMemberData(self.m_data.attack_uid) then
      attackerName = self.m_pvpData:GetMemberData(self.m_data.attack_uid).uname
    end
    self.m_stateLabel:setString(string.format(g_LM:getBy("a00252"), attackerName))
    self.m_stateLabel:setColor(td.RED)
  else
    td.EnableButton(self.m_btnStart, false)
    self.m_stateLabel:setString(self:GetTimeDownStr(self.m_countDown))
    self.m_stateLabel:setColor(td.GREEN)
    self.m_countDown = 180 - (serverTime - self.m_data.atkedTime)
  end
  if self.m_data.isSelf then
    self.m_btnStart:setVisible(false)
  end
  if self.m_pvpData:GetValue("isIn") then
    td.EnableButton(self.m_btnStart, false)
  end
  if nil == self.m_timeScheduler then
    self:OnTimer()
    self.m_timeScheduler = scheduler.scheduleGlobal(function()
      self:OnTimer()
    end, 1)
  end
end
function GuildPVPInfoDlg:Start()
  if self.m_pvpData:GetValue("isIn") then
    td.alert(g_LM:getBy("a00334"))
    return
  end
  if self.m_data.attack_uid ~= "" then
    local attackerName = self.m_data.attack_uid
    if self.m_pvpData:GetMemberData(self.m_data.attack_uid) then
      attackerName = self.m_pvpData:GetMemberData(self.m_data.attack_uid).uname
    end
    td.alert(g_LM:getBy("a00335") .. attackerName .. g_LM:getBy("a00336"))
  elseif self.m_countDown <= 0 then
    local msg = {}
    msg.sendData = {
      index = self.m_index,
      team_id = self.m_pvpData:GetValue("battleId")
    }
    msg.msgType = td.RequestID.GuildPVPBefore
    TDHttpRequest:getInstance():Send(msg)
  else
    td.alert(g_LM:getBy("a00337"), true)
  end
end
function GuildPVPInfoDlg:PVPStartData(data)
  if data.state == td.ResponseState.Success then
    self.m_pvpData:UpdateValue("fightingIndex", self.m_index)
    self.m_pvpData:UpdateValue("logId", data.log_id)
    local loadingScene = require("app.scenes.LoadingScene").new(td.PVP_GUILD_ID)
    cc.Director:getInstance():replaceScene(loadingScene)
  end
end
function GuildPVPInfoDlg:AddEvents()
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
  self:AddCustomEvent(td.GUILD_PVP_UPDATE, handler(self, self.OnDataChanged))
end
function GuildPVPInfoDlg:OnDataChanged()
  local posData = self.m_pvpData:GetValue("battlePos")[self.m_index]
  if posData.id ~= self.m_data.id then
    self:SetData(posData)
  end
end
function GuildPVPInfoDlg:SetData(data)
  self.m_data = clone(data)
  self:UpdateUI()
end
function GuildPVPInfoDlg:StopTimer()
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
    self.m_timeScheduler = nil
  end
end
function GuildPVPInfoDlg:OnTimer()
  if self.m_countDown > 0 then
    self.m_countDown = math.max(self.m_countDown - 1, 0)
    local countDownStr = self:GetTimeDownStr(self.m_countDown)
    self.m_stateLabel:setString(countDownStr)
    if self.m_countDown == 0 then
      td.EnableButton(self.m_btnStart, true)
    end
  end
  self.m_totalRes = td.CalGuildPVPRes(self.m_data.startTime) + 5
  self.m_resLabel:setString(tostring(self.m_totalRes))
end
function GuildPVPInfoDlg:GetTimeDownStr(time)
  if time <= 0 then
    return g_LM:getBy("a00251")
  end
  local str = g_LM:getBy("a00253")
  local min, sec = math.floor(time % 3600 / 60), math.floor(time % 60)
  str = str .. string.format("%02d:%02d", min, sec)
  return str
end
return GuildPVPInfoDlg
