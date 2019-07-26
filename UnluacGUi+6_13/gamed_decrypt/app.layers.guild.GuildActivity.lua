local GuildContentBase = require("app.layers.guild.GuildContentBase")
local UserDataManager = require("app.UserDataManager")
local GuildDataManager = require("app.GuildDataManager")
local RuleInfoDlg = require("app.layers.RuleInfoDlg")
local GuildActivity = class("GuildActivity", GuildContentBase)
function GuildActivity:ctor(height)
  GuildActivity.super.ctor(self, height)
  self.m_gdMng = GuildDataManager:GetInstance()
  self.actList = {
    {},
    {},
    {}
  }
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function GuildActivity:onEnter()
  self:AddListeners()
end
function GuildActivity:onExit()
  self:RemoveListeners()
  GuildActivity.super.onExit(self)
end
function GuildActivity:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/guild/GuildActivity.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  for i = 1, 2 do
    do
      local actBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_act" .. i)
      local btnLeft = cc.uiloader:seekNodeByName(actBg, "Button_left_5")
      td.BtnSetTitle(btnLeft, g_LM:getBy("a00317"))
      td.BtnAddTouch(btnLeft, function()
        self:ShowRule(i)
      end)
      local btnRight = cc.uiloader:seekNodeByName(actBg, "Button_right_3")
      td.BtnSetTitle(btnRight, g_LM:getBy("a00318"))
      td.BtnAddTouch(btnRight, function()
        self:EnterAct(i)
      end)
    end
  end
end
function GuildActivity:ShowRule(index)
  local rules = {"a00222", "a00226"}
  local str = g_LM:getBy(rules[index])
  local data = {
    title = "\232\167\132\229\136\153\232\175\180\230\152\142",
    text = str
  }
  local ruleInfo = RuleInfoDlg.new(data)
  td.popView(ruleInfo)
end
function GuildActivity:EnterAct(index)
  if index == 1 then
    local pvpData = self.m_gdMng:GetGuildPVPData()
    if pvpData.battleId then
      self:ShowPVPDlg()
    else
      self.m_gdMng:SendRequest(nil, td.RequestID.GetGuildPVPInfo)
    end
  else
    local dlg = require("app.layers.guild.GuildBossDlg").new()
    td.popView(dlg)
  end
end
function GuildActivity:ShowPVPDlg()
  local pvpData = self.m_gdMng:GetGuildPVPData()
  if pvpData:GetValue("battleState") ~= td.GuildPVPState.NotOver then
    local dlg = require("app.layers.guild.GuildPVPOverDlg").new()
    td.popView(dlg)
  else
    local bStart, cdTime = self.m_gdMng:IsGuildPVPStart()
    if bStart then
      local dlg = require("app.layers.guild.GuildPVPDlg").new()
      td.popView(dlg)
    else
      td.alert(g_LM:getBy("a00330"))
    end
  end
end
function GuildActivity:AddListeners()
  self:AddCustomEvent(td.GUILD_PVP_INFO_UPDATE, handler(self, self.ShowPVPDlg))
end
function GuildActivity:RemoveListeners()
end
return GuildActivity
