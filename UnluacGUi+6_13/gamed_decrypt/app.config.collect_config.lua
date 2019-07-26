local collect_config = {}
collect_config.Items = {
  [1] = {
    {
      {itemId = 20105, max = 5},
      {itemId = 20112, max = 5}
    },
    {
      {itemId = 20105, max = 5},
      {itemId = 20112, max = 5},
      {itemId = 20106, max = 5}
    },
    {
      {itemId = 20105, max = 10},
      {itemId = 20112, max = 10},
      {itemId = 20106, max = 10}
    }
  },
  [2] = {
    {
      {itemId = 20102, max = 5},
      {itemId = 20103, max = 5}
    },
    {
      {itemId = 20102, max = 5},
      {itemId = 20103, max = 5},
      {itemId = 20104, max = 5}
    },
    {
      {itemId = 20102, max = 10},
      {itemId = 20103, max = 10},
      {itemId = 20104, max = 10}
    }
  },
  [3] = {
    {
      {itemId = 20118, max = 5},
      {itemId = 20003, max = 5}
    },
    {
      {itemId = 20118, max = 5},
      {itemId = 20003, max = 5},
      {itemId = 20113, max = 5}
    },
    {
      {itemId = 20118, max = 10},
      {itemId = 20003, max = 10},
      {itemId = 20113, max = 10}
    }
  }
}
collect_config.MissionIds = {
  [1] = {
    6001,
    6004,
    6007
  },
  [2] = {
    6002,
    6005,
    6008
  },
  [3] = {
    6003,
    6006,
    6009
  }
}
return collect_config
