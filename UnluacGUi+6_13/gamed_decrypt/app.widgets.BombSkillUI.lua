local SkillInfoManager = require("app.info.SkillInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local BombSkillUI = class("BombSkillUI", function(layer)
  return cc.uiloader:load("CCS/BombSkillUI.csb")
end)
function BombSkillUI:ctor()
  self.m_siMng = SkillInfoManager:GetInstance()
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function BombSkillUI:onEnter()
end
function BombSkillUI:onExit()
end
function BombSkillUI:InitUI()
  self.m_bg = cc.uiloader:seekNodeByName(self, "Image_bg")
  self.m_nameLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_name")
  self.m_equipBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_equip")
  td.BtnSetTitle(self.m_equipBtn, g_LM:getBy("a00096"))
  self.m_equipBtn:setVisible(false)
end
function BombSkillUI:RefreshUI(skillData, unselectCb)
  if skillData then
    local skillInfo = skillData.skillInfo
    self.m_nameLabel:setString(skillInfo.name)
    local skillIcon = td.CreateSkillIcon(skillInfo.id, skillData.star, skillData.quality)
    skillIcon:scale(0.65)
    td.AddRelaPos(self.m_bg, skillIcon, 1, cc.p(0.5, 0.64))
    self.m_skillIcon = skillIcon
    self.m_descLabel = self:GetSkillLabel(skillData)
    self.m_descLabel:align(display.LEFT_TOP, 50, 160):addTo(self.m_bg)
    if skillData.star == 0 then
      self.m_equipBtn:setVisible(true)
      td.BtnSetTitle(self.m_equipBtn, g_LM:getBy("a00115"))
      td.BtnAddTouch(self.m_equipBtn, handler(self, self.Buy))
    elseif unselectCb then
      self.m_equipBtn:setVisible(true)
      td.BtnAddTouch(self.m_equipBtn, unselectCb)
    end
  end
end
function BombSkillUI:GetSkillLabel(skillData)
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
          color = td.LIGHT_BLUE,
          size = 16,
          str = var
        })
      else
        table.insert(textData, {
          type = 1,
          color = td.YELLOW,
          size = 16,
          str = var
        })
      end
    end
    return td.RichText(textData, cc.size(250, 80))
  else
    return td.CreateLabel(skillInfo.desc, td.LIGHT_BLUE, 16)
  end
end
function BombSkillUI:Close()
  self:removeFromParent()
end
function BombSkillUI:Buy()
  g_MC:OpenModule(td.UIModule.Store)
end
return BombSkillUI
