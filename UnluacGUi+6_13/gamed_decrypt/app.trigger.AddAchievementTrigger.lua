local TDHttpRequest = require("app.net.TDHttpRequest")
local TriggerBase = import(".TriggerBase")
local UserDataManager = require("app.UserDataManager")
local AddAchievementTrigger = class("AddAchievementTrigger", TriggerBase)
function AddAchievementTrigger:ctor(iID, iType, bLoop, conditionType, data)
  AddAchievementTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_achieveId = data.achieveId
end
function AddAchievementTrigger:Active()
  AddAchievementTrigger.super.Active(self)
  if not UserDataManager:GetInstance():IsAchieveReached(self.m_achieveId) then
    local data = {}
    data.tid = self.m_achieveId
    local Msg = {}
    Msg.msgType = td.RequestID.AddAchieventment
    Msg.sendData = data
    TDHttpRequest:getInstance():Send(Msg)
  else
    td.alertDebug("\230\136\144\229\176\177\229\183\178\231\187\143\232\190\190\230\136\144\232\191\135")
  end
end
return AddAchievementTrigger
