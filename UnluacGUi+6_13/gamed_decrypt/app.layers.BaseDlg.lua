local UserDataManager = require("app.UserDataManager")
local BaseDlg = class("BaseDlg", function()
  return display.newLayer()
end)
function BaseDlg:ctor(alpha, bHaveBg)
  if alpha == nil then
    alpha = 200
  end
  self.m_bHaveBar = false
  self.m_useAnim = false
  self.m_uiId = nil
  self.m_scale = 1
  self.m_vCustomListeners = {}
  self.m_vEnterSubIndex = {}
  self.m_vGuideNodePath = {}
  self:setContentSize(display.width, display.height)
  self:CreateMaskLayer(alpha, bHaveBg)
  self:setNodeEventEnabled(true)
end
function BaseDlg:onEnter()
  self:AddCustomEvent(td.USERWEALTH_CHANGED, handler(self, self.OnWealthChanged))
  self:AddCustomEvent(td.ITEM_UPDATE, handler(self, self.OnItemUpdate))
  self:AddCustomEvent(td.CLOSE_MODULE, function(event)
    local uiId = tonumber(event:getDataString())
    if uiId == self.m_uiId then
      self:close()
    end
  end)
end
function BaseDlg:onExit()
  local eventDsp = self:getEventDispatcher()
  for i, listener in ipairs(self.m_vCustomListeners) do
    eventDsp:removeEventListener(listener)
  end
  self.m_vCustomListeners = {}
  eventDsp:removeEventListenersForTarget(self)
end
function BaseDlg:CreateForgroundMask()
  self.m_forgroundMaskLayer = require("app.layers.MaskLayer").new(0)
  self.m_forgroundMaskLayer:addTo(self, 10000)
  local pos = cc.p(self.m_forgroundMaskLayer:getPosition())
  pos.y = pos.y - self.m_forgroundMaskLayer.m_yOffset
  pos.x = pos.x - self.m_forgroundMaskLayer.m_xOffset
  self.m_forgroundMaskLayer:setPosition(pos)
end
function BaseDlg:RemoveForgroundMask()
  if self.m_forgroundMaskLayer then
    self.m_forgroundMaskLayer:removeFromParent()
    self.m_forgroundMaskLayer = nil
  end
end
function BaseDlg:SetBg(file)
  if self.m_maskLayer then
    self.m_maskLayer:SetBg(file)
  end
end
function BaseDlg:CreateMaskLayer(alpha, bHaveBg)
  self.m_maskLayer = require("app.layers.MaskLayer").new(alpha, bHaveBg)
  self.m_maskLayer:addTo(self, -10)
  local pos = cc.p(self.m_maskLayer:getPosition())
  pos.y = pos.y - self.m_maskLayer.m_yOffset
  pos.x = pos.x - self.m_maskLayer.m_xOffset
  self.m_maskLayer:setPosition(pos)
end
function BaseDlg:AddCustomEvent(name, func)
  local eventDsp = self:getEventDispatcher()
  local customListener = cc.EventListenerCustom:create(name, func)
  eventDsp:addEventListenerWithFixedPriority(customListener, 1)
  table.insert(self.m_vCustomListeners, customListener)
end
function BaseDlg:SetEnterSubIndex(vSubIndex, vGuideNodePath)
  if vSubIndex then
    self.m_vEnterSubIndex = vSubIndex
  end
  if vGuideNodePath then
    self.m_vGuideNodePath = vGuideNodePath
  end
end
function BaseDlg:CheckGuideNode()
  local guideNode
  local parentNode = self.m_uiRoot
  for i, var in ipairs(self.m_vGuideNodePath) do
    if not parentNode then
      break
    end
    if type(var) == "number" then
      guideNode = parentNode:getChildByTag(var)
    else
      guideNode = cc.uiloader:seekNodeByName(parentNode, var)
    end
    parentNode = guideNode
  end
  if guideNode then
    local skeleton = SkeletonUnit:create("Spine/UI_effect/UI_shouzhi_01")
    skeleton:PlayAni("animation_02", true)
    td.ShowRP(guideNode, true, cc.p(0.5, 0.5), skeleton)
  end
end
function BaseDlg:SetUseAnim(useAnim)
  self.m_useAnim = useAnim
end
function BaseDlg:close()
  g_MC:CloseModule(self.m_uiId)
  if self.m_useAnim then
    local duration = 0.3
    local action = cca.seq({
      cca.scaleTo(duration, 0.1),
      cca.cb(function()
        if self.m_uiId then
          td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
        end
        self:removeFromParent(true)
      end)
    })
    self:runAction(cc.EaseBackIn:create(action))
    if self.m_maskLayer then
      self.m_maskLayer:setVisible(false)
    end
  else
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    self:removeFromParent(true)
  end
end
function BaseDlg:setCloseBtn(closeBtn)
  if closeBtn then
    td.BtnAddTouch(closeBtn, function()
      self:close()
    end)
    closeBtn:setPressedActionEnabled(true)
  end
end
function BaseDlg:AddCloseTip()
  local tipLabel = td.CreateLabel(g_LM:getBy("a00410"), td.WHITE, 24)
  tipLabel:align(display.CENTER, 568, 20)
  tipLabel:setOpacity(0)
  self.m_uiRoot:addChild(tipLabel)
  tipLabel:runAction(cca.seq({
    cca.delay(1),
    cca.cb(function()
      tipLabel:runAction(cca.repeatForever(cca.seq({
        cca.fadeIn(2),
        cca.fadeOut(2)
      })))
    end)
  }))
end
function BaseDlg:SetTitle(fileName)
  local titleBg = cc.uiloader:seekNodeByName(self, "Image_title")
  local spr = display.newSprite(fileName)
  if titleBg then
    td.AddRelaPos(titleBg, spr)
  else
    local bg = cc.uiloader:seekNodeByName(self, "Image_bg")
    if bg then
      local bgSize = bg:getContentSize()
      spr:pos(bgSize.width / 2, bgSize.height - 40):addTo(bg)
    end
  end
end
function BaseDlg:enterAnim(duration)
  local duration = 0.3
  local action = cc.Sequence:create({
    cca.scaleTo(duration, 0.9),
    cca.scaleTo(duration, 1)
  })
  self:runAction(cc.EaseElasticOut:create(action))
  self:SetUseAnim(true)
end
function BaseDlg:PlayTopBarAni()
  self.m_titleBg:runAction(cca.seq({
    cca.delay(0.2),
    cc.EaseBackOut:create((cca.moveTo(0.3, 165, 603.5)))
  }))
end
function BaseDlg:LoadUI(file, horType, verType, bAddBar)
  self.m_uiRoot = cc.uiloader:load(file)
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  if bAddBar then
    self:AddCommonBar()
    self.m_titleBg = cc.uiloader:seekNodeByName(self, "Image_title")
    self:setAutoScale(self.m_uiRoot, horType, verType)
    self:PlayTopBarAni()
  end
end
function BaseDlg:AddCommonBar()
  local commonUI = cc.uiloader:load("CCS/CommonTopLayer.csb")
  commonUI:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(commonUI)
  self:addChild(commonUI, 10)
  self:setAutoScale(commonUI, td.UIPosHorizontal.Center, td.UIPosVertical.Top)
  local backBtn = cc.uiloader:seekNodeByName(commonUI, "Button_back")
  self:setCloseBtn(backBtn)
  local forceBtn = cc.uiloader:seekNodeByName(commonUI, "Button_force")
  td.BtnAddTouch(forceBtn, function()
    g_MC:OpenModule(td.UIModule.BuyForce)
  end)
  local staminaBtn = cc.uiloader:seekNodeByName(commonUI, "Button_strength")
  td.BtnAddTouch(staminaBtn, function()
    g_MC:OpenModule(td.UIModule.BuyStamina)
  end)
  local goldBtn = cc.uiloader:seekNodeByName(commonUI, "Button_gold")
  td.BtnAddTouch(goldBtn, function()
    g_MC:OpenModule(td.UIModule.BuyGold)
  end)
  local diamondBtn = cc.uiloader:seekNodeByName(commonUI, "Button_diamond")
  td.BtnAddTouch(diamondBtn, function()
    g_MC:OpenModule(td.UIModule.Topup)
  end)
  local udMng = UserDataManager:GetInstance()
  local RollNumberLabel = require("app.widgets.RollNumberLabel")
  self.m_labelStamina = td.CreateLabel(string.format("%d/%d", udMng:GetItemNum(td.ItemID_Stamina), udMng:GetMaxStamina()), td.WHITE, 18)
  self.m_labelStamina:align(display.LEFT_CENTER, 48, 20):addTo(staminaBtn)
  self.m_labelForce = RollNumberLabel.new({
    num = udMng:GetItemNum(td.ItemID_Force),
    color = td.WHITE,
    size = 18
  })
  self.m_labelForce:align(display.LEFT_CENTER, 48, 20):addTo(forceBtn)
  self.m_labelGold = RollNumberLabel.new({
    num = udMng:GetItemNum(td.ItemID_Gold),
    color = td.WHITE,
    size = 18
  })
  self.m_labelGold:align(display.LEFT_CENTER, 48, 20):addTo(goldBtn)
  self.m_labelDiamond = RollNumberLabel.new({
    num = udMng:GetItemNum(td.ItemID_Diamond),
    color = td.WHITE,
    size = 18
  })
  self.m_labelDiamond:align(display.LEFT_CENTER, 48, 20):addTo(diamondBtn)
  self.m_bHaveBar = true
end
function BaseDlg:OnWealthChanged()
  if self.m_bHaveBar then
    local udMng = UserDataManager:GetInstance()
    self.m_labelStamina:setString(string.format("%d/%d", udMng:GetItemNum(td.ItemID_Stamina), udMng:GetMaxStamina()))
    self.m_labelForce:SetNumber(udMng:GetItemNum(td.ItemID_Force))
    self.m_labelGold:SetNumber(udMng:GetItemNum(td.ItemID_Gold))
    self.m_labelDiamond:SetNumber(udMng:GetItemNum(td.ItemID_Diamond))
  end
end
function BaseDlg:OnItemUpdate()
end
function BaseDlg:setAutoScale(root, uiPosHorizontal, uiPosVertical)
  if not root then
    return
  end
  self.m_scale = td.GetAutoScale()
  root:setScale(self.m_scale * root:getScale())
  local x, y
  if uiPosHorizontal == td.UIPosHorizontal.Left then
    x = 0
  elseif uiPosHorizontal == td.UIPosHorizontal.Right then
    x = display.size.width - 1136 * self.m_scale
  else
    x = (display.size.width - 1136 * self.m_scale) / 2
  end
  local displayHeight = display.size.height
  if self.m_bHaveBar then
    displayHeight = displayHeight - 70 * self.m_scale
  end
  if uiPosVertical == td.UIPosVertical.Top then
    y = displayHeight - 640 * self.m_scale
  elseif uiPosVertical == td.UIPosVertical.Bottom then
    y = 0
  else
    y = (displayHeight - 640 * self.m_scale) / 2
  end
  root:setPosition(x, y)
end
function BaseDlg:CheckGuide(event)
  local GuideManager = require("app.GuideManager")
  GuideManager.H_GuideUI(self.m_uiId, self)
end
return BaseDlg
