local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local EnemyDescDlg = class("EnemyDescDlg", BaseDlg)
function EnemyDescDlg:ctor()
  EnemyDescDlg.super.ctor(self)
  self.m_vMonsterIds = clone(GameDataManager:GetInstance():GetNewMonsterTips())
  self.m_iCurIndex = 1
  self:setNodeEventEnabled(true)
  self:InitUIMonster()
end
function EnemyDescDlg:onEnter()
  EnemyDescDlg.super.onEnter(self)
  cc.Director:getInstance():pause()
  cc.Director:getInstance():setOwenPause(true)
end
function EnemyDescDlg:onExit()
  EnemyDescDlg.super.onExit(self)
  cc.Director:getInstance():resume()
  cc.Director:getInstance():setOwenPause(false)
  require("app.trigger.TriggerManager"):GetInstance():SendEvent({
    eType = td.ConditionType.CloseModule,
    moduleID = td.UIModule.NewEnemyTip
  })
end
function EnemyDescDlg:Show()
  local pRunScene = display.getRunningScene()
  pRunScene:addChild(self, td.ZORDER.Pause)
end
function EnemyDescDlg:InitUIMonster()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosVertical.Center, td.UIPosHorizontal.Center)
  self.m_panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_panelSize = self.m_panel:getContentSize()
  self.m_bg = display.newSprite("UI/tips/biaotidiwen.png")
  self.m_bg:pos(self.m_panelSize.width / 2, self.m_panelSize.height * 0.85):addTo(self.m_panel)
  local label = td.CreateBMF(g_LM:getBy("t00054"), "Fonts/BlackWhite26.fnt")
  td.AddRelaPos(self.m_bg, label)
  self.m_tipNode = cc.uiloader:load("CCS/MonsterTip.csb")
  self.m_tipNode:pos(self.m_panelSize.width / 2, self.m_panelSize.height * 0.56):addTo(self.m_panel)
  self.m_pContent = td.CreateLabel("", td.WHITE, 16, nil, nil, cc.size(240, 180))
  self.m_pContent:setAnchorPoint(cc.p(0, 1))
  self.m_pContent:pos(540, 400):addTo(self.m_panel)
  self.m_skillLabel = td.CreateLabel("", td.WHITE, 16, nil, nil, cc.size(140, 40))
  self.m_skillLabel:setAnchorPoint(0, 1)
  self.m_skillLabel:pos(610, 285):addTo(self.m_panel)
  local menu = cc.Menu:create()
  menu:setPosition(0, 0)
  menu:addTo(self.m_panel)
  local btn = cc.MenuItemImage:create(td.BtnBS.enabled, td.BtnBS.pressed)
  btn:registerScriptTapHandler(handler(self, self.BtnClicked))
  btn:setPosition(self.m_panelSize.width / 2, self.m_panelSize.height / 2 - 155)
  btn:addTo(menu)
  local btnStr = self.m_iCurIndex == #self.m_vMonsterIds and "a00164" or "a00124"
  self.m_btnTitle = td.CreateLabel(g_LM:getBy(btnStr), td.WHITE, 18)
  self.m_btnTitle:setAnchorPoint(0.5, 0.5)
  td.AddRelaPos(btn, self.m_btnTitle)
  self:UpdateShowMonster()
end
function EnemyDescDlg:UpdateShowMonster()
  local id = self.m_vMonsterIds[self.m_iCurIndex]
  local info = ActorInfoManager:GetInstance():GetMonsterInfo(id)
  local tipImage = cc.uiloader:seekNodeByName(self.m_tipNode, "Image_tip")
  tipImage:loadTexture("UI/tips/monster_" .. id .. td.PNG_Suffix)
  if self.m_pNameLabel then
    self.m_pNameLabel:removeFromParent()
    self.m_pNameLabel = nil
  end
  local iconSpr = td.CreateCareerIcon(info.career)
  iconSpr:scale(0.55)
  self.m_pNameLabel = td.RichText({
    {
      type = 1,
      color = td.YELLOW,
      size = 18,
      str = info.name
    },
    {type = 3, node = iconSpr}
  })
  self.m_pNameLabel:setAnchorPoint(cc.p(0, 1))
  self.m_pNameLabel:pos(540, 450):addTo(self.m_panel)
  self.m_pContent:setString(info.desc)
  if self.m_properties then
    for i, var in ipairs(self.m_properties) do
      var:removeFromParent()
    end
  end
  self.m_properties = {}
  local values = {
    info.attack,
    info.hp,
    info.def,
    info.attack_speed
  }
  local vPos = {
    cc.p(543, 330),
    cc.p(665, 330),
    cc.p(543, 302),
    cc.p(665, 302)
  }
  for i, var in ipairs(values) do
    local label = td.GetPropertyStr(i, var)
    label:setAnchorPoint(0, 0.5)
    label:pos(vPos[i].x, vPos[i].y):addTo(self.m_panel)
    table.insert(self.m_properties, label)
  end
  local str = self:GetSkillStr(info.skill)
  self.m_skillLabel:setString(str)
  if self.m_iCurIndex == #self.m_vMonsterIds then
    self.m_btnTitle:setString(g_LM:getBy("a00164"))
  end
end
function EnemyDescDlg:BtnClicked()
  if #self.m_vMonsterIds > self.m_iCurIndex then
    self.m_iCurIndex = self.m_iCurIndex + 1
    self:UpdateShowMonster()
  else
    GameDataManager:GetInstance():ClearNewMonsterTips()
    self:removeFromParent()
  end
end
function EnemyDescDlg:GetSkillStr(vSkill)
  local mng = SkillInfoManager:GetInstance()
  local str, count = "", 0
  for i, id in ipairs(vSkill) do
    local sInfo = mng:GetInfo(id)
    if sInfo.type ~= 0 then
      if count == 0 then
        str = str .. sInfo.name
      else
        str = str .. "," .. sInfo.name
      end
      count = count + 1
    end
  end
  if count == 0 then
    str = "\230\151\160"
  end
  return str
end
return EnemyDescDlg
