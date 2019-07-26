local MissionInfoManager = require("app.info.MissionInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local GuideManager = require("app.GuideManager")
local UserDataManager = require("app.UserDataManager")
local TouchIcon = require("app.widgets.TouchIcon")
local MessageBoxDlg = require("app.layers.MessageBoxDlg")
local BaseDlg = require("app.layers.BaseDlg")
local MissionLayer = class("MissionLayer", BaseDlg)
function MissionLayer:ctor(missionId)
  MissionLayer.super.ctor(self, 255, true)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_miMng = MissionInfoManager:GetInstance()
  self.m_uiId = td.UIModule.MissionDetail
  self.m_vTargetLabel = {}
  self.m_scale = 1
  self.m_bDefense = false
  self:SetMissionData(missionId)
  self:InitUI()
end
function MissionLayer:onEnter()
  MissionLayer.super.onEnter(self)
  self:AddCustomEvent(td.FIGHT_WIN, handler(self, self.QuickFightDone))
  self:AddCustomEvent(td.MISSION_UPDATE, handler(self, self.RefreshUI))
  self:AddCustomEvent(td.MISSION_DATA_INITED, handler(self, self.RefreshUI))
  self:AddCustomEvent(td.USERWEALTH_CHANGED, handler(self, self.RefreshUI))
  self:CreateForgroundMask()
  self:PlayEnterAni(function()
    self:CheckGuide()
    self:CheckGuideNode()
    self:RemoveForgroundMask()
  end)
end
function MissionLayer:onExit()
  td.dispatchEvent(td.MISSION_CLOSE)
  MissionLayer.super.onExit(self)
end
function MissionLayer:PlayEnterAni(cb)
  for i = 1, 2 do
    local gearSpr = cc.uiloader:seekNodeByName(self.m_panelLeft, "Sprite_gear" .. i)
    gearSpr:runAction(cc.EaseSineOut:create(cca.rotateBy(1.5, 540)))
    local clipSpr = cc.uiloader:seekNodeByName(self.m_panelLeft, "Sprite_clip" .. i)
    clipSpr:runAction(cca.rotateTo(0.5, 0))
  end
  local panelBg = cc.uiloader:seekNodeByName(self.m_panelLeft, "Panel_bg")
  panelBg:runAction(cca.moveBy(0.5, 75, 0))
  self.m_bg:runAction(cca.seq({
    cca.delay(0.3),
    cca.fadeIn(0.5),
    cca.cb(function()
      self.m_imageMap:setVisible(true)
    end)
  }))
  self.m_bg:getChildByTag(2):runAction(cca.seq({
    cca.delay(0.55),
    cca.fadeIn(0.3)
  }))
  local vRightElement = self.m_panelRight:getChildren()
  for i, var in ipairs(vRightElement) do
    local actions = {
      cca.delay(0.3 + i * 0.05),
      cc.EaseBackOut:create(cca.moveBy(0.3, -510, 0))
    }
    if i == #vRightElement then
      table.insert(actions, cca.cb(cb))
    end
    var:runAction(cca.seq(actions))
  end
  G_SoundUtil:PlaySound(67)
end
function MissionLayer:SetMissionData(missionId)
  self.m_missionId = missionId
  self.m_missionInfo = clone(self.m_miMng:GetMissionInfo(self.m_missionId))
  self.m_missionData = self.m_udMng:GetCityData(self.m_missionId)
  if self.m_missionData and self.m_missionData.occupation ~= td.OccupState.Normal then
    self.m_bDefense = true
    local defenseInfo = self.m_miMng:GetMissionInfo(self.m_missionInfo.defense_mission)
    self.m_missionInfo.vit = defenseInfo.vit
    self.m_missionInfo.exp = defenseInfo.exp
    self.m_missionInfo.award = defenseInfo.award
  end
end
function MissionLayer:InitUI()
  self:LoadUI("CCS/MissionLayer.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetBg("UI/common/uibg2.png")
  self:SetTitle(td.Word_Path .. "wenzi_chuzheng.png")
  self.m_panelLeft = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_left")
  self.m_panelRight = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_right")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_panelLeft, "Image_bg")
  self.m_imageMap = cc.uiloader:seekNodeByName(self.m_bg, "Image_map")
  self.m_imageMap:loadTexture(self.m_missionInfo.mini_map .. td.PNG_Suffix)
  self.m_imageMapBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_mapBg")
  if self.m_missionInfo.mode == 2 then
    self.m_imageMapBg:loadTexture("UI/mission/kunnan_tupian2_kuang.png")
  elseif self.m_missionInfo.mode == 3 then
    self.m_imageMapBg:loadTexture("UI/mission/emeng_tupian2_kuang.png")
  end
  self.m_modeBg = cc.uiloader:seekNodeByName(self.m_imageMapBg, "Mode_bg")
  local txtType = td.CreateLabel(self:_GetGameTypeStr(self.m_missionInfo.type), td.YELLOW, 20, td.OL_BROWN)
  td.AddRelaPos(self.m_modeBg, txtType)
  local txtName = cc.uiloader:seekNodeByName(self.m_bg, "Text_name")
  txtName:setString(self.m_missionInfo.name)
  local txtRcmdLvl = cc.uiloader:seekNodeByName(self.m_bg, "Text_recommend_lvl")
  txtRcmdLvl:setString(g_LM:getBy("a00131") .. self.m_missionInfo.base_level)
  local txtMode = cc.uiloader:seekNodeByName(self.m_bg, "Text_mode")
  txtMode:setString(self:_GetModeStr(self.m_missionInfo.mode))
  local txtGoal = cc.uiloader:seekNodeByName(self.m_bg, "Text_goal")
  txtGoal:setString(self.m_missionInfo.text)
  local panelCost = cc.uiloader:seekNodeByName(self.m_panelRight, "Panel_cost")
  local txtStamCost = cc.uiloader:seekNodeByName(panelCost, "Text_stamina_cost")
  txtStamCost:setString(g_LM:getBy("a00082") .. ":")
  local txtCostData = cc.uiloader:seekNodeByName(panelCost, "Text_cost_data")
  txtCostData:setString("x" .. self.m_missionInfo.vit)
  local txtExp = cc.uiloader:seekNodeByName(panelCost, "Text_exp_gain")
  txtExp:setString(g_LM:getBy("a00260") .. ":")
  local txtExpData = cc.uiloader:seekNodeByName(panelCost, "Text_gain_data")
  txtExpData:setString(self.m_missionInfo.exp)
  self.m_panelTimeLeft = cc.uiloader:seekNodeByName(self.m_panelRight, "Panel_time_left")
  self.m_txtTimeLeft = cc.uiloader:seekNodeByName(self.m_panelTimeLeft, "Text_times")
  self.m_btnAddTime = cc.uiloader:seekNodeByName(self.m_panelTimeLeft, "Button_add_chance")
  td.BtnAddTouch(self.m_btnAddTime, handler(self, self.BuyTime))
  local txtTimesLeft = cc.uiloader:seekNodeByName(self.m_panelTimeLeft, "Text_times_left")
  txtTimesLeft:setString(g_LM:getBy("a00188"))
  self.m_BtnStart = cc.uiloader:seekNodeByName(self.m_panelRight, "Button_start_3")
  td.BtnAddTouch(self.m_BtnStart, handler(self, self.BtnStartCallback))
  td.BtnSetTitle(self.m_BtnStart, g_LM:getBy("a00232"))
  self.m_BtnQuick = cc.uiloader:seekNodeByName(self.m_panelRight, "Button_quick_5")
  td.BtnAddTouch(self.m_BtnQuick, handler(self, self.BtnQuickCallback))
  td.BtnSetTitle(self.m_BtnQuick, g_LM:getBy("a00309"))
  self.m_BtnQuick10 = cc.uiloader:seekNodeByName(self.m_panelRight, "Button_quick10_5")
  td.BtnAddTouch(self.m_BtnQuick10, handler(self, self.BtnBatchCallback))
  td.BtnSetTitle(self.m_BtnQuick10, g_LM:getBy("a00261"))
  for i = 1, 3 do
    local label = cc.uiloader:seekNodeByName(self.m_panelRight, "Text_desc" .. i)
    table.insert(self.m_vTargetLabel, label)
  end
  self:CreateTargetList()
  self:CreateRewardList()
  self:RefreshUI()
  self:RefreshDefenseUI()
end
function MissionLayer:RefreshUI()
  if self.m_missionInfo.mode > 1 and self.m_missionData then
    self.m_txtTimeLeft:setString(string.format("%d/%d", self.m_missionData.num, td.MissionTime))
  else
    self.m_panelTimeLeft:setVisible(false)
  end
  if self.quickLabel then
    self.quickLabel:removeFromParent()
    self.quickLabel = nil
  end
  local costSweepNum = MissionInfoManager.GetSweepCost(1, self.m_missionInfo.sweep)
  local labelColor = costSweepNum > self.m_udMng:GetItemNum(50004) and td.RED or td.WHITE
  self.quickLabel = td.RichText({
    {
      type = 2,
      file = td.GetItemIcon(50004),
      scale = 0.3
    },
    {
      type = 1,
      str = "x" .. costSweepNum,
      color = labelColor,
      size = 18
    }
  })
  td.AddRelaPos(self.m_BtnQuick, self.quickLabel, 1, cc.p(0.5, -0.4))
  if self.quick10Label then
    self.quick10Label:removeFromParent()
    self.quick10Label = nil
  end
  costSweepNum = MissionInfoManager.GetSweepCost(2, self.m_missionInfo.sweep)
  labelColor = costSweepNum > self.m_udMng:GetItemNum(50004) and td.RED or td.WHITE
  self.quick10Label = td.RichText({
    {
      type = 2,
      file = td.GetItemIcon(50004),
      scale = 0.3
    },
    {
      type = 1,
      str = "x" .. costSweepNum,
      color = labelColor,
      size = 18
    }
  })
  td.AddRelaPos(self.m_BtnQuick10, self.quick10Label, 1, cc.p(0.5, -0.4))
  local bEnable = self:CheckCanFight(0)
  td.EnableButton(self.m_BtnStart, bEnable)
  bEnable = self:CheckCanFight(1)
  td.EnableButton(self.m_BtnQuick, bEnable)
  bEnable = self:CheckCanFight(2)
  td.EnableButton(self.m_BtnQuick10, bEnable)
end
function MissionLayer:RefreshDefenseUI()
  if self.m_bDefense then
    self.m_panelTimeLeft:setVisible(false)
    td.BtnSetTitle(self.m_BtnStart, g_LM:getBy("a00150"))
    local occupSpr = display.newSprite("UI/mission/occup.png")
    occupSpr:opacity(0):scale(3)
    occupSpr:runAction(cca.seq({
      cca.delay(1),
      cca.spawn({
        cca.fadeIn(0.3),
        cca.scaleTo(0.5, 1)
      })
    }))
    td.AddRelaPos(self.m_imageMap, occupSpr)
  end
end
function MissionLayer:CreateRewardList()
  self.m_RewardList = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
    viewRect = cc.rect(0, 0, 400, 100),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_RewardList:setAnchorPoint(0, 0)
  local panelReward = cc.uiloader:seekNodeByName(self.m_panelRight, "Panel_award")
  td.AddRelaPos(panelReward, self.m_RewardList, 1, cc.p(0.2, 0))
  for key, var in ipairs(self.m_missionInfo.award) do
    local itemNode = display.newNode()
    local item = self.m_RewardList:newItem(itemNode)
    local bgSize = cc.size(75, 75)
    local itembg = display.newScale9Sprite("UI/scale9/bantoumingkuang.png", 0, 0, cc.size(75, 75))
    local itemIcon = TouchIcon.new(var.itemId, true, false)
    itemIcon:setScale(0.7)
    td.AddRelaPos(itembg, itemIcon, 1, cc.p(0.5, 0.5))
    itembg:setAnchorPoint(cc.p(0, 0))
    itembg:setName("bg")
    itembg:addTo(itemNode)
    local autoScale = td.GetAutoScale()
    item:setItemSize((bgSize.width + 10) * autoScale, (bgSize.height + 5) * autoScale)
    item:setAnchorPoint(cc.p(0.5, 0.5))
    item:setScale(autoScale)
    self.m_RewardList:addItem(item)
  end
  self.m_RewardList:reload()
end
function MissionLayer:CreateTargetList()
  for i, val in ipairs(self.m_vTargetLabel) do
    if self.m_missionData and self.m_missionData.star[i] then
      val:setColor(td.YELLOW)
      local starIcon = cc.uiloader:seekNodeByName(self.m_panelRight, "Sprite_target" .. i)
      td.setTexture(starIcon, "UI/icon/xingxing_icon.png")
    else
      val:setColor(td.GRAY)
      local label = td.RichText({
        {
          type = 2,
          file = td.DIAMOND_ICON,
          scale = 0.6
        },
        {
          type = 1,
          str = "x10",
          color = td.WHITE,
          size = 18
        }
      })
      label:pos(350, val:getPositionY()):addTo(val:getParent())
    end
    local type = self.m_missionInfo.star_level[i][1]
    if type == td.StarLevel.UNIT_LIMIT then
      val:setString(string.format(g_LM:getMode("starlvl", type), g_LM:getMode("career", self.m_missionInfo.star_level[i][2])))
    else
      val:setString(string.format(g_LM:getMode("starlvl", type), self.m_missionInfo.star_level[i][2]))
    end
  end
end
function MissionLayer:_GetGameTypeStr(gameType)
  local str = ""
  if gameType == 0 then
    str = g_LM:getBy("a00135")
  elseif gameType == 1 then
    str = g_LM:getBy("a00137")
  elseif gameType == 2 then
    str = g_LM:getBy("t00058")
  elseif gameType == 3 then
    str = g_LM:getBy("a00136")
  elseif gameType == 4 then
    str = g_LM:getBy("a00138")
  end
  return str
end
function MissionLayer:_GetModeStr(mode)
  local str = ""
  if mode == 1 then
    str = g_LM:getBy("a00177")
  elseif mode == 2 then
    str = g_LM:getBy("a00178")
  else
    str = g_LM:getBy("a00262")
  end
  return str
end
function MissionLayer:BuyTime()
  if self.m_udMng:GetVipLevel() < 1 then
    td.alert(g_LM:getBy("a00346"))
    return
  end
  if self.m_missionData and self.m_missionData.num > 0 then
    td.alert(g_LM:getBy("a00347"))
    return
  end
  local function cb()
    if self.m_udMng:GetDiamond() >= td.GetConst("mission_cost") then
      self.m_miMng:SendBuyMissionRequest(self.m_missionId)
    else
      td.alertErrorMsg(td.ErrorCode.DIAMOND_NOT_ENOUGH)
    end
  end
  local data
  if 0 < self.m_missionData.buy_num then
    data = {
      size = cc.size(454, 300),
      content = string.format(g_LM:getBy("a00348"), td.GetConst("mission_cost"), self.m_missionData.buy_num),
      buttons = {
        {
          text = g_LM:getBy("a00009"),
          callFunc = cb
        },
        {
          text = g_LM:getBy("a00116")
        }
      }
    }
  else
    data = {
      size = cc.size(454, 300),
      content = g_LM:getMode("errormsg", td.ErrorCode.TIME_NOT_ENOUGH),
      buttons = {
        {
          text = g_LM:getBy("a00009")
        }
      }
    }
  end
  local messageBox = require("app.layers.MessageBoxDlg").new(data)
  messageBox:Show()
end
function MissionLayer:BtnStartCallback()
  g_MC:SetOnlyEnableName("")
  local recoPower = self.m_missionInfo.base_level
  local myPower = self.m_udMng:GetTotalPower()
  if recoPower > myPower then
    local msgData = {}
    msgData.content = g_LM:getBy("a00214")
    local button1 = {
      text = g_LM:getBy("a00009"),
      callFunc = function()
        self:StartGame()
      end
    }
    local button2 = {
      text = g_LM:getBy("a00116")
    }
    msgData.buttons = {button1, button2}
    local messageBox = MessageBoxDlg.new(msgData)
    messageBox:Show()
  else
    self:StartGame()
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  end
end
function MissionLayer:StartGame()
  local bEnable, errorcode = self:CheckCanFight(0)
  if bEnable then
    g_MC:OpenModule(td.UIModule.MissionReady, self.m_missionId)
  else
    td.alertErrorMsg(errorcode)
  end
end
function MissionLayer:BtnQuickCallback()
  local bEnable, errorcode = self:CheckCanFight(1)
  if bEnable then
    self.m_miMng:SendQuickMissionRequest(self.m_missionId, 1)
    self.m_txtTimeLeft:setString(string.format("%d/%d", self.m_missionData.num, td.MissionTime))
  elseif errorcode == td.ErrorCode.SWEEP_NOT_ENOUGH then
    local function cb()
      if self.m_udMng:GetDiamond() >= 10 then
        self.m_miMng:SendQuickMissionRequest(self.m_missionId, 1)
        self.m_txtTimeLeft:setString(string.format("%d/%d", self.m_missionData.num, td.MissionTime))
      else
        td.alertErrorMsg(td.ErrorCode.DIAMOND_NOT_ENOUGH)
      end
    end
    local data = {
      size = cc.size(454, 300),
      content = string.format(g_LM:getBy("a00263"), 10),
      buttons = {
        {
          text = g_LM:getBy("a00009"),
          callFunc = cb
        },
        {
          text = g_LM:getBy("a00116")
        }
      }
    }
    local messageBox = require("app.layers.MessageBoxDlg").new(data)
    messageBox:Show()
  else
    td.alertErrorMsg(errorcode)
  end
end
function MissionLayer:BtnBatchCallback()
  local bEnable, errorcode = self:CheckCanFight(2)
  if bEnable then
    self.m_miMng:SendQuickMissionRequest(self.m_missionId, 10)
    self.m_txtTimeLeft:setString(string.format("%d/%d", self.m_missionData.num, td.MissionTime))
  elseif errorcode == td.ErrorCode.SWEEP_NOT_ENOUGH then
    local function cb()
      if self.m_udMng:GetDiamond() >= 80 then
        self.m_miMng:SendQuickMissionRequest(self.m_missionId, 10)
        self.m_txtTimeLeft:setString(string.format("%d/%d", self.m_missionData.num, td.MissionTime))
      else
        td.alertErrorMsg(td.ErrorCode.DIAMOND_NOT_ENOUGH)
      end
    end
    local data = {
      size = cc.size(454, 300),
      content = string.format(g_LM:getBy("a00263"), 80),
      buttons = {
        {
          text = g_LM:getBy("a00009"),
          callFunc = cb
        },
        {
          text = g_LM:getBy("a00116")
        }
      }
    }
    local messageBox = require("app.layers.MessageBoxDlg").new(data)
    messageBox:Show()
  else
    td.alertErrorMsg(errorcode)
  end
end
function MissionLayer:CheckCanFight(type)
  if type == 0 and self.m_bDefense then
    return true, td.ErrorCode.SUCCESS
  end
  local errorCode = td.ErrorCode.SUCCESS
  if self.m_udMng:GetStamina() < MissionInfoManager.GetStaminaCost(type, self.m_missionInfo.vit) then
    errorCode = td.ErrorCode.TL_NOT_ENOUGH
  elseif self.m_missionInfo.mode > 1 and self.m_missionData and (type == 2 and self.m_missionData.num < 10 or 0 >= self.m_missionData.num) then
    errorCode = td.ErrorCode.TIME_NOT_ENOUGH
  elseif type > 0 then
    if not self.m_missionData then
      errorCode = td.ErrorCode.MISSION_LOCKED
    elseif self.m_bDefense then
      errorCode = td.ErrorCode.MISSION_OCCUPED
    elseif table.nums(self.m_missionData.star) < 3 then
      errorCode = td.ErrorCode.STAR_LOW_SWEEP
    elseif type == 2 and 3 > self.m_udMng:GetVipLevel() then
      errorCode = td.ErrorCode.VIP_LOW
    elseif self.m_udMng:GetItemNum(50004) < MissionInfoManager.GetSweepCost(type, self.m_missionInfo.sweep) then
      errorCode = td.ErrorCode.SWEEP_NOT_ENOUGH
    end
  end
  if errorCode == td.ErrorCode.SUCCESS then
    return true, errorCode
  end
  return false, errorCode
end
function MissionLayer:OnWealthChanged()
  MissionLayer.super.OnWealthChanged(self)
  self:RefreshUI()
end
function MissionLayer:QuickFightDone(event)
  local data = string.toTable(event:getDataString())
  local awardDlg = require("app.layers.battle.FightWinAwardsDlg").new(data.awards)
  td.popView(awardDlg)
end
function MissionLayer:_GetStarStr(_type)
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
function MissionLayer:GetImageMapPos()
  local pos = cc.p(self.m_imageMap:getPosition())
  return self.m_imageMap:getParent():convertToWorldSpace(pos)
end
return MissionLayer
