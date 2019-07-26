td = td or {}
td.WIN_COLOR = cc.c4b(0, 0, 0, 200)
td.BTN_PRESSED_COLOR = cc.c3b(120, 120, 120)
td.GREEN = cc.c3b(160, 254, 49)
td.LIGHT_GREEN = cc.c3b(120, 244, 191)
td.BLUE = cc.c3b(7, 179, 236)
td.LIGHT_BLUE = cc.c3b(102, 238, 255)
td.DARK_BLUE = cc.c3b(7, 168, 197)
td.RED = cc.c3b(254, 41, 29)
td.YELLOW = cc.c3b(255, 241, 83)
td.WHITE = cc.c3b(255, 255, 255)
td.GRAY = cc.c3b(170, 170, 170)
td.OL_BLACK = cc.c4b(13, 39, 54, 255)
td.OL_BROWN = cc.c4b(67, 43, 15, 255)
td.OL_BLUE = cc.c4b(102, 238, 255, 255)
td.DEFAULT_FONT = "Fonts/FZPW.ttf"
td.Word_Path = "UI/words/"
td.UI_shiyou = "Spine/skill/UI_shiyou_01"
td.UI_shuijing = "Spine/skill/UI_shuijing_01"
td.UI_danyao = "Spine/skill/UI_danyao_01"
td.UI_ziyuan = "Spine/skill/UI_ziyuan_01"
td.UI_jinbi = "Spine/skill/UI_jinbi_01"
td.UI_nengliang = "Spine/skill/UI_jingyan_01"
td.UI_energy1 = "Spine/UI_effect/UI_nengliang_01"
td.UI_energy2 = "Spine/UI_effect/UI_nengliang_02"
td.UI_energy3 = "Spine/UI_effect/UI_nengliang_03"
td.UI_medal1 = "Spine/UI_effect/UI_xunzhang_01"
td.UI_medal2 = "Spine/UI_effect/UI_xunzhang_02"
td.UI_medal3 = "Spine/UI_effect/UI_xunzhang_03"
td.UI_star1 = "Spine/UI_effect/UI_xingshi_01"
td.UI_star2 = "Spine/UI_effect/UI_xingshi_02"
td.UI_star3 = "Spine/UI_effect/UI_xingshi_03"
td.UI_PATH_SIGN = "UI/common/guangban.png"
td.UI_shuzi_yellow = "Fonts/shuzi_yellow.fnt"
td.UI_yellow_outline = "Fonts/Yellow_outlight.fnt"
td.PNG_Suffix = ".png"
td.HOME_FILE = "Spine/bingying/dabenying_0"
td.HOME_SHIP_FILE = "Spine/bingying/feichuan_0"
td.ENEMY_HOME_FILE = "Spine/bingying/difangdabenying_0"
td.ENEMY_DEPUTY_HOME_FILE = "Spine/bingying/difangfujidi_0"
td.HOME_CAMP_DEF_FILE = "Spine/bingying/jianzao"
td.HOME_CAMP_LOCK_FILE = "Spine/bingying/suoding"
td.GOLD_ICON = "UI/icon/jinbi_icon.png"
td.EXP_ICON = "UI/icon/nengliang_icon.png"
td.DIAMOND_ICON = "UI/icon/zuanshi_icon.png"
td.FORCE_ICON = "UI/icon/yuanli.png"
td.NOT_FOUND_ICON = "UI/icon/item/00000.png"
td.CAREER_ICON = {
  [td.CareerType.Non] = "UI/scale9/transparent1x1.png",
  [td.CareerType.Saber] = "UI/icon/career2_1.png",
  [td.CareerType.Archer] = "UI/icon/career2_2.png",
  [td.CareerType.Caster] = "UI/icon/career2_3.png",
  [td.CareerType.Fly] = "UI/icon/career2_4.png"
}
td.RATING_ICON = {
  [td.Rating.B] = "UI/icon/rate/1.png",
  [td.Rating.A] = "UI/icon/rate/2.png",
  [td.Rating.APlus] = "UI/icon/rate/3.png",
  [td.Rating.S] = "UI/icon/rate/4.png",
  [td.Rating.SPlus] = "UI/icon/rate/5.png",
  [td.Rating.SS] = "UI/icon/rate/6.png"
}
td.UIPosVertical = {
  Top = 0,
  Bottom = 1,
  Center = 2
}
td.UIPosHorizontal = {
  Left = 0,
  Right = 1,
  Center = 2
}
td.BtnType = {
  YellowShort = 1,
  YellowLong = 2,
  GreenShort = 3,
  GreenLong = 4,
  BlueShort = 5,
  BlueLong = 6
}
td.BtnGS = {
  enabled = "UI/button/lvse1_duan_button.png",
  pressed = "UI/button/lvse2_duan_button.png",
  disabled = "UI/button/huise_duan_button.png"
}
td.BtnGL = {
  enabled = "UI/button/lvse1_chang_button.png",
  pressed = "UI/button/lvse2_chang_button.png",
  disabled = "UI/button/huise_chang_button.png"
}
td.BtnBS = {
  enabled = "UI/button/lanse1_duan_button.png",
  pressed = "UI/button/lanse2_duan_button.png",
  disabled = "UI/button/huise_duan_button.png"
}
td.BtnBL = {
  enabled = "UI/button/lanse1_chang_button.png",
  pressed = "UI/button/lanse2_chang_button.png",
  disabled = "UI/button/huise_chang_button.png"
}
td.BtnYS = {
  enabled = "UI/button/huangse1_duan_button.png",
  pressed = "UI/button/huangse2_duan_button.png",
  disabled = "UI/button/huise_duan_button.png"
}
td.BtnYL = {
  enabled = "UI/button/huangse1_chang_button.png",
  pressed = "UI/button/huangse2_chang_button.png",
  disabled = "UI/button/huise_chang_button.png"
}
td.ButtonEffectType = {
  Long = 1,
  Short = 2,
  StartGame = 3
}
function td.CreateLabel(str, fColor, fSize, olColor, olSize, dimen, bAdjustSize)
  fColor = fColor or cc.c3b(255, 255, 255)
  fSize = fSize or 20
  if g_LM.Language ~= cc.LANGUAGE_CHINESE and bAdjustSize then
    fSize = fSize * 0.8
  end
  local textLabel = display.newTTFLabel({
    text = str,
    font = td.DEFAULT_FONT,
    size = fSize,
    color = fColor,
    dimensions = dimen
  })
  if olColor then
    olSize = olSize or 1
    textLabel:enableOutline(olColor, olSize)
  end
  return textLabel
end
function td.CreateLabel2(data)
  data.color = data.color or cc.c3b(255, 255, 255)
  data.size = data.size or 20
  local textLabel = display.newTTFLabel({
    text = data.str,
    font = td.DEFAULT_FONT,
    size = data.size,
    color = data.color,
    dimensions = data.dimen,
    align = data.align,
    valign = data.valign
  })
  if data.olColor then
    data.olSize = data.olSize or 1
    textLabel:enableOutline(data.olColor, data.olSize)
  end
  return textLabel
end
function td.CreateBMF(str, bmfont, scale, bAdjustSize)
  scale = scale or 1
  if g_LM.Language ~= cc.LANGUAGE_CHINESE and bAdjustSize then
    scale = scale * 0.8
  end
  local textLabel = cc.LabelBMFont:create(str, bmfont)
  textLabel:setScale(scale)
  return textLabel
end
function td.RichText(datas, _size)
  local richText = ccui.RichText:create()
  if _size then
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(_size)
  end
  for i, data in ipairs(datas) do
    local richNode
    if data.type == 1 then
      if data.bAjust and g_LM.Language ~= cc.LANGUAGE_CHINESE then
        data.size = data.size * 0.8
      end
      richNode = ccui.RichElementText:create(i, data.color, 255, data.str, td.DEFAULT_FONT, data.size)
    elseif data.type == 2 then
      local spr = display.newSprite(data.file)
      spr:setScale(data.scale or 1)
      richNode = ccui.RichElementCustomNode:create(i, td.WHITE, 255, spr)
    elseif data.type == 3 then
      local color = data.color or td.WHITE
      richNode = ccui.RichElementCustomNode:create(i, color, 255, data.node)
    else
      richNode = ccui.RichElementNewLine:create(i, td.WHITE, 255)
    end
    richText:pushBackElement(richNode)
  end
  richText:formatText()
  return richText
end
function td.CreateBtn(btnType)
  local btnMap = td.BtnGS
  if btnType == td.BtnType.GreenLong then
    btnMap = td.BtnGL
  elseif btnType == td.BtnType.BlueShort then
    btnMap = td.BtnBS
  elseif btnType == td.BtnType.BlueLong then
    btnMap = td.BtnBL
  elseif btnType == td.BtnType.YellowShort then
    btnMap = td.BtnYS
  elseif btnType == td.BtnType.YellowLong then
    btnMap = td.BtnYL
  end
  return ccui.Button:create(btnMap.enabled, btnMap.pressed, btnMap.disabled)
end
function td.popView(dialog, useAnim)
  if not dialog then
    return
  end
  local pRunScene = display.getRunningScene()
  pRunScene:addChild(dialog, td.ZORDER.Min)
  Util_changeAnchor(dialog, cc.p(0.5, 0.5))
  if useAnim then
    dialog:enterAnim()
  end
end
function td.alert(message, bIsWarning)
  if not g_MC:GetShowAlert() or not message then
    return
  end
  local pLabel = display.newTTFLabel({
    text = message,
    font = td.DEFAULT_FONT,
    size = 22,
    color = cc.c3b(162, 255, 116),
    align = cc.TEXT_ALIGNMENT_CENTER,
    valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
  })
  local autoScale = td.GetAutoScale()
  local bgSize = pLabel:getContentSize()
  bgSize = cc.size(bgSize.width + 30, bgSize.height + 30)
  local pBgSpri
  if bIsWarning then
    pBgSpri = display.newScale9Sprite("UI/scale9/hongse_tishikuang.png", 0, 0, bgSize)
    pLabel:setColor(cc.c3b(255, 43, 43))
  else
    pBgSpri = display.newScale9Sprite("UI/scale9/lvse_tishikuang.png", 0, 0, bgSize)
  end
  pBgSpri:setScale(autoScale)
  local duration = 1.5
  local startTag = td.ZORDER.Info
  local pRunScene = display.getRunningScene()
  local pNode = pRunScene:getChildByTag(startTag)
  local i = 1
  local targetTag = 0
  while pNode or i < 10 do
    if pNode then
      transition.moveBy(pNode, {
        x = 0,
        y = bgSize.height * autoScale,
        time = 0.1
      })
    elseif targetTag == 0 then
      targetTag = startTag
    end
    startTag = startTag + 1
    pNode = pRunScene:getChildByTag(startTag)
    i = i + 1
  end
  pBgSpri:addChild(pLabel)
  pLabel:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
  pRunScene:addChild(pBgSpri, targetTag, targetTag)
  pBgSpri:setPosition(display.width * 0.5, display.height * 0.7)
  local function callback()
    pBgSpri:removeFromParent()
  end
  local bgAction = transition.sequence({
    cc.FadeIn:create(0.2),
    cc.EaseIn:create(cc.MoveBy:create(duration, cc.p(0, bgSize.height * 0.5 * autoScale)), 0.5),
    cc.FadeOut:create(0.2),
    cc.CallFunc:create(callback)
  })
  pBgSpri:runAction(bgAction)
  local labelAction = transition.sequence({
    cc.DelayTime:create(duration + 0.2),
    cc.FadeOut:create(0.2)
  })
  pLabel:runAction(labelAction)
end
function td.alertDebug(msg)
  if td.Debug_Tag then
    td.alert(msg)
  end
  pu.logDebug(msg)
end
function td.IsVisible(node)
  local tmpNode = node
  if nil == tmpNode:getParent() then
    return false
  end
  while tmpNode do
    if not tmpNode:isVisible() then
      return false
    end
    tmpNode = tmpNode:getParent()
  end
  return true
end
function td.setTexture(spri, fileName)
  if not spri then
    return
  end
  local texture = cc.Director:getInstance():getTextureCache():addImage(fileName)
  if texture ~= nil then
    spri:setTexture(texture)
  end
end
function td.calcOffsetByAnchor(pNode, newAnchorPt)
  local ret = cc.p(0, 0)
  if pNode then
    local pos = cc.p(pNode:getPosition())
    local anchor = cc.p(pNode:getAnchorPoint())
    local anchorInPt = cc.p(pNode:getAnchorPointInPoints())
    local posNew = cc.pSub(pos, anchorInPt)
    local szContentsize = pNode:getContentSize()
    posNew.x = posNew.x + szContentsize.width * newAnchorPt.x
    posNew.y = posNew.y + szContentsize.height * newAnchorPt.y
    ret = posNew
  end
  return ret
end
function td.adjustPosByAnchor(pNode, newAnchorPt)
  local newPos = td.calcOffsetByAnchor(pNode, newAnchorPt)
  pNode:setAnchorPoint(newAnchorPt)
  pNode:setPosition(newPos)
end
function td.alertErrorMsg(errorCode)
  if errorCode == td.ErrorCode.DIAMOND_NOT_ENOUGH then
    td.ShowAskToupDlg()
  else
    local pString = g_LM:getMode("errormsg", errorCode)
    pString = pString or errorCode
    td.alert(pString, true)
  end
end
function td.GetPortrait(id)
  local CommanderInfoManager = require("app.info.CommanderInfoManager")
  local portraitInfo = CommanderInfoManager:GetInstance():GetPortraitInfo(id)
  portraitInfo = portraitInfo or CommanderInfoManager:GetInstance():GetPortraitInfo(1)
  return portraitInfo.file .. td.PNG_Suffix
end
function td.GetVIPIcon(vipLevel)
  vipLevel = vipLevel and cc.clampf(vipLevel, 0, 10) or 0
  return "UI/icon/vip/" .. vipLevel .. ".png"
end
function td.GetItemIcon(id)
  local ItemInfoManager = require("app.info.ItemInfoManager")
  local item = ItemInfoManager:GetInstance():GetItemInfo(tonumber(id))
  if not item then
    return nil
  end
  return item.icon .. td.PNG_Suffix
end
function td.CreateItemIcon(id, bStar, posY)
  local ItemInfoManager = require("app.info.ItemInfoManager")
  local itemInfo = ItemInfoManager:GetInstance():GetItemInfo(tonumber(id))
  if not itemInfo then
    local StrongInfoManager = require("app.info.StrongInfoManager")
    itemInfo = StrongInfoManager:GetInstance():GetGemInfo(tonumber(id))
    if not itemInfo then
      return td.CreateWeaponIcon(id, 1, posY)
    end
  end
  if bStar then
    return td.IconWithStar(itemInfo.icon .. td.PNG_Suffix, itemInfo.quality, itemInfo.quality, posY)
  end
  return display.newSprite(itemInfo.icon .. td.PNG_Suffix)
end
function td.CreateWeaponIcon(id, star, posY)
  local StrongInfoManager = require("app.info.StrongInfoManager")
  local weaponInfo = StrongInfoManager:GetInstance():GetWeaponInfo(tonumber(id))
  if not weaponInfo then
    return display.newSprite(td.NOT_FOUND_ICON)
  end
  if star then
    return td.IconWithStar(weaponInfo.icon .. td.PNG_Suffix, star, weaponInfo.quality, posY)
  end
  return display.newSprite(weaponInfo.icon .. td.PNG_Suffix)
end
function td.CreateSkillIcon(id, star, quality, posY)
  local SkillInfoManager = require("app.info.SkillInfoManager")
  local skillInfo = SkillInfoManager:GetInstance():GetInfo(tonumber(id))
  if not skillInfo then
    return nil
  end
  local iconSpr
  if star then
    iconSpr = td.IconWithStar(skillInfo.icon .. td.PNG_Suffix, star, quality, posY, true)
    local borderSpr = display.newSprite("UI/backpack/item_border" .. quality .. td.PNG_Suffix)
    borderSpr:setScale(1.1)
    td.AddRelaPos(iconSpr, borderSpr)
  else
    iconSpr = display.newSprite(skillInfo.icon .. td.PNG_Suffix)
  end
  return iconSpr
end
function td.IconWithStar(iconFile, star, quality, posY, bNoBg)
  posY = posY or 5
  quality = quality or star
  local iconSpr = display.newSprite(iconFile)
  local iconWidth = iconSpr:getContentSize().width
  local startX, gapX, starScale
  for i = 1, quality do
    local starIcon
    if i <= star then
      starIcon = display.newSprite("UI/icon/xingxing_icon.png")
    else
      starIcon = display.newSprite("UI/icon/xingxing2_icon.png")
    end
    if not startX or not gapX then
      local starSize = starIcon:getContentSize()
      gapX = iconWidth * 0.18
      starScale = iconWidth * 0.25 / (starSize.width * 1.3)
      startX = (iconWidth - gapX * (quality - 1)) * 0.5
    end
    starIcon:scale(starScale):pos(startX + (i - 1) * gapX, posY):addTo(iconSpr, 10 - i)
    starIcon:setLocalZOrder(10)
  end
  if not bNoBg then
    local index = cc.clampf(quality, 1, 5)
    local bgSpr = display.newSprite("UI/backpack/item_bg" .. index .. td.PNG_Suffix)
    td.AddRelaPos(iconSpr, bgSpr, -1)
    local borderSpr = display.newSprite("UI/backpack/item_border" .. index .. td.PNG_Suffix)
    td.AddRelaPos(iconSpr, borderSpr)
  end
  if quality >= 5 then
    local legendParticle = ParticleManager:GetInstance():CreateParticle("Effect/chuanshuo.plist")
    td.AddRelaPos(iconSpr, legendParticle)
  end
  return iconSpr
end
function td.CreateCareerIcon(career)
  local iconSpr
  if td.CAREER_ICON[career] then
    iconSpr = display.newSprite(td.CAREER_ICON[career])
    if career ~= td.CareerType.Non then
      td.CreateUIEffect(iconSpr, "Spine/UI_effect/UI_kezhitishi_01")
    end
  end
  return iconSpr
end
function td.CreateRatingIcon(rating)
  local ratingSpr
  if td.RATING_ICON[rating] then
    ratingSpr = display.newSprite(td.RATING_ICON[rating])
  end
  return ratingSpr
end
function td.BtnSetTitle(btn, str, fontSize, color)
  fontSize = fontSize or 22
  color = color or td.WHITE
  local label = btn:getChildByName("title")
  if label then
    label:setString(str)
  else
    label = td.CreateLabel(str, color, fontSize)
    label:setName("title")
    label:setAnchorPoint(0.5, 0.5)
    td.AddRelaPos(btn, label)
  end
  return label
end
function td.BtnAddTouch(btn, cb, clickSound, effectType)
  if not btn then
    return
  end
  clickSound = clickSound or 53
  local bIsClicked = false
  btn:addTouchEventListener(function(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      td.ShowRP(btn, false)
      g_MC:UpdateOpTime()
      if not bIsClicked then
        if not g_MC:GetEnableUI() then
          return
        end
        local onlyName = g_MC:GetOnlyEnableName()
        if onlyName and onlyName ~= "" and onlyName ~= btn:getName() then
          return
        end
        if effectType then
          local effect
          if effectType == td.ButtonEffectType.Long then
            effect = "Spine/UI_effect/UI_anjianfankui_01"
          elseif effectType == td.ButtonEffectType.Short then
            effect = "Spine/UI_effect/UI_anjianfankui_02"
          end
          bIsClicked = true
          cb(btn)
          td.CreateUIEffect(btn, effect, {
            cb = function()
              bIsClicked = false
            end
          })
        else
          cb(btn)
        end
        G_SoundUtil:PlaySound(clickSound, false)
      end
    end
  end)
end
function td.EnableButton(btn, enable)
  local tmp = string.split(btn:getName(), "_") or {}
  local btnType = tonumber(tmp[#tmp])
  if not btnType then
    return
  end
  if enable then
    if btnType == td.BtnType.YellowShort then
      btn:loadTextures(td.BtnYS.enabled, td.BtnYS.pressed)
    elseif btnType == td.BtnType.GreenShort then
      btn:loadTextures(td.BtnGS.enabled, td.BtnGS.pressed)
    elseif btnType == td.BtnType.BlueShort then
      btn:loadTextures(td.BtnBS.enabled, td.BtnBS.pressed)
    elseif btnType == td.BtnType.YellowLong then
      btn:loadTextures(td.BtnYL.enabled, td.BtnYL.pressed)
    elseif btnType == td.BtnType.GreenLong then
      btn:loadTextures(td.BtnGL.enabled, td.BtnGL.pressed)
    elseif btnType == td.BtnType.BlueLong then
      btn:loadTextures(td.BtnBL.enabled, td.BtnBL.pressed)
    end
  elseif btnType == td.BtnType.YellowShort or btnType == td.BtnType.GreenShort or btnType == td.BtnType.BlueShort then
    btn:loadTextures("UI/button/huise_duan_button.png", "UI/button/huise_duan_button.png")
  else
    btn:loadTextures("UI/button/huise_chang_button.png", "UI/button/huise_chang_button.png")
  end
end
function td.ShowRP(node, bShow, relaPos, rp)
  local guideMng = require("app.GuideManager"):GetInstance()
  if not guideMng:IsForceGuideOver() then
    return
  end
  local redPoint = node:getChildByName("RedPoint")
  if redPoint then
    if not bShow then
      redPoint:removeFromParent()
    end
  elseif bShow then
    relaPos = relaPos or cc.p(0.95, 0.95)
    redPoint = rp or display.newSprite("UI/common/tishitubiao.png")
    redPoint:setName("RedPoint")
    td.AddRelaPos(node, redPoint, 10, relaPos)
    local scaleX = node:getScaleX() > 0 and redPoint:getScaleX() or -1 * redPoint:getScaleX()
    local scaleY = 0 < node:getScaleY() and redPoint:getScaleY() or -1 * redPoint:getScaleY()
    redPoint:setScaleX(0.01 * scaleX)
    redPoint:setScaleY(0.01 * scaleY)
    redPoint:runAction(cc.EaseBackInOut:create(cca.scaleTo(0.5, scaleX, scaleY)))
  end
end
function td.CreateUIEffect(parent, file, info)
  info = info or {}
  local pos = info.pos or cc.p(parent:getContentSize().width / 2, parent:getContentSize().height / 2)
  local aniName = info.ani or "animation"
  local pEffect = SkeletonUnit:create(file)
  pEffect:setPosition(pos)
  pEffect:setRotation(info.rotation or 0)
  pEffect:setScale(info.scale or 1)
  pEffect:addTo(parent, info.zorder or 1)
  if info.loop then
    pEffect:PlayAni(aniName, true)
  elseif info.random then
    pEffect:registerSpineEventHandler(function(event)
      if event.animation == "animation" then
        local delay = math.random(3, 6)
        pEffect:performWithDelay(function()
          pEffect:PlayAni("animation", false, false)
        end, delay)
      end
    end, sp.EventType.ANIMATION_COMPLETE)
    pEffect:setVisible(false)
    pEffect:performWithDelay(function()
      pEffect:setVisible(true)
      pEffect:PlayAni("animation", false, false)
    end, math.random(3, 6))
  else
    pEffect:registerSpineEventHandler(function(event)
      parent:performWithDelay(function()
        pEffect:removeFromParent()
        if info.cb then
          info.cb()
        end
      end, 0.05)
    end, sp.EventType.ANIMATION_COMPLETE)
    pEffect:PlayAni(aniName, false)
  end
  return pEffect
end
function td.ProgressTo(progressBar, toValue, endCb, fullCb, speed)
  speed = speed or 200
  local actions = {}
  local curPercent = progressBar:getPercentage()
  repeat
    local toValue1 = math.min(toValue, 100)
    local addPercent = toValue1 - curPercent
    local progressAction = cca.progressTo(addPercent / speed, toValue1)
    table.insert(actions, progressAction)
    if toValue1 == 100 then
      table.insert(actions, cca.cb(function()
        td.CreateUIEffect(progressBar, "Spine/UI_effect/UI_jingyantiao_01")
        progressBar:setPercentage(0)
        if fullCb then
          fullCb()
        end
      end))
    end
    curPercent = 0
    toValue = toValue - 100
  until toValue <= 0
  if endCb then
    table.insert(actions, cca.cb(function()
      endCb()
    end))
  end
  progressBar:runAction(cca.seq(actions))
end
function td.GetAutoScale(designW, designH)
  designW = designW or 1136
  designH = designH or 640
  local scaleWidth = display.size.width / designW
  local scaleHeight = display.size.height / designH
  return math.min(scaleWidth, scaleHeight)
end
function td.GetPropertyStr(type, value)
  local icon, str
  if type == 1 then
    icon = "\230\148\187\229\135\187: "
    if value < 0 then
      str = "?"
    elseif value <= 20 then
      str = g_LM:getBy("a00203")
    elseif value <= 50 then
      str = g_LM:getBy("a00202")
    else
      str = g_LM:getBy("a00201")
    end
  elseif type == 2 then
    icon = "\231\148\159\229\145\189: "
    if value < 0 then
      str = "?"
    elseif value <= 200 then
      str = g_LM:getBy("a00203")
    elseif value <= 500 then
      str = g_LM:getBy("a00202")
    elseif value <= 2000 then
      str = g_LM:getBy("a00201")
    else
      str = g_LM:getBy("a00200")
    end
  elseif type == 3 then
    icon = "\233\152\178\229\190\161: "
    if value < 0 then
      str = "?"
    elseif value <= 25 then
      str = g_LM:getBy("a00203")
    elseif value <= 60 then
      str = g_LM:getBy("a00202")
    else
      str = g_LM:getBy("a00201")
    end
  else
    icon = "\230\148\187\233\128\159: "
    if value < 0 then
      str = "?"
    elseif value >= 1.2 then
      str = g_LM:getBy("a00205")
    elseif value >= 1 then
      str = g_LM:getBy("a00202")
    else
      str = g_LM:getBy("a00204")
    end
  end
  local label = td.RichText({
    {
      type = 1,
      color = td.BLUE,
      size = 18,
      str = icon
    },
    {
      type = 1,
      color = td.WHITE,
      size = 18,
      str = str,
      bAjust = true
    }
  })
  return label
end
function td.GetWeaponPropLabel(type, value, varValue)
  local typeStr = g_LM:getMode("prop", type) .. ":"
  local valueStr = td.GetPropValue(type, value)
  local varValueStr = td.GetPropValue(type, varValue or 0)
  local typeLabel = td.CreateLabel(typeStr, td.BLUE, 20)
  local valueLabel
  if varValue then
    local iconFile = varValue >= 0 and "shangsheng_jiantou.png" or "xiajiang_jiantou.png"
    valueLabel = td.RichText({
      {
        type = 1,
        color = td.WHITE,
        size = 20,
        str = valueStr
      },
      {
        type = 2,
        file = "UI/common/" .. iconFile,
        scale = 1
      },
      {
        type = 1,
        color = td.YELLOW,
        size = 20,
        str = string.format("(%s)", varValueStr)
      }
    })
  else
    valueLabel = td.CreateLabel(valueStr, td.WHITE)
  end
  return typeLabel, valueLabel
end
function td.GetPropValue(type, value)
  if table.indexof({
    td.Property.Crit,
    td.Property.Dodge,
    td.Property.SuckHp,
    td.Property.Reflect
  }, type) then
    return value .. "%"
  end
  return value
end
function Util_calcOffsetByAnchor(pNode, newAncPos)
  local rtnPos = cc.p(0, 0)
  if pNode then
    local scaleX = pNode:getScaleX()
    local scaleY = pNode:getScaleY()
    local pos = cc.p(pNode:getPosition())
    local ancPos = cc.p(pNode:getAnchorPoint())
    local ancInPos = cc.p(pNode:getAnchorPointInPoints())
    ancInPos.x = ancInPos.x * scaleX
    ancInPos.y = ancInPos.y * scaleY
    local posNew = cc.pSub(pos, ancInPos)
    local size = pNode:getBoundingBox()
    posNew.x = posNew.x + size.width * newAncPos.x
    posNew.y = posNew.y + size.height * newAncPos.y
    rtnPos = posNew
  end
  return rtnPos
end
function Util_changeAnchor(pNode, newAncPos)
  if pNode then
    local pos = Util_calcOffsetByAnchor(pNode, newAncPos)
    pNode:setAnchorPoint(newAncPos)
    pNode:setPosition(pos)
  end
end
function td.AddRelaPos(parent, child, zorder, relaPos)
  relaPos = relaPos or cc.p(0.5, 0.5)
  zorder = zorder or 0
  local conSize = parent:getContentSize()
  child:setPosition(conSize.width * relaPos.x, conSize.height * relaPos.y)
  parent:addChild(child, zorder)
end
function td.SetAutoScale(root, uiPosHorizontal, uiPosVertical, designW, designH)
  designW = designW or 1136
  designH = designH or 640
  local scale = td.GetAutoScale(designW, designH)
  root:setScale(scale * root:getScale())
  if uiPosHorizontal == td.UIPosHorizontal.Left then
    root:setPositionX(0)
  elseif uiPosHorizontal == td.UIPosHorizontal.Right then
    root:setPositionX(display.size.width - designW * scale)
  else
    root:setPositionX((display.size.width - designW * scale) / 2)
  end
  if uiPosVertical == td.UIPosVertical.Top then
    root:setPositionY(display.size.height - designH * scale)
  elseif uiPosVertical == td.UIPosVertical.Bottom then
    root:setPositionY(0)
  else
    root:setPositionY((display.size.height - designH * scale) / 2)
  end
end
function td.StretchScale(root, uiPosHorizontal, uiPosVertical, designW, designH)
  designW = designW or 1136
  designH = designH or 640
  local scaleX, scaleY = display.width / designW, display.height / designH
  root:setScaleX(scaleX)
  root:setScaleY(scaleY)
  if uiPosHorizontal == td.UIPosHorizontal.Left then
    root:setPositionX(0)
  elseif uiPosHorizontal == td.UIPosHorizontal.Right then
    root:setPositionX(display.size.width - 1136 * scaleX)
  else
    root:setPositionX((display.size.width - 1136 * scaleX) / 2)
  end
  if uiPosVertical == td.UIPosVertical.Top then
    root:setPositionY(display.size.height - 640 * scaleY)
  elseif uiPosVertical == td.UIPosVertical.Bottom then
    root:setPositionY(0)
  else
    root:setPositionY((display.size.height - 640 * scaleY) / 2)
  end
end
function isTouchInNode(node, touchPoint)
  assert(node, "node is null")
  local viewRect = {}
  local size = node:getContentSize()
  viewRect.x = 0
  viewRect.y = 0
  viewRect.height = size.height
  viewRect.width = size.width
  return cc.rectContainsPoint(viewRect, cc.p(touchPoint.x, touchPoint.y))
end
function td.GetGuideArea(guideInfo, uiRoot)
  local guidePos, guideSize
  if guideInfo.nodeName then
    local targetNode = cc.uiloader:seekNodeByName(uiRoot, guideInfo.nodeName)
    if guideInfo.childId and #guideInfo.childId > 0 then
      for _, value in ipairs(guideInfo.childId) do
        if iskindof(targetNode, "UIListView") or iskindof(targetNode, "UIPageView") then
          targetNode = targetNode:getItemByPos(value)
        elseif type(value) == "string" then
          targetNode = cc.uiloader:seekNodeByName(targetNode, value)
        else
          targetNode = targetNode:getChildByTag(value)
        end
        if nil == targetNode then
          return guidePos, guideSize, false
        end
      end
    end
    guidePos = cc.p(targetNode:getPosition())
    if guideInfo.offset then
      guidePos = cc.pAdd(guidePos, guideInfo.offset)
    end
    guidePos = targetNode:getParent():convertToWorldSpace(guidePos)
    if guideInfo.size then
      guideSize = guideInfo.size
    else
      local box = targetNode:getBoundingBox()
      guideSize = cc.size(box.width, box.height)
    end
  else
    local GameDataManager = require("app.GameDataManager")
    guidePos = GameDataManager.GetInstance():GetGameMap():GetTileMap():convertToWorldSpace(guideInfo.pos)
    guideSize = guideInfo.size
  end
  return guidePos, guideSize, true
end
function td.GetGuideTarget(guideInfo, uiRoot)
  local targetNode
  if guideInfo.nodeName then
    targetNode = cc.uiloader:seekNodeByName(uiRoot, guideInfo.nodeName)
    if guideInfo.childId and #guideInfo.childId > 0 then
      for _, value in ipairs(guideInfo.childId) do
        if iskindof(targetNode, "UIListView") or iskindof(targetNode, "UIPageView") then
          targetNode = targetNode:getItemByPos(value)
        elseif type(value) == "string" then
          targetNode = cc.uiloader:seekNodeByName(targetNode, value)
        else
          targetNode = targetNode:getChildByTag(value)
        end
      end
    end
  end
  return targetNode
end
function td.UpdatePageArrow(data)
  local activeSpr = data.activeSpr or "UI/common/jiantou2_icon.png"
  local inactiveSpr = data.inactiveSpr or "UI/common/jiantou1_icon.png"
  local playAni = data.playAni
  data.leftArrow:stopAllActions()
  data.rightArrow:stopAllActions()
  if data.curPage == 1 then
    if playAni then
      data.leftArrow:runAction(cca.scaleTo(0, 1, 1))
      data.leftArrow:stopAllActions()
    end
    data.leftArrow:loadTexture(inactiveSpr)
  else
    data.leftArrow:loadTexture(activeSpr)
    data.leftArrow:runAction(cca.repeatForever(cca.seq({
      cca.scaleTo(0.5, 1.2),
      cca.scaleTo(0.2, 1)
    })))
  end
  if data.curPage == data.totalPage then
    if playAni then
      data.rightArrow:runAction(cca.scaleTo(0, -1, 1))
      data.rightArrow:stopAllActions()
    end
    data.rightArrow:loadTexture(inactiveSpr)
  else
    data.rightArrow:runAction(cca.repeatForever(cca.seq({
      cca.scaleTo(0.5, -1.2, 1.2),
      cca.scaleTo(0.2, -1, 1)
    })))
    data.rightArrow:loadTexture(activeSpr)
  end
end
function td.AfterReceive(btn, cb)
  local spr = display.newSprite("UI/words/yilingqu_icon.png")
  spr:setPosition(btn:getPosition())
  btn:getParent():addChild(spr)
  spr:setOpacity(0)
  spr:setScale(3)
  spr:runAction(cca.seq({
    cca.spawn({
      cca.scaleTo(0.3, 1),
      cca.fadeIn(0.3)
    }),
    cca.cb(cb)
  }))
  btn:setVisible(false)
end
function td.ShowAskToupDlg()
  local cb = function()
    g_MC:OpenModule(td.UIModule.Topup)
  end
  local data = {
    size = cc.size(454, 300),
    content = "\233\146\187\231\159\179\228\184\141\232\182\179\239\188\140\230\152\175\229\144\166\229\137\141\229\190\128\229\133\133\229\128\188\239\188\159",
    buttons = {
      {
        text = g_LM:getBy("a00009"),
        callFunc = cb
      },
      {
        text = g_LM:getBy("a00116")
      }
    }
  }
  local messageBox = require("app.layers.MessageBoxDlg").new(data)
  messageBox:Show()
end
function td.ShowBuyTimeDlg(uiId, cb)
  local cmMng = require("app.info.CommonInfoManager"):GetInstance()
  local udMng = require("app.UserDataManager"):GetInstance()
  local productId
  if uiId == td.UIModule.Endless then
    productId = td.BuyEndlessId
  elseif uiId == td.UIModule.Trial then
    productId = td.BuyTrialId
  elseif uiId == td.UIModule.Collect then
    productId = td.BuyCollectId
  elseif uiId == td.UIModule.Rob then
    productId = td.BuyRobId
  elseif uiId == td.UIModule.Bombard then
    productId = td.BuyBombId
  end
  local productInfo = cmMng:GetMallItemInfo(productId)
  if not productInfo then
    return
  end
  local vipInfo = cmMng:GetVipInfo(udMng:GetVipLevel())
  local remainTime = udMng:GetDungeonBuyTime(uiId)
  local costDiamond = productInfo.price + td.GetConst("exchange_add") * (vipInfo.dungeon_numbers - remainTime)
  local data
  if remainTime > 0 then
    data = {
      size = cc.size(454, 300),
      content = string.format(g_LM:getBy("a00250"), costDiamond, remainTime),
      buttons = {
        {
          text = g_LM:getBy("a00009"),
          callFunc = function()
            if udMng:GetDiamond() >= costDiamond then
              cb()
            else
              td.alertErrorMsg(td.ErrorCode.DIAMOND_NOT_ENOUGH)
            end
          end
        },
        {
          text = g_LM:getBy("a00116")
        }
      }
    }
  else
    data = {
      size = cc.size(454, 300),
      content = g_LM:getMode("errormsg", td.ErrorCode.TIME_NOT_ENOUGH),
      buttons = {
        {
          text = g_LM:getBy("a00009")
        }
      }
    }
  end
  local messageBox = require("app.layers.MessageBoxDlg").new(data)
  messageBox:Show()
end
