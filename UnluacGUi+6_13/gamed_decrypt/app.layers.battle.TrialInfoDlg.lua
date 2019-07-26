local TDHttpRequest = require("app.net.TDHttpRequest")
local MissionInfoManager = require("app.info.MissionInfoManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local RichIcon = require("app.widgets.RichIcon")
local UserDataManager = require("app.UserDataManager")
local GameDataManager = require("app.GameDataManager")
local BaseDlg = require("app.layers.BaseDlg")
local TrialInfoDlg = class("TrialInfoDlg", BaseDlg)
function TrialInfoDlg:ctor()
  TrialInfoDlg.super.ctor(self)
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function TrialInfoDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/TrialInfoDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_10_0")
  label:setString(g_LM:getBy("a00400") .. ":")
  local trialData = GameDataManager:GetInstance():GetTrialData()
  local trialLevel = GameDataManager:GetInstance():GetTrialData().level
  local titleLabel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Label_title")
  titleLabel:setString(string.format(g_LM:getBy("a00288"), trialLevel))
  local mapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  self.m_minimap = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_minimap")
  self.m_minimap:loadTexture(mapInfo.mini_map .. td.PNG_Suffix)
  local vCareer = self:GetCareers()
  local gapX = 45
  local startX = 450 - (#vCareer - 1) / 2 * gapX
  for i, career in ipairs(vCareer) do
    local careerIcon = td.CreateCareerIcon(career)
    careerIcon:scale(0.65):pos(startX + (i - 1) * gapX, 270):addTo(self.m_bg)
  end
  self.m_BtnDo = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_do_2")
  td.BtnAddTouch(self.m_BtnDo, function()
    if self.m_cb then
      self.m_cb()
      self.m_cb = nil
      self:close()
    end
  end)
  td.BtnSetTitle(self.m_BtnDo, g_LM:getBy("a00102"))
end
function TrialInfoDlg:GetCareers()
  local vCareer = {}
  local monsterPlan = GameDataManager:GetInstance():GetGameMapInfo().monster_plan
  local tmp = string.split(monsterPlan, ";")
  for i, var in ipairs(tmp) do
    local tmp2 = string.split(var, ":")
    local monsterInfo = ActorInfoManager:GetInstance():GetMonsterInfo(tonumber(tmp2[1]))
    if not table.indexof(vCareer, monsterInfo.career) then
      table.insert(vCareer, monsterInfo.career)
      if #vCareer >= 4 then
        break
      end
    end
  end
  return vCareer
end
function TrialInfoDlg:SetCallback(cb)
  self.m_cb = cb
end
return TrialInfoDlg
