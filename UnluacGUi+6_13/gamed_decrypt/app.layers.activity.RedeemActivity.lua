local TDHttpRequest = require("app.net.TDHttpRequest")
local InformationManager = require("app.layers.InformationManager")
local UserDataManager = require("app.UserDataManager")
local RedeemActivity = class("RedeemActivity", function()
  return display.newNode()
end)
function RedeemActivity:ctor()
  self.m_bIsRequsting = false
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function RedeemActivity:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/activities/Redeem.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_editbox = ccui.EditBox:create(cc.size(420, 50), "UI/scale9/transparent1x1.png")
  self.m_editbox:setFontSize(20)
  self.m_editbox:setMaxLength(18)
  td.AddRelaPos(self.m_bg, self.m_editbox, 1, cc.p(0.5, 0.41))
  local btn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_get")
  td.BtnAddTouch(btn, function()
    local str = self.m_editbox:getText()
    if self.m_bIsRequsting or str == "" then
      return
    end
    self.m_bIsRequsting = true
    self:SendRedeemReq(str)
  end)
end
function RedeemActivity:onEnter()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.Redeem, handler(self, self.RedeemCallback))
end
function RedeemActivity:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.Redeem)
end
function RedeemActivity:SendRedeemReq(str)
  local udMng = UserDataManager:GetInstance()
  local sendData = {
    invitationId = str,
    uid = udMng:GetUId(),
    serverId = udMng:GetServerData().id
  }
  TDHttpRequest:getInstance():SendNoProto("GetInvitationServelt", sendData, handler(self, self.RedeemCallback))
end
function RedeemActivity:RedeemCallback(data)
  if data.state == td.ResponseState.Success then
    td.alert(g_LM:getBy("a00365"))
  end
  self.m_bIsRequsting = false
end
return RedeemActivity
