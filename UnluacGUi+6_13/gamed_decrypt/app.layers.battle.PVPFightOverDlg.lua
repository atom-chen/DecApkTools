local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local PVPFightOverDlg = class("PVPFightOverDlg", BaseDlg)
PVPFightOverDlg.FailConfig = {
  {
    str = "a00297",
    img = "sodier.png",
    ui = td.UIModule.Camp
  },
  {
    str = "a00299",
    img = "sodier_skill.png",
    ui = td.UIModule.Camp
  },
  {
    str = "a00298",
    img = "hero.png",
    ui = td.UIModule.Hero
  },
  {
    str = "a00314",
    img = "base.png",
    ui = td.UIModule.BaseCamp
  }
}
function PVPFightOverDlg:ctor(info)
  PVPFightOverDlg.super.ctor(self)
  self.m_bIsWin = info.isWin
  self.m_maxRank = info.maxRank
  self.m_curRank = info.curRank
  self.m_ticket = info.ticket
  self.m_iTimeInterval = 0
  self.m_bExit = false
  self:setNodeEventEnabled(true)
  self:InitUI()
end
function PVPFightOverDlg:onEnter()
  PVPFightOverDlg.super.onEnter(self)
  self:AddEvents()
  self:AddEffect()
  G_SoundUtil:StopMusic()
  G_SoundUtil:StopAllSounds()
  G_SoundUtil:PlaySound(60, false)
end
function PVPFightOverDlg:onExit()
  PVPFightOverDlg.super.onExit(self)
end
function PVPFightOverDlg:AddEvents()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function PVPFightOverDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/PVPFightOverDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "BgNode")
  local labelPosY, labelPosX = -150, -100
  if not self.m_bIsWin then
    labelPosY = -230
    self.m_failConfig = PVPFightOverDlg.FailConfig[math.random(#PVPFightOverDlg.FailConfig)]
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
  local label1 = td.CreateBMF(tostring(self.m_maxRank), "Fonts/Yellow_outlight.fnt", 0.6)
  local label = td.RichText({
    {
      type = 1,
      color = td.WHITE,
      size = 20,
      str = g_LM:getBy("a00275")
    },
    {type = 3, node = label1}
  })
  label:align(display.LEFT_CENTER, labelPosX, labelPosY):addTo(self.m_bg)
  local label2 = td.CreateBMF(tostring(self.m_curRank), "Fonts/Yellow_outlight.fnt", 0.6)
  local textData = {
    {
      type = 1,
      color = td.WHITE,
      size = 20,
      str = g_LM:getBy("a00274")
    },
    {type = 3, node = label2}
  }
  if self.m_curRank < self.m_maxRank then
    table.insert(textData, {
      type = 1,
      color = td.YELLOW,
      size = 20,
      str = "("
    })
    table.insert(textData, {
      type = 2,
      file = "UI/common/shangsheng_jiantou.png",
      scale = 1
    })
    table.insert(textData, {
      type = 1,
      color = td.YELLOW,
      size = 20,
      str = tostring(self.m_maxRank - self.m_curRank) .. ")"
    })
  end
  label = td.RichText(textData)
  label:align(display.LEFT_CENTER, labelPosX, labelPosY - 50):addTo(self.m_bg)
  local textData = {
    {
      type = 1,
      color = td.WHITE,
      size = 20,
      str = g_LM:getBy("a00315") .. ":"
    },
    {
      type = 2,
      file = td.GetItemIcon(td.ItemID_Check),
      scale = 0.5
    },
    {
      type = 1,
      color = td.WHITE,
      size = 20,
      str = "x" .. self.m_ticket
    }
  }
  label = td.RichText(textData)
  label:align(display.LEFT_CENTER, labelPosX, labelPosY - 100):addTo(self.m_bg)
end
function PVPFightOverDlg:onTouchEnded()
  if self.m_bActionOver and not self.m_bExit then
    self.m_bExit = true
    GameDataManager:GetInstance():ExitGame(td.UIModule.PVP)
  end
end
function PVPFightOverDlg:AddEffect()
  local file = self.m_bIsWin and "Spine/UI_effect/UI_shilianshengli_01" or "Spine/UI_effect/UI_shilianshibai_01"
  local spine = SkeletonUnit:create(file)
  spine:setPosition(self.m_bg:getPosition())
  spine:addTo(self.m_bg:getParent())
  spine:PlayAni("animation_01", false)
  spine:registerSpineEventHandler(function(event)
    if event.animation == "animation_01" then
      spine:PlayAni("animation_02", true)
      self.m_bg:setVisible(true)
      self.m_bActionOver = true
    end
  end, sp.EventType.ANIMATION_COMPLETE)
end
return PVPFightOverDlg
