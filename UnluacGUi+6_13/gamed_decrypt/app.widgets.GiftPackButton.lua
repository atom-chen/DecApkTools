local UserDataManager = require("app.UserDataManager")
local StoreDataManager = require("app.StoreDataManager")
local GiftPackButton = class("GiftPackButton", function()
  return ccui.Button:create("UI/button/shibinglibao.png", "UI/button/shibinglibao.png")
end)
function GiftPackButton:ctor()
  self.cbLabel = nil
  self:Init()
  self:setNodeEventEnabled(true)
end
function GiftPackButton:Init()
  td.CreateUIEffect(self, "Spine/UI_effect/UI_huodongtishi_01", {zorder = -1, loop = true})
end
return GiftPackButton
