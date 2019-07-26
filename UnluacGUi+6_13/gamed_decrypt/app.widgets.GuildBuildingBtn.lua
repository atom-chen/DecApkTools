local UserDataManager = require("app.UserDataManager")
local GuildBuildingBtn = class("GuildBuildingBtn", function(info, data)
  local rank = cc.clampf(math.floor((data.level - 1) / 3) + 1, 1, 4)
  return SkeletonUnit:create(info.image .. string.format("%02d", rank))
end)
function GuildBuildingBtn:ctor(info, data)
  self.m_gdm = UserDataManager:GetInstance():GetGuildManager()
  self.m_info = info
  self.m_data = data
  self.m_bActive = false
  self.m_vBtn = {}
  self.m_scale = 0.5
  self:Init()
  self:setNodeEventEnabled(true)
end
function GuildBuildingBtn:onEnter()
  self:scale(self.m_scale)
  self:PlayAni("animation", true)
end
function GuildBuildingBtn:onExit()
end
function GuildBuildingBtn:Init()
  self:CreateNameLabel()
  local bg = display.newNode()
  bg:setName("bg")
  bg:setContentSize(200, 200)
  bg:setLocalZOrder(10)
  bg:addTo(self)
end
function GuildBuildingBtn:CreateNameLabel()
  if self.m_nameLabel then
    self.m_nameLabel:removeFromParent()
    self.m_nameLabel = nil
  end
  local buildingName = td.CreateLabel(self.m_info.name, td.WHITE, 18, td.OL_BLACK)
  local lvl = td.CreateLabel(" LV." .. self.m_data.level, td.WHITE, 18, td.OL_BLACK)
  self.m_nameLabel = td.RichText({
    {type = 3, node = buildingName},
    {type = 3, node = lvl}
  })
  self.m_nameLabel:scale(1 / self.m_scale):pos(0, -100):addTo(self)
  self.m_nameLabel:setVisible(false)
end
function GuildBuildingBtn:InitBtns()
  local btnsConfig = {
    {
      type = 1,
      normal = "UI/guild/juanxian1_icon.png",
      press = "UI/guild/juanxian2_icon.png"
    },
    {
      type = 2,
      normal = "UI/guild/xiangqing1_icon.png",
      press = "UI/guild/xiangqing2_icon.png"
    },
    {
      type = 3,
      normal = "UI/guild/xuexi1_icon.png",
      press = "UI/guild/xuexi2_icon.png"
    }
  }
  if self.m_info.id == 1 then
    table.remove(btnsConfig, 3)
  else
    table.remove(btnsConfig, 2)
  end
  for i, config in ipairs(btnsConfig) do
    do
      local btn = ccui.Button:create(config.normal, config.press)
      td.BtnAddTouch(btn, function()
        self:OnBtnClicked(config.type)
      end)
      btn:scale(1 / self.m_scale):addTo(self)
      btn:setVisible(false)
      table.insert(self.m_vBtn, btn)
    end
  end
end
function GuildBuildingBtn:OnBtnClicked(_type)
  if not self:isVisible() then
    return
  end
  local dlg
  if _type == 1 then
    if self.m_data.level >= 10 then
      td.alertErrorMsg(td.ErrorCode.LEVEL_MAX)
    else
      dlg = require("app.layers.guild.GuildDonateDlg").new(self.m_data.id)
    end
  elseif _type == 2 then
    dlg = require("app.layers.guild.GuildLevelDlg").new(self.m_data.level)
  else
    dlg = require("app.layers.guild.GuildSkillDlg").new(self.m_data.id)
  end
  td.popView(dlg)
end
function GuildBuildingBtn:OnTouchBegan()
  if self.m_bActive then
    self:Inactive()
  else
    self:runAction(cca.seq({
      cca.scaleTo(0.1, 1.1 * self.m_scale),
      cca.cb(handler(self, self.Active)),
      cca.scaleTo(0.1, 1 * self.m_scale)
    }))
  end
  self.m_bActive = not self.m_bActive
end
function GuildBuildingBtn:Active()
  self.m_nameLabel:setVisible(true)
  if #self.m_vBtn == 0 then
    self:InitBtns()
  end
  if self.m_gdm:GetRPBuildings()[self.m_info.id] == true then
    self.m_gdm:SetBuildingRP(self.m_info.id, false)
    td.dispatchEvent(td.BUILDING_UPGRADE, 0)
  end
  for i, btn in ipairs(self.m_vBtn) do
    btn:runAction(cca.seq({
      cca.delay((i - 1) * 0.1),
      cca.cb(function()
        btn:setVisible(true)
      end),
      cc.EaseElasticOut:create(cca.moveTo(0.5, (-180 + i * 120) / self.m_scale, 130 / self.m_scale), 1)
    }))
  end
end
function GuildBuildingBtn:Inactive()
  self.m_nameLabel:setVisible(false)
  for i, btn in ipairs(self.m_vBtn) do
    btn:setVisible(false)
    btn:pos(0, 0)
  end
end
return GuildBuildingBtn
