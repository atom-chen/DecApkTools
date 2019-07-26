local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local CommonInfoManager = require("app.info.CommonInfoManager")
local VIPDlg = class("VIPDlg", BaseDlg)
function VIPDlg:ctor(data)
  VIPDlg.super.ctor(self, 200)
  self.m_uiId = td.UIModule.VIP
  self.m_chargeDiamond = UserDataManager:GetInstance():GetVIPData().diamond
  self.m_level = data.level
  self:InitUI()
end
function VIPDlg:onEnter()
  VIPDlg.super.onEnter(self)
  self:AddEvents()
end
function VIPDlg:onExit()
  VIPDlg.super.onExit(self)
end
function VIPDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/VIPDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.pBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_charge")
  td.BtnSetTitle(self.pBtn, g_LM:getBy("a00227"))
  td.BtnAddTouch(self.pBtn, function()
  end)
  self.labelLevel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_vip")
  self.labelPro = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_progress")
  self.sprPro = cc.uiloader:seekNodeByName(self.m_uiRoot, "spr_progress")
  local label = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_31_1")
  label:setString(g_LM:getBy("a00375"))
  self:RefreshUI()
end
function VIPDlg:RefreshUI()
  local info = CommonInfoManager:GetInstance():GetVipInfo(self.m_level)
  self.labelLevel:setString("VIP " .. self.m_level)
  self.labelPro:setString(string.format("%d/%d", self.m_chargeDiamond, info.diamond_demand))
  self.sprPro:setScaleX(cc.clampf(self.m_chargeDiamond / info.diamond_demand, 0, 1))
  if self.m_chargeDiamond < info.diamond_demand then
    local label = td.RichText({
      {
        type = 1,
        str = "\229\134\141\229\133\133\229\128\188",
        color = td.WHITE,
        size = 18
      },
      {
        type = 2,
        file = td.DIAMOND_ICON,
        scale = 0.6
      },
      {
        type = 1,
        str = "x" .. info.diamond_demand - self.m_chargeDiamond .. "\229\141\179\229\143\175\230\136\144\228\184\186",
        color = td.WHITE,
        size = 18
      },
      {
        type = 1,
        str = "VIP " .. self.m_level,
        color = td.YELLOW,
        size = 18
      }
    }, cc.size(190, 70))
    label:align(display.LEFT_TOP, 435, 415):addTo(self.m_bg)
  end
  local scrollView = cc.uiloader:seekNodeByName(self.m_uiRoot, "ScrollView")
  local itemInfo = td.GetItemInfo(info.sweep.itemId)
  local vDesc = {
    {
      "\230\175\143\229\164\169\229\143\175\232\180\173\228\185\176",
      info.vit_numbers,
      "\230\172\161\228\189\147\229\138\155"
    },
    {
      "\230\175\143\229\164\169\229\143\175\232\180\173\228\185\176",
      info.gold_numbers,
      "\230\172\161\233\135\145\229\184\129"
    },
    {
      "\230\175\143\229\164\169\229\143\175\233\162\134\229\143\150" .. itemInfo.name,
      "x" .. info.sweep.num,
      ""
    },
    {
      "\230\175\143\229\164\169\229\143\175\230\140\145\230\136\152\229\137\175\230\156\172",
      info.dungeon,
      "\230\172\161"
    },
    {
      "\230\175\143\229\164\169\229\143\175\232\180\173\228\185\176\229\137\175\230\156\172\233\162\157\229\164\150\230\172\161\230\149\176",
      info.dungeon_numbers,
      "\230\172\161"
    },
    {
      "\233\135\145\229\184\129\229\146\140\229\142\159\229\138\155\230\148\182\233\155\134\233\128\159\229\186\166\229\162\158\229\138\160",
      "" .. info.gold_speed .. "%",
      ""
    },
    {
      "\230\175\143\229\164\169\229\143\175\229\133\141\232\180\185\229\136\183\230\150\176",
      info.store_refresh,
      "\230\172\161\229\149\134\229\186\151"
    },
    {
      "\230\175\143\229\164\169\229\143\175\232\180\173\228\185\176",
      info.mission_purchase,
      "\230\172\161\229\133\179\229\141\161\230\140\145\230\136\152\230\172\161\230\149\176"
    },
    {
      "\230\175\143\230\156\136\229\143\175\232\161\165\231\173\190\229\136\176",
      info.sign_in,
      "\230\172\161"
    }
  }
  if info.batch_sweep == 1 then
    table.insert(vDesc, {
      "\232\167\163\233\148\129\229\141\129\232\191\158\230\137\171\232\141\161",
      "",
      ""
    })
  end
  local height = 0
  local vDescLabel = {}
  for i, desc in ipairs(vDesc) do
    local descLabel = td.RichText({
      {
        type = 1,
        str = desc[1],
        color = td.BLUE,
        size = 20
      },
      {
        type = 1,
        str = tostring(desc[2]),
        color = td.WHITE,
        size = 20
      },
      {
        type = 1,
        str = desc[3],
        color = td.BLUE,
        size = 20
      }
    })
    descLabel:setAnchorPoint(0, 1)
    height = height + descLabel:getContentSize().height + 5
    table.insert(vDescLabel, descLabel)
  end
  height = math.max(200, height)
  local y = height
  for i, var in ipairs(vDescLabel) do
    var:pos(0, y):addTo(scrollView)
    y = y - var:getContentSize().height - 5
  end
  scrollView:setInnerContainerSize(cc.size(440, height))
end
function VIPDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function()
        self:close()
      end, 0.1)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
return VIPDlg
