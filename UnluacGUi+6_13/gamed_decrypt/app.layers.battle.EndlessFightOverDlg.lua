local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local EndlessFightOverDlg = class("EndlessFightOverDlg", BaseDlg)
function EndlessFightOverDlg:ctor()
  EndlessFightOverDlg.super.ctor(self)
  local gdMng = GameDataManager:GetInstance()
  self.m_iWave = (gdMng:GetMonsterWave() - 1) * gdMng:GetMaxMonsterCount() + gdMng:GetCurMonsterCount()
  if self.m_iWave < 0 then
    self.m_iWave = 0
  end
  self.m_iMaxWave = gdMng:GetEndlessMaxWave()
  self.m_reward = gdMng:GetEndlessReward()
  self.m_bExit = false
  self:InitUI()
end
function EndlessFightOverDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EndlessFightOverDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:SetTitle(td.Word_Path .. "wenzi_zhanbao.png")
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  local bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local value = math.floor(self.m_iWave / 5)
  local dizuo = cc.uiloader:seekNodeByName(self.m_uiRoot, "dizuo1")
  local label = td.CreateLabel(tostring(value), td.WHITE, 16, td.OL_BLACK)
  label:setAnchorPoint(cc.p(0.5, 0.5))
  label:setPosition(cc.p(dizuo:getContentSize().width / 2, -12))
  dizuo:addChild(label)
  local vStr = string.split(g_LM:getBy("a00215"), "#")
  label = td.RichText({
    {
      type = 1,
      color = td.WHITE,
      size = 18,
      str = vStr[1]
    },
    {
      type = 1,
      color = td.YELLOW,
      size = 20,
      str = tostring(self.m_iWave)
    },
    {
      type = 1,
      color = td.WHITE,
      size = 18,
      str = vStr[2]
    }
  })
  label:setAnchorPoint(cc.p(0, 0.5))
  label:setPosition(cc.p(60, 300))
  bg:addChild(label)
  local time = 0
  if self.m_iMaxWave == 0 then
    if self.m_iWave ~= 0 then
      time = os.time()
      self.m_iMaxWave = self.m_iWave
    end
  elseif self.m_iMaxWave < self.m_iWave then
    time = os.time()
    self.m_iMaxWave = self.m_iWave
  else
    time = GameDataManager:GetInstance():GetEndlessMaxWaveTime()
  end
  if time ~= 0 then
    local timeStr = os.date("%Y/%m/%d", time)
    local t = string.split(timeStr, "/")
    local vStr = string.split(string.format(g_LM:getBy("a00216"), t[1], t[2], t[3]), "#")
    label = td.RichText({
      {
        type = 1,
        color = td.WHITE,
        size = 18,
        str = vStr[1]
      },
      {
        type = 1,
        color = td.YELLOW,
        size = 20,
        str = tostring(self.m_iMaxWave)
      },
      {
        type = 1,
        color = td.WHITE,
        size = 18,
        str = vStr[2]
      }
    })
    label:setAnchorPoint(cc.p(0, 0.5))
    label:setPosition(cc.p(60, 250))
    bg:addChild(label)
  end
  local label = td.CreateBMF(g_LM:getBy("a00281"), "Fonts/BlackWhite18.fnt", 1)
  label:setAnchorPoint(0, 0.5)
  label:pos(60, 180):addTo(bg)
end
function EndlessFightOverDlg:onEnter()
  EndlessFightOverDlg.super.onEnter(self)
  self:AddEvents()
  G_SoundUtil:StopMusic()
  G_SoundUtil:StopAllSounds()
  G_SoundUtil:PlaySound(51, false)
end
function EndlessFightOverDlg:onExit()
  EndlessFightOverDlg.super.onExit(self)
end
function EndlessFightOverDlg:AddEvents()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded()
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function EndlessFightOverDlg:onTouchEnded()
  if not self.m_bExit then
    self.m_bExit = true
    GameDataManager:GetInstance():ExitGame(td.UIModule.Endless)
  end
end
return EndlessFightOverDlg
