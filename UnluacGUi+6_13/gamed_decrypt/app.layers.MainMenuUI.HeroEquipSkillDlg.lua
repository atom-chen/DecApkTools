local SkillInfoManager = require("app.info.SkillInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local GuideManager = require("app.GuideManager")
local TouchIcon = require("app.widgets.TouchIcon")
local PickItemUI = require("app.widgets.PickItemUI")
local HeroEquipSkillDlg = class("HeroEquipSkillDlg", BaseDlg)
local Item_Size = cc.size(375, 70)
local SeleTag = 111
local HeroSkillState = {
  NotFull = 1,
  Full = 2,
  Evo = 3
}
function HeroEquipSkillDlg:ctor(data)
  HeroEquipSkillDlg.super.ctor(self)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_siMng = SkillInfoManager:GetInstance()
  self.m_iiMng = ItemInfoManager:GetInstance()
  self.m_uiId = td.UIModule.HeroSkill
  self.m_showingSkillUId = 0
  self.m_curSkillIndex = {}
  self.m_bActionOver = false
  self:InitUI()
  self:SetData(data)
end
function HeroEquipSkillDlg:onEnter()
  HeroEquipSkillDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.EquipSkill_req, handler(self, self.EquipSkillCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UpHeroSkill, handler(self, self.UpSkillCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.EvoHeroSkill, handler(self, self.EvoSkillCallback))
  self:AddEvents()
  self:PlayEnterAni(function()
    self:CheckGuide()
  end)
end
function HeroEquipSkillDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.EquipSkill_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.UpHeroSkill)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.EvoHeroSkill)
  HeroEquipSkillDlg.super.onExit(self)
end
function HeroEquipSkillDlg:PlayEnterAni(cb)
  if not self.m_bUnlock then
    cb()
    self.m_bActionOver = true
    return
  end
  if not self.m_bg2:isVisible() then
    self.m_bg1:runAction(cca.seq({
      cca.moveBy(0.5, -175, 0),
      cca.cb(function()
        local spineInfo = {
          pos = cc.p(self.m_bg2:getPositionX() + self.m_bg2:getContentSize().width / 2, self.m_bg2:getPositionY())
        }
        td.CreateUIEffect(self.m_panelBg, "Spine/UI_effect/UI_zhuangbeitanchu_01", spineInfo)
      end)
    }))
    self.m_bg2:runAction(cca.seq({
      cca.show(),
      cca.delay(1),
      cca.fadeIn(0.4, 1),
      cca.cb(function()
        self.m_panelEvo:setVisible(true)
        self.m_panelEvo:runAction(cca.fadeIn(0.5))
        cb()
        td.CreateUIEffect(self.m_panelMain, "Spine/UI_effect/UI_zhuangbei_01", {
          loop = true,
          pos = cc.p(170, 295)
        })
        self.m_bActionOver = true
      end)
    }))
  else
    self.m_bActionOver = true
  end
end
function HeroEquipSkillDlg:InitUI()
  local uiRoot = cc.uiloader:load("CCS/HeroEquipSkillDlg.csb")
  self.m_uiRoot = uiRoot
  uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(uiRoot)
  self:addChild(uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self:AddCloseTip()
  self.m_panelBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.m_bg1 = cc.uiloader:seekNodeByName(self.m_panelBg, "Image_bg1")
  self.m_bg2 = cc.uiloader:seekNodeByName(self.m_panelBg, "Image_bg2")
  self.m_bg2:setVisible(false)
  self.m_panelMain = cc.uiloader:seekNodeByName(self.m_bg1, "Panel_main")
  self.m_panelEvo = cc.uiloader:seekNodeByName(self.m_bg2, "Panel_evo")
  self.m_panelEvo:setVisible(false)
  self.m_panelEvo:setOpacity(0)
  self.m_nameLabel = cc.uiloader:seekNodeByName(self.m_panelMain, "Text_name")
  self.m_skillIcon = cc.uiloader:seekNodeByName(self.m_panelMain, "Image_icon")
  self.m_confirmBtn = cc.uiloader:seekNodeByName(self.m_panelEvo, "Button_yes_2")
  td.BtnAddTouch(self.m_confirmBtn, handler(self, self.OnEvoBtnClicked))
  td.BtnSetTitle(self.m_confirmBtn, g_LM:getBy("a00421"))
end
function HeroEquipSkillDlg:SetData(data)
  local skillData = data.skillData
  self.m_showingSkillUId = skillData.skillUid
  self.m_bIsActive = skillData.isActive
  self.m_bUnlock = skillData.unlock
  self.m_unlockLevel = skillData.unlockLevel
  local showSkillData = self.m_udMng:GetSkillLib()[self.m_showingSkillUId]
  showSkillData = showSkillData or self.m_siMng:MakeSkillData({
    skill_id = skillData.skillId,
    star = 1
  }, true)
  self:RefreshDetail(showSkillData)
end
function HeroEquipSkillDlg:RefreshDetail(skillData)
  if self.m_descLabel then
    self.m_descLabel:removeFromParent()
    self.m_descLabel = nil
  end
  local skillInfo = skillData.skillInfo
  self.m_nameLabel:setString(skillInfo.name)
  local x, y = self.m_skillIcon:getPosition()
  self.m_skillIcon:removeFromParent()
  local skillIcon = td.CreateSkillIcon(skillInfo.id, skillData.star, skillData.quality)
  skillIcon:scale(0.65):pos(x, y):addTo(self.m_panelMain)
  self.m_skillIcon = skillIcon
  self.m_descLabel = self:GetSkillLabel(skillData)
  self.m_descLabel:align(display.LEFT_TOP, 20, 160):addTo(self.m_panelMain)
  if self.m_bUnlock then
    self:RefreshEvoDetail()
  else
    local str = string.format(g_LM:getMode("tipmsg", td.ErrorCode.HERO_LEVEL_LOW), self.m_unlockLevel)
    local unlockLabel = td.CreateLabel(str, td.GRAY, 16)
    td.AddRelaPos(self.m_panelMain, unlockLabel, 1, cc.p(0.5, 0.38))
  end
end
function HeroEquipSkillDlg:GetSkillLabel(skillData)
  local skillInfo = skillData.skillInfo
  local skillLevelInfo = self.m_siMng:GetHeroSkillInfo(skillInfo.id)
  if skillLevelInfo then
    local skillContent = skillInfo.desc
    local variables = skillLevelInfo.variable[cc.clampf(skillData.star, 1, skillLevelInfo.quality)]
    for i, var in ipairs(variables) do
      skillContent = string.gsub(skillContent, "{" .. i .. "}", "#" .. var .. "#")
    end
    local textData = {}
    local vStr = string.split(skillContent, "#")
    for i, var in ipairs(vStr) do
      if i % 2 == 1 then
        table.insert(textData, {
          type = 1,
          color = td.BLUE,
          size = 18,
          str = var
        })
      else
        table.insert(textData, {
          type = 1,
          color = td.YELLOW,
          size = 18,
          str = var
        })
      end
    end
    return td.RichText(textData, cc.size(300, 80))
  else
    return td.CreateLabel(skillInfo.desc, td.BLUE, 18)
  end
end
function HeroEquipSkillDlg:RefreshEvoDetail(skillData)
  local skillData = self.m_udMng:GetSkillLib()[self.m_showingSkillUId]
  local skillInfo = skillData.skillInfo
  local skillHeroInfo = self.m_siMng:GetHeroSkillInfo(skillData.skill_id)
  local showStarLevel = skillData.star
  if skillData.star >= skillHeroInfo.quality then
    showStarLevel = showStarLevel - 1
  end
  local maxNeed = skillHeroInfo.star_cost[showStarLevel].num
  local skillIcon = cc.uiloader:seekNodeByName(self.m_panelEvo, "Image_icon")
  local x, y = skillIcon:getPosition()
  skillIcon:removeFromParent()
  skillIcon = td.CreateSkillIcon(skillInfo.id, skillData.star, skillData.quality)
  skillIcon:setName("Image_icon")
  skillIcon:scale(0.65):pos(x, y):addTo(self.m_panelEvo)
  local skillBg = cc.uiloader:seekNodeByName(self.m_panelEvo, "Image_iconBg")
  skillBg:loadTexture("UI/hero/guangquan_" .. maxNeed .. "_jinengtupo.png")
  skillBg:removeAllChildren()
  td.CreateUIEffect(skillBg, "Spine/UI_effect/UI_jinengzhuangshi_01", {loop = true, zorder = 10})
  local skillBgSize = skillBg:getContentSize()
  for i = 1, maxNeed do
    do
      local angle = 90 - (i - 1) * 360 / maxNeed
      local radian, radius = math.angle2radian(angle), 128
      local posSkill = cc.p(radius * math.cos(radian) + skillBgSize.width / 2, radius * math.sin(radian) + skillBgSize.height / 2)
      if i <= skillData.curNeed then
        td.CreateUIEffect(skillBg, "Spine/UI_effect/UI_jinengjiesuo_01", {
          ani = "animation_02",
          pos = posSkill,
          loop = true
        })
        td.CreateUIEffect(skillBg, "Spine/UI_effect/UI_jinengjiesuo_02", {
          pos = posSkill,
          loop = true,
          rotation = 180 - angle
        })
      else
        self.skillHolebtn = ccui.Button:create("UI/scale9/lanse_xuanfukuang.png")
        self.skillHolebtn:setOpacity(0)
        td.BtnAddTouch(self.skillHolebtn, function()
          local pickItemLayer = PickItemUI.new(skillHeroInfo.star_cost[showStarLevel].itemId, skillBg:convertToWorldSpace(posSkill))
          td.popView(pickItemLayer)
        end)
        self.skillHolebtn:pos(posSkill.x, posSkill.y):addTo(skillBg)
        td.CreateUIEffect(self.skillHolebtn, "Spine/UI_effect/UI_daidianji_01", {loop = true})
        break
      end
    end
  end
  local bookItemId = skillHeroInfo.star_cost[showStarLevel].itemId
  local skillBook = cc.uiloader:seekNodeByName(self.m_panelEvo, "Image_item")
  skillBook:loadTexture(td.GetItemIcon(bookItemId))
  local skillBookNum = cc.uiloader:seekNodeByName(self.m_panelEvo, "Text_num")
  local num = self.m_udMng:GetItemNum(bookItemId)
  skillBookNum:setString(string.format("x%d", num))
  local bEnable = self:CheckCanEvo(skillData)
  td.EnableButton(self.m_confirmBtn, bEnable)
end
function HeroEquipSkillDlg:CheckCanEvo(skillData)
  local skillHeroInfo = self.m_siMng:GetHeroSkillInfo(skillData.skill_id)
  if skillData.star >= skillHeroInfo.quality then
    return false, td.ErrorCode.STAR_MAX
  elseif skillData.state == 1 then
    return false, td.ErrorCode.SKILL_STATE_LOW
  end
  local vItems = skillHeroInfo.star_cost[skillData.star]
  for i, var in ipairs(vItems) do
    local haveNum = self.m_udMng:GetItemNum(var.itemId)
    if haveNum < var.num then
      return false, td.ErrorCode.MATERIAL_NOT_ENOUGH
    end
  end
  return true, td.ErrorCode.SUCCESS
end
function HeroEquipSkillDlg:OnEvoBtnClicked()
  local skillData = self.m_udMng:GetSkillLib()[self.m_showingSkillUId]
  local bEnable, errorCode = self:CheckCanEvo(skillData)
  if bEnable then
    self:SendEvoSkillRequest()
  else
    td.alertErrorMsg(errorCode)
  end
end
function HeroEquipSkillDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if not self.m_bActionOver then
      return true
    end
    local bg = self.m_bUnlock and self.m_panelBg or self.m_bg1
    local tmpPos = bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(bg, tmpPos) then
      self:performWithDelay(function()
        self:close()
        td.dispatchEvent(td.GUIDE_CONTINUE)
      end, 0.1)
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  self:AddCustomEvent(td.HERO_SKILL_HOLE, handler(self, self.UpdateSkillHole))
  self:AddCustomEvent(td.HERO_SKILL_UPDATE, handler(self, self.OnSkillUpdate))
end
function HeroEquipSkillDlg:OnSkillUpdate()
  local skillData = self.m_udMng:GetSkillLib()[self.m_showingSkillUId]
  self:RefreshDetail(skillData)
end
function HeroEquipSkillDlg:UpdateSkillHole()
  self.skillHolebtn:removeAllChildren()
  local effect = SkeletonUnit:create("Spine/UI_effect/UI_jinengjiesuo_01")
  effect:registerSpineEventHandler(function(event)
    if event.animation == "animation_01" then
      effect:PlayAni("animation_02", true)
      self:SendUpSkillRequest()
    end
  end, sp.EventType.ANIMATION_COMPLETE)
  effect:PlayAni("animation_01")
  td.AddRelaPos(self.skillHolebtn, effect)
end
function HeroEquipSkillDlg:OnWealthChanged()
  HeroEquipSkillDlg.super.OnWealthChanged(self)
  if self.m_panelEvo:isVisible() then
    self:RefreshEvoDetail()
  end
end
function HeroEquipSkillDlg:OnItemUpdate()
  HeroEquipSkillDlg.super.OnItemUpdate(self)
  if self.m_panelEvo:isVisible() then
    self:RefreshEvoDetail()
  end
end
function HeroEquipSkillDlg:SendUpSkillRequest()
  local skillData = self.m_udMng:GetSkillLib()[self.m_showingSkillUId]
  local item = {
    item_id = skillData.itemNeed,
    item_num = 1
  }
  local Msg = {}
  Msg.msgType = td.RequestID.UpHeroSkill
  Msg.sendData = {
    id = self.m_showingSkillUId,
    itemProto = {item}
  }
  Msg.cbData = {
    id = self.m_showingSkillUId,
    num = 1
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function HeroEquipSkillDlg:UpSkillCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    local skillData = self.m_udMng:GetSkillLib()[cbData.id]
    skillData.items = string.format("%d#%d", skillData.itemNeed, skillData.curNeed + cbData.num)
    self.m_udMng:UpdateHeroSkillData(skillData)
    skillData = self.m_udMng:GetSkillLib()[cbData.id]
    self:RefreshEvoDetail(skillData)
  end
end
function HeroEquipSkillDlg:SendEvoSkillRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.EvoHeroSkill
  Msg.sendData = {
    id = self.m_showingSkillUId
  }
  Msg.cbData = {
    id = self.m_showingSkillUId
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function HeroEquipSkillDlg:EvoSkillCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    local skillData = self.m_udMng:GetSkillLib()[cbData.id]
    skillData.star = skillData.star + 1
    self.m_udMng:UpdateHeroSkillData(skillData)
    local data = {
      data = skillData,
      type = "Skill",
      eventName = td.HERO_SKILL_UPDATE
    }
    local evoWindow = require("app.layers.CommonEvoDlg").new(data)
    td.popView(evoWindow)
  end
end
return HeroEquipSkillDlg
