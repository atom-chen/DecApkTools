local ActorManager = require("app.actor.ActorManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local GameDataManager = require("app.GameDataManager")
local EditorUILayer = class("EditorUILayer", function()
  return display.newNode()
end)
EditorUILayer.Maps = {
  "Map/tiled_shilian/beijing",
  "Map/tiled_shilian/bynsals",
  "Map/tiled_shilian/huilingdun",
  "Map/tiled_shilian/xini",
  "Map/tiled_shilian/lundun",
  "Map/tiled_shilian/mosike",
  "Map/tiled_shilian/dibai"
}
function EditorUILayer:ctor()
  self:setNodeEventEnabled(true)
  self.m_actorInfoMng = ActorInfoManager:GetInstance()
  self.m_selectActor = nil
  self.m_selectActorPos = nil
  self.m_actorId = 0
  self.m_isActive = false
  self.m_iCurMapIndex = 1
  self.m_vMonsters = {}
  self.m_curItem = nil
  self.m_touchListener = nil
  self:InitUI()
end
function EditorUILayer:onEnter()
  self:AddTouch()
end
function EditorUILayer:onExit()
end
function EditorUILayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EditorUILayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  for i = 1, #EditorUILayer.Maps do
    do
      local button = self.m_uiRoot:getChildByTag(i)
      button:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
          self:ChangeMap(i)
        end
      end)
    end
  end
  local saveButton = self.m_uiRoot:getChildByTag(100)
  saveButton:addTouchEventListener(function(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      self:Save()
    end
  end)
  local clearButton = self.m_uiRoot:getChildByTag(101)
  clearButton:addTouchEventListener(function(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      self:RemoveAllActor()
    end
  end)
  self:InitList()
end
function EditorUILayer:InitList()
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
    viewRect = cc.rect(0, 0, 1136, 100),
    touchOnContent = false,
    scale = 1
  })
  self.m_UIListView:setPosition(0, 0)
  self.m_UIListView:setAlignment(4)
  self:addChild(self.m_UIListView)
  self.m_UIListView:onTouch(function(event)
    if "clicked" == event.name and event.item then
      self:OnListItemClicked(event)
    end
  end)
  local infos = self.m_actorInfoMng:GetMonsterInfos()
  for id, var in pairs(infos) do
    if var.monster_type ~= td.MonsterType.BOSS and var.monster_type ~= td.MonsterType.Patrol then
      local item = self:CreateItem(var)
      item:setTag(id)
      self.m_UIListView:addItem(item)
    end
  end
  self.m_UIListView:reload()
end
function EditorUILayer:CreateItem(info)
  local itemNode = display.newNode()
  local sk = SkeletonUnit:create(info.image)
  sk:setTag(1)
  sk:setScale(-0.3, 0.3)
  sk:setPosition(0, -50)
  sk:addTo(itemNode)
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize(50, 100)
  return item
end
function EditorUILayer:OnListItemClicked(event)
  if not event.item then
    return
  end
  if self.m_curItem then
    self.m_curItem:getContent():getChildByTag(1):PlayAni("stand", false)
  end
  self.m_curItem = event.item
  self.m_curItem:getContent():getChildByTag(1):PlayAni("run", true)
  self.m_actorId = self.m_curItem:getTag()
  GameDataManager:GetInstance():SetFocusNode(self)
end
function EditorUILayer:ChangeMap(i)
  if i ~= self.m_iCurMapIndex then
    self.m_iCurMapIndex = i
    self:RemoveAllActor()
    self:getParent():ChangeMap(EditorUILayer.Maps[i])
    self:AddTouch()
  end
end
function EditorUILayer:Save()
  local data = ""
  for i, v in ipairs(self.m_vMonsters) do
    if i ~= 1 then
      data = data .. ";"
    end
    data = data .. v.key .. ":" .. math.floor(v:getPositionX()) .. ":" .. math.floor(v:getPositionY())
  end
  cc.UserDefault:getInstance():setStringForKey("editor_map", EditorUILayer.Maps[self.m_iCurMapIndex])
  cc.UserDefault:getInstance():setStringForKey("editor", data)
  self:getParent():SaveScreen()
  td.alertDebug("\228\191\157\229\173\152\230\136\144\229\138\159")
end
function EditorUILayer:CreateActor(id, pos)
  local info = self.m_actorInfoMng:GetMonsterInfo(id)
  local actor = SkeletonUnit:create(info.image)
  actor:setScale(-0.4, 0.4)
  actor:setPosition(0, -50)
  actor:PlayAni("stand", true)
  actor:setPosition(pos)
  actor.key = id
  local pMap = self:getParent():GetGameMap()
  pMap:addChild(actor, pMap:GetPiexlSize().height - actor:getPositionY(), actor:getTag())
  return actor
end
function EditorUILayer:RemoveActor(actor)
  for i, v in ipairs(self.m_vMonsters) do
    if v == actor then
      v:removeFromParent()
      table.remove(self.m_vMonsters, i)
      return
    end
  end
end
function EditorUILayer:RemoveAllActor()
  for i, v in ipairs(self.m_vMonsters) do
    v:removeFromParent()
  end
  self.m_vMonsters = {}
end
function EditorUILayer:AddTouch()
  local eventDsp = self:getEventDispatcher()
  if self.m_touchListener then
    eventDsp:removeEventListener(self.m_touchListener)
  end
  local pMap = self:getParent():GetGameMap()
  self.m_touchListener = cc.EventListenerTouchOneByOne:create()
  self.m_touchListener:setSwallowTouches(true)
  self.m_touchListener:registerScriptHandler(function(_touch, _event)
    local touchPos = _touch:getLocation()
    if self.m_UIListView:isTouchInViewRect({
      x = touchPos.x,
      y = touchPos.y
    }) then
      self.m_UIListView:onTouch_({
        name = "began",
        x = touchPos.x,
        y = touchPos.y,
        prevX = _touch:getPreviousLocation().x,
        prevY = _touch:getPreviousLocation().y
      })
      self.m_bIsTouchInList = true
      return true
    else
      self.m_bIsTouchInList = false
    end
    local mapPos = cc.p(pMap:GetMapPosFromWorldPos(touchPos))
    for i, v in ipairs(self.m_vMonsters) do
      local actorPos = cc.p(v:getPosition())
      local rect = {}
      rect.width = v:GetContentSize().width * math.abs(v:getScaleX())
      rect.height = v:GetContentSize().height * math.abs(v:getScaleY())
      rect.x = actorPos.x - rect.width / 2
      rect.y = actorPos.y
      if cc.rectContainsPoint(rect, mapPos) then
        self.m_selectActor = v
        self.m_selectActorPos = actorPos
        self.m_selectActorOffsetPos = cc.p(mapPos.x - self.m_selectActorPos.x, mapPos.y - self.m_selectActorPos.y)
        return true
      end
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  self.m_touchListener:registerScriptHandler(function(_touch, _event)
    local touchPos = _touch:getLocation()
    if self.m_UIListView:isTouchInViewRect({
      x = touchPos.x,
      y = touchPos.y
    }) then
      self.m_UIListView:onTouch_({
        name = "moved",
        x = touchPos.x,
        y = touchPos.y,
        prevX = _touch:getPreviousLocation().x,
        prevY = _touch:getPreviousLocation().y
      })
      return
    end
    if self.m_selectActor then
      local mapPos = cc.p(pMap:GetMapPosFromWorldPos(touchPos))
      mapPos.x = mapPos.x - self.m_selectActorOffsetPos.x
      mapPos.y = mapPos.y - self.m_selectActorOffsetPos.y
      local mapTilePos = pMap:GetTilePosFromPixelPos(mapPos)
      if pMap:IsWalkable(mapTilePos) then
        self.m_selectActor:setVisible(true)
        self.m_selectActor:setPosition(mapPos)
      else
        self.m_selectActor:setVisible(false)
      end
      self.m_bChanged = true
    elseif self.m_isActive then
      local rect = _event:getCurrentTarget():getBoundingBox()
      local pos = self:getParent():convertToNodeSpace({
        x = touchPos.x,
        y = touchPos.y
      })
      if not cc.rectContainsPoint(rect, pos) then
        self:onTouchMoved(_touch:getLocation())
      end
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  self.m_touchListener:registerScriptHandler(function(_touch, _event)
    local touchPos = _touch:getLocation()
    if self.m_bIsTouchInList then
      self.m_UIListView:onTouch_({
        name = "ended",
        x = touchPos.x,
        y = touchPos.y,
        prevX = _touch:getPreviousLocation().x,
        prevY = _touch:getPreviousLocation().y
      })
      return
    end
    if self.m_selectActor then
      local mapPos = cc.p(pMap:GetMapPosFromWorldPos(touchPos))
      mapPos.x = mapPos.x - self.m_selectActorOffsetPos.x
      mapPos.y = mapPos.y - self.m_selectActorOffsetPos.y
      local mapTilePos = pMap:GetTilePosFromPixelPos(mapPos)
      if pMap:IsWalkable(mapTilePos) then
        self.m_selectActor:setVisible(true)
        self.m_selectActor:setPosition(mapPos)
      else
        self:RemoveActor(self.m_selectActor, true)
        self.m_selectActor = nil
      end
      self.m_selectActor = nil
      self.m_selectActorPos = {}
    elseif not self.m_isActive then
      GameDataManager:GetInstance():SetFocusNode(nil)
    else
      self:onTouchEnded(_touch:getLocation())
      local rect = self.m_bg:getBoundingBox()
      local pos = self:getParent():convertToNodeSpace({
        x = touchPos.x,
        y = touchPos.y
      })
      if not cc.rectContainsPoint(rect, pos) then
        self:DoFocus(touchPos)
      end
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(self.m_touchListener, self)
end
function EditorUILayer:onTouchBegan()
  if GameDataManager:GetInstance():GetFocusNode() ~= self then
    GameDataManager:GetInstance():SetFocusNode(self)
  end
end
function EditorUILayer:onTouchMoved(_pos)
  local pos = self:convertToNodeSpace(cc.p(_pos.x, _pos.y))
  if self.m_skeleton then
    self.m_skeleton:setPosition(pos)
  else
    local fileName = ActorInfoManager:GetInstance():GetMonsterInfo(self.m_actorId).image
    self.m_skeleton = SkeletonUnit:create(fileName)
    self.m_skeleton:setScale(0.3)
    self.m_skeleton:setPosition(pos)
    self.m_skeleton:addTo(self, 0)
    self.m_skeleton:PlayAni("stand", true, false)
  end
end
function EditorUILayer:onTouchEnded(_pos)
  if self.m_skeleton then
    self.m_skeleton:removeFromParent()
    self.m_skeleton = nil
  end
end
function EditorUILayer:ActiveFocus()
  self.m_isActive = true
end
function EditorUILayer:InactiveFocus()
  self.m_isActive = false
end
function EditorUILayer:DoFocus(_pos)
  if self.m_skeleton then
    self.m_skeleton:removeFromParent()
    self.m_skeleton = nil
  end
  if self.m_actorId == 0 then
    return
  end
  local pMap = self:getParent():GetGameMap()
  local mapPos = cc.p(pMap:GetMapPosFromWorldPos(_pos))
  local mapTilePos = pMap:GetTilePosFromPixelPos(mapPos)
  local actor = self:CreateActor(self.m_actorId, mapPos)
  table.insert(self.m_vMonsters, actor)
end
return EditorUILayer
