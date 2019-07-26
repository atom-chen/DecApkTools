local GameDataManager = require("app.GameDataManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local SoldierButton = require("app.widgets.SoldierButton")
local CampUpgradeLayer = class("CampUpgradeLayer", function()
  return display.newLayer()
end)
function CampUpgradeLayer:ctor(data, pos)
  self.m_uiId = td.UIModule.SoldierUp
  self.m_bIsAniOver = false
  self.m_data = data
  self.m_scale = td.GetAutoScale()
  self:InitUI(data, pos)
  self:setNodeEventEnabled(true)
end
function CampUpgradeLayer:InitUI(data, pos)
  pos.y = pos.y + 110 * self.m_scale
  local startX = (#data - 1) / 2 * -80 * self.m_scale
  for i, var in ipairs(data) do
    do
      local iconFile = var.image
      if var.lock then
        iconFile = "UI/common/suo_icon"
      end
      local bgFile = "UI/battle/bingyingkuang" .. var.career .. ".png"
      local size = cc.size(62, 56)
      local btn = ccui.Button:create(bgFile, bgFile, bgFile, ccui.TextureResType.plistType)
      btn:setTag(i)
      btn:setName("btn_" .. i)
      td.BtnAddTouch(btn, function(sender)
        self:BtnClicked(sender)
      end)
      btn:pos(pos.x + startX + (i - 1) * 80 * self.m_scale, pos.y):scale(0):addTo(self)
      btn:setEnabled(false)
      btn:runAction(cca.seq({
        cc.EaseBackOut:create(cca.scaleTo(0.3, 1 * self.m_scale)),
        cca.cb(function()
          if var.lock then
            btn:setEnabled(false)
          else
            btn:setEnabled(true)
          end
          if i == #data then
            self:CheckGuide()
          end
        end),
        cca.delay(0.1),
        cca.cb(function()
          self.m_bIsAniOver = true
        end)
      }))
      display.newSprite(iconFile .. td.PNG_Suffix):pos(size.width * 0.5, size.height * 0.5):addTo(btn):setTag(99)
      display.newSprite("#UI/battle/bingyingkuang.png"):pos(size.width * 0.5, size.height * 0.5):addTo(btn)
      if not var.lock then
        local tmpLabel = td.CreateLabel("" .. math.abs(var.cost), td.WHITE, 16, td.OL_BLACK)
        btn:addChild(tmpLabel, 2)
        tmpLabel:setAnchorPoint(cc.p(0.5, 0))
        tmpLabel:setPosition(size.width * 0.5, 0)
      end
    end
  end
end
function CampUpgradeLayer:onEnter()
  self:AddEvents()
end
function CampUpgradeLayer:onExit()
  self:getEventDispatcher():removeEventListener(self.m_checkGuideListener)
end
function CampUpgradeLayer:BtnClicked(_btn)
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  local _tag = _btn:getTag()
  if not self.m_iSeleBtn or self.m_iSeleBtn ~= _btn then
    if self.m_iSeleBtn then
      self.m_iSeleBtn:getChildByTag(99):show()
      self.m_iSeleBtn:getChildByTag(100):removeFromParent()
    end
    self.m_iSeleBtn = _btn
    local size = _btn:getContentSize()
    display.newSprite("UI/icon/camp/gou.png"):pos(size.width * 0.5, size.height * 0.5):addTo(self.m_iSeleBtn):setTag(100)
    self.m_iSeleBtn:getChildByTag(99):hide()
    self:ShowTip(_btn)
    return
  end
  local data = {}
  data.index = self.m_data[_tag].index
  data.upgrade = 1
  data.branch = self.m_data[_tag].branch
  local cost = self.m_data[_tag].cost
  local total = GameDataManager:GetInstance():GetCurResCount()
  if cost <= total then
    GameDataManager:GetInstance():UpdateCurResCount(-cost)
    td.dispatchEvent(td.CAMP_UPDATE_EVENT, data)
    self:Disapear()
  else
    td.alert(g_LM:getBy("a00174"), true)
  end
end
function CampUpgradeLayer:ShowTip(pSender)
  if self.m_pTip then
    self.m_pTip:removeFromParent()
    self.m_pTip = nil
  end
  local conSize = cc.size(300, 190)
  self.m_pTip = display.newScale9Sprite("UI/scale9/tipskuang.png", 0, 0, conSize)
  self.m_pTip:setScale(self.m_scale)
  local tipPos = cc.p(pSender:getPositionX(), pSender:getPositionY() + 130 * self.m_scale)
  if tipPos.x < 160 * self.m_scale then
    tipPos.x = 160 * self.m_scale
  end
  self.m_pTip:setPosition(tipPos)
  self:addChild(self.m_pTip)
  self.m_pTip:setOpacity(0)
  self.m_pTip:runAction(cca.fadeIn(0.5))
  local actorInfoMng = require("app.info.ActorInfoManager"):GetInstance()
  local tag = pSender:getTag()
  local soldierInfo = actorInfoMng:GetSoldierInfo(self.m_data[tag].soldierId)
  local iconSpr = td.CreateCareerIcon(soldierInfo.career)
  iconSpr:scale(0.5)
  local nameLabel = td.RichText({
    {
      type = 1,
      str = soldierInfo.name,
      color = td.LIGHT_GREEN,
      size = 18
    },
    {type = 3, node = iconSpr}
  })
  nameLabel:setAnchorPoint(0, 0.5)
  nameLabel:setPosition(20, conSize.height - 20)
  nameLabel:addTo(self.m_pTip)
  local line = display.newSprite("UI/common/fengexian.png")
  line:setScaleX(conSize.width * 0.9)
  line:pos(conSize.width / 2, conSize.height - 40):addTo(self.m_pTip)
  local spineBg = display.newSprite("UI/scale9/lanse_xiaobingkuang.png")
  spineBg:scale(1.2):pos(50, conSize.height - 83):addTo(self.m_pTip)
  local spine = SkeletonUnit:create(soldierInfo.image)
  spine:PlayAni("stand")
  spine:scale(0.3)
  td.AddRelaPos(spineBg, spine, 1, cc.p(0.5, 0.2))
  local posY = conSize.height - 45
  local tmp1 = string.split(soldierInfo.desc, "#")
  local textData = {}
  for i, text in ipairs(tmp1) do
    local label
    if i % 2 == 1 then
      label = td.CreateLabel(text, td.WHITE, 16, nil, nil, cc.size(200, 0))
    else
      label = td.CreateLabel(text, td.YELLOW, 16, nil, nil, cc.size(200, 0))
    end
    label:setAnchorPoint(0, 1)
    label:pos(95, posY):addTo(self.m_pTip)
    posY = posY - label:getContentSize().height
  end
end
function CampUpgradeLayer:Disapear()
  self:removeFromParent()
end
function CampUpgradeLayer:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(touch, event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bIsAniOver then
      self:Disapear()
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  listener:setSwallowTouches(true)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self.m_checkGuideListener = cc.EventListenerCustom:create(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  eventDsp:addEventListenerWithFixedPriority(self.m_checkGuideListener, 1)
end
function CampUpgradeLayer:CheckGuide(event)
  local GuideManager = require("app.GuideManager")
  GuideManager.H_GuideUI(td.UIModule.SoldierUp, self)
end
return CampUpgradeLayer
