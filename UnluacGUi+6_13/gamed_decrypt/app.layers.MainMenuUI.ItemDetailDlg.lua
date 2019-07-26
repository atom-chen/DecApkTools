local BaseDlg = require("app.layers.BaseDlg")
local ItemInfoManager = require("app.info.ItemInfoManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local InformationManager = require("app.layers.InformationManager")
local ItemDetailDlg = class("ItemDetailDlg", BaseDlg)
ItemDetailDlg.ShowType = {Bag = 1, Mall = 2}
function ItemDetailDlg:ctor(data)
  ItemDetailDlg.super.ctor(self)
  self.m_uiId = td.UIModule.ItemDetail
  self:InitUI()
  self:SetData(data.itemId, data.showType)
end
function ItemDetailDlg:onEnter()
  ItemDetailDlg.super.onEnter(self)
  self:CheckGuide()
  self:AddEvents()
  self:AddTouch()
end
function ItemDetailDlg:onExit()
  self:RemoveEvents()
  ItemDetailDlg.super.onExit(self)
end
function ItemDetailDlg:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function()
        self:close()
      end, 0.1)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function ItemDetailDlg:AddEvents()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UseItem_req, handler(self, self.UseItemRequestCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.OpenBox_req, handler(self, self.OpenBoxRequestCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.LearnSkill, handler(self, self.LearnSkillCallback))
end
function ItemDetailDlg:RemoveEvents()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.UseItem_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.OpenBox_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.LearnSkill)
end
function ItemDetailDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/ItemDetailDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local titleSpr = display.newSprite(td.Word_Path .. "wenzi_wupingxiangqing.png")
  td.AddRelaPos(self.m_bg, titleSpr, 1, cc.p(0.5, 0.9))
  self.iconBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_iconBg")
  self.nameLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_name")
  self.descLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_desc")
  self.numLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_num")
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_3")
  label:setString(g_LM:getBy("a00377") .. ":")
end
function ItemDetailDlg:SetData(itemId, showType)
  self.m_itemInfo = td.GetItemInfo(itemId)
  self.iconSpr = td.IconWithStar(self.m_itemInfo.icon .. td.PNG_Suffix, self.m_itemInfo.quality, nil, -60)
  self.iconSpr:scale(1.2)
  td.AddRelaPos(self.iconBg, self.iconSpr, 1, cc.p(0.5, 0.55))
  self.nameLabel:setString(self.m_itemInfo.name)
  self.descLabel:setString(self.m_itemInfo.desc)
  self.numLabel:setString(tostring(UserDataManager:GetInstance():GetItemNum(itemId)))
  if showType == ItemDetailDlg.ShowType.Bag then
    self:CreateButton(self.m_itemInfo.use_type, itemId)
  end
end
function ItemDetailDlg:CreateButton(vUseType, itemId)
  local startx, gapx = 0.5, 0
  if #vUseType == 2 then
    startx, gapx = 0.35, 0.3
  end
  for i, useType in ipairs(vUseType) do
    if useType ~= 0 then
      local button = td.CreateBtn(td.BtnType.GreenShort)
      td.BtnAddTouch(button, function()
        self:DoEvent(useType)
      end)
      button:setName("Button_do_" .. td.BtnType.GreenShort)
      td.BtnSetTitle(button, self:GetBtnTxt(useType, itemId))
      td.AddRelaPos(self.m_bg, button, 1, cc.p(startx, 0.15))
      if useType == td.ItemUseType.Learn and not ItemDetailDlg.IsCanLearn(itemId) then
        td.EnableButton(button, false)
      end
      startx = startx + gapx
    end
  end
end
function ItemDetailDlg:DoEvent(useType)
  if self.m_bIsSending then
    return
  end
  local data = self.m_itemInfo
  if td.ItemUseType.Use == useType then
    self:SendUseItemRequest(data.id)
  elseif td.ItemUseType.Break == useType then
    self:close()
    g_MC:OpenModule(td.UIModule.Decompose, {
      itemId = data.id
    })
  elseif td.ItemUseType.Compose == useType then
    self:close()
    g_MC:OpenModule(td.UIModule.Compose, {
      itemId = data.id
    })
  elseif td.ItemUseType.Open == useType then
    self:OpenBoxRequest(data.id)
  elseif td.ItemUseType.Learn == useType then
    if not ItemDetailDlg.IsCanLearn(data.id) then
      td.alertErrorMsg(td.ErrorCode.LEARN_ALREADY)
    else
      self:LearnSkillRequest(data.id)
    end
  elseif td.ItemUseType.Sell == useType then
    self:close()
    g_MC:OpenModule(td.UIModule.ItemSell, {
      itemId = data.id
    })
  end
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
end
function ItemDetailDlg.IsCanLearn(itemId)
  local info = SkillInfoManager:GetInstance():GetItemSkillInfo(itemId)
  if not info then
    return false
  end
  local IsInFunc = function(list, id)
    for key, var in pairs(list) do
      if var.skill_id == id then
        return true
      end
    end
    return false
  end
  local UserDataManager = require("app.UserDataManager")
  local vSkillLib = UserDataManager:GetInstance():GetSkillLib()
  if not IsInFunc(vSkillLib, info.skill_id) then
    return true
  end
  return false
end
function ItemDetailDlg:GetBtnTxt(useType, itemId)
  local txt = ""
  if td.ItemUseType.Use == useType then
    txt = g_LM:getBy("a00005")
  elseif td.ItemUseType.Break == useType then
    txt = g_LM:getBy("a00006")
  elseif td.ItemUseType.Compose == useType then
    txt = g_LM:getBy("a00153")
  elseif td.ItemUseType.Open == useType then
    if itemId and itemId == 30000 then
      txt = g_LM:getBy("a00011")
    else
      txt = g_LM:getBy("a00005")
    end
  elseif td.ItemUseType.Learn == useType then
    if not ItemDetailDlg.IsCanLearn(itemId) then
      txt = g_LM:getBy("a00225")
    else
      txt = g_LM:getBy("a00094")
    end
  elseif td.ItemUseType.Sell == useType then
    txt = g_LM:getBy("a00231")
  end
  return txt
end
function ItemDetailDlg:SendUseItemRequest(targetId)
  self.m_bIsSending = true
  local Msg = {}
  Msg.msgType = td.RequestID.UseItem_req
  Msg.sendData = {itemId = targetId}
  Msg.cbData = {itemId = targetId}
  TDHttpRequest:getInstance():Send(Msg)
end
function ItemDetailDlg:UseItemRequestCallback(data, cbData)
  self.m_bIsSending = false
  if td.ResponseState.Success == data.state then
    self:close()
    if cbData.itemId == 20123 then
      UserDataManager:GetInstance():PublicGain(td.WealthType.STAMINA, 50)
    end
  end
end
function ItemDetailDlg:OpenBoxRequest(targetId)
  self.m_bIsSending = true
  local Msg = {}
  Msg.msgType = td.RequestID.OpenBox_req
  Msg.sendData = {itemId = targetId}
  TDHttpRequest:getInstance():Send(Msg)
end
function ItemDetailDlg:OpenBoxRequestCallback(data)
  self.m_bIsSending = false
  if td.ResponseState.Success == data.state and #data.itemProto > 0 then
    local items = {}
    if data.itemProto and #data.itemProto > 0 then
      for k, value in pairs(data.itemProto) do
        if 0 < value.num then
          table.insert(items, value)
        end
      end
    end
    if self.m_itemInfo.id ~= 20005 and self.m_itemInfo.id ~= 20004 then
      InformationManager:GetInstance():ShowOpenBox(items)
    else
      for i, item in ipairs(items) do
        InformationManager:GetInstance():ShowInfoDlg({
          type = td.ShowInfo.Item,
          items = {
            [item.itemId] = item.num
          }
        })
      end
    end
    self:close()
  end
end
function ItemDetailDlg:LearnSkillRequest(targetId)
  self.m_bIsSending = true
  local tdRequest = TDHttpRequest:getInstance()
  local data = {}
  data.item_id = targetId
  local Msg = {}
  Msg.msgType = td.RequestID.LearnSkill
  Msg.sendData = data
  tdRequest:Send(Msg)
end
function ItemDetailDlg:LearnSkillCallback(data)
  self.m_bIsSending = false
  if td.ResponseState.Success == data.state then
    UserDataManager:GetInstance():UpdateHeroSkillData(data.skillProto)
    td.alertDebug("\229\173\166\228\185\160\230\136\144\229\138\159")
    InformationManager:GetInstance():ShowInfoDlg({
      type = td.ShowInfo.Skill,
      items = {
        [data.skillProto.skill_id] = 1
      }
    })
    self:close()
  end
end
return ItemDetailDlg
