local BaseDlg = require("app.layers.BaseDlg")
local MagicBannerLayer = class("MagicBannerLayer", BaseDlg)
function MagicBannerLayer:ctor(skillId, cb)
  self.endCb = cb
  self:InitUI(skillId)
end
function MagicBannerLayer:InitUI(skillId)
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  local bg = SkeletonUnit:create("Spine/UI_effect/UI_jinengshifang_01")
  bg:setScaleX(-1)
  bg:pos(-500, 215):addTo(self.m_bg)
  bg:runAction(cca.seq({
    cc.EaseBackOut:create(cca.moveBy(0.3, 930, 0)),
    cca.delay(2.5),
    cca.scaleTo(0.1, 1, 0),
    cca.cb(function()
      if self.endCb then
        self.endCb()
        self.endCb = nil
      end
      self:close()
    end)
  }))
  td.CreateUIEffect(bg, "Spine/UI_effect/UI_jinengshifang_02", {zorder = 1})
  local heroId = require("app.GameDataManager"):GetInstance():GetCurHeroData().hid
  local heroInfo = require("app.info.ActorInfoManager"):GetInstance():GetHeroInfo(heroId)
  local headSpr = display.newSprite(heroInfo.head .. td.PNG_Suffix)
  headSpr:setScale(0.01)
  headSpr:setLocalZOrder(0)
  td.AddRelaPos(bg, headSpr, 1, cc.p(0.3, 0.5))
  headSpr:runAction(cca.seq({
    cca.delay(0.3),
    cc.EaseBounceOut:create(cca.scaleTo(0.2, 1, 1))
  }))
  local skillInfo = require("app.info.SkillInfoManager"):GetInstance():GetInfo(skillId)
  local sprs = {}
  for i = 3, string.len(skillInfo.name), 3 do
    local _str = string.sub(skillInfo.name, i - 2, i)
    local _spr = td.CreateLabel(_str, td.WHITE, 36, td.OL_BLUE)
    local bgSpr = display.newSprite("UI/skill_words/word_bg.png")
    td.AddRelaPos(bgSpr, _spr)
    table.insert(sprs, bgSpr)
  end
  for i, val in ipairs(sprs) do
    do
      local width = val:getContentSize().width
      val:setScaleX(-3)
      val:setScaleY(3)
      val:setLocalZOrder(2)
      val:setVisible(false)
      val:pos(430 - width * i, bg:getContentSize().height / 2):addTo(bg)
      val:runAction(cca.seq({
        cca.delay(0.3 + 0.4 * i),
        cca.show(),
        cca.cb(function()
          td.CreateUIEffect(val, "Spine/UI_effect/UI_jinengshifang_03")
        end),
        cca.scaleTo(0.15, -1, 1)
      }))
    end
  end
end
function MagicBannerLayer:onEnter()
  MagicBannerLayer.super.onEnter(self)
end
function MagicBannerLayer:onExit()
  MagicBannerLayer.super.onExit(self)
end
return MagicBannerLayer
