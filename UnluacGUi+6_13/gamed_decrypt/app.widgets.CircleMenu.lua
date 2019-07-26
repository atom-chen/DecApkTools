local ActorInfoManager = require("app.info.ActorInfoManager")
local GameDataManager = require("app.GameDataManager")
local CircleMenu = class("CircleMenu", function()
  return display.newLayer()
end)
CircleMenu.btnType = {
  CAMP_JZYL = 1,
  CAMP_JZJX = 2,
  CAMP_YCJX = 3,
  CAMP_YCZS = 4,
  CAMP_FSYL = 5,
  CAMP_FSZLB = 6,
  BRANCH_1 = 7,
  BRANCH_2 = 8,
  UPGRADE = 9,
  SELL = 10
}
function CircleMenu:ctor(_index, _type, _level, _branch)
  self.m_uiId = td.UIModule.CircleMenu
  self.m_index = _index
  self.m_type = _type
  self.m_level = _level
  self.m_branch = _branch
  self.m_iSeleBtn = nil
  self.m_pTip = nil
  self.m_bIsAniOver = false
  self:InitUI()
  self:BlockTouch()
  self:setNodeEventEnabled(true)
end
function CircleMenu:onEnter()
  self.m_bg:runAction(cca.seq({
    cca.scaleTo(0.3, td.GetAutoScale()),
    cca.delay(0.1),
    cca.cb(function()
      local eventDispatcher = self:getEventDispatcher()
      self.m_checkGuideListener = cc.EventListenerCustom:create(td.CHECK_GUIDE, handler(self, self.CheckGuide))
      eventDispatcher:addEventListenerWithFixedPriority(self.m_checkGuideListener, 1)
      self:CheckGuide()
    end),
    cca.delay(0.1),
    cca.cb(function()
      self.m_bIsAniOver = true
    end)
  }))
end
function CircleMenu:onExit()
  self:getEventDispatcher():removeEventListener(self.m_checkGuideListener)
end
function CircleMenu:InitUI()
  local data = self:GetConfig()
  self.m_bg = display.newSprite("#UI/battle/huan.png"):scale(0.01):addTo(self, 1)
  self.m_bg:setName("CircleMenu")
  local r = self.m_bg:getContentSize().width / 2
  self.m_count = table.nums(data)
  for i = 1, self.m_count do
    do
      local iconFile = data[i].image
      if data[i].lock then
        iconFile = "UI/common/suo_icon"
      end
      local bgFile = "UI/battle/bingyingkuang3.png"
      if data[i].btnType ~= CircleMenu.btnType.SELL then
        bgFile = "UI/battle/bingyingkuang" .. data[i].career .. ".png"
      end
      local size = cc.size(62, 56)
      local btn = ccui.Button:create(bgFile, bgFile, bgFile, ccui.TextureResType.plistType)
      btn:setTag(data[i].btnType)
      btn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
          self:BtnClicked(sender)
        end
      end)
      btn:setPosition(r + r * math.sin(math.rad(180 + (i - 1) * 360 / self.m_count)), r + r * math.cos(math.rad(180 + (i - 1) * 360 / self.m_count)))
      btn:setEnabled(false)
      btn:addTo(self.m_bg)
      btn:runAction(cca.seq({
        cca.rotateBy(0.3, 360),
        cca.cb(function()
          if data[i].lock then
            btn:setEnabled(false)
          else
            btn:setEnabled(true)
          end
        end)
      }))
      display.newSprite(iconFile .. td.PNG_Suffix):pos(size.width * 0.5, size.height * 0.5):addTo(btn):setTag(99)
      display.newSprite("#UI/battle/bingyingkuang.png"):pos(size.width * 0.5, size.height * 0.5):addTo(btn)
      if not data[i].lock then
        local tmpLabel = td.CreateLabel("" .. math.abs(data[i].cost), td.WHITE, 16, td.OL_BLACK)
        btn:addChild(tmpLabel, 2)
        tmpLabel:setAnchorPoint(cc.p(0.5, 0))
        tmpLabel:setPosition(size.width * 0.5, 0)
      end
    end
  end
end
function CircleMenu:ShowTip(bIsCurrent)
  local conSize = cc.size(300, 190)
  if self.m_pTip then
    self.m_pTip:removeAllChildren()
  else
    self.m_pTip = display.newScale9Sprite("UI/scale9/tipskuang.png", 0, 0, conSize)
    self.m_pTip:setScale(td.GetAutoScale())
    if self.m_bg:getPositionX() > display.width / 2 then
      self.m_pTip:setPosition(self.m_bg:getPositionX() - 250 * td.GetAutoScale(), self.m_bg:getPositionY())
    else
      self.m_pTip:setPosition(self.m_bg:getPositionX() + 250 * td.GetAutoScale(), self.m_bg:getPositionY())
    end
    self:addChild(self.m_pTip)
    self.m_pTip:setOpacity(0)
    self.m_pTip:runAction(cca.fadeIn(0.5))
  end
  local actorInfoMng = require("app.info.ActorInfoManager"):GetInstance()
  local soldierInfo
  if bIsCurrent then
    local campInfo = actorInfoMng:GetCampInfo(self.m_type)
    if self.m_level == 1 or self.m_level == 2 then
      soldierInfo = actorInfoMng:GetSoldierInfo(campInfo["level" .. self.m_level .. "_role"])
    elseif self.m_level == 3 then
      soldierInfo = actorInfoMng:GetSoldierInfo(campInfo["level3_branch" .. self.m_branch])
    else
      soldierInfo = actorInfoMng:GetSoldierInfo(campInfo["level4_final" .. self.m_branch])
    end
  else
    local btnType = self.m_iSeleBtn:getTag()
    if self.m_type == -1 then
      local campInfo = actorInfoMng:GetCampInfo(btnType)
      soldierInfo = actorInfoMng:GetSoldierInfo(campInfo.level1_role)
    else
      local campInfo = actorInfoMng:GetCampInfo(self.m_type)
      if self.m_level == 1 then
        soldierInfo = actorInfoMng:GetSoldierInfo(campInfo.level2_role)
      elseif self.m_level == 2 then
        if btnType == CircleMenu.btnType.BRANCH_1 then
          soldierInfo = actorInfoMng:GetSoldierInfo(campInfo["level3_branch" .. 1])
        else
          soldierInfo = actorInfoMng:GetSoldierInfo(campInfo["level3_branch" .. 2])
        end
      elseif self.m_level == 3 then
        soldierInfo = actorInfoMng:GetSoldierInfo(campInfo["level4_final" .. self.m_branch])
      end
    end
  end
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
function CircleMenu:Disapear()
  if self.m_pTip then
    self.m_pTip:removeFromParent()
    self.m_pTip = nil
  end
  local bgActTime = 0.3
  self.m_bg:runAction(cca.spawn({
    cca.rotateBy(bgActTime, -270),
    cca.scaleTo(bgActTime, 0.01)
  }))
  local actions = {
    cca.delay(bgActTime),
    cca.callFunc(function()
      self:removeFromParent()
    end)
  }
  self:runAction(cca.seq(actions))
  td.dispatchEvent(td.BUIDING_MENU_EVENT, {
    index = self.m_index,
    hide = 1
  })
end
function CircleMenu:GetConfig()
  local actorInfoMng = ActorInfoManager:GetInstance()
  local homeLevel = GameDataManager:GetInstance():GetHomeLevel()
  local data = {}
  if self.m_type == -1 then
    for i = 1, 6 do
      local campInfo = actorInfoMng:GetCampInfo(i)
      local bIsForbidden = GameDataManager:GetInstance():IsCampForbidden(i)
      local record = {
        btnType = i,
        image = "UI/icon/camp/bingying_" .. i,
        scale = 1,
        cost = campInfo.buildCost,
        lock = bIsForbidden,
        career = campInfo.career
      }
      table.insert(data, record)
    end
  else
    local campInfo = actorInfoMng:GetCampInfo(self.m_type)
    table.insert(data, {
      btnType = CircleMenu.btnType.SELL,
      image = "UI/icon/camp/maichu",
      scale = 1,
      cost = -campInfo["recyclingClass" .. self.m_level]
    })
  end
  return data
end
function CircleMenu:GetCost(_type, _isSell)
  local cost = 0
  local campInfo = ActorInfoManager:GetInstance():GetCampInfo(_type)
  if _isSell then
    cost = 0 - campInfo["recyclingClass" .. self.m_level]
  elseif self.m_level == 0 then
    cost = campInfo.buildCost
  else
    cost = campInfo["levelup" .. self.m_level]
  end
  return cost
end
function CircleMenu:BtnClicked(_btn)
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  local _tag = _btn:getTag()
  local nextType = self.m_type
  local bIsSell = false
  local data = {}
  data.index = self.m_index
  if _tag ~= CircleMenu.btnType.SELL and (not self.m_iSeleBtn or self.m_iSeleBtn ~= _btn) then
    if self.m_iSeleBtn then
      self.m_iSeleBtn:getChildByTag(99):show()
      self.m_iSeleBtn:getChildByTag(100):removeFromParent()
    end
    self.m_iSeleBtn = _btn
    local size = _btn:getContentSize()
    display.newSprite("UI/icon/camp/gou.png"):pos(size.width * 0.5, size.height * 0.5):addTo(self.m_iSeleBtn):setTag(100)
    self.m_iSeleBtn:getChildByTag(99):hide()
    self:ShowTip()
    return
  end
  if _tag > 0 and _tag < CircleMenu.btnType.BRANCH_1 then
    nextType = _tag
    data.build = 1
    data.bType = _tag
  elseif _tag == CircleMenu.btnType.BRANCH_1 then
    data.upgrade = 1
    data.branch = 1
  elseif _tag == CircleMenu.btnType.BRANCH_2 then
    data.upgrade = 1
    data.branch = 2
  elseif _tag == CircleMenu.btnType.UPGRADE then
    data.upgrade = 1
  elseif _tag == CircleMenu.btnType.SELL then
    bIsSell = true
    data.sell = 1
  end
  local GameDataManager = require("app.GameDataManager")
  local cost = self:GetCost(nextType, bIsSell)
  local total = GameDataManager:GetInstance():GetCurResCount()
  if cost <= total then
    GameDataManager:GetInstance():UpdateCurResCount(-cost)
    td.dispatchEvent(td.CAMP_UPDATE_EVENT, data)
    self:Disapear()
  else
    td.alert(g_LM:getBy("a00174"), true)
  end
end
function CircleMenu:BlockTouch()
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
end
function CircleMenu:GetContentSize()
  local size = self.m_bg:getContentSize()
  size = cc.size(size.width * td.GetAutoScale(), size.height * td.GetAutoScale())
  return size
end
function CircleMenu:CheckGuide(event)
  local GuideManager = require("app.GuideManager")
  GuideManager.H_GuideUI(td.UIModule.CircleMenu, self.m_bg)
end
function CircleMenu:setPosition(_x, _y)
  self.m_bg:setPosition(_x, _y)
end
return CircleMenu
