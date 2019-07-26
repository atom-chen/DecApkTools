local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local GuideManager = require("app.GuideManager")
local TouchIcon = require("app.widgets.TouchIcon")
local WeaponDlg = class("WeaponDlg", BaseDlg)
local OpType = {
  Info = 0,
  Replace = 1,
  Upgrade = 2,
  Evol = 3
}
local Item_Size = cc.size(300, 100)
function WeaponDlg:ctor(data)
  WeaponDlg.super.ctor(self)
  self.m_uiId = td.UIModule.WeaponUpgrade
  self.m_siMng = StrongInfoManager:GetInstance()
  self.m_iiMng = ItemInfoManager:GetInstance()
  self.m_udMng = UserDataManager:GetInstance()
  self.m_opType = nil
  self.m_vProLabel = {}
  self.m_vSelMeterial = {
    {},
    {}
  }
  self.m_data = nil
  self.m_repData = nil
  self.m_upgExp = nil
  self.isAdding = false
  self.m_bActionOver = false
  self:InitUI()
  self:SetData(data)
end
function WeaponDlg:onEnter()
  WeaponDlg.super.onEnter(self)
  self:AddHttpListener()
  self:AddEvent()
  if self.m_heroData then
    self:PlayEnterAni(function()
      if self.m_data then
        self:ShowInfo()
        if GuideManager:GetInstance():IsForceGuideOver() then
          GuideManager.H_StartGuideGroup(116)
        end
      else
        self:ShowWeapons()
      end
      self:CheckGuide()
    end)
  else
    self:PlayEnterAni(function()
      self:ShowInfo()
    end)
  end
end
function WeaponDlg:MoveBgs()
  local posX, posY = self.m_bg1:getPosition()
  self.m_bg1:pos(posX - 182.5, posY)
  self.m_bg2:setOpacity(255)
end
function WeaponDlg:onExit()
  self:RemoveHttpListener()
  WeaponDlg.super.onExit(self)
end
function WeaponDlg:PlayEnterAni(cb)
  local t = 0.5
  if not self.m_bg2:isVisible() then
    self.m_bg1:runAction(cca.seq({
      cca.moveBy(t, -182.5, 0),
      cca.cb(function()
        local spineInfo = {
          pos = cc.p(self.m_bg2:getPositionX() + self.m_bg2:getContentSize().width / 2, self.m_bg2:getPositionY())
        }
        local effect = td.CreateUIEffect(self.m_panelBg, "Spine/UI_effect/UI_zhuangbeitanchu_01", spineInfo)
      end)
    }))
    self.m_bg2:setVisible(true)
    self.m_bg2:runAction(cca.seq({
      cca.delay(t),
      cca.fadeIn(t),
      cca.cb(function()
        cb()
        self.m_bActionOver = true
      end)
    }))
  elseif cb then
    cb()
    self.m_bActionOver = true
  end
end
function WeaponDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/WeaponDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self:AddCloseTip()
  self.m_panelBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.m_bg1 = cc.uiloader:seekNodeByName(self.m_panelBg, "Image_bg1")
  self.m_weaponBg = cc.uiloader:seekNodeByName(self.m_bg1, "Image_1")
  self.m_bg2 = cc.uiloader:seekNodeByName(self.m_panelBg, "Image_bg2")
  self.m_panelInfo = cc.uiloader:seekNodeByName(self.m_bg2, "Panel_info")
  self.m_panelSkill = cc.uiloader:seekNodeByName(self.m_panelInfo, "Panel_skill")
  self.m_panelUp = cc.uiloader:seekNodeByName(self.m_bg2, "Panel_up")
  self.m_panelEvo = cc.uiloader:seekNodeByName(self.m_bg2, "Panel_evo")
  self.m_txtExp = cc.uiloader:seekNodeByName(self.m_panelUp, "Text_exp")
  self.m_txtGold = cc.uiloader:seekNodeByName(self.m_panelUp, "Text_gold")
  self.m_nameLabel = cc.uiloader:seekNodeByName(self.m_bg1, "Text_name")
  self.m_panelLevel = cc.uiloader:seekNodeByName(self.m_bg1, "Panel_level")
  self.m_levelLabel = cc.uiloader:seekNodeByName(self.m_panelLevel, "Text_level")
  self.m_descLabel = cc.uiloader:seekNodeByName(self.m_bg2, "Text_desc")
  self.m_expBarBg = cc.uiloader:seekNodeByName(self.m_bg1, "Image_exp_bg")
  self.m_expPgBar = cc.ProgressTimer:create(display.newSprite("UI/scale9/lvjindutiao.png"))
  self.m_expPgBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  self.m_expPgBar:setMidpoint(cc.p(0, 0))
  self.m_expPgBar:setBarChangeRate(cc.p(1, 0))
  self.m_expPgBar:setPercentage(0)
  td.AddRelaPos(self.m_expBarBg, self.m_expPgBar)
  self.m_expLabel = td.CreateLabel("", nil, 16, td.OL_BLACK, 1)
  td.AddRelaPos(self.m_expPgBar, self.m_expLabel)
  self.m_evoLvl1 = td.CreateLabel("", td.WHITE, 18, td.OL_BLACK)
  td.AddRelaPos(self.m_panelEvo, self.m_evoLvl1, 1, cc.p(0.24, 0.72))
  self.m_evoLvl2 = td.CreateLabel("", td.WHITE, 18, td.OL_BLACK)
  td.AddRelaPos(self.m_panelEvo, self.m_evoLvl2, 1, cc.p(0.76, 0.72))
  self.m_replaceBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_replace")
  td.BtnAddTouch(self.m_replaceBtn, function()
    if self.m_heroData then
      self:ShowWeapons()
      td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    else
      local weaponUid = self.m_data.id
      self:close()
      g_MC:OpenModule(td.UIModule.WeaponDecompose, {id = weaponUid})
    end
  end)
  self.m_upgradeBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_upgrade_1")
  td.BtnAddTouch(self.m_upgradeBtn, handler(self, self.ShowUpgrade))
  td.BtnSetTitle(self.m_upgradeBtn, g_LM:getBy("a00078"))
  self.m_evoBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_evo_1")
  td.BtnAddTouch(self.m_evoBtn, handler(self, self.ShowEvolve))
  td.BtnSetTitle(self.m_evoBtn, g_LM:getBy("a00079"))
  self.m_btnYes = cc.uiloader:seekNodeByName(self.m_bg2, "Button_yes_4")
  td.BtnAddTouch(self.m_btnYes, handler(self, self.OnYesBtnClicked), nil, td.ButtonEffectType.Short)
  self.m_btnBack = cc.uiloader:seekNodeByName(self.m_bg2, "Button_back")
  td.BtnAddTouch(self.m_btnBack, function()
    self.m_upgExp = 0
    self:ShowInfo()
  end)
  td.BtnSetTitle(self.m_btnBack, g_LM:getBy("a00240"))
end
function WeaponDlg:UpdateBtnsState()
  self.m_upgradeBtn:setDisable(true)
  self.m_evoBtn:setDisable(true)
  self.m_replaceBtn:setDisable(true)
  if self.m_data then
    self.m_btnBack:setDisable(false)
    if self.m_opType ~= OpType.Upgrade then
      self.m_upgradeBtn:setDisable(false)
    end
    if self.m_opType ~= OpType.Evol then
      self.m_evoBtn:setDisable(false)
    end
  else
    self.m_btnBack:setDisable(true)
  end
  if self.m_opType == OpType.Info then
    if self.m_infoOnly == true then
      self.m_replaceBtn:setVisible(false)
      self.m_evoBtn:setVisible(false)
      self.m_upgradeBtn:setVisible(false)
    else
      self.m_upgradeBtn:setVisible(true)
      self.m_evoBtn:setVisible(true)
      if self.m_data.weaponInfo.quality <= self.m_data.star then
        self.m_evoBtn:setDisable(true)
      end
      self.m_btnYes:setVisible(false)
      self.m_btnBack:setVisible(false)
    end
  else
    self.m_upgradeBtn:setVisible(false)
    self.m_evoBtn:setVisible(false)
  end
  if self.m_opType ~= OpType.Replace then
    self.m_replaceBtn:setDisable(false)
    if self.m_heroData then
      td.ShowRP(self.m_replaceBtn, self.m_udMng:CanEquipNewWeapon(self.m_heroData.id, self.m_type))
    end
  end
end
function WeaponDlg:RefreshUI()
  self.m_txtExp:setString(" ")
  self.m_txtGold:setString(" ")
  if self.m_icon and not self.m_info then
    self.m_icon:removeFromParent()
    self.m_icon = nil
  end
  if self.m_careerIcon then
    self.m_careerIcon:removeFromParent()
    self.m_careerIcon = nil
  end
  local function createCareerIcon(info)
    self.m_careerIcon = display.newNode()
    self.m_careerIcon:setContentSize(300, 150)
    self.m_careerIcon:setAnchorPoint(0.5, 0.5)
    local icon = td.CreateCareerIcon(info.career)
    icon:setScale(0.5)
    td.AddRelaPos(self.m_careerIcon, icon, 1, cc.p(0.33, 0.5))
    local career
    if info.career == td.CareerType.Saber then
      career = td.CreateLabel(g_LM:getMode("career", td.CareerType.Saber), td.YELLOW, 18)
    elseif info.career == td.CareerType.Archer then
      career = td.CreateLabel(g_LM:getMode("career", td.CareerType.Archer), td.YELLOW, 18)
    elseif info.career == td.CareerType.Caster then
      career = td.CreateLabel(g_LM:getMode("career", td.CareerType.Caster), td.YELLOW, 18)
    end
    td.AddRelaPos(self.m_careerIcon, career, 1, cc.p(0.47, 0.5))
    local text = td.CreateLabel(g_LM:getBy("a00411"), td.GRAY, 18)
    td.AddRelaPos(self.m_careerIcon, text, 1, cc.p(0.62, 0.5))
    td.AddRelaPos(self.m_bg1, self.m_careerIcon, 1, cc.p(0.48, 0.42))
  end
  if self.m_info then
    createCareerIcon(self.m_info)
  end
  if self.m_data then
    createCareerIcon(self.m_data.weaponInfo)
  end
  for i, label in ipairs(self.m_vProLabel) do
    label:removeFromParent()
  end
  self.m_vProLabel = {}
  if self.m_data then
    self.m_expBarBg:setVisible(true)
    self.m_panelLevel:setVisible(true)
    self.m_bIsMax = self.m_data.level >= self.m_data.star * 5
    local weaponInfo = self.m_data.weaponInfo
    self.m_nameLabel:setString(weaponInfo.name)
    self.m_descLabel:setString(weaponInfo.desc)
    self:RefreshExpBar(self.m_data)
    self:RefreshSkill(weaponInfo.skill)
    self.m_icon = td.CreateWeaponIcon(self.m_data.weaponId, self.m_data.star)
    self.m_icon:setScale(0.75)
    td.AddRelaPos(self.m_weaponBg, self.m_icon, 1, cc.p(0.5, 0.5))
    if self.m_bIsMax then
      local starCost = weaponInfo.star_cost[self.m_data.star]
      if starCost then
      end
      local effect = td.CreateUIEffect(self.m_icon, "Spine/UI_effect/UI_tishikeyong_01", {loop = true, scale = 0.86})
    end
    local count = 0
    for type, var in pairs(self.m_data.property) do
      local typeLabel, valueLabel = td.GetWeaponPropLabel(type, var)
      typeLabel:align(display.LEFT_CENTER, 40 + count * 265, 120):addTo(self.m_bg1)
      valueLabel:align(display.LEFT_CENTER, 90 + count * 265, 120):addTo(self.m_bg1)
      table.insert(self.m_vProLabel, typeLabel)
      table.insert(self.m_vProLabel, valueLabel)
      count = count + 1
    end
  elseif not self.m_info then
    self.m_icon = display.newSprite("UI/hero/jia_icon.png")
    if not self.m_repData then
      self.m_expBarBg:setVisible(false)
      self.m_panelLevel:setVisible(false)
    end
    td.AddRelaPos(self.m_weaponBg, self.m_icon)
    self.m_nameLabel:setString("")
    self.m_descLabel:setString("")
    self.m_levelLabel:setString("")
    self.m_expPgBar:setPercentage(0)
    self.m_expLabel:setString("0/0")
    self.m_panelSkill:setVisible(false)
  end
  self:UpdateBtnsState()
end
function WeaponDlg:RefreshReplaceUI(bAni)
  if not self.m_repData then
    return
  end
  self.m_upgExp = self.m_upgExp or 0
  self.m_txtExp:setString(self.m_upgExp)
  self.m_txtGold:setString(self.m_upgExp / 2)
  self.m_icon:removeFromParent()
  self.m_icon = nil
  for i, label in ipairs(self.m_vProLabel) do
    label:removeFromParent()
  end
  self.m_vProLabel = {}
  local weaponInfo = self.m_repData.weaponInfo
  self.m_nameLabel:setString(weaponInfo.name)
  self.m_descLabel:setString(weaponInfo.desc)
  self:RefreshExpBar(self.m_repData, bAni)
  self.m_icon = td.CreateWeaponIcon(self.m_repData.weaponId, self.m_repData.star)
  self.m_icon:setScale(0.75)
  td.AddRelaPos(self.m_weaponBg, self.m_icon, 1, cc.p(0.5, 0.5))
  local count = 0
  for type, value in pairs(self.m_repData.property) do
    local oriValue = 0
    oriValue = self.m_data and (self.m_data.property[type] or 0)
    local typeLabel, valueLabel = td.GetWeaponPropLabel(type, value, value - oriValue)
    typeLabel:align(display.LEFT_CENTER, 40 + count * 180, 120):addTo(self.m_bg1)
    valueLabel:align(display.LEFT_CENTER, 90 + count * 180, 120):addTo(self.m_bg1)
    table.insert(self.m_vProLabel, typeLabel)
    table.insert(self.m_vProLabel, valueLabel)
    count = count + 1
  end
end
function WeaponDlg:RefreshExpBar(data, bAni)
  if data.level >= data.star * 5 then
    local maxExp = td.CalWeaponExp(data.star, data.level - 1, data.weaponInfo.quality)
    self.m_levelLabel:setString(" Max")
    self.m_expPgBar:setPercentage(100)
    self.m_expLabel:setString(string.format("%d/%d", maxExp, maxExp))
  else
    local curExp = data.exp
    local maxExp = td.CalWeaponExp(data.star, data.level, data.weaponInfo.quality)
    self.m_levelLabel:setString(tostring(data.level))
    self.m_expPgBar:setPercentage(curExp / maxExp * 100)
    self.m_expLabel:setString(string.format("%d/%d", curExp, maxExp))
  end
end
function WeaponDlg:RefreshSkill(skillId)
  local skillInfo = SkillInfoManager:GetInstance():GetInfo(skillId)
  if skillInfo then
    self.m_panelSkill:setVisible(true)
    self.m_panelSkill:getChildByName("Image_skill"):loadTexture(skillInfo.icon .. td.PNG_Suffix)
    self.m_panelSkill:getChildByName("Text_skill_name"):setString(skillInfo.name)
    self.m_panelSkill:getChildByName("Text_skill_desc"):setString(skillInfo.desc)
  else
    self.m_panelSkill:setVisible(false)
  end
end
function WeaponDlg:SetData(data)
  self.m_data = self.m_udMng:GetWeaponData(data.weaponId)
  self.m_heroData = data.heroData or self.m_heroData
  self.m_type = data.type or self.m_type
  if self.m_data then
    self.m_replaceBtn:setVisible(true)
    if self.m_heroData then
      td.BtnSetTitle(self.m_replaceBtn, g_LM:getBy("a00235"))
    else
      td.BtnSetTitle(self.m_replaceBtn, g_LM:getBy("a00006"))
    end
  else
    self.m_replaceBtn:setVisible(false)
    self.m_infoOnly = data.infoOnly
    self.m_info = self.m_siMng:GetWeaponInfo(data.weaponId)
  end
end
function WeaponDlg:ClearRightBg(cb)
  if self.m_UIListView then
    self.m_UIListView:removeFromParent()
    self.m_UIListView = nil
  end
  self.m_panelUp:setVisible(false)
  self.m_panelEvo:setVisible(false)
  self.m_panelInfo:setVisible(false)
  self.m_repData = nil
  self.m_vSelMeterial = {
    {},
    {}
  }
  self:PlayEnterAni(cb)
  self:RefreshUI()
end
function WeaponDlg:ShowInfo()
  self.m_opType = OpType.Info
  local function showInfo()
    self.m_panelInfo:setVisible(true)
    if self.m_infoOnly == true then
      self.m_nameLabel:setString(self.m_info.name)
      self.m_descLabel:setString(self.m_info.desc)
      self:RefreshSkill(self.m_info.skill)
      self.m_icon = td.CreateWeaponIcon(self.m_info.id, 1)
      self.m_icon:setScale(0.75)
      td.AddRelaPos(self.m_weaponBg, self.m_icon, 1, cc.p(0.5, 0.5))
      local count = 0
      for type, var in pairs(self.m_info.property[1]) do
        local typeLabel, valueLabel = td.GetWeaponPropLabel(type, var)
        typeLabel:align(display.LEFT_CENTER, 40 + count * 265, 120):addTo(self.m_bg1)
        valueLabel:align(display.LEFT_CENTER, 90 + count * 265, 120):addTo(self.m_bg1)
        count = count + 1
      end
    end
  end
  self:ClearRightBg(handler(self, showInfo))
end
function WeaponDlg:ShowWeapons()
  self.m_opType = OpType.Replace
  local function showWeapons()
    self.m_UIListView = cc.ui.UIListView.new({
      direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
      viewRect = cc.rect(20, 80, Item_Size.width, 350),
      touchOnContent = false,
      scale = self.m_scale
    })
    self.m_UIListView:onTouch(function(event)
      if event.name == "clicked" and event.item then
        local itemSize = event.item:getContentSize()
        local insideIndex = math.ceil(event.point.x / (itemSize.width / 3))
        self:OnWeaponClicked(event.itemPos, insideIndex)
      end
    end)
    self.m_UIListView:setName("ListView")
    self.m_UIListView:addTo(self.m_bg2)
    self.m_btnYes:setVisible(true)
    self.m_btnBack:setVisible(true)
    self:RefreshWeaponList()
  end
  self:ClearRightBg(handler(self, showWeapons))
end
function WeaponDlg:RefreshWeaponList()
  self.m_UIListView:removeAllItems()
  self.m_selIconSpr = nil
  self.m_vWeaponsData = self.m_udMng:GetIdleWeapons(self.m_heroData.heroInfo.career, self.m_type)
  local itemCount = math.ceil((table.nums(self.m_vWeaponsData) + 1) / 3)
  for i = 1, itemCount do
    local item = self:CreateWeaponItem(self.m_vWeaponsData, i)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
  self:OnWeaponClicked(1, 1)
end
function WeaponDlg:CreateWeaponItem(datas, pos)
  local content = display.newNode()
  content:scale(self.m_scale)
  content:setContentSize(Item_Size)
  for i = 1, 3 do
    local iconBg = display.newSprite("UI/scale9/wupingdikuang.png")
    iconBg:setScale(0.8, 0.8)
    iconBg:setTag(i)
    iconBg:align(display.LEFT_BOTTOM, 10 + 95 * (i - 1), 0):addTo(content)
    local idx = (pos - 1) * 3 + i - 1
    local iconSpr
    if pos == 1 and i == 1 then
      if self.m_data then
        local weaponinfo = StrongInfoManager:GetInstance():GetWeaponInfo(self.m_data.weaponId)
        iconSpr = td.CreateWeaponIcon(self.m_data.weaponId, self.m_data.star)
        iconSpr:scale(0.8)
      else
        iconSpr = display.newSprite("UI/hero/jia_icon.png")
      end
      iconSpr:setTag(1)
      td.AddRelaPos(iconBg, iconSpr)
    elseif datas[idx] then
      local weaponInfo = StrongInfoManager:GetInstance():GetWeaponInfo(datas[idx].weaponId)
      local iconSpr = td.IconWithStar(weaponInfo.icon .. td.PNG_Suffix, datas[idx].star, weaponInfo.quality)
      iconSpr:scale(0.8)
      iconSpr:setTag(1)
      td.AddRelaPos(iconBg, iconSpr)
    end
    local selSpr = display.newSprite("UI/common/huangse_xuanzhongkuang.png")
    selSpr:setVisible(false)
    selSpr:setName("selSpr")
    td.AddRelaPos(iconBg, selSpr)
    selSpr:setLocalZOrder(1)
  end
  local item = self.m_UIListView:newItem(content)
  item:setItemSize(Item_Size.width * self.m_scale, Item_Size.height * self.m_scale)
  return item
end
function WeaponDlg:OnWeaponClicked(itemPos, insideIndex)
  td.EnableButton(self.m_btnYes, true)
  local item = self.m_UIListView:getItemByPos(itemPos)
  local clickIndex = insideIndex
  local iconSpr = item:getContent():getChildByTag(clickIndex)
  local cellIndex = (itemPos - 1) * 3 + clickIndex - 1
  if iconSpr then
    if self.m_selIconSpr then
      self.m_selIconSpr:getChildByName("selSpr"):setVisible(false)
    end
    iconSpr:getChildByName("selSpr"):setVisible(true)
    self.m_selIconSpr = iconSpr
    self.m_repData = self.m_vWeaponsData[cellIndex]
  end
  if cellIndex == 0 then
    td.BtnSetTitle(self.m_btnYes, g_LM:getBy("a00096"))
    if self.m_data and GuideManager:GetInstance():IsForceGuideOver() then
      self.m_btnYes:setDisable(false)
    else
      self.m_btnYes:setDisable(true)
    end
    self:RefreshUI(self.m_data)
  else
    td.BtnSetTitle(self.m_btnYes, g_LM:getBy("a00086"))
    if self.m_repData then
      self.m_btnYes:setDisable(false)
      self.m_replaceBtn:setDisable(true)
      self.m_upgradeBtn:setDisable(true)
      self.m_evoBtn:setDisable(true)
      self.m_panelLevel:setVisible(true)
      self.m_expBarBg:setVisible(true)
      self:RefreshReplaceUI()
    else
      self.m_btnYes:setDisable(true)
    end
  end
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
end
function WeaponDlg:ShowUpgrade()
  self.m_opType = OpType.Upgrade
  local function upgrade()
    self.m_panelUp:setVisible(true)
    self.m_UIListView = cc.ui.UIListView.new({
      direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
      viewRect = cc.rect(0, 0, 280, 180),
      touchOnContent = false,
      scale = self.m_scale
    })
    self.m_UIListView:onTouch(function(event)
      if event.name == "clicked" then
        self:OnMaterialClicked(event)
      end
    end)
    self.m_UIListView:setName("ListView")
    self.m_UIListView:pos(45, 90):addTo(self.m_bg2)
    self:RefreshMaterialList()
    td.BtnSetTitle(self.m_btnYes, g_LM:getBy("a00009"))
    self.m_btnYes:setVisible(true)
    self.m_btnBack:setVisible(true)
  end
  self:ClearRightBg(upgrade)
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
end
function WeaponDlg:RefreshMaterialList()
  self.m_UIListView:removeAllItems()
  self.m_vSelMeterial = {
    {},
    {}
  }
  td.EnableButton(self.m_btnYes, false)
  self.m_vMeterial = {}
  local expItems = ItemInfoManager:GetInstance():GetExpItemInfos(2)
  for i, var in ipairs(expItems) do
    local haveNum = self.m_udMng:GetItemNum(var.id)
    if haveNum > 0 then
      local meterial = {
        type = 1,
        id = var.id,
        num = haveNum,
        exp = var.quantity
      }
      table.insert(self.m_vMeterial, meterial)
    end
  end
  local weapons = self.m_udMng:GetIdleWeapons()
  for i, weaponData in ipairs(weapons) do
    if weaponData.id ~= self.m_data.id then
      local weaponExp = td.CalWeaponProvideExp(weaponData.star, weaponData.level, weaponData.exp, weaponData.weaponInfo.quality)
      local meterial = {
        type = 2,
        id = weaponData.id,
        num = 1,
        exp = weaponExp
      }
      table.insert(self.m_vMeterial, meterial)
    end
  end
  local itemCount = math.max(math.ceil(table.nums(self.m_vMeterial) / 3), 3)
  for i = 1, itemCount do
    local item = self:CreateMeterialItem(self.m_vMeterial, i)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function WeaponDlg:CreateMeterialItem(datas, pos)
  local content = display.newNode()
  content:scale(self.m_scale)
  content:setContentSize(Item_Size)
  for i = 1, 3 do
    do
      local iconBg = display.newSprite("UI/scale9/wupingdikuang.png")
      iconBg:setScale(0.7)
      iconBg:setTag(i)
      iconBg:align(display.LEFT_BOTTOM, 10 + 95 * (i - 1), 0):addTo(content)
      local idx = (pos - 1) * 3 + i
      if datas[idx] then
        local iconSpr
        if datas[idx].type == 1 then
          iconSpr = td.CreateItemIcon(datas[idx].id, true)
          local numLabel = td.CreateLabel(datas[idx].num, td.WHITE, 24)
          td.AddRelaPos(iconBg, numLabel, 1, cc.p(0.5, 0.14))
          iconBg.numLabel = numLabel
        else
          local weaponData = self.m_udMng:GetWeaponData(datas[idx].id)
          local info = weaponData.weaponInfo
          iconSpr = td.CreateWeaponIcon(weaponData.weaponId, weaponData.star)
          local lvLabel = td.CreateLabel("LV." .. weaponData.level, td.WHITE, 24)
          td.AddRelaPos(iconBg, lvLabel, 1, cc.p(0.5, 0.14))
        end
        iconSpr:setName("icon")
        iconSpr:setScale(0.75)
        td.AddRelaPos(iconBg, iconSpr, 1, cc.p(0.5, 0.6))
        local delBtn = ccui.Button:create("UI/button/jian1_icon.png", "UI/button/jian2_icon.png")
        td.BtnAddTouch(delBtn, function()
          self:UpdateMaterial(iconBg, datas[idx], -1)
        end)
        delBtn:setVisible(false)
        td.AddRelaPos(iconBg, delBtn, 1, cc.p(0.8, 0.8))
        iconBg.delBtn = delBtn
      end
    end
  end
  local item = self.m_UIListView:newItem(content)
  item:setItemSize(Item_Size.width * self.m_scale, Item_Size.height * self.m_scale)
  return item
end
function WeaponDlg:OnMaterialClicked(event)
  local item = event.item
  if not item then
    return
  end
  if self.m_bIsMax then
    if self.m_data.star < self.m_data.weaponInfo.quality then
      td.alertErrorMsg(td.ErrorCode.EVOLUTION_LOW)
    else
      td.alertErrorMsg(td.ErrorCode.LEVEL_MAX)
    end
    return
  end
  local itemSize = item:getContentSize()
  local clickIndex = math.ceil(event.point.x / (itemSize.width / 3))
  local iconBg = item:getContent():getChildByTag(clickIndex)
  local cellIndex = (event.itemPos - 1) * 3 + clickIndex
  local seleItem = self.m_vMeterial[cellIndex]
  if seleItem then
    self.m_currIconBg = iconBg
    self.m_selectItem = seleItem
    self:UpdateMaterial(self.m_currIconBg, self.m_selectItem, 1)
  end
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
end
function WeaponDlg:UpdateMaterial(iconBg, seleItem, num)
  local selNum = self.m_vSelMeterial[seleItem.type][seleItem.id] or 0
  selNum = selNum + num
  if selNum > seleItem.num or selNum < 0 then
    return
  end
  if selNum == 0 then
    self.m_vSelMeterial[seleItem.type][seleItem.id] = nil
    iconBg.delBtn:setVisible(false)
  else
    self.m_vSelMeterial[seleItem.type][seleItem.id] = selNum
    iconBg.delBtn:setVisible(true)
  end
  self.m_repData = self:MakeRepData()
  if self.m_repData.level >= self.m_repData.star * 5 then
    self.m_bIsMax = true
  else
    self.m_bIsMax = false
  end
  self:RefreshReplaceUI()
  if seleItem.type == 1 then
    iconBg.numLabel:setString(selNum .. "/" .. seleItem.num)
  end
  if 0 < table.nums(self.m_vSelMeterial[1]) or 0 < table.nums(self.m_vSelMeterial[2]) then
    td.EnableButton(self.m_btnYes, true)
  else
    td.EnableButton(self.m_btnYes, false)
  end
end
function WeaponDlg:MakeRepData()
  local repData = clone(self.m_data)
  local curExp = repData.exp
  for id, num in pairs(self.m_vSelMeterial[1]) do
    local itemExp = self.m_iiMng:GetItemExp(id)
    curExp = curExp + itemExp * num
  end
  for id, num in pairs(self.m_vSelMeterial[2]) do
    local weaponData = self.m_udMng:GetWeaponData(id)
    local itemExp = td.CalWeaponProvideExp(weaponData.star, weaponData.level, weaponData.exp, weaponData.weaponInfo.quality)
    curExp = curExp + itemExp
  end
  self.m_upgExp = curExp - repData.exp
  local maxExp = td.CalWeaponExp(repData.star, repData.level, repData.weaponInfo.quality)
  local upLevel = 0
  while curExp >= maxExp do
    upLevel = upLevel + 1
    if repData.level + upLevel >= repData.star * 5 then
      curExp = 0
    else
      curExp = curExp - maxExp
    end
    maxExp = td.CalWeaponExp(repData.star, repData.level + upLevel, repData.weaponInfo.quality)
  end
  repData.exp = curExp
  repData.level = repData.level + upLevel
  self.m_siMng:SaveWeaponAttr(repData)
  return repData
end
function WeaponDlg:ShowEvolve()
  self.m_opType = OpType.Evol
  local function evolve()
    self.m_panelEvo:setVisible(true)
    local fullData1 = clone(self.m_data)
    fullData1.level = fullData1.star * 5
    self.m_siMng:SaveWeaponAttr(fullData1)
    local fullData2 = clone(self.m_data)
    fullData2.star = math.min(fullData2.star + 1, fullData2.weaponInfo.quality)
    fullData2.level = fullData2.star * 5
    self.m_siMng:SaveWeaponAttr(fullData2)
    local weaponInfo = fullData1.weaponInfo
    local imgBg1 = cc.uiloader:seekNodeByName(self.m_panelEvo, "Image_4")
    imgBg1:removeAllChildren()
    local imgBg2 = cc.uiloader:seekNodeByName(self.m_panelEvo, "Image_5")
    imgBg2:removeAllChildren()
    local icon1 = td.CreateWeaponIcon(fullData1.weaponId, fullData1.star)
    icon1:setScale(0.8)
    td.AddRelaPos(imgBg1, icon1)
    local icon2 = td.CreateWeaponIcon(fullData2.weaponId, fullData2.star)
    icon2:setScale(0.8)
    td.AddRelaPos(imgBg2, icon2)
    if self.m_data.level < fullData1.star * 5 and fullData1.star < weaponInfo.quality then
      self.m_evoLvl1:setColor(td.RED)
    else
      self.m_evoLvl1:setColor(td.WHITE)
    end
    if fullData1.star >= weaponInfo.quality then
      self.m_evoLvl1:setString("Max")
      self.m_evoLvl2:setString("Max")
    else
      self.m_evoLvl1:setString("LV." .. fullData1.level)
      self.m_evoLvl2:setString("LV." .. fullData2.level)
    end
    local bCanEvo = self:CheckCanEvolve(fullData1.star, fullData1.level, weaponInfo)
    local starCost = weaponInfo.star_cost[fullData1.star]
    if starCost then
      for i, var in ipairs(starCost) do
        local itemMainBg = cc.uiloader:seekNodeByName(self.m_panelEvo, "Image_item" .. i)
        local itemBg = cc.uiloader:seekNodeByName(itemMainBg, "item_bg")
        itemBg:removeAllChildren()
        local itemIcon = TouchIcon.new(var.itemId, true)
        td.AddRelaPos(itemBg, itemIcon)
        local haveNum = self.m_udMng:GetItemNum(var.itemId)
        local numLabel = td.CreateLabel(string.format("%d/%d", haveNum, var.num), td.WHITE, 26, td.OL_BLACK)
        td.AddRelaPos(itemBg, numLabel, 1, cc.p(0.5, -0.25))
        if haveNum < var.num then
          numLabel:setColor(td.RED)
        end
      end
    end
    local proBg = cc.uiloader:seekNodeByName(self.m_panelEvo, "Image_proBg")
    proBg:removeAllChildren()
    local tmp = {fullData1, fullData2}
    for i = 1, 2 do
      local count = 0
      for type, var in pairs(tmp[i].property) do
        local typeLabel, valueLabel = td.GetWeaponPropLabel(type, var)
        typeLabel:align(display.LEFT_CENTER, 10 + 170 * (i - 1), 30 - (count - 1) * 30):addTo(proBg)
        valueLabel:align(display.LEFT_CENTER, 60 + 170 * (i - 1), 30 - (count - 1) * 30):addTo(proBg)
        count = count + 1
      end
    end
    td.EnableButton(self.m_btnYes, bCanEvo)
    td.BtnSetTitle(self.m_btnYes, g_LM:getBy("a00009"))
    self.m_btnYes:setVisible(true)
    self.m_btnBack:setVisible(true)
  end
  self:ClearRightBg(handler(self, evolve))
end
function WeaponDlg:CheckCanEvolve(star, level, info)
  local bResult, errorCode = true, td.ErrorCode.SUCCESS
  if star >= info.quality then
    bResult, errorCode = false, td.ErrorCode.LEVEL_MAX
  elseif level < star * 5 then
    bResult, errorCode = false, td.ErrorCode.LEVEL_LOW
  else
    local starCost = info.star_cost[star]
    for i, var in ipairs(starCost) do
      local haveNum = self.m_udMng:GetItemNum(var.itemId)
      if haveNum < var.num then
        bResult, errorCode = false, td.ErrorCode.MATERIAL_NOT_ENOUGH
      end
    end
  end
  return bResult, errorCode
end
function WeaponDlg:RefreshEvolve()
end
function WeaponDlg:OnYesBtnClicked()
  if self.m_opType == OpType.Replace then
    if self.m_repData then
      self:SendEquipRequest(self.m_repData.id, 1)
    elseif self.m_data then
      self:SendEquipRequest(self.m_data.id, 0)
    end
  elseif self.m_opType == OpType.Upgrade then
    if self.m_data and (0 < table.nums(self.m_vSelMeterial[1]) or 0 < table.nums(self.m_vSelMeterial[2])) then
      do
        local meterials = {}
        local weapons = {}
        local hasWeapon = false
        for _id, _num in pairs(self.m_vSelMeterial[1]) do
          table.insert(meterials, {id = _id, num = _num})
        end
        for _id, _num in pairs(self.m_vSelMeterial[2]) do
          table.insert(weapons, _id)
          local weaponData = UserDataManager:GetInstance():GetWeaponData(_id)
          if weaponData.weaponInfo.quality >= 3 then
            hasWeapon = true
          end
        end
        local function sendUpgReq()
          local data = {
            id = self.m_data.id,
            itemProto = meterials,
            weapon_id = weapons
          }
          self:SendUpgradeRequest(data)
        end
        if not hasWeapon then
          sendUpgReq()
        else
          local conStr = "\230\130\168\233\128\137\228\184\173\231\154\132\231\137\169\229\147\129\228\184\173\229\140\133\229\144\1713\230\152\159\228\187\165\228\184\138\231\154\132\232\163\133\229\164\135\239\188\140\231\161\174\229\174\154\231\187\167\231\187\173\229\144\151\239\188\159"
          local button1 = {
            text = g_LM:getBy("a00009"),
            callFunc = handler(self, sendUpgReq)
          }
          local button2 = {
            text = g_LM:getBy("a00116")
          }
          local data = {
            size = cc.size(454, 300),
            content = conStr,
            buttons = {button1, button2}
          }
          local messageBox = require("app.layers.MessageBoxDlg").new(data)
          messageBox:Show()
        end
      end
    end
  elseif self.m_opType == OpType.Evol then
    local bResult, errorCode = self:CheckCanEvolve(self.m_data.star, self.m_data.level, self.m_data.weaponInfo)
    if bResult then
      local data = {
        id = self.m_data.id
      }
      self:SendUpgradeRequest(data)
    else
      td.alertErrorMsg(errorCode)
    end
  end
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
end
function WeaponDlg:AddEvent()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if not self.m_bActionOver then
      return true
    end
    if self.m_UIListView then
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
        self.m_bTouchInList = true
      end
    else
      local tmpPos, bg
      if self.m_bg2:isVisible() then
        bg = self.m_panelBg
      else
        bg = self.m_bg1
      end
      tmpPos = bg:convertToNodeSpace(touch:getLocation())
      if not isTouchInNode(bg, tmpPos) then
        self:performWithDelay(function()
          self:close()
          td.dispatchEvent(td.GUIDE_CONTINUE)
        end, 0.1)
      end
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bTouchInList then
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
    if self.m_bTouchInList then
      self.m_UIListView:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
      self.m_bTouchInList = false
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
function WeaponDlg:AddHttpListener()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.EquipWeapon_req, handler(self, self.EquipCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.WeaponStreng_req, handler(self, self.UpgradeCallback))
end
function WeaponDlg:RemoveHttpListener()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.EquipWeapon_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.WeaponStreng_req)
end
function WeaponDlg:OnWealthChanged()
  WeaponDlg.super.OnWealthChanged(self)
  if self.m_opType == OpType.Evol then
    self:ShowEvolve()
  end
end
function WeaponDlg:OnItemUpdate()
  WeaponDlg.super.OnItemUpdate(self)
  if self.m_opType == OpType.Evol then
    self:ShowEvolve()
  end
end
function WeaponDlg:SendEquipRequest(wid, type)
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.EquipWeapon_req
  Msg.sendData = {
    heroId = self.m_heroData.id,
    weaponId = wid,
    state = type
  }
  Msg.cbData = clone(Msg.sendData)
  tdRequest:Send(Msg)
end
function WeaponDlg:EquipCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    if cbData.state == 0 then
      self.m_data.hero_id = 0
      if self.m_type == td.WeaponType.Weapon then
        self.m_heroData.attackSite = 0
      else
        self.m_heroData.defSite = 0
      end
      self:SetData({weaponId = 0})
    else
      if self.m_data then
        self.m_data.hero_id = 0
      end
      if self.m_type == td.WeaponType.Weapon then
        self.m_heroData.attackSite = cbData.weaponId
      else
        self.m_heroData.defSite = cbData.weaponId
      end
      local newData = self.m_udMng:GetWeaponData(cbData.weaponId)
      newData.hero_id = self.m_heroData.id
      self:SetData({
        weaponId = cbData.weaponId
      })
    end
    self:RefreshUI()
    self:RefreshWeaponList()
    td.dispatchEvent(td.HERO_WEAPON_UPGRADE)
    self.m_udMng:UpdateTotalPower()
  end
end
function WeaponDlg:SendUpgradeRequest(data)
  local Msg = {}
  Msg.msgType = td.RequestID.WeaponStreng_req
  Msg.sendData = data
  Msg.cbData = clone(Msg.sendData)
  TDHttpRequest:getInstance():Send(Msg)
end
function WeaponDlg:UpgradeCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    if cbData.itemProto and cbData.weapon_id then
      do
        local _weapons = {}
        local totalExp = 0
        for i, var in ipairs(cbData.itemProto) do
          totalExp = totalExp + self.m_iiMng:GetItemExp(var.id) * var.num
        end
        for i, id in ipairs(cbData.weapon_id) do
          local weaponData = self.m_udMng:GetWeaponData(id)
          table.insert(_weapons, weaponData)
          totalExp = totalExp + td.CalWeaponProvideExp(weaponData.star, weaponData.level, weaponData.exp, weaponData.weaponInfo.quality)
          self.m_udMng:DeleteWeaponData(id)
        end
        self.m_panelBg:setVisible(false)
        local function upgradeCallback()
          self.m_panelBg:setVisible(true)
          self.m_siMng:UpdateWeaponData(cbData.id, totalExp)
          self:SetData({
            weaponId = cbData.id
          })
          self:RefreshUI()
          self:RefreshMaterialList()
          self.m_upgExp = 0
          td.dispatchEvent(td.HERO_WEAPON_UPGRADE)
        end
        local data = {
          weaponData = self.m_data,
          materials = cbData.itemProto,
          weapons = _weapons
        }
        local upgradeView = require("app.layers.MainMenuUI.WeaponUpgradeEffect").new(data, upgradeCallback)
        td.popView(upgradeView)
      end
    else
      self.m_siMng:UpdateWeaponData(cbData.id)
      self:SetData({
        weaponId = cbData.id
      })
      self:ShowEvolve()
      td.dispatchEvent(td.HERO_WEAPON_UPGRADE)
      local data = {
        data = self.m_data,
        type = "Equipment"
      }
      local evoWindow = require("app.layers.CommonEvoDlg").new(data)
      td.popView(evoWindow)
    end
  end
end
return WeaponDlg
