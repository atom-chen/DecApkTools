local TDHttpRequest = require("app.net.TDHttpRequest")
local AttributeBase = import(".AttributeBase")
local UserDataManager = require("app.UserDataManager")
local AddAchievementAttribute = class("AddAchievementAttribute", AttributeBase)
function AddAchievementAttribute:ctor(pEffect, fNextAttributeTime, data)
  AddAchievementAttribute.super.ctor(self, td.AttributeType.OverAchievement, pEffect, fNextAttributeTime)
  self.m_achievementId = data.achievementId
  self.m_rewardId = data.itemId
end
function AddAchievementAttribute:Active()
  AddAchievementAttribute.super.Active(self)
  self.m_callback = handler(self, self.AddItemCallback)
  if UserDataManager:GetInstance():IsAchieveReached(self.m_achievementId) then
    self:SetOver()
    print("\230\136\144\229\176\177\229\183\178\231\187\143\232\190\190\230\136\144\232\191\135")
  else
    TDHttpRequest:getInstance():registerCallback(td.RequestID.AddAchieventment, self.m_callback)
    local data = {}
    data.tid = self.m_achievementId
    local Msg = {}
    Msg.msgType = td.RequestID.AddAchieventment
    Msg.sendData = data
    TDHttpRequest:getInstance():Send(Msg, true)
  end
end
function AddAchievementAttribute:AddItemCallback(data)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.AddAchieventment, self.m_callback)
  self:SetOver()
end
return AddAchievementAttribute
