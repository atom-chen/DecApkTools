local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local GuideManager = require("app.GuideManager")
local UserDataManager = require("app.UserDataManager")
local config = require("app.config.dungeon_config")
local DungeonLayer = class("DungeonLayer", BaseDlg)
function DungeonLayer:ctor()
  DungeonLayer.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Dungeon
  self.m_udMng = UserDataManager:GetInstance()
  self.m_weekDay = tonumber(os.date("%w", self.m_udMng:GetServerTime()))
  self:InitUI()
end
function DungeonLayer:onEnter()
  DungeonLayer.super.onEnter(self)
  self:CheckGuide()
end
function DungeonLayer:onExit()
  DungeonLayer.super.onExit(self)
end
function DungeonLayer:InitUI()
  self:LoadUI("CCS/DungeonLayer.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_fuben.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  for i = 1, 5 do
    local btn = cc.uiloader:seekNodeByName(self.m_bg, "Button_" .. i)
    td.BtnAddTouch(btn, handler(self, self.OnBtnClicked))
    local titleLabel = td.CreateLabel(config[i].name, td.YELLOW, 22)
    td.AddRelaPos(btn, titleLabel, 1, cc.p(0.5, 0.16))
    local timeLabel = td.CreateLabel(self:GetDateStr(config[i].open), td.WHITE, 16)
    td.AddRelaPos(btn, timeLabel, 1, cc.p(0.5, 0.08))
    local bgSpr
    if self:CheckOpen(config[i].open) then
      bgSpr = display.newSprite(config[i].bg)
    else
      bgSpr = display.newGraySprite(config[i].bg)
    end
    td.AddRelaPos(btn, bgSpr, -1)
  end
end
function DungeonLayer:OnBtnClicked(sender)
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  local tag = sender:getTag()
  if self:CheckOpen(config[tag].open) then
    g_MC:OpenModule(config[tag].id)
  else
    td.alertErrorMsg(td.ErrorCode.DATE_WRONG)
  end
end
function DungeonLayer:CheckOpen(vTimes)
  if table.indexof(vTimes, self.m_weekDay) then
    return true
  end
  return false
end
function DungeonLayer:GetDateStr(vTimes)
  local weekdays = {
    "\229\145\168\230\151\165",
    "\229\145\168\228\184\128",
    "\229\145\168\228\186\140",
    "\229\145\168\228\184\137",
    "\229\145\168\229\155\155",
    "\229\145\168\228\186\148",
    "\229\145\168\229\133\173"
  }
  return string.format("\230\175\143%s\227\128\129%s\229\188\128\230\148\190", weekdays[vTimes[1] + 1], weekdays[vTimes[2] + 1])
end
return DungeonLayer
