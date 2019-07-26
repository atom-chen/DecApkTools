local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local GuildPVPOverDlg = class("GuildPVPOverDlg", BaseDlg)
function GuildPVPOverDlg:ctor()
  GuildPVPOverDlg.super.ctor(self, 200)
  self.m_gdMng = UserDataManager:GetInstance():GetGuildManager()
  self.m_pvpData = self.m_gdMng:GetGuildPVPData()
  self.m_bWin = self.m_pvpData:GetValue("battleState") == td.GuildPVPState.Win
  self:InitUI()
end
function GuildPVPOverDlg:onEnter()
  GuildPVPOverDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GuildPVPResLog, handler(self, self.LogResCallback))
  self:AddEvents()
  self:SendLogResReq()
end
function GuildPVPOverDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GuildPVPResLog)
  GuildPVPOverDlg.super.onExit(self)
end
function GuildPVPOverDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/guild/GuildPVPOverDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  local spFile
  if self.m_bWin then
    self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
    spFile = "Spine/UI_effect/UI_zhandoujiesuan_01"
  else
    self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
    self.m_bg:setVisible(false)
    self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg_lose")
    self.m_bg:setVisible(true)
    spFile = "Spine/UI_effect/UI_zhandoujiesuan_02"
  end
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  local spine = SkeletonUnit:create(spFile)
  td.AddRelaPos(self.m_bg, spine, 1, cc.p(0.5, 1.1))
  spine:PlayAni("animation_01", false, true)
  spine:PlayAni("animation_02", true, true)
  self.m_textTotalWin = cc.uiloader:seekNodeByName(self.m_bg, "Text_total_win")
  self.m_textTotalRes = cc.uiloader:seekNodeByName(self.m_bg, "Text_total_res")
  self.m_btnLeft = cc.uiloader:seekNodeByName(self.m_bg, "Button_left_6")
  self.m_btnStart = cc.uiloader:seekNodeByName(self.m_bg, "Button_right_4")
  td.BtnSetTitle(self.m_btnLeft, g_LM:getBy("g00042"))
  td.BtnAddTouch(self.m_btnLeft, handler(self, self.ShowLog))
  td.BtnSetTitle(self.m_btnStart, g_LM:getBy("a00009"))
  td.BtnAddTouch(self.m_btnStart, handler(self, self.Back))
end
function GuildPVPOverDlg:UpdateUI()
  if self.m_bWin then
    local mvpMemberData = self.m_vResData[1]
    local mvpHead = cc.uiloader:seekNodeByName(self.m_bg, "Image_head")
    mvpHead:loadTexture(td.GetPortrait(mvpMemberData.image_id))
    local mvpName = cc.uiloader:seekNodeByName(self.m_bg, "Text_name")
    mvpName:setString(mvpMemberData.uname)
    local mvpWin = cc.uiloader:seekNodeByName(self.m_bg, "Text_vip_win")
    mvpWin:setString(mvpMemberData.win_num)
    local mvpRes = cc.uiloader:seekNodeByName(self.m_bg, "Text_vip_res")
    mvpRes:setString(mvpMemberData.res)
  end
  self.m_textTotalWin:setString(self:GetTotalWin())
  self.m_textTotalRes:setString(self.m_pvpData:GetValue("totalRes"))
end
function GuildPVPOverDlg:GetTotalWin()
  local totalWin = 0
  for i, var in ipairs(self.m_vResData) do
    totalWin = totalWin + var.win_num
  end
  return totalWin
end
function GuildPVPOverDlg:ShowLog()
  local dlg = require("app.layers.guild.GuildPVPLogOverDlg").new(self.m_vResData)
  td.popView(dlg)
end
function GuildPVPOverDlg:Back()
  if display.getRunningScene():GetType() == td.SceneType.Guild then
    self:close()
  else
    local pScene = require("app.scenes.GuildScene").new()
    pScene:SetEnterModule(3)
    cc.Director:getInstance():replaceScene(pScene)
  end
end
function GuildPVPOverDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function GuildPVPOverDlg:SendLogResReq()
  local Msg = {}
  Msg.msgType = td.RequestID.GuildPVPResLog
  Msg.sendData = {
    team_id = self.m_pvpData:GetValue("battleId")
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildPVPOverDlg:LogResCallback(data)
  self.m_vResData = {}
  for i, var in ipairs(data.award) do
    local playerData = clone(self.m_pvpData:GetMemberData(var.uid))
    if playerData then
      playerData.res = var.award
      playerData.win_num = var.win_num
      if playerData.isSelf then
        table.insert(self.m_vResData, playerData)
      end
    end
  end
  table.sort(self.m_vResData, function(a, b)
    return a.res > b.res
  end)
  self:UpdateUI()
end
return GuildPVPOverDlg
