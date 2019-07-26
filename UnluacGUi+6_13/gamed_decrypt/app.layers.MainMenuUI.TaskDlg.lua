local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local BaseInfoManager = require("app.info.BaseInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local TabButton = require("app.widgets.TabButton")
local GuideManager = require("app.GuideManager")
local RichIcon = require("app.widgets.RichIcon")
local TouchIcon = require("app.widgets.TouchIcon")
local InformationManager = require("app.layers.InformationManager")
local TaskDlg = class("TaskDlg", BaseDlg)
local ItemSize = cc.size(1030, 90)
function TaskDlg:ctor()
  TaskDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Task
  self.m_userDataMng = UserDataManager:GetInstance()
  self.m_taskInfoMng = require("app.info.TaskInfoManager"):GetInstance()
  self.m_itemInfoMng = require("app.info.ItemInfoManager"):GetInstance()
  self.m_datas = self.m_userDataMng:GetTaskData()
  self.m_liveBtns = {}
  self.m_receivingTaskId = -1
  self.m_curAwardItem = nil
  self:initUI()
end
function TaskDlg:onEnter()
  TaskDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetLivenessAward, handler(self, self.LivenessRewardResponse))
  self:AddEvents()
  self.m_userDataMng:SendTaskRequest(td.TaskType.All)
end
function TaskDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetLivenessAward)
  TaskDlg.super.onExit(self)
end
function TaskDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_UIListView:onTouch_({
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
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_UIListView:onTouch_({
        name = "moved",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    self.m_UIListView:onTouch_({
      name = "ended",
      x = touch:getLocation().x,
      y = touch:getLocation().y,
      prevX = touch:getPreviousLocation().x,
      prevY = touch:getPreviousLocation().y
    })
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.TASK_UPDATE, handler(self, self.OnTaskUpate))
  self:AddCustomEvent(td.USERWEALTH_CHANGED, handler(self, self.UpdateLivenessBar))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  self:AddCustomEvent(td.TASK_REWARD, handler(self, self.TaskRewardCallback))
end
function TaskDlg:initUI()
  self:LoadUI("CCS/TaskDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_renwu.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self:InitList()
  self:InitLivenessBar()
  self:UpdateLivenessBar()
  self:RefreshTaskList()
end
function TaskDlg:InitList()
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, ItemSize.width + 50, 345),
    touchOnContent = false,
    scale = td.GetAutoScale()
  })
  self.m_UIListView:setName("ListView")
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:setPosition(25, 50)
  self.m_bg:addChild(self.m_UIListView, 1)
end
function TaskDlg:InitLivenessBar()
  local wordLabel = td.CreateLabel(g_LM:getBy("a00415"), td.LIGHT_BLUE, 20)
  wordLabel:setAnchorPoint(0, 0.5)
  wordLabel:pos(485, 555):addTo(self.m_bg)
  self.m_livenessBar = cc.uiloader:seekNodeByName(self.m_bg, "LivenessBar")
  self.m_livenessBar:setPercent(0)
  for i = 1, 4 do
    do
      local btn = cc.uiloader:seekNodeByName(self.m_bg, "Button_" .. i)
      td.BtnAddTouch(btn, function()
        self:OnLivenessBtnClicked(i)
      end)
      table.insert(self.m_liveBtns, btn)
      local title = td.CreateLabel(td.AwardLiveness[i], cc.c3b(230, 230, 230), 18, td.OL_BLACK)
      title:setTag(233)
      title:setAnchorPoint(0.5, 0.5)
      td.AddRelaPos(btn, title, 1, cc.p(0.5, 0))
    end
  end
  self.m_liveLabel = td.RichText({
    {
      type = 1,
      color = td.LIGHT_GREEN,
      size = 20,
      str = "0"
    },
    {
      type = 1,
      color = td.WHITE,
      size = 20,
      str = "/" .. td.MAX_LIVENESS
    }
  })
  self.m_liveLabel:setAnchorPoint(0, 0.5)
  self.m_liveLabel:setPosition(140, 360)
  self.m_liveLabel:addTo(self.m_bg)
end
function TaskDlg:UpdateLivenessBar()
  local curLiveness = self.m_userDataMng:GetLiveness()
  self.m_livenessBar:setPercent(curLiveness / td.MAX_LIVENESS * 100)
  for i, btn in ipairs(self.m_liveBtns) do
    if btn.icon then
      btn.icon:removeFromParent()
      btn.icon = nil
    end
    local color
    if self.m_userDataMng:IsLivenessReceived(i) then
      btn:loadTextureDisabled("UI/task/baoxiang_1.png")
      btn:setDisable(true)
      color = td.LIGHT_BLUE
      btn.icon = RichIcon.new("UI/task/baoxiang_1.png", self:_getLivenessAwardStr(i), self.m_scale)
      td.AddRelaPos(btn, btn.icon)
      if btn.effect then
        btn.effect:removeFromParent()
        btn.effect = nil
      end
    elseif self.m_userDataMng:CheckLivenessReward(i) then
      color = td.YELLOW
      btn:setDisable(false)
      if not btn.effect then
        local pEffect = SkeletonUnit:create("Spine/UI_effect/UI_huoyuedu_01")
        td.AddRelaPos(btn, pEffect, 1)
        pEffect:PlayAni("animation", true)
        btn.effect = pEffect
      end
    else
      btn:loadTextureDisabled("UI/task/baoxiang_3.png")
      btn:setDisable(true)
      color = cc.c3b(230, 230, 230)
      btn.icon = RichIcon.new("UI/task/baoxiang_3.png", self:_getLivenessAwardStr(i), self.m_scale)
      td.AddRelaPos(btn, btn.icon)
    end
    btn:getChildByTag(233):setColor(color)
  end
  if self.m_liveLabel then
    self.m_liveLabel:removeFromParent()
    self.m_liveLabel = nil
  end
  self.m_liveLabel = td.RichText({
    {
      type = 1,
      color = td.LIGHT_GREEN,
      size = 20,
      str = "" .. curLiveness
    },
    {
      type = 1,
      color = td.WHITE,
      size = 20,
      str = "/" .. td.MAX_LIVENESS
    }
  })
  self.m_liveLabel:setAnchorPoint(0, 0.5)
  self.m_liveLabel:setPosition(592, 555)
  self.m_liveLabel:addTo(self.m_bg)
end
function TaskDlg:_getLivenessAwardStr(index)
  local livenessInfo = self.m_taskInfoMng:GetLivenessInfo(index)
  local textData = {}
  for key, var in pairs(livenessInfo.awardTab) do
    local itemInfo = self.m_itemInfoMng:GetItemInfo(key)
    table.insert(textData, {
      type = 2,
      file = itemInfo.icon .. td.PNG_Suffix,
      scale = 0.5
    })
    table.insert(textData, {
      type = 1,
      str = "x" .. var .. " ",
      color = td.WHITE,
      size = 22
    })
  end
  return td.RichText(textData)
end
function TaskDlg:OnLivenessBtnClicked(index)
  if self:IsLivenessComplete(index) then
    self:SendLivenessRewardRequest(index)
  else
    td.alert(g_LM:getBy("a00323"), true)
  end
end
function TaskDlg:IsLivenessComplete(index)
  if self.m_userDataMng:IsLivenessReceived(index) then
    return false
  end
  local livenessInfo = self.m_taskInfoMng:GetLivenessInfo(index)
  if self.m_userDataMng:GetLiveness() < livenessInfo.active then
    return false
  end
  return true
end
function TaskDlg:CreateItem(data)
  local pItem = self:CreateItemPart(data)
  local item = self.m_UIListView:newItem(pItem)
  item:setItemSize(ItemSize.width * self.m_scale, (ItemSize.height + 5) * self.m_scale)
  return item
end
function TaskDlg:CreateItemPart(data)
  local taskInfo = data.taskInfo
  local item = cc.uiloader:load("CCS/TaskItem.csb")
  local pBg = cc.uiloader:seekNodeByName(item, "Image_bg")
  local size = pBg:getContentSize()
  item:setScale(self.m_scale)
  item:setContentSize(size)
  local imageType = cc.uiloader:seekNodeByName(item, "Image_type")
  local taskTypeFile = "UI/task/task_icon2.png"
  if data.taskInfo.type == td.TaskType.Daily then
    taskTypeFile = "UI/task/task_icon1.png"
  end
  imageType:loadTexture(taskTypeFile)
  local imageIcon = cc.uiloader:seekNodeByName(item, "Image_icon")
  imageIcon:loadTexture(taskInfo.image .. td.PNG_Suffix)
  local taskNameLabel = td.CreateLabel(taskInfo.target_text, td.LIGHT_GREEN, 18, nil, nil, cc.size(200, 0), true)
  taskNameLabel:setAnchorPoint(cc.p(0, 0.5))
  td.AddRelaPos(pBg, taskNameLabel, 1, cc.p(0.12, 0.5))
  local totalJd
  if taskInfo.targetTab[1] == 21 or taskInfo.targetTab[1] == 36 or taskInfo.targetTab[1] == 37 or taskInfo.targetTab[1] == 38 or taskInfo.targetTab[1] == 39 then
    totalJd = 1
  else
    totalJd = taskInfo.targetTab[2]
  end
  local jdLabel = td.CreateLabel(data.target .. "/" .. totalJd, td.WHITE, 20)
  td.AddRelaPos(pBg, jdLabel, 1, cc.p(0.5, 0.5))
  self:CreateItemAwards(taskInfo.awardTab, item)
  self:CreateItemBtn(data, item)
  return item
end
function TaskDlg:CreateItemAwards(vAwards, item)
  local pBg = cc.uiloader:seekNodeByName(item, "Image_bg")
  item.awards = {}
  local count = 0
  for itemId, itemNum in pairs(vAwards) do
    if itemId == 1 then
      itemId = itemNum
      itemNum = 1
    end
    local iconBg = display.newScale9Sprite("UI/scale9/bantoumingkuang.png", 10, 10, cc.size(60, 60))
    td.AddRelaPos(pBg, iconBg, 1, cc.p(0.75 - 0.07 * count, 0.5))
    count = count + 1
    local iconSpri = TouchIcon.new(itemId, true)
    iconSpri:setScale(0.55)
    iconSpri.itemId = itemId
    td.AddRelaPos(iconBg, iconSpri)
    local numLabel = td.CreateLabel("" .. itemNum, nil, 14, td.OL_BLACK)
    numLabel:setAnchorPoint(0, 1)
    td.AddRelaPos(iconBg, numLabel, 1, cc.p(0.1, 0.95))
    table.insert(item.awards, iconSpri)
  end
end
function TaskDlg:CreateItemBtn(data, item)
  local taskState = self.m_taskInfoMng:CheckTaskState(data)
  local pBg = cc.uiloader:seekNodeByName(item, "Image_bg")
  local pBtn = pBg:getChildByTag(2)
  td.BtnAddTouch(pBtn, function()
    if td.TaskState.Complete == taskState then
      pBtn:setDisable(true)
      self:doTaskEvent(data, item)
    elseif data.taskInfo.guide then
      g_MC:OpenModule(data.taskInfo.guide.moduleId, data.taskInfo.guide.data, data.taskInfo.guide.subData, data.taskInfo.guide_widget)
    else
      td.alert(g_LM:getBy("a00189"))
    end
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  end)
  item.btn = pBtn
  td.BtnSetTitle(pBtn, g_LM:getBy("a00052"))
  if td.TaskState.Incomplete == taskState then
    if data.taskInfo.guide then
      pBtn:loadTextures(td.BtnBS.enabled, td.BtnBS.pressed, td.BtnBS.disabled)
      td.BtnSetTitle(pBtn, g_LM:getBy("a00051"))
    else
      td.EnableButton(pBtn, false)
    end
  elseif td.TaskState.Received == taskState then
    pBtn:setVisible(false)
    display.newSprite("UI/words/yilingqu_icon.png"):pos(pBtn:getPosition()):addTo(pBg)
  elseif td.TaskState.Complete == taskState then
    local spine = SkeletonUnit:create("Spine/UI_effect/EFT_renwuwancheng_01")
    spine:setScale(1.58, 1.1)
    td.AddRelaPos(pBg, spine, 10)
    spine:PlayAni("animation", true)
  end
end
function TaskDlg:doTaskEvent(data, item)
  if self.m_receivingTaskId ~= -1 or self.m_curAwardItem then
    return
  end
  self.m_curAwardItem = item
  self:SendTaskRewardRequest(data.tid)
end
function TaskDlg:RefreshTaskList()
  self.m_UIListView:removeAllItems()
  local incompleteQuests = {}
  for i, value in ipairs(self.m_datas[td.TaskType.MainLine]) do
    if value.state == td.TaskState.Complete then
      local item = self:CreateItem(value)
      self.m_UIListView:addItem(item)
    elseif value.state == td.TaskState.Incomplete then
      table.insert(incompleteQuests, value)
    end
  end
  for i, value in ipairs(self.m_datas[td.TaskType.Common]) do
    if value.state == td.TaskState.Complete then
      local item = self:CreateItem(value)
      self.m_UIListView:addItem(item)
    elseif value.state == td.TaskState.Incomplete then
      table.insert(incompleteQuests, value)
    end
  end
  for i, value in ipairs(self.m_datas[td.TaskType.Daily]) do
    local taskState = self.m_taskInfoMng:CheckTaskState(value)
    if taskState == td.TaskState.Complete then
      local item = self:CreateItem(value)
      self.m_UIListView:addItem(item)
    elseif taskState == td.TaskState.Incomplete then
      table.insert(incompleteQuests, value)
    end
  end
  for i, value in ipairs(incompleteQuests) do
    local item = self:CreateItem(value)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function TaskDlg:OnTaskUpate(event)
  if self.m_curAwardItem then
    return
  end
  self.m_datas = self.m_userDataMng:GetTaskData()
  self:RefreshTaskList()
  self:CheckGuide()
end
function TaskDlg:SendTaskRewardRequest(taskId)
  self.m_receivingTaskId = taskId
  self.m_userDataMng:SendTaskRewardRequest(taskId)
end
function TaskDlg:TaskRewardCallback()
  self.m_curAwardItem:runAction(cca.seq({
    cc.EaseSineIn:create(cca.moveBy(0.5, 2000, 0)),
    cca.cb(function()
      self.m_curAwardItem = nil
      td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
      self.m_receivingTaskId = -1
      self.m_datas = self.m_userDataMng:GetTaskData()
      self:RefreshTaskList()
    end)
  }))
end
function TaskDlg:SendLivenessRewardRequest(index)
  self.m_clickLiveBtnIndex = index
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.GetLivenessAward
  Msg.sendData = {type = index}
  tdRequest:Send(Msg)
end
function TaskDlg:LivenessRewardResponse(data)
  if data.state ~= td.ResponseState.Success then
    td.alert(g_LM:getBy("a00323"), true)
  else
    local livenessInfo = self.m_taskInfoMng:GetLivenessInfo(self.m_clickLiveBtnIndex)
    local items = {}
    for key, var in pairs(livenessInfo.awardTab) do
      local item = {}
      item.itemId = key
      item.num = var
      table.insert(items, item)
    end
    InformationManager:GetInstance():ShowOpenBox(items)
    if self.m_clickLiveBtnIndex then
      self.m_userDataMng:SetLivenessReceived(self.m_clickLiveBtnIndex)
      self.m_clickLiveBtnIndex = nil
    end
    self:UpdateLivenessBar()
    td.dispatchEvent(td.TASK_UPDATE)
  end
end
return TaskDlg
