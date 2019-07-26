local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local BaseDlg = require("app.layers.BaseDlg")
local PlayerInfoDlg = class("PlayerInfoDlg", BaseDlg)
function PlayerInfoDlg:ctor()
  PlayerInfoDlg.super.ctor(self)
  self.m_uiId = td.UIModule.PlayerInfo
  self:InitUI()
  self:AddEvents()
end
function PlayerInfoDlg:onEnter()
  PlayerInfoDlg.super.onEnter(self)
end
function PlayerInfoDlg:onExit()
  PlayerInfoDlg.super.onExit(self)
end
function PlayerInfoDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/PlayerInfoDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  local udMng = require("app.UserDataManager").GetInstance()
  local inFunc = function(data)
    local parent = data.parent
    local node = data.node
    if data.ancPos then
      node:setAnchorPoint(data.ancPos)
    end
    node:setPosition(data.pos)
    parent:addChild(node)
  end
  local pTempParent = cc.uiloader:seekNodeByName(self.m_bg, "Button_head")
  td.BtnAddTouch(pTempParent, function()
    local imageId = udMng:GetPortrait()
    local dlg = require("app.layers.MainMenuUI.PortraitDlg").new(imageId)
    td.popView(dlg)
  end)
  local portraitInfo = require("app.info.CommanderInfoManager"):GetInstance():GetPortraitInfo(udMng:GetPortrait())
  self.m_portrait = pTempParent:getChildByTag(1)
  self.m_portrait:loadTexture(portraitInfo.file .. td.PNG_Suffix)
  local palyerName = udMng:GetNickname()
  local pTmpNode = td.CreateLabel(palyerName, td.WHITE, 20)
  inFunc({
    parent = self.m_bg,
    node = pTmpNode,
    pos = cc.p(170, 250),
    ancPos = cc.p(0, 0.5)
  })
  local shenwang = udMng:GetReputation()
  local pCommanderInfoManager = require("app.info.CommanderInfoManager").GetInstance()
  local pHonorInfo = pCommanderInfoManager:GetHonorInfoByRepu(shenwang)
  local iconSpr = display.newSprite(pHonorInfo.image .. td.PNG_Suffix)
  iconSpr:scale(0.6)
  inFunc({
    parent = self.m_bg,
    node = iconSpr,
    pos = cc.p(170, 200),
    ancPos = cc.p(0, 0.5)
  })
  pTmpNode = td.CreateLabel(pHonorInfo.military_rank, td.YELLOW)
  inFunc({
    parent = self.m_bg,
    node = pTmpNode,
    pos = cc.p(170 + iconSpr:getBoundingBox().width, 200),
    ancPos = cc.p(0, 0.5)
  })
  local label = td.CreateLabel(g_LM:getBy("a00105"), td.LIGHT_BLUE)
  inFunc({
    parent = self.m_bg,
    node = label,
    pos = cc.p(60, 140),
    ancPos = cc.p(0, 0.5)
  })
  local uid = udMng:GetUId()
  pTmpNode = td.CreateLabel(uid, td.WHITE, 18)
  inFunc({
    parent = self.m_bg,
    node = pTmpNode,
    pos = cc.p(60 + label:getContentSize().width, 140),
    ancPos = cc.p(0, 0.5)
  })
  label = td.CreateLabel(g_LM:getBy("a00032") .. ":", td.LIGHT_GREEN)
  inFunc({
    parent = self.m_bg,
    node = label,
    pos = cc.p(60, 80),
    ancPos = cc.p(0, 0.5)
  })
  local zhanli = udMng:GetTotalPower()
  pTmpNode = td.CreateLabel(zhanli)
  inFunc({
    parent = self.m_bg,
    node = pTmpNode,
    pos = cc.p(60 + label:getContentSize().width, 80),
    ancPos = cc.p(0, 0.5)
  })
  label = td.CreateLabel(g_LM:getBy("it00003") .. ":", td.LIGHT_GREEN)
  inFunc({
    parent = self.m_bg,
    node = label,
    pos = cc.p(245, 80),
    ancPos = cc.p(0, 0.5)
  })
  pTmpNode = td.CreateLabel(shenwang)
  inFunc({
    parent = self.m_bg,
    node = pTmpNode,
    pos = cc.p(245 + label:getContentSize().width, 80),
    ancPos = cc.p(0, 0.5)
  })
  local honorBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_honor")
  td.BtnAddTouch(honorBtn, function()
    local pDlg = require("app.layers.worldmap.HonorDlg").new()
    pDlg:InitUI(udMng:GetReputation())
    td.popView(pDlg, true)
  end)
  local renameBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_name")
  td.BtnAddTouch(renameBtn, function()
    local pDlg = require("app.layers.NameDlg").new()
    td.popView(pDlg, true)
    self:close()
  end)
  local settingBtn = ccui.Button:create("UI/button/shezhi1_button.png", "UI/button/shezhi2_button.png")
  td.BtnAddTouch(settingBtn, function()
    g_MC:OpenModule(td.UIModule.System)
  end)
  td.AddRelaPos(self.m_bg, settingBtn, 1, cc.p(0.3, 0))
  local achieveBtn = ccui.Button:create("UI/button/chengjiu1_button.png", "UI/button/chengjiu2_button.png")
  td.BtnAddTouch(achieveBtn, function()
    g_MC:OpenModule(td.UIModule.Achievement)
  end)
  td.AddRelaPos(self.m_bg, achieveBtn, 1, cc.p(0.7, 0))
  if self:CheckAchieve() then
    td.ShowRP(achieveBtn, true)
  end
end
function PlayerInfoDlg:CheckAchieve()
  local vAchieveData = UserDataManager:GetInstance():GetAchieveData()
  local vAchiveTypes = {
    td.AchieveType.Explore,
    td.AchieveType.Mission,
    td.AchieveType.Mixed
  }
  for i, type in ipairs(vAchiveTypes) do
    if #vAchieveData[type][td.AchievementState.Complete] > 0 then
      return true
    end
  end
  return false
end
function PlayerInfoDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function(times)
        self:close()
      end, 0.1)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.MODIFY_PORTRAIT, handler(self, self.ModifyPortrait))
end
function PlayerInfoDlg:ModifyPortrait(event)
  local id = tonumber(event:getDataString())
  local portraitInfo = require("app.info.CommanderInfoManager"):GetInstance():GetPortraitInfo(id)
  self.m_portrait:loadTexture(portraitInfo.file .. td.PNG_Suffix)
end
return PlayerInfoDlg
