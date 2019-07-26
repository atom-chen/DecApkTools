local UserDataManager = require("app.UserDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local ItemInfoManager = require("app.info.ItemInfoManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local BaseDlg = require("app.layers.BaseDlg")
local WeaponUpgradeEffect = class("WeaponUpgradeEffect", BaseDlg)
function WeaponUpgradeEffect:ctor(config, cb)
  WeaponUpgradeEffect.super.ctor(self)
  self.m_config = config
  self.m_items = {}
  self:SetData()
  self:InitUI(cb)
end
function WeaponUpgradeEffect:onEnter()
  WeaponUpgradeEffect.super.onEnter(self)
end
function WeaponUpgradeEffect:onExit()
  WeaponUpgradeEffect.super.onExit(self)
end
function WeaponUpgradeEffect:InitUI(cb)
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  local bgParticle = ParticleManager:GetInstance():CreateParticle("Effect/shexian_01.plist")
  td.AddRelaPos(self.m_bg, bgParticle, 1, cc.p(0, 0.5))
  self.m_weaponIcon = td.CreateWeaponIcon(self.m_weaponData.weaponId, self.m_weaponData.star)
  self.m_weaponIcon:setVisible(false)
  td.AddRelaPos(self.m_bg, self.m_weaponIcon, 1, cc.p(0.3, 0.7))
  local length = #self.m_weapons + #self.m_materials
  if #self.m_weapons >= 5 then
    for key, val in ipairs(self.m_weapons) do
      local item = td.CreateWeaponIcon(val.weaponId, val.star)
      table.insert(self.m_items, item)
    end
  elseif #self.m_weapons < 5 and length > 5 then
    for key, val in ipairs(self.m_weapons) do
      local item = td.CreateWeaponIcon(val.weaponId, val.star)
      table.insert(self.m_items, item)
    end
    for i = 1, 5 - #self.m_weapons do
      local item = td.CreateItemIcon(self.m_materials[i].id, true)
      table.insert(self.m_items, item)
    end
  elseif length <= 5 then
    for key, val in ipairs(self.m_weapons) do
      local item = td.CreateWeaponIcon(val.weaponId, val.star)
      table.insert(self.m_items, item)
    end
    for key, val in ipairs(self.m_materials) do
      local item = td.CreateItemIcon(val.id, true)
      table.insert(self.m_items, item)
    end
  end
  for key, val in ipairs(self.m_items) do
    local width = val:getContentSize().width
    local offset = (1136 - width * (#self.m_items - 1)) / (#self.m_items - 1 + 2)
    local posX = (key - 1) * width + key * offset
    val:pos(posX, 120):addTo(self.m_bg)
    val:setVisible(false)
    val:setScale(0.1, 0.1)
  end
  self:RunActions(cb)
end
function WeaponUpgradeEffect:RunActions(cb)
  local bezierConfig = {
    cc.p(200, 400),
    cc.p(800, 620),
    cc.p(568, 500)
  }
  local loopX = 3
  local loopY = 6
  local x = 568
  local y = 500
  local twirlAction = cca.repeatForever(cca.seq({
    cc.BezierTo:create(0.6, {
      cc.p(x, y),
      cc.p(x - loopX, y - loopY),
      cc.p(x - 2 * loopX, y)
    }),
    cc.BezierTo:create(0.6, {
      cc.p(x - 2 * loopX, y),
      cc.p(x - 3 * loopX, y + loopY),
      cc.p(x - 4 * loopX, y)
    }),
    cc.BezierTo:create(0.6, {
      cc.p(x - 4 * loopX, y),
      cc.p(x - 3 * loopX, y - loopY),
      cc.p(x - 2 * loopX, y)
    }),
    cc.BezierTo:create(0.6, {
      cc.p(x - 2 * loopX, y),
      cc.p(x - 1 * loopX, y + loopY),
      cc.p(x, y)
    })
  }))
  self.m_weaponIcon:setScale(0.3, 0.3)
  self.m_weaponIcon:setVisible(true)
  self.m_weaponIcon:runAction(cca.seq({
    cca.spawn({
      cc.EaseBackOut:create(cc.BezierTo:create(0.5, bezierConfig)),
      cca.scaleTo(0.5, 1)
    }),
    twirlAction
  }))
  for key, val in ipairs(self.m_items) do
    val:runAction(cca.seq({
      cca.delay(0.2 + 0.2 * (key - 1)),
      cca.cb(function()
        val:setVisible(true)
        td.CreateUIEffect(val, "Spine/UI_effect/UI_iconchuxian_01", {scale = 2})
      end),
      cc.EaseBackOut:create(cca.scaleTo(0.2, 1)),
      cca.delay(0.1 + key * 0.3),
      cca.cb(function()
        local g = ParticleManager:GetInstance():CreateParticle("Effect/guiji_01.plist")
        td.AddRelaPos(val, g)
        G_SoundUtil:PlaySound(71)
      end),
      cca.spawn({
        cca.scaleTo(0.7, 0),
        cc.EaseBackOut:create(cca.moveTo(1, x, y)),
        cca.seq({
          cca.delay(0.35),
          cca.cb(function()
            local b = ParticleManager:GetInstance():CreateParticle("Effect/baodian05.plist")
            td.AddRelaPos(self.m_weaponIcon, b)
            td.CreateUIEffect(self.m_weaponIcon, "Spine/UI_effect/UI_iconxishou_01", {scale = 2})
          end)
        })
      })
    }))
  end
  self:performWithDelay(function()
    if cb then
      cb()
    end
    self:close()
  end, 2.3 + #self.m_items * 0.6)
end
function WeaponUpgradeEffect:SetData()
  self.m_weaponData = self.m_config.weaponData
  if self.m_config.weapons then
    self.m_weapons = self.m_config.weapons
  end
  self.m_materials = {}
  if self.m_config.materials then
    for key, material in ipairs(self.m_config.materials) do
      for i = 1, material.num do
        local item = {
          id = material.id
        }
        table.insert(self.m_materials, item)
      end
    end
  end
end
return WeaponUpgradeEffect
