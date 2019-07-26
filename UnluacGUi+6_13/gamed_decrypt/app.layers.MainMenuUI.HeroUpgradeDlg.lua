local TDHttpRequest = require("app.net.TDHttpRequest")
local StrongInfoManager = require("app.info.StrongInfoManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local UserDataManager = require("app.UserDataManager")
local scheduler = require("framework.scheduler")
local BaseDlg = require("app.layers.BaseDlg")
local HeroUpgradeDlg = class("HeroUpgradeDlg", BaseDlg)
function HeroUpgradeDlg:ctor()
  HeroUpgradeDlg.super.ctor(self)
  self.m_uiId = td.UIModule.HeroUpgrade
  self.m_heroData = nil
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function HeroUpgradeDlg:onEnter()
  HeroUpgradeDlg.super.onEnter(self)
  self:AddEvents()
  self:CheckGuide()
end
function HeroUpgradeDlg:onExit()
  HeroUpgradeDlg.super.onExit(self)
end
function HeroUpgradeDlg:SetData(data)
  self.m_heroData = data
  self:RefreshUI()
end
function HeroUpgradeDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/HeroUpgradeDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_uiBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self:SetTitle(td.Word_Path .. "wenzi_shengji.png")
end
function HeroUpgradeDlg:RefreshUI()
  local inFunc1 = function(data)
    local tmpLabel = data.node
    local tmpNode = data.parent
    tmpNode:addChild(tmpLabel)
    tmpLabel:setAnchorPoint(data.ancPos)
    tmpLabel:setPosition(data.pos)
  end
  local heroInfo = self.m_heroData.heroInfo
  local nextInfo = ActorInfoManager:GetInstance():GetHeroInfo(self.m_heroData.hid + 1) or {}
  local tmpNode = cc.uiloader:seekNodeByName(self.m_uiBg, "Image_lv_bg")
  local fromLv = self.m_heroData.heroInfo.level
  local tmpLabel = td.RichText({
    {
      type = 1,
      color = td.YELLOW,
      size = 16,
      str = "LV." .. fromLv
    },
    {
      type = 2,
      file = "UI/hero/jiantou_icon.png",
      scale = 1
    },
    {
      type = 1,
      color = td.YELLOW,
      size = 16,
      str = "LV." .. fromLv + 1
    }
  })
  inFunc1({
    node = tmpLabel,
    parent = tmpNode,
    ancPos = cc.p(0.5, 0.5),
    pos = cc.p(tmpNode:getContentSize().width * 0.5, tmpNode:getContentSize().height * 0.5)
  })
  tmpNode = cc.uiloader:seekNodeByName(self.m_uiBg, "Image_icon_bg")
  local heroSpineFile = self.m_heroData.heroInfo.image
  tmpLabel = SkeletonUnit:create(heroSpineFile)
  tmpLabel:PlayAni("stand")
  inFunc1({
    node = tmpLabel,
    parent = tmpNode,
    ancPos = cc.p(0.5, 0),
    pos = cc.p(tmpNode:getContentSize().width * 0.5, 20)
  })
  tmpNode = cc.uiloader:seekNodeByName(self.m_uiBg, "Image_detail_bg")
  local y_attribute1 = tmpNode:getContentSize().height - 20
  local y_offset = 35
  local x_start = 260
  local inFunc2 = function(data)
    data.icon = data.icon
    local fromValueStr = data.fromValue .. ""
    while string.len(fromValueStr) < 5 do
      fromValueStr = fromValueStr .. " "
    end
    local tmpLabel = td.RichText({
      {
        type = 2,
        file = data.icon,
        scale = 1
      },
      {
        type = 1,
        color = td.LIGHT_GREEN,
        size = 16,
        str = data.txt
      },
      {
        type = 1,
        color = td.WHITE,
        size = 14,
        str = fromValueStr
      },
      {
        type = 2,
        file = "UI/hero/jiantou_icon.png",
        scale = 1
      },
      {
        type = 1,
        color = td.WHITE,
        size = 14,
        str = data.toValue
      }
    })
    tmpLabel:setAnchorPoint(0, 0.5)
    tmpLabel:setPosition(cc.p(data.pos))
    data.parent:addChild(tmpLabel)
  end
  inFunc2({
    parent = tmpNode,
    pos = cc.p(x_start, y_attribute1),
    fromValue = heroInfo.attack,
    toValue = nextInfo.attack,
    icon = "UI/icon/atk_icon.png",
    txt = g_LM:getMode("prop", td.Property.Atk)
  })
  y_attribute1 = y_attribute1 - y_offset
  inFunc2({
    parent = tmpNode,
    pos = cc.p(x_start, y_attribute1),
    fromValue = heroInfo.hp,
    toValue = nextInfo.hp,
    icon = "UI/icon/hp_icon.png",
    txt = g_LM:getBy("a00035")
  })
  y_attribute1 = y_attribute1 - y_offset
  inFunc2({
    parent = tmpNode,
    pos = cc.p(x_start, y_attribute1),
    fromValue = heroInfo.def,
    toValue = nextInfo.def,
    icon = "UI/icon/def_icon.png",
    txt = g_LM:getBy("a00065")
  })
  y_attribute1 = y_attribute1 - y_offset
  inFunc2({
    parent = tmpNode,
    pos = cc.p(x_start, y_attribute1),
    fromValue = math.floor(60 / heroInfo.attack_speed),
    toValue = math.floor(60 / nextInfo.attack_speed),
    icon = "UI/icon/asp_icon.png",
    txt = g_LM:getBy("a00066")
  })
  y_attribute1 = y_attribute1 - y_offset
  inFunc2({
    parent = tmpNode,
    pos = cc.p(x_start, y_attribute1),
    fromValue = heroInfo.move_speed,
    toValue = nextInfo.move_speed,
    icon = "UI/icon/sp_icon.png",
    txt = g_LM:getBy("a00067")
  })
  tmpNode = cc.uiloader:seekNodeByName(self.m_uiBg, "Image_detail_bg")
  local y_attribute2 = tmpNode:getContentSize().height - 190
  local y_offset2 = 30
  local x_start2 = 260
  local inFunc3 = function(data)
    local fromValueStr = data.fromValue .. ""
    while string.len(fromValueStr) < 2 do
      fromValueStr = " " .. fromValueStr
    end
    local tmpLabel = td.RichText({
      {
        type = 1,
        color = td.LIGHT_GREEN,
        size = 16,
        str = data.txt
      },
      {
        type = 1,
        color = td.YELLOW,
        size = 16,
        str = "" .. fromValueStr .. "%"
      },
      {
        type = 2,
        file = "UI/hero/jiantou_icon.png",
        scale = 1
      },
      {
        type = 1,
        color = td.YELLOW,
        size = 16,
        str = "" .. data.toValue .. "%"
      }
    })
    tmpLabel:setAnchorPoint(0, 0.5)
    tmpLabel:setPosition(cc.p(data.pos))
    data.parent:addChild(tmpLabel)
  end
  inFunc3({
    parent = tmpNode,
    pos = cc.p(x_start2, y_attribute2),
    fromValue = heroInfo.crit_rate,
    toValue = nextInfo.crit_rate,
    txt = g_LM:getBy("a00068")
  })
  y_attribute2 = y_attribute2 - y_offset2
  inFunc3({
    parent = tmpNode,
    pos = cc.p(x_start2, y_attribute2),
    fromValue = heroInfo.dodge_rate,
    toValue = nextInfo.dodge_rate,
    txt = g_LM:getBy("a00069")
  })
  y_attribute2 = y_attribute2 - y_offset2
  tmpNode = self.m_uiBg
  local useYuanli = heroInfo.exp
  local haveYuanli = UserDataManager:GetInstance():GetExp()
  local tmpLabel = td.RichText({
    {
      type = 1,
      color = td.LIGHT_BLUE,
      size = 16,
      str = g_LM:getBy("a00075")
    },
    {
      type = 2,
      file = td.FORCE_ICON,
      scale = 0.5
    },
    {
      type = 1,
      color = td.GREEN,
      size = 16,
      str = "" .. useYuanli .. ","
    },
    {
      type = 1,
      color = td.LIGHT_BLUE,
      size = 16,
      str = g_LM:getBy("a00076")
    },
    {
      type = 2,
      file = td.FORCE_ICON,
      scale = 0.5
    },
    {
      type = 1,
      color = td.GREEN,
      size = 16,
      str = "" .. haveYuanli .. ","
    },
    {
      type = 1,
      color = td.LIGHT_BLUE,
      size = 16,
      str = g_LM:getBy("a00077")
    }
  })
  inFunc1({
    node = tmpLabel,
    parent = tmpNode,
    ancPos = cc.p(0, 1),
    pos = cc.p(50, 100)
  })
  local btnGet = cc.uiloader:seekNodeByName(self.m_uiBg, "Button_get_2")
  local btnTxtStr = g_LM:getBy("a00009")
  td.BtnSetTitle(btnGet, btnTxtStr)
  td.BtnAddTouch(btnGet, function()
    self:OnUpgradeBtnClicked()
  end)
end
function HeroUpgradeDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_uiBg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_uiBg, tmpPos) then
      scheduler.performWithDelayGlobal(function(times)
        self:close()
      end, 0.016666666666666666)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
function HeroUpgradeDlg:OnUpgradeBtnClicked()
  local bEnable, errorCode = StrongInfoManager:GetInstance():IsEnableHeroStrong(self.m_heroData.id)
  if bEnable then
    local data = {}
    data.id = self.m_heroData.id
    StrongInfoManager:GetInstance():SendUpgradeHeroRequest(data)
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    self:close()
  elseif errorCode == td.ErrorCode.BASE_LEVEL_LOW then
    td.alertDebug("\232\175\183\230\143\144\229\141\135\229\164\167\230\156\172\232\144\165\231\173\137\231\186\167")
  elseif errorCode == td.ErrorCode.EXP_NOT_ENOUGH then
    td.alertDebug("\229\142\159\229\138\155\228\184\141\232\182\179")
  end
end
return HeroUpgradeDlg
