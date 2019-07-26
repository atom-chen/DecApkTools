local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local PauseDlg = class("PauseDlg", BaseDlg)
function PauseDlg:ctor()
  PauseDlg.super.ctor(self)
  self.m_uiRoot = cc.uiloader:load("CCS/PauseDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_panelTarget = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_target")
  local conBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_continue")
  td.BtnAddTouch(conBtn, handler(self, self.Continue))
  local exBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_exit")
  td.BtnAddTouch(exBtn, function()
    self:ExitGame()
  end)
  local mapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  if mapInfo.id >= 1000 and mapInfo.id < 4000 then
    self:AddTarget()
  else
    self.m_panelTarget:setVisible(false)
    self.m_bg:setContentSize(cc.size(600, 225))
    ccui.Helper:doLayout(self.m_uiRoot)
  end
end
function PauseDlg:onEnter()
  PauseDlg.super.onEnter(self)
  cc.Director:getInstance():pause()
  cc.Director:getInstance():setOwenPause(true)
  G_SoundUtil:Pause(true)
end
function PauseDlg:onExit()
  PauseDlg.super.onExit(self)
  cc.Director:getInstance():resume()
  cc.Director:getInstance():setOwenPause(false)
end
function PauseDlg:AddTarget()
  local label = td.CreateLabel(g_LM:getBy("a00404"), nil, nil, td.OL_BLACK, 2)
  td.AddRelaPos(self.m_bg, label, 1, cc.p(0.5, 0.55))
  local gdMng = GameDataManager:GetInstance()
  local missionInfo = gdMng:GetGameMapInfo()
  for i = 1, 3 do
    local starSpr = cc.uiloader:seekNodeByName(self.m_uiRoot, "Sprite_target" .. i)
    local starLabel = starSpr:getChildByName("Text_desc" .. i)
    local numLabel = starSpr:getChildByName("Text_num" .. i)
    local type, expValue = missionInfo.star_level[i][1], missionInfo.star_level[i][2]
    local bResult, curValue = gdMng:CheckStarCondition(type, expValue)
    if type == td.StarLevel.UNIT_LIMIT then
      starLabel:setString(string.format(g_LM:getMode("starlvl", type), g_LM:getMode("career", expValue)))
    else
      starLabel:setString(string.format(g_LM:getMode("starlvl", type), expValue))
    end
    if type == td.StarLevel.UNIT_LIMIT or type == td.StarLevel.ONLY_PRIMITIVE then
      if bResult then
        numLabel:setString(g_LM:getBy("a00245"))
      else
        numLabel:setString(g_LM:getBy("a00323"))
      end
    else
      numLabel:setString(string.format("%d/%d", curValue, expValue))
    end
    if bResult then
      td.setTexture(starSpr, "UI/icon/xingxing_icon.png")
      starLabel:setColor(td.YELLOW)
      numLabel:setColor(td.YELLOW)
    end
  end
end
function PauseDlg:Continue()
  self:removeFromParent()
  G_SoundUtil:Resume(true)
end
function PauseDlg:ExitGame()
  local gdMng = GameDataManager:GetInstance()
  local type = gdMng:GetGameMapInfo().type
  if type == td.MapType.Endless then
    local function button1CallFunc()
      gdMng:ExitGame(td.UIModule.Endless)
    end
    local wave = (gdMng:GetMonsterWave() - 1) * gdMng:GetMaxMonsterCount() + gdMng:GetCurMonsterCount() - 1
    if wave < 0 then
      wave = 0
    end
    local maxWave = gdMng:GetEndlessMaxWave()
    local conStr = string.format(g_LM:getBy("a00197"), wave, maxWave)
    local button1 = {
      text = g_LM:getBy("a00009"),
      callFunc = button1CallFunc
    }
    local button2 = {
      text = g_LM:getBy("a00116")
    }
    local messageBoxDlg = require("app.layers.MessageBoxDlg").new({
      size = cc.size(454, 300),
      title = g_LM:getBy("a00196"),
      content = conStr,
      buttons = {button1, button2}
    })
    messageBoxDlg:Show()
  elseif type == td.MapType.Bomb then
    local function button1CallFunc(args)
      self:Continue()
      gdMng:GameWin()
    end
    local conStr = "\228\184\173\233\128\148\233\128\128\229\135\186\229\176\134\230\143\144\229\137\141\231\187\147\230\157\159\230\156\172\230\172\161\230\184\184\230\136\143"
    local button1 = {
      text = g_LM:getBy("a00009"),
      callFunc = handler(self, button1CallFunc)
    }
    local button2 = {
      text = g_LM:getBy("a00116")
    }
    local messageBoxDlg = require("app.layers.MessageBoxDlg").new({
      size = cc.size(454, 300),
      title = g_LM:getBy("a00196"),
      content = conStr,
      buttons = {button1, button2}
    })
    messageBoxDlg:Show()
  else
    gdMng:ExitGame()
  end
end
return PauseDlg
