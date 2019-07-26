local GameDataManager = require("app.GameDataManager")
local HeroButton = class("HeroButton", function(heroData)
  return display.newSprite(heroData.head .. td.PNG_Suffix)
end)
function HeroButton:ctor(heroData)
  self.m_bClickedOnce = false
  self.m_bIsEnable = true
  self.m_seleSpr = display.newScale9Sprite("UI/scale9/xiaobingxuanzhongkuang.png", 0, 0, cc.size(93, 98))
  td.AddRelaPos(self, self.m_seleSpr, 10)
  self.m_disableSpr = display.newSprite("UI/battle/zhenwang_icon.png")
  self.m_disableSpr:setVisible(false)
  td.AddRelaPos(self, self.m_disableSpr, 11)
  local timerSpr = display.newSprite("UI/common/mask_80.png")
  timerSpr:setColor(display.COLOR_BLACK)
  local progressTimer = cc.ProgressTimer:create(timerSpr)
  progressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
  progressTimer:setPercentage(0)
  progressTimer:setScaleX(self:getContentSize().width / timerSpr:getContentSize().width)
  progressTimer:setScaleY(self:getContentSize().height / timerSpr:getContentSize().height)
  td.AddRelaPos(self, progressTimer, 11)
  self.m_pProgressTimer = progressTimer
  local borderSpr = display.newSprite("UI/battle/yingxiongkuang_" .. heroData.career .. ".png")
  td.AddRelaPos(self, borderSpr, 12, cc.p(0.5, 0.4))
  self:setNodeEventEnabled(true)
end
function HeroButton:onEnter()
  self:AddTouch()
end
function HeroButton:onExit()
end
function HeroButton:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    local rect = _event:getCurrentTarget():getBoundingBox()
    local pos = _touch:getLocation()
    pos = self:getParent():convertToNodeSpace(cc.p(pos.x, pos.y))
    if cc.rectContainsPoint(rect, pos) then
      if self.m_bIsEnable then
        self:onTouchBegan()
      elseif self:CheckCanReborn() then
        local curHeroIndex = GameDataManager:GetInstance():GetCurHeroIndex()
        local uiLayer = display.getRunningScene():GetUILayer()
        uiLayer:ShowRebornMsg(curHeroIndex)
      end
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function HeroButton:setEnable(bEnable)
  if bEnable == self.m_bIsEnable then
    return
  end
  self.m_bIsEnable = bEnable
  if bEnable then
    self:setColor(display.COLOR_WHITE)
    self.m_disableSpr:setVisible(false)
  else
    self:setColor(td.BTN_PRESSED_COLOR)
    self.m_disableSpr:setVisible(true)
  end
end
function HeroButton:SetSelected(bSele)
  self.m_seleSpr:setVisible(bSele)
end
function HeroButton:onTouchBegan()
end
function HeroButton:onTouchEnded(_pos)
  local hero = GameDataManager:GetInstance():GetCurHero()
  if nil == hero then
    return
  end
  if self.m_bClickedOnce then
    self.m_bClickedOnce = false
    do
      local heroPos = cc.p(hero:getPosition())
      local pMap = GameDataManager:GetInstance():GetGameMap()
      pMap:SetIsTouchable(false)
      self.m_bIsEnable = false
      pMap:HighlightPos(heroPos, 2000, function()
        pMap:SetIsTouchable(true)
        self.m_bIsEnable = true
      end)
    end
  else
    self.m_bClickedOnce = true
    self:performWithDelay(function()
      self.m_bClickedOnce = false
    end, 0.5)
  end
  GameDataManager:GetInstance():SetFocusNode(hero)
end
function HeroButton:PlayCD(total, cur)
  self:setEnable(false)
  self.m_pProgressTimer:runAction(cca.seq({
    cca.progressFromTo(cur, cur / total * 100, 0),
    cca.cb(function()
      self:setEnable(true)
    end)
  }))
end
function HeroButton:CheckCanReborn()
  local gdMng = GameDataManager:GetInstance()
  if gdMng:GetGameMapInfo().type ~= td.MapType.Bomb then
    local hero = GameDataManager:GetInstance():GetCurHero()
    if hero == nil or hero:IsDead() then
      return true
    end
  end
  return false
end
function HeroButton:ActiveFocus()
end
function HeroButton:InactiveFocus()
end
return HeroButton
