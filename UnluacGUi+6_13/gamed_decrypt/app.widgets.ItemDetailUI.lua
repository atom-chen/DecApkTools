local ItemInfoManager = require("app.info.ItemInfoManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local InformationManager = require("app.layers.InformationManager")
local UserDataManager = require("app.UserDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
require("app.config.break_config")
require("app.config.compose_config")
local ItemDetailUI = class("ItemDetailUI", function(layer)
  return display.newNode()
end)
local ComposeBookCost = {15, 30}
function ItemDetailUI:ctor(layer)
  self.m_uiId = td.UIModule.ItemDetail
  self.m_tmpNodes = {}
  self.m_bIsSending = false
  self.m_backpackLayer = layer
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function ItemDetailUI:onEnter()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UseItem_req, handler(self, self.UseItemRequestCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.HeChengItem_req, handler(self, self.HeChengItemRequestCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.FenJieItem_req, handler(self, self.FenJieItemRequestCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.OpenBox_req, handler(self, self.OpenBoxRequestCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.HeChengSkill1, handler(self, self.HeChengSkillRequestCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.LearnSkill, handler(self, self.LearnSkillCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.HeChengSkill2, handler(self, self.HeChengItemRequestCallback))
  local eventDsp = self:getEventDispatcher()
  self.m_guideListener = cc.EventListenerCustom:create(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  eventDsp:addEventListenerWithFixedPriority(self.m_guideListener, 1)
end
function ItemDetailUI:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.UseItem_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.HeChengItem_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.FenJieItem_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.OpenBox_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.HeChengSkill1)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.LearnSkill)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.HeChengSkill2)
  local eventDsp = self:getEventDispatcher()
  eventDsp:removeEventListener(self.m_guideListener)
end
function ItemDetailUI:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/ItemDetailDlg.csb")
  self:addChild(self.m_uiRoot, 1)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "DlgBg")
  self.m_conBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_content")
  self.m_icon = cc.uiloader:seekNodeByName(self.m_bg, "Image_icon")
  self.m_nameLabel = td.CreateBMF("", "Fonts/white22.fnt", 1, true)
  self.m_nameLabel:setAnchorPoint(0, 0)
  self.m_nameLabel:pos(160, 230):addTo(self.m_bg)
  local sourceLabel = td.CreateBMF(g_LM:getBy("a00147"), "Fonts/green22.fnt", 1)
  sourceLabel:setAnchorPoint(0, 1)
  sourceLabel:pos(160, 228):addTo(self.m_bg)
  self.m_sourceLabel = display.newBMFontLabel({
    text = "",
    font = "Fonts/yellow22.fnt",
    maxLineWidth = 200
  })
  self.m_sourceLabel:setAnchorPoint(0, 1)
  self.m_sourceLabel:pos(160, 228):addTo(self.m_bg)
end
function ItemDetailUI:RefreshUI(itemData)
  if self.m_subUI then
    self.m_subUI:removeFromParent()
    self.m_subUI = nil
  end
  self.m_conBg:setVisible(true)
  self.m_num = itemData.num
  self.m_itemInfo = itemData.itemInfo
  self.m_icon:loadTexture(self.m_itemInfo.icon .. td.PNG_Suffix)
  self.m_nameLabel:setString(self.m_itemInfo.name)
  local sourceStr = "               " .. self:GetSourceStr(self.m_itemInfo.source)
  self.m_sourceLabel:setString(sourceStr)
  for i, node in ipairs(self.m_tmpNodes) do
    node:removeFromParent()
  end
  self.m_tmpNodes = {}
  if self.m_itemInfo.bag_type == 2 then
    local skillId = SkillInfoManager:GetInstance():GetItemSkillInfo(self.m_itemInfo.id).skill_id
    local skillInfo = SkillInfoManager:GetInstance():GetInfo(skillId)
    local iconSpr = display.newSprite(skillInfo.icon .. td.PNG_Suffix)
    iconSpr:scale(0.6)
    self:InFunc1({
      parent = self.m_conBg,
      node = iconSpr,
      ancPos = cc.p(0.5, 1),
      pos = cc.p(40, 95)
    })
    local descLabel = td.CreateLabel(skillInfo.desc, td.LIGHT_BLUE, 14, nil, nil, cc.size(260, 0))
    self:InFunc1({
      parent = self.m_conBg,
      node = descLabel,
      ancPos = cc.p(0, 1),
      pos = cc.p(75, 95)
    })
  else
    local descLabel = td.CreateLabel(self.m_itemInfo.desc, td.LIGHT_BLUE, 16, nil, nil, cc.size(310, 0))
    self:InFunc1({
      parent = self.m_conBg,
      node = descLabel,
      ancPos = cc.p(0, 1),
      pos = cc.p(20, 95)
    })
  end
  local posConfig = {
    [1] = {0.5},
    [2] = {0.33, 0.67},
    [3] = {
      0.2,
      0.5,
      0.8
    }
  }
  local vPos = posConfig[#self.m_itemInfo.use_type]
  local conWidth = self.m_conBg:getContentSize().width
  local button = self:CreateButton(self.m_itemInfo.use_type, self.m_itemInfo.id)
  self:InFunc1({
    parent = self.m_conBg,
    node = button,
    ancPos = cc.p(0.5, 0.5),
    pos = cc.p(conWidth * 0.5, -30)
  })
  self:CheckGuide()
end
function ItemDetailUI:InFunc1(data)
  local parent = data.parent
  local node = data.node
  parent:addChild(node)
  node:setAnchorPoint(data.ancPos)
  node:setPosition(data.pos)
  table.insert(self.m_tmpNodes, node)
end
function ItemDetailUI:GetSourceStr(source)
  local result = ""
  local vec = string.split(source, "#")
  for i, var in ipairs(vec) do
    local sType = tonumber(var)
    if sType == 1 then
      result = result .. g_LM:getBy("a00148")
    elseif sType == 2 then
      result = result .. g_LM:getBy("a00153")
    elseif sType == 3 then
      result = result .. g_LM:getBy("a00149")
    elseif sType == 4 then
      result = result .. g_LM:getBy("a00119")
    elseif sType == 5 then
      result = result .. g_LM:getBy("a00150")
    elseif sType == 6 then
      result = result .. g_LM:getBy("a00286")
    end
    if i ~= #vec then
      result = result .. ","
    end
  end
  return result == "" and g_LM:getBy("a00151") or result
end
function ItemDetailUI:CreateButton(useType, itemId)
  local button, touchFunc
  if table.indexof({
    td.ItemUseType.Break,
    td.ItemUseType.ComposeBook,
    td.ItemUseType.Compose,
    td.ItemUseType.ComposeBook2
  }, useType) then
    button = td.CreateBtn(td.BtnType.BlueShort)
    function touchFunc(sender, eventType)
      if eventType == ccui.TouchEventType.ended then
        self:ShowSubUI(useType)
      end
    end
  else
    button = td.CreateBtn(td.BtnType.GreenShort)
    function touchFunc(sender, eventType)
      if eventType == ccui.TouchEventType.ended then
        self:DoEvent(useType)
      end
    end
    if useType == td.ItemUseType.Learn and not ItemDetailUI.IsCanLearn(self.m_itemInfo.id) then
      td.EnableButton(button, false)
    end
  end
  button:setName("Button_" .. useType)
  button:setScale(0.8)
  td.BtnAddTouch(button, function()
    touchFunc()
  end)
  td.BtnSetTitle(button, self:GetBtnTxt(useType, itemId))
  return button
end
function ItemDetailUI:GetBtnTxt(useType, itemId)
  local txt = ""
  if td.ItemUseType.ComposeBook == useType then
    txt = g_LM:getBy("a00004")
  elseif td.ItemUseType.Use == useType then
    txt = g_LM:getBy("a00005")
  elseif td.ItemUseType.Break == useType then
    txt = g_LM:getBy("a00006")
  elseif td.ItemUseType.Open == useType then
    if itemId and itemId == 30000 then
      txt = g_LM:getBy("a00011")
    else
      txt = g_LM:getBy("a00005")
    end
  elseif td.ItemUseType.Learn == useType then
    txt = g_LM:getBy("a00094")
  elseif td.ItemUseType.Compose == useType then
    txt = g_LM:getBy("a00004")
  elseif td.ItemUseType.ComposeBook2 == useType then
    txt = g_LM:getBy("a00004")
  end
  return txt
end
function ItemDetailUI:ShowSubUI(useType)
  self.m_conBg:setVisible(false)
  if self.m_subUI then
    self.m_subUI:removeFromParent()
    self.m_subUI = nil
  end
  if useType == td.ItemUseType.ComposeBook2 or useType == td.ItemUseType.Compose then
    self:InitSubUICompose(useType)
  elseif td.ItemUseType.ComposeBook == useType then
    self:InitSubUIComposeSkill(useType)
  elseif td.ItemUseType.Break == useType then
    self:InitSubUIBreak(useType)
  end
end
function ItemDetailUI:InitSubButton(useType)
  if self.m_subUI then
    local fromIcon = cc.uiloader:seekNodeByName(self.m_subUI, "Image_icon_from")
    fromIcon:loadTexture(self.m_itemInfo.icon .. td.PNG_Suffix)
    self.m_yesBtn = cc.uiloader:seekNodeByName(self.m_subUI, "Button_yes_3")
    td.BtnAddTouch(self.m_yesBtn, function()
      self:DoEvent(useType)
    end)
    td.BtnSetTitle(self.m_yesBtn, g_LM:getBy("a00009"))
    local cancelBtn = cc.uiloader:seekNodeByName(self.m_subUI, "Button_no")
    td.BtnAddTouch(cancelBtn, function()
      self:DoEvent()
    end)
    td.BtnSetTitle(cancelBtn, g_LM:getBy("a00116"))
    self.m_subUI:pos(195, 124):addTo(self.m_bg)
  end
end
function ItemDetailUI:InitSubUIComposeSkill(useType)
  self.m_subUI = cc.uiloader:load("CCS/ItemSubCompose2.csb")
  self:InitSubButton(useType)
  self.m_composeIndex = 1
  self.m_imageFrom = cc.uiloader:seekNodeByName(self.m_subUI, "kuang_1")
  self.m_imageTo1 = cc.uiloader:seekNodeByName(self.m_subUI, "kuang_2")
  self.m_imageTo2 = cc.uiloader:seekNodeByName(self.m_subUI, "kuang_3")
  self.m_getLabel1 = td.CreateLabel("x1", nil, nil, td.OL_BLACK)
  self.m_getLabel1:setAnchorPoint(1, 0.5)
  self.m_getLabel1:pos(90, 20):addTo(self.m_imageTo1)
  self.m_getNameLabel1 = td.CreateLabel(g_LM:getBy("a00071"), nil, nil, td.OL_BLACK)
  self.m_getNameLabel1:setAnchorPoint(0.5, 0.5)
  self.m_getNameLabel1:pos(50, -10):addTo(self.m_imageTo1)
  self.m_selectSpr1 = display.newScale9Sprite("UI/scale9/xiaobingxuanzhongkuang.png", 0, 0, cc.size(100, 100))
  td.AddRelaPos(self.m_imageTo1, self.m_selectSpr1, 1)
  self.m_getLabel2 = td.CreateLabel("x1", nil, nil, td.OL_BLACK)
  self.m_getLabel2:setVisible(false)
  self.m_getLabel2:setAnchorPoint(1, 0.5)
  self.m_getLabel2:pos(90, 20):addTo(self.m_imageTo2)
  self.m_getNameLabel2 = td.CreateLabel(g_LM:getBy("a00072"), nil, nil, td.OL_BLACK)
  self.m_getNameLabel2:setVisible(false)
  self.m_getNameLabel2:setAnchorPoint(0.5, 0.5)
  self.m_getNameLabel2:pos(50, -10):addTo(self.m_imageTo2)
  self.m_selectSpr2 = display.newScale9Sprite("UI/scale9/xiaobingxuanzhongkuang.png", 0, 0, cc.size(100, 100))
  self.m_selectSpr2:setVisible(false)
  td.AddRelaPos(self.m_imageTo2, self.m_selectSpr2, 1)
  local costNum = ComposeBookCost[self.m_composeIndex]
  self.m_cost = td.CreateLabel("x" .. costNum, nil, nil, td.OL_BLACK)
  self.m_cost:setAnchorPoint(1, 0.5)
  self.m_cost:pos(90, 20):addTo(self.m_imageFrom)
  if costNum > self.m_num then
    td.EnableButton(self.m_yesBtn, false)
    self.m_cost:setColor(td.RED)
  else
    td.EnableButton(self.m_yesBtn, true)
    self.m_cost:setColor(td.WHITE)
  end
  td.BtnAddTouch(self.m_imageTo1, function()
    self.m_composeIndex = 1
    local costNum = ComposeBookCost[self.m_composeIndex]
    if costNum > self.m_num then
      td.EnableButton(self.m_yesBtn, false)
      self.m_cost:setColor(td.RED)
    else
      td.EnableButton(self.m_yesBtn, true)
      self.m_cost:setColor(display.COLOR_WHITE)
    end
    self.m_getLabel1:setVisible(true)
    self.m_getLabel2:setVisible(false)
    self.m_getNameLabel1:setVisible(true)
    self.m_getNameLabel2:setVisible(false)
    self.m_selectSpr1:setVisible(true)
    self.m_selectSpr2:setVisible(false)
    self.m_cost:setString("x" .. costNum)
    self.m_imageTo1:setColor(cc.c3b(255, 255, 255))
    self.m_imageTo2:setColor(cc.c3b(100, 100, 100))
  end)
  td.BtnAddTouch(self.m_imageTo2, function()
    self.m_composeIndex = 2
    local costNum = ComposeBookCost[self.m_composeIndex]
    if costNum > self.m_num then
      td.EnableButton(self.m_yesBtn, false)
      self.m_cost:setColor(td.RED)
    else
      td.EnableButton(self.m_yesBtn, true)
      self.m_cost:setColor(display.COLOR_WHITE)
    end
    self.m_getLabel1:setVisible(false)
    self.m_getLabel2:setVisible(true)
    self.m_getNameLabel1:setVisible(false)
    self.m_getNameLabel2:setVisible(true)
    self.m_selectSpr1:setVisible(false)
    self.m_selectSpr2:setVisible(true)
    self.m_cost:setString("x" .. costNum)
    self.m_imageTo1:setColor(cc.c3b(100, 100, 100))
    self.m_imageTo2:setColor(cc.c3b(255, 255, 255))
  end)
end
function ItemDetailUI:InitSubUICompose(useType)
  self.m_subUI = cc.uiloader:load("CCS/ItemSubCompose1.csb")
  self:InitSubButton(useType)
  self.m_imageFrom = cc.uiloader:seekNodeByName(self.m_subUI, "kuang_1")
  self.m_imageTo1 = cc.uiloader:seekNodeByName(self.m_subUI, "kuang_2")
  local comInfo = GetComposeConfig(self.m_itemInfo.id)
  local itemInfo = ItemInfoManager:GetInstance():GetItemInfo(comInfo.itemId)
  local iconTo = cc.uiloader:seekNodeByName(self.m_subUI, "Image_icon_to")
  iconTo:loadTexture(itemInfo.icon .. td.PNG_Suffix)
  self.m_getLabel1 = td.CreateLabel("x1", nil, nil, td.OL_BLACK)
  self.m_getLabel1:setAnchorPoint(1, 0.5)
  self.m_getLabel1:pos(90, 20):addTo(self.m_imageTo1)
  self.m_getNameLabel1 = td.CreateLabel(itemInfo.name, nil, nil, td.OL_BLACK)
  self.m_getNameLabel1:setAnchorPoint(0.5, 0.5)
  self.m_getNameLabel1:pos(50, -10):addTo(self.m_imageTo1)
  self.m_cost = td.CreateLabel("x" .. comInfo.num, labelColor, nil, td.OL_BLACK)
  self.m_cost:setAnchorPoint(1, 0.5)
  self.m_cost:pos(90, 20):addTo(self.m_imageFrom)
  if comInfo.num > self.m_num then
    td.EnableButton(self.m_yesBtn, false)
    self.m_cost:setColor(td.RED)
  else
    td.EnableButton(self.m_yesBtn, true)
    self.m_cost:setColor(td.WHITE)
  end
end
function ItemDetailUI:InitSubUIBreak(useType)
  self.m_subUI = cc.uiloader:load("CCS/ItemSubBreak.csb")
  self:InitSubButton(useType)
  self.m_imageFrom = cc.uiloader:seekNodeByName(self.m_subUI, "kuang_1")
  self.m_imageTo1 = cc.uiloader:seekNodeByName(self.m_subUI, "kuang_2")
  self.m_imageFrom = cc.uiloader:seekNodeByName(self.m_subUI, "kuang_1")
  self.m_imageTo1 = cc.uiloader:seekNodeByName(self.m_subUI, "kuang_2")
  local breakInfo = GetBreakConfig(self.m_itemInfo.id)
  local itemInfo = ItemInfoManager:GetInstance():GetItemInfo(breakInfo.itemId)
  local iconTo = cc.uiloader:seekNodeByName(self.m_subUI, "Image_icon_to")
  iconTo:loadTexture(itemInfo.icon .. td.PNG_Suffix)
  self.m_getLabel1 = td.CreateLabel(breakInfo.num.min .. "~" .. breakInfo.num.max, nil, nil, td.OL_BLACK)
  self.m_getLabel1:setAnchorPoint(1, 0.5)
  self.m_getLabel1:pos(90, 20):addTo(self.m_imageTo1)
  self.m_getNameLabel1 = td.CreateLabel(itemInfo.name, nil, nil, td.OL_BLACK)
  self.m_getNameLabel1:setAnchorPoint(0.5, 0.5)
  self.m_getNameLabel1:pos(50, -10):addTo(self.m_imageTo1)
  self.m_cost = td.CreateLabel("x1", nil, nil, td.OL_BLACK)
  self.m_cost:setAnchorPoint(1, 0.5)
  self.m_cost:pos(90, 20):addTo(self.m_imageFrom)
end
function ItemDetailUI:DoEvent(useType)
  if self.m_bIsSending then
    return
  end
  local data = self.m_itemInfo
  if td.ItemUseType.ComposeBook == useType then
    local costNum = ComposeBookCost[self.m_composeIndex]
    if costNum > self.m_num then
      td.alertErrorMsg(td.ErrorCode.MATERIAL_NOT_ENOUGH)
    else
      self:SendHeChengItemRequest(data.id, self.m_composeIndex)
    end
  elseif td.ItemUseType.Use == useType then
    self:SendUseItemRequest(data.id)
  elseif td.ItemUseType.Break == useType then
    self:FenJieItemRequest(data.id)
  elseif td.ItemUseType.Open == useType then
    self:OpenBoxRequest(data.id)
  elseif td.ItemUseType.Learn == useType then
    if not ItemDetailUI.IsCanLearn(data.id) then
      td.alertErrorMsg(td.ErrorCode.LEARN_ALREADY)
    else
      self:LearnSkillRequest(data.id)
    end
  elseif td.ItemUseType.Compose == useType then
    local comInfo = GetComposeConfig(self.m_itemInfo.id)
    if comInfo.num > self.m_num then
      td.alertErrorMsg(td.ErrorCode.MATERIAL_NOT_ENOUGH)
    else
      self:ComposeStoneRequest(data.id)
    end
  elseif td.ItemUseType.ComposeBook2 == useType then
    local comInfo = GetComposeConfig(self.m_itemInfo.id)
    if comInfo.num > self.m_num then
      td.alertErrorMsg(td.ErrorCode.MATERIAL_NOT_ENOUGH)
    else
      self:ComposeSkillRequest(data.id)
    end
  else
    if self.m_subUI then
      self.m_subUI:removeFromParent()
      self.m_subUI = nil
    end
    self.m_conBg:setVisible(true)
  end
end
function ItemDetailUI.IsCanLearn(itemId)
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
function ItemDetailUI:Close()
  self:setVisible(false)
  self.m_backpackLayer:OnInitItemSuccess()
end
function ItemDetailUI:SendUseItemRequest(targetId)
  self.m_bIsSending = true
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.UseItem_req
  Msg.sendData = {itemId = targetId}
  tdRequest:Send(Msg)
end
function ItemDetailUI:SendHeChengItemRequest(targetId, hechengType)
  self.m_bIsSending = true
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.HeChengSkill1
  Msg.sendData = {itemId = targetId, type = hechengType}
  tdRequest:Send(Msg)
end
function ItemDetailUI:FenJieItemRequest(targetId)
  self.m_bIsSending = true
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.FenJieItem_req
  Msg.sendData = {itemId = targetId}
  tdRequest:Send(Msg)
end
function ItemDetailUI:OpenBoxRequest(targetId)
  self.m_bIsSending = true
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.OpenBox_req
  Msg.sendData = {itemId = targetId}
  tdRequest:Send(Msg)
end
function ItemDetailUI:LearnSkillRequest(targetId)
  self.m_bIsSending = true
  local data = {}
  data.item_id = targetId
  local Msg = {}
  Msg.msgType = td.RequestID.LearnSkill
  Msg.sendData = data
  TDHttpRequest:getInstance():Send(Msg)
end
function ItemDetailUI:ComposeStoneRequest(targetId)
  self.m_bIsSending = true
  local tdRequest = TDHttpRequest:getInstance()
  local data = {}
  data.itemId = targetId
  if targetId == 20107 then
    data.type = 3
  elseif targetId == 20108 then
    data.type = 4
  elseif targetId == 20109 then
    data.type = 5
  else
    td.alertDebug("item id error:" .. targetId)
    return
  end
  local Msg = {}
  Msg.msgType = td.RequestID.HeChengItem_req
  Msg.sendData = data
  tdRequest:Send(Msg)
end
function ItemDetailUI:ComposeSkillRequest(targetId)
  self.m_bIsSending = true
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.HeChengSkill2
  Msg.sendData = {item_id = targetId}
  tdRequest:Send(Msg)
end
function ItemDetailUI:UseItemRequestCallback(data)
  self.m_bIsSending = false
  if td.ResponseState.Success == data.state then
    local config = require("app.config.property_item")
    if config[1][self.m_itemInfo.id] then
      StrongInfoManager:GetInstance():sendGetHeroRequest()
      td.alert(g_LM:getBy(config[1][self.m_itemInfo.id]))
    elseif config[2][self.m_itemInfo.id] then
      StrongInfoManager:GetInstance():SendCampRequest()
      td.alert(g_LM:getBy(config[2][self.m_itemInfo.id]))
    end
    self:Close()
  end
end
function ItemDetailUI:HeChengSkillRequestCallback(data)
  self.m_bIsSending = false
  if td.ResponseState.Success == data.state then
    local parent = self.m_composeIndex == 1 and self.m_imageTo1 or self.m_imageTo2
    td.CreateUIEffect(parent, "Spine/UI_effect/UI_wupinhecheng_01", {
      cb = function()
        self:Close()
        local itemid, _num = 0, 0
        if data.itemProto and 0 < #data.itemProto then
          for k, value in ipairs(data.itemProto) do
            if 0 < value.num then
              itemid = value.itemId
              _num = value.num
              break
            end
          end
        end
        InformationManager:GetInstance():ShowInfoDlg({
          type = td.ShowInfo.Item,
          items = {
            [itemid] = _num
          }
        })
      end
    })
  end
end
function ItemDetailUI:HeChengItemRequestCallback(data)
  self.m_bIsSending = false
  if td.ResponseState.Success == data.state then
    td.CreateUIEffect(self.m_imageTo1, "Spine/UI_effect/UI_wupinhecheng_01", {
      cb = function()
        self:Close()
        local itemid, _num = 0, 0
        if data.itemProto and 0 < #data.itemProto then
          for k, value in ipairs(data.itemProto) do
            if 0 < value.num then
              itemid = value.itemId
              _num = value.num
              break
            end
          end
        end
        InformationManager:GetInstance():ShowInfoDlg({
          type = td.ShowInfo.Item,
          items = {
            [itemid] = _num
          }
        })
      end
    })
  end
end
function ItemDetailUI:FenJieItemRequestCallback(data)
  self.m_bIsSending = false
  if td.ResponseState.Success == data.state then
    td.CreateUIEffect(self.m_imageFrom, "Spine/UI_effect/UI_fenjie_01", {
      cb = function()
        self:Close()
      end
    })
  end
end
function ItemDetailUI:OpenBoxRequestCallback(data)
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
    self:Close()
    if self.m_itemInfo.id == 30000 then
      InformationManager:GetInstance():ShowOpenBox(items)
    end
  end
end
function ItemDetailUI:LearnSkillCallback(data)
  self.m_bIsSending = false
  if td.ResponseState.Success == data.state then
    UserDataManager:GetInstance():UpdateHeroSkillData(data.skillProto)
    td.alertDebug("\229\173\166\228\185\160\230\136\144\229\138\159")
    self:Close()
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    InformationManager:GetInstance():ShowInfoDlg({
      type = td.ShowInfo.Skill,
      items = {
        [data.skillProto.skill_id] = 1
      }
    })
  end
end
function ItemDetailUI:CheckGuide(event)
  local GuideManager = require("app.GuideManager")
  GuideManager.H_GuideUI(td.UIModule.ItemDetail, self.m_uiRoot)
end
return ItemDetailUI
