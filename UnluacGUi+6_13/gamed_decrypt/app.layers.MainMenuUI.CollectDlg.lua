local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local MissionInfoManager = require("app.info.MissionInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local UserDataManager = require("app.UserDataManager")
local TabButton = require("app.widgets.TabButton")
local TouchIcon = require("app.widgets.TouchIcon")
local CollectDlg = class("CollectDlg", BaseDlg)
function CollectDlg:ctor()
  CollectDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Collect
  self.m_udMng = UserDataManager:GetInstance()
  self.m_config = require("app.config.collect_config")
  self.m_mode = 0
  self.m_tabs = {}
  self:InitUI()
end
function CollectDlg:onEnter()
  CollectDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.MallBuy, handler(self, self.BuyCallback))
  self:AddEvents()
end
function CollectDlg:onExit()
  CollectDlg.super.onExit(self)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.MallBuy)
end
function CollectDlg:InitUI()
  self:LoadUI("CCS/CollectDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_caiji.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  for i = 1, 3 do
    do
      local bg = cc.uiloader:seekNodeByName(self.m_bg, "Image_bg" .. i)
      local startBtn = cc.uiloader:seekNodeByName(bg, "Button_start_1")
      td.BtnAddTouch(startBtn, function()
        self:StartGame(i)
      end)
      td.BtnSetTitle(startBtn, g_LM:getBy("a00102"))
    end
  end
  self.m_textTime = cc.uiloader:seekNodeByName(self.m_bg, "Text_times")
  local btnAdd = cc.uiloader:seekNodeByName(self.m_bg, "Button_add_chance")
  td.BtnAddTouch(btnAdd, handler(self, self.OnAddBtnClicked))
  self:CreateTabs()
end
function CollectDlg:RefreshUI()
  for i = 1, 3 do
    local bg = cc.uiloader:seekNodeByName(self.m_bg, "Image_bg" .. i)
    bg:loadTexture("UI/collect/bg_" .. self.m_mode .. ".png")
    local imageTitle = cc.uiloader:seekNodeByName(bg, "Image_type")
    imageTitle:loadTexture("UI/collect/title_" .. i .. "_" .. self.m_mode .. td.PNG_Suffix)
    local panelReward = cc.uiloader:seekNodeByName(bg, "Panel_rewards")
    panelReward:removeAllChildren()
    local panelSize = panelReward:getContentSize()
    local rewards = self.m_config.Items[i][self.m_mode]
    local gapX = 90
    local startX = panelSize.width / 2 - (#rewards - 1) / 2 * gapX
    for j, var in ipairs(rewards) do
      local icon = TouchIcon.new(var.itemId, true)
      icon:scale(0.7):pos(startX + (j - 1) * gapX, panelSize.height / 2):addTo(panelReward)
    end
    local startBtn = cc.uiloader:seekNodeByName(bg, "Button_start_1")
    local bEnable = self:_CheckCanStart(i)
    td.EnableButton(startBtn, bEnable)
  end
  local remainTimes = self.m_udMng:GetDungeonTime(self.m_uiId)
  self.m_textTime:setString(remainTimes)
  if remainTimes <= 0 then
    self.m_textTime:setColor(td.RED)
  else
    self.m_textTime:setColor(td.WHITE)
  end
end
function CollectDlg:StartGame(type)
  local bEnabel, errorCode = self:_CheckCanStart(type)
  if bEnabel then
    local missionId = self.m_config.MissionIds[type][self.m_mode]
    GameDataManager:GetInstance():SetCollectData(self.m_mode, type)
    g_MC:OpenModule(td.UIModule.MissionReady, missionId)
  else
    td.alertErrorMsg(errorCode)
  end
end
function CollectDlg:CreateTabs(mode)
  self.m_tabs = {}
  local tabs = {}
  for i = 1, 3 do
    local _tab = cc.uiloader:seekNodeByName(self.m_bg, "Tab" .. i)
    table.insert(self.m_tabs, _tab)
    if not self:_CheckUnlock(i) then
      local grayIcon = display.newGraySprite("UI/button/nandu" .. i .. "_icon2.png")
      local parent = _tab:getParent()
      local x, y = _tab:getPosition()
      grayIcon:pos(x, y):addTo(parent)
    else
      _tab:setOpacity(255)
    end
    local tab = {
      tab = _tab,
      callfunc = handler(self, self.UpdatePanels),
      normalImageFile = "UI/button/nandu" .. i .. "_icon2.png",
      highImageFile = "UI/button/nandu" .. i .. "_icon1.png"
    }
    table.insert(tabs, tab)
  end
  local tabButtons = TabButton.new(tabs, {autoSelectIndex = mode})
end
function CollectDlg:UpdatePanels(index)
  if not self:_CheckUnlock(index) then
    if index == 2 then
      td.alert(g_LM:getBy("a00341"))
    elseif index == 3 then
      td.alert(g_LM:getBy("a00342"))
    end
    return false
  end
  self.m_mode = index
  self:RefreshUI()
  return true
end
function CollectDlg:_CheckCanStart(type)
  local bResult, errorCode = true, td.ErrorCode.SUCCESS
  if self.m_udMng:GetDungeonTime(self.m_uiId) <= 0 then
    bResult, errorCode = false, td.ErrorCode.MISSION_TIME_NOT_ENOUGH
  end
  return bResult, errorCode
end
function CollectDlg:_CheckUnlock(mode)
  if mode == 2 then
    if self.m_udMng:GetBaseCampLevel() < 20 then
      return false
    end
  elseif mode == 3 and self.m_udMng:GetBaseCampLevel() < 30 then
    return false
  end
  return true
end
function CollectDlg:AddEvents()
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
function CollectDlg:OnAddBtnClicked()
  td.ShowBuyTimeDlg(self.m_uiId, handler(self, self.SendBuyRequest))
end
function CollectDlg:SendBuyRequest()
  if self.m_bIsRequsting then
    return
  end
  self.m_bIsRequsting = true
  local Msg = {}
  Msg.msgType = td.RequestID.MallBuy
  Msg.sendData = {
    id = td.BuyCollectId,
    num = 1
  }
  Msg.cbData = {
    id = td.BuyCollectId
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function CollectDlg:BuyCallback(data, cbData)
  if data.state == td.ResponseState.Success and cbData.id == td.BuyCollectId then
    self.m_udMng:UpdateDungeonTime(self.m_uiId, 1)
    self.m_udMng:UpdateDungeonBuyTime(self.m_uiId, -1)
    self:RefreshUI()
  end
  self.m_bIsRequsting = false
end
return CollectDlg
