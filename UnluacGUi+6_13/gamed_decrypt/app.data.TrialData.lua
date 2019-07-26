local TrialData = class("TrialData")
function TrialData:ctor()
  self.m_data = {}
  self:InitData()
end
function TrialData:InitData()
  local udMng = require("app.UserDataManager"):GetInstance()
  local vipDetail = udMng:GetVIPData()
  self.m_data.res = {
    vipDetail.practice_num1,
    vipDetail.practice_num2,
    vipDetail.practice_num3
  }
  self.m_data.lastRes = {
    vipDetail.practice_num1,
    vipDetail.practice_num2,
    vipDetail.practice_num3
  }
end
function TrialData:GetLastRes(mode)
  return self.m_data.lastRes[mode]
end
function TrialData:UpdateLastRes(mode)
  self.m_data.lastRes[mode] = self.m_data.res[mode]
end
function TrialData:GetInitRes(mode)
  return self.m_data.res[mode]
end
function TrialData:UpdateInitRes(arg, mode)
  self:UpdateLastRes(mode)
  self.m_data.res[mode] = self.m_data.res[mode] + arg
end
return TrialData
