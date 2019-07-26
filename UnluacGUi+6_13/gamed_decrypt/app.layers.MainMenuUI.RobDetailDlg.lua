local UserDataManager = require("app.UserDataManager")
local GameDataManager = require("app.GameDataManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local RobDetailDlg = class("RobDetailDlg", BaseDlg)
function RobDetailDlg:ctor(data)
  RobDetailDlg.super.ctor(self)
  self.m_uiId = td.UIModule.RobDetail
  self.m_data = data
  self:InitUI()
end
function RobDetailDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/RobDetailDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self:SetTitle(td.Word_Path .. "wenzi_difangfangshouyingxiong.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_btnStart = cc.uiloader:seekNodeByName(self.m_bg, "Button_yes_2")
  td.BtnSetTitle(self.m_btnStart, g_LM:getBy("a00102"))
  td.BtnAddTouch(self.m_btnStart, handler(self, self.StartBattle), nil, td.ButtonEffectType.Long)
  for i = 1, 3 do
    local heroPanel = cc.uiloader:seekNodeByName(self.m_bg, "Panel_hero" .. i)
    local heroNode = heroPanel:getChildByName("Node_hero")
    local heroData = self.m_data.heros[i]
    if heroData then
      local heroInfo = ActorInfoManager:GetInstance():GetHeroInfo(heroData.hid)
      local skeleton = SkeletonUnit:create(heroInfo.image)
      skeleton:PlayAni("stand")
      skeleton:scale(heroInfo.scale):addTo(heroNode)
      local lightSpr = heroPanel:getChildByName("srp_light")
      lightSpr:setVisible(true)
      local nameLabel = td.CreateLabel(heroInfo.name, td.YELLOW, 22, td.OL_BROWN)
      nameLabel:pos(0, -35):addTo(heroNode)
    end
  end
end
function RobDetailDlg:onEnter()
  RobDetailDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.RobBefore, handler(self, self.StartCallback))
  self:AddEvents()
end
function RobDetailDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.RobBefore)
  RobDetailDlg.super.onExit(self)
end
function RobDetailDlg:StartBattle()
  if td.CheckStamina(td.ROB_GOLD_ID) then
    self:SendStartRequest()
  else
    td.alert(g_LM:getBy("a00351"))
  end
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
end
function RobDetailDlg:EnterRob()
  GameDataManager:GetInstance():SetRobData(self.m_data)
  g_MC:OpenModule(td.UIModule.MissionReady, td.ROB_GOLD_ID)
end
function RobDetailDlg:SendStartRequest()
  local data = {}
  data.fid = self.m_data.fid
  data.item_id = td.ItemID_Gold
  data.msg = string.format("%s,%d", UserDataManager:GetInstance():GetNickname(), td.ItemID_Gold)
  local Msg = {}
  Msg.msgType = td.RequestID.RobBefore
  Msg.sendData = data
  TDHttpRequest:getInstance():Send(Msg)
end
function RobDetailDlg:StartCallback(data)
  if data.state == td.ResponseState.Success then
    UserDataManager:GetInstance():UpdateDungeonTime(td.UIModule.Rob, -1)
    self:EnterRob()
  end
end
function RobDetailDlg:AddEvents()
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
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
return RobDetailDlg
