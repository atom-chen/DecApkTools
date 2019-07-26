local BaseDlg = require("app.layers.BaseDlg")
local CommonEvoDlg = class("CommonEvoDlg", BaseDlg)
function CommonEvoDlg:ctor(data)
  CommonEvoDlg.super.ctor(self, 255, false)
  self.m_id = nil
  self.m_quality = nil
  self.m_star = nil
  self.m_icon = nil
  self.m_cbEventName = data.eventName
  self:InitUI(data)
end
function CommonEvoDlg:onEnter()
  CommonEvoDlg.super.onEnter(self)
  self:AnimateIcon()
end
function CommonEvoDlg:onExit()
  CommonEvoDlg.super.onEnter(self)
end
function CommonEvoDlg:InitUI(data)
  self.m_uiRoot = cc.uiloader:load("CCS/CommonEvoLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  print(self.m_uiRoot:getContentSize().width)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_panelStars = cc.uiloader:seekNodeByName(self.m_bg, "Panel_stars")
  td.CreateUIEffect(self.m_bg, "Spine/UI_effect/UI_jinhuachenggong_01", {
    loop = true,
    pos = cc.p(568, 410)
  })
  local bgParticle = ParticleManager:GetInstance():CreateParticle("Effect/shexian_01.plist")
  td.AddRelaPos(self.m_bg, bgParticle, 0, cc.p(0, 0.5))
  if data.type == "Equipment" then
    self.m_quality = data.data.weaponInfo.quality
    self.m_star = data.data.star
    self.m_icon = td.CreateWeaponIcon(data.data.weaponId)
  elseif data.type == "Skill" then
    self.m_quality = data.data.quality
    self.m_star = data.data.star
    self.m_icon = td.CreateSkillIcon(data.data.skill_id)
  elseif data.type == "Unit" then
    self.m_quality = data.data.quality
    self.m_star = data.data.star
    self.m_icon = display.newSprite(data.data.soldierInfo.head .. td.PNG_Suffix)
  elseif data.type == "Hero" then
    self.m_quality = data.data.quality
    self.m_star = data.data.star
    self.m_icon = display.newSprite(data.data.heroInfo.head .. td.PNG_Suffix)
  end
  if self.m_icon then
    self.m_icon:pos(568, 410):addTo(self.m_bg)
  end
end
function CommonEvoDlg:AnimateIcon()
  if self.m_icon then
    self.m_icon:setVisible(false)
    self.m_icon:setScale(3)
    self.m_icon:setLocalZOrder(99)
    self.m_icon:runAction(cca.seq({
      cca.cb(function()
        self.m_icon:setVisible(true)
      end),
      cc.EaseBackOut:create(cca.scaleTo(0.35, 1.2)),
      cca.cb(handler(self, self.CreateStars))
    }))
  end
end
function CommonEvoDlg:CreateStars()
  local bgSize = self.m_panelStars:getContentSize()
  local length = self.m_quality
  for i = 1, length do
    do
      local starBg = ccui.ImageView:create("UI/common/xingxing2_icon.png")
      local starSize = starBg:getContentSize()
      starBg:setAnchorPoint(0, 0.5)
      local Gap = 32
      local x = (bgSize.width - (length - 1) * Gap - starSize.width * length) / 2 + (i - 1) * (Gap + starSize.width)
      starBg:pos(x, bgSize.height / 2):addTo(self.m_panelStars)
      if i < self.m_star then
        do
          local star = display.newSprite("UI/common/xingxing1_icon.png")
          star:setScale(0.1)
          star:setVisible(false)
          td.AddRelaPos(starBg, star)
          star:runAction(cca.seq({
            cca.delay(i * 0.2),
            cca.cb(function()
              star:setVisible(true)
            end),
            cca.scaleTo(0.2, 1),
            cca.cb(function()
              starBg:loadTexture("UI/common/xingxing1_icon.png")
            end)
          }))
        end
      elseif i == self.m_star then
        starBg:runAction(cca.seq({
          cca.delay(0.2 * i),
          cca.cb(function()
            local star = SkeletonUnit:create("Spine/UI_effect/UI_jiesuanxing_01")
            td.AddRelaPos(starBg, star)
            star:PlayAni("animation", false)
            star:performWithDelay(function()
              td.CreateUIEffect(self.m_icon, "Spine/UI_effect/UI_iconxishou_01")
              starBg:loadTexture("UI/common/xingxing1_icon.png")
            end, 0.7)
          end),
          cca.delay(2.5),
          cca.cb(function()
            if self.m_cbEventName then
              td.dispatchEvent(self.m_cbEventName)
            end
            self:close()
          end)
        }))
      end
    end
  end
end
return CommonEvoDlg
