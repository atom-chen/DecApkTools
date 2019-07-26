local EffectConfig = {
  [1] = {
    id = 1,
    type = 0,
    name = "\229\183\168\228\186\186\228\185\139\229\137\145",
    file = "Spine/skill/jurenzhijian_01",
    overRemove = true,
    scale = 1.2,
    zType = 2,
    attrs = {
      {
        type = 4,
        timeNext = 0,
        placeType = 0,
        x = 0,
        y = 1000
      },
      {
        type = 3,
        timeNext = 0,
        animation = "jurenzhijian_01",
        loop = true
      },
      {
        type = 0,
        timeNext = -1,
        moveType = 0,
        speed = 2500
      },
      {type = 2, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 501,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "jurenzhijian_02",
        loop = false
      }
    }
  },
  [2] = {
    id = 2,
    type = 1,
    name = "\232\135\170\232\181\176\231\130\174\231\131\159\233\155\190",
    file = "Effect/paodanyanwu",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [3] = {
    id = 3,
    type = 0,
    name = "\229\159\186\229\156\176\230\148\187\229\135\187\232\147\132\229\138\155",
    file = "Spine/skill/EFT_zhujigongji_01",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "EFT_zhujigongji_01",
        loop = false
      }
    }
  },
  [4] = {
    id = 4,
    type = 0,
    name = "\229\159\186\229\156\176\230\148\187\229\135\187\233\151\170\231\148\181",
    file = "Spine/skill/EFT_zhujigongji_02",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "EFT_zhujigongji_02",
        loop = false
      },
      {type = 1, timeNext = -1}
    }
  },
  [5] = {
    id = 5,
    type = 2,
    name = "\232\135\170\232\181\176\231\130\174\229\188\185\233\129\147",
    file = "#Effect/EFT_paodan_01",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 2,
        zorder = -1,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 8,
        timeNext = -1,
        fixedType = 0,
        value = 0.7,
        rotate = true,
        randX = 50,
        randY = 50
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = 0},
      {
        type = 2,
        timeNext = 0,
        damage = 50
      },
      {
        type = 14,
        timeNext = -1,
        newID = 6
      }
    }
  },
  [6] = {
    id = 6,
    type = 3,
    name = "\232\135\170\232\181\176\231\130\174\231\136\134\231\130\184",
    file = "Effect/baozha",
    overRemove = true,
    scale = 1.4,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "Effect/baozha",
        loop = false,
        frames = 9
      },
      {type = 10, timeNext = 0.1},
      {
        type = 14,
        timeNext = -1,
        newID = 12
      }
    }
  },
  [7] = {
    id = 7,
    type = 2,
    name = "\229\188\185\229\185\149\229\176\132\229\135\187",
    file = "#Effect/EFT_mjzdandao_02",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 37,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 209,
        loop = true
      },
      {
        type = 0,
        timeNext = -1,
        moveType = 0,
        speed = 500,
        rotate = true,
        tag = 1
      },
      {
        type = 12,
        timeNext = -1,
        speed = 290,
        radius = 100,
        rotate = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true,
        refind = true
      },
      {type = 31, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 210,
        loop = false
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = 0},
      {
        type = 2,
        timeNext = 0,
        damage = 50
      },
      {
        type = 14,
        timeNext = -1,
        newID = 6
      }
    }
  },
  [8] = {
    id = 8,
    type = 0,
    name = "\229\142\159\229\138\155\231\139\130\230\128\146",
    file = "Spine/skill/EFT_yuanlikuangnu_01",
    overRemove = true,
    scale = 0.7,
    members = {
      {
        id = 10,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      },
      {
        id = 11,
        zorder = -2,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 4,
        timeNext = 0,
        placeType = 0,
        x = -400,
        y = 800
      },
      {type = 10, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 504,
        loop = false
      },
      {
        type = 3,
        timeNext = 0,
        animation = "EFT_yuanlikuangnu_01",
        loop = true
      },
      {
        type = 0,
        timeNext = -1,
        moveType = 0,
        speed = 600,
        rotate = true
      },
      {
        type = 14,
        timeNext = -1,
        newID = 9
      },
      {
        type = 2,
        timeNext = -1,
        width = 100,
        height = 100
      }
    }
  },
  [9] = {
    id = 9,
    type = 3,
    name = "\229\142\159\229\138\155\231\139\130\230\128\146\231\136\134\231\130\184",
    file = "Effect/baozha",
    overRemove = true,
    scale = 2,
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 505,
        loop = false
      },
      {
        type = 3,
        timeNext = 0,
        animation = "Effect/baozha",
        loop = false,
        frames = 9
      },
      {type = 10, timeNext = 0.1},
      {
        type = 14,
        timeNext = -1,
        newID = 12
      }
    }
  },
  [10] = {
    id = 10,
    type = 1,
    name = "\229\142\159\229\138\155\231\139\130\230\128\146\231\129\171\230\152\159",
    file = "Effect/huoxing_01",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [11] = {
    id = 11,
    type = 1,
    name = "\229\142\159\229\138\155\231\139\130\230\128\146\231\131\159\233\155\190",
    file = "Effect/yanwu_01",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [12] = {
    id = 12,
    type = 2,
    name = "\231\136\134\231\130\184\230\174\139\231\149\153",
    file = "#Effect/dimian",
    overRemove = true,
    scale = 1,
    zType = 1,
    attrs = {
      {type = 10, timeNext = 5},
      {
        type = 5,
        timeNext = -1,
        time = 1,
        fromOpacity = 255,
        toOpacity = 0
      }
    }
  },
  [13] = {
    id = 13,
    type = 2,
    name = "\230\160\184\231\136\134\231\158\132\229\135\134",
    file = "#Effect/EFT_paodan_01",
    overRemove = true,
    scale = 0.75,
    attrs = {}
  },
  [14] = {
    id = 14,
    type = 2,
    name = "\230\160\184\231\136\134\230\160\184\229\188\185",
    file = "#Effect/EFT_paodan_01",
    overRemove = true,
    scale = 0.5,
    members = {
      {
        id = 2,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 13,
        timeNext = -1,
        speed = 600,
        rotate = true
      }
    }
  },
  [15] = {
    id = 15,
    type = 0,
    name = "\231\187\183\229\184\166\231\154\132\231\131\159\233\155\190",
    file = "Spine/skill/EFT_shuangzinan_01",
    overRemove = true,
    scale = 0.55,
    zType = 2,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      },
      {type = 10, timeNext = 0.1},
      {
        type = 14,
        timeNext = -1,
        newID = 16,
        inherit = true,
        zorder = -1
      }
    }
  },
  [16] = {
    id = 16,
    type = 0,
    name = "\231\187\183\229\184\166\231\154\132\231\187\183\229\184\166",
    file = "Spine/skill/EFT_shuangzinan_02",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      },
      {type = 10, timeNext = 1.7},
      {
        type = 14,
        timeNext = -1,
        newID = 17
      }
    }
  },
  [17] = {
    id = 17,
    type = 0,
    name = "\231\187\183\229\184\166\231\154\132\231\136\134\231\130\184",
    file = "Spine/skill/EFT_shuangzinan_03",
    overRemove = true,
    scale = 1.2,
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 308,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [18] = {
    id = 18,
    type = 0,
    name = "\229\131\181\229\176\184\229\164\141\231\148\159",
    file = "Spine/skill/EFT_shuangzinv_01",
    overRemove = true,
    scale = 1.5,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [19] = {
    id = 19,
    type = 2,
    name = "Lucy\229\188\185\233\129\147",
    file = "#Effect/EFT_lucydandao_01",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 20,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 600,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 21
      },
      {type = 1, timeNext = -1}
    }
  },
  [20] = {
    id = 20,
    type = 1,
    name = "Lucy\229\188\185\233\129\147\230\139\150\229\176\190",
    file = "Effect/lucytrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [21] = {
    id = 21,
    type = 0,
    name = "Lucy\229\188\185\233\129\147\229\143\151\229\135\187",
    file = "Spine/skill/EFT_lucybeiji_01",
    overRemove = true,
    scale = 0.4,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [22] = {
    id = 22,
    type = 2,
    name = "\230\179\149\229\184\136\229\188\185\233\129\147",
    file = "#Effect/EFT_xuetudandao_01",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 23,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 400,
        rotate = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 400,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 24
      },
      {type = 1, timeNext = -1}
    }
  },
  [23] = {
    id = 23,
    type = 1,
    name = "\230\179\149\229\184\136\229\188\185\233\129\147\230\139\150\229\176\190",
    file = "Effect/xuetutrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [24] = {
    id = 24,
    type = 0,
    name = "\230\179\149\229\184\136\229\188\185\233\129\147\229\143\151\229\135\187",
    file = "Spine/skill/EFT_xuetubeiji_01",
    overRemove = true,
    scale = 0.3,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [25] = {
    id = 25,
    type = 2,
    name = "\229\134\176\230\179\149\229\188\185\233\129\147",
    file = "#Effect/EFT_nvwudandao_01",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 26,
        zorder = -1,
        x = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 27
      },
      {
        type = 1,
        timeNext = -1,
        damage = 100
      }
    }
  },
  [26] = {
    id = 26,
    type = 1,
    name = "\229\134\176\230\179\149\229\188\185\233\129\147\230\139\150\229\176\190",
    file = "Effect/nvwutrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [27] = {
    id = 27,
    type = 0,
    name = "\229\134\176\230\179\149\229\188\185\233\129\147\229\143\151\229\135\187",
    file = "Spine/skill/EFT_nvwubeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [28] = {
    id = 28,
    type = 2,
    name = "\231\129\171\230\179\149\229\188\185\233\129\147",
    file = "#Effect/EFT_xianzhedandao_01",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 29,
        zorder = -1,
        x = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 30
      },
      {
        type = 1,
        timeNext = -1,
        damage = 100
      }
    }
  },
  [29] = {
    id = 29,
    type = 1,
    name = "\231\129\171\230\179\149\229\188\185\233\129\147\230\139\150\229\176\190",
    file = "Effect/xianzhetrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [30] = {
    id = 30,
    type = 0,
    name = "\231\129\171\230\179\149\229\188\185\233\129\147\229\143\151\229\135\187",
    file = "Spine/skill/EFT_xianzhebeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [31] = {
    id = 31,
    type = 2,
    name = "\230\151\160\228\186\186\230\156\186\229\188\185\233\129\147",
    file = "#Effect/EFT_wurenjidandao_01",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 32,
        zorder = -1,
        x = 0,
        y = 0,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 300,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = 0},
      {
        type = 2,
        timeNext = 0,
        damage = 50
      },
      {
        type = 14,
        timeNext = -1,
        newID = 33
      }
    }
  },
  [32] = {
    id = 32,
    type = 1,
    name = "\230\151\160\228\186\186\230\156\186\229\188\185\233\129\147\230\139\150\229\176\190",
    file = "Effect/wurentrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [33] = {
    id = 33,
    type = 0,
    name = "\230\151\160\228\186\186\230\156\186\229\188\185\233\129\147\231\136\134\231\130\184",
    file = "Spine/skill/EFT_wurenjibeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [34] = {
    id = 34,
    type = 2,
    name = "\233\147\182\231\191\188\229\188\185\233\129\147",
    file = "#Effect/EFT_yinyidandao_01",
    overRemove = true,
    scale = 0.8,
    members = {
      {
        id = 35,
        zorder = -1,
        x = 0,
        y = 0,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 700,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = -1},
      {
        type = 14,
        timeNext = -1,
        newID = 36
      }
    }
  },
  [35] = {
    id = 35,
    type = 1,
    name = "\233\147\182\231\191\188\229\188\185\233\129\147\230\139\150\229\176\190",
    file = "Effect/yinyitrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [36] = {
    id = 36,
    type = 0,
    name = "\233\147\182\231\191\188\229\188\185\233\129\147\231\136\134\231\130\184",
    file = "Spine/skill/EFT_yinyibeiji_01",
    overRemove = true,
    scale = 0.3,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [37] = {
    id = 37,
    type = 1,
    name = "\229\188\185\229\185\149\229\176\132\229\135\187\231\131\159\233\155\190",
    file = "Effect/daodanyanwu",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [38] = {
    id = 38,
    type = 1,
    name = "\229\188\185\229\185\149\229\176\132\229\135\187\231\129\171\232\139\151",
    file = "Effect/huomiao",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [39] = {
    id = 39,
    type = 2,
    name = "\229\175\134\233\155\134\233\152\181\229\188\185\233\129\147",
    file = "#Effect/EFT_mjzdandao_01",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 40,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 8,
        timeNext = -1,
        fixedType = 1,
        value = 400,
        rotate = true,
        randX = 50,
        randY = 50
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = 0},
      {
        type = 2,
        timeNext = 0,
        damage = 50
      },
      {
        type = 14,
        timeNext = -1,
        newID = 6
      }
    }
  },
  [40] = {
    id = 40,
    type = 1,
    name = "\229\175\134\233\155\134\233\152\181\229\188\185\233\129\147\231\131\159\233\155\190",
    file = "Effect/daodanyanwu_2",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [41] = {
    id = 41,
    type = 0,
    name = "\230\156\168\228\185\131\228\188\138\231\190\164\230\153\174",
    file = "",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {type = 2, timeNext = -1}
    }
  },
  [42] = {
    id = 42,
    type = 2,
    name = "\230\158\170\229\133\181\229\136\134\230\148\1751\229\188\185\233\129\147",
    file = "#Effect/EFT_bpdsdandao_01",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 1000,
        rotate = true,
        random = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = -1},
      {
        type = 14,
        timeNext = -1,
        newID = 43
      }
    }
  },
  [43] = {
    id = 43,
    type = 2,
    name = "\230\158\170\229\133\181\229\136\134\230\148\1751\229\143\151\229\135\187",
    file = "#Effect/Ty_beiji_01",
    overRemove = true,
    scale = 0.01,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 18,
        timeNext = -1,
        scaleType = 1,
        time = 0.1,
        x = 0.5
      },
      {
        type = 18,
        timeNext = -1,
        scaleType = 1,
        time = 0.06,
        x = 0.7
      },
      {
        type = 5,
        timeNext = -1,
        time = 0.06,
        fromOpacity = 255,
        toOpacity = 0
      }
    }
  },
  [44] = {
    id = 44,
    type = 2,
    name = "\230\158\170\229\133\181\229\136\134\230\148\1752\229\188\185\233\129\147",
    file = "#Effect/EFT_jujidandao_01",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 1200,
        rotate = true,
        random = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = -1},
      {
        type = 14,
        timeNext = -1,
        newID = 45
      }
    }
  },
  [45] = {
    id = 45,
    type = 0,
    name = "\230\158\170\229\133\181\229\136\134\230\148\1752\229\143\151\229\135\187",
    file = "Spine/skill/EFT_jujibeiji_01",
    overRemove = true,
    scale = 0.6,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [46] = {
    id = 46,
    type = 2,
    name = "\230\158\170\229\133\181\229\188\185\233\129\147",
    file = "#Effect/EFT_shibingdandao_01",
    overRemove = true,
    scale = 0.55,
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 1000,
        rotate = true,
        random = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = -1},
      {
        type = 14,
        timeNext = -1,
        newID = 47
      }
    }
  },
  [47] = {
    id = 47,
    type = 2,
    name = "\230\158\170\229\133\181\229\143\151\229\135\187",
    file = "#Effect/Ty_beiji_01",
    overRemove = true,
    scale = 0.01,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 18,
        timeNext = -1,
        scaleType = 1,
        time = 0.1,
        x = 0.5
      },
      {
        type = 18,
        timeNext = 0,
        scaleType = 1,
        time = 0.06,
        x = 0.7
      },
      {
        type = 5,
        timeNext = -1,
        time = 0.06,
        fromOpacity = 255,
        toOpacity = 0
      }
    }
  },
  [48] = {
    id = 48,
    type = 0,
    name = "\229\164\169\228\189\191\229\188\185\233\129\147",
    file = "Spine/skill/EFT_anqierdandao_01",
    overRemove = true,
    scale = 0.25,
    members = {
      {
        id = 49,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 50
      },
      {type = 1, timeNext = -1}
    }
  },
  [49] = {
    id = 49,
    type = 1,
    name = "\229\164\169\228\189\191\230\139\150\229\176\190",
    file = "Effect/angeltrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [50] = {
    id = 50,
    type = 0,
    name = "\229\164\169\228\189\191\229\143\151\229\135\187",
    file = "Spine/skill/EFT_anqierbeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [51] = {
    id = 51,
    type = 0,
    name = "\229\164\169\228\189\191\229\136\134\230\148\1751\229\188\185\233\129\147",
    file = "Spine/skill/EFT_jiabailiedandao_01",
    overRemove = true,
    scale = 0.3,
    members = {
      {
        id = 52,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 600,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 53
      },
      {type = 1, timeNext = -1}
    }
  },
  [52] = {
    id = 52,
    type = 1,
    name = "\229\164\169\228\189\191\229\136\134\230\148\1751\230\139\150\229\176\190",
    file = "Effect/jiabailietrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [53] = {
    id = 53,
    type = 0,
    name = "\229\164\169\228\189\191\229\136\134\230\148\1751\229\143\151\229\135\187",
    file = "Spine/skill/EFT_jiabailiebeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [54] = {
    id = 54,
    type = 2,
    name = "\229\164\169\228\189\191\229\136\134\230\148\1752\229\188\185\233\129\147",
    file = "#Effect/EFT_mijialedandao_01",
    overRemove = true,
    scale = 0.55,
    members = {
      {
        id = 55,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 700,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 56
      },
      {type = 1, timeNext = -1}
    }
  },
  [55] = {
    id = 55,
    type = 1,
    name = "\229\164\169\228\189\191\229\136\134\230\148\1752\230\139\150\229\176\190",
    file = "Effect/mijialetrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [56] = {
    id = 56,
    type = 0,
    name = "\229\164\169\228\189\191\229\136\134\230\148\1752\229\143\151\229\135\187",
    file = "Spine/skill/EFT_mijialebeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [57] = {
    id = 57,
    type = 0,
    name = "\232\191\158\229\143\145\230\158\170\229\143\163\231\137\185\230\149\136",
    file = "Spine/skill/EFT_qianghuo_01",
    overRemove = false,
    scale = 1,
    bone = "bone_shoot",
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [58] = {
    id = 58,
    type = 0,
    name = "\229\141\149\229\143\145\230\158\170\229\143\163\231\137\185\230\149\136",
    file = "Spine/skill/EFT_jujiqianghuo_01",
    overRemove = true,
    scale = 1,
    bone = "bone_shoot",
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [59] = {
    id = 59,
    type = 2,
    name = "\233\151\170\229\133\137\229\188\185\229\188\185\233\129\147",
    file = "#Effect/EFT_shanguangdan_01",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 15,
        timeNext = 0,
        rotateType = 3,
        angle = 0,
        speed = 500
      },
      {
        type = 8,
        timeNext = -1,
        fixedType = 1,
        value = 400
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = -1},
      {
        type = 14,
        timeNext = -1,
        newID = 60
      }
    }
  },
  [60] = {
    id = 60,
    type = 0,
    name = "\233\151\170\229\133\137\229\188\185\231\136\134\231\130\184",
    file = "Spine/skill/EFT_shanguangdan_02",
    overRemove = true,
    scale = 1.3,
    members = {
      {
        id = 61,
        zorder = 1,
        x = 0,
        y = 50,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [61] = {
    id = 61,
    type = 1,
    name = "\233\151\170\229\133\137\229\188\185\230\152\159\230\152\159",
    file = "Effect/flashbomb",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [62] = {
    id = 62,
    type = 0,
    name = "\229\164\169\228\189\191\230\178\187\230\132\136\232\191\158\231\186\191",
    file = "Spine/skill/EFT_zhiliaobo_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 16,
        timeNext = 0,
        baseBone = "bone_beiji",
        targetBone = "bone_beiji",
        offset = 20
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {type = 10, timeNext = 0.25}
    }
  },
  [63] = {
    id = 63,
    type = 0,
    name = "\230\160\184\230\137\147\229\135\187\231\158\132\229\135\134",
    file = "Spine/skill/EFT_guidaopao_01",
    overRemove = true,
    scale = 1,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      },
      {type = 1, timeNext = -1},
      {
        type = 14,
        timeNext = -1,
        newID = 64
      }
    }
  },
  [64] = {
    id = 64,
    type = 0,
    name = "\230\160\184\230\137\147\229\135\187\231\136\134\231\130\184",
    file = "Spine/skill/EFT_guidaopao_02",
    overRemove = true,
    scale = 1.2,
    bone = "root",
    attrs = {
      {
        type = 4,
        timeNext = 0,
        placeType = 0,
        x = 0,
        y = 400
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      },
      {
        type = 0,
        timeNext = -1,
        moveType = 0,
        speed = 2400
      }
    }
  },
  [65] = {
    id = 65,
    type = 0,
    name = "\229\152\178\232\174\189\229\133\137\230\149\136",
    file = "Spine/skill/EFT_chaofeng_01",
    overRemove = true,
    scale = 1.2,
    bone = "bone_beiji",
    attrs = {
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 10, timeNext = 0.5},
      {
        type = 9,
        timeNext = -1,
        visible = true
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [66] = {
    id = 66,
    type = 0,
    name = "\229\143\152\231\190\138\229\133\137\230\149\136",
    file = "Spine/skill/EFT_bianyang_01",
    overRemove = true,
    scale = 0.8,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [67] = {
    id = 67,
    type = 0,
    name = "\229\134\176\230\179\149\229\188\185\233\129\1472",
    file = "Spine/skill/EFT_nvwudandao_02",
    overRemove = true,
    scale = 0.5,
    members = {
      {
        id = 26,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 192
      },
      {
        type = 30,
        timeNext = 0,
        sound = 215,
        loop = false
      },
      {type = 2, timeNext = -1}
    }
  },
  [68] = {
    id = 68,
    type = 0,
    name = "\231\129\171\230\179\149\229\188\185\233\129\1472",
    file = "Spine/skill/EFT_xianzhedandao_02",
    overRemove = true,
    scale = 1.5,
    members = {
      {
        id = 29,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 69
      },
      {
        type = 30,
        timeNext = 0,
        sound = 214,
        loop = false
      },
      {type = 1, timeNext = -1}
    }
  },
  [69] = {
    id = 69,
    type = 0,
    name = "\231\129\171\230\179\149\229\188\185\233\129\147\229\143\151\229\135\1872",
    file = "Spine/skill/EFT_xianzhebeiji_02",
    overRemove = true,
    scale = 0.7,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [70] = {
    id = 70,
    type = 0,
    name = "\231\148\159\229\140\150\231\148\181\231\189\145",
    file = "Spine/skill/EFT_shenghuadianwang_01",
    overRemove = true,
    scale = 1.2,
    zType = 2,
    attrs = {
      {
        type = 4,
        timeNext = 0,
        placeType = 0,
        x = 0,
        y = 1000
      },
      {
        type = 3,
        timeNext = 0,
        animation = "shenghuadianwang_01",
        loop = true
      },
      {
        type = 0,
        timeNext = -1,
        moveType = 0,
        speed = 2500
      },
      {type = 2, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 502,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "shenghuadianwang_02",
        loop = false
      },
      {
        type = 30,
        timeNext = 0,
        sound = 503,
        loop = true
      },
      {
        type = 3,
        timeNext = 0,
        animation = "shenghuadianwang_03",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 2,
        overType = 1,
        value = 5
      },
      {type = 31, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 515,
        loop = false
      }
    }
  },
  [71] = {
    id = 71,
    type = 0,
    name = "\230\178\188\230\179\189\230\162\166\233\173\135",
    file = "Spine/skill/EFT_zhaozemengyan_01",
    overRemove = true,
    scale = 2,
    zType = 1,
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 512,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_01",
        loop = false
      },
      {type = 2, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 513,
        loop = true
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_02",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 2,
        overType = 1,
        value = 10
      },
      {type = 31, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 514,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_03",
        loop = false
      }
    }
  },
  [72] = {
    id = 72,
    type = 0,
    name = "\230\150\173\231\189\170\229\174\161\229\136\164",
    file = "Spine/skill/EFT_duanzuishenpan_01",
    overRemove = true,
    scale = 1.5,
    zType = 2,
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 508,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_01",
        loop = false
      },
      {type = 2, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 516,
        loop = true
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_02",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 0,
        overType = 1,
        value = 20
      },
      {type = 31, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 517,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_03",
        loop = false
      }
    }
  },
  [73] = {
    id = 73,
    type = 0,
    name = "\229\142\159\229\138\155\229\155\190\232\133\190",
    file = "Spine/skill/EFT_yuanlituteng_01",
    overRemove = true,
    scale = 1.4,
    zType = 2,
    attrs = {
      {
        type = 14,
        timeNext = 0,
        newID = 165
      },
      {
        type = 30,
        timeNext = 0,
        sound = 509,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_01",
        loop = false
      },
      {type = 2, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 510,
        loop = true
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_02",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 1,
        value = 20
      },
      {type = 31, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 511,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_03",
        loop = false
      }
    }
  },
  [74] = {
    id = 74,
    type = 0,
    name = "\229\142\159\229\138\155\229\155\190\232\133\1902",
    file = "Spine/skill/EFT_yuanlituteng_01",
    overRemove = true,
    scale = 1.4,
    zType = 2,
    members = {
      {
        id = 75,
        zorder = 1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 14,
        timeNext = 0,
        newID = 165
      },
      {
        type = 30,
        timeNext = 0,
        sound = 509,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_01",
        loop = false
      },
      {type = 2, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 510,
        loop = true
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_02",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 1,
        value = 20
      },
      {type = 31, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 511,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_03",
        loop = false
      }
    }
  },
  [75] = {
    id = 75,
    type = 1,
    name = "\229\142\159\229\138\155\229\155\190\232\133\1902\231\178\146\229\173\144",
    file = "Effect/bling",
    overRemove = false,
    scale = 1.5,
    attrs = {}
  },
  [76] = {
    id = 76,
    type = 0,
    name = "\230\158\129\229\175\146\230\152\159\232\190\176",
    file = "Spine/skill/EFT_jihanxingchen_01",
    overRemove = true,
    scale = 1.15,
    zType = 2,
    members = {
      {
        id = 77,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 507,
        loop = false
      },
      {
        type = 4,
        timeNext = 0,
        placeType = 0,
        x = 0,
        y = 1000
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation_01",
        loop = true
      },
      {
        type = 0,
        timeNext = -1,
        moveType = 0,
        speed = 1600,
        acc = -850
      },
      {type = 2, timeNext = 0},
      {
        type = 3,
        timeNext = -1,
        animation = "animation_02",
        loop = false
      }
    }
  },
  [77] = {
    id = 77,
    type = 1,
    name = "\230\158\129\229\175\146\230\152\159\232\190\176\231\178\146\229\173\144",
    file = "Effect/jihantrail",
    overRemove = false,
    scale = 1.2,
    attrs = {}
  },
  [78] = {
    id = 78,
    type = 2,
    name = "\230\175\146\230\182\178\229\188\185\233\129\147",
    file = "#Effect/EFT_dfdandao_01",
    overRemove = true,
    scale = 0.6,
    attrs = {
      {
        type = 8,
        timeNext = -1,
        fixedType = 1,
        value = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 80
      },
      {type = 1, timeNext = -1}
    }
  },
  [79] = {
    id = 79,
    type = 1,
    name = "\230\175\146\230\182\178\230\139\150\229\176\190",
    file = "Effect/duyetrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [80] = {
    id = 80,
    type = 0,
    name = "\230\175\146\230\182\178\231\136\134\231\130\184",
    file = "Spine/skill/EFT_dfbeiji_01",
    overRemove = true,
    scale = 0.3,
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 601,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [81] = {
    id = 81,
    type = 0,
    name = "\230\129\182\233\173\148\229\165\179\229\188\185\233\129\1471",
    file = "Spine/skill/EFT_gjfadandao_01",
    overRemove = true,
    scale = 0.2,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 82
      },
      {type = 1, timeNext = -1}
    }
  },
  [82] = {
    id = 82,
    type = 0,
    name = "\230\129\182\233\173\148\229\165\179\229\143\151\229\135\187",
    file = "Spine/skill/EFT_dffsbeiji_01",
    overRemove = true,
    scale = 0.3,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [83] = {
    id = 83,
    type = 0,
    name = "\233\146\162\233\147\129\232\139\141\231\169\185\233\163\158\232\137\135",
    file = "Spine/skill/EFT_GangTieCangQiong_01",
    overRemove = false,
    scale = 0.1,
    zType = 1,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 30,
        timeNext = 0,
        sound = 506,
        loop = false
      }
    }
  },
  [84] = {
    id = 84,
    type = 2,
    name = "\233\163\158\232\137\135\229\188\185\233\129\147",
    file = "#Effect/laser",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 10,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = false,
        delayRemove = 0
      }
    },
    attrs = {
      {
        type = 4,
        timeNext = 0,
        placeType = 0,
        x = 0,
        y = 1500
      },
      {
        type = 18,
        timeNext = 0,
        scaleType = 0,
        time = 0.35,
        x = 2,
        y = 1
      },
      {
        type = 0,
        timeNext = -1,
        moveType = 0,
        speed = 2500,
        rotate = true
      },
      {
        type = 18,
        timeNext = -1,
        scaleType = 0,
        time = 0.1,
        x = 0,
        y = 1
      },
      {
        type = 9,
        timeNext = 0,
        visible = false
      },
      {
        type = 14,
        timeNext = 0,
        newID = 85
      },
      {
        type = 2,
        timeNext = 0,
        width = 100,
        height = 100
      }
    }
  },
  [85] = {
    id = 85,
    type = 0,
    name = "\233\163\158\232\137\135\231\130\174\231\136\134\231\130\184",
    file = "Spine/skill/EFT_GangTieCangQiong_02",
    overRemove = true,
    scale = 1,
    zType = 2,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [86] = {
    id = 86,
    type = 0,
    name = "\230\129\182\233\173\148\229\165\179\229\188\185\233\129\1472",
    file = "Spine/skill/EFT_gjfadandao_02",
    overRemove = true,
    scale = 0.35,
    members = {
      {
        id = 87,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 82
      },
      {type = 1, timeNext = -1}
    }
  },
  [87] = {
    id = 87,
    type = 1,
    name = "\230\129\182\233\173\148\229\165\179\230\139\150\229\176\190",
    file = "Effect/evilnvtrail",
    overRemove = false,
    scale = 1,
    bone = "bone_beiji",
    attrs = {}
  },
  [88] = {
    id = 88,
    type = 2,
    name = "\230\175\146\230\182\178\229\188\185\233\129\1472",
    file = "#Effect/EFT_dfdandao_01",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 79,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 8,
        timeNext = -1,
        fixedType = 1,
        value = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 80
      },
      {type = 1, timeNext = -1}
    }
  },
  [89] = {
    id = 89,
    type = 2,
    name = "\229\183\161\233\128\187\230\128\170\230\179\149\229\184\136\229\188\185\233\129\147",
    file = "#Effect/EFT_xunluodandao_01",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 90
      },
      {type = 1, timeNext = -1}
    }
  },
  [90] = {
    id = 90,
    type = 0,
    name = "\229\183\161\233\128\187\230\128\170\230\179\149\229\184\136\229\143\151\229\135\187",
    file = "Spine/skill/EFT_xunluobeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [91] = {
    id = 91,
    type = 0,
    name = "\230\129\182\233\173\148\229\165\179\229\188\185\233\129\1473",
    file = "Spine/skill/EFT_gjfadandao_02",
    overRemove = true,
    scale = 0.45,
    members = {
      {
        id = 87,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 82
      },
      {type = 1, timeNext = -1}
    }
  },
  [92] = {
    id = 92,
    type = 2,
    name = "47\229\188\185\233\129\147",
    file = "#Effect/EFT_47dandao_01",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 1000,
        rotate = true,
        random = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = -1},
      {
        type = 14,
        timeNext = -1,
        newID = 93
      }
    }
  },
  [93] = {
    id = 93,
    type = 0,
    name = "47\229\143\151\229\135\187",
    file = "Spine/skill/EFT_47beiji_01",
    overRemove = true,
    scale = 0.4,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [94] = {
    id = 94,
    type = 0,
    name = "\230\129\182\233\173\148\231\148\183\229\188\185\233\129\1471",
    file = "Spine/skill/EFT_dfndandao_01",
    overRemove = true,
    scale = 0.35,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 96
      },
      {type = 1, timeNext = -1}
    }
  },
  [95] = {
    id = 95,
    type = 1,
    name = "\230\129\182\233\173\148\231\148\183\230\139\150\229\176\190",
    file = "Effect/evilnantrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [96] = {
    id = 96,
    type = 0,
    name = "\230\129\182\233\173\148\231\148\183\229\143\151\229\135\187",
    file = "Spine/skill/EFT_dfnbeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [97] = {
    id = 97,
    type = 0,
    name = "\230\129\182\233\173\148\231\148\183\229\188\185\233\129\1472",
    file = "Spine/skill/EFT_dfndandao_01",
    overRemove = true,
    scale = 0.5,
    members = {
      {
        id = 95,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 96
      },
      {type = 1, timeNext = -1}
    }
  },
  [98] = {
    id = 98,
    type = 0,
    name = "\230\129\182\233\173\148\231\148\183\229\188\185\233\129\1473",
    file = "Spine/skill/EFT_dfndandao_01",
    overRemove = true,
    scale = 0.6,
    members = {
      {
        id = 95,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 96
      },
      {type = 1, timeNext = -1}
    }
  },
  [99] = {
    id = 99,
    type = 0,
    name = "\231\191\133\232\134\128\230\128\170\229\188\185\233\129\1471",
    file = "Spine/skill/EFT_dffxdandao_01",
    overRemove = true,
    scale = 0.55,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 101
      },
      {type = 1, timeNext = -1}
    }
  },
  [100] = {
    id = 100,
    type = 1,
    name = "\231\191\133\232\134\128\230\128\170\230\139\150\229\176\190",
    file = "Effect/chibangtrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [101] = {
    id = 101,
    type = 0,
    name = "\231\191\133\232\134\128\230\128\170\229\143\151\229\135\187",
    file = "Spine/skill/EFT_dffxbeiji_01",
    overRemove = true,
    scale = 0.4,
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 602,
        loop = false
      },
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [102] = {
    id = 102,
    type = 0,
    name = "\231\191\133\232\134\128\230\128\170\229\188\185\233\129\1472",
    file = "Spine/skill/EFT_dffxdandao_01",
    overRemove = false,
    scale = 0.7,
    members = {
      {
        id = 100,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 14,
        timeNext = -1,
        newID = 101
      },
      {type = 1, timeNext = -1}
    }
  },
  [103] = {
    id = 103,
    type = 0,
    name = "\233\163\158\230\156\186\230\128\170\229\188\185\233\129\1471",
    file = "Spine/skill/EFT_dffxjxdandao_01",
    overRemove = true,
    scale = 0.2,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 600,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 105
      },
      {type = 1, timeNext = -1}
    }
  },
  [104] = {
    id = 104,
    type = 1,
    name = "\233\163\158\230\156\186\230\128\170\230\139\150\229\176\190",
    file = "Effect/feijiguaitrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [105] = {
    id = 105,
    type = 0,
    name = "\233\163\158\230\156\186\230\128\170\229\143\151\229\135\187",
    file = "Spine/skill/EFT_dffxjxbeiji_01",
    overRemove = true,
    scale = 0.4,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [106] = {
    id = 106,
    type = 0,
    name = "\233\163\158\230\156\186\230\128\170\229\188\185\233\129\1472",
    file = "Spine/skill/EFT_dffxjxdandao_01",
    overRemove = true,
    scale = 0.3,
    members = {
      {
        id = 104,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 600,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 105
      },
      {type = 1, timeNext = -1}
    }
  },
  [107] = {
    id = 107,
    type = 0,
    name = "\231\180\171\231\130\174\230\128\170\229\188\185\233\129\1471",
    file = "Spine/skill/EFT_Djxycdandao_01",
    overRemove = true,
    scale = 0.2,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 700,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 109
      },
      {type = 1, timeNext = -1}
    }
  },
  [109] = {
    id = 109,
    type = 0,
    name = "\231\180\171\231\130\174\230\128\170\229\143\151\229\135\187",
    file = "Spine/skill/EFT_Djxycbeiji_01",
    overRemove = true,
    scale = 0.35,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [110] = {
    id = 110,
    type = 0,
    name = "\231\180\171\231\130\174\230\128\170\229\188\185\233\129\1472",
    file = "Spine/skill/EFT_Djxycdandao_01",
    overRemove = true,
    scale = 0.3,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 700,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 109
      },
      {type = 1, timeNext = -1}
    }
  },
  [111] = {
    id = 111,
    type = 0,
    name = "\231\180\171\231\130\174\230\128\170\229\188\185\233\129\1473",
    file = "Spine/skill/EFT_Djxycdandao_01",
    overRemove = true,
    scale = 0.45,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 700,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 109
      },
      {type = 1, timeNext = -1}
    }
  },
  [112] = {
    id = 112,
    type = 0,
    name = "\233\151\170\231\148\181\233\147\190",
    file = "Spine/skill/EFT_zhujigongji_02",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 16,
        timeNext = 0,
        baseBone = "bone_beiji",
        targetBone = "bone_beiji",
        offset = 20
      },
      {
        type = 3,
        timeNext = 0,
        animation = "EFT_zhujigongji_02",
        loop = true
      },
      {type = 10, timeNext = 0.25}
    }
  },
  [113] = {
    id = 113,
    type = 0,
    name = "\233\151\170\231\148\181\233\147\190\229\143\151\229\135\187",
    file = "Spine/skill/BUFF_mabi_01",
    overRemove = true,
    scale = 2,
    bone = "bone_beiji",
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = 0,
        animation = "BUFF_mabi_01",
        loop = false
      }
    }
  },
  [114] = {
    id = 114,
    type = 0,
    name = "\230\156\186\229\153\168boss\231\130\184\229\188\185",
    file = "Spine/renwu/zibaojiqiren90",
    overRemove = false,
    scale = 0.55,
    zType = 2,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation_01",
        loop = true
      },
      {
        type = 8,
        timeNext = -1,
        fixedType = 0,
        value = 1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation_02",
        loop = true
      }
    }
  },
  [115] = {
    id = 115,
    type = 3,
    name = "\230\156\186\229\153\168boss\231\130\184\229\188\185\231\136\134\231\130\184",
    file = "Effect/baozha",
    overRemove = true,
    scale = 2,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "Effect/baozha",
        loop = false,
        frames = 9
      },
      {type = 10, timeNext = 0.1},
      {
        type = 14,
        timeNext = -1,
        newID = 12
      }
    }
  },
  [116] = {
    id = 116,
    type = 0,
    name = "\229\141\129\229\173\151\229\133\137\230\150\169\232\140\131\229\155\180",
    file = "",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 4,
        timeNext = -1,
        placeType = 2
      },
      {type = 2, timeNext = -1}
    }
  },
  [117] = {
    id = 117,
    type = 0,
    name = "\229\141\129\229\173\151\229\133\137\230\150\169\229\188\185\233\129\147",
    file = "Spine/skill/EFT_BossDaoguang_01",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 118,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 700,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 119
      },
      {
        type = 1,
        timeNext = -1,
        damage = 999999
      }
    }
  },
  [118] = {
    id = 118,
    type = 1,
    name = "\229\141\129\229\173\151\229\133\137\230\150\169\230\139\150\229\176\190",
    file = "Effect/mijialetrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [119] = {
    id = 119,
    type = 0,
    name = "\229\141\129\229\173\151\229\133\137\230\150\169\229\143\151\229\135\187",
    file = "Spine/skill/EFT_BossDaoBeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [120] = {
    id = 120,
    type = 2,
    name = "\232\191\158\229\143\145\229\175\188\229\188\185",
    file = "#Effect/EFT_BossDandao_01",
    overRemove = true,
    scale = 0.7,
    members = {
      {
        id = 121,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 0,
        timeNext = -1,
        moveType = 0,
        speed = 500,
        rotate = true,
        tag = 1
      },
      {
        type = 12,
        timeNext = -1,
        speed = 290,
        radius = 100,
        rotate = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true,
        refind = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = -1},
      {
        type = 14,
        timeNext = -1,
        newID = 122
      }
    }
  },
  [121] = {
    id = 121,
    type = 1,
    name = "\232\191\158\229\143\145\229\175\188\229\188\185\230\139\150\229\176\190",
    file = "Effect/daodanyanwu",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [122] = {
    id = 122,
    type = 0,
    name = "\232\191\158\229\143\145\229\175\188\229\188\185\229\143\151\229\135\187",
    file = "Spine/skill/EFT_BossBeiji_01",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [123] = {
    id = 123,
    type = 0,
    name = "\230\150\167\229\164\180\230\128\170\231\190\164\230\153\174",
    file = "",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 4,
        timeNext = -1,
        placeType = 2
      },
      {type = 2, timeNext = -1}
    }
  },
  [124] = {
    id = 124,
    type = 0,
    name = "\229\143\140\231\130\174\230\128\170\230\158\170\229\143\163",
    file = "Spine/skill/EFT_qianghuo_02",
    overRemove = false,
    scale = 1,
    bone = "bone_shoot",
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [125] = {
    id = 125,
    type = 2,
    name = "\229\143\140\231\130\174\230\128\170\229\188\185\233\129\147",
    file = "#Effect/EFT_BossDandao_02",
    overRemove = true,
    scale = 0.65,
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 1000,
        rotate = true,
        random = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = -1},
      {
        type = 14,
        timeNext = -1,
        newID = 127
      }
    }
  },
  [126] = {
    id = 126,
    type = 0,
    name = "\229\143\140\231\130\174\230\128\170\230\139\150\229\176\190",
    file = "",
    overRemove = true,
    scale = 1,
    attrs = {
      {type = 2, timeNext = -1}
    }
  },
  [127] = {
    id = 127,
    type = 0,
    name = "\229\143\140\231\130\174\230\128\170\229\175\188\229\188\185\229\143\151\229\135\187",
    file = "Spine/skill/EFT_BossBeiji_02",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [128] = {
    id = 128,
    type = 0,
    name = "\229\143\140\231\130\174\230\128\170\229\135\187\233\128\128\230\158\170\229\143\163",
    file = "Spine/skill/EFT_qianghuo_02",
    overRemove = false,
    scale = 1,
    bone = "bone_shoot",
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = true
      }
    }
  },
  [129] = {
    id = 129,
    type = 0,
    name = "\229\143\140\231\130\174\230\128\170\229\135\187\233\128\128",
    file = "Spine/skill/EFT_BossSkill_02",
    overRemove = false,
    scale = 1,
    zType = 2,
    attrs = {}
  },
  [130] = {
    id = 130,
    type = 0,
    name = "\229\143\140\231\130\174\230\128\170\229\135\187\233\128\128\229\143\151\229\135\187",
    file = "Spine/skill/EFT_BossBeiji_02",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [131] = {
    id = 131,
    type = 2,
    name = "\231\186\162\231\130\174\230\128\170\229\188\185\233\129\1471",
    file = "#Effect/EFT_Djxycdandao_02",
    overRemove = true,
    scale = 0.35,
    attrs = {
      {
        type = 8,
        timeNext = -1,
        fixedType = 0,
        value = 0.7,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = 0},
      {
        type = 14,
        timeNext = -1,
        newID = 133
      }
    }
  },
  [132] = {
    id = 132,
    type = 1,
    name = "\231\186\162\231\130\174\230\128\170\231\131\159\233\155\190",
    file = "Effect/redyanwu",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [133] = {
    id = 133,
    type = 0,
    name = "\231\186\162\231\130\174\230\128\170\229\143\151\229\135\187",
    file = "Spine/skill/EFT_djxycbeiji_02",
    overRemove = true,
    scale = 0.35,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [134] = {
    id = 134,
    type = 2,
    name = "\231\186\162\231\130\174\230\128\170\229\188\185\233\129\1472",
    file = "#Effect/EFT_Djxycdandao_02",
    overRemove = true,
    scale = 0.5,
    members = {
      {
        id = 132,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 8,
        timeNext = -1,
        fixedType = 0,
        value = 0.7,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = 0},
      {
        type = 14,
        timeNext = -1,
        newID = 133
      }
    }
  },
  [135] = {
    id = 135,
    type = 2,
    name = "\231\186\162\231\130\174\230\128\170\229\188\185\233\129\1473",
    file = "#Effect/EFT_Djxycdandao_02",
    overRemove = true,
    scale = 0.75,
    members = {
      {
        id = 132,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 8,
        timeNext = -1,
        fixedType = 0,
        value = 0.7,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = 0},
      {
        type = 14,
        timeNext = -1,
        newID = 133
      }
    }
  },
  [136] = {
    id = 136,
    type = 0,
    name = "\230\149\140\230\150\185\229\161\148\230\148\187\229\135\187\232\147\132\229\138\155",
    file = "Spine/skill/EFT_xunluofashe_01",
    overRemove = true,
    scale = 0.8,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [137] = {
    id = 137,
    type = 2,
    name = "\230\149\140\230\150\185\229\161\148\229\188\185\233\129\147",
    file = "#Effect/EFT_xunluodandao_01",
    overRemove = true,
    scale = 1.2,
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 600,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 138
      },
      {type = 1, timeNext = -1}
    }
  },
  [138] = {
    id = 138,
    type = 0,
    name = "\230\149\140\230\150\185\229\161\148\229\143\151\229\135\187",
    file = "Spine/skill/EFT_xunluobeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [139] = {
    id = 139,
    type = 0,
    name = "\230\136\152\228\186\137\232\183\181\232\184\143",
    file = "",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 303,
        loop = false
      },
      {type = 2, timeNext = -1}
    }
  },
  [140] = {
    id = 140,
    type = 0,
    name = "\230\186\133\229\176\132",
    file = "",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 4,
        timeNext = -1,
        placeType = 2
      },
      {type = 2, timeNext = -1}
    }
  },
  [141] = {
    id = 141,
    type = 0,
    name = "\231\148\159\229\145\189\230\177\178\229\143\150",
    file = "Spine/skill/EFT_xixue_02",
    overRemove = false,
    scale = 0.8,
    attrs = {
      {
        type = 16,
        timeNext = 0,
        baseBone = "bone_beiji",
        targetBone = "bone_beiji",
        offset = 60
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [142] = {
    id = 142,
    type = 0,
    name = "\231\148\159\229\145\189\230\177\178\229\143\150\232\162\171\229\135\187",
    file = "Spine/skill/EFT_xixue_01",
    overRemove = false,
    scale = 2,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = true
      }
    }
  },
  [143] = {
    id = 143,
    type = 0,
    name = "\230\175\146\232\153\171\232\135\170\231\136\134\231\136\134\231\130\184",
    file = "Spine/skill/EFT_shuangzinan_03",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 306,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [144] = {
    id = 144,
    type = 0,
    name = "\230\175\146\232\153\171\232\135\170\231\136\134\230\175\146\230\176\180",
    file = "Spine/skill/EFT_lvsezhaoze_01",
    overRemove = true,
    scale = 1.5,
    zType = 1,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 2,
        overType = 1,
        value = 5
      },
      {
        type = 5,
        timeNext = -1,
        time = 1,
        fromOpacity = 255,
        toOpacity = 0
      }
    }
  },
  [145] = {
    id = 145,
    type = 0,
    name = "\232\161\128\233\155\190\229\156\176",
    file = "Spine/skill/EFT_xuewudi_02",
    overRemove = true,
    scale = 3,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 14,
        timeNext = -1,
        newID = 146
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 2,
        overType = 1,
        value = 10
      }
    }
  },
  [146] = {
    id = 146,
    type = 0,
    name = "\232\161\128\233\155\190\233\155\190",
    file = "Spine/skill/EFT_xuewudi_01",
    overRemove = true,
    scale = 3,
    zType = 1,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {type = 10, timeNext = 10}
    }
  },
  [147] = {
    id = 147,
    type = 0,
    name = "\229\174\154\230\151\182\231\130\184\229\188\185",
    file = "Spine/skill/EFT_dingshizhadan_01",
    overRemove = true,
    scale = 0.5,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true,
        refind = true
      },
      {
        type = 30,
        timeNext = 0,
        sound = 309,
        loop = false
      },
      {
        type = 17,
        timeNext = 0,
        zorder = 1,
        time = -1,
        bTarget = true
      },
      {type = 10, timeNext = 3},
      {type = 1, timeNext = -1},
      {
        type = 14,
        timeNext = -1,
        newID = 148
      }
    }
  },
  [148] = {
    id = 148,
    type = 0,
    name = "\229\174\154\230\151\182\231\130\184\229\188\185\231\136\134\231\130\184",
    file = "Spine/skill/EFT_xianzhebeiji_02",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [149] = {
    id = 149,
    type = 2,
    name = "\231\131\159\232\138\177\231\130\184\229\188\185",
    file = "#Effect/EFT_sandandandao_01",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 153,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 8,
        timeNext = -1,
        fixedType = 1,
        value = 400,
        rotate = true,
        moveType = 1,
        x = 300,
        y = 200,
        gravity = 20
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 150
      }
    }
  },
  [150] = {
    id = 150,
    type = 0,
    name = "\231\131\159\232\138\177\231\130\184\229\188\185\231\136\134\231\130\1841",
    file = "Spine/skill/EFT_sandanbeiji_01",
    overRemove = true,
    scale = 1.8,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 151,
        count = 10,
        inherit = true,
        zorder = -1
      }
    }
  },
  [151] = {
    id = 151,
    type = 2,
    name = "\231\131\159\232\138\177\231\130\184\229\188\185\229\136\134\232\163\130",
    file = "#Effect/EFT_Djxycdandao_02",
    overRemove = true,
    scale = 0.3,
    attrs = {
      {
        type = 8,
        timeNext = -1,
        fixedType = 1,
        value = 350,
        rotate = true,
        moveType = 1,
        x = 0,
        y = -250,
        randX = 300,
        randY = 100,
        gravity = 20
      },
      {type = 2, timeNext = 0},
      {
        type = 14,
        timeNext = -1,
        newID = 152
      }
    }
  },
  [152] = {
    id = 152,
    type = 0,
    name = "\231\131\159\232\138\177\231\130\184\229\188\185\231\136\134\231\130\1842",
    file = "Spine/skill/EFT_sandanbeiji_02",
    overRemove = true,
    scale = 1.8,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [153] = {
    id = 153,
    type = 1,
    name = "\231\131\159\232\138\177\231\130\184\229\188\185\231\131\159\233\155\190",
    file = "Effect/sandanyanwu",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [154] = {
    id = 154,
    type = 0,
    name = "\229\183\161\233\128\187\230\128\170\230\179\149\229\184\136\232\147\132\229\138\155",
    file = "Spine/skill/EFT_xunluofashe_01",
    overRemove = true,
    scale = 0.8,
    bone = "bone_shoot",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [155] = {
    id = 155,
    type = 0,
    name = "\229\183\161\233\128\187\230\128\170\229\176\132\230\137\139\229\188\185\233\129\147",
    file = "Spine/skill/EFT_xunluodaoDD_01",
    overRemove = true,
    scale = 0.7,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 156
      },
      {type = 1, timeNext = -1}
    }
  },
  [156] = {
    id = 156,
    type = 0,
    name = "\229\183\161\233\128\187\230\128\170\229\176\132\230\137\139\229\143\151\229\135\187",
    file = "Spine/skill/EFT_mijialebeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [157] = {
    id = 157,
    type = 0,
    name = "\229\183\161\233\128\187\230\128\170\229\176\132\230\137\139\232\147\132\229\138\155",
    file = "Spine/skill/EFT_xunluofashe_01",
    overRemove = true,
    scale = 0.8,
    bone = "bone_shoot",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [158] = {
    id = 158,
    type = 2,
    name = "\229\183\161\233\128\187\230\128\170\232\191\156\231\168\139\229\188\185\233\129\147",
    file = "#Effect/EFT_xunluopaoDD_01",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 153,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 159
      },
      {type = 1, timeNext = -1}
    }
  },
  [159] = {
    id = 159,
    type = 0,
    name = "\229\183\161\233\128\187\230\128\170\232\191\156\231\168\139\229\143\151\229\135\187",
    file = "Spine/skill/EFT_xunluopaoBJ_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [160] = {
    id = 160,
    type = 0,
    name = "\229\183\161\233\128\187\230\128\170\232\191\156\231\168\139\232\147\132\229\138\155",
    file = "Spine/skill/EFT_xunluofashe_01",
    overRemove = true,
    scale = 0.8,
    bone = "bone_shoot",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [161] = {
    id = 161,
    type = 0,
    name = "\230\129\182\233\173\148\230\168\170\230\137\171",
    file = "",
    overRemove = true,
    scale = 1,
    attrs = {
      {type = 2, timeNext = -1}
    }
  },
  [162] = {
    id = 162,
    type = 0,
    name = "\232\131\189\233\135\143\229\157\151",
    file = "Spine/skill/EFT_nengliangkuai_01",
    overRemove = false,
    scale = 1,
    zType = 2,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 11,
        timeNext = 0,
        revolveType = 2,
        angle = 0,
        speed = 60,
        rotate = false
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 2,
        overType = 2
      }
    }
  },
  [163] = {
    id = 163,
    type = 0,
    name = "\232\131\189\233\135\143\232\191\158\231\186\191",
    file = "Spine/skill/EFT_nengliangxian_01",
    overRemove = false,
    scale = 1.4,
    zType = 2,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 11,
        timeNext = 0,
        revolveType = 2,
        angle = 0,
        speed = 60,
        rotate = false
      },
      {
        type = 15,
        timeNext = 0,
        rotateType = 3,
        angle = -1,
        speed = 60
      }
    }
  },
  [164] = {
    id = 164,
    type = 0,
    name = "\230\132\164\230\128\146\229\134\178\233\148\139\233\163\158\229\137\145",
    file = "Spine/skill/EFT_feijian_01",
    overRemove = false,
    scale = 1.6,
    zType = 1,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation_01",
        loop = true
      },
      {
        type = 6,
        timeNext = 0,
        groupType = 2,
        overType = 2
      },
      {
        type = 0,
        timeNext = -1,
        moveType = 0,
        speed = 1000
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation_02",
        loop = false
      }
    }
  },
  [165] = {
    id = 165,
    type = 0,
    name = "\229\142\159\229\138\155\229\155\190\232\133\190\229\186\149\229\177\130",
    file = "Spine/skill/EFT_yuanlituteng_02",
    overRemove = true,
    scale = 1.5,
    zType = 1,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation_01",
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_02",
        loop = true
      },
      {type = 10, timeNext = 20},
      {
        type = 3,
        timeNext = -1,
        animation = "animation_03",
        loop = false
      }
    }
  },
  [166] = {
    id = 166,
    type = 0,
    name = "Boss3\231\190\164\230\153\174",
    file = "",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 4,
        timeNext = -1,
        placeType = 2
      },
      {
        type = 2,
        timeNext = -1,
        damage = 50
      }
    }
  },
  [167] = {
    id = 167,
    type = 0,
    name = "\230\132\164\230\128\146\229\134\178\233\148\139\229\143\151\229\135\187",
    file = "Spine/skill/EFT_xunluobeiji_01",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [168] = {
    id = 168,
    type = 0,
    name = "\233\156\135\229\156\176\229\135\187",
    file = "",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 313,
        loop = false
      },
      {type = 2, timeNext = -1}
    }
  },
  [169] = {
    id = 169,
    type = 0,
    name = "\230\128\170\231\137\169\233\161\186\229\138\136\230\150\169",
    file = "",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 314,
        loop = false
      },
      {type = 2, timeNext = -1}
    }
  },
  [170] = {
    id = 170,
    type = 2,
    name = "\229\183\171\229\184\136\233\187\145\229\188\185\233\129\147",
    file = "#Effect/EFT_fashi_01",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 400,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 172
      },
      {type = 1, timeNext = -1}
    }
  },
  [171] = {
    id = 171,
    type = 1,
    name = "\229\183\171\229\184\136\233\187\145\230\139\150\229\176\190",
    file = "Effect/angeltrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [172] = {
    id = 172,
    type = 0,
    name = "\229\183\171\229\184\136\233\187\145\229\143\151\229\135\187",
    file = "Spine/skill/EFT_fashi_02",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [173] = {
    id = 173,
    type = 2,
    name = "\229\183\171\229\184\136\231\187\191\229\188\185\233\129\147",
    file = "#Effect/EFT_fashi_03",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 174,
        zorder = -1,
        x = 0,
        y = 0,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 300,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 175
      },
      {type = 1, timeNext = -1}
    }
  },
  [174] = {
    id = 174,
    type = 1,
    name = "\229\183\171\229\184\136\231\187\191\230\139\150\229\176\190",
    file = "Effect/wushilvtrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [175] = {
    id = 175,
    type = 0,
    name = "\229\183\171\229\184\136\231\187\191\229\143\151\229\135\187",
    file = "Spine/skill/EFT_fashi_04",
    overRemove = true,
    scale = 0.3,
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 601,
        loop = false
      },
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [176] = {
    id = 176,
    type = 2,
    name = "\229\183\171\229\184\136\231\186\162\229\188\185\233\129\147",
    file = "#Effect/EFT_fashi_05",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 177,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 400,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 178
      },
      {type = 1, timeNext = -1}
    }
  },
  [177] = {
    id = 177,
    type = 1,
    name = "\229\183\171\229\184\136\231\186\162\230\139\150\229\176\190",
    file = "Effect/xianzhetrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [178] = {
    id = 178,
    type = 0,
    name = "\229\183\171\229\184\136\231\186\162\229\143\151\229\135\187",
    file = "Spine/skill/EFT_fashi_06",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [179] = {
    id = 179,
    type = 2,
    name = "\233\178\168\233\177\188\231\130\1741\229\188\185\233\129\147",
    file = "#Effect/EFT_yuancheng_01",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 181
      },
      {type = 1, timeNext = -1}
    }
  },
  [181] = {
    id = 181,
    type = 0,
    name = "\233\178\168\233\177\188\231\130\1741\229\143\151\229\135\187",
    file = "Spine/skill/EFT_yuanchengbeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [182] = {
    id = 182,
    type = 2,
    name = "\233\178\168\233\177\188\231\130\1742\229\188\185\233\129\147",
    file = "#Effect/EFT_yuancheng_01",
    overRemove = true,
    scale = 1.1,
    members = {
      {
        id = 183,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 184
      },
      {type = 1, timeNext = -1}
    }
  },
  [183] = {
    id = 183,
    type = 1,
    name = "\233\178\168\233\177\188\231\130\1742\230\139\150\229\176\190",
    file = "Effect/sharktrail",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [184] = {
    id = 184,
    type = 0,
    name = "\233\178\168\233\177\188\231\130\1742\229\143\151\229\135\187",
    file = "Spine/skill/EFT_yuanchengbeiji_01",
    overRemove = true,
    scale = 0.5,
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [185] = {
    id = 185,
    type = 2,
    name = "\233\178\168\233\177\188\231\130\1743\229\188\185\233\129\147",
    file = "#Effect/EFT_yuancheng_03",
    overRemove = true,
    scale = 0.9,
    attrs = {
      {
        type = 8,
        timeNext = -1,
        fixedType = 0,
        value = 0.7,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 2, timeNext = 0},
      {
        type = 14,
        timeNext = -1,
        newID = 186
      }
    }
  },
  [186] = {
    id = 186,
    type = 3,
    name = "\233\178\168\233\177\188\231\130\1743\231\136\134\231\130\184",
    file = "Effect/baozha",
    overRemove = true,
    scale = 2,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "Effect/baozha",
        loop = false,
        frames = 9
      },
      {type = 10, timeNext = 0.1},
      {
        type = 14,
        timeNext = -1,
        newID = 12
      }
    }
  },
  [187] = {
    id = 187,
    type = 0,
    name = "\230\132\164\230\128\146\229\134\178\233\148\139\233\163\158\229\137\145",
    file = "Spine/skill/EFT_feijian_01",
    overRemove = false,
    scale = 1.6,
    zType = 1,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation_01",
        loop = true
      },
      {
        type = 0,
        timeNext = -1,
        moveType = 0,
        speed = 1000
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation_02",
        loop = false
      }
    }
  },
  [188] = {
    id = 188,
    type = 0,
    name = "boss\232\132\154\229\186\149\228\184\139\231\137\185\230\149\1361",
    file = "Spine/skill/EFT_shuangzinv_01",
    overRemove = true,
    scale = 2,
    zType = 1,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 189
      }
    }
  },
  [189] = {
    id = 189,
    type = 0,
    name = "boss\232\132\154\229\186\149\228\184\139\231\137\185\230\149\1362",
    file = "Spine/skill/EFT_shuangzinv_02",
    overRemove = false,
    scale = 2,
    zType = 1,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = true
      }
    }
  },
  [190] = {
    id = 190,
    type = 0,
    name = "\228\191\174\231\189\151\230\150\151\229\156\186",
    file = "Spine/skill/EFT_xiuluodouchang_01",
    overRemove = true,
    scale = 1.3,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [191] = {
    id = 191,
    type = 0,
    name = "\231\165\158\229\156\163\229\144\140\231\155\159",
    file = "Spine/skill/EFT_shengshentongmeng_01",
    overRemove = true,
    scale = 1.3,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [192] = {
    id = 192,
    type = 0,
    name = "\229\134\176\230\179\149\229\188\185\233\129\147\229\143\151\229\135\1872",
    file = "Spine/skill/EFT_nvwubeiji_02",
    overRemove = true,
    scale = 0.8,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [193] = {
    id = 193,
    type = 0,
    name = "\233\146\162\233\147\129\232\139\141\231\169\185\229\156\136",
    file = "Spine/skill/EFT_GangTieCangQiong_03",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [194] = {
    id = 194,
    type = 0,
    name = "boss3\229\143\172\229\148\164\231\130\184\229\188\185",
    file = "Spine/renwu/zibaojiqiren90",
    overRemove = false,
    scale = 0.55,
    zType = 2,
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation_03",
        loop = false
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation_04",
        loop = true
      },
      {
        type = 20,
        timeNext = -1,
        speed = 200,
        rotate = false,
        refind = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = 0,
        newID = 115
      },
      {
        type = 2,
        timeNext = -1,
        width = 100,
        height = 100
      }
    }
  },
  [195] = {
    id = 195,
    type = 0,
    name = "\230\150\176\230\152\159\231\130\184\229\188\185",
    file = "Spine/skill/EFT_xinxingzhadan_01",
    overRemove = true,
    scale = 1,
    zType = 2,
    attrs = {
      {
        type = 4,
        timeNext = 0,
        placeType = 0,
        x = 0,
        y = 1000
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation_01",
        loop = true
      },
      {
        type = 0,
        timeNext = -1,
        moveType = 0,
        speed = 2500
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_02",
        loop = false
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation_03",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 2,
        overType = 0,
        value = 1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation_04",
        loop = true
      },
      {type = 10, timeNext = 1.5},
      {type = 2, timeNext = 0},
      {
        type = 3,
        timeNext = -1,
        animation = "animation_05",
        loop = false
      }
    }
  },
  [196] = {
    id = 196,
    type = 0,
    name = "\230\181\129\230\152\159\233\153\168\231\159\179",
    file = "Spine/skill/EFT_liuxingyunshi_01",
    overRemove = true,
    scale = 1.2,
    zType = 2,
    members = {
      {
        id = 199,
        zorder = -1,
        x = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 4,
        timeNext = 0,
        placeType = 0,
        x = 0,
        y = 1000
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation_01",
        loop = true
      },
      {
        type = 0,
        timeNext = -1,
        moveType = 0,
        speed = 800
      },
      {type = 2, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 501,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation_02",
        loop = false
      }
    }
  },
  [197] = {
    id = 197,
    type = 0,
    name = "\231\165\158\231\129\173\230\150\169",
    file = "Spine/skill/EFT_shenmiezhan_01",
    overRemove = true,
    scale = 0.7,
    attrs = {
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 10, timeNext = 0},
      {
        type = 9,
        timeNext = -1,
        visible = true
      },
      {
        type = 30,
        timeNext = 0,
        sound = 519,
        loop = false
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      },
      {
        type = 2,
        timeNext = -1,
        width = 100,
        height = 100
      }
    }
  },
  [198] = {
    id = 198,
    type = 0,
    name = "\229\134\176\233\156\156\230\185\174\231\129\173",
    file = "Spine/skill/EFT_minmie_01",
    overRemove = true,
    scale = 0.5,
    zType = 2,
    attrs = {
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 10, timeNext = 0},
      {
        type = 9,
        timeNext = -1,
        visible = true
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      },
      {
        type = 2,
        timeNext = -1,
        width = 100,
        height = 100
      }
    }
  },
  [199] = {
    id = 199,
    type = 1,
    name = "\230\181\129\230\152\159\233\153\168\231\159\179\230\139\150\229\176\190",
    file = "Effect/liuxing",
    overRemove = false,
    scale = 1,
    attrs = {}
  },
  [200] = {
    id = 200,
    type = 0,
    name = "\231\165\158\229\156\163\229\133\137\232\128\128",
    file = "Spine/skill/EFT_shenshengguangyao_01",
    overRemove = true,
    scale = 1,
    bone = "root",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [201] = {
    id = 201,
    type = 2,
    name = "\232\191\156\231\168\139\232\139\177\233\155\1322\229\188\185\233\129\147",
    file = "#Effect/paodan_06",
    overRemove = true,
    scale = 0.7,
    members = {
      {
        id = 37,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 209,
        loop = true
      },
      {
        type = 19,
        timeNext = -1,
        speed = 500,
        rotate = true,
        refind = true
      },
      {type = 31, timeNext = 0},
      {
        type = 30,
        timeNext = 0,
        sound = 210,
        loop = false
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = 0},
      {
        type = 2,
        timeNext = 0,
        damage = 50
      },
      {
        type = 14,
        timeNext = -1,
        newID = 205
      }
    }
  },
  [202] = {
    id = 202,
    type = 2,
    name = "\230\179\149\229\184\136\232\139\177\233\155\1322\229\188\185\233\129\147",
    file = "#Effect/huoqiu_06",
    overRemove = true,
    scale = 1,
    members = {
      {
        id = 20,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 600,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 21
      },
      {type = 1, timeNext = -1}
    }
  },
  [203] = {
    id = 203,
    type = 2,
    name = "\229\133\168\229\177\143\230\175\146\230\182\178\229\188\185\233\129\147",
    file = "#Effect/EFT_dfdandao_01",
    overRemove = true,
    scale = 0.6,
    members = {
      {
        id = 79,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 1
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 600,
        rotate = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {
        type = 14,
        timeNext = -1,
        newID = 80
      },
      {type = 1, timeNext = -1}
    }
  },
  [204] = {
    id = 204,
    type = 0,
    name = "\229\189\177\229\136\134\232\186\171\231\136\134\231\130\184",
    file = "Spine/skill/EFT_shenshengguangyao_01",
    overRemove = true,
    scale = 1,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      },
      {
        type = 2,
        timeNext = 0,
        damage = 50
      },
      {type = 10, timeNext = 0.1},
      {
        type = 14,
        timeNext = -1,
        newID = 12
      }
    }
  },
  [205] = {
    id = 205,
    type = 3,
    name = "\231\130\174\232\139\177\233\155\132\231\136\134\231\130\184",
    file = "Effect/baozha",
    overRemove = true,
    scale = 2,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "Effect/baozha",
        loop = false,
        frames = 9
      },
      {type = 10, timeNext = 0.1},
      {
        type = 14,
        timeNext = -1,
        newID = 12
      }
    }
  },
  [206] = {
    id = 206,
    type = 0,
    name = "\232\141\134\230\163\152\231\188\160\231\187\149",
    file = "",
    overRemove = true,
    scale = 1,
    attrs = {
      {type = 2, timeNext = -1}
    }
  },
  [207] = {
    id = 207,
    type = 2,
    name = "\233\151\170\229\133\137\229\188\185\229\188\185\233\129\147\231\190\164\228\189\147",
    file = "#Effect/EFT_shanguangdan_01",
    overRemove = true,
    scale = 1.3,
    attrs = {
      {
        type = 15,
        timeNext = 0,
        rotateType = 3,
        angle = 0,
        speed = 500
      },
      {
        type = 8,
        timeNext = -1,
        fixedType = 1,
        value = 400
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 2, timeNext = -1},
      {
        type = 14,
        timeNext = -1,
        newID = 60
      }
    }
  },
  [208] = {
    id = 208,
    type = 2,
    name = "\231\139\153\229\135\187\228\184\137\232\191\158\229\143\145",
    file = "#Effect/sanlianji",
    overRemove = true,
    scale = 3,
    members = {
      {
        id = 23,
        zorder = -1,
        x = 0,
        y = 0,
        noRotate = true,
        delayRemove = 2
      }
    },
    attrs = {
      {
        type = 19,
        timeNext = -1,
        speed = 800,
        rotate = true,
        random = true
      },
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 1, timeNext = -1},
      {
        type = 14,
        timeNext = -1,
        newID = 45
      }
    }
  },
  [209] = {
    id = 209,
    type = 0,
    name = "\230\152\159\232\144\189",
    file = "Spine/skill/EFT_lieyanfengbao_01",
    overRemove = true,
    scale = 0.7,
    attrs = {
      {
        type = 9,
        timeNext = -1,
        visible = false
      },
      {type = 10, timeNext = 0},
      {
        type = 9,
        timeNext = -1,
        visible = true
      },
      {
        type = 30,
        timeNext = 0,
        sound = 519,
        loop = false
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      },
      {
        type = 2,
        timeNext = -1,
        width = 100,
        height = 100
      }
    }
  },
  [1001] = {
    id = 1001,
    type = 1,
    name = "\230\174\139\229\189\177",
    file = "Effect/canying",
    overRemove = false,
    scale = 1,
    zType = 2,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        zorder = -1,
        time = -1,
        offsetY = 25
      }
    }
  },
  [1002] = {
    id = 1002,
    type = 2,
    name = "\229\143\151\229\135\187",
    file = "#Effect/Ty_beiji_01",
    overRemove = true,
    scale = 0.01,
    bone = "bone_beiji",
    attrs = {
      {
        type = 15,
        timeNext = -1,
        rotateType = 2
      },
      {
        type = 18,
        timeNext = -1,
        scaleType = 1,
        time = 0.1,
        x = 2
      },
      {
        type = 18,
        timeNext = -1,
        scaleType = 1,
        time = 0.06,
        x = 2.4
      },
      {
        type = 5,
        timeNext = -1,
        time = 0.06,
        fromOpacity = 255,
        toOpacity = 0
      }
    }
  },
  [1003] = {
    id = 1003,
    type = 0,
    name = "\229\143\151\229\159\186\229\156\176\229\135\187",
    file = "Spine/skill/EFT_zhujigongji_03",
    overRemove = true,
    scale = 1,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "EFT_zhujigongji_03",
        loop = false
      }
    }
  },
  [1004] = {
    id = 1004,
    type = 0,
    name = "\233\186\187\231\151\185",
    file = "Spine/skill/BUFF_mabi_01",
    overRemove = false,
    scale = 2,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "BUFF_mabi_01",
        loop = true
      }
    }
  },
  [1005] = {
    id = 1005,
    type = 0,
    name = "\231\129\188\231\131\167",
    file = "Spine/skill/BUFF_zhuoshao_01",
    overRemove = false,
    scale = 2,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "BUFF_zhuoshao_01",
        loop = true
      }
    }
  },
  [1008] = {
    id = 1008,
    type = 0,
    name = "\230\156\168\228\185\131\228\188\138buff\232\132\154\228\184\139",
    file = "Spine/skill/BUFF_shuangziroot_01",
    overRemove = false,
    scale = 1,
    bone = "root",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1009] = {
    id = 1009,
    type = 0,
    name = "\229\131\181\229\176\184buff",
    file = "Spine/skill/EFT_shuangzinv_03",
    overRemove = false,
    scale = 2,
    bone = "root",
    color = cc.c3b(100, 100, 100),
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1010] = {
    id = 1010,
    type = 0,
    name = "\229\131\181\229\176\184buff\232\132\154\228\184\139",
    file = "Spine/skill/EFT_shuangzinv_02",
    overRemove = false,
    scale = 1.5,
    bone = "root",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1011] = {
    id = 1011,
    type = 0,
    name = "\230\156\168\228\185\131\228\188\138\229\129\135\230\173\187",
    file = "Spine/skill/EFT_shuangzi_dead01",
    overRemove = false,
    scale = 2,
    bone = "root",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1014] = {
    id = 1014,
    type = 0,
    name = "\231\156\169\230\153\149",
    file = "Spine/skill/BUFF_xuanyun_01",
    overRemove = false,
    scale = 1,
    bone = "bone_buff",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1015] = {
    id = 1015,
    type = 0,
    name = "\230\181\129\232\161\128",
    file = "Spine/skill/BUFF_liuxue_beiji",
    overRemove = false,
    scale = 1,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1016] = {
    id = 1016,
    type = 0,
    name = "\228\184\173\230\175\146\231\180\171",
    file = "Spine/skill/BUFF_zhongdu_beiji",
    overRemove = false,
    scale = 1,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1017] = {
    id = 1017,
    type = 0,
    name = "\229\134\187\231\187\147",
    file = "Spine/skill/BUFF_dongjie_root",
    overRemove = false,
    scale = 1,
    bone = "root",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1018] = {
    id = 1018,
    type = 0,
    name = "\229\134\176\233\148\129\232\182\179",
    file = "Spine/skill/EFT_icesuozu_01",
    overRemove = false,
    scale = 1,
    bone = "root",
    color = cc.c3b(80, 160, 255),
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1019] = {
    id = 1019,
    type = 0,
    name = "\229\143\151\228\188\164\229\162\158\229\138\160",
    file = "Spine/skill/BUFF_siwangyinji_01",
    overRemove = false,
    scale = 0.8,
    bone = "bone_buff",
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "siwangyinji_01",
        loop = false
      },
      {
        type = 3,
        timeNext = 0,
        animation = "siwangyinji_02",
        loop = true
      }
    }
  },
  [1020] = {
    id = 1020,
    type = 0,
    name = "\231\158\172\233\151\180\229\138\160\232\161\128",
    file = "Spine/skill/BUFF_zhiliao_01",
    overRemove = true,
    scale = 1,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [1021] = {
    id = 1021,
    type = 0,
    name = "\230\140\129\231\187\173\229\138\160\232\161\128",
    file = "Spine/skill/BUFF_zhiliao_01",
    overRemove = false,
    scale = 0.7,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = true
      }
    }
  },
  [1022] = {
    id = 1022,
    type = 0,
    name = "\230\138\164\231\155\190",
    file = "Spine/skill/BUFF_hudun_01",
    overRemove = false,
    scale = 1.4,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = true
      }
    }
  },
  [1023] = {
    id = 1023,
    type = 0,
    name = "\232\162\171\229\152\178\232\174\189",
    file = "Spine/skill/BUFF_chaofeng_01",
    overRemove = false,
    scale = 0.5,
    bone = "bone_buff",
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = true
      }
    }
  },
  [1024] = {
    id = 1024,
    type = 1,
    name = "\229\134\176\229\135\143\233\128\159",
    file = "Effect/snow",
    overRemove = false,
    scale = 1,
    bone = "bone_beiji",
    color = cc.c3b(80, 160, 255),
    attrs = {}
  },
  [1025] = {
    id = 1025,
    type = 1,
    name = "\232\135\180\231\155\178",
    file = "Effect/blind",
    overRemove = false,
    scale = 1,
    bone = "bone_beiji",
    attrs = {}
  },
  [1026] = {
    id = 1026,
    type = 0,
    name = "\230\138\164\231\148\178\230\143\144\233\171\152",
    file = "Spine/skill/BUFF_hujiazengjia_01",
    overRemove = false,
    scale = 0.5,
    bone = "bone_buff",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1027] = {
    id = 1027,
    type = 0,
    name = "\230\138\164\231\148\178\233\153\141\228\189\142",
    file = "Spine/skill/BUFF_hujiajiangdi_01",
    overRemove = false,
    scale = 0.5,
    bone = "bone_buff",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1028] = {
    id = 1028,
    type = 0,
    name = "\230\148\187\229\135\187\233\153\141\228\189\142",
    file = "Spine/skill/EFT_gongjijiangdi_01",
    overRemove = false,
    scale = 0.5,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [1029] = {
    id = 1029,
    type = 0,
    name = "\230\154\180\229\135\187\230\143\144\233\171\152",
    file = "Spine/skill/EFT_baojitigao_01",
    overRemove = false,
    scale = 0.5,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [1030] = {
    id = 1030,
    type = 0,
    name = "\233\128\159\229\186\166\230\143\144\233\171\152",
    file = "Spine/skill/EFT_yidongjiasu_01",
    overRemove = false,
    scale = 1,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1031] = {
    id = 1031,
    type = 1,
    name = "\230\174\139\229\189\1772",
    file = "Effect/canying2",
    overRemove = false,
    scale = 1,
    zType = 2,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        zorder = -1,
        time = -1,
        offsetY = 20
      }
    }
  },
  [1032] = {
    id = 1032,
    type = 0,
    name = "\229\143\151\229\136\176\229\133\137\231\142\175",
    file = "Spine/skill/BUFF_yingxiangGH_01",
    overRemove = false,
    scale = 1.2,
    bone = "root",
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1033] = {
    id = 1033,
    type = 0,
    name = "\231\148\159\229\145\189\229\133\137\231\142\1751",
    file = "Spine/skill/BUFF_shengmingGH_01",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1034] = {
    id = 1034,
    type = 0,
    name = "\231\148\159\229\145\189\229\133\137\231\142\1752",
    file = "Spine/skill/BUFF_shengmingGH_02",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1035] = {
    id = 1035,
    type = 0,
    name = "\230\148\187\229\135\187\229\133\137\231\142\1751",
    file = "Spine/skill/BUFF_gongjiGH_01",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1036] = {
    id = 1036,
    type = 0,
    name = "\230\148\187\229\135\187\229\133\137\231\142\1752",
    file = "Spine/skill/BUFF_gongjiGH_02",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1037] = {
    id = 1037,
    type = 0,
    name = "\230\148\187\233\128\159\229\133\137\231\142\1751",
    file = "Spine/skill/BUFF_gongsuGH_01",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1038] = {
    id = 1038,
    type = 0,
    name = "\230\148\187\233\128\159\229\133\137\231\142\1752",
    file = "Spine/skill/BUFF_gongsuGH_02",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1039] = {
    id = 1039,
    type = 0,
    name = "\229\144\184\232\161\128\229\133\137\231\142\1751",
    file = "Spine/skill/BUFF_xixueGH_01",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1040] = {
    id = 1040,
    type = 0,
    name = "\229\144\184\232\161\128\229\133\137\231\142\1752",
    file = "Spine/skill/BUFF_xixueGH_02",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1041] = {
    id = 1041,
    type = 0,
    name = "\229\143\141\228\188\164\229\133\137\231\142\1751",
    file = "Spine/skill/BUFF_jingjiGH_01",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1042] = {
    id = 1042,
    type = 0,
    name = "\229\143\141\228\188\164\229\133\137\231\142\1752",
    file = "Spine/skill/BUFF_jingjiGH_02",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1043] = {
    id = 1043,
    type = 0,
    name = "\232\181\132\230\186\144\229\133\137\231\142\1751",
    file = "Spine/skill/BUFF_ziyuanGH_01",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1044] = {
    id = 1044,
    type = 0,
    name = "\232\181\132\230\186\144\229\133\137\231\142\1752",
    file = "Spine/skill/BUFF_ziyuanGH_02",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1045] = {
    id = 1045,
    type = 0,
    name = "\229\143\141\229\176\132\230\138\164\231\155\190",
    file = "Spine/skill/EFT_fanshehudun_01",
    overRemove = true,
    scale = 2,
    bone = "bone_beiji",
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 304,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [1046] = {
    id = 1046,
    type = 0,
    name = "\230\156\186\230\162\176\229\168\129\232\131\189",
    file = "Spine/skill/EFT_fanshehudun_01",
    overRemove = false,
    scale = 1.2,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1047] = {
    id = 1047,
    type = 0,
    name = "\229\143\151\229\136\176\229\133\137\231\142\1752",
    file = "Spine/skill/BUFF_yingxiangGH_01",
    overRemove = false,
    scale = 0.6,
    zType = -1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1048] = {
    id = 1048,
    type = 1,
    name = "\233\163\158\232\161\140\229\138\160\233\128\159",
    file = "Effect/mijialetrail",
    overRemove = false,
    scale = 1,
    zType = 2,
    bone = "bone_beiji",
    attrs = {
      {
        type = 17,
        timeNext = 0,
        zorder = -1,
        time = -1
      }
    }
  },
  [1049] = {
    id = 1049,
    type = 0,
    name = "boss3\230\151\160\230\149\140",
    file = "Spine/skill/EFT_bossxishou_01",
    overRemove = false,
    scale = 3,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1050] = {
    id = 1050,
    type = 0,
    name = "\230\148\187\229\135\187\230\143\144\233\171\152",
    file = "Spine/skill/BUFF_jiagongji_01",
    overRemove = false,
    scale = 0.5,
    bone = "bone_buff",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [1051] = {
    id = 1051,
    type = 0,
    name = "\228\184\173\230\175\146\231\187\191",
    file = "Spine/skill/BUFF_zhongdu_01",
    overRemove = false,
    scale = 1,
    bone = "bone_beiji",
    color = cc.c3b(0, 255, 0),
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1052] = {
    id = 1052,
    type = 0,
    name = "\233\173\133\230\131\145",
    file = "Spine/skill/BUFF_meihuo_01",
    overRemove = false,
    scale = 1,
    bone = "bone_buff",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1053] = {
    id = 1053,
    type = 0,
    name = "\232\153\154\230\151\160\231\138\182\230\128\129",
    file = "Spine/skill/BUFF_xuwu_01",
    overRemove = false,
    scale = 1.2,
    bone = "root",
    color = cc.c3b(100, 100, 100),
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1054] = {
    id = 1054,
    type = 0,
    name = "\229\133\141\228\188\164\230\138\164\231\155\190",
    file = "Spine/skill/EFT_hudun_01",
    overRemove = true,
    scale = 1.3,
    bone = "bone_beiji",
    attrs = {
      {
        type = 30,
        timeNext = 0,
        sound = 302,
        loop = false
      },
      {
        type = 3,
        timeNext = -1,
        animation = "animation",
        loop = false
      }
    }
  },
  [1055] = {
    id = 1055,
    type = 0,
    name = "\229\175\185\229\176\132\230\137\139\228\188\164\229\174\179\229\162\158\229\138\160",
    file = "Spine/skill/BUFF_jinzhanSH_01",
    overRemove = false,
    scale = 0.7,
    bone = "bone_buff",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1056] = {
    id = 1056,
    type = 0,
    name = "\229\175\185\232\191\156\231\168\139\228\188\164\229\174\179\229\162\158\229\138\160",
    file = "Spine/skill/BUFF_yuanchengSH_01",
    overRemove = false,
    scale = 0.7,
    bone = "bone_buff",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1057] = {
    id = 1057,
    type = 0,
    name = "\229\175\185\230\179\149\229\184\136\228\188\164\229\174\179\229\162\158\229\138\160",
    file = "Spine/skill/BUFF_fashiSH_01",
    overRemove = false,
    scale = 0.7,
    bone = "bone_buff",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1058] = {
    id = 1058,
    type = 0,
    name = "\229\175\185\232\191\156\231\168\139\229\146\140\230\179\149\229\184\136\228\188\164\229\174\179\229\162\158\229\138\160",
    file = "Spine/skill/BUFF_yuanfaSH_01",
    overRemove = false,
    scale = 0.7,
    bone = "bone_buff",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1059] = {
    id = 1059,
    type = 0,
    name = "boss3\229\135\143\228\188\1641",
    file = "Spine/skill/BUFF_bossjianshang_01",
    overRemove = false,
    scale = 1.5,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation_01",
        loop = true
      }
    }
  },
  [1060] = {
    id = 1060,
    type = 0,
    name = "boss3\229\135\143\228\188\1642",
    file = "Spine/skill/BUFF_bossjianshang_01",
    overRemove = false,
    scale = 1.5,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation_02",
        loop = true
      }
    }
  },
  [1061] = {
    id = 1061,
    type = 0,
    name = "boss3\229\135\143\228\188\1643",
    file = "Spine/skill/BUFF_bossjianshang_01",
    overRemove = false,
    scale = 1.5,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation_03",
        loop = true
      }
    }
  },
  [1062] = {
    id = 1062,
    type = 0,
    name = "\228\184\141\230\173\187\228\185\139\232\186\171",
    file = "Spine/skill/EFT_busizhishen_01",
    overRemove = false,
    scale = cc.p(2, 3),
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1063] = {
    id = 1063,
    type = 0,
    name = "\233\173\148\230\179\149\230\138\164\231\155\190",
    file = "Spine/skill/EFT_mofahudun_01",
    overRemove = false,
    scale = 2,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation_01",
        loop = true
      }
    }
  },
  [1064] = {
    id = 1064,
    type = 0,
    name = "\229\143\141\228\188\164\230\138\164\231\148\178",
    file = "Spine/skill/BUFF_fanshang_01",
    overRemove = true,
    scale = 2,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [1065] = {
    id = 1065,
    type = 0,
    name = "\229\134\176\233\156\156\230\138\164\231\148\178",
    file = "Spine/skill/EFT_shuangdonghuijia_01",
    overRemove = false,
    scale = 1.2,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1066] = {
    id = 1066,
    type = 0,
    name = "\229\137\145\229\136\131\233\163\142\230\154\180",
    file = "Spine/skill/EFT_jianrenfengbao_01",
    overRemove = false,
    scale = 1.5,
    bone = "bone_beiji",
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 2,
        overType = 2
      }
    }
  },
  [1067] = {
    id = 1067,
    type = 0,
    name = "\228\189\191\231\148\168\229\156\176\229\155\190\231\130\174",
    file = "Spine/skill/EFT_ditupaofashe_01",
    overRemove = true,
    scale = 2.5,
    bone = "bone_beiji",
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = false
      }
    }
  },
  [1068] = {
    id = 1068,
    type = 0,
    name = "\229\155\158\229\164\141\229\133\137\231\142\175",
    file = "Spine/skill/BUFF_huifuGH_01",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1069] = {
    id = 1069,
    type = 0,
    name = "\230\138\164\231\148\178\229\133\137\231\142\175",
    file = "Spine/skill/BUFF_hujiaguanghuan_01",
    overRemove = false,
    scale = 1,
    zType = 1,
    attrs = {
      {
        type = 17,
        timeNext = 0,
        time = -1
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      },
      {
        type = 6,
        timeNext = -1,
        groupType = 1,
        overType = 2
      }
    }
  },
  [1070] = {
    id = 1070,
    type = 0,
    name = "\229\164\169\231\165\158\228\184\139\229\135\161\229\138\160\230\148\187\229\135\187",
    file = "Spine/skill/BUFF_jiagongji_01",
    overRemove = false,
    scale = 0.5,
    bone = "bone_buff",
    actorScale = 1.5,
    attrs = {
      {
        type = 3,
        timeNext = 0,
        animation = "animation",
        loop = true
      }
    }
  },
  [1071] = {
    id = 1071,
    type = 1,
    name = "\232\191\145\230\136\152\230\157\128\230\137\139",
    file = "Effect/jinzhanshashou_01",
    overRemove = false,
    scale = 1,
    bone = "bone_beiji",
    attrs = {}
  },
  [1072] = {
    id = 1072,
    type = 1,
    name = "\232\191\156\231\168\139\230\157\128\230\137\139",
    file = "Effect/yuanchengshashou_01",
    overRemove = false,
    scale = 1,
    bone = "bone_beiji",
    attrs = {}
  },
  [1073] = {
    id = 1073,
    type = 1,
    name = "\230\179\149\229\184\136\230\157\128\230\137\139",
    file = "Effect/yuanchengshashou_01",
    overRemove = false,
    scale = 1,
    bone = "bone_beiji",
    attrs = {}
  },
  [1074] = {
    id = 1074,
    type = 1,
    name = "\229\164\169\231\165\158\228\184\139\229\135\161\229\138\160\232\161\128\233\135\143",
    file = "Effect/tianshenxiafan_01",
    overRemove = false,
    scale = 1,
    bone = "bone_beiji",
    attrs = {}
  },
  [1075] = {
    id = 1075,
    type = 0,
    name = "\232\141\134\230\163\152\233\148\129\232\182\179",
    file = "Spine/skill/EFT_chanrao_01",
    overRemove = false,
    scale = 2,
    bone = "root",
    attrs = {
      {
        type = 3,
        timeNext = -1,
        animation = "animation_01",
        loop = false
      },
      {
        type = 3,
        timeNext = 0,
        animation = "animation_02",
        loop = true
      },
      {type = 10, timeNext = 4},
      {
        type = 3,
        timeNext = -1,
        animation = "animation_03",
        loop = false
      }
    }
  }
}
local EffectConfig2 = import(".EffectConfig2")
function GetEffectConfig(id)
  if id > 2000 then
    return clone(EffectConfig2[id])
  end
  return clone(EffectConfig[id])
end
