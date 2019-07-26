local BattleUILayer = import(".BattleUILayer")
local GameDataManager = require("app.GameDataManager")
local MaskLayer = require("app.layers.MaskLayer")
local BattleUIGuideLayer = class("BattleUIGuideLayer", BattleUILayer)
function BattleUIGuideLayer:ctor()
  BattleUIGuideLayer.super.ctor(self)
end
function BattleUIGuideLayer:InitUI()
  BattleUIGuideLayer.super.InitUI(self)
  self:PrepareGuide()
end
function BattleUIGuideLayer:AddListeners()
  BattleUIGuideLayer.super.AddListeners(self)
  self:AddCustomEvent(td.GUIDE_UI, handler(self, self.DoGuide))
  self:AddCustomEvent(td.GUIDE_HERO, handler(self, self.GuideHero))
  self:AddCustomEvent(td.GUIDE_MAP, handler(self, self.GuideMoveMap))
end
function BattleUIGuideLayer:PrepareGuide()
  self.m_guideUIStep = 1
  self.m_guideItems = {
    {},
    {},
    {}
  }
  if GameDataManager:GetInstance():GetGameMapInfo().id == td.TRAIN_ID then
    local pauseBar = cc.uiloader:seekNodeByName(self.m_pPanel_top, "RightBg")
    pauseBar:setVisible(false)
  end
  self.m_resourceBar = cc.uiloader:seekNodeByName(self.m_pPanel_top, "LeftBg")
  self.m_resourceBar:setVisible(false)
  local tmp = {
    "PopuLabelNode"
  }
  local words = {
    "\229\189\147\229\137\141\228\186\186\229\143\163/\228\186\186\229\143\163\228\184\138\233\153\144"
  }
  for i, name in ipairs(tmp) do
    local pItem = cc.uiloader:seekNodeByName(self.m_resourceBar, name)
    pItem:setScale(0)
    table.insert(self.m_guideItems[1], {
      item = pItem,
      oriPos = cc.p(pItem:getPosition()),
      word = words[i]
    })
  end
  for i = 1, 6 do
    local pItem = cc.uiloader:seekNodeByName(self.m_pPanel_bottom_left, "SoldierBtn_" .. i)
    pItem:setVisible(false)
    table.insert(self.m_guideItems[2], {
      item = pItem,
      oriPos = cc.p(pItem:getPosition())
    })
  end
  local pItem = cc.uiloader:seekNodeByName(self.m_pPanel_bottom_right, "HeroSlotBg")
  table.insert(self.m_guideItems[3], {
    item = pItem,
    oriPos = cc.p(pItem:getPosition())
  })
  pItem:setPositionY(pItem:getPositionY() - 200)
  self.m_tipButton:setVisible(false)
  self.m_btnRestrain:setVisible(false)
end
function BattleUIGuideLayer:DoGuide()
  if self.m_guideUIStep == 1 then
    self:GuideResource()
  elseif self.m_guideUIStep == 2 then
    self:GuideSoldier1()
  elseif self.m_guideUIStep == 3 then
    self:GuideSoldier2()
  else
    return
  end
  self.m_guideUIStep = self.m_guideUIStep + 1
end
function BattleUIGuideLayer:GuideResource()
  local colorLayer = MaskLayer.new(200)
  self:addChild(colorLayer, -1)
  local centerPos = cc.p(display.width / 2, display.height / 2)
  centerPos = self.m_resourceBar:convertToNodeSpace(centerPos)
  for i, var in ipairs(self.m_guideItems[1]) do
    do
      local bg1 = display.newSprite("UI/battle/redBg.png")
      bg1:setScale(1, 0.5)
      bg1:setOpacity(0)
      td.AddRelaPos(var.item, bg1, -1)
      local spBg = SkeletonUnit:create("Spine/UI_effect/UI_xinshouyindao_01")
      td.AddRelaPos(var.item, spBg)
      local bg2 = display.newSprite("UI/battle/redBg.png")
      bg2:setScale(1.7, 0.5)
      bg2:setOpacity(0)
      bg2:pos(200, 0):addTo(var.item)
      local spLabelBg = SkeletonUnit:create("Spine/UI_effect/UI_xinshouyindao_02")
      spLabelBg:pos(200, 0):addTo(var.item)
      spLabelBg:setOpacity(0)
      local label = td.CreateLabel(var.word)
      td.AddRelaPos(spLabelBg, label)
      label:setScale(0)
      var.item:setPosition(centerPos)
      var.item:runAction(cca.seq({
        cca.delay(1 + 4 * (i - 1)),
        cca.cb(function()
          spBg:PlayAni("animation", false)
          bg1:runAction(cca.fadeIn(0.3))
        end),
        cc.EaseBackOut:create(cca.scaleTo(0.2, 1)),
        cca.delay(0.5),
        cca.moveBy(0.5, -100, 0),
        cca.cb(function()
          spLabelBg:PlayAni("animation", false)
          spLabelBg:runAction(cca.fadeIn(0.3))
          bg2:runAction(cca.fadeIn(0.3))
          label:runAction(cc.EaseBackOut:create(cca.scaleTo(0.3, 1)))
        end),
        cca.delay(2),
        cca.cb(function()
          bg1:removeFromParent()
          bg2:removeFromParent()
          spBg:removeFromParent()
          spLabelBg:removeFromParent()
        end),
        cca.moveTo(0.5, var.oriPos.x, var.oriPos.y),
        cca.scaleTo(0.1, 1.2),
        cca.scaleTo(0.1, 0.8),
        cca.scaleTo(0.05, 1)
      }))
    end
  end
  self.m_resourceBar:setPositionY(self.m_resourceBar:getPositionY() + 200)
  self.m_resourceBar:runAction(cca.seq({
    cca.show(),
    cca.moveBy(1, 0, -200),
    cca.delay(5),
    cca.cb(function()
      colorLayer:removeFromParent()
      self:DoGuide()
    end)
  }))
end
function BattleUIGuideLayer:GuideSoldier1()
  local colorLayer = MaskLayer.new(200)
  self:addChild(colorLayer, -1)
  local var = self.m_guideItems[2][1]
  local centerPos = cc.p(display.width / 2, display.height / 2)
  centerPos = var.item:getParent():convertToNodeSpace(centerPos)
  var.item:setPosition(centerPos)
  var.item:getChildByTag(1):ShowFlash()
  var.item:runAction(cca.seq({
    cca.show(),
    cca.delay(2),
    cca.moveTo(0.5, var.oriPos.x, var.oriPos.y),
    cca.scaleTo(0.1, 1.2),
    cca.scaleTo(0.1, 0.8),
    cca.scaleTo(0.05, 1),
    cca.cb(function()
      colorLayer:removeFromParent()
      self:DoGuide()
    end)
  }))
end
function BattleUIGuideLayer:GuideSoldier2()
  local colorLayer = MaskLayer.new(200)
  self:addChild(colorLayer, -1)
  local var = self.m_guideItems[2][2]
  local centerPos = cc.p(display.width / 2, display.height / 2)
  centerPos = var.item:getParent():convertToNodeSpace(centerPos)
  var.item:setPosition(centerPos)
  var.item:getChildByTag(1):ShowFlash()
  var.item:runAction(cca.seq({
    cca.show(),
    cca.delay(2),
    cca.moveTo(0.5, var.oriPos.x, var.oriPos.y),
    cca.scaleTo(0.1, 1.2),
    cca.scaleTo(0.1, 0.8),
    cca.scaleTo(0.05, 1)
  }))
  for i = 3, 6 do
    local var = self.m_guideItems[2][i]
    var.item:setPosition(cc.p(var.oriPos.x, var.oriPos.y - 200))
    local actions = {
      cca.delay(2.5 + 0.1 * i),
      cca.show(),
      cc.EaseBackOut:create(cca.moveTo(0.5, var.oriPos.x, var.oriPos.y))
    }
    if i == 6 then
      table.insert(actions, cca.cb(function()
        colorLayer:removeFromParent()
        td.dispatchEvent(td.GUIDE_CONTINUE)
      end))
    end
    var.item:runAction(cca.seq(actions))
  end
end
function BattleUIGuideLayer:GuideHero()
  local var = self.m_guideItems[3][1]
  var.item:runAction(cc.EaseBackOut:create(cca.moveTo(0.5, var.oriPos.x, var.oriPos.y)))
  td.dispatchEvent(td.GUIDE_CONTINUE)
end
function BattleUIGuideLayer:GuideMoveMap()
  local gameMapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  if gameMapInfo.id == td.TRAIN_ID then
    local spine = SkeletonUnit:create("Spine/UI_effect/UI_shouzhi_02")
    spine:PlayAni("animation")
    spine:runAction(cca.seq({
      cca.delay(5),
      cca.removeSelf()
    }))
    td.AddRelaPos(self.m_pPanel_top, spine, -1, cc.p(0.9, 0.5))
  else
    local vPos, vScalex = {
      cc.p(0.1, 0.5),
      cc.p(0.9, 0.5)
    }, {-1, 1}
    for i = 1, 2 do
      local spine = SkeletonUnit:create("Spine/UI_effect/UI_suofang_01")
      spine:PlayAni("animation")
      spine:runAction(cca.seq({
        cca.delay(5),
        cca.removeSelf()
      }))
      spine:setScale(vScalex[i], 1)
      td.AddRelaPos(self.m_pPanel_top, spine, -1, vPos[i])
    end
  end
end
return BattleUIGuideLayer
