local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local FightWinLayer = class("FightWinLayer", BaseDlg)
function FightWinLayer:ctor(data)
  FightWinLayer.super.ctor(self)
  if data then
    self.m_missionId = data.missionId
    self.m_awards = data.awards
  end
  self.m_bActionOver = false
  self.m_bExit = false
  self:setNodeEventEnabled(true)
  self:InitUI()
end
function FightWinLayer:onEnter()
  FightWinLayer.super.onEnter(self)
  self:AddEvents()
  G_SoundUtil:StopMusic()
  G_SoundUtil:StopAllSounds()
  G_SoundUtil:PlaySound(51, false)
end
function FightWinLayer:AddEvents()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function FightWinLayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/FightWinLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.m_panelTarget = cc.uiloader:seekNodeByName(self.m_bg, "Panel_target")
  local spine = SkeletonUnit:create("Spine/UI_effect/UI_zhandoujiesuan_01")
  td.AddRelaPos(self.m_bg, spine, 1, cc.p(0.5, 0.7))
  spine:PlayAni("animation_01", false)
  spine:registerSpineEventHandler(function(event)
    if event.animation == "animation_01" then
      if self.m_missionId then
        self:AddTarget()
      else
        self.m_bActionOver = true
      end
      spine:PlayAni("animation_02", true)
    end
  end, sp.EventType.ANIMATION_COMPLETE)
end
function FightWinLayer:AddTarget()
  local gdMng = GameDataManager:GetInstance()
  local missionInfo = gdMng:GetGameMapInfo()
  if missionInfo.id ~= gdMng:GetMissionId() then
    self.m_bActionOver = true
    return
  end
  local label = td.CreateLabel(g_LM:getBy("a00404"), nil, 24, td.OL_BLACK, 2)
  td.AddRelaPos(self.m_panelTarget, label, 1, cc.p(0.5, 1))
  local delayTime = 0
  local oriMissionData = gdMng:GetOriMissionData()
  for i = 1, 3 do
    do
      local starSpr = cc.uiloader:seekNodeByName(self.m_uiRoot, "Sprite_target" .. i)
      local starLabel = starSpr:getChildByTag(1)
      local type, expValue = missionInfo.star_level[i][1], missionInfo.star_level[i][2]
      local bResult, curValue = gdMng:CheckStarCondition(type, expValue)
      if type == td.StarLevel.UNIT_LIMIT then
        starLabel:setString(string.format(g_LM:getMode("starlvl", type), g_LM:getMode("career", expValue)))
      else
        starLabel:setString(string.format(g_LM:getMode("starlvl", type), expValue))
      end
      if bResult then
        do
          local star = display.newSprite("UI/common/xingxing1_icon.png")
          star:setScale(0)
          star:setVisible(false)
          td.AddRelaPos(starSpr, star)
          star:runAction(cca.seq({
            cca.delay(delayTime),
            cca.cb(function()
              star:setVisible(true)
            end),
            cc.EaseBounceOut:create(cca.scaleTo(0.3, 1, 1)),
            cca.cb(function()
              starLabel:setColor(td.GREEN)
              local stateLabel
              if not oriMissionData or not oriMissionData.star[i] then
                stateLabel = td.RichText({
                  {
                    type = 2,
                    file = td.DIAMOND_ICON,
                    scale = 0.5
                  },
                  {
                    type = 1,
                    str = "x10",
                    color = td.WHITE,
                    size = 18
                  }
                })
              else
                stateLabel = td.CreateLabel(g_LM:getBy("a00405"), td.GREEN, 18)
              end
              stateLabel:align(display.LEFT_CENTER, 300, 30):addTo(starSpr)
            end)
          }))
          delayTime = delayTime + 0.3
        end
      end
    end
  end
  self.m_panelTarget:setVisible(true)
  self.m_panelTarget:performWithDelay(function()
    self.m_bActionOver = true
  end, delayTime)
end
function FightWinLayer:onTouchEnded()
  if self.m_bActionOver and not self.m_bExit then
    if self.m_awards then
      local awardDlg = require("app.layers.battle.FightWinAwardsDlg").new(self.m_awards)
      td.popView(awardDlg)
      self.m_bExit = true
      self:removeFromParent()
    else
      GameDataManager:GetInstance():ExitGame()
    end
  end
end
return FightWinLayer
