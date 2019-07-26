local BaseDlg = require("app.layers.BaseDlg")
local TabButton = require("app.widgets.TabButton")
local ActorInfoManager = require("app.info.ActorInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local UserDataManager = require("app.UserDataManager")
local UnitDataManager = require("app.UnitDataManager")
local UnitGizmo = require("app.widgets.UnitGizmo")
local scheduler = require("framework.scheduler")
local GuideManager = require("app.GuideManager")
local UnitDlg = class("UnitDlg", BaseDlg)
UnitDlg.CounterConfig = {
  [td.CareerType.Saber] = {
    name = g_LM:getBy("rt00004")
  },
  [td.CareerType.Archer] = {
    name = g_LM:getBy("rt00008")
  },
  [td.CareerType.Caster] = {
    name = g_LM:getBy("rt00009")
  }
}
local RefreshType = {Evo = 1, LevelUp = 2}
function UnitDlg:ctor()
  UnitDlg.super.ctor(self, 255, true)
  self.udMng = UserDataManager:GetInstance()
  self.unitMng = UnitDataManager:GetInstance()
  self.aiMng = ActorInfoManager:GetInstance()
  self.stiMng = StrongInfoManager:GetInstance()
  self.m_uiId = td.UIModule.Camp
  self.soldierData = nil
  self.m_campIndex = -1
  self.m_soldierIndex = -1
  self.soldierId = 0
  self.curSoldierLevel = 0
  self.m_bUnlock = true
  self.m_tabs = {}
  self.m_unitSpines = {}
  self.m_availableEffects = {}
  self.m_stars = {}
  self:InitUI()
end
function UnitDlg:onEnter()
  UnitDlg.super.onEnter(self)
  self:CreateForgroundMask()
  self.m_campIndex = self.m_vEnterSubIndex[1] or 1
  self:AddTabs()
  self:AddListeners()
  self:OnTabClicked(self.m_campIndex)
  if self.m_vEnterSubIndex[2] then
    self:OnSoldierIconClicked(self.m_vEnterSubIndex[2])
  end
  self:PlayEnterAni(function()
    if GuideManager:GetInstance():IsForceGuideOver() then
      self.weakGuideScheduler = scheduler.scheduleGlobal(handler(self, self.WeakGuide), 5)
    end
    self:CheckGuide()
    self:performWithDelay(function()
      self:AddBtnEvent()
      self:RemoveForgroundMask()
    end, 0.1)
  end)
end
function UnitDlg:onExit()
  if self.weakGuideScheduler then
    scheduler.unscheduleGlobal(self.weakGuideScheduler)
    self.weakGuideScheduler = nil
  end
  UnitDlg.super.onExit(self)
end
function UnitDlg:InitUI()
  self:LoadUI("CCS/UnitDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Bottom, true)
  self:SetTitle(td.Word_Path .. "wenzi_bingying.png")
  self.panelMid = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_mid")
  self.panelBtm = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bottom")
  local whRatio = display.width / display.height
  if whRatio > 1.5 then
    self.panelMid:setPositionY((display.size.height - 640 * self.m_scale) / 2)
  else
    self.panelMid:setPositionY((display.size.height - 768 * self.m_scale) / 2)
  end
  self.m_unitsBg = cc.uiloader:seekNodeByName(self.panelBtm, "Node_units_bg")
  self.m_btmButtons = {}
  for i = 1, 6 do
    local btmBtn = cc.uiloader:seekNodeByName(self.panelBtm, "Button_soldier" .. i)
    table.insert(self.m_btmButtons, btmBtn)
  end
  self.panelTabs = cc.uiloader:seekNodeByName(self.panelMid, "Left")
  self.panelUnitAttr = cc.uiloader:seekNodeByName(self.panelMid, "Panel_unit_attr")
  self.panelUnitSkill = cc.uiloader:seekNodeByName(self.panelMid, "Panel_unit_skill")
  self.panelUnitTrain = cc.uiloader:seekNodeByName(self.panelMid, "Panel_unit_train")
  local labelTitle = cc.uiloader:seekNodeByName(self.panelUnitAttr, "Text_title")
  labelTitle:setString(g_LM:getBy("a00247"))
  labelTitle = cc.uiloader:seekNodeByName(self.panelUnitSkill, "Text_title")
  labelTitle:setString(g_LM:getBy("\231\174\128 \228\187\139"))
  labelTitle = cc.uiloader:seekNodeByName(self.panelUnitTrain, "Text_title")
  labelTitle:setString(g_LM:getBy("\232\174\173 \231\187\131"))
  self.panelExp = cc.uiloader:seekNodeByName(self.panelMid, "Panel_exp")
  self.panelCamp = cc.uiloader:seekNodeByName(self.panelMid, "Panel_camp_anim")
  self.lvLabel = cc.uiloader:seekNodeByName(self.panelExp, "Text_level")
  self.soldierNameLabel = cc.uiloader:seekNodeByName(self.panelMid, "Text_soldier_name")
  self.campNameLabel = cc.uiloader:seekNodeByName(self.panelMid, "Text_camp_name")
  self.skillDesc = cc.uiloader:seekNodeByName(self.panelUnitSkill, "Text_desc")
  self.trainFeeLabel = cc.uiloader:seekNodeByName(self.panelUnitTrain, "Text_fee")
  self.trainTimeLabel = cc.uiloader:seekNodeByName(self.panelUnitTrain, "Text_time")
  self.trainSpaceLabel = cc.uiloader:seekNodeByName(self.panelUnitTrain, "Text_space")
  self.trainCDLabel = cc.uiloader:seekNodeByName(self.panelUnitTrain, "Text_cd")
  self.trainQueueLabel = cc.uiloader:seekNodeByName(self.panelUnitTrain, "Text_queue")
  local barBg = cc.uiloader:seekNodeByName(self.panelExp, "Image_exp_bg")
  self.m_expPgBar = cc.ProgressTimer:create(display.newSprite("UI/hero/lvse_jindutiao.png"))
  self.m_expPgBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  self.m_expPgBar:setMidpoint(cc.p(0, 0))
  self.m_expPgBar:setBarChangeRate(cc.p(1, 0))
  self.m_expPgBar:setPercentage(0)
  td.AddRelaPos(barBg, self.m_expPgBar)
  self.m_expLabel = td.CreateLabel("", nil, 16, td.OL_BLACK, 1)
  td.AddRelaPos(self.m_expPgBar, self.m_expLabel)
  self.btnUpgrade = cc.uiloader:seekNodeByName(self.panelExp, "Button_upgrade")
  td.BtnSetTitle(self.btnUpgrade, g_LM:getBy("a00025"))
  self.btnSkill = cc.uiloader:seekNodeByName(self.panelUnitSkill, "Button_skill")
  td.BtnSetTitle(self.btnSkill, g_LM:getBy("a00118"))
  self.btnTrain = cc.uiloader:seekNodeByName(self.panelUnitTrain, "Button_train")
  td.BtnSetTitle(self.btnTrain, g_LM:getBy("\232\174\173 \231\187\131"))
  self.btnRestrain = cc.uiloader:seekNodeByName(self.panelCamp, "Button_restrain")
  local vStr = {
    td.Property.Atk,
    td.Property.HP,
    td.Property.Def,
    td.Property.AtkSp,
    td.Property.Dodge,
    td.Property.Crit
  }
  local vPos = {
    cc.p(71, -30),
    cc.p(186, -30),
    cc.p(301, -30),
    cc.p(71, -80),
    cc.p(186, -80),
    cc.p(301, -80)
  }
  for i, var in ipairs(vStr) do
    local label = td.CreateLabel(g_LM:getMode("prop", var), td.LIGHT_BLUE, 20)
    label:setAnchorPoint(1, 0.5)
    label:setPosition(vPos[i])
    label:addTo(self.panelUnitAttr)
  end
end
function UnitDlg:PlayEnterAni(cb)
  for i = 1, 6 do
    local tab = cc.uiloader:seekNodeByName(self.panelTabs, "tab" .. i)
    tab:setOpacity(0)
    tab:setRotation(30)
    tab:runAction(cca.seq({
      cca.delay((i + 1) * 0.1),
      cca.spawn({
        cca.fadeIn(0.2),
        cca.rotateBy(0.2, -30)
      })
    }))
  end
  local positions = {
    {x = 38, y = 113},
    {x = 300, y = 20},
    {x = 34, y = 225}
  }
  self.panelCamp:runAction(cca.seq({
    cca.cb(function()
      local laserEffects = {}
      for i = 1, 3 do
        local laserEffect = SkeletonUnit:create("Spine/UI_effect/UI_yingxiongtiao_0" .. i + 1)
        if i == 1 then
          laserEffect:pos(positions[i].x, positions[i].y):addTo(self.panelCamp)
        else
          laserEffect:pos(positions[i].x, positions[i].y):addTo(laserEffects[1])
        end
        laserEffect:PlayAni("animation", false)
        table.insert(laserEffects, laserEffect)
      end
    end),
    cca.delay(0.85),
    cca.cb(function()
      laserEffects = {}
      for i = 1, 3 do
        local laserEffect = SkeletonUnit:create("Spine/UI_effect/UI_yingxiongtiao_0" .. i + 1)
        if i == 1 then
          laserEffect:pos(positions[i].x, positions[i].y):addTo(self.panelCamp)
        else
          laserEffect:pos(positions[i].x, positions[i].y):addTo(laserEffects[1])
        end
        table.insert(laserEffects, laserEffect)
      end
    end)
  }))
  local unitsBg = SkeletonUnit:create("Spine/UI_effect/UI_bingyingxuanze_01")
  unitsBg:pos(568, 55):addTo(self.m_unitsBg)
  unitsBg:PlayAni("animation", true)
  unitsBg:performWithDelay(function()
    unitsBg:setTimeScale(0)
    cb()
  end, 1.2)
  self.m_unitsBg:runAction(cca.seq({
    cca.moveTo(0.2, 0, 25),
    cca.moveTo(0.05, 0, -15),
    cca.moveTo(0.05, 0, 0),
    cca.delay(0.35),
    cca.cb(function()
      local btmLaserEffect = SkeletonUnit:create("Spine/UI_effect/UI_bingyingxuanze_02")
      btmLaserEffect:pos(568, 55):addTo(self.panelBtm)
      btmLaserEffect:setLocalZOrder(999)
      btmLaserEffect:PlayAni("animation", false)
    end)
  }))
  for i = 1, #self.m_btmButtons do
    do
      local btn = self.m_btmButtons[i]
      btn:runAction(cca.seq({
        cca.delay(0.3 + i * 0.1),
        cca.cb(function()
          btn:setVisible(true)
        end),
        cca.scaleTo(0.15, 1.1),
        cca.scaleTo(0.05, 0.9),
        cca.scaleTo(0.05, 1)
      }))
    end
  end
  local pedestal = cc.uiloader:seekNodeByName(self.panelCamp, "Panel_pedestal")
  pedestal:runAction(cca.seq({
    cca.delay(0.3),
    cca.fadeIn(0.3, 1)
  }))
  local pedestalEffect = SkeletonUnit:create("Spine/UI_effect/UI_bingyingyuanhuan_01")
  pedestalEffect:setVisible(false)
  pedestalEffect:pos(172, 70):addTo(self.panelCamp)
  pedestalEffect:runAction(cca.seq({
    cca.delay(0.5),
    cca.cb(function()
      pedestalEffect:setVisible(true)
      pedestalEffect:PlayAni("animation", true)
    end)
  }))
end
function UnitDlg:RefreshUI(refreshType)
  for i, val in ipairs(self.m_availableEffects) do
    val:removeFromParent()
  end
  self.m_availableEffects = {}
  self.soldierData = self.unitMng:GetSoldierData(self.soldierId)
  if not self.soldierData then
    self.soldierData = self.stiMng:MakeSoldierData({
      role_id = self.soldierId,
      star = 1,
      level = 1,
      exp = 0,
      skill_level = 1
    }, self.udMng:GetBoostData())
  end
  self.soldierInfo = self.soldierData.soldierInfo
  self.curSoldierLevel = self.soldierData.level
  self.lvLabel:setString("LV." .. self.soldierData.level)
  self.soldierNameLabel:setString(self.soldierInfo.name)
  local curExp, maxExp = self.soldierData.exp, td.CalSoldierExp(self.soldierData.star, self.soldierData.level, self.soldierData.quality)
  local curPercent = self.m_expPgBar:getPercentage()
  local time = math.abs(curPercent / 100 - curExp / maxExp)
  self.m_expPgBar:stopAllActions()
  self.m_expPgBar:runAction(cc.EaseBackOut:create(cca.progressTo(time, curExp / maxExp * 100)))
  self.m_expLabel:setString(string.format("%d/%d", curExp, maxExp))
  self:UpdateProp()
  self:UpdateSkill()
  self:RefreshRatingIcon(self.soldierId)
  self:UpdateTrainingInfo()
  self:CreateCampSpine()
  self:CreateUnitSpine(self.soldierInfo.image)
  if refreshType ~= RefreshType.LevelUp then
    self:RefreshStars(self.soldierData)
  end
  self:RefreshRP()
  self:RefreshButtons()
end
function UnitDlg:RefreshSoldierNum(event)
  local roleId = tonumber(event:getDataString())
  if math.floor(roleId / 100) == self.m_campIndex then
    local soldierInfo = self.stiMng:GetSoldierStrongInfo(roleId)
    local numLabel = self.m_btmButtons[roleId % 100]:getChildByName("number")
    numLabel:setString(string.format("%d/%d", self.unitMng:GetSoldierNum(roleId), soldierInfo.storage))
    if roleId == self.soldierId then
      local plan = self.unitMng:GetPlan(self.soldierId)
      local trainNum = plan and plan.num or 0
      self.trainQueueLabel:setString(string.format("%d/%d", trainNum, td.GetConst("queue_size")))
    end
  end
end
function UnitDlg:RefreshStars(soldierData)
  for i, star in ipairs(self.m_stars) do
    star:stopAllActions()
    star:removeFromParent()
  end
  self.m_stars = {}
  for i = 1, 4 do
    local starIcon = cc.uiloader:seekNodeByName(self.panelCamp, "Image_star" .. i)
    if i <= soldierData.quality then
      starIcon:setVisible(true)
      starIcon:loadTexture("UI/icon/xingxing2_icon.png")
      if i <= soldierData.star then
        do
          local star = display.newSprite("UI/icon/xingxing_icon.png")
          star:setScale(3, 3)
          td.AddRelaPos(starIcon, star)
          star:setVisible(false)
          table.insert(self.m_stars, star)
          star:runAction(cca.seq({
            cca.delay((i - 1) * 0.15),
            cca.cb(function()
              star:setVisible(true)
            end),
            cca.scaleTo(0.1, 1.2)
          }))
        end
      end
    else
      starIcon:setVisible(false)
    end
  end
end
function UnitDlg:RefreshRatingIcon(soldierId)
  if self.m_ratingIcon then
    self.m_ratingIcon:removeFromParent()
    self.m_ratingIcon = nil
  end
  self.m_ratingIcon = td.CreateRatingIcon(self.soldierInfo.rate)
  td.AddRelaPos(self.panelCamp, self.m_ratingIcon, 1, cc.p(0.05, 1))
end
function UnitDlg:RefreshButtons()
  self.btnUpgrade:setDisable(false)
  if self.m_soldierIndex <= 4 then
    self.btnSkill:setVisible(false)
  else
    self.btnSkill:setVisible(true)
  end
  if self.m_bUnlock then
    self.btnTrain:setDisable(false)
    self.btnSkill:setDisable(false)
    local soldierData = self.soldierData
    if soldierData.level >= soldierData.star * 10 then
      if soldierData.star >= soldierData.quality then
        td.BtnSetTitle(self.btnUpgrade, g_LM:getBy("a00391"))
        self.btnUpgrade:setDisable(true)
      else
        td.BtnSetTitle(self.btnUpgrade, g_LM:getBy("a00079"))
      end
    else
      td.BtnSetTitle(self.btnUpgrade, g_LM:getBy("a00025"))
    end
  else
    self.btnTrain:setDisable(true)
    self.btnSkill:setDisable(true)
    td.BtnSetTitle(self.btnUpgrade, g_LM:getBy("a00256"))
  end
end
function UnitDlg:RefreshRP()
  if not self.m_bUnlock then
    local rp = SkeletonUnit:create("Spine/UI_effect/UI_shengjitishi_02")
    rp:PlayAni("animation")
    td.ShowRP(self.btnUpgrade, true, cc.p(0.5, 0.5), rp)
    return
  end
  local canUpg = self.unitMng:IsSoldierCanUpgrade(self.soldierId)
  local canEvo, errorCode = self.unitMng:IsRoleCanEvo(self.soldierId)
  if canUpg or canEvo then
    local rp = SkeletonUnit:create("Spine/UI_effect/UI_shengjitishi_02")
    rp:PlayAni("animation")
    td.ShowRP(self.btnUpgrade, true, cc.p(0.5, 0.5), rp)
  else
    td.ShowRP(self.btnUpgrade, false)
  end
  td.ShowRP(self.m_tabs[self.m_campIndex], false)
end
function UnitDlg:UpdateProp()
  local info = self.soldierInfo
  local data = {
    info.property[td.Property.Atk].value,
    info.property[td.Property.HP].value,
    info.property[td.Property.Def].value,
    60 / info.property[td.Property.AtkSp].value,
    string.format("%d%%", info.property[td.Property.Dodge].value),
    string.format("%d%%", info.property[td.Property.Crit].value)
  }
  for i = 1, 6 do
    local numLabel = cc.uiloader:seekNodeByName(self.panelUnitAttr, "Text_prop_" .. i)
    numLabel:setString(data[i])
  end
end
function UnitDlg:UpdateSkill()
  self.skillDesc:setString(self.soldierInfo.ro_desc)
end
function UnitDlg:UpdateTrainingInfo()
  local info = self.stiMng:GetSoldierStrongInfo(self.soldierId)
  self.trainFeeLabel:setString("x" .. info.create_cost)
  self.trainTimeLabel:setString(string.format("%d\231\167\146", info.create_time))
  self.trainSpaceLabel:setString(self.soldierInfo.space)
  self.trainCDLabel:setString(string.format("%d\231\167\146", self.soldierInfo.role_cd))
  local plan = self.unitMng:GetPlan(self.soldierId)
  local trainNum = plan and plan.num or 0
  self.trainQueueLabel:setString(string.format("%d/%d", trainNum, td.GetConst("queue_size")))
end
function UnitDlg:AddTabs()
  local baseLevel = UserDataManager:GetInstance():GetBaseCampLevel()
  for i = 1, 6 do
    do
      local tab = cc.uiloader:seekNodeByName(self.panelTabs, "tab" .. i)
      td.BtnAddTouch(tab, function()
        self:OnTabClicked(i)
        td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
      end)
      for j = 1, 6 do
        local soldierId = tonumber(tostring(i) .. "0" .. tostring(j))
        local canEvo, errorMsg = self.unitMng:IsRoleCanEvo(soldierId)
        if canEvo then
          td.ShowRP(tab, true)
          break
        end
      end
      table.insert(self.m_tabs, tab)
    end
  end
end
function UnitDlg:OnTabClicked(index)
  if self.m_campIndex ~= -1 then
    self.m_tabs[self.m_campIndex]:getChildByTag(2):setVisible(false)
    self.m_tabs[self.m_campIndex]:setScale(0.8)
  end
  self.m_campIndex = index
  self.m_tabs[self.m_campIndex]:getChildByTag(2):setVisible(true)
  self.m_tabs[self.m_campIndex]:setScale(1)
  local campInfo = ActorInfoManager:GetInstance():GetCampInfo(self.m_campIndex)
  self.campNameLabel:setString(campInfo.name)
  self:UpdateSoldierIcon(campInfo.career)
  for i = 6, 1, -1 do
    local soldierId = tonumber(self.m_campIndex .. "0" .. i)
    if self.unitMng:IsRoleUnlock(soldierId) then
      self:OnSoldierIconClicked(i)
      break
    end
  end
  if self.careerIcon then
    self.careerIcon:removeFromParent()
    self.careerIcon = nil
  end
  self.careerIcon = td.CreateCareerIcon(campInfo.career)
  self.careerIcon:scale(0.7):pos(330, 360):addTo(self.panelCamp)
  self:WeakGuide()
end
function UnitDlg:OnSoldierIconClicked(index)
  local soldierId = tonumber(self.m_campIndex .. "0" .. index)
  if self.m_bUnlock and self.soldierId == soldierId then
    return
  end
  self.m_bUnlock = self.unitMng:IsRoleUnlock(soldierId)
  self.m_soldierIndex = index
  self.soldierId = soldierId
  for i = 1, 6 do
    local soldierBtn = self.m_btmButtons[i]
    if self.m_soldierIndex == i then
      soldierBtn:getChildByName("Image_sele"):setVisible(true)
    else
      soldierBtn:getChildByName("Image_sele"):setVisible(false)
    end
    local roleId = tonumber(self.m_campIndex .. "0" .. i)
    if not self.unitMng:IsRoleUnlock(roleId) and self.unitMng:IsRoleCanUnlock(roleId) then
      local avaiEff = td.CreateUIEffect(soldierBtn, "Spine/UI_effect/UI_tishikeyong_02", {loop = true, scale = 1.35})
      table.insert(self.m_availableEffects, avaiEff)
    end
  end
  self:RefreshUI()
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
end
function UnitDlg:UpdateSoldierIcon(career)
  for i = 1, 6 do
    local soldierBtn = self.m_btmButtons[i]
    local soldierIcon = soldierBtn:getChildByName("Image_head")
    soldierIcon:stopAllActions()
    soldierIcon:removeAllChildren()
    local roleId = tonumber(self.m_campIndex .. "0" .. i)
    local soldierInfo = self.aiMng:GetSoldierInfo(roleId)
    if self.unitMng:IsRoleUnlock(roleId) then
      soldierIcon:loadTexture(soldierInfo.head .. td.PNG_Suffix)
      soldierIcon:setContentSize(70, 70)
    else
      local grayIcon = display.newGraySprite(soldierInfo.head .. td.PNG_Suffix)
      grayIcon:setScale(0.8)
      grayIcon:setOpacity(100)
      td.AddRelaPos(soldierIcon, grayIcon, -1, cc.p(0.5, 0.5))
      soldierIcon:loadTexture("UI/common/suo_icon2.png")
      soldierIcon:setContentSize(72, 56)
    end
    local numLabel = soldierBtn:getChildByName("number")
    if not numLabel then
      numLabel = td.CreateLabel("", td.WHITE, 14)
      numLabel:setName("number")
      td.AddRelaPos(soldierBtn, numLabel, 10, cc.p(0.5, -0.05))
    end
    local strInfo = self.stiMng:GetSoldierStrongInfo(roleId)
    numLabel:setString(string.format("%d/%d", self.unitMng:GetSoldierNum(roleId), strInfo.storage))
  end
end
function UnitDlg:CreateCampSpine()
  if self.campSk then
    self.campSk:removeFromParent()
    self.campSk = nil
  end
  local soldierIndex = self.m_soldierIndex == -1 and 1 or self.m_soldierIndex
  local strFileName = self.soldierInfo.camp_file
  self.campSk = SkeletonUnit:create(strFileName)
  self.campSk:setScale(1.2)
  self.campSk:PlayAni("bingying_01")
  self.campSk:pos(162, 100):addTo(self.panelCamp, 2)
  if not self.m_bUnlock then
    self.campSk:setColor(td.BTN_PRESSED_COLOR)
  end
end
function UnitDlg:CreateUnitSpine(unitSpinePath)
  for i, var in ipairs(self.m_unitSpines) do
    var:removeFromParent(true)
  end
  self.m_unitSpines = {}
  local unitSpine = SkeletonUnit:create(unitSpinePath)
  unitSpine:PlayAni("stand")
  unitSpine:scale(0.5):pos(125, 50):addTo(self.panelCamp, 3)
  table.insert(self.m_unitSpines, unitSpine)
  if not self.m_bUnlock then
    unitSpine:setColor(td.BTN_PRESSED_COLOR)
  end
end
function UnitDlg:WeakGuide()
  if GuideManager:GetInstance():IsGuiding() then
    return
  end
  for i = 2, 6 do
    local roleId = tonumber(self.m_campIndex .. "0" .. i)
    if not self.unitMng:IsRoleUnlock(roleId) then
      local soldierInfo = self.stiMng:GetSoldierStrongInfo(roleId)
      local preSoldierId = soldierInfo.unlock.soldierId
      if self.unitMng:IsRoleUnlock(preSoldierId) then
        local pArrow = SkeletonUnit:create("Spine/UI_effect/UI_ruoyindao_01")
        pArrow:PlayAni("animation", false)
        td.AddRelaPos(self.m_btmButtons[i], pArrow)
        break
      end
    end
  end
end
function UnitDlg:AddBtnEvent()
  for i, soldierBtn in ipairs(self.m_btmButtons) do
    do
      local senderIndex = soldierBtn:getTag()
      td.BtnAddTouch(soldierBtn, function()
        self:OnSoldierIconClicked(senderIndex)
      end)
    end
  end
  td.BtnAddTouch(self.btnUpgrade, function()
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    if not self.m_bUnlock then
      local index = self.m_soldierIndex
      local worldPos = self.m_btmButtons[index]:getParent():convertToWorldSpace(cc.p(self.m_btmButtons[index]:getPosition()))
      local unlockDlg = require("app.layers.MainMenuUI.UnitUnlockDlg").new(self.soldierId, worldPos)
      td.popView(unlockDlg)
      return
    end
    if self.soldierData.level >= self.soldierData.star * 10 then
      local dlg = require("app.layers.MainMenuUI.UnitEvoDlg").new(self.soldierId)
      td.popView(dlg)
    else
      g_MC:OpenModule(td.UIModule.UpgradeHeroOrSoldier, {
        type = 3,
        id = self.soldierId
      })
    end
  end)
  td.BtnAddTouch(self.btnSkill, function()
    local dlg = require("app.layers.MainMenuUI.UnitSkillDlg").new(self.soldierId)
    td.popView(dlg)
  end)
  td.BtnAddTouch(self.btnTrain, function()
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    g_MC:OpenModule(td.UIModule.UnitTrain, {
      id = self.soldierId
    })
  end)
  td.BtnAddTouch(self.btnRestrain, function()
    local restrainDlg = require("app.layers.battle.RestrainDlg").new()
    td.popView(restrainDlg)
  end)
end
function UnitDlg:AddListeners()
  self:AddCustomEvent(td.SOLDIER_UPGRADE, handler(self, self.UpgradeCallback))
  self:AddCustomEvent(td.SOLDIER_EVO, handler(self, self.EvoCallback))
  self:AddCustomEvent(td.SOLDIER_UNLOCK, handler(self, self.UnlockUnit))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  self:AddCustomEvent(td.ITEM_UPDATE, handler(self, self.RefreshUI))
  self:AddCustomEvent(td.SOLDIER_NUM_UPDATE, handler(self, self.RefreshSoldierNum))
end
function UnitDlg:UnlockUnit(event)
  local soldierId = tonumber(event:getDataString())
  local soldierBtn = self.m_btmButtons[soldierId % 10]
  td.CreateUIEffect(soldierBtn, "Spine/UI_effect/UI_jiesuo_01", {scale = 1.5})
  soldierBtn:performWithDelay(function()
    local pDlg = require("app.layers.MainMenuUI.UnitUnlockedDlg").new(soldierId)
    td.popView(pDlg, true)
    self:OnTabClicked(self.m_campIndex)
    self:OnSoldierIconClicked(soldierId % 10)
  end, 0.55)
  td.CreateUIEffect(self.panelCamp, "Spine/UI_effect/UI_shengji_01")
end
function UnitDlg:UpgradeCallback(event)
  if tonumber(event:getDataString()) == 1 then
    do
      local soldierData = self.soldierData
      local curExp, maxExp = soldierData.exp, td.CalSoldierExp(soldierData.star, soldierData.level, soldierData.quality)
      local curLevel = self.curSoldierLevel
      td.ProgressTo(self.m_expPgBar, (curExp / maxExp + soldierData.level - self.curSoldierLevel) * 100, function()
        self:RefreshUI(RefreshType.LevelUp)
      end, function()
        curLevel = curLevel + 1
        self.lvLabel:setString("LV." .. curLevel)
        td.CreateUIEffect(self.panelCamp, "Spine/UI_effect/UI_shengji_01")
        if curLevel == soldierData.quality * 5 then
          self:UpdateSoldierIcon()
        end
      end)
      G_SoundUtil:PlaySound(55, false)
    end
  else
    local data = {
      data = self.unitMng:GetSoldierData(self.soldierId),
      type = "Unit",
      eventName = td.SOLDIER_EVO
    }
    local evoWindow = require("app.layers.CommonEvoDlg").new(data)
    td.popView(evoWindow)
  end
end
function UnitDlg:EvoCallback(event)
  self:RefreshUI(RefreshType.Evo)
  td.CreateUIEffect(self.panelCamp, "Spine/UI_effect/UI_shengji_01")
end
return UnitDlg
