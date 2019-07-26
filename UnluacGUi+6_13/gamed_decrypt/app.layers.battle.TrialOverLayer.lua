local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local MissionInfoManager = require("app.info.MissionInfoManager")
local TrialOverLayer = class("TrialOverLayer", BaseDlg)
TrialOverLayer.FailConfig = {
  {
    str = "a00297",
    img = "sodier.png",
    ui = td.UIModule.Camp
  },
  {
    str = "a00299",
    img = "sodier_skill.png",
    ui = td.UIModule.Camp
  }
}
function TrialOverLayer:ctor(bIsWin)
  TrialOverLayer.super.ctor(self)
  self.m_uiRoot = nil
  self.m_bIsWin = bIsWin
  self.m_curLevel = GameDataManager:GetInstance():GetTrialData().level
  self.m_mode = GameDataManager:GetInstance():GetTrialData().mode
  self:InitUI()
end
function TrialOverLayer:onEnter()
  TrialOverLayer.super.onEnter(self)
  self:AddEvents()
  self:AddEffect()
  G_SoundUtil:StopMusic()
  G_SoundUtil:StopAllSounds()
  G_SoundUtil:PlaySound(60, false)
end
function TrialOverLayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/TrialOverLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "BgNode")
  if self.m_bIsWin then
  else
    self.m_failConfig = TrialOverLayer.FailConfig[math.random(#TrialOverLayer.FailConfig)]
    do
      local failBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_fail")
      failBg:setVisible(true)
      local label = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_str")
      label:setString(g_LM:getBy(self.m_failConfig.str))
      local icon = failBg:getChildByName("Image_icon")
      icon:loadTexture("UI/battle/fightover/" .. self.m_failConfig.img)
      local btn = failBg:getChildByName("Button_go")
      td.BtnAddTouch(btn, function()
        btn:setDisable(true)
        GameDataManager:GetInstance():ExitGame(self.m_failConfig.ui)
      end)
      td.BtnSetTitle(btn, g_LM:getBy("a00051"))
    end
  end
  local btnExit = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_exit_6")
  td.BtnAddTouch(btnExit, function()
    btnExit:setDisable(true)
    GameDataManager:GetInstance():ExitGame(td.UIModule.Trial)
  end)
  td.BtnSetTitle(btnExit, g_LM:getBy("a00287"))
end
function TrialOverLayer:AddEvents()
end
function TrialOverLayer:AddEffect()
  local file = self.m_bIsWin and "Spine/UI_effect/UI_shilianshengli_01" or "Spine/UI_effect/UI_shilianshibai_01"
  local spine = SkeletonUnit:create(file)
  spine:setPosition(self.m_bg:getPosition())
  spine:addTo(self.m_bg:getParent())
  spine:PlayAni("animation_01", false)
  spine:registerSpineEventHandler(function(event)
    if event.animation == "animation_01" then
      spine:PlayAni("animation_02", true)
    end
  end, sp.EventType.ANIMATION_COMPLETE)
end
return TrialOverLayer
