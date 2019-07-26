require("config")
require("cocos.init")
require("framework.init")
require("app.init")
local MyApp = class("MyApp", cc.mvc.AppBase)
function MyApp:ctor()
  MyApp.super.ctor(self)
end
function MyApp:exit()
  require("app.GameControl").ClearValueForType(td.GameControlType.ExitGame)
  MyApp.super.exit(self)
end
function MyApp:run()
  cc.FileUtils:getInstance():addSearchPath("res/")
  math.randomseed(os.time())
  cc.Image:setPVRImagesHavePremultipliedAlpha(true)
  g_LM:Init()
  pu.MobClickFunc(1)
  self:enterScene("HealthyScene")
end
return MyApp
