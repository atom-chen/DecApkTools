local LanguageManager = class("LanguageManager")
LanguageManager.instance = nil
function LanguageManager:ctor()
  self.Language = cc.LANGUAGE_CHINESE
  self:Init()
end
function LanguageManager:GetInstance()
  if LanguageManager.instance == nil then
    LanguageManager.instance = LanguageManager.new()
  end
  return LanguageManager.instance
end
function LanguageManager:Init()
  if cc.LANGUAGE_CHINESE == self.Language then
    self.language_map = require("app.language.language_ZH")
  else
    self.language_map = require("app.language.language_EN")
  end
end
function LanguageManager:getBy(key)
  if key then
    return self.language_map[key] or key
  end
  return ""
end
function LanguageManager:getMode(model, key)
  if key and model and self.language_map[model] then
    return self.language_map[model][key]
  end
  return ""
end
g_LM = g_LM or LanguageManager:GetInstance()
