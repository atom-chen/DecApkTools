local CommanderInfoManager = require("app.info.CommanderInfoManager")
local UserDataManager = require("app.UserDataManager")
local GameDataManager = require("app.GameDataManager")
local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local GuideManager = require("app.GuideManager")
local CommonInfoManager = require("app.info.CommonInfoManager")
local RobDlg = class("RobDlg", BaseDlg)
function RobDlg:ctor()
  RobDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Rob
  self.m_udMng = UserDataManager:GetInstance()
  self.m_list = nil
  self.m_robType = td.RobType.Gold
  self.m_itemId = td.ItemID_Gold
  self.m_currIndex = 0
  self.m_robData = {}
  self.m_enemyData = {}
  self:InitUI()
end
function RobDlg:InitUI()
  self:LoadUI("CCS/RobDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetBg("UI/rob/lueduo_bg.png")
  self:SetTitle(td.Word_Path .. "wenzi_jinbilueduo.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_collector = SkeletonUnit:create("Spine/UI_effect/UI_caijiqi_01")
  self.m_collector:pos(268, 185):addTo(self.m_bg)
  self.m_collector:PlayAni("animation", true)
  self.m_btnSet = cc.uiloader:seekNodeByName(self.m_bg, "Button_set")
  td.BtnSetTitle(self.m_btnSet, g_LM:getBy("a00026"))
  td.BtnAddTouch(self.m_btnSet, handler(self, self.GoToRobSetting))
  self.m_textTime = cc.uiloader:seekNodeByName(self.m_bg, "Text_times")
  local btnAdd = cc.uiloader:seekNodeByName(self.m_bg, "Button_add_chance")
  td.BtnAddTouch(btnAdd, handler(self, self.OnAddBtnClicked))
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_choose")
  label:setString(g_LM:getBy("a00378"))
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_times_left")
  label:setString(g_LM:getBy("a00188"))
  self:CreateList()
  self:RefreshUI()
end
function RobDlg:RefreshUI()
  local remainTimes = self.m_udMng:GetDungeonTime(self.m_uiId)
  self.m_textTime:setString(remainTimes)
  if remainTimes <= 0 then
    self.m_textTime:setColor(td.RED)
  else
    self.m_textTime:setColor(td.WHITE)
  end
end
function RobDlg:onEnter()
  RobDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetRobList, handler(self, self.GetRobListCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetRobDetail, handler(self, self.GetRobDetailCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.MallBuy, handler(self, self.BuyCallback))
  self:AddEvents()
  GuideManager.H_StartGuideGroup(115)
  self:CheckGuide()
end
function RobDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetRobList)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetRobDetail)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.MallBuy)
  RobDlg.super.onExit(self)
end
function RobDlg:CreateList()
  self.m_list = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 555, 400),
    touchOnContent = true,
    scale = self.m_scale
  })
  self.m_list:setName("ListView")
  self.m_list:onTouch(function(event)
    if "clicked" == event.name and event.item then
      if self.m_udMng:GetDungeonTime(self.m_uiId) <= 0 then
        td.alertErrorMsg(td.ErrorCode.MISSION_TIME_NOT_ENOUGH)
      else
        self.m_currIndex = event.itemPos
        self:StartBattle()
        td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
      end
    end
  end)
  self.m_list:pos(535, 150):addTo(self.m_bg)
  self:SendRobListRequest()
end
function RobDlg:RefreshList()
  self.m_list:removeAllItems()
  for key, val in ipairs(self.m_robData) do
    if val.fid ~= UserDataManager:GetInstance():GetUId() then
      local item = self:CreateItem(val)
      self.m_list:addItem(item)
    end
  end
  self.m_list:reload()
end
function RobDlg:CreateItem(itemData)
  local itemNode = cc.uiloader:load("CCS/RobRivalItem.csb")
  local itemBg = cc.uiloader:seekNodeByName(itemNode, "Image_bg")
  local textName = cc.uiloader:seekNodeByName(itemNode, "Text_name")
  textName:setString(itemData.uname)
  local nodeMRank = cc.uiloader:seekNodeByName(itemNode, "Node_mrank")
  local honorInfo = CommanderInfoManager:GetInstance():GetHonorInfoByRepu(itemData.reputation)
  local imagePath = honorInfo.image .. td.PNG_Suffix
  local imageHonor = display.newSprite(imagePath)
  imageHonor:setScale(0.6, 0.6)
  imageHonor:pos(-15, -10):setAnchorPoint(0, 0)
  imageHonor:addTo(nodeMRank)
  local textPowerLabel = cc.uiloader:seekNodeByName(itemNode, "Text_power_label")
  textPowerLabel:setString(g_LM:getBy("a00032") .. ": ")
  local textPowerData = cc.uiloader:seekNodeByName(itemNode, "Text_power_data")
  textPowerData:setString(tostring(itemData.attack))
  local textGoldLabel = cc.uiloader:seekNodeByName(itemNode, "Text_gold_label")
  textGoldLabel:setString(g_LM:getBy("a00249") .. ": ")
  local max = td.GetMaxRob(self.m_itemId, itemData.level)
  local num = cc.clampf(itemData.num, 0, max)
  local textGoldData = cc.uiloader:seekNodeByName(itemNode, "Text_gold_data")
  textGoldData:setString(tostring(num))
  local size = itemBg:getContentSize()
  local item = self.m_list:newItem(itemNode)
  item:setAnchorPoint(cc.p(0.5, 0.5))
  item:setItemSize((size.width + 20) * self.m_scale, (size.height + 25) * self.m_scale)
  item:setScale(self.m_scale)
  return item
end
function RobDlg:OnAddBtnClicked()
  td.ShowBuyTimeDlg(self.m_uiId, handler(self, self.SendBuyRequest))
end
function RobDlg:StartBattle()
  if self.m_currIndex ~= 0 then
    local fid = self.m_robData[self.m_currIndex].fid
    if self.m_enemyData.fid == fid then
      self:EnterRob()
    else
      self.m_enemyData.level = self.m_robData[self.m_currIndex].level
      self.m_enemyData.name = self.m_robData[self.m_currIndex].uname
      self.m_enemyData.num = self.m_robData[self.m_currIndex].num
      self.m_enemyData.type = td.ResourceType.Gold
      self:SendGetRobDetailRequest(fid)
    end
  end
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
end
function RobDlg:EnterRob()
  local dlg = require("app.layers.MainMenuUI.RobDetailDlg").new(self.m_enemyData)
  td.popView(dlg)
end
function RobDlg:GoToRobSetting()
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  local robSetting = require("app.layers.MainMenuUI.RobSettingDlg").new()
  td.popView(robSetting)
end
function RobDlg:SendRobListRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetRobList
  Msg.sendData = {
    type = self.m_robType
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function RobDlg:GetRobListCallback(data)
  self.m_robData = data.zplunderProto
  self:RefreshList()
end
function RobDlg:SendGetRobDetailRequest(id)
  local Msg = {}
  Msg.msgType = td.RequestID.GetRobDetail
  Msg.sendData = {fid = id}
  Msg.cbData = {fid = id}
  TDHttpRequest:getInstance():Send(Msg)
end
function RobDlg:GetRobDetailCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    self.m_enemyData.heros = data.arenaHeroProto
    self.m_enemyData.weapons = data.weaponProto
    self.m_enemyData.guildSkill = data.guildSkillproto
    self.m_enemyData.skillProto = data.friendSkillproto
    self.m_enemyData.fid = cbData.fid
    self:EnterRob()
  end
end
function RobDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_list:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_list:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
      return true
    end
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_list:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_list:onTouch_({
        name = "moved",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    self.m_list:onTouch_({
      name = "ended",
      x = touch:getLocation().x,
      y = touch:getLocation().y,
      prevX = touch:getPreviousLocation().x,
      prevY = touch:getPreviousLocation().y
    })
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
function RobDlg:SendBuyRequest()
  if self.m_bIsRequsting then
    return
  end
  self.m_bIsRequsting = true
  local Msg = {}
  Msg.msgType = td.RequestID.MallBuy
  Msg.sendData = {
    id = td.BuyRobId,
    num = 1
  }
  Msg.cbData = {
    id = td.BuyRobId
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function RobDlg:BuyCallback(data, cbData)
  if data.state == td.ResponseState.Success and cbData.id == td.BuyRobId then
    self.m_udMng:UpdateDungeonTime(self.m_uiId, 1)
    self.m_udMng:UpdateDungeonBuyTime(self.m_uiId, -1)
    self:RefreshUI()
  end
  self.m_bIsRequsting = false
end
return RobDlg
