local TDHttpRequest = require("app.net.TDHttpRequest")
local MissionInfoManager = require("app.info.MissionInfoManager")
local scheduler = require("framework.scheduler")
local GuideManager = require("app.GuideManager")
local UserDataManager = require("app.UserDataManager")
local MessageBoxDlg = require("app.layers.MessageBoxDlg")
local BaseDlg = require("app.layers.BaseDlg")
local MissionDlg = class("MissionDlg", BaseDlg)
local touchHelpTag = 0
local toScale_ = 1.1
local StartType = {
  SimpleWar = 1,
  SimpleReceive = 2,
  DifficultWar = 3,
  DifficultReceive = 4
}
function MissionDlg:ctor()
  MissionDlg.super.ctor(self)
  self.m_uiId = td.UIModule.Mission
  self.m_missionId = nil
  self.m_mapId = nil
  self.m_tmpNodes = {}
  self.m_startType = StartType.SimpleReceive
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function MissionDlg:onEnter()
  MissionDlg.super.onEnter(self)
  self:AddEvents()
  self:CheckGuide()
end
function MissionDlg:onExit()
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
    self.m_timeScheduler = nil
  end
  MissionDlg.super.onExit(self)
end
function MissionDlg:SetMissionData(missionData)
  self.m_missionData = clone(missionData)
  self:RefreshUI()
end
function MissionDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/MissionDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_Panel_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.m_ImageOp = cc.uiloader:seekNodeByName(self.m_Panel_bg, "Image_op")
  self.m_minimap = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_minimap")
  self.m_Label_title = cc.uiloader:seekNodeByName(self.m_uiRoot, "Label_title")
  self.m_BtnSimple = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_simple")
  local simpleLabel = td.CreateLabel(g_LM:getBy("a00177"), td.LIGHT_BLUE, 16, td.OL_BLACK, 2)
  td.AddRelaPos(self.m_BtnSimple:getChildByTag(3), simpleLabel, 1, cc.p(0.5, 0.6))
  self.m_BtnDifficult = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_difficult")
  local diffLabel = td.CreateLabel(g_LM:getBy("a00178"), td.LIGHT_BLUE, 14, td.OL_BLACK, 2)
  td.AddRelaPos(self.m_BtnDifficult:getChildByTag(3), diffLabel, 1, cc.p(0.5, 0.6))
  self.m_PanelNormal = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_normal")
  self.m_PanelHard = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_hard")
  self.m_BtnDo = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_do_2")
  td.BtnAddTouch(self.m_BtnDo, handler(self, self.BtnDoCallback))
  self:SetBtnSelect(true)
  self.m_ReceivePanelLocSize = self.m_PanelHard:getContentSize()
end
function MissionDlg:RefreshUI()
  local state = self.m_missionData.state
  if state == td.MissionState.NotOccupied then
    self.m_missionId = self.m_missionData.normal
    self.m_mapId = self.m_missionData.normal
    self:ShowMissionInfoUI(self.m_missionData.normal, false)
    self.m_startType = StartType.SimpleWar
  elseif state == td.MissionState.Occupieding then
    self.m_missionId = self.m_missionData.hard
    self.m_mapId = self.m_missionData.hard
    self:ShowProductInfo(self.m_missionData.normal, false)
    self.m_startType = StartType.SimpleReceive
    td.BtnAddTouch(self.m_BtnSimple, handler(self, self.SimpleBtnCallback))
    td.BtnAddTouch(self.m_BtnDifficult, handler(self, self.DifficulyBtnCallback))
    local effect = SkeletonUnit:create("Spine/UI_effect/UI_kunnan_01")
    effect:PlayAni("animation")
    effect:setScaleY(1.1)
    td.AddRelaPos(self.m_BtnDifficult, effect, 1, cc.p(0.5, 0.6))
  elseif state == td.MissionState.Occupieded then
    self.m_missionId = self.m_missionData.hard
    self.m_mapId = self.m_missionData.hard
    self:ShowProductInfo(self.m_missionData.hard, true)
    self.m_startType = StartType.DifficultReceive
    self:SetBtnSelect(false)
  elseif state == td.MissionState.MonstSimpleOccu or state == td.MissionState.MonstSimpleOccued then
    self.m_missionId = self.m_missionData.normal
    self.m_mapId = self.m_missionData.normalDf
    self:ShowDFInfoUI(self.m_missionData.normalDf, false, state == td.MissionState.MonstSimpleOccued)
    self.m_startType = StartType.SimpleWar
  elseif state == td.MissionState.MonstDifficultOccu or state == td.MissionState.MonstDifficultOccued then
    self.m_missionId = self.m_missionData.hard
    self.m_mapId = self.m_missionData.hardDf
    self:ShowDFInfoUI(self.m_missionData.hardDf, true, state == td.MissionState.MonstDifficultOccued)
    self.m_startType = StartType.DifficultWar
    self:SetBtnSelect(false)
  end
  if self:IsDifficult() then
    self.m_BtnDifficult:getChildByTag(1):loadTexture("UI/mainmenu_new/mission/kunnan_icon.png")
  end
  self:InitCityIcon()
end
function MissionDlg:InitCityIcon()
  local info = MissionInfoManager:GetInstance():GetMissionInfo(self.m_missionData.normal)
  self.m_minimap:loadTexture(info.mini_map .. td.PNG_Suffix)
  self.m_Label_title:setString(g_LM:getBy(info.name))
end
function MissionDlg:SimpleBtnCallback(sender, eventType)
  if eventType == ccui.TouchEventType.ended then
    self:SimpleMissionInfo()
    GuideManager.H_GuideUI(td.UIModule.Mission, self.m_uiRoot)
  end
end
function MissionDlg:SimpleMissionInfo()
  if not self:IsDifficult() then
    return
  end
  self:ShowProductInfo(self.m_missionData.normal, false)
  self.m_startType = StartType.SimpleReceive
  self:SetBtnSelect(true)
end
function MissionDlg:DifficulyBtnCallback(sender, eventType)
  if eventType == ccui.TouchEventType.ended then
    self:DifficulyMissionInfo()
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  end
end
function MissionDlg:DifficulyMissionInfo()
  local state = self.m_missionData.state
  if not self:IsDifficult() then
    return
  end
  if state == td.MissionState.Occupieded then
    self:ShowProductInfo(self.m_missionData.hard)
    self.m_startType = StartType.DifficultReceive
  else
    local missionId = self.m_missionData.hard
    if state == td.MissionState.MonstDifficultOccu or state == td.MissionState.MonstDifficultOccued then
      missionId = self.m_missionData.hardDf
    end
    self:ShowMissionInfoUI(missionId, true)
    self.m_startType = StartType.DifficultWar
  end
  td.EnableButton(self.m_BtnDo, true)
  self:SetBtnSelect(false)
end
function MissionDlg:ShowMissionInfoUI(missionCfgId, bIsHard)
  local missionData = require("app.info.MissionInfoManager"):GetInstance():GetMissionInfo(missionCfgId)
  local parentPanel = bIsHard and self.m_PanelHard or self.m_PanelNormal
  self.m_PanelNormal:setVisible(not bIsHard)
  self.m_PanelHard:setVisible(bIsHard)
  self.m_ImageOp:setVisible(false)
  if parentPanel:getChildrenCount() == 0 then
    local vLabels = {
      "a00130",
      "a00131",
      "a00132"
    }
    local vDatas = {
      self:_GetTypeStr(missionData.type),
      missionData.base_level,
      missionData.attempts
    }
    local vSize, vColor = {
      24,
      18,
      18
    }, {
      td.YELLOW,
      td.LIGHT_BLUE,
      td.LIGHT_BLUE
    }
    for i, var in ipairs(vLabels) do
      local tmpLabel = td.RichText({
        {
          type = 1,
          color = td.WHITE,
          size = vSize[i],
          str = g_LM:getBy(var)
        },
        {
          type = 1,
          color = vColor[i],
          size = vSize[i],
          str = vDatas[i]
        }
      })
      tmpLabel:setAnchorPoint(cc.p(0, 0.5))
      tmpLabel:pos(0, 270 - 30 * i):addTo(parentPanel)
    end
    local wordSpr = display.newSprite(td.Word_Path .. "wenzi_zhanlinghouhuodeshouyi.png")
    wordSpr:setAnchorPoint(0, 0.5)
    td.AddRelaPos(parentPanel, wordSpr, 1, cc.p(0, 0.44))
    local tax_data = string.split(missionData.tax, "|")
    for i, var in ipairs(tax_data) do
      local t = string.split(var, "#")
      local iconSpr = td.CreateItemIcon(t[1])
      iconSpr:pos(15, 140 - 40 * i):scale(0.4):addTo(parentPanel)
      local num = tonumber(t[2]) * 10
      local tmpLabel = td.CreateLabel("+" .. num .. g_LM:getBy("a00139"), td.LIGHT_BLUE, 18)
      tmpLabel:setAnchorPoint(cc.p(0, 0.5))
      tmpLabel:pos(40, 140 - 40 * i):addTo(parentPanel)
    end
    local awardData = string.split(missionData.award, "#")
    local itemData = require("app.info.ItemInfoManager").GetInstance():GetItemInfo(tonumber(awardData[1]))
    local tmpLabel = td.RichText({
      {
        type = 1,
        color = td.WHITE,
        size = 18,
        str = g_LM:getBy("a00134")
      },
      {
        type = 2,
        file = itemData.icon .. td.PNG_Suffix,
        scale = 0.4
      },
      {
        type = 1,
        color = td.LIGHT_BLUE,
        size = 18,
        str = "x" .. awardData[2]
      }
    })
    tmpLabel:setAnchorPoint(cc.p(0, 0.5))
    tmpLabel:pos(-505, 45):addTo(parentPanel)
  end
  td.BtnSetTitle(self.m_BtnDo, g_LM:getBy("a00102"))
end
function MissionDlg:ShowProductInfo(missionCfgId, bIsHard)
  local missionInfoManager = require("app.info.MissionInfoManager"):GetInstance()
  local missionData = missionInfoManager:GetMissionInfo(missionCfgId)
  local parentPanel = bIsHard and self.m_PanelHard or self.m_PanelNormal
  self.m_PanelNormal:setVisible(not bIsHard)
  self.m_PanelHard:setVisible(bIsHard)
  self.m_ImageOp:setVisible(true)
  if bIsHard then
    self.m_ImageOp:loadTexture("UI/mainmenu_new/mission/wanquanzhanling_icon.png")
  else
    self.m_ImageOp:loadTexture("UI/mainmenu_new/mission/bufenshoufu_icon.png")
  end
  if parentPanel:getChildrenCount() == 0 then
    local tax_data = string.split(missionData.tax, "|")
    for i, var in ipairs(tax_data) do
      local t = string.split(var, "#")
      local iconSpr = td.CreateItemIcon(t[1])
      iconSpr:pos(15, 280 - 40 * i):scale(0.4):addTo(parentPanel)
      local num = tonumber(t[2]) * 10
      local tmpLabel = td.CreateLabel("+" .. num .. g_LM:getBy("a00139"), td.LIGHT_BLUE, 18)
      tmpLabel:setName("ProfitLabel")
      tmpLabel:setAnchorPoint(cc.p(0, 0.5))
      tmpLabel:pos(40, 280 - 40 * i):addTo(parentPanel)
    end
  end
  td.BtnSetTitle(self.m_BtnDo, g_LM:getBy("a00009"))
end
function MissionDlg:ShowDFInfoUI(missionCfgId, bIsHard, bComplete)
  local MissionInfoManager = require("app.info.MissionInfoManager")
  local missionData = MissionInfoManager:GetInstance():GetMissionInfo(missionCfgId)
  local parentPanel = bIsHard and self.m_PanelHard or self.m_PanelNormal
  self.m_PanelNormal:setVisible(not bIsHard)
  self.m_PanelHard:setVisible(bIsHard)
  self.m_ImageOp:setVisible(true)
  if bComplete then
    self.m_ImageOp:loadTexture("UI/mainmenu_new/mission/beizhanling_icon.png")
  else
    self.m_ImageOp:loadTexture("UI/mainmenu_new/mission/beigongji_icon.png")
  end
  if parentPanel:getChildrenCount() == 0 then
    local oriMissionData = MissionInfoManager:GetInstance():GetMissionInfo(self.m_missionId)
    local tax_data = string.split(oriMissionData.tax, "|")
    for i, var in ipairs(tax_data) do
      local t = string.split(var, "#")
      local iconSpr = td.CreateItemIcon(t[1])
      iconSpr:pos(15, 280 - 40 * i):scale(0.4):addTo(parentPanel)
      local num = bComplete and 0 or tonumber(t[2]) * 10
      local tmpLabel = td.CreateLabel("+" .. num .. g_LM:getBy("a00139"), td.LIGHT_BLUE, 18)
      tmpLabel:setAnchorPoint(cc.p(0, 0.5))
      tmpLabel:pos(40, 280 - 40 * i):addTo(parentPanel)
    end
    if not bComplete then
      local wordSpr = display.newSprite(td.Word_Path .. "wenzi_beigongjidaojishi.png")
      wordSpr:setAnchorPoint(0, 0.5)
      wordSpr:pos(0, 80):addTo(parentPanel)
      local serverTime = math.floor(UserDataManager:GetInstance():GetServerTime())
      self.m_countDown = self.m_missionData.attack_time + 86400 - serverTime
      local hour, min, sec = math.floor(self.m_countDown / 3600), math.floor(self.m_countDown % 3600 / 60), math.floor(self.m_countDown % 60)
      self.m_countDownLabel = td.CreateLabel(string.format("%02d:%02d:%02d", hour, min, sec))
      self.m_countDownLabel:setAnchorPoint(0, 0.5)
      self.m_countDownLabel:pos(0, 50):addTo(parentPanel)
      self.m_timeScheduler = scheduler.scheduleGlobal(function()
        self.m_countDown = cc.clampf(self.m_countDown - 1, 0, 86400)
        local hour, min, sec = math.floor(self.m_countDown / 3600), math.floor(self.m_countDown % 3600 / 60), math.floor(self.m_countDown % 60)
        self.m_countDownLabel:setString(string.format("%02d:%02d:%02d", hour, min, sec))
      end, 1)
    end
    local awardData = string.split(missionData.award, "#")
    local itemData = require("app.info.ItemInfoManager").GetInstance():GetItemInfo(tonumber(awardData[1]))
    local tmpLabel = td.RichText({
      {
        type = 1,
        color = td.WHITE,
        size = 18,
        str = g_LM:getBy("a00134")
      },
      {
        type = 2,
        file = itemData.icon .. td.PNG_Suffix,
        scale = 0.4
      },
      {
        type = 1,
        color = td.LIGHT_BLUE,
        size = 18,
        str = "x" .. awardData[2]
      }
    })
    tmpLabel:setAnchorPoint(cc.p(0, 0.5))
    tmpLabel:pos(-505, 45):addTo(parentPanel)
  end
  td.BtnSetTitle(self.m_BtnDo, g_LM:getBy("a00102"))
end
function MissionDlg:BtnDoCallback(sender, eventType)
  if ccui.TouchEventType.ended == eventType then
    if self.m_startType == StartType.DifficultWar or self.m_startType == StartType.SimpleWar then
      local recoLevel = MissionInfoManager:GetInstance():GetMissionInfo(self.m_mapId).base_level
      local baseLevel = UserDataManager:GetInstance():GetBaseCampLevel()
      if recoLevel > baseLevel then
        local msgData = {}
        msgData.content = g_LM:getBy("a00214")
        local button1 = {
          text = g_LM:getBy("a00116")
        }
        local button2 = {
          text = g_LM:getBy("a00009"),
          callFunc = function()
            self:StartGame()
          end
        }
        msgData.buttons = {button1, button2}
        local messageBox = MessageBoxDlg.new(msgData)
        messageBox:Show()
      else
        self:StartGame()
      end
    elseif self.m_startType == StartType.DifficultReceive or self.m_startType == StartType.SimpleReceive then
      self:close()
    end
  end
end
function MissionDlg:StartGame()
  if not self.m_missionId or self.m_missionId > 2000 then
    td.alertDebug("error,map id:" .. self.m_mapId .. ",mission id:" .. self.m_missionId)
    print("error,map id:" .. self.m_mapId .. ",mission id:" .. self.m_missionId)
    return
  end
  local loadingScene = require("app.scenes.LoadingScene").new(self.m_mapId, self.m_missionId)
  cc.Director:getInstance():replaceScene(loadingScene)
end
function MissionDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_Panel_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_Panel_bg, tmpPos) then
      scheduler.performWithDelayGlobal(function(times)
        self:close()
      end, 0.016666666666666666)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
function MissionDlg:ClearTmpNode()
  for k, value in pairs(self.m_tmpNodes) do
    value:removeFromParent()
  end
  self.m_tmpNodes = {}
end
function MissionDlg:SetBtnSelect(isSimple)
  if isSimple then
    self.m_BtnSimple:getChildByTag(2):setVisible(true)
    self.m_BtnDifficult:getChildByTag(2):setVisible(false)
  else
    self.m_BtnSimple:getChildByTag(2):setVisible(false)
    self.m_BtnDifficult:getChildByTag(2):setVisible(true)
  end
end
function MissionDlg:IsDifficult()
  local state = self.m_missionData.state
  if state <= td.MissionState.NotOccupied or state == td.MissionState.MonstSimpleOccu or state == td.MissionState.MonstSimpleOccued then
    return false
  end
  return true
end
function MissionDlg:_GetTypeStr(_type)
  local key = ""
  if _type == td.MapType.FangShou then
    key = "a00136"
  elseif _type == td.MapType.ZhanLing then
    key = "a00137"
  elseif _type == td.MapType.ZiYuan then
    key = "a00138"
  else
    key = "a00135"
  end
  return g_LM:getBy(key)
end
return MissionDlg
