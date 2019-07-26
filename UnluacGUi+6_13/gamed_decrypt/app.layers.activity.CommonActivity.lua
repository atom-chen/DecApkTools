local UserDataManager = require("app.UserDataManager")
local ActivityDataManager = require("app.ActivityDataManager")
local scheduler = require("framework.scheduler")
local TouchIcon = require("app.widgets.TouchIcon")
local CommonActivity = class("CommonActivity", function()
  return display.newNode()
end)
function CommonActivity:ctor(data)
  self.m_data = data
  self.m_udMng = UserDataManager:GetInstance()
  self.m_adMng = ActivityDataManager:GetInstance()
  if self.m_data.to then
    local serverTime = self.m_udMng:GetServerTime()
    self.m_countDown = self.m_data.to - serverTime
  end
  self:setNodeEventEnabled(true)
end
function CommonActivity:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/activities/CommonActivity.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local fromStr = os.date("%Y/%m/%d %H:%M:%S", self.m_data.from)
  local toStr = os.date("%Y/%m/%d %H:%M:%S", self.m_data.to)
  local timeLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_time")
  timeLabel:setString(fromStr .. " - " .. toStr)
  local descLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_desc")
  descLabel:setString(self.m_data.desc)
  local countDownStr = self:GetTimeDownStr(self.m_countDown)
  self.m_countDownLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_title")
  self.m_countDownLabel:setString(countDownStr)
end
function CommonActivity:onEnter()
  self.m_timeScheduler = scheduler.scheduleGlobal(function()
    self:OnTimer()
  end, 1)
end
function CommonActivity:onExit()
  if self.m_timeScheduler then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
    self.m_timeScheduler = nil
  end
end
function CommonActivity:OnTimer()
  self.m_countDown = cc.clampf(self.m_countDown - 1, 0, 99999999)
  local countDownStr = self:GetTimeDownStr(self.m_countDown)
  self.m_countDownLabel:setString(countDownStr)
  if self.m_countDown <= 0 then
    scheduler.unscheduleGlobal(self.m_timeScheduler)
    self.m_timeScheduler = nil
  end
end
function CommonActivity:GetTimeDownStr(time)
  local str = "\232\183\157\231\166\187\230\180\187\229\138\168\231\187\147\230\157\159"
  local day = math.floor(time / 86400)
  local hour, min, sec = math.floor(time % 86400 / 3600), math.floor(time % 3600 / 60), math.floor(time % 60)
  str = str .. string.format(" %d\229\164\169 %02d:%02d:%02d", day, hour, min, sec)
  return str
end
function CommonActivity:CreateItem(info)
  local itemNode = display.newNode()
  local item = self.m_UIListView:newItem(itemNode)
  local autoScale = td.GetAutoScale()
  local bgSize = cc.size(580, 85)
  local itembg = display.newScale9Sprite("UI/scale9/jianglidikuang.png", 0, 0, bgSize, cc.rect(11, 26, 5, 25))
  itembg:setAnchorPoint(cc.p(0, 0))
  itembg:setName("bg")
  itemNode:setScale(autoScale)
  itemNode:setContentSize(bgSize)
  itembg:addTo(itemNode)
  for i, var in ipairs(info.award) do
    local iconSpr = TouchIcon.new(var.itemId, true, false)
    iconSpr:scale(0.45)
    td.AddRelaPos(itembg, iconSpr, 1, cc.p(0.08 + (i - 1) * 0.08, 0.35))
    local numLabel = td.CreateLabel("x" .. var.num, td.WHITE, 12)
    numLabel:setAnchorPoint(0, 0.5)
    td.AddRelaPos(itembg, numLabel, 1, cc.p(0.05 + (i - 1) * 0.08, 0.5))
  end
  local condLabel = self:GetConditionLabel(info)
  condLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itembg, condLabel, 1, cc.p(0.04, 0.8))
  item.condLabel = condLabel
  self:AddProgressBar(itembg, info)
  if info.result == 1 then
    local spr = display.newSprite("UI/words/yilingqu_icon.png")
    td.AddRelaPos(itembg, spr, 1, cc.p(0.85, 0.5))
  else
    do
      local btn = td.CreateBtn(td.BtnType.GreenShort)
      td.BtnAddTouch(btn, function()
        self.m_adMng:GetActivityAwardRequest(self.m_data.id, info.id)
        td.AfterReceive(btn)
      end, nil, td.ButtonEffectType.Short)
      td.AddRelaPos(itembg, btn, 1, cc.p(0.85, 0.5))
      btn:setDisable(not self:CheckCondition(info, self.m_data.from, self.m_data.to))
      item.btn = btn
      td.BtnSetTitle(btn, g_LM:getBy("a00052"))
    end
  end
  item:setItemSize((bgSize.width + 5) * autoScale, (bgSize.height + 3) * autoScale)
  return item
end
function CommonActivity:CheckCondition(info, startTime, endTime)
  return self.m_adMng:CheckCondition(info.condition, startTime, endTime)
end
function CommonActivity:GetConditionLabel(info)
  local condition = info.condition
  local str1, str2, value = "", "", condition.value
  if condition.id == td.ActConditionType.Base then
    str1, str2 = "\229\164\167\230\156\172\232\144\165\231\173\137\231\186\167\232\190\190\229\136\176", "\231\186\167"
  elseif condition.id == td.ActConditionType.Mission then
    str1 = "\233\128\154\229\133\179"
    local missionInfo = require("app.info.MissionInfoManager"):GetInstance():GetMissionInfo(value)
    value = missionInfo.name .. "(" .. (missionInfo.mode == 2 and "\229\155\176\233\154\190" or "\230\153\174\233\128\154") .. ")"
  elseif condition.id == td.ActConditionType.Arena then
    str1, str2 = "\231\171\158\230\138\128\229\156\186\230\142\146\229\144\141\232\190\190\229\136\176", "\229\144\141"
  elseif condition.id == td.ActConditionType.Charge then
    str1, str2 = "\231\180\175\232\174\161\229\133\133\229\128\188", "\229\133\131"
    value = value * 0.1
  elseif condition.id == td.ActConditionType.Consume then
    str1, str2 = "\231\180\175\232\174\161\230\182\136\232\180\185", "\233\146\187\231\159\179"
  end
  local label = td.RichText({
    {
      type = 1,
      str = str1,
      color = td.GREEN,
      size = 16
    },
    {
      type = 1,
      str = tostring(value),
      color = td.WHITE,
      size = 16
    },
    {
      type = 1,
      str = str2,
      color = td.GREEN,
      size = 16
    }
  })
  return label
end
function CommonActivity:AddProgressBar(itemBg, info)
  local condition = info.condition
  if condition.id ~= td.ActConditionType.Charge and condition.id ~= td.ActConditionType.Consume then
    return
  end
  local total, cur = condition.value, 0
  if condition.id == td.ActConditionType.Charge then
    cur = self.m_udMng:GetUserLog(1, self.m_data.from, self.m_data.to)
    total = total * 0.1
    cur = cur * 0.1
  elseif condition.id == td.ActConditionType.Consume then
    cur = self.m_udMng:GetUserLog(td.ItemID_Diamond, self.m_data.from, self.m_data.to)
  end
  local proBg = display.newScale9Sprite("UI/scale9/jindutiao_aocao.png", 0, 0, cc.size(158, 17))
  td.AddRelaPos(itemBg, proBg, 1, cc.p(0.6, 0.5))
  local proSpr = display.newSprite("UI/common/huangse_jindutiao.png")
  proSpr:setScaleX(cc.clampf(cur / total, 0, 1) * 0.7)
  proSpr:setAnchorPoint(0, 0.5)
  td.AddRelaPos(proBg, proSpr, 1, cc.p(0.03, 0.5))
  local label = td.CreateLabel(cur .. "/" .. total, td.WHITE, 16, td.OL_BLACK)
  td.AddRelaPos(proBg, label, 2)
end
return CommonActivity
