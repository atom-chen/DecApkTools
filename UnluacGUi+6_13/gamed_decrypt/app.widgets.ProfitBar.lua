local MissionInfoManager = require("app.info.MissionInfoManager")
local ProfitBar = class("ProfitBar", function(index)
  return display.newScale9Sprite("UI/mainmenu_new/tubiaofangzhikuang.png", 0, 0, cc.size(160, 38), cc.rect(50, 11, 10, 28))
end)
local spines = {
  "EFT_shuihuang_01",
  "EFT_shuifen_01",
  "EFT_shuizi_01",
  "EFT_shuilv_01",
  "EFT_shuibai_01"
}
local ProfitIds = {
  20001,
  20132,
  20003,
  20006,
  20007
}
function ProfitBar:ctor(i, scene)
  self.m_index = i
  self.m_scene = scene
  self.m_itemId = ProfitIds[i]
  self.m_pLockEffect = nil
  self.m_bIsLocked = false
  self.m_pFullEffect = nil
  self.m_bIsFull = false
  self:Init()
  self:setNodeEventEnabled(true)
end
function ProfitBar:Init()
  self.icon = display.newSprite(td.GetItemIcon(self.m_itemId))
  self.icon:scale(0.3):pos(20, 19):addTo(self)
  local file = "Spine/UI_effect/" .. spines[self.m_index]
  self.bar = require("app.widgets.SpineProgressBar").new(file, cc.size(125, 25))
  self.bar:pos(40, 10):addTo(self, -1)
  local label = td.CreateLabel("0/0", td.WHITE, 14)
  label:setAnchorPoint(0.5, 0.5)
  self.label = label
  local spr = display.newScale9Sprite("UI/scale9/lanseshuzi_dikuang.png", 0, 0, cc.size(80, 30))
  spr:setVisible(false)
  spr:align(display.LEFT_BOTTOM, 40, 5):addTo(self)
  td.AddRelaPos(spr, label)
  self.numBg = spr
end
function ProfitBar:onEnter()
  self:AddTouch()
end
function ProfitBar:Update()
  local cur, max = MissionInfoManager.GetProfit(self.m_itemId)
  self:SetPercent(cur / max * 100)
  self.label:setString(string.format("%d/%d", cur, max))
  local labelWidth = self.label:getContentSize().width
  local wordBgWidth = math.max(80, labelWidth + 20)
  self.numBg:setContentSize(cc.size(wordBgWidth + 20, 30))
  self.label:setPositionX(labelWidth / 2 + 10)
end
function ProfitBar:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    local rect = _event:getCurrentTarget():getBoundingBox()
    local pos = _touch:getLocation()
    pos = self:getParent():convertToNodeSpace({
      x = pos.x,
      y = pos.y
    })
    if cc.rectContainsPoint(rect, pos) then
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:OnTouch()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function ProfitBar:OnTouch()
  if self.m_bIsLocked then
    return
  end
  local preIndex = self.m_scene.m_curProfitBtnIndex
  if preIndex ~= self.m_index then
    if self.m_scene.m_curProfitBtnIndex ~= 0 then
      self.m_scene.m_vProfitBtns[preIndex].numBg:setVisible(false)
    end
    self.m_scene.m_curProfitBtnIndex = self.m_index
    self.m_scene.m_vProfitBtns[self.m_index].numBg:setVisible(true)
    td.dispatchEvent(td.GUIDE_FINISHED, td.UIModule.MainMenu)
    return
  end
  self.m_scene.m_vProfitBtns[preIndex].numBg:setVisible(false)
  self.m_scene.m_curProfitBtnIndex = 0
  local cur = MissionInfoManager.GetProfit(self.m_itemId)
  if cur >= 1 then
    MissionInfoManager:GetInstance():SendGetProfitRequest(self.m_itemId)
    td.dispatchEvent(td.GUIDE_FINISHED, td.UIModule.MainMenu)
    local count = math.floor(MissionInfoManager.GetProfit(self.m_itemId))
    local iconPos = self.icon:getParent():convertToWorldSpace(cc.p(self.icon:getPosition()))
    for j = 1, 6 do
      local flyIcon = require("app.widgets.FlyIcon").new(self.m_itemId, nil, j == 1, count)
      flyIcon:setPosition(iconPos)
      flyIcon:setScale(0.4 * td.GetAutoScale())
      flyIcon:Fly()
    end
    local spine = SkeletonUnit:create("Spine/UI_effect/EFT_shoujiguang_02")
    spine:setPosition(iconPos)
    spine:addTo(display.getRunningScene(), 5000)
    spine:PlayAni("animation", false)
  else
    G_SoundUtil:PlaySound(53, false)
  end
end
function ProfitBar:SetPercent(per)
  self.bar:SetPercent(per)
  if per >= 100 and not self.m_bIsFull then
    self:SetFull(true)
  elseif per < 100 and self.m_bIsFull then
    self:SetFull(false)
  end
end
function ProfitBar:GetPercent()
  return self.bar:GetPercent()
end
function ProfitBar:SetLocked(bLock)
  if bLock and not self.m_pLockEffect then
    self.m_pLockEffect = SkeletonUnit:create("Spine/UI_effect/UI_ziyuansuoding_01")
    td.AddRelaPos(self, self.m_pLockEffect)
    self.m_pLockEffect:PlayAni("animation_01", false)
    self.m_pLockEffect:registerSpineEventHandler(function(event)
      if event.animation == "animation_01" then
        self.m_pLockEffect:PlayAni("animation_02", true)
      end
    end, sp.EventType.ANIMATION_COMPLETE)
  elseif not bLock and self.m_pLockEffect then
    self.m_pLockEffect:PlayAni("animation_03", false)
    self.m_pLockEffect:registerSpineEventHandler(function(event)
      if event.animation == "animation_03" then
        self.m_pLockEffect:removeFromParent()
        self.m_pLockEffect = nil
      end
    end, sp.EventType.ANIMATION_COMPLETE)
  end
  self.m_bIsLocked = bLock
end
function ProfitBar:SetFull(bFull)
  if bFull and not self.m_pFullEffect then
    self.m_pFullEffect = SkeletonUnit:create("Spine/UI_effect/UI_huoyuedu_01")
    self.m_pFullEffect:setTimeScale((math.random(5) + 5) / 10)
    self.m_pFullEffect:scale(0.5)
    td.AddRelaPos(self, self.m_pFullEffect, 0, cc.p(0.15, 0.5))
    self.m_pFullEffect:PlayAni("animation", true)
  elseif not bFull and self.m_pFullEffect then
    self.m_pFullEffect:removeFromParent()
    self.m_pFullEffect = nil
  end
  self.m_bIsFull = bFull
end
return ProfitBar
