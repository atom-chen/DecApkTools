local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local SupplyDlg = class("SupplyDlg", BaseDlg)
function SupplyDlg:ctor()
  SupplyDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Supply
  self:initUI()
end
function SupplyDlg:initUI()
  self:LoadUI("CCS/SupplyDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_buji.png")
  local bResult, vIndex = UserDataManager:GetInstance():GetStoreManager():CheckRP()
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_btnStore = cc.uiloader:seekNodeByName(self.m_bg, "Button_store")
  self.m_btnStore:setPressedActionEnabled(true)
  if table.indexof(vIndex, 1) then
    td.ShowRP(self.m_btnStore, true)
  end
  self.m_btnSupply = cc.uiloader:seekNodeByName(self.m_bg, "Button_supply")
  self.m_btnSupply:setPressedActionEnabled(true)
  if table.indexof(vIndex, 2) then
    td.ShowRP(self.m_btnSupply, true)
  end
  self.m_btnTopup = cc.uiloader:seekNodeByName(self.m_bg, "Button_topup")
  self.m_btnTopup:setPressedActionEnabled(true)
  if table.indexof(vIndex, 3) then
    td.ShowRP(self.m_btnTopup, true)
  end
end
function SupplyDlg:onEnter()
  SupplyDlg.super.onEnter(self)
  self:AddButtonEvents()
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  require("app.GuideManager").H_StartGuideGroup(104)
end
function SupplyDlg:onExit()
  SupplyDlg.super.onExit(self)
end
function SupplyDlg:AddButtonEvents()
  td.BtnAddTouch(self.m_btnStore, function()
    g_MC:OpenModule(td.UIModule.Store)
  end)
  td.BtnAddTouch(self.m_btnSupply, function()
    g_MC:OpenModule(td.UIModule.DrawCard)
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  end)
  td.BtnAddTouch(self.m_btnTopup, function()
    g_MC:OpenModule(td.UIModule.Topup)
  end)
end
return SupplyDlg
