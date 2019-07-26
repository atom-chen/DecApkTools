local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local StrongInfoManager = require("app.info.StrongInfoManager")
local UserDataManager = require("app.UserDataManager")
local UnitDataManager = require("app.UnitDataManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local scheduler = require("framework.scheduler")
local GuideManager = require("app.GuideManager")
local UnitTrainDlg = class("UnitTrainDlg", BaseDlg)
function UnitTrainDlg:ctor(data)
  UnitTrainDlg.super.ctor(self, 220)
  self.m_uiId = td.UIModule.UnitTrain
  self.udMng = UserDataManager:GetInstance()
  self.unitMng = UnitDataManager:GetInstance()
  self.uniTag = 1
  self.queueNum = 0
  self.vSoldierIcon = {}
  self.curTimeLeft = 0
  self:InitUI()
  self:SetData(data.id)
end
function UnitTrainDlg:onEnter()
  UnitTrainDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UpdateSoldierPlan, handler(self, self.UpdatePlanSuccess))
  self:AddEvents()
  self:CheckGuide()
  if self.plan and self.plan.num > 0 then
    for i = 1, self.plan.num do
      self:AddToQueue()
    end
    self:StartTimer()
  end
end
function UnitTrainDlg:onExit()
  self:StopTimer()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.UpdateSoldierPlan)
  UnitTrainDlg.super.onExit(self)
  td.dispatchEvent(td.GUIDE_CONTINUE)
end
function UnitTrainDlg:OnTimer()
  if self.plan and self.plan.num > 0 then
    self.queueLabel:setString(string.format("%d/%d", self.plan.num, td.GetConst("queue_size")))
    self.curTimeLabel:setString(self:GetTimeDownStr(self.plan.curTime))
    self.curTimeBar:setPercentage(self.plan.curTime / self.plan.costTime * 100)
    local totalTime = self:GetTotalTime(self.plan)
    self.totalTimeLabel:setString(self:GetTimeDownStr(totalTime))
    self.clearCostLabel:setString("x" .. self:GetClearCDCost(self.plan))
  else
    self.queueLabel:setString(string.format("%d/%d", 0, td.GetConst("queue_size")))
    self.curTimeLabel:setString(self:GetTimeDownStr(0))
    self.totalTimeLabel:setString(self:GetTimeDownStr(0))
    self.curTimeBar:setPercentage(0)
    self.clearCostLabel:setString("x0")
    self.plan = nil
    self:StopTimer()
  end
end
function UnitTrainDlg:StartTimer()
  self:StopTimer()
  self.m_timeScheduler = scheduler.scheduleGlobal(function()
    self:OnTimer()
  end, 1)
  self:OnTimer()
  self.curTimeBar:setVisible(true)
end
function UnitTrainDlg:StopTimer()
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
    self.m_timeScheduler = nil
  end
  self.curTimeBar:setVisible(false)
end
function UnitTrainDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/UnitTrainDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:SetTitle(td.Word_Path .. "wenzi_xunlianchang.png")
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.iconBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_iconBg")
  self.m_panelItems = cc.uiloader:seekNodeByName(self.m_bg, "Image_itemBg")
  self.queueLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_queue")
  self.queueLabel:setString("0/" .. td.GetConst("queue_size"))
  self.totalTimeLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_time")
  local barBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_exp_bg")
  self.curTimeBar = cc.ProgressTimer:create(display.newSprite("UI/hero/lvse_jindutiao.png"))
  self.curTimeBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  self.curTimeBar:setMidpoint(cc.p(0, 0))
  self.curTimeBar:setBarChangeRate(cc.p(1, 0))
  self.curTimeBar:setPercentage(0)
  self.curTimeBar:setVisible(false)
  td.AddRelaPos(barBg, self.curTimeBar, -1, cc.p(0.5, 0.47))
  self.curTimeLabel = td.CreateLabel("00:00", nil, 16, td.OL_BLACK, 1)
  td.AddRelaPos(self.curTimeBar, self.curTimeLabel)
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_1")
  label:setString(g_LM:getBy("\233\152\159\229\136\151") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_2")
  label:setString(g_LM:getBy("\230\128\187\230\151\182\233\151\180") .. ":")
end
function UnitTrainDlg:InitBtn()
  self.addBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_add")
  td.BtnAddTouch(self.addBtn, handler(self, self.OnAddBtnClicked), nil, td.ButtonEffectType.Long)
  local titleSpr = td.RichText({
    {
      type = 1,
      str = g_LM:getBy("\232\174\173\231\187\131") .. "   ",
      color = td.WHITE,
      size = 18
    },
    {
      type = 2,
      file = td.FORCE_ICON,
      scale = 0.5
    },
    {
      type = 1,
      str = "x" .. self.soldierStrongInfo.create_cost,
      color = td.WHITE,
      size = 18
    }
  })
  td.AddRelaPos(self.addBtn, titleSpr)
  self.clearCdBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_clear")
  td.BtnAddTouch(self.clearCdBtn, handler(self, self.OnClearBtnClicked), nil, td.ButtonEffectType.Long)
  local titleSpr = td.RichText({
    {
      type = 1,
      str = g_LM:getBy("\229\138\160\233\128\159") .. "   ",
      color = td.WHITE,
      size = 18
    },
    {
      type = 2,
      file = td.DIAMOND_ICON,
      scale = 0.5
    }
  })
  td.AddRelaPos(self.clearCdBtn, titleSpr, 1, cc.p(0.4, 0.5))
  self.clearCostLabel = td.CreateLabel("x0", td.WHITE, 18)
  self.clearCostLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self.clearCdBtn, self.clearCostLabel, 1, cc.p(0.65, 0.5))
end
function UnitTrainDlg:SetData(soldierId)
  self.soldierId = soldierId
  self.soldierInfo = ActorInfoManager:GetInstance():GetSoldierInfo(self.soldierId)
  self.soldierStrongInfo = StrongInfoManager:GetInstance():GetSoldierStrongInfo(self.soldierId)
  self.plan = self.unitMng:GetPlan(self.soldierId)
  self:InitBtn()
end
function UnitTrainDlg:RefreshUI(event)
  local soldierId = tonumber(event:getDataString())
  if soldierId ~= self.soldierId then
    return
  end
  local count = #self.vSoldierIcon
  for i = count, 1, -1 do
    local soldierIcon = self.vSoldierIcon[i]
    if i == 1 then
      if count == 1 then
        soldierIcon:runAction(cca.seq({
          cca.spawn({
            cca.moveBy(0.3, 0, 50),
            cca.fadeOut(0.3)
          }),
          cca.removeSelf()
        }))
        table.remove(self.vSoldierIcon, i)
      end
    elseif i == 2 then
      local bgPos = cc.p(self.iconBg:getPosition())
      soldierIcon:runAction(cca.seq({
        cca.delay(i * 0.1),
        cca.moveTo(0.2, bgPos.x, bgPos.y + 50),
        cca.removeSelf()
      }))
      soldierIcon:removeAllChildren()
      table.remove(self.vSoldierIcon, i)
    else
      soldierIcon:runAction(cca.seq({
        cca.delay(i * 0.1),
        cca.moveBy(0.2, -80, 0)
      }))
    end
  end
end
function UnitTrainDlg:CreateSoldierIcon()
  local iconBg = display.newSprite("UI/scale9/wupingdikuang.png")
  local icon = display.newSprite(self.soldierInfo.head .. td.PNG_Suffix)
  td.AddRelaPos(iconBg, icon)
  local delBtn = ccui.Button:create("UI/button/jian1_icon.png", "UI/button/jian2_icon.png")
  td.BtnAddTouch(delBtn, function()
    self:OnDelBtnClicked(delBtn)
  end)
  td.AddRelaPos(iconBg, delBtn, 1, cc.p(0.8, 0.8))
  return iconBg
end
function UnitTrainDlg:AddToQueue()
  local soldierIcon
  if #self.vSoldierIcon == 0 then
    soldierIcon = SkeletonUnit:create(self.soldierInfo.image)
    soldierIcon:PlayAni("stand", true)
    local x, y = self.iconBg:getPosition()
    soldierIcon:scale(0.8):pos(x, y):addTo(self.m_bg)
  else
    soldierIcon = self:CreateSoldierIcon()
    soldierIcon:scale(0):pos(20 + #self.vSoldierIcon * 80, 180):addTo(self.m_bg, 1)
    soldierIcon:setTag(self.uniTag)
    self.uniTag = self.uniTag + 1
    soldierIcon:runAction(cca.scaleTo(0.3, 0.8, 0.8))
  end
  table.insert(self.vSoldierIcon, soldierIcon)
end
function UnitTrainDlg:DelFromQueue(tag)
  local count = #self.vSoldierIcon
  for i = count, 1, -1 do
    local icon = self.vSoldierIcon[i]
    if icon:getTag() == tag then
      icon:runAction(cca.seq({
        cca.spawn({
          cca.moveBy(0.3, 0, 50),
          cca.fadeOut(0.3)
        }),
        cca.removeSelf()
      }))
      table.remove(self.vSoldierIcon, i)
    elseif tag < icon:getTag() then
      icon:runAction(cca.seq({
        cca.delay((icon:getTag() - tag) * 0.1),
        cca.moveBy(0.2, -80, 0)
      }))
    end
  end
end
function UnitTrainDlg:OnAddBtnClicked()
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  local bCanAdd, errorCode = self.unitMng:CheckPlan(self.soldierId, 1)
  if not bCanAdd then
    td.alertErrorMsg(errorCode)
    return
  end
  self:SendAddRequest()
end
function UnitTrainDlg:OnDelBtnClicked(sender)
  local bCanAdd, errorCode = self.unitMng:CheckPlan(self.soldierId, -1)
  if not bCanAdd then
    td.alertErrorMsg(errorCode)
    return
  end
  sender:setDisable(true)
  self:SendDelRequest(sender:getParent():getTag())
end
function UnitTrainDlg:OnClearBtnClicked()
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  local costNum = self:GetClearCDCost(self.plan)
  if costNum == 0 then
    return
  elseif costNum > self.udMng:GetItemNum(td.ItemID_Diamond) then
    td.alertErrorMsg(td.ErrorCode.DIAMOND_NOT_ENOUGH)
    return
  end
  self:SendClearRequest()
end
function UnitTrainDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function()
        self:close()
      end, 0.05)
      return false
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.SOLDIER_NUM_UPDATE, handler(self, self.RefreshUI))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
function UnitTrainDlg:GetTotalTime(plan)
  local time = 0
  if self.plan then
    time = self.plan.curTime + (self.plan.num - 1) * self.plan.costTime
  end
  return time
end
function UnitTrainDlg:GetClearCDCost(plan)
  local totalTime = self:GetTotalTime(plan)
  return math.ceil(totalTime / td.GetConst("queue_time_unit")) * td.GetConst("queue_clear_ratio")
end
function UnitTrainDlg:GetTimeDownStr(time)
  if time <= 0 then
    return "00:00"
  end
  local min, sec = math.floor(time % 3600 / 60), math.floor(time % 60)
  return string.format("%02d:%02d", min, sec)
end
function UnitTrainDlg:SendAddRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.UpdateSoldierPlan
  Msg.sendData = {
    role_id = self.soldierId,
    num = 1,
    type = 0
  }
  Msg.cbData = {num = 1, type = 0}
  TDHttpRequest:getInstance():Send(Msg)
end
function UnitTrainDlg:SendDelRequest(tag)
  local Msg = {}
  Msg.msgType = td.RequestID.UpdateSoldierPlan
  Msg.sendData = {
    role_id = self.soldierId,
    num = -1,
    type = 0
  }
  Msg.cbData = {
    num = -1,
    type = 0,
    tag = tag
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function UnitTrainDlg:SendClearRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.UpdateSoldierPlan
  Msg.sendData = {
    role_id = self.soldierId,
    num = 0,
    type = 1
  }
  Msg.cbData = {num = 0, type = 1}
  TDHttpRequest:getInstance():Send(Msg)
end
function UnitTrainDlg:UpdatePlanSuccess(data, cbData)
  if data.state == td.ResponseState.Success then
    if cbData.type == 1 then
      self:ClearCDCallback()
    elseif cbData.num > 0 then
      self:AddCallback()
    else
      self:DelCallback(cbData.tag)
    end
  end
end
function UnitTrainDlg:AddCallback()
  self:AddToQueue()
  self.unitMng:UpdatePlan(self.soldierId, 1)
  if not self.plan then
    self.plan = self.unitMng:GetPlan(self.soldierId)
    self:StartTimer()
  end
end
function UnitTrainDlg:DelCallback(tag)
  self:DelFromQueue(tag)
  self.unitMng:UpdatePlan(self.soldierId, -1)
end
function UnitTrainDlg:ClearCDCallback()
  for i, soldierIcon in ipairs(self.vSoldierIcon) do
    soldierIcon:runAction(cca.seq({
      cca.spawn({
        cca.moveBy(0.3, 0, 50),
        cca.fadeOut(0.3)
      }),
      cca.cb(function()
        soldierIcon:removeFromParent()
      end)
    }))
  end
  self.vSoldierIcon = {}
  self.plan = nil
  self.unitMng:CompletePlanInstantly(self.soldierId)
end
return UnitTrainDlg
