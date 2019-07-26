local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local MissionInfoManager = require("app.info.MissionInfoManager")
local UserDataManager = require("app.UserDataManager")
local GuideManager = require("app.GuideManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local TouchIcon = require("app.widgets.TouchIcon")
local FightWinAwardsDlg = class("FightWinAwardsDlg", BaseDlg)
function FightWinAwardsDlg:ctor(awards)
  FightWinAwardsDlg.super.ctor(self)
  self.udMng = UserDataManager:GetInstance()
  self.m_vAwrads = {}
  for i, val in ipairs(awards) do
    local id = val.itemId
    local num = val.num
    if not self.m_vAwrads[id] then
      self.m_vAwrads[id] = num
    else
      self.m_vAwrads[id] = self.m_vAwrads[id] + num
    end
  end
  self:InitUI()
end
function FightWinAwardsDlg:onEnter()
  FightWinAwardsDlg.super.onEnter(self)
end
function FightWinAwardsDlg:onExit()
  FightWinAwardsDlg.super.onExit(self)
end
function FightWinAwardsDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/FightWinAwardsDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.panelAwards = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_award")
  self.panelLost = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_soldier")
  self.labelExp = cc.uiloader:seekNodeByName(self.m_bg, "Text_exp")
  local baseLevel = self.udMng:GetBaseCampLevel()
  local curExp, maxExp = self.udMng:GetExp(), td.CalBaseExp(baseLevel)
  self.m_levelLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_level")
  self.m_levelLabel:setString("LV." .. baseLevel)
  local barBg = cc.uiloader:seekNodeByName(self.m_bg, "Image_barBg")
  self.m_expPgBar = cc.ProgressTimer:create(display.newSprite("UI/battle/huangsejindutiao.png"))
  self.m_expPgBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  self.m_expPgBar:setMidpoint(cc.p(0, 0))
  self.m_expPgBar:setBarChangeRate(cc.p(1, 0))
  self.m_expPgBar:setPercentage(curExp / maxExp * 100)
  td.AddRelaPos(barBg, self.m_expPgBar)
  self.m_expLabel = td.CreateLabel(string.format("%d/%d", curExp, maxExp), nil, nil, td.OL_BLACK, 2)
  td.AddRelaPos(self.m_expPgBar, self.m_expLabel)
  local exitBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_exit")
  td.BtnAddTouch(exitBtn, function()
    exitBtn:setDisable(true)
    if self.bLevelUp then
      require("app.layers.InformationManager"):GetInstance():ShowLevelUp(function()
        if display.getRunningScene():GetType() == td.SceneType.Battle then
          GameDataManager:GetInstance():ExitGame(td.UIModule.Mission)
        end
      end)
    elseif display.getRunningScene():GetType() == td.SceneType.Battle then
      GameDataManager:GetInstance():ExitGame(td.UIModule.Mission)
    end
    self:removeFromParent()
  end)
  td.BtnSetTitle(exitBtn, g_LM:getBy("a00009"))
  if display.getRunningScene():GetType() == td.SceneType.Battle then
    self:CreateLost()
    self:CreateAwards()
  else
    self.panelLost:setVisible(false)
    self.panelAwards:setPositionY(240)
    self:CreateAwards()
  end
end
function FightWinAwardsDlg:CreateAwards()
  local goldNum, expNum = 0, 0
  local count = 0
  for i, var in pairs(self.m_vAwrads) do
    local itemIcon
    if i == 1 then
      self.udMng:SendGetHeroRequest()
      self.udMng:SendGetSkillsRequest()
    elseif i == td.ItemID_Exp then
      self.bLevelUp = self.udMng:AddExp(var)
      self:UpdateExpBar(self.bLevelUp)
      expNum = var
    else
      itemIcon = TouchIcon.new(i, true, false)
    end
    if itemIcon then
      local bg = display.newScale9Sprite("UI/scale9/bantoumingkuang.png", 0, 0, cc.size(70, 70))
      td.AddRelaPos(self.panelAwards, bg, 1, cc.p(0.25 + count * 0.13, 0.6))
      bg:scale(0)
      bg:runAction(cca.seq({
        cca.delay(count * 0.2),
        cca.scaleTo(0.4, 1, 1)
      }))
      itemIcon:scale(0)
      itemIcon:runAction(cca.seq({
        cca.delay(count * 0.2),
        cca.scaleTo(0.4, 0.6, 0.6)
      }))
      td.AddRelaPos(bg, itemIcon)
      local numLabel = td.CreateLabel(var, td.WHITE, 18, td.OL_BLACK, 1)
      numLabel:setAnchorPoint(0, 0.5)
      td.AddRelaPos(bg, numLabel, 1, cc.p(0.1, 0.85))
      count = count + 1
    end
  end
  self.labelExp:opacity(0)
  self.labelExp:setString("+" .. expNum)
  self.labelExp:runAction(cca.seq({
    cca.spawn({
      cca.moveBy(0.2, 0, 25),
      cca.fadeIn(0.2)
    }),
    cca.delay(0.5),
    cca.spawn({
      cca.moveBy(0.2, 0, 25),
      cca.fadeOut(0.2)
    })
  }))
end
function FightWinAwardsDlg:CreateLost()
  local aiMng = ActorInfoManager:GetInstance()
  local deadUnit = GameDataManager:GetInstance():GetDeadUnit()
  local count = 0
  for key, var in pairs(deadUnit) do
    local bg = display.newScale9Sprite("UI/scale9/bantoumingkuang.png", 0, 0, cc.size(70, 70))
    td.AddRelaPos(self.panelLost, bg, 1, cc.p(0.25 + count * 0.13, 0.6))
    bg:scale(0)
    bg:runAction(cca.seq({
      cca.delay(count * 0.2),
      cca.scaleTo(0.4, 1, 1)
    }))
    local info = aiMng:GetSoldierInfo(key)
    local itemIcon = display.newSprite(info.head .. td.PNG_Suffix)
    itemIcon:scale(0.7)
    td.AddRelaPos(bg, itemIcon)
    local numLabel = td.CreateLabel(var, td.WHITE, 18, td.OL_BLACK, 1)
    numLabel:setAnchorPoint(0, 0.5)
    td.AddRelaPos(bg, numLabel, 1, cc.p(0.1, 0.85))
    count = count + 1
  end
end
function FightWinAwardsDlg:UpdateExpBar(bLevelUp)
  local baseLevel = self.udMng:GetBaseCampLevel()
  local curExp, maxExp = self.udMng:GetExp(), td.CalBaseExp(baseLevel)
  local toPercent = bLevelUp and 100 or 0
  td.ProgressTo(self.m_expPgBar, toPercent + curExp / maxExp * 100, function()
    self.m_expLabel:setString(string.format("%d/%d", curExp, maxExp))
  end, function()
    if bLevelUp then
      self.m_levelLabel:setString("LV." .. baseLevel)
    end
  end)
end
return FightWinAwardsDlg
