local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local CommanderInfoManager = class("CommanderInfoManager", GameControl)
CommanderInfoManager.instance = nil
function CommanderInfoManager:ctor(eType)
  CommanderInfoManager.super.ctor(self, eType)
  self:Init()
end
function CommanderInfoManager:GetInstance()
  if CommanderInfoManager.instance == nil then
    CommanderInfoManager.instance = CommanderInfoManager.new(td.GameControlType.ExitGame)
  end
  return CommanderInfoManager.instance
end
function CommanderInfoManager:Init()
  self.m_honorInfos = {}
  self.m_portraitInfos = {}
  self.m_nameInfo = nil
  self:SaveInfos()
end
function CommanderInfoManager:ClearValue()
end
function CommanderInfoManager:SaveInfos()
  local vData = CSVLoader.loadCSV("Config/honor.csv")
  for i, v in ipairs(vData) do
    v.military_rank = g_LM:getBy(v.military_rank)
    local tmp = string.split(v.limit, "|")
    v.limit = {}
    for j, var in ipairs(tmp) do
      local tmp1 = string.split(var, "#")
      v.limit[tonumber(tmp1[1])] = tonumber(tmp1[2])
    end
    self.m_honorInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/portrait.csv")
  for i, v in ipairs(vData) do
    self.m_portraitInfos[v.id] = v
  end
end
function CommanderInfoManager:GetHonorInfo(id)
  return self.m_honorInfos[id]
end
function CommanderInfoManager:GetAllHonorInfo()
  return clone(self.m_honorInfos)
end
function CommanderInfoManager:GetPortraitInfo(id)
  return self.m_portraitInfos[id] or self.m_portraitInfos[1]
end
function CommanderInfoManager:GetAllPortraitInfo()
  return clone(self.m_portraitInfos)
end
function CommanderInfoManager:GetRandomName()
  if not self.m_nameInfo then
    self:SaveNameInfo()
  end
  local name, nameLen, i = "", 0, 1
  while i <= 2 and nameLen < 6 do
    local totalCount = #self.m_nameInfo[i]
    local var = self.m_nameInfo[i][math.random(totalCount)]
    if 6 >= nameLen + var.length then
      name = name .. var.name
      nameLen = nameLen + var.length
      i = i + 1
    end
  end
  return name
end
function CommanderInfoManager:SaveNameInfo()
  self.m_nameInfo = {}
  for i = 1, 2 do
    local vData = CSVLoader.loadCSV("Config/name_" .. i .. ".csv")
    table.insert(self.m_nameInfo, vData)
  end
end
function CommanderInfoManager:GetHonorInfoByRepu(repuaction)
  local rtnVal = self.m_honorInfos[1]
  for k, value in pairs(self.m_honorInfos) do
    if repuaction >= value.honor_need then
      rtnVal = value
    else
      break
    end
  end
  return rtnVal
end
function CommanderInfoManager:GetMaxProfitByRepu(repuaction, itemId)
  local info = self:GetHonorInfoByRepu(repuaction)
  return info.limit[itemId]
end
function CommanderInfoManager:GetSoldierByRepu(repuaction)
  local info = self:GetHonorInfoByRepu(repuaction)
  return info.atk_increase
end
return CommanderInfoManager
