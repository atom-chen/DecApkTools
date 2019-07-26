local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local InformationManager = require("app.layers.InformationManager")
local RobFightOverDlg = class("RobFightOverDlg", BaseDlg)
function RobFightOverDlg:ctor()
  RobFightOverDlg.super.ctor(self)
  self.m_uiRoot = nil
  self.m_bActionOver = false
  self.m_bExit = false
  local gameDataMng = GameDataManager:GetInstance()
  if gameDataMng:GetMaxNeedCount(td.ResourceType.Gold) > 0 then
    self.m_iRobType = td.RobType.Gold
    self.m_iRobCount = gameDataMng:GetCurNeedCount(td.ResourceType.Gold)
  else
    self.m_iRobType = td.RobType.Exp
    self.m_iRobCount = gameDataMng:GetCurNeedCount(td.ResourceType.Exp)
  end
  self.m_iRobCountEnd = self.m_iRobCount
  self.m_bStartCount = false
  self:setNodeEventEnabled(true)
  self:InitUI()
end
function RobFightOverDlg:onEnter()
  RobFightOverDlg.super.onEnter(self)
  g_MC:SetShowAlert(false)
  self:AddListeners()
  self:SendRequest()
  G_SoundUtil:StopMusic()
  G_SoundUtil:StopAllSounds()
  G_SoundUtil:PlaySound(51, false)
end
function RobFightOverDlg:onExit()
  self:removeNodeEventListener(handler(self, self.update))
  self:unscheduleUpdate()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.RobAfter)
  g_MC:SetShowAlert(true)
end
function RobFightOverDlg:update(dt)
  if self.m_bStartCount then
    if self.m_iRobCount < self.m_iRobCountEnd then
      if self.m_iRobCountEnd - self.m_iRobCount > 10 then
        self.m_iRobCount = self.m_iRobCount + math.floor((self.m_iRobCountEnd - self.m_iRobCount) / 10)
      else
        self.m_iRobCount = self.m_iRobCount + 1
      end
      self.m_numberLabel:setString("" .. self.m_iRobCount)
    else
      self:ActionOver()
    end
  end
end
function RobFightOverDlg:AddListeners()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
  self:scheduleUpdate()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.RobAfter, handler(self, self.GetRobAwardCallback))
end
function RobFightOverDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/RobFightOverDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "BG")
  self.m_dial = cc.uiloader:seekNodeByName(self.m_uiRoot, "Dial")
  local iconStr = self.m_iRobType == td.RobType.Exp and td.EXP_ICON or td.GOLD_ICON
  local iconSpr = display.newSprite(iconStr)
  iconSpr:pos(140, 65):addTo(self.m_bg)
  self.m_numberLabel = cc.LabelBMFont:create("" .. self.m_iRobCount, td.UI_shuzi_yellow)
  td.AddRelaPos(self.m_bg, self.m_numberLabel, 1, cc.p(0.5, 0.18))
end
function RobFightOverDlg:onTouchEnded()
  if self.m_bActionOver and not self.m_bExit then
    self.m_bExit = true
    GameDataManager:GetInstance():ExitGame(td.UIModule.Rob)
  end
end
function RobFightOverDlg:SendRequest()
  local log = GameDataManager:GetInstance():GetBattleLog()
  local robType = GameDataManager:GetInstance():GetRobData().type
  local robItem = td.ItemID_Gold
  if robType == td.ResourceType.Exp then
    robItem = td.ItemID_Exp
  end
  local logStr, nickname = "", UserDataManager:GetInstance():GetNickname()
  for key, var in pairs(log) do
    logStr = logStr .. string.format("%d#%d&", key, var)
    print(string.format("%d kill %d unit", key, var))
  end
  if logStr ~= "" then
    logStr = string.sub(logStr, 1, string.len(logStr) - 1)
  end
  local data = {}
  data.value = self.m_iRobCount
  data.msg = string.format("%s,%d,%d,%s", nickname, robItem, self.m_iRobCount, logStr)
  print("\230\142\160\229\164\186\230\136\152\230\138\165\239\188\154" .. data.msg)
  local Msg = {}
  Msg.msgType = td.RequestID.RobAfter
  Msg.sendData = data
  TDHttpRequest:getInstance():Send(Msg)
end
function RobFightOverDlg:GetRobAwardCallback(data)
  td.alertDebug("\229\128\141\231\142\135" .. data.num)
  print("\229\128\141\231\142\135" .. data.num)
  UserDataManager:GetInstance():UpdateRobTime()
  self.m_vSpines = {}
  local bgSpine = SkeletonUnit:create("Spine/UI_effect/EFT_zhuanpanquan_01")
  td.AddRelaPos(self.m_bg, bgSpine, 1, cc.p(0.5, 0.63))
  bgSpine:PlayAni("animation", true)
  table.insert(self.m_vSpines, bgSpine)
  local vPos, vScalex = {
    cc.p(0.13, 0.7),
    cc.p(0.87, 0.7)
  }, {1, -1}
  for i = 1, 2 do
    local spine = SkeletonUnit:create("Spine/UI_effect/EFT_zhuanpanhuang_01")
    td.AddRelaPos(self.m_bg, spine, 1, vPos[i])
    spine:setScaleX(vScalex[i])
    spine:PlayAni("animation", true)
    table.insert(self.m_vSpines, spine)
  end
  local tarRotation = self:GetRotation(data.num) + 360 * math.random(5)
  local duration = tarRotation / 360
  self.m_dial:runAction(cca.seq({
    cc.EaseInOut:create(cca.rotateBy(duration, -tarRotation), 3),
    cca.cb(function()
      for key, var in ipairs(self.m_vSpines) do
        var:removeFromParent()
      end
      self.m_vSpines = {}
      local spine1 = SkeletonUnit:create("Spine/UI_effect/EFT_zhuanpanbeijing_01")
      td.AddRelaPos(self.m_bg, spine1, -1)
      spine1:PlayAni("animation", true)
      local spine2 = SkeletonUnit:create("Spine/UI_effect/EFT_baoshan_01")
      td.AddRelaPos(self.m_bg, spine2, 1, cc.p(0.5, 0.63))
      spine2:PlayAni("animation", false)
      table.insert(self.m_vSpines, spine2)
      local spine3 = SkeletonUnit:create("Spine/UI_effect/EFT_zishanguang_01")
      td.AddRelaPos(self.m_bg, spine3, 1, cc.p(0.5, 0.15))
      spine3:PlayAni("animation", true)
      table.insert(self.m_vSpines, spine3)
      self.m_bStartCount = true
      self.m_iRobCountEnd = self.m_iRobCount * data.num
    end)
  }))
  G_SoundUtil:PlaySound(57, false)
end
function RobFightOverDlg:GetRotation(ratio)
  local rotation = (ratio - 2) * 72 % 360
  return rotation
end
function RobFightOverDlg:ActionOver()
  self.m_bStartCount = false
  self.m_bActionOver = true
  for key, var in ipairs(self.m_vSpines) do
    var:removeFromParent()
  end
  self.m_vSpines = {}
  local _pos = cc.p(self.m_bg:getContentSize().width * 0.5, self.m_bg:getContentSize().width * 0.17)
  td.CreateUIEffect(self.m_bg, "Spine/UI_effect/EFT_zibaoshan_01", {
    pos = _pos,
    cb = function()
      local itemId = self.m_iRobType == td.RobType.Exp and td.ItemID_Exp or td.ItemID_Gold
      InformationManager:GetInstance():ShowInfoDlg({
        type = td.ShowInfo.Item,
        items = {
          [itemId] = self.m_iRobCountEnd
        }
      })
    end
  })
end
return RobFightOverDlg
