local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local BuffManager = require("app.buff.BuffManager")
local DlgWidth = 300
local DlgHeight = 230
local ActorDetailDlg = class("ActorDetailDlg", function()
  return display.newScale9Sprite("UI/scale9/shang_dikuang.png", 0, 0, cc.size(DlgWidth, DlgHeight))
end)
function ActorDetailDlg:ctor()
  self.m_pActor = nil
  self.m_pAtkLabel = nil
  self.m_pHpLabel = nil
  self.m_pASpLabel = nil
  self.m_pDefLabel = nil
  self.m_pNameLabel = nil
  self.m_pPriceLabel = nil
  self.m_pPriceIcon = nil
  self.m_pBtn = nil
  self.m_bShowCost = true
  self:InitUI()
  self:setNodeEventEnabled(true)
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
    self:Update(dt)
  end)
end
function ActorDetailDlg:onEnter()
  self.m_listener = cc.EventListenerCustom:create(td.ACTOR_REMOVE, handler(self, self.RemoveCallback))
  self:getEventDispatcher():addEventListenerWithFixedPriority(self.m_listener, 1)
  self:scheduleUpdate()
end
function ActorDetailDlg:onExit()
  self:unscheduleUpdate()
  self:getEventDispatcher():removeEventListener(self.m_listener)
end
function ActorDetailDlg:RemoveCallback(event)
  local tag = tonumber(event:getDataString())
  if tag == self.m_actorTag then
    self:removeFromParent()
    self.m_pActor = nil
  end
end
function ActorDetailDlg:Update(dt)
  if self.m_pActor then
    self.m_pAtkLabel:setString(math.floor(self.m_pActor:GetAttackValue()))
    self.m_pHpLabel:setString(math.floor(self.m_pActor:GetCurHp()))
    self.m_pASpLabel:setString(math.floor(60 / self.m_pActor:GetAttackSpeed()))
    self.m_pDefLabel:setString(math.floor(self.m_pActor:GetDefense()))
    if self.m_bShowCost then
      self.m_pPriceLabel:setString(self:GetPrice())
      if self.m_pActor:IsCharmed() and self.m_pBtn:isEnabled() then
        self.m_pBtn:setEnabled(false)
        self.m_pBtn:setColor(td.BTN_PRESSED_COLOR)
      elseif not self.m_pActor:IsCharmed() and not self.m_pBtn:isEnabled() then
        self.m_pBtn:setEnabled(true)
        self.m_pBtn:setColor(cc.c3b(255, 255, 255))
      end
    end
  end
end
function ActorDetailDlg:SetData(iTag)
  self.m_actorTag = iTag
  self.m_pActor = ActorManager:GetInstance():FindActorByTag(iTag)
  self.m_pAtkLabel:setString(math.floor(self.m_pActor:GetAttackValue()))
  self.m_pHpLabel:setString(math.floor(self.m_pActor:GetCurHp()))
  self.m_pASpLabel:setString(math.floor(60 / self.m_pActor:GetAttackSpeed()))
  self.m_pDefLabel:setString(math.floor(self.m_pActor:GetDefense()))
  if self:CanSell() then
    self.m_pPriceLabel:setString(self:GetPrice())
  else
    self.m_bShowCost = false
    self.m_pBtn:setVisible(false)
    self.m_pPriceLabel:setVisible(false)
    self.m_pPriceIcon:setVisible(false)
  end
  local iconSpr = td.CreateCareerIcon(self.m_pActor:GetCareerType())
  if iconSpr then
    iconSpr:pos(30, 190):scale(0.5):addTo(self)
  end
  self.m_pNameLabel:setString(self.m_pActor:GetData().name)
  local profitStr = self.m_pActor:GetData().profile
  if profitStr and profitStr ~= "" then
    local tmp = string.split(profitStr, "#")
    if #tmp >= 2 then
      self.m_profileLabel:setString(tmp[1] .. "\n" .. tmp[2])
    else
      self.m_profileLabel:setString(profitStr)
    end
  end
  local pos = self.m_pActor:getParent():convertToWorldSpace(cc.p(self.m_pActor:getPosition()))
  pos.x = cc.clampf(pos.x, DlgWidth, display.width - DlgWidth)
  pos.y = cc.clampf(pos.y + 100 * td.GetAutoScale(), DlgHeight, display.height - DlgHeight)
  self:setPosition(pos.x, pos.y)
end
function ActorDetailDlg:CanSell()
  return false
end
function ActorDetailDlg:InitUI()
  self.m_pAtkLabel = td.CreateLabel("", td.WHITE, 20)
  self.m_pAtkLabel:setAnchorPoint(0, 0.5)
  self.m_pAtkLabel:setPosition(60, 130)
  self:addChild(self.m_pAtkLabel)
  self.m_pHpLabel = td.CreateLabel("", td.WHITE, 20)
  self.m_pHpLabel:setAnchorPoint(0, 0.5)
  self.m_pHpLabel:setPosition(210, 130)
  self:addChild(self.m_pHpLabel)
  self.m_pASpLabel = td.CreateLabel("", td.WHITE, 20)
  self.m_pASpLabel:setAnchorPoint(0, 0.5)
  self.m_pASpLabel:setPosition(60, 95)
  self:addChild(self.m_pASpLabel)
  self.m_pDefLabel = td.CreateLabel("", td.WHITE, 20)
  self.m_pDefLabel:setAnchorPoint(0, 0.5)
  self.m_pDefLabel:setPosition(210, 95)
  self:addChild(self.m_pDefLabel)
  self.m_pPriceLabel = td.CreateLabel("", td.LIGHT_BLUE, 22)
  self.m_pPriceLabel:setAnchorPoint(0, 0.5)
  self.m_pPriceLabel:setPosition(190, 190)
  self:addChild(self.m_pPriceLabel)
  self.m_pNameLabel = td.CreateLabel("", td.YELLOW, 22)
  self.m_pNameLabel:setAnchorPoint(0, 0.5)
  self.m_pNameLabel:setPosition(50, 190)
  self:addChild(self.m_pNameLabel)
  local icons = {
    "UI/icon/atk_icon.png",
    "UI/icon/hp_icon.png",
    "UI/icon/asp_icon.png",
    "UI/icon/def_icon.png"
  }
  local pos = {
    cc.p(40, 130),
    cc.p(180, 130),
    cc.p(40, 95),
    cc.p(180, 95)
  }
  for i = 1, 4 do
    local iconSpr = display.newSprite(icons[i])
    iconSpr:setPosition(pos[i])
    iconSpr:setScale(1.5)
    self:addChild(iconSpr)
  end
  self.m_lineSpr = display.newSprite("UI/common/fengexian1.png")
  self.m_lineSpr:setScale(1.5)
  td.AddRelaPos(self, self.m_lineSpr, 1, cc.p(0.5, 0.7))
  self.m_pPriceIcon = display.newSprite(td.FORCE_ICON)
  self.m_pPriceIcon:setScale(0.8)
  self.m_pPriceIcon:setPosition(170, 190)
  self:addChild(self.m_pPriceIcon)
  self.m_pBtn = ccui.Button:create("UI/button/maichu1_button.png", "UI/button/maichu2_button.png")
  self.m_pBtn:setScale(1)
  self.m_pBtn:setPosition(260, 195)
  self:addChild(self.m_pBtn)
  self.m_pBtn:addTouchEventListener(function(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      self:Sell()
    end
  end)
  self.m_profileLabel = td.CreateLabel("", td.YELLOW, 18, nil, nil, cc.size(260, 50))
  self.m_profileLabel:setAnchorPoint(0, 0.5)
  self.m_profileLabel:setPosition(20, 45)
  self:addChild(self.m_profileLabel)
end
function ActorDetailDlg:Sell()
  if self.m_pActor:IsDead() then
    return
  end
  GameDataManager:GetInstance():UpdateCurResCount(self:GetPrice())
  self.m_pActor:SetCurHp(0)
  self.m_pActor:OnDead()
  td.dispatchEvent(td.ACTOR_DIED, self.m_actorTag)
  self.m_pBtn:setVisible(false)
  td.dispatchEvent(td.SHOW_ACTOR_DETAIL, {tag = -1})
end
function ActorDetailDlg:GetPrice()
  local hpRatio = self.m_pActor:GetCurHp() / self.m_pActor:GetMaxHp()
  return math.ceil(0.5 * self.m_pActor:GetData().cost * math.pow(hpRatio, 1.5))
end
return ActorDetailDlg
