local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local ActivityInfoManager = class("ActivityInfoManager", GameControl)
ActivityInfoManager.instance = nil
function ActivityInfoManager:ctor(eType)
  ActivityInfoManager.super.ctor(self, eType)
  self:Init()
end
function ActivityInfoManager:GetInstance()
  if ActivityInfoManager.instance == nil then
    ActivityInfoManager.instance = ActivityInfoManager.new(td.GameControlType.ExitGame)
  end
  return ActivityInfoManager.instance
end
function ActivityInfoManager:Init()
  self.m_signInfos = {}
  self.m_onlineInfos = {}
  self.m_inviteInfos = {}
  self:SaveInfo()
end
function ActivityInfoManager:ClearValue()
end
function ActivityInfoManager:SaveInfo()
  local vData = CSVLoader.loadCSV("Config/check_in.csv")
  for i, v in ipairs(vData) do
    local tmp = string.split(v.reward, "#")
    v.itemId = tonumber(tmp[1])
    v.num = tonumber(tmp[2])
    self.m_signInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/online_activity.csv")
  for i, v in ipairs(vData) do
    local tmp = string.split(v.reward, "#")
    v.itemId = tonumber(tmp[1])
    v.num = tonumber(tmp[2])
    self.m_onlineInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/invite.csv")
  for i, v in ipairs(vData) do
    local tmp = string.split(v.reward, "#")
    v.itemId = tonumber(tmp[1])
    v.num = tonumber(tmp[2])
    self.m_inviteInfos[v.id] = v
  end
end
function ActivityInfoManager:GetSignInfo(id)
  return self.m_signInfos[id]
end
function ActivityInfoManager:GetSignInfos()
  return self.m_signInfos
end
function ActivityInfoManager:GetOnlineInfo(id)
  return self.m_onlineInfos[id]
end
function ActivityInfoManager:GetOnlineInfos()
  return self.m_onlineInfos
end
function ActivityInfoManager:GetInviteInfos()
  return self.m_inviteInfos
end
return ActivityInfoManager
