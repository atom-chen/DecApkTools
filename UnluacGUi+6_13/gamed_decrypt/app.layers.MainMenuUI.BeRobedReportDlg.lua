local BaseDlg = require("app.layers.BaseDlg")
local scheduler = require("framework.scheduler")
local ActorInfoManager = require("app.info.ActorInfoManager")
local UserDataManager = require("app.UserDataManager")
local InformationManager = require("app.layers.InformationManager")
local BeRobedReportDlg = class("BeRobedReportDlg", BaseDlg)
function BeRobedReportDlg:ctor(data)
  BeRobedReportDlg.super.ctor(self)
  self.m_name = data.name
  self.m_itemId = data.itemId
  local udMng = UserDataManager:GetInstance()
  self.m_baseLevel = udMng:GetBaseCampLevel()
  self.m_maxCount = td.GetMaxRob(self.m_itemId, self.m_baseLevel)
  if data.type == 1 then
    self.m_count = data.count
    self.m_proCount = self.m_maxCount - self.m_count
    self.m_reports = {}
    if data.report and data.report ~= "" then
      local tmp = string.split(data.report, "&")
      for i, var in ipairs(tmp) do
        local report = {}
        local tmp1 = string.split(var, "#")
        report.heroId = tonumber(tmp1[1])
        report.num = tonumber(tmp1[2])
        table.insert(self.m_reports, report)
      end
    end
    self:ShowReport()
    if not data.already then
      if self.m_itemId == td.ItemID_Gold then
        udMng:PublicGain(td.WealthType.GOLD, self.m_proCount)
      else
        udMng:PublicGain(td.WealthType.EXP, self.m_proCount)
      end
    end
  else
    self:ShowInfo()
    if self.m_itemId == td.ItemID_Gold then
      udMng:PublicConsume(td.WealthType.GOLD, self.m_maxCount)
    else
      udMng:PublicConsume(td.WealthType.EXP, self.m_maxCount)
    end
  end
  self:setNodeEventEnabled(true)
end
function BeRobedReportDlg:onEnter()
  BeRobedReportDlg.super.onEnter(self)
  self:AddEvents()
end
function BeRobedReportDlg:onExit()
  BeRobedReportDlg.super.onExit(self)
end
function BeRobedReportDlg:ShowInfo()
  local udMng = UserDataManager:GetInstance()
  udMng:UpdateBeRobedTime()
  udMng:SetProfitLock(self.m_itemId, true)
  local bgSize = cc.size(450, 290)
  self.m_bg = display.newScale9Sprite("UI/scale9/yijitankuang2.png", display.size.width / 2, display.size.height / 2, bgSize, cc.rect(110, 80, 5, 2))
  self.m_bg:setScale(td.GetAutoScale())
  self:addChild(self.m_bg)
  local vScale, vPosX = {
    cc.p(1, 1),
    cc.p(-1, 1)
  }, {
    self.m_bg:getContentSize().width - 8,
    8
  }
  local wealthName = self.m_itemId == td.ItemID_Gold and "it00002" or "it00001"
  local str = string.format(g_LM:getBy("a00292"), self.m_maxCount, g_LM:getBy(wealthName), self.m_name)
  local label = td.CreateLabel(str, td.WHITE, 20, nil, nil, cc.size(bgSize.width - 120, 0))
  td.AddRelaPos(self.m_bg, label, 1, cc.p(0.5, 0.6))
  local button = td.CreateBtn(td.BtnType.GreenLong)
  td.AddRelaPos(self.m_bg, button, 1, cc.p(0.5, 0.2))
  button:addTouchEventListener(function(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      self:close()
      InformationManager:GetInstance():OnShowDone(td.ShowInfo.BeRobed)
    end
  end)
  td.BtnSetTitle(button, g_LM:getBy("a00009"))
end
function BeRobedReportDlg:ShowReport()
  local udMng = UserDataManager:GetInstance()
  udMng:UpdateBeRobedTime(true)
  udMng:SetProfitLock(self.m_itemId, false)
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  local panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_bg = display.newSprite("UI/scale9/jianbiandi.png")
  td.AddRelaPos(panel, self.m_bg)
  local titleSpr = display.newSprite(td.Word_Path .. "wenzi_jinbilueduo.png")
  td.AddRelaPos(self.m_bg, titleSpr, 1, cc.p(0.5, 1))
  local conBg = display.newScale9Sprite("UI/scale9/bantouming3.png", 0, 0, cc.size(550, 50))
  td.AddRelaPos(self.m_bg, conBg, 1, cc.p(0.5, 0.8))
  local conLabel = td.RichText({
    {
      type = 1,
      str = self.m_name,
      color = td.YELLOW,
      size = 22
    },
    {
      type = 1,
      str = "\230\142\160\229\164\186\228\186\134\228\189\160",
      color = td.WHITE,
      size = 22
    },
    {
      type = 2,
      file = td.GetItemIcon(self.m_itemId),
      scale = 0.4
    },
    {
      type = 1,
      str = "" .. self.m_count,
      color = td.YELLOW,
      size = 22
    },
    {
      type = 1,
      str = ",\228\189\160\231\154\132\232\139\177\233\155\132\228\184\186\228\189\160\229\174\136\230\138\164\228\186\134",
      color = td.WHITE,
      size = 22
    },
    {
      type = 2,
      file = td.GetItemIcon(self.m_itemId),
      scale = 0.4
    },
    {
      type = 1,
      str = "" .. self.m_proCount,
      color = td.YELLOW,
      size = 22
    }
  })
  conLabel:setAnchorPoint(0, 0.5)
  conLabel:pos(20, 25):addTo(conBg)
  local label = td.CreateBMF(g_LM:getBy("a00293"), "Fonts/BlackWhite18.fnt")
  label:setAnchorPoint(0, 0.5)
  label:pos(305, 237):addTo(self.m_bg)
  local count = #self.m_reports
  local vPosX
  if count == 1 then
    vPosX = {0.5}
  elseif count == 2 then
    vPosX = {0.4, 0.6}
  else
    vPosX = {
      0.3,
      0.5,
      0.7
    }
  end
  for i, var in ipairs(self.m_reports) do
    if i > 3 then
      break
    end
    local node = self:CreateItem(var)
    td.AddRelaPos(self.m_bg, node, 1, cc.p(vPosX[i], 0.4))
  end
end
function BeRobedReportDlg:CreateItem(data)
  local itemBg = display.newSprite("UI/hero/touxiangkuang2.png")
  local bgSize = itemBg:getContentSize()
  local heroInfo = ActorInfoManager:GetInstance():GetHeroInfo(data.heroId)
  local headSpr = display.newSprite(heroInfo.head .. td.PNG_Suffix)
  headSpr:setScale(bgSize.width / headSpr:getContentSize().width)
  td.AddRelaPos(itemBg, headSpr)
  local borderSpr = display.newSprite("UI/hero/touxiangkuang1.png")
  td.AddRelaPos(itemBg, borderSpr, 1, cc.p(0.5, 0.55))
  local nameLabel = td.CreateLabel(heroInfo.name, td.LIGHT_BLUE, 16)
  td.AddRelaPos(itemBg, nameLabel, 1, cc.p(0.5, 1.3))
  local killLabel = td.RichText({
    {
      type = 2,
      file = "UI/icon/kulou_icon.png",
      scale = 0.4
    },
    {
      type = 1,
      str = "x" .. data.num,
      color = td.WHITE,
      size = 18
    }
  })
  td.AddRelaPos(itemBg, killLabel, 1, cc.p(0.5, -0.3))
  local jumpBtn = td.CreateBtn(td.BtnType.GreenShort)
  jumpBtn:setScale(0.8)
  td.BtnAddTouch(jumpBtn, function()
    self:close()
    g_MC:OpenModule(td.UIModule.Hero)
  end)
  td.BtnSetTitle(jumpBtn, g_LM:getBy("a00078"))
  td.AddRelaPos(itemBg, jumpBtn, 1, cc.p(0.5, -0.8))
  return itemBg
end
function BeRobedReportDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      scheduler.performWithDelayGlobal(function(times)
        self:close()
        InformationManager:GetInstance():OnShowDone(td.ShowInfo.BeRobed)
      end, 0.03333333333333333)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
return BeRobedReportDlg
