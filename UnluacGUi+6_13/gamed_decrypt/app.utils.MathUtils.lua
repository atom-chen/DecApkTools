function IsIn2Point(pos, pos1, pos2)
  local dis1 = cc.pGetDistance(pos, pos2)
  local dis2 = cc.pGetDistance(pos1, pos2)
  if dis1 <= dis2 then
    return true
  end
  return false
end
function IsCircleAndEllipseCross(x1, y1, r1, r2, x2, y2, radius)
  if math.abs(x2 - x1) > r1 + radius or math.abs(y2 - y1) > r2 + radius then
    return false
  end
  local xTemp, yTemp
  if y1 ~= y2 then
    local angle = math.atan((x1 - x2) / (y1 - y2))
    xTemp = radius * math.sin(angle)
    yTemp = radius * math.cos(angle)
  else
    xTemp = radius
    yTemp = 0
  end
  if x1 < x2 then
    xTemp = math.abs(xTemp) * -1
    if y1 < y2 then
      yTemp = math.abs(yTemp) * -1
    elseif y2 < y1 then
      yTemp = math.abs(yTemp)
    end
  elseif x2 < x1 then
    xTemp = math.abs(xTemp)
    if y1 < y2 then
      yTemp = math.abs(yTemp) * -1
    elseif y2 < y1 then
      yTemp = math.abs(yTemp)
    end
  elseif y1 < y2 then
    yTemp = math.abs(yTemp) * -1
  else
    yTemp = math.abs(yTemp)
  end
  local xCross = x2 + xTemp
  local yCross = y2 + yTemp
  local fTemp = r2 * math.sqrt(1 - (xCross - x1) * (xCross - x1) / (r1 * r1))
  local fMin = fTemp * -1 + y1
  local fMax = fTemp + y1
  if yCross >= fMin and yCross <= fMax then
    return true
  end
  return false
end
function IsInEllipse(x, y, r1, r2, pos)
  if r1 < math.abs(x - pos.x) or r2 < math.abs(y - pos.y) then
    return false
  end
  local fTemp = r2 * math.sqrt(1 - (pos.x - x) * (pos.x - x) / (r1 * r1))
  if fTemp >= math.abs(pos.y - y) then
    return true
  end
  return false
end
function IsRectCross(rect1, rect2)
  local minX = math.max(rect1.x, rect2.x)
  local minY = math.max(rect1.y, rect2.y)
  local maxX = math.min(rect1.x + rect1.width, rect2.x + rect2.width)
  local maxY = math.min(rect1.y + rect1.height, rect2.y + rect2.height)
  if minX > maxX or minY > maxY then
    return false
  end
  return true
end
function IsRectAndCircleCross(x1, y1, r, x2, y2, width, height)
  local function PointInCircle(pos)
    return (pos.x - x1) * (pos.x - x1) + (pos.y - y1) * (pos.y - y1) <= r * r
  end
  if PointInCircle(cc.p(x2, y2 + height)) then
    return true
  end
  if PointInCircle(cc.p(x2, y2)) then
    return true
  end
  if PointInCircle(cc.p(x2 + width, y2)) then
    return true
  end
  if PointInCircle(cc.p(x2 + width, y2 + height)) then
    return true
  end
  if y2 <= y1 and y1 <= y2 + height then
    if x1 <= x2 then
      return r >= math.abs(x1 - x2)
    end
    if x1 >= x2 + width then
      return r >= math.abs(x2 + width - x1)
    end
  end
  if x2 <= x1 and x1 <= x2 + width then
    if y1 <= y2 then
      return r >= math.abs(y1 - y2)
    end
    if y1 >= y2 + height then
      return r >= math.abs(y2 + height - y1)
    end
  end
  return false
end
function GetMinCountForPath(path, pos)
  if not path or #path == 0 then
    return 0
  end
  local minDis = 1000000
  local minCount = 0
  for i, v in ipairs(path) do
    local dis = cc.pGetDistance(v, pos)
    if minDis > dis then
      minDis = dis
      minCount = i
      if minDis == 0 then
        return minCount
      end
    end
  end
  return minCount
end
function GetAzimuth(base, target)
  local angle = 0
  if base.x == target.x then
    if base.y > target.y then
      angle = -90
    else
      angle = 90
    end
  else
    local dir = cc.pSub(target, base)
    local radian = math.atan((target.y - base.y) / (target.x - base.x))
    angle = math.deg(radian)
    if base.x > target.x then
      angle = 180 + angle
    end
  end
  return -angle
end
