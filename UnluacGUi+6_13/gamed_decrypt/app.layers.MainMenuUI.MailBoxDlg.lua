local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local InformationManager = require("app.layers.InformationManager")
local MailBoxDlg = class("MailBoxDlg", BaseDlg)
local ITEM_SIZE = cc.size(380, 80)
local MAIL_ICON = {
  NORMAL = "UI/mailbox/xinfeng1_icon.png",
  READED = "UI/mailbox/xinfeng2_icon.png",
  AFFIX = "UI/mailbox/fujian_icon.png"
}
function MailBoxDlg:ctor()
  MailBoxDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Mail
  self.m_hasMail = false
  self.m_getAllBtnEnable = false
  self.m_getRewardTag = false
  self.m_items = {}
  self:InitUI()
  self:AddEvents()
end
function MailBoxDlg:onEnter()
  MailBoxDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetReward_req, handler(self, self.GetRewardRequestCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetAllReward_req, handler(self, self.GetAllRewardRequestCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.DeleteMail, handler(self, self.DeleteRequestCallback))
  self:PlayEnterAnim(function()
    if g_MC:IsModuleUpdate(self.m_uiId) then
      UserDataManager:GetInstance():SendGetMailsRequest()
      g_MC:SetModuleUpdate(self.m_uiId, false)
    else
      self:GetMailsRequestCallback()
    end
  end)
end
function MailBoxDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetReward_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetAllReward_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.DeleteMail)
  MailBoxDlg.super.onExit(self)
end
function MailBoxDlg:InitUI()
  self:LoadUI("CCS/MailBoxDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_youxiang.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.m_bg:setOpacity(0)
  self.m_conBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_conBg")
  self.m_conBg:setVisible(false)
  local label = cc.uiloader:seekNodeByName(self.m_bg, "Text_2")
  label:setString(g_LM:getBy("a00269") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_3")
  label:setString(g_LM:getBy("a00379") .. ":")
  label = cc.uiloader:seekNodeByName(self.m_bg, "Text_4")
  label:setString(g_LM:getBy("a00380") .. ":")
  self.labelSender = cc.uiloader:seekNodeByName(self.m_conBg, "Text_sender")
  self.labelTime = cc.uiloader:seekNodeByName(self.m_conBg, "Text_time")
  self.labelAffx = cc.uiloader:seekNodeByName(self.m_conBg, "Text_4")
  self.m_awardBg = cc.uiloader:seekNodeByName(self.m_conBg, "Panel_award")
  self.scrollView = cc.uiloader:seekNodeByName(self.m_uiRoot, "ScrollView_1")
  self.scrollView:setBounceEnabled(true)
  local listView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(25, 100, 370, 410),
    touchOnContent = false,
    scale = self.m_scale
  })
  listView:setAnchorPoint(cc.p(0, 0))
  listView:addTo(self.m_bg)
  listView:onTouch(function(event)
    if event.name == "clicked" and event.item then
      self:OnItemClicked(event.itemPos)
    end
  end)
  self.m_UIListView = listView
  self.m_btnGetAll = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_getAll_2")
  td.BtnSetTitle(self.m_btnGetAll, g_LM:getBy("a00007"))
  td.BtnAddTouch(self.m_btnGetAll, function()
    if self.m_getAllBtnEnable then
      self:SendGetAllRewardRequest()
    end
  end, nil, td.ButtonEffectType.Long)
  td.EnableButton(self.m_btnGetAll, false)
  self.m_btnGet = cc.uiloader:seekNodeByName(self.m_conBg, "Button_get_4")
  td.BtnSetTitle(self.m_btnGet, g_LM:getBy("a00052"))
  td.BtnAddTouch(self.m_btnGet, function()
    self:SendGetRewardRequest(self.curMailData.id, 1)
  end, nil, td.ButtonEffectType.Long)
  self.m_btnDel = cc.uiloader:seekNodeByName(self.m_conBg, "Button_dele_4")
  td.BtnSetTitle(self.m_btnDel, g_LM:getBy("a00126"))
  td.BtnAddTouch(self.m_btnDel, function()
    if self.curMailData.type == 1 then
      td.alert(g_LM:getBy("a00345"))
    else
      self:SendDeleteRequest(self.curMailData.id)
    end
  end, nil, td.ButtonEffectType.Long)
end
function MailBoxDlg:PlayEnterAnim(cb)
  local panelDeco = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_decorations")
  local btmLight = cc.uiloader:seekNodeByName(panelDeco, "Image_btmLight")
  btmLight:runAction(cc.EaseBackOut:create(cca.moveBy(0.6, 0, -530)))
  self.m_bg:runAction(cca.seq({
    cca.delay(0.4),
    cca.fadeIn(0.2),
    cca.cb(cb)
  }))
end
function MailBoxDlg:initMailList()
  self.m_UIListView:removeAllItems()
  self.m_items = {}
  self.m_hasMail = false
  for k, v in pairs(self.m_mail_list) do
    local item = self:CreateItem(v)
    self.m_UIListView:addItem(item)
    table.insert(self.m_items, item)
  end
  self.m_UIListView:reload()
  self.seleSpr = nil
  if #self.m_mail_list > 0 then
    self.m_hasMail = true
    self:OnItemClicked(1)
  else
    self.m_conBg:setVisible(false)
  end
  td.EnableButton(self.m_btnGetAll, self.m_getAllBtnEnable)
end
function MailBoxDlg:CreateItem(mailData)
  local itemBg = display.newScale9Sprite("UI/scale9/lankuang.png", 0, 0, ITEM_SIZE)
  itemBg:setScale(self.m_scale)
  local fileName
  if 1 == mailData.type then
    if mailData.affix and mailData.affix ~= "" then
      fileName = MAIL_ICON.AFFIX
    else
      fileName = MAIL_ICON.NORMAL
    end
  else
    fileName = MAIL_ICON.READED
  end
  local iconSpr = display.newSprite(fileName)
  iconSpr:setName("icon")
  td.AddRelaPos(itemBg, iconSpr, 1, cc.p(0.1, 0.5))
  local senderLabel = td.CreateLabel(g_LM:getBy("a00418") .. mailData.title, td.WHITE, 18)
  senderLabel:align(display.LEFT_CENTER, 80, ITEM_SIZE.height * 0.7):addTo(itemBg)
  local timeLabel = td.CreateLabel(timeStampToStr(mailData.time), td.WHITE, 18)
  timeLabel:align(display.LEFT_CENTER, 80, ITEM_SIZE.height * 0.3):addTo(itemBg)
  local item = self.m_UIListView:newItem(itemBg)
  item:setItemSize(ITEM_SIZE.width * self.m_scale, ITEM_SIZE.height * self.m_scale)
  return item
end
function MailBoxDlg:CreateAwards(awards)
  self.m_awardBg:removeAllChildren()
  local rewards = string.split(awards, "|")
  for k, value in pairs(rewards) do
    local item = string.split(value, "#")
    local itemId, num = tonumber(item[1]), tonumber(item[2])
    if itemId == 1 then
      itemId = num
      num = 1
    end
    local listItembg = display.newScale9Sprite("UI/backpack/wupinkuang.png", 0, 0, cc.size(135, 165), cc.rect(17, 20, 100, 4))
    listItembg:pos(120 + (k - 1) * 100, 40)
    listItembg:scale(0.55)
    listItembg:addTo(self.m_awardBg)
    local icon = td.CreateItemIcon(itemId, true)
    td.AddRelaPos(listItembg, icon, 1, cc.p(0.5, 0.62))
    local numLabel = td.CreateLabel("x" .. num, td.WHITE, 24)
    td.AddRelaPos(listItembg, numLabel, 1, cc.p(0.5, 0.15))
  end
end
function MailBoxDlg:OnItemClicked(index)
  self.m_conBg:setVisible(true)
  self.m_itemIndex = index
  self.curMailData = self.m_mail_list[index]
  local curItem = self.m_items[self.m_itemIndex]
  if self.seleSpr then
    self.seleSpr:removeFromParent()
    self.seleSpr = nil
  end
  self.seleSpr = display.newScale9Sprite("UI/scale9/huangkuang.png", 0, 0, ITEM_SIZE)
  td.AddRelaPos(curItem:getContent(), self.seleSpr)
  self.labelSender:setString(self.curMailData.fname)
  self.labelTime:setString(timeStampToStr(self.curMailData.time))
  if self.labelCon then
    self.labelCon:removeFromParent()
    self.labelCon = nil
  end
  self.labelCon = cc.ui.UILabel.new({
    text = string.urldecode(self.curMailData.content),
    font = td.DEFAULT_FONT,
    size = 18,
    color = td.WHITE,
    align = cc.ui.TEXT_ALIGN_LEFT,
    valign = cc.ui.TEXT_VALIGN_TOP,
    dimensions = cc.size(600, 0)
  })
  local height = math.max(self.scrollView:getContentSize().height, self.labelCon:getContentSize().height)
  self.scrollView:setInnerContainerSize(cc.size(600, height))
  self.scrollView:addChild(self.labelCon)
  self.labelCon:align(display.LEFT_TOP, 0, height)
  if self.curMailData.affix and self.curMailData.affix ~= "" then
    if self.curMailData.type == 1 then
      self.m_btnGet:setVisible(true)
      self.labelAffx:setVisible(true)
      self.m_awardBg:setVisible(true)
      self:CreateAwards(self.curMailData.affix)
    else
      self.m_btnGet:setVisible(false)
      self.labelAffx:setVisible(false)
      self.m_awardBg:setVisible(false)
    end
  else
    self.m_btnGet:setVisible(false)
    self.labelAffx:setVisible(false)
    self.m_awardBg:setVisible(false)
    if self.curMailData.type == 1 then
      self:SendGetRewardRequest(self.curMailData.id, 0)
    end
  end
end
function MailBoxDlg:ShowReward(id)
  local bHero = false
  local function getAffix(affix)
    local awardItems = {}
    local tmp = string.split(affix, "|")
    for i, var in ipairs(tmp) do
      local tmp1 = string.split(var, "#")
      if tonumber(tmp1[1]) == 1 then
        awardItems[tonumber(tmp1[2])] = 1
        bHero = true
      else
        awardItems[tonumber(tmp1[1])] = tonumber(tmp1[2])
      end
    end
    InformationManager:GetInstance():ShowInfoDlg({
      type = td.ShowInfo.Item,
      items = awardItems
    })
  end
  if id then
    if self.m_mail_list[id].affix and self.m_mail_list[id].affix ~= "" then
      getAffix(self.m_mail_list[id].affix)
    end
  else
    for i, val in ipairs(self.m_mail_list) do
      if val.type ~= 0 and val.affix and val.affix ~= "" then
        getAffix(val.affix)
      end
    end
  end
  if bHero then
    UserDataManager:GetInstance():SendGetHeroRequest()
    UserDataManager:GetInstance():SendGetSkillsRequest()
  end
end
function MailBoxDlg:refreshMailAllGetted()
  for k, value in ipairs(self.m_mail_list) do
    if 1 == value.type and value.affix then
      value.type = 0
    end
  end
  self:RefreshAllGetBtn()
  self:initMailList()
end
function MailBoxDlg:RefreshAllGetBtn()
  self.m_getAllBtnEnable = false
  for i, v in ipairs(self.m_mail_list) do
    if v.type == 1 and v.affix and v.affix ~= "" then
      self.m_getAllBtnEnable = true
      break
    end
  end
  td.EnableButton(self.m_btnGetAll, self.m_getAllBtnEnable)
end
function MailBoxDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_hasMail then
      if self.m_UIListView:isTouchInViewRect({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.m_UIListView:onTouch_({
          name = "began",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
        return true
      end
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_hasMail then
      if self.m_UIListView:isTouchInViewRect({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.m_UIListView:onTouch_({
          name = "moved",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
      end
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    if self.m_hasMail then
      self.m_UIListView:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.MAIL_DATA_INITED, handler(self, self.GetMailsRequestCallback))
end
function MailBoxDlg:GetMailsRequestCallback(data)
  self.m_mail_list = UserDataManager:GetInstance():GetMailsData()
  print("\233\130\174\228\187\182\230\149\176\233\135\143\239\188\154" .. #self.m_mail_list)
  self:RefreshAllGetBtn()
  self:initMailList()
end
function MailBoxDlg:SendGetRewardRequest(inId, dtype)
  local Msg = {}
  Msg.msgType = td.RequestID.GetReward_req
  Msg.sendData = {id = inId, type = dtype}
  Msg.cbData = clone(Msg.sendData)
  TDHttpRequest:getInstance():Send(Msg)
end
function MailBoxDlg:GetRewardRequestCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    if cbData.type == 1 then
      for key, val in ipairs(self.m_mail_list) do
        if val.id == cbData.id then
          self:ShowReward(key)
          break
        end
      end
    end
    td.setTexture(self.m_items[self.m_itemIndex]:getContent():getChildByName("icon"), MAIL_ICON.READED)
    self.curMailData.type = 0
    self:RefreshAllGetBtn()
    self:OnItemClicked(self.m_itemIndex)
  else
    td.alertDebug("\233\162\134\229\143\150\229\164\177\232\180\165")
  end
end
function MailBoxDlg:SendGetAllRewardRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetAllReward_req
  Msg.sendData = nil
  TDHttpRequest:getInstance():Send(Msg)
end
function MailBoxDlg:GetAllRewardRequestCallback(data)
  if data.state == td.ResponseState.Success then
    td.alertDebug("\229\133\168\233\131\168\233\162\134\229\143\150\230\136\144\229\138\159")
    self:ShowReward()
    for key, var in ipairs(self.m_mail_list) do
      var.type = 0
    end
    self:RefreshAllGetBtn()
    self:initMailList()
  else
    td.alertDebug("\233\162\134\229\143\150\229\164\177\232\180\165")
  end
end
function MailBoxDlg:SendDeleteRequest(inId)
  local Msg = {}
  Msg.msgType = td.RequestID.DeleteMail
  Msg.sendData = {
    id = {inId}
  }
  Msg.cbData = clone(Msg.sendData)
  TDHttpRequest:getInstance():Send(Msg)
end
function MailBoxDlg:DeleteRequestCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    for i, mailId in ipairs(cbData.id) do
      for j = #self.m_mail_list, 1, -1 do
        if self.m_mail_list[j].id == mailId then
          table.remove(self.m_mail_list, j)
          break
        end
      end
    end
    self:initMailList()
  else
    td.alertDebug("\229\136\160\233\153\164\229\164\177\232\180\165")
  end
end
return MailBoxDlg
