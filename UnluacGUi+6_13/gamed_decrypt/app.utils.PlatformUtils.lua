pu = pu or {}
pu.platformId = nil
function pu.ShowLoginDlg(loginScene)
  local platformId = pu.GetPlatform()
  if platformId == "yaphet" or platformId == "appstore" then
    loginScene:InitUIForgroud()
  elseif device.platform == "android" then
    luaj.callStaticMethod("org/cocos2dx/lua/NativeUtils", "showLoginDlg", {
      handler(loginScene, loginScene.sdkLoginCallback)
    })
  elseif device.platform == "ios" then
    luaoc.callStaticMethod("IOSPlatformUtil", "showLoginDlg", {
      callback = handler(loginScene, loginScene.sdkLoginCallback)
    })
  end
end
function pu.ShowExitDlg()
  local udMng = require("app.UserDataManager"):GetInstance()
  local userData = udMng:GetSubmitUserData()
  userData.sceneValue = tostring(3)
  local data = json.encode(userData)
  if device.platform == "android" then
    luaj.callStaticMethod("org/cocos2dx/lua/NativeUtils", "showExitDlg", {data})
  else
  end
end
function pu.SetLogoutCallback()
  local GameControl = require("app.GameControl")
  if device.platform == "android" then
    luaj.callStaticMethod("org/cocos2dx/lua/NativeUtils", "setLogoutCallback", {
      GameControl.Logout
    })
  elseif device.platform == "ios" then
    luaoc.callStaticMethod("IOSPlatformUtil", "setLogoutCallback", {
      callback = GameControl.Logout
    })
  end
end
function pu.SubmitData(sceneValue)
  local udMng = require("app.UserDataManager"):GetInstance()
  local userData = udMng:GetSubmitUserData()
  userData.sceneValue = tostring(sceneValue)
  if device.platform == "android" then
    local data = json.encode(userData)
    luaj.callStaticMethod("org/cocos2dx/lua/NativeUtils", "submitUserData", {data})
  elseif device.platform == "ios" then
    luaoc.callStaticMethod("IOSPlatformUtil", "submitUserData", userData)
  end
end
function pu.MobClickFunc(type, data)
  if not MobClickForLua then
    return
  end
  if type == 1 then
    if device.platform == "ios" then
      MobClickForLua.startMobclick("59376a1465b6d672680006b5", pu.GetPlatform())
    end
  elseif type == 2 then
    MobClickForLua.profileSignIn(data)
  elseif type == 3 then
    MobClickForLua.profileSignOff()
  elseif type == 4 then
    MobClickForLua.pay(data.cash, 1, data.coin)
  elseif type == 5 then
    MobClickForLua.pay(data.cash, 1, data.item, 1, data.price)
  elseif type == 6 then
    MobClickForLua.setUserLevel(data)
  end
end
function pu.logDebug(msg)
  if device.platform == "android" then
    luaj.callStaticMethod("org/cocos2dx/lua/NativeUtils", "logDebug", {msg})
  else
    print(msg)
  end
end
function pu.GetVersion()
  local version = ""
  if device.platform == "android" then
    version = luaj.callStaticMethod("org/cocos2dx/lua/NativeUtils", "getVersion", {})
  elseif device.platform == "ios" then
  end
  return version
end
function pu.GetPlatform()
  if pu.platformId then
    return pu.platformId
  end
  local bResult, ret = true, "yaphet"
  if device.platform == "android" then
    bResult, ret = luaj.callStaticMethod("org/cocos2dx/lua/NativeUtils", "getPlatform", {}, "()Ljava/lang/String;")
  elseif device.platform == "ios" then
    bResult, ret = luaoc.callStaticMethod("IOSPlatformUtil", "getPlatform", {})
  end
  if not bResult then
    td.alertDebug("\232\142\183\229\143\150\230\184\160\233\129\147id\229\164\177\232\180\165\239\188\140\233\148\153\232\175\175\231\160\129:" .. ret)
  end
  pu.platformId = ret
  return ret
end
function pu.Pay(data)
  if device.platform == "android" then
    local params = {
      tostring(data.orderId),
      data.url,
      data.sum,
      data.desc,
      data.callback
    }
    luaj.callStaticMethod("org/cocos2dx/lua/NativeUtils", "pay", params)
  elseif device.platform == "ios" then
    luaoc.callStaticMethod("IOSPlatformUtil", "pay", data)
    dump(data)
  else
    dump(data)
  end
end
function pu.InitIAP(data)
  if pu.GetPlatform() == "appstore" then
    luaoc.callStaticMethod("IOSPlatformUtil", "initIAP", data)
  end
end
