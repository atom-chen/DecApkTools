local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local UserDataManager = require("app.UserDataManager")
local TaskInfoManager = class("TaskInfoManager", GameControl)
TaskInfoManager.instance = nil
function TaskInfoManager:ctor(eType)
  TaskInfoManager.super.ctor(self, eType)
  self:Init()
end
function TaskInfoManager:GetInstance()
  if TaskInfoManager.instance == nil then
    TaskInfoManager.instance = TaskInfoManager.new(td.GameControlType.ExitGame)
  end
  return TaskInfoManager.instance
end
function TaskInfoManager:Init()
  self.m_taskInfos = {}
  self.m_livenessInfos = {}
  self:SaveInfo()
end
function TaskInfoManager:ClearValue()
end
function TaskInfoManager:SaveInfo()
  self:SaveTaskInfo()
  self:SaveLivenessInfo()
end
function TaskInfoManager:SaveTaskInfo()
  local vTaskData = CSVLoader.loadCSV("Config/task.csv")
  for i, v in ipairs(vTaskData) do
    v.target_text = g_LM:getBy(v.target_text) or v.target_text
    local awardStr = string.split(v.award, "|")
    v.awardTab = {}
    for j, var in ipairs(awardStr) do
      local awardInfo = string.split(var, "#")
      v.awardTab[tonumber(awardInfo[1])] = tonumber(awardInfo[2])
    end
    local targetStr = string.split(v.target, "#")
    v.targetTab = {}
    v.targetTab[1] = tonumber(targetStr[1])
    v.targetTab[2] = tonumber(targetStr[2])
    if v.time ~= "" and v.time ~= "0" then
      local tmp = string.split(v.time, "#")
      v.time = {}
      v.time.min = tonumber(tmp[1])
      v.time.max = tonumber(tmp[2])
    else
      v.time = nil
    end
    if v.guide ~= "" and v.guide ~= "0" then
      local guideStr = string.split(v.guide, "#")
      if #guideStr == 3 then
        v.guide = {}
        v.guide.moduleId = tonumber(guideStr[1])
        v.guide.subData = {
          tonumber(guideStr[2]),
          tonumber(guideStr[3])
        }
      else
        v.guide = {}
        v.guide.moduleId = tonumber(guideStr[1])
        v.guide.data = tonumber(guideStr[2])
      end
    else
      v.guide = nil
    end
    if v.guide_widget ~= "" and v.guide_widget ~= "0" then
      local tmp = string.split(v.guide_widget, "#")
      v.guide_widget = {}
      for j, var in ipairs(tmp) do
        if tonumber(var) then
          var = tonumber(var)
        end
        table.insert(v.guide_widget, var)
      end
    else
      v.guide_widget = nil
    end
    self.m_taskInfos[v.id] = v
  end
end
function TaskInfoManager:SaveLivenessInfo()
  local vData = CSVLoader.loadCSV("Config/liveness.csv")
  for i, v in ipairs(vData) do
    local awardStr = string.split(v.award, "|")
    v.awardTab = {}
    for j, var in ipairs(awardStr) do
      local awardInfo = string.split(var, "#")
      v.awardTab[tonumber(awardInfo[1])] = tonumber(awardInfo[2])
    end
    self.m_livenessInfos[v.id] = v
  end
end
function TaskInfoManager:GetTaskInfo(id)
  return clone(self.m_taskInfos[id])
end
function TaskInfoManager:GetLivenessInfo(id)
  return clone(self.m_livenessInfos[id])
end
function TaskInfoManager:CheckTaskState(data)
  local time = data.taskInfo.time
  if not time or data.state == td.TaskState.Received then
    return data.state
  else
    local serverTime = UserDataManager:GetInstance():GetServerTime()
    local timeTab = os.date("*t", serverTime)
    if timeTab.hour >= time.min and timeTab.hour < time.max then
      return td.TaskState.Complete
    elseif timeTab.hour >= time.max then
      return td.TaskState.Received
    end
  end
  return td.TaskState.Incomplete
end
return TaskInfoManager
