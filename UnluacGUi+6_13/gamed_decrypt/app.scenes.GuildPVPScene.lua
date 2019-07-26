local UserDataManager = require("app.UserDataManager")
local GameSceneBase = require("app.scenes.GameSceneBase")
local TDHttpRequest = require("app.net.TDHttpRequest")
local NetManager = require("app.net.NetManager")
local scheduler = require("framework.scheduler")
local GuildPVPScene = class("GuildPVPScene", GameSceneBase)
local MAX_RES = 8000
function GuildPVPScene:ctor()
  GuildPVPScene.super.ctor(self)
  self.m_eType = td.SceneType.GuildPVP
  self.m_udMng = UserDataManager:GetInstance()
  self.m_gdMng = self.m_udMng:GetGuildManager()
  self.m_pvpData = self.m_gdMng:GetGuildPVPData()
  self.m_vBattlePosData = {}
  self.m_reqTiemInterval = 0
  self.m_bReceived = true
  self.m_vBattleBtn = {}
  self:Init()
end
function GuildPVPScene:onEnter()
  GuildPVPScene.super.onEnter(self)
  self:AddListeners()
  self:AddBtnEvent()
  g_NetManager:startHeartBeat()
  G_SoundUtil:PlayMusic(13, true)
  self.m_gdMng:GetPVPDetailReq()
  self.m_timeScheduler = scheduler.scheduleGlobal(function()
    self:OnTimer()
  end, 1)
end
function GuildPVPScene:onExit()
  self:StopTimer()
  GuildPVPScene.super.onExit(self)
end
function GuildPVPScene:Init()
  self.m_uiRoot = cc.uiloader:load("CCS/guild/GuildPVPLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_scale = td.GetAutoScale()
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.m_panelTop = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_top")
  td.SetAutoScale(self.m_panelTop, td.UIPosHorizontal.Center, td.UIPosVertical.Top)
  self.m_panelBottom = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bottom")
  td.SetAutoScale(self.m_panelBottom, td.UIPosHorizontal.Center, td.UIPosVertical.Bottom)
  self:InitMap()
  self:InitUI()
end
function GuildPVPScene:InitUI()
  local selfGuildData = self.m_gdMng:GetGuildData()
  local headBg1 = cc.uiloader:seekNodeByName(self.m_panelTop, "Image_headBg1")
  local imageHead = cc.uiloader:seekNodeByName(headBg1, "Image_head")
  imageHead:loadTexture("UI/icon/guild/" .. selfGuildData.guild_emblem .. ".png")
  local nameLabel = cc.uiloader:seekNodeByName(headBg1, "Text_name")
  nameLabel:setString(selfGuildData.guild_name)
  self.m_progressSelf = cc.uiloader:seekNodeByName(headBg1, "LoadingBar_1")
  self.m_labelRes1 = td.CreateLabel("0/" .. MAX_RES, td.WHITE, 20, td.OL_BLACK)
  self.m_labelRes1:align(display.RIGHT_CENTER, 430, 25):addTo(headBg1)
  local enemyGuildData = self.m_pvpData:GetValue("enemyGuild")
  headBg1 = cc.uiloader:seekNodeByName(self.m_panelTop, "Image_headBg2")
  imageHead = cc.uiloader:seekNodeByName(headBg1, "Image_head")
  imageHead:loadTexture("UI/icon/guild/" .. enemyGuildData.head .. ".png")
  nameLabel = cc.uiloader:seekNodeByName(headBg1, "Text_name")
  nameLabel:setString(enemyGuildData.name)
  self.m_progressEnemy = cc.uiloader:seekNodeByName(headBg1, "LoadingBar_1")
  self.m_labelRes2 = td.CreateLabel("0/" .. MAX_RES, td.WHITE, 20, td.OL_BLACK)
  self.m_labelRes2:align(display.LEFT_CENTER, -350, 25):addTo(headBg1)
  local spineVS = SkeletonUnit:create("Spine/UI_effect/UI_juntuanzhan_02")
  spineVS:PlayAni("animation")
  td.AddRelaPos(self.m_panelTop, spineVS, 1, cc.p(0.5, 0.9))
  self.m_btnInfo = cc.uiloader:seekNodeByName(self.m_panelBottom, "Button_info")
  td.BtnSetTitle(self.m_btnInfo, g_LM:getBy("g00042"))
  self.m_btnBack = cc.uiloader:seekNodeByName(self.m_panelBottom, "Button_back")
  td.BtnSetTitle(self.m_btnBack, g_LM:getBy("a00240"))
  self.m_btnPrepare = cc.uiloader:seekNodeByName(self.m_panelBottom, "Button_lineup")
  td.BtnSetTitle(self.m_btnPrepare, g_LM:getBy("a00320"))
end
function GuildPVPScene:InitMap()
  local mapRect = cc.rect(0, 0, display.width, display.height)
  cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2D_PIXEL_FORMAT_RGB565)
  self.m_map = display.newSprite("UI/guild/guild_pvp_map.png")
  cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2D_PIXEL_FORMAT_RGBA8888)
  self.m_map:scale(self.m_scale * 0.6)
  local emptyNode = cc.Node:create()
  emptyNode:pos(mapRect.width / 2, mapRect.height / 2)
  emptyNode:addChild(self.m_map)
  self.m_scrollView = cc.ui.UIScrollView.new({viewRect = mapRect, scale = 1}):addScrollNode(emptyNode):setBounceable(false):addTo(self)
  self:AddBattleBtns()
end
function GuildPVPScene:AddBattleBtns()
  local config = require("app.config.guild_pvp_config")
  for i, var in ipairs(config) do
    local btn = ccui.Button:create("UI/scale9/transparent1x1.png", "UI/scale9/transparent1x1.png")
    btn:setTag(i)
    btn:setScale9Enabled(true)
    btn:setContentSize(cc.size(370, 200))
    td.BtnAddTouch(btn, handler(self, self.OnBattleBtnClicked))
    btn:pos(var.x, var.y):addTo(self.m_map)
    self:ShowTip(btn)
    table.insert(self.m_vBattleBtn, btn)
  end
end
function GuildPVPScene:ShowTip(btn)
  local label = td.CreateLabel(g_LM:getBy("t00018"), td.YELLOW, 16, td.OL_BROWN, 2)
  local labelSize = label:getContentSize()
  local bgSize = cc.size(labelSize.width + 20, labelSize.height + 20)
  local pArrow = display.newScale9Sprite("UI/scale9/paopaokuang2.png", 0, 0, bgSize)
  pArrow:setRotation(180)
  label:setRotation(-180)
  td.AddRelaPos(pArrow, label)
  local spr = display.newSprite("UI/scale9/paopaokuang1.png")
  spr:setAnchorPoint(0.5, 0)
  spr:setPosition(bgSize.width / 2, bgSize.height - 4)
  pArrow:addChild(spr)
  pArrow:setScale(0.01)
  pArrow:runAction(cca.seq({
    cca.delay(math.random(10) / 10),
    cca.scaleTo(0.2, 2.4),
    cca.scaleTo(0.2, 1.7),
    cca.scaleTo(0.2, 2),
    cca.cb(function()
      pArrow:runAction(cca.repeatForever(cca.seq({
        cca.moveBy(0.5, 0, 10),
        cca.moveBy(1, 0, -20),
        cca.moveBy(0.5, 0, 10)
      })))
    end)
  }))
  td.AddRelaPos(btn, pArrow, 2, cc.p(0.5, 1))
end
function GuildPVPScene:UpdateBattleBtns()
  local vNewBattlePosData = clone(self.m_pvpData:GetValue("battlePos"))
  for i, var in pairs(vNewBattlePosData) do
    if nil == self.m_vBattlePosData[i] or self.m_vBattlePosData[i].id ~= var.id then
      local battleBtn = self.m_vBattleBtn[i]
      battleBtn:removeAllChildren()
      if var.id ~= 0 then
        self:_CreatePosEffect(battleBtn, self.m_vBattlePosData[i], var)
        self:_CreatePosContent(battleBtn, var)
      end
    end
  end
  self.m_vBattlePosData = vNewBattlePosData
  self:UpdateRes()
  self.m_bReceived = true
end
function GuildPVPScene:_CreatePosContent(battleBtn, curData)
  if curData.id == self.m_udMng:GetUId() then
    local arrowSpr = display.newSprite("UI/common/yindaojiantou.png")
    arrowSpr:scale(2)
    td.AddRelaPos(battleBtn, arrowSpr, 4, cc.p(0.5, 2))
    arrowSpr:runAction(cca.repeatForever(cca.seq({
      cca.moveBy(0.5, 0, -50),
      cca.moveBy(1, 0, 100),
      cca.moveBy(0.5, 0, -50)
    })))
  end
  local nameLabel = td.CreateLabel(curData.name, td.WHITE, 30)
  td.AddRelaPos(battleBtn, nameLabel, 2, cc.p(0.5, 0.7))
  local headSpr = display.newSprite(td.GetPortrait(curData.head))
  headSpr:scale(0.5)
  td.AddRelaPos(battleBtn, headSpr, 2, cc.p(0.5, 1))
  local serverTime = self.m_udMng:GetServerTime()
  local cd = 180 - (serverTime - curData.atkedTime)
  local timeLabel = td.CreateLabel(self:GetTimeDownStr(cd), td.WHITE, 30)
  timeLabel:setName("cdLabel")
  td.AddRelaPos(battleBtn, timeLabel, 2, cc.p(0.5, 0.5))
end
function GuildPVPScene:_CreatePosEffect(battleBtn, lastData, curData)
  local fileName1, fileName2
  if lastData == nil then
    if curData.isSelf then
      fileName1 = "Spine/UI_effect/UI_juntuanguang_lan"
      fileName2 = "Spine/UI_effect/UI_zhanlingguang_01"
    else
      fileName1 = "Spine/UI_effect/UI_juntuanguang_hong"
      fileName2 = "Spine/UI_effect/UI_zhanlingguang_04"
    end
  elseif lastData.isSelf ~= curData.isSelf then
    if curData.isSelf then
      fileName1 = "Spine/UI_effect/UI_zhanlingguang_03"
      fileName2 = "Spine/UI_effect/UI_zhanlingguang_01"
    else
      fileName1 = "Spine/UI_effect/UI_zhanlingguang_02"
      fileName2 = "Spine/UI_effect/UI_zhanlingguang_04"
    end
  end
  td.CreateUIEffect(battleBtn, fileName1, {
    scale = 2.5,
    loop = false,
    cb = function()
      td.CreateUIEffect(battleBtn, fileName2, {scale = 2.5, loop = true})
    end
  })
end
function GuildPVPScene:OnBattleBtnClicked(sender)
  self:GetBattlePosDetailReq(sender:getTag())
end
function GuildPVPScene:Prepare()
  local loadingScene = require("app.scenes.LoadingScene").new(td.PVP_GUILD_ID)
  cc.Director:getInstance():replaceScene(loadingScene)
end
function GuildPVPScene:ShowLog()
  local dlg = require("app.layers.guild.GuildPVPLogDlg").new()
  td.popView(dlg)
end
function GuildPVPScene:Leave()
  self:GuildPVPLeaveReq()
  local pScene = require("app.scenes.GuildScene").new()
  pScene:SetEnterModule(3)
  cc.Director:getInstance():replaceScene(pScene)
end
function GuildPVPScene:OnTimer()
  local serverTime = self.m_udMng:GetServerTime()
  for i, var in pairs(self.m_vBattlePosData) do
    local battleBtn = self.m_vBattleBtn[i]
    local timeLabel = battleBtn:getChildByName("cdLabel")
    local cd = 180 - (serverTime - var.atkedTime)
    timeLabel:setString(self:GetTimeDownStr(cd))
    local attackingSp = battleBtn:getChildByName("attacking")
    if cd <= 0 and attackingSp then
      attackingSp:removeFromParent()
    elseif cd > 0 and nil == attackingSp then
      local attackSp = SkeletonUnit:create("Spine/UI_effect/UI_xiaojian_01")
      attackSp:scale(2)
      attackSp:PlayAni("animation", true)
      attackSp:setName("attacking")
      td.AddRelaPos(battleBtn, attackSp, 3, cc.p(0.5, 1.5))
    end
  end
  self:UpdateRes()
end
function GuildPVPScene:StopTimer()
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
    self.m_timeScheduler = nil
  end
end
function GuildPVPScene:GetTimeDownStr(time)
  if time <= 0 then
    return ""
  end
  local min, sec = math.floor(time % 3600 / 60), math.floor(time % 60)
  local str = string.format(" %02d:%02d", min, sec)
  return str
end
function GuildPVPScene:UpdateRes()
  local selfRes = self.m_pvpData:GetValue("totalRes")
  local enemyRes = self.m_pvpData:GetValue("totalEnemyRes")
  for i, var in pairs(self.m_vBattlePosData) do
    local res = td.CalGuildPVPRes(var.startTime)
    if var.isSelf then
      selfRes = selfRes + res
    else
      enemyRes = enemyRes + res
    end
  end
  self.m_progressSelf:setPercent(selfRes / MAX_RES * 100)
  self.m_labelRes1:setString(string.format("%d/%d", math.min(selfRes, MAX_RES), MAX_RES))
  self.m_progressEnemy:setPercent(enemyRes / MAX_RES * 100)
  self.m_labelRes2:setString(string.format("%d/%d", math.min(enemyRes, MAX_RES), MAX_RES))
end
function GuildPVPScene:AddListeners()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetGuildPVPPos, handler(self, self.GetBattlePosDetailCallback))
  self:AddCustomEvent(td.GUILD_PVP_UPDATE, handler(self, self.UpdateBattleBtns))
  self:AddCustomEvent(td.GUILD_PVP_INFO_UPDATE, function()
    local dlg = require("app.layers.guild.GuildPVPOverDlg").new()
    td.popView(dlg)
  end)
  self:AddCustomEvent(td.HEART_BEAT, handler(self, self.HeartBeatCallback))
end
function GuildPVPScene:RemoveListeners()
  GuildPVPScene.super.RemoveListeners(self)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetGuildPVPPos)
end
function GuildPVPScene:AddBtnEvent()
  td.BtnAddTouch(self.m_btnInfo, handler(self, self.ShowLog))
  td.BtnAddTouch(self.m_btnBack, handler(self, self.Leave))
  td.BtnAddTouch(self.m_btnPrepare, handler(self, self.Prepare))
end
function GuildPVPScene:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, _event)
    self.m_bTouchInScrollView = false
    local pos = touch:getLocation()
    local posInRect = self:convertToNodeSpace({
      x = pos.x,
      y = pos.y
    })
    if self.m_scrollView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_bTouchInScrollView = true
      self.m_scrollView:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bTouchInScrollView then
      if self.m_scrollView:isTouchInViewRect({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.m_scrollView:onTouch_({
          name = "moved",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
      end
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    self.m_scrollView:onTouch_({
      name = "ended",
      x = touch:getLocation().x,
      y = touch:getLocation().y,
      prevX = touch:getPreviousLocation().x,
      prevY = touch:getPreviousLocation().y
    })
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function GuildPVPScene:HeartBeatCallback(event)
  local str = event:getDataString()
  local data = string.toTable(str)
  if data.type == td.HBType.GuildPVPOver then
    self:StopTimer()
    self.m_gdMng:SendRequest(nil, td.RequestID.GetGuildPVPInfo)
  elseif data.type == td.HBType.GuildPVPUp then
    self.m_gdMng:GetPVPDetailReq()
  end
end
function GuildPVPScene:GetBattlePosDetailReq(_index)
  local Msg = {}
  Msg.msgType = td.RequestID.GetGuildPVPPos
  Msg.sendData = {
    index = _index,
    team_id = self.m_pvpData:GetValue("battleId")
  }
  Msg.cbData = clone(Msg.sendData)
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildPVPScene:GetBattlePosDetailCallback(data, cbData)
  local newPosData = data.guildBattleProto
  self.m_pvpData:UpdateBattlePosData(newPosData)
  local serverTime = self.m_udMng:GetServerTime()
  local localPosData = self.m_vBattlePosData[cbData.index]
  if nil == localPosData or newPosData.uid ~= localPosData.id then
    self:UpdateBattleBtns()
  end
  if nil == localPosData and newPosData.uid == self.m_udMng:GetUId() then
    td.alert(g_LM:getBy("a00356"))
  elseif newPosData.uid == "" then
    td.alert(g_LM:getBy("a00357"))
  else
    local infoDlg = require("app.layers.guild.GuildPVPInfoDlg").new(newPosData.index)
    td.popView(infoDlg)
  end
end
function GuildPVPScene:GuildPVPLeaveReq()
  local Msg = {}
  Msg.msgType = td.RequestID.GuildPVPLeave
  Msg.sendData = {
    team_id = self.m_pvpData:GetValue("battleId")
  }
  TDHttpRequest:getInstance():Send(Msg)
end
return GuildPVPScene
