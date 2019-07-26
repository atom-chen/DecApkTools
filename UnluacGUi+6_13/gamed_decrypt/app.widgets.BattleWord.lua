local GameDataManager = require("app.GameDataManager")
local BattleWord = class("BattleWord", function(word)
  if type(word) == "number" then
    local w = cc.LabelBMFont:create("+" .. word, td.UI_shuzi_yellow)
    w:setScale(1.5)
    return w
  elseif word == "miss" then
    return display.newSprite("UI/skill_words/wenzi_shanbi.png")
  elseif word == "crit" then
    return display.newSprite("UI/skill_words/wenzi_baoji.png")
  elseif word == "block" then
    return display.newSprite("UI/skill_words/wenzi_gedang.png")
  elseif word == "ref" then
    return display.newSprite("UI/skill_words/wenzi_fanshe.png")
  else
    return display.newSprite(word .. td.PNG_Suffix)
  end
end)
function BattleWord:ctor(word)
  self:setNodeEventEnabled(true)
end
function BattleWord:onEnter()
  self:setRotation(math.random(40) - 20)
  self:runAction(cca.seq({
    cca.scaleBy(0.1, 1.2),
    cca.scaleBy(0.05, 0.8),
    cca.delay(0.3),
    cca.removeSelf()
  }))
end
function BattleWord:onExit()
end
function BattleWord:AddToActor(pActor)
  local pos
  local size = pActor:GetContentSize()
  local offsetX = math.floor(size.width * pActor:getScaleX())
  local offsetY = size.height * pActor:getScaleY()
  if pActor:GetType() == td.ActorType.Home then
    offsetX = offsetX ~= 0 and math.random(offsetX) or 0
    offsetY = offsetY * 0.7
  else
    offsetX = offsetX ~= 0 and math.random(offsetX) - size.width / 2 * pActor:getScaleX() or 0
  end
  self:setPosition(cc.pAdd(cc.p(offsetX, offsetY), cc.p(pActor:getPosition())))
  self:addTo(pActor:getParent(), td.InMapZOrder.UI)
end
return BattleWord
