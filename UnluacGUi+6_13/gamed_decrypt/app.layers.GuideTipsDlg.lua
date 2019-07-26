local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local GuideTipsDlg = class("GuideTipsDlg", BaseDlg)
local UIType = {
  Soldier = 1,
  Monster = 2,
  TitleAndPic = 3,
  CSB = 4
}
function GuideTipsDlg:ctor(info)
  GuideTipsDlg.super.ctor(self)
  self.m_guideInfo = info
  self.m_pGuideManager = require("app.GuideManager").GetInstance()
  self.m_tmpTable = {}
  self:InitEmptyPanel()
  self:InitNext()
  self:setNodeEventEnabled(true)
end
function GuideTipsDlg:onEnter()
  GuideTipsDlg.super.onEnter(self)
  display.getRunningScene():SetPause(true)
end
function GuideTipsDlg:onExit()
  GuideTipsDlg.super.onExit(self)
end
function GuideTipsDlg:AddEvents()
end
function GuideTipsDlg:BtnClicked()
  self.m_pGuideManager:UpdateGuide()
  display.getRunningScene():SetPause(false)
  self:performWithDelay(function()
    self:close()
  end, 0.1)
end
function GuideTipsDlg:InitEmptyPanel()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosVertical.Center, td.UIPosHorizontal.Center)
  self.m_panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_panelSize = self.m_panel:getContentSize()
end
function GuideTipsDlg:InitNext()
  self.m_panel:removeAllChildren()
  if self.m_guideInfo.style == UIType.Soldier then
    self:InitUISoldier(self.m_guideInfo)
  elseif self.m_guideInfo.style == UIType.TitleAndPic then
    self:InitUIOther(self.m_guideInfo)
  elseif self.m_guideInfo.style == UIType.CSB then
    self:InitUIWithCSB(self.m_guideInfo)
  end
  self:SetTitle(self.m_guideInfo.title)
  self:AddSpine(self.m_guideInfo)
end
function GuideTipsDlg:SetTitle(title)
  if self.m_uiRoot then
    local titleBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_title")
    local label = td.CreateBMF(g_LM:getBy(title), "Fonts/BlackWhite26.fnt")
    if titleBg and label then
      td.AddRelaPos(titleBg, label)
    end
  end
end
function GuideTipsDlg:AddSpine(tipInfo)
  if not tipInfo.spine then
    return
  end
  for i, var in ipairs(tipInfo.spine) do
    local skeleton = SkeletonUnit:create(var.file)
    skeleton:PlayAni(var.ani, true)
    skeleton:setPosition(var.pos)
    self.m_bg:addChild(skeleton)
    if var.scale then
      skeleton:setScale(var.scale)
    end
  end
end
function GuideTipsDlg:InitUISoldier(tipInfo)
  self.m_bg = display.newSprite("UI/tips/biaotidiwen.png")
  self.m_bg:setName("Image_title")
  self.m_bg:pos(self.m_panelSize.width / 2, self.m_panelSize.height * 0.85):addTo(self.m_panel)
  local soldierIds = tipInfo.image
  local count = #soldierIds
  local startX, gap = self.m_panelSize.width / 2 - (count - 1) * 180, 360
  for i, id in ipairs(soldierIds) do
    local info = ActorInfoManager:GetInstance():GetSoldierInfo(tonumber(id))
    local tipNode = cc.uiloader:load("CCS/SoldierTip.csb")
    tipNode:pos(startX + (i - 1) * gap, self.m_panelSize.height * 0.5):addTo(self.m_panel)
    local tipImage = cc.uiloader:seekNodeByName(tipNode, "Image_tip")
    tipImage:loadTexture("UI/tips/soldier_" .. id .. td.PNG_Suffix)
    local bg = cc.uiloader:seekNodeByName(tipNode, "Image_bg")
    local nameLabel = td.RichText({
      {
        type = 1,
        color = td.YELLOW,
        size = 20,
        str = info.name
      },
      {
        type = 2,
        file = td.CAREER_ICON[info.career],
        scale = 0.5
      }
    })
    nameLabel:pos(25 + nameLabel:getContentSize().width / 2, 165):addTo(bg)
    local posY = 145
    local tmp1 = string.split(info.desc, "#")
    for i, text in ipairs(tmp1) do
      local label
      if i % 2 == 1 then
        label = td.CreateLabel(text, td.WHITE, 16, nil, nil, cc.size(240, 0))
      else
        label = td.CreateLabel(text, td.YELLOW, 16, nil, nil, cc.size(240, 0))
      end
      label:setAnchorPoint(0, 1)
      label:pos(25, posY):addTo(bg)
      posY = posY - label:getContentSize().height
    end
  end
  local btn = td.CreateBtn(td.BtnType.BlueShort)
  btn:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.ended == eventType then
      btn:setDisable(true)
      self:BtnClicked()
    end
  end)
  btn:setPosition(self.m_panelSize.width / 2, self.m_panelSize.height / 2 - 205)
  btn:addTo(self.m_panel)
  td.BtnSetTitle(btn, g_LM:getBy("a00009"))
end
function GuideTipsDlg:InitUIOther(tipInfo)
  local imageFiles = tipInfo.image
  local margin, gap = 25, 12
  local bgWidth = margin * 2 + (#imageFiles - 1) * gap
  local images = {}
  for i, file in ipairs(imageFiles) do
    local image = display.newSprite(file .. td.PNG_Suffix)
    bgWidth = bgWidth + image:getContentSize().width
    table.insert(images, image)
  end
  local bgSize = cc.size(bgWidth, 470)
  self.m_bg = display.newScale9Sprite("UI/tips/dikuang.png", 0, 0, bgSize, cc.rect(25, 50, 60, 18))
  self.m_bg:setPosition(self.m_panelSize.width / 2, self.m_panelSize.height / 2)
  self.m_panel:addChild(self.m_bg)
  local imgGap = (bgWidth - (margin * 2 + (#imageFiles - 1) * gap)) / (#imageFiles * 2)
  for i, image in ipairs(images) do
    local size = image:getContentSize()
    local frame = display.newScale9Sprite("UI/tips/bantoumingkuang.png", 0, 0, cc.size(size.width + 6, size.height + 6))
    td.AddRelaPos(image, frame)
    image:setAnchorPoint(0.5, 0)
    image:pos(margin + (i * 2 - 1) * imgGap + (i - 1) * gap, 75):addTo(self.m_bg)
  end
  local titleBg = display.newScale9Sprite("UI/tips/biaotidi.png", 0, 0, cc.size(280, 38), cc.rect(35, 0, 10, 0))
  titleBg:setName("Image_title")
  titleBg:setAnchorPoint(0.5, 1.1)
  td.AddRelaPos(self.m_bg, titleBg, 0, cc.p(0.5, 1))
  local vConStr = string.split(g_LM:getBy(tipInfo.content), "#")
  if #vConStr == 1 then
    local label = td.CreateLabel(vConStr[1], td.LIGHT_GREEN, 18, nil, nil, cc.size(bgWidth - 70, 0))
    label:setAnchorPoint(0, 1)
    label:pos(35, bgSize.height - 50):addTo(self.m_bg)
  else
    local count = math.floor(#vConStr / 2) - 1
    for i = 0, count do
      local olLabel = td.CreateLabel(vConStr[i * 2 + 1], td.YELLOW, 18, td.OL_BROWN, 2)
      local label = td.RichText({
        {
          type = 3,
          node = olLabel,
          color = td.YELLOW
        },
        {
          type = 1,
          color = td.LIGHT_GREEN,
          size = 18,
          str = vConStr[i * 2 + 2]
        }
      }, cc.size(bgWidth - 70, 0))
      label:setAnchorPoint(0, 1)
      label:pos(35, bgSize.height - 45 - 35 * i):addTo(self.m_bg)
    end
  end
  local btn = td.CreateBtn(td.BtnType.BlueShort)
  btn:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.ended == eventType then
      btn:setDisable(true)
      self:BtnClicked()
    end
  end)
  btn:setPosition(bgSize.width / 2, 45)
  btn:addTo(self.m_bg)
  td.BtnSetTitle(btn, g_LM:getBy("a00009"))
end
function GuideTipsDlg:InitUIWithCSB(tipInfo)
  if tipInfo.csb == "" then
    td.alertDebug("tip \233\133\141\231\189\174\233\148\153\232\175\175\239\188\154id=" .. tipInfo.id)
    print("tip \233\133\141\231\189\174\233\148\153\232\175\175\239\188\154id=" .. tipInfo.id)
  end
  local contentNode = cc.uiloader:load(tipInfo.csb)
  td.AddRelaPos(self.m_panel, contentNode)
  if tipInfo.content then
    if type(tipInfo.content) ~= "table" then
      tipInfo.content = {
        tipInfo.content
      }
    end
    for i, var in ipairs(tipInfo.content) do
      local text = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_" .. i)
      text:setString(g_LM:getBy(var))
    end
  end
  local btn = cc.uiloader:seekNodeByName(contentNode, "Button_yes")
  btn:addTouchEventListener(function(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      btn:setDisable(true)
      self:BtnClicked()
    end
  end)
  td.BtnSetTitle(btn, g_LM:getBy("a00009"))
end
return GuideTipsDlg
