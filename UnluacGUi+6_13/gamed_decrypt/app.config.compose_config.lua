local compose_config = {
  [20107] = {itemId = 20108, num = 10},
  [20108] = {itemId = 20109, num = 5},
  [20109] = {itemId = 20110, num = 5}
}
function GetComposeConfig(id)
  return clone(compose_config[id])
end
