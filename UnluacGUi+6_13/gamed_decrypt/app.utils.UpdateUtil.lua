require("lfs")
Launcher = {}
Launcher.server = "http://112.74.131.139/dlr/"
Launcher.fListName = "flist.upd"
Launcher.libDir = "lib/"
Launcher.lcherZipName = "launcher.zip"
Launcher.updateFilePostfix = ".upd"
Launcher.ResolutionPolicy = {
  EXACT_FIT = 0,
  NO_BORDER = 1,
  SHOW_ALL = 2,
  FIXED_HEIGHT = 3,
  FIXED_WIDTH = 4,
  FILL_ALL = 5,
  UNKNOWN = 6
}
Launcher.PLATFORM_OS_WINDOWS = 0
Launcher.PLATFORM_OS_LINUX = 1
Launcher.PLATFORM_OS_MAC = 2
Launcher.PLATFORM_OS_ANDROID = 3
Launcher.PLATFORM_OS_IPHONE = 4
Launcher.PLATFORM_OS_IPAD = 5
Launcher.PLATFORM_OS_BLACKBERRY = 6
Launcher.PLATFORM_OS_NACL = 7
Launcher.PLATFORM_OS_EMSCRIPTEN = 8
Launcher.PLATFORM_OS_TIZEN = 9
Launcher.PLATFORM_OS_WINRT = 10
Launcher.PLATFORM_OS_WP8 = 11
Launcher.PROGRESS_TIMER_BAR = 1
Launcher.PROGRESS_TIMER_RADIAL = 0
local sharedApplication = cc.Application:getInstance()
local sharedDirector = cc.Director:getInstance()
local target = sharedApplication:getTargetPlatform()
Launcher.platform = "unknown"
Launcher.model = "unknown"
if target == Launcher.PLATFORM_OS_WINDOWS then
  Launcher.platform = "windows"
elseif target == Launcher.PLATFORM_OS_MAC then
  Launcher.platform = "mac"
elseif target == Launcher.PLATFORM_OS_ANDROID then
  Launcher.platform = "android"
elseif target == Launcher.PLATFORM_OS_IPHONE or target == Launcher.PLATFORM_OS_IPAD then
  Launcher.platform = "ios"
  if target == Launcher.PLATFORM_OS_IPHONE then
    Launcher.model = "iphone"
  else
    Launcher.model = "ipad"
  end
elseif target == Launcher.PLATFORM_OS_WINRT then
  Launcher.platform = "winrt"
elseif target == Launcher.PLATFORM_OS_WP8 then
  Launcher.platform = "wp8"
end
local winSize = sharedDirector:getWinSize()
Launcher.size = {
  width = winSize.width,
  height = winSize.height
}
Launcher.width = Launcher.size.width
Launcher.height = Launcher.size.height
Launcher.cx = Launcher.width / 2
Launcher.cy = Launcher.height / 2
Launcher.writablePath = cc.FileUtils:getInstance():getWritablePath()
if Launcher.platform == "android" then
  Launcher.javaClassName = "org/cocos2dx/lua/luajavabridge/Luajavabridge"
  Launcher.luaj = {}
  function Launcher.luaj.callStaticMethod(className, methodName, args, sig)
    return LuaJavaBridge.callStaticMethod(className, methodName, args, sig)
  end
elseif Launcher.platform == "ios" then
  Launcher.ocClassName = "LuaObjcFun"
  Launcher.luaoc = {}
  function Launcher.luaoc.callStaticMethod(className, methodName, args)
    local ok, ret = LuaObjcBridge.callStaticMethod(className, methodName, args)
    if not ok then
      local msg = string.format("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ", className, methodName, tostring(args), tostring(ret))
      if ret == -1 then
        print(msg .. "INVALID PARAMETERS")
      elseif ret == -2 then
        print(msg .. "CLASS NOT FOUND")
      elseif ret == -3 then
        print(msg .. "METHOD NOT FOUND")
      elseif ret == -4 then
        print(msg .. "EXCEPTION OCCURRED")
      elseif ret == -5 then
        print(msg .. "INVALID METHOD SIGNATURE")
      else
        print(msg .. "UNKNOWN")
      end
    end
    return ok, ret
  end
end
Launcher.RequestType = {
  LAUNCHER = 0,
  FLIST = 1,
  RES = 2
}
Launcher.UpdateRetType = {
  SUCCESSED = 0,
  NETWORK_ERROR = 1,
  MD5_ERROR = 2,
  OTHER_ERROR = 3
}
function lcher_handler(obj, method)
  return function(...)
    return method(obj, ...)
  end
end
function lcher_class(classname, super)
  local superType = type(super)
  local cls
  if superType ~= "function" and superType ~= "table" then
    superType = nil
    super = nil
  end
  if superType == "function" or super and super.__ctype == 1 then
    cls = {}
    if superType == "table" then
      for k, v in pairs(super) do
        cls[k] = v
      end
      cls.__create = super.__create
      cls.super = super
    else
      cls.__create = super
      function cls.ctor()
      end
    end
    cls.__cname = classname
    cls.__ctype = 1
    function cls.new(...)
      local instance = cls.__create(...)
      for k, v in pairs(cls) do
        instance[k] = v
      end
      instance.class = cls
      instance:ctor(...)
      return instance
    end
  else
    if super then
      cls = {}
      setmetatable(cls, {__index = super})
      cls.super = super
    else
      cls = {
        ctor = function()
        end
      }
    end
    cls.__cname = classname
    cls.__ctype = 2
    cls.__index = cls
    function cls.new(...)
      local instance = setmetatable({}, cls)
      instance.class = cls
      instance:ctor(...)
      return instance
    end
  end
  return cls
end
function Launcher.hex(s)
  s = string.gsub(s, "(.)", function(x)
    return string.format("%02X", string.byte(x))
  end)
  return s
end
function Launcher.fileExists(path)
  return cc.FileUtils:getInstance():isFileExist(path)
end
function Launcher.readFile(path)
  return cc.FileUtils:getInstance():getDataFromFile(path)
end
function Launcher.writefile(path, content, mode)
  mode = mode or "w+b"
  local file = io.open(path, mode)
  if file then
    if file:write(content) == nil then
      return false
    end
    io.close(file)
    return true
  else
    return false
  end
end
function Launcher.removePath(path)
  local mode = lfs.attributes(path, "mode")
  if mode == "directory" then
    local dirPath = path .. "/"
    for file in lfs.dir(dirPath) do
      if file ~= "." and file ~= ".." then
        local f = dirPath .. file
        Launcher.removePath(f)
      end
    end
    os.remove(path)
  else
    os.remove(path)
  end
end
function Launcher.mkDir(path)
  if not Launcher.fileExists(path) then
    return lfs.mkdir(path)
  end
  return true
end
function Launcher.doFile(path)
  local fileData = cc.HelperFunc:getFileData(path)
  local fun = loadstring(fileData)
  local ret, flist = pcall(fun)
  if ret then
    return flist
  end
  return flist
end
function Launcher.fileDataMd5(fileData)
  if fileData ~= nil then
    return cc.Crypto:MD5(Launcher.hex(fileData), false)
  else
    return nil
  end
end
function Launcher.fileMd5(filePath)
  local data = Launcher.readFile(filePath)
  return Launcher.fileDataMd5(data)
end
function Launcher.checkFileDataWithMd5(data, cryptoCode)
  if cryptoCode == nil then
    return true
  end
  local fMd5 = cc.Crypto:MD5(Launcher.hex(data), false)
  if fMd5 == cryptoCode then
    return true
  end
  return false
end
function Launcher.checkFileWithMd5(filePath, cryptoCode)
  if not Launcher.fileExists(filePath) then
    return false
  end
  local data = Launcher.readFile(filePath)
  if data == nil then
    return false
  end
  return Launcher.checkFileDataWithMd5(data, cryptoCode)
end
function Launcher.getAppVersionCode()
  local appVersion = 1
  if Launcher.platform == "android" then
    local javaMethodName = "getAppVersionCode"
    local javaParams = {}
    local javaMethodSig = "()I"
    local ok, ret = Launcher.luaj.callStaticMethod(Launcher.javaClassName, javaMethodName, javaParams, javaMethodSig)
    if ok then
      appVersion = ret
    end
  elseif Launcher.platform == "ios" then
    local ok, ret = Launcher.luaoc.callStaticMethod(Launcher.ocClassName, "getAppVersionCode")
    if ok then
      appVersion = ret
    end
  end
  return appVersion
end
function Launcher.runWithScene(scene)
  local curScene = sharedDirector:getRunningScene()
  if curScene then
    sharedDirector:replaceScene(scene)
  else
    sharedDirector:runWithScene(scene)
  end
end
