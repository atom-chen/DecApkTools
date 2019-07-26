local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local BuffInfoManager = class("BuffInfoManager", GameControl)
BuffInfoManager.instance = nil
function BuffInfoManager:ctor(eType)
  BuffInfoManager.super.ctor(self, eType)
  self:Init()
end
function BuffInfoManager:GetInstance()
  if BuffInfoManager.instance == nil then
    BuffInfoManager.instance = BuffInfoManager.new(td.GameControlType.ExitGame)
  end
  return BuffInfoManager.instance
end
function BuffInfoManager:Init()
  self.m_Infos = {}
  self.m_TypeInfos = {}
  self:SaveBuffTypeInfo()
  self:SaveBuffInfo()
end
function BuffInfoManager:ClearValue()
end
function BuffInfoManager:SaveBuffTypeInfo()
  local vData = CSVLoader.loadCSV("Config/buff_type.csv")
  for i, v in ipairs(vData) do
    local removeType = string.split(v.remove_type, "#")
    v.remove_type = {}
    for j, var in ipairs(removeType) do
      table.insert(v.remove_type, tonumber(var))
    end
    local rejectType = string.split(v.reject_type, "#")
    v.reject_type = {}
    for j, var in ipairs(rejectType) do
      table.insert(v.reject_type, tonumber(var))
    end
    self.m_TypeInfos[v.id] = v
  end
end
function BuffInfoManager:SaveBuffInfo()
  local vData = CSVLoader.loadCSV("Config/buff.csv")
  for i, v in ipairs(vData) do
    local values = string.split(v.value, "|")
    v.value = {}
    for j, var in ipairs(values) do
      table.insert(v.value, tonumber(var))
    end
    local triggerBuffs = string.split(v.custom_data, "#")
    v.custom_data = {}
    for j, var in ipairs(triggerBuffs) do
      table.insert(v.custom_data, tonumber(var))
    end
    self.m_Infos[v.id] = v
  end
end
function BuffInfoManager:GetInfo(id)
  return self.m_Infos[id]
end
function BuffInfoManager:GetTypeInfo(typeId)
  return self.m_TypeInfos[typeId]
end
return BuffInfoManager
