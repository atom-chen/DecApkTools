local CSVLoader = {}
function CSVLoader.getLines(_path)
  local data = cc.FileUtils:getInstance():getStringFromFile(_path)
  local dataLines = string.split(data, "\n")
  local count = #dataLines
  if dataLines[count] == "" then
    table.remove(dataLines)
    count = count - 1
  end
  return dataLines, count
end
function CSVLoader.getValues(line)
  local count = 0
  local values = {}
  if line ~= nil then
    while string.find(line, ",") ~= nil do
      local i, j = string.find(line, ",")
      count = count + 1
      values[count] = string.sub(line, 1, j - 1)
      line = string.sub(line, j + 1, string.len(line))
    end
    count = count + 1
    values[count] = line
  end
  return values, count
end
function CSVLoader.loadCSV(_fileName)
  local result = {}
  local path = cc.FileUtils:getInstance():fullPathForFilename(_fileName)
  local lines, lineCount = CSVLoader.getLines(path)
  if lineCount < 3 then
    return result
  end
  local keys, colCount = CSVLoader.getValues(lines[1])
  local types = CSVLoader.getValues(lines[2])
  local count = 0
  for i = 3, lineCount do
    count = count + 1
    local record = {}
    local values = CSVLoader.getValues(lines[i])
    for j = 1, colCount do
      if types[j] == "char" then
        record[keys[j]] = values[j]
      else
        record[keys[j]] = tonumber(values[j])
      end
    end
    result[count] = record
  end
  return result
end
return CSVLoader
