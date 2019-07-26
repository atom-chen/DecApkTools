local UserDataManager = require("app.UserDataManager")
local TaskInfoManager = require("app.info.TaskInfoManager")
local scheduler = require("framework.scheduler")
local GuideManager = require("app.GuideManager")
local TaskBar = class("TaskBar", function()
  return display.newSprite("UI/mainmenu_new/renwu_waifaguangxian.png")
end)
function TaskBar:ctor()
  self.taskData = nil
  self.bEnable = true
  self.bIsGuiding = false
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function TaskBar:onEnter()
  if UserDataManager:GetInstance():GetBaseCampLevel() < 8 then
    self.m_weakGuideScheduler = scheduler.scheduleGlobal(handler(self, self.WeakGuide), 8)
  end
end
function TaskBar:onExit()
  if self.m_weakGuideScheduler then
    scheduler.unscheduleGlobal(self.m_weakGuideScheduler)
    self.m_weakGuideScheduler = nil
  end
end
function TaskBar:InitUI()
  local decoSpr = display.newSprite("UI/mainmenu_new/renwu_zhuangshi.png")
  td.AddRelaPos(self, decoSpr, -1, cc.p(-0.01, 0.5))
  self.m_effect = SkeletonUnit:create("Spine/UI_effect/UI_renwutishi_03")
  td.AddRelaPos(decoSpr, self.m_effect, 1, cc.p(0.35, 0.5))
  self.m_effect2 = SkeletonUnit:create("Spine/UI_effect/UI_renwuling_01")
  self.m_effect2:scale(1.2)
  td.AddRelaPos(decoSpr, self.m_effect2, 1, cc.p(4.4, 0.5))
  local taskLabel = td.CreateLabel(g_LM:getBy("a00406") .. ":", td.WHITE, 20)
  taskLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self, taskLabel, 1, cc.p(0.02, 0.5))
  self.nameLabel = td.CreateLabel("", td.LIGHT_BLUE, 20)
  self.nameLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(self, self.nameLabel, 1, cc.p(0.22, 0.5))
  self.btn = ccui.Button:create("UI/mainmenu_new/lvse_renwu_button.png")
  self.btn:setName("Button_task_receive")
  td.AddRelaPos(self, self.btn, 1, cc.p(0.93, 0.5))
  td.BtnAddTouch(self.btn, handler(self, self.OnClicked))
  self.btn:setVisible(false)
end
function TaskBar:SetData(taskId)
  local taskDatas = UserDataManager:GetInstance():GetTaskData()
  local taskInfo = TaskInfoManager:GetInstance():GetTaskInfo(taskId)
  for i, var in ipairs(taskDatas[taskInfo.type]) do
    if var.tid == taskId then
      self.taskData = var
      break
    end
  end
  if not self.taskData then
    self.bEnable = false
    self:setVisible(false)
    return
  end
  self:setVisible(true)
  self.bEnable = true
  self.nameLabel:setString(taskInfo.target_text)
  self.btn:setVisible(false)
  if self.taskData.state == td.TaskState.Complete then
    local rp = SkeletonUnit:create("Spine/UI_effect/EFT_renwuG_01")
    rp:PlayAni("animation", true)
    td.ShowRP(self, true, cc.p(0.5, 0.5), rp)
    self.m_effect:PlayAni("animation_01", true)
    self.m_effect2:setVisible(true)
    self.m_effect2:PlayAni("animation", true)
    self.btn:setVisible(true)
    td.BtnSetTitle(self.btn, g_LM:getBy("a00052"), 22, td.GREEN)
  else
    td.ShowRP(self, false)
    if self.taskData.state == td.TaskState.Incomplete then
      local taskInfo = self.taskData.taskInfo
      if taskInfo.guide then
        self.btn:setVisible(true)
        self.m_effect:PlayAni("animation_02", true)
        self.m_effect2:setVisible(false)
        td.BtnSetTitle(self.btn, g_LM:getBy("a00420"), 22, td.GREEN)
      end
    end
  end
end
function TaskBar:OnClicked()
  self.bIsGuiding = false
  td.ShowRP(self.btn, false)
  if not self.bEnable then
    return
  end
  if self.taskData.state == td.TaskState.Complete then
    td.ShowRP(self, false)
    self.bEnable = false
    UserDataManager:GetInstance():SendTaskRewardRequest(self.taskData.tid)
    td.dispatchEvent(td.GUIDE_FINISHED, td.UIModule.MainMenu)
  elseif self.taskData.state == td.TaskState.Incomplete then
    local taskInfo = self.taskData.taskInfo
    if taskInfo.guide then
      g_MC:OpenModule(taskInfo.guide.moduleId, taskInfo.guide.data, taskInfo.guide.subData, taskInfo.guide_widget)
    end
  end
end
function TaskBar:WeakGuide()
  if not GuideManager:GetInstance():IsForceGuideOver() then
    return
  end
  if GuideManager:GetInstance():IsGuiding() then
    return
  end
  if not g_MC:IsAllModuleClose() then
    return
  end
  if not self.bIsGuiding then
    local spine = SkeletonUnit:create("Spine/UI_effect/UI_shouzhi_01")
    spine:scale(0.8)
    spine:PlayAni("animation_02", true)
    td.ShowRP(self.btn, true, cc.p(0.5, 0.5), spine)
    self.bIsGuiding = true
  end
end
return TaskBar
