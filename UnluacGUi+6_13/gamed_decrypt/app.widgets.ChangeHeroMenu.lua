local ActorInfoManager = require("app.info.ActorInfoManager")
local GameDataManager = require("app.GameDataManager")
local ChangeHeroMenu = class("ChangeHeroMenu", function()
  return display.newLayer()
end)
function ChangeHeroMenu:ctor()
  self.m_vBtn = {}
  self.selectIndex = nil
  self:InitUI()
  self:BlockTouch()
  self:setNodeEventEnabled(true)
end
function ChangeHeroMenu:onEnter()
  local gdMng = GameDataManager:GetInstance()
  gdMng:SetFocusNode(gdMng:GetCurHero())
  for i, btn in ipairs(self.m_vBtn) do
    local y = 15 + i * 80
    btn:runAction(cca.seq({
      cca.show(),
      cc.EaseElasticOut:create(cca.moveBy(y / 300, 0, y), 1),
      cca.cb(function()
        self.m_bIsAniOver = true
      end)
    }))
  end
end
function ChangeHeroMenu:onExit()
end
function ChangeHeroMenu:InitUI()
  local gdMng = GameDataManager:GetInstance()
  local heroDatas = gdMng:GetHeros()
  local curData = gdMng:GetCurHeroData()
  self.m_bg = display.newNode()
  self.m_bg:scale(td.GetAutoScale()):addTo(self, 1)
  local count = #heroDatas
  for i, var in ipairs(heroDatas) do
    if var ~= curData then
      local heroInfo = var.heroInfo
      local btn = ccui.Button:create("UI/battle/genghuantouxiangkuang2.png", "UI/battle/genghuantouxiangkuang2.png")
      td.BtnAddTouch(btn, function()
        local uiLayer = display.getRunningScene():GetUILayer()
        if not var.bDead then
          uiLayer:ChangeHero(i)
        else
          uiLayer:ShowRebornMsg(i)
        end
        self:Disapear()
      end)
      btn:setVisible(false)
      self.m_bg:addChild(btn, count - i)
      local headSpr = display.newSprite(heroInfo.head .. td.PNG_Suffix)
      headSpr:scale(0.8)
      td.AddRelaPos(btn, headSpr)
      if var.bDead then
        local timerSpr = display.newSprite("UI/common/mask_80.png")
        timerSpr:setColor(display.COLOR_BLACK)
        timerSpr:setOpacity(150)
        timerSpr:setScaleX(btn:getContentSize().width * 0.9 / timerSpr:getContentSize().width)
        timerSpr:setScaleY(btn:getContentSize().height * 0.9 / timerSpr:getContentSize().height)
        td.AddRelaPos(btn, timerSpr, 1)
        local disableSpr = display.newSprite("UI/battle/zhenwang_icon.png")
        disableSpr:scale(0.7)
        td.AddRelaPos(btn, disableSpr, 2)
      end
      local borderSpr = display.newSprite("UI/battle/genghuantouxiangkuang1.png")
      td.AddRelaPos(btn, borderSpr, 2)
      table.insert(self.m_vBtn, btn)
    end
  end
end
function ChangeHeroMenu:Disapear()
  self:removeFromParent()
end
function ChangeHeroMenu:BlockTouch()
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
function ChangeHeroMenu:setPosition(_x, _y)
  self.m_bg:setPosition(_x, _y)
end
return ChangeHeroMenu
