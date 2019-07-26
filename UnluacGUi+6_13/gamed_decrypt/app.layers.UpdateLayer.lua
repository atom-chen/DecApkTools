local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local UpdateLayer = class("UpdateLayer", BaseDlg)
function UpdateLayer:ctor(pScene)
  UpdateLayer.super.ctor(self, 0)
  self._curScene = pScene
  self:InitUI()
  self._path = Launcher.writablePath .. "upd/"
  scheduler.performWithDelayGlobal(function()
    self:_checkUpdate()
  end, 0.1)
end
function UpdateLayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/UpdateLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  td.SetAutoScale(self.m_uiRoot, td.UIPosHorizontal.Right, td.UIPosVertical.Bottom)
  self._progressBar = cc.uiloader:seekNodeByName(self.m_uiRoot, "Slider")
  self._progressBar:setPercent(0)
  self._textLabel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Label_progress")
end
function UpdateLayer:_checkUpdate()
  Launcher.mkDir(self._path)
  self._curListFile = self._path .. Launcher.fListName
  if Launcher.fileExists(self._curListFile) then
    self._fileList = Launcher.doFile(self._curListFile)
  end
  if self._fileList ~= nil then
  else
    self._fileList = Launcher.doFile(Launcher.fListName)
  end
  self._textLabel:setString("\230\163\128\230\159\165\230\155\180\230\150\176\228\184\173...")
  if self._fileList == nil then
    self._updateRetType = Launcher.UpdateRetType.OTHER_ERROR
    self:_endUpdate()
  end
  self:_requestFromServer(Launcher.fListName, Launcher.RequestType.FLIST)
end
function UpdateLayer:_endUpdate()
  if self._updateRetType ~= Launcher.UpdateRetType.SUCCESSED then
    print("\230\155\180\230\150\176\229\164\177\232\180\165,errorcode:" .. self._updateRetType)
    Launcher.removePath(self._curListFile)
    self._textLabel:setString("\230\155\180\230\150\176\229\164\177\232\180\165,errorcode:" .. self._updateRetType)
  else
    require("main")
  end
end
function UpdateLayer:_requestFromServer(filename, requestType, waittime)
  local url = Launcher.server .. filename
  local request = cc.HTTPRequest:createWithUrl(function(event)
    self:_onResponse(event, requestType)
  end, url, cc.kCCHTTPRequestMethodGET)
  if request then
    request:setTimeout(waittime or 30)
    request:start()
  else
    self._updateRetType = Launcher.UpdateRetType.NETWORK_ERROR
    self:_endUpdate()
  end
end
function UpdateLayer:_onResponse(event, requestType)
  local request = event.request
  if event.name == "completed" then
    if request:getResponseStatusCode() ~= 200 then
      self._updateRetType = Launcher.UpdateRetType.NETWORK_ERROR
      self:_endUpdate()
    else
      local dataRecv = request:getResponseData()
      if requestType == Launcher.RequestType.FLIST then
        self:_onFileListDownloaded(dataRecv)
      else
        self:_onResFileDownloaded(dataRecv)
      end
    end
  elseif event.name == "progress" then
    if requestType == Launcher.RequestType.RES then
      self:_onResProgress(event.dltotal)
    end
  else
    self._updateRetType = Launcher.UpdateRetType.NETWORK_ERROR
    self:_endUpdate()
  end
end
function UpdateLayer:_onFileListDownloaded(dataRecv)
  self._newListFile = self._curListFile .. Launcher.updateFilePostfix
  Launcher.writefile(self._newListFile, dataRecv)
  self._fileListNew = Launcher.doFile(self._newListFile)
  if self._fileListNew == nil then
    self._updateRetType = Launcher.UpdateRetType.OTHER_ERROR
    self:_endUpdate()
    return
  end
  if self._fileListNew.version == self._fileList.version then
    Launcher.removePath(self._newListFile)
    self._updateRetType = Launcher.UpdateRetType.SUCCESSED
    self._curScene:ShowLoginLayer()
    self:close()
    return
  end
  local dirPaths = self._fileListNew.dirPaths
  for i = 1, #dirPaths do
    Launcher.mkDir(self._path .. dirPaths[i].name)
  end
  self:_updateNeedDownloadFiles()
  self._numFileCheck = 0
  self:_reqNextResFile()
end
function UpdateLayer:_onResFileDownloaded(dataRecv)
  local fn = self._curFileInfo.name .. Launcher.updateFilePostfix
  Launcher.writefile(self._path .. fn, dataRecv)
  if Launcher.checkFileWithMd5(self._path .. fn, self._curFileInfo.code) then
    table.insert(self._downList, fn)
    self._hasDownloadSize = self._hasDownloadSize + self._curFileInfo.size
    self._hasCurFileDownloadSize = 0
    self:_reqNextResFile()
  else
    self._updateRetType = Launcher.UpdateRetType.MD5_ERROR
    self:_endUpdate()
  end
end
function UpdateLayer:_onResProgress(dltotal)
  self._hasCurFileDownloadSize = dltotal
  self:_updateProgressUI()
end
function UpdateLayer:_updateNeedDownloadFiles()
  self._needDownloadFiles = {}
  self._needRemoveFiles = {}
  self._downList = {}
  self._needDownloadSize = 0
  self._hasDownloadSize = 0
  self._hasCurFileDownloadSize = 0
  local newFileInfoList = self._fileListNew.fileInfoList
  local oldFileInfoList = self._fileList.fileInfoList
  local hasChanged = false
  for i = 1, #newFileInfoList do
    hasChanged = false
    for k = 1, #oldFileInfoList do
      if newFileInfoList[i].name == oldFileInfoList[k].name then
        hasChanged = true
        if newFileInfoList[i].code ~= oldFileInfoList[k].code then
          local fn = newFileInfoList[i].name .. Launcher.updateFilePostfix
          if Launcher.checkFileWithMd5(self._path .. fn, newFileInfoList[i].code) then
            table.insert(self._downList, fn)
          else
            self._needDownloadSize = self._needDownloadSize + newFileInfoList[i].size
            table.insert(self._needDownloadFiles, newFileInfoList[i])
          end
        end
        table.remove(oldFileInfoList, k)
        break
      end
    end
    if hasChanged == false then
      self._needDownloadSize = self._needDownloadSize + newFileInfoList[i].size
      table.insert(self._needDownloadFiles, newFileInfoList[i])
    end
  end
  self._needRemoveFiles = oldFileInfoList
  print("self._needDownloadFiles count = " .. #self._needDownloadFiles)
  self._textLabel:setString("\230\173\163\229\156\168\230\155\180\230\150\176..." .. "0%")
end
function UpdateLayer:_updateProgressUI()
  local downloadPro = (self._hasDownloadSize + self._hasCurFileDownloadSize) * 100 / self._needDownloadSize
  self._progressBar:setPercent(downloadPro)
  self._textLabel:setString("\230\173\163\229\156\168\230\155\180\230\150\176..." .. string.format("%d%%", downloadPro))
end
function UpdateLayer:_reqNextResFile()
  self:_updateProgressUI()
  self._numFileCheck = self._numFileCheck + 1
  self._curFileInfo = self._needDownloadFiles[self._numFileCheck]
  if self._curFileInfo and self._curFileInfo.name then
    self:_requestFromServer(self._curFileInfo.name, Launcher.RequestType.RES)
  else
    self:_endAllResFileDownloaded()
  end
end
function UpdateLayer:_endAllResFileDownloaded()
  local data = Launcher.readFile(self._newListFile)
  Launcher.writefile(self._curListFile, data)
  self._fileList = Launcher.doFile(self._curListFile)
  if self._fileList == nil then
    self._updateRetType = Launcher.UpdateRetType.OTHER_ERROR
    self:_endUpdate()
    return
  end
  Launcher.removePath(self._newListFile)
  local offset = -1 - string.len(Launcher.updateFilePostfix)
  for i, v in ipairs(self._downList) do
    v = self._path .. v
    local data = Launcher.readFile(v)
    local fn = string.sub(v, 1, offset)
    Launcher.writefile(fn, data)
    Launcher.removePath(v)
  end
  for i, v in ipairs(self._needRemoveFiles) do
    Launcher.removePath(self._path .. v.name)
  end
  self._updateRetType = Launcher.UpdateRetType.SUCCESSED
  self:_endUpdate()
end
return UpdateLayer
