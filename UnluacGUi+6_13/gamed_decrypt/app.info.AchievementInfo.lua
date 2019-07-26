local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local AchievementInfo = class("AchievementInfo", GameControl)
AchievementInfo.instance = nil
function AchievementInfo:ctor(eType)
  AchievementInfo.super.ctor(self, eType)
  self:Init()
end
function AchievementInfo:GetInstance()
  if AchievementInfo.instance == nil then
    AchievementInfo.instance = AchievementInfo.new(td.GameControlType.ExitGame)
  end
  return AchievementInfo.instance
end
function AchievementInfo:Init()
  self.m_Infos = {}
  self:SaveInfo()
end
function AchievementInfo:ClearValue()
end
function AchievementInfo:SaveInfo()
  local vData = CSVLoader.loadCSV("Config/achievement.csv")
  for i, v in ipairs(vData) do
    v.name = g_LM:getBy(v.name)
    v.descrip = g_LM:getBy(v.descrip)
    local t = string.split(v.get_type, "#")
    v.childType = tonumber(t[1])
    if v.type == 0 then
      v.maxNum = tonumber(t[2])
    else
      v.maxNum = 1
    end
    t = string.split(v.award, "|")
    v.award = {}
    for i, var in ipairs(t) do
      local tmp = string.split(var, "#")
      table.insert(v.award, {
        id = tonumber(tmp[1]),
        num = tonumber(tmp[2])
      })
    end
    self.m_Infos[v.id] = v
  end
end
function AchievementInfo:GetInfo(id)
  return self.m_Infos[id]
end
function AchievementInfo:GetInfos()
  return self.m_Infos
end
return AchievementInfo
