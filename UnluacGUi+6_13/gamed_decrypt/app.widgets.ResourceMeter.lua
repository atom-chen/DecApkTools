local GameDataManager = require("app.GameDataManager")
local ResourceMeter = class("ResourceMeter", function()
  return display.newNode()
end)
function ResourceMeter:ctor()
  self.m_resIcons = {}
  self.m_resBars = {}
  self.m_resLabel = {}
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function ResourceMeter:InitUI()
  local vNeedRes = {}
  local resTypes = {
    td.ResourceType.ShiYou,
    td.ResourceType.ShuiJing,
    td.ResourceType.DanYao,
    td.ResourceType.Gold,
    td.ResourceType.Exp,
    td.ResourceType.EnergyBall_l,
    td.ResourceType.EnergyBall_m,
    td.ResourceType.EnergyBall_s,
    td.ResourceType.Medal_l,
    td.ResourceType.Medal_m,
    td.ResourceType.Medal_s,
    td.ResourceType.StarStone_l,
    td.ResourceType.StarStone_m,
    td.ResourceType.StarStone_s
  }
  for i, v in ipairs(resTypes) do
    local iMaxNeed = GameDataManager:GetInstance():GetMaxNeedCount(v)
    if iMaxNeed and iMaxNeed > 0 then
      table.insert(vNeedRes, {v, iMaxNeed})
    end
  end
  local uiRoot = cc.uiloader:load("CCS/ResMeter.csb")
  uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(uiRoot)
  self:addChild(uiRoot, 1)
  local resBg = cc.uiloader:seekNodeByName(uiRoot, "ResBg")
  for i, v in ipairs(vNeedRes) do
    local resBg = cc.uiloader:seekNodeByName(uiRoot, "Res" .. i)
    resBg:setVisible(true)
    local icon = resBg:getChildByTag(2)
    icon:setVisible(false)
    local iconSpr = display.newSprite("#UI/battle/ziyuan_" .. tostring(v[1]) .. td.PNG_Suffix)
    iconSpr:pos(icon:getPosition()):addTo(icon:getParent())
    self.m_resIcons[v[1]] = iconSpr
    td.CreateUIEffect(iconSpr, "Spine/UI_effect/UI_kezhitishi_01", {random = true})
    local timerSpr
    if v[1] > 10 then
      timerSpr = display.newSprite("#UI/battle/ziyuantiao9" .. td.PNG_Suffix)
    else
      timerSpr = display.newSprite("#UI/battle/ziyuantiao" .. tostring(v[1]) .. td.PNG_Suffix)
    end
    local bar = cc.ProgressTimer:create(timerSpr)
    bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    bar:setMidpoint(cc.p(1, 0))
    bar:setBarChangeRate(cc.p(1, 0))
    bar:setPercentage(0)
    bar:setScale(1.2)
    bar:addTo(resBg:getChildByTag(1))
    self.m_resBars[v[1]] = bar
    local label = td.CreateLabel("0/" .. v[2], td.LIGHT_BLUE, 12)
    label:setAnchorPoint(0.5, 0.5)
    label:pos(bar:getContentSize().width / 2, bar:getContentSize().height / 2):addTo(bar)
    self.m_resLabel[v[1]] = label
  end
end
function ResourceMeter:onEnter()
  local updateNeedResListener = cc.EventListenerCustom:create(td.UPDATE_NEED_RES, function(_event)
    local data = string.toTable(_event:getDataString())
    if not data.type then
      return
    end
    local iCurNeed = GameDataManager:GetInstance():GetCurNeedCount(data.type)
    local iMaxNeed = GameDataManager:GetInstance():GetMaxNeedCount(data.type)
    if iCurNeed >= iMaxNeed then
      iCurNeed = iMaxNeed
    end
    self.m_resIcons[data.type]:runAction(cca.seq({
      cca.scaleTo(0.1, 1.6),
      cca.scaleTo(0.15, 0.9),
      cca.scaleTo(0.07, 1)
    }))
    self.m_resBars[data.type]:setPercentage(iCurNeed / iMaxNeed * 100)
    self.m_resLabel[data.type]:setString("" .. iCurNeed .. "/" .. iMaxNeed)
  end)
  self:getEventDispatcher():addEventListenerWithFixedPriority(updateNeedResListener, 1)
end
function ResourceMeter:onExit()
  self:getEventDispatcher():removeCustomEventListeners(td.UPDATE_NEED_RES)
end
return ResourceMeter
