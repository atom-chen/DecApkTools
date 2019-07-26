local GameDataManager = require("app.GameDataManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local GuideManager = require("app.GuideManager")
local SkillButton = class("SkillButton", function(skill)
  return display.newSprite("#UI/battle/jinengkuang.png")
end)
function SkillButton:ctor(skill, isWeapon)
  self.m_pSkill = skill
  local skillInfo = SkillInfoManager:GetInstance():GetInfo(skill:GetID())
  self.m_iSkillId = skillInfo.id
  self.m_needTarget = skillInfo.type == td.SkillType.FixedMagic and true or false
  self.m_iWidth = skillInfo.range_long
  self.m_iHeight = skillInfo.range_high
  self.m_iCD = skill:GetCD()
  self.m_iCDTime = skill:GetCDTime()
  self.m_CDLabel = nil
  self.m_iIsEnable = 0
  self.m_isActive = false
  self:InitUI(skillInfo, isWeapon)
  self:setNodeEventEnabled(true)
end
function SkillButton:onEnter()
  self:AddTouch()
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
  self:scheduleUpdate()
end
function SkillButton:onExit()
end
function SkillButton:update(dt)
  self.m_iCD = self.m_pSkill:GetCD()
  self.m_iCDTime = self.m_pSkill:GetCDTime()
  local beforePercent = self.m_pProgressTimer:getPercentage()
  self.m_pProgressTimer:setPercentage((self.m_iCD - self.m_iCDTime) / self.m_iCD * 100)
  self.m_CDLabel:setString(string.format("%d", self.m_iCD - self.m_iCDTime))
  local afterPercent = self.m_pProgressTimer:getPercentage()
  if self.m_iCD - self.m_iCDTime > 0 then
    self.m_CDLabel:setVisible(true)
  else
    self.m_CDLabel:setVisible(false)
  end
  if beforePercent ~= 0 and afterPercent == 0 then
    td.CreateUIEffect(self, "Spine/UI_effect/UI_jinengCD_01")
  end
end
function SkillButton:InitUI(skillInfo, isWeapon)
  self.m_pIcon = display.newSprite(skillInfo.icon .. td.PNG_Suffix)
  self.m_pIcon:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
  self.m_pIcon:addTo(self, -1)
  local iconScale = self:getContentSize().width * 0.9 / self.m_pIcon:getContentSize().width
  self.m_pIcon:setScale(iconScale)
  local timerSpr = display.newSprite(skillInfo.icon .. td.PNG_Suffix)
  timerSpr:setColor(td.BTN_PRESSED_COLOR)
  local progressTimer = cc.ProgressTimer:create(timerSpr)
  self.m_pProgressTimer = progressTimer
  progressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
  progressTimer:setPercentage((self.m_iCD - self.m_iCDTime) / self.m_iCD * 100)
  td.AddRelaPos(self.m_pIcon, progressTimer, 1)
  self.m_CDLabel = td.CreateBMF("", "Fonts/Yellow_outline.fnt", 0.8)
  self.m_CDLabel:setVisible(false)
  td.AddRelaPos(self.m_pIcon, self.m_CDLabel, 2)
  self.m_seleSpr = display.newSprite("UI/scale9/jinengxuanzhongkuang.png")
  self.m_seleSpr:setVisible(false)
  td.AddRelaPos(self, self.m_seleSpr, 10)
  if isWeapon then
    local spr = display.newSprite("#UI/battle/jineng_zhuangshidi.png")
    td.AddRelaPos(self, spr, 11, cc.p(0.5, -0.15))
  end
end
function SkillButton:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    if not g_MC:GetEnableUI() then
      return false
    end
    local rect = _event:getCurrentTarget():getBoundingBox()
    local pos = _touch:getLocation()
    pos = self:getParent():convertToNodeSpace({
      x = pos.x,
      y = pos.y
    })
    if cc.rectContainsPoint(rect, pos) then
      self:onTouchBegan()
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function SkillButton:setEnable(bEnable)
  if bEnable then
    self.m_iIsEnable = self.m_iIsEnable + 1
  else
    self.m_iIsEnable = self.m_iIsEnable - 1
  end
  if self.m_iIsEnable >= 0 then
    self:setColor(display.COLOR_WHITE)
  else
    self.m_pProgressTimer:setPercentage(100)
    self:setColor(td.BTN_PRESSED_COLOR)
  end
end
function SkillButton:ResetEnable()
  self.m_iIsEnable = 0
end
function SkillButton:isEnable()
  return self.m_iIsEnable >= 0 and self.m_iCDTime >= self.m_iCD
end
function SkillButton:onTouchBegan()
  if self.m_iIsEnable >= 0 then
    self:setScale(0.9)
  end
end
function SkillButton:onTouchEnded(_pos)
  self:setScale(1)
  if self.m_iIsEnable < 0 then
    return
  end
  if self.m_iCDTime < self.m_iCD then
    local uiLayer = display.getRunningScene():GetUILayer()
    uiLayer:ShowClearCDMsg(self.m_iSkillId)
    return
  end
  if self.m_needTarget then
    if self.m_isActive then
      GameDataManager:GetInstance():SetFocusNode(nil)
    else
      GameDataManager:GetInstance():SetFocusNode(self)
    end
  else
    self:PreDoSkill()
  end
end
function SkillButton:PreDoSkill()
  local gdMng = GameDataManager:GetInstance()
  local pMap = gdMng:GetGameMap()
  if self.m_needTarget then
    local childPos = gdMng:GetSkillTarget()
    local rangeEffect = EffectManager:GetInstance():CreateEffect(2004)
    rangeEffect:setScale(2)
    rangeEffect:setPosition(childPos)
    rangeEffect:SetEndCallback(function()
      self:DoSkill()
    end)
    rangeEffect:AddToMap(pMap)
  else
    self:DoSkill()
  end
end
function SkillButton:DoSkill()
  local gdMng = GameDataManager:GetInstance()
  local pHero = gdMng:GetCurHero()
  pHero:SetCurSkill(self.m_iSkillId, true)
  local doSkillEffect = EffectManager:GetInstance():CreateEffect(1067)
  doSkillEffect:AddToActor(pHero)
  local curHeroData = gdMng:GetCurHeroData()
  curHeroData.skillCD[self.m_iSkillId].time = 0
  td.dispatchEvent(td.ENABLE_SKILL_BTN, 0)
  local bannerLayer = require("app.layers.battle.MagicBannerLayer").new(self.m_iSkillId, function()
    td.dispatchEvent(td.ENABLE_SKILL_BTN, 1)
  end)
  display.getRunningScene():GetUILayer():addChild(bannerLayer, -1)
  self:SendAchieveReq()
end
function SkillButton:SendAchieveReq()
  local TDHttpRequest = require("app.net.TDHttpRequest")
  local msg = {}
  msg.msgType = td.RequestID.UpAchieventment
  msg.sendData = {type = 16}
  TDHttpRequest:getInstance():SendPrivate(msg, true)
end
function SkillButton:ActiveFocus()
  GameDataManager:GetInstance():SetActorCanTouch(false)
  if GuideManager:GetInstance():ShouldWeakGuide() then
    display.getRunningScene():GetUILayer():ShowUIMessage(g_LM:getBy("a00217"))
  end
  self.m_seleSpr:setVisible(true)
  self.m_isActive = true
end
function SkillButton:InactiveFocus()
  GameDataManager:GetInstance():SetActorCanTouch(true)
  if GuideManager:GetInstance():ShouldWeakGuide() then
    display.getRunningScene():GetUILayer():ShowUIMessage()
  end
  self.m_seleSpr:setVisible(false)
  self.m_isActive = false
end
function SkillButton:DoFocus(_pos)
  local gdMng = GameDataManager:GetInstance()
  local pMap = gdMng:GetGameMap()
  local childPos = pMap:GetMapPosFromWorldPos(_pos)
  if self.m_iSkillId == 2078 or self.m_iSkillId == 4022 then
    local home = require("app.actor.ActorManager"):GetInstance():FindHome(false)
    if not pMap:IsWalkable(cc.p(pMap:GetTilePosFromPixelPos(childPos))) or home and home:IsInEllipse(childPos) then
      td.alert(g_LM:getBy("a00367"))
      return
    end
  end
  gdMng:SetSkillTarget(childPos)
  self:PreDoSkill()
  gdMng:SetFocusNode(nil)
end
return SkillButton
