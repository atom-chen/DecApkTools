local guide_config = {
  [1] = {
    conditions = {
      {type = 1, cityId = 1000}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00023"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00024"
      },
      {
        type = 2,
        style = 1,
        uiId = 26,
        nodeName = "Button_right1"
      },
      {
        type = 2,
        style = 1,
        uiId = 1,
        nodeName = "Button_1"
      },
      {
        type = 2,
        style = 1,
        uiId = 44,
        nodeName = "Button_start_3"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00025"
      },
      {
        type = 2,
        style = 1,
        uiId = 65,
        nodeName = "ListView1",
        childId = {1, 11}
      },
      {
        type = 2,
        style = 1,
        uiId = 65,
        nodeName = "ListView1",
        childId = {2, 11}
      },
      {
        type = 2,
        style = 1,
        uiId = 65,
        nodeName = "Button_start"
      }
    }
  },
  [2] = {
    conditions = {
      {type = 1, cityId = 1001}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00028"
      },
      {
        type = 2,
        style = 1,
        uiId = 1,
        nodeName = "Button_2"
      },
      {
        type = 2,
        style = 1,
        uiId = 44,
        nodeName = "Button_start_3"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00029"
      },
      {
        type = 2,
        style = 1,
        uiId = 65,
        nodeName = "ListView3",
        childId = {1, 11}
      },
      {
        type = 2,
        style = 1,
        uiId = 65,
        nodeName = "ListView3",
        childId = {2, 11}
      },
      {
        type = 2,
        style = 1,
        uiId = 65,
        nodeName = "Button_start"
      }
    }
  },
  [3] = {
    conditions = {
      {
        type = 11,
        soldierId = 302,
        level = 1
      }
    },
    steps = {
      {
        type = 2,
        style = 1,
        uiId = 26,
        nodeName = "Panel_btm_btns",
        childId = {3}
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00032"
      },
      {
        type = 2,
        style = 1,
        uiId = 6,
        nodeName = "tab3"
      },
      {
        type = 2,
        style = 1,
        uiId = 6,
        nodeName = "Button_soldier2"
      },
      {
        type = 2,
        style = 1,
        uiId = 6,
        nodeName = "Button_upgrade"
      },
      {
        type = 2,
        style = 1,
        uiId = 50,
        nodeName = "Button_confirm",
        pause = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00026"
      }
    }
  },
  [4] = {
    conditions = {
      {
        type = 15,
        soldierId = 302,
        num = 1
      }
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00027"
      },
      {
        type = 2,
        style = 1,
        uiId = 6,
        nodeName = "Button_train"
      },
      {
        type = 2,
        style = 1,
        uiId = 64,
        nodeName = "Button_add"
      },
      {
        type = 2,
        style = 1,
        uiId = 64,
        nodeName = "Button_add"
      },
      {
        type = 2,
        style = 1,
        uiId = 64,
        nodeName = "Button_add"
      },
      {
        type = 2,
        style = 1,
        uiId = 64,
        nodeName = "Button_add"
      },
      {
        type = 2,
        style = 1,
        uiId = 64,
        nodeName = "Button_add"
      },
      {
        type = 2,
        style = 1,
        uiId = 64,
        nodeName = "Button_add"
      },
      {
        type = 2,
        style = 1,
        uiId = 64,
        nodeName = "Button_add"
      },
      {
        type = 2,
        style = 1,
        uiId = 64,
        nodeName = "Button_clear"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00030",
        pause = true
      },
      {
        type = 2,
        style = 1,
        uiId = 6,
        nodeName = "Button_back"
      }
    }
  },
  [5] = {
    conditions = {
      {type = 1, cityId = 1002}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00035",
        sound = 2007
      },
      {
        type = 2,
        style = 1,
        uiId = 26,
        nodeName = "Button_right1"
      },
      {
        type = 2,
        style = 1,
        uiId = 1,
        nodeName = "Button_3"
      },
      {
        type = 2,
        style = 1,
        uiId = 44,
        nodeName = "Button_start_3"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00085"
      },
      {
        type = 2,
        style = 1,
        uiId = 65,
        nodeName = "ListView2",
        childId = {1, 11}
      },
      {
        type = 2,
        style = 1,
        uiId = 65,
        nodeName = "ListView2",
        childId = {2, 11}
      },
      {
        type = 2,
        style = 1,
        uiId = 65,
        nodeName = "Button_start"
      }
    }
  },
  [6] = {
    conditions = {
      {
        type = 4,
        taskId = 100,
        state = 2
      }
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00039"
      },
      {
        type = 2,
        style = 1,
        uiId = 26,
        nodeName = "Panel_btm_btns",
        childId = {4}
      },
      {
        type = 2,
        style = 1,
        uiId = 2,
        nodeName = "ListView",
        childId = {
          1,
          11,
          "Image_bg",
          2
        }
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00040"
      }
    }
  },
  [51] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 26,
        nodeName = "Button_right1"
      }
    }
  },
  [52] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 26,
        nodeName = "Panel_btm_btns",
        childId = {4}
      }
    }
  },
  [53] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 26,
        nodeName = "Button_right4"
      }
    }
  },
  [61] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_1",
        childId = {1}
      }
    }
  },
  [62] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_2",
        childId = {1}
      }
    }
  },
  [63] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_3",
        childId = {1}
      }
    }
  },
  [64] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_4",
        childId = {1}
      }
    }
  },
  [65] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_5",
        childId = {1}
      }
    }
  },
  [66] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_6",
        childId = {1}
      }
    }
  },
  [67] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 31,
        nodeName = "Button_skill1"
      }
    }
  },
  [68] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 31,
        nodeName = "Button_skill2"
      }
    }
  },
  [69] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 31,
        nodeName = "Button_skill3"
      }
    }
  },
  [70] = {
    steps = {
      {
        type = 4,
        style = 1,
        uiId = 31,
        nodeName = "Button_skill4"
      }
    }
  },
  [100] = {
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00036",
        enableUI = false
      },
      {
        type = 2,
        style = 1,
        uiId = 26,
        nodeName = "Button_collect",
        enableUI = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00037"
      }
    }
  },
  [101] = {
    conditions = {
      {type = 12}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00041",
        uiId = 1,
        nodeName = "Tab2",
        color = 1
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00042",
        save = true
      }
    }
  },
  [102] = {
    conditions = {
      {type = 12}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00038"
      },
      {
        type = 2,
        style = 1,
        uiId = 3,
        nodeName = "Image_goldnote",
        save = true,
        needCallback = false
      }
    }
  },
  [103] = {
    conditions = {
      {type = 12}
    },
    steps = {
      {
        type = 3,
        style = 3,
        title = "t00049",
        content = "t00016",
        image = {
          "UI/tips/mode_fangong"
        },
        save = true
      }
    }
  },
  [104] = {
    conditions = {
      {type = 14, achieveId = 204}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00045"
      },
      {
        type = 2,
        style = 1,
        uiId = 43,
        nodeName = "Button_supply"
      },
      {
        type = 2,
        style = 1,
        uiId = 53,
        nodeName = "Button_3"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00046"
      }
    }
  },
  [105] = {
    steps = {
      {
        type = 3,
        style = 3,
        title = "t00050",
        content = "t00010",
        image = {
          "UI/tips/unlock_arena"
        },
        enableUI = false
      },
      {
        type = 2,
        style = 1,
        uiId = 26,
        nodeName = "Button_arena",
        enableUI = true
      }
    }
  },
  [107] = {
    steps = {
      {
        type = 3,
        style = 3,
        title = "t00049",
        content = "t00011",
        image = {
          "UI/tips/other_fangong"
        },
        spine = {
          {
            file = "Spine/UI_effect/UI_guanqiatubiao_02",
            ani = "animation02",
            pos = cc.p(190, 150),
            scale = 0.7
          }
        }
      }
    }
  },
  [110] = {
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00047",
        enableUI = false
      },
      {
        type = 2,
        style = 1,
        uiId = 26,
        nodeName = "Button_right2",
        enableUI = true
      }
    }
  },
  [113] = {
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00034",
        enableUI = false
      },
      {
        type = 2,
        style = 1,
        uiId = 26,
        nodeName = "Panel_btm_btns",
        childId = {5},
        enableUI = true
      }
    }
  },
  [115] = {
    conditions = {
      {type = 12}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00048"
      },
      {
        type = 2,
        style = 1,
        uiId = 29,
        nodeName = "Button_set"
      },
      {
        type = 2,
        style = 1,
        uiId = 49,
        nodeName = "ListView",
        childId = {
          1,
          11,
          "icon"
        }
      },
      {
        type = 2,
        style = 1,
        uiId = 49,
        nodeName = "Panel_hero1",
        needCallback = false
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00049",
        save = true
      }
    }
  },
  [116] = {
    conditions = {
      {type = 14, achieveId = 200}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00043"
      },
      {
        type = 2,
        style = 1,
        uiId = 17,
        nodeName = "Button_upgrade_1"
      },
      {
        type = 2,
        style = 1,
        uiId = 17,
        nodeName = "ListView",
        childId = {
          1,
          11,
          1,
          "icon"
        }
      },
      {
        type = 2,
        style = 1,
        uiId = 17,
        nodeName = "Button_yes_4"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00044"
      }
    }
  },
  [117] = {
    conditions = {
      {type = 12}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00065",
        save = true
      },
      {
        type = 2,
        style = 1,
        uiId = 57,
        nodeName = "dikuang_2",
        childId = {"Button_go"}
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00031"
      },
      {
        type = 2,
        style = 1,
        uiId = 6,
        nodeName = "Button_upgrade"
      }
    }
  },
  [6000] = {
    conditions = {
      {type = 8}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00066"
      },
      {
        type = 2,
        style = 1,
        uiId = 36,
        nodeName = "ListView",
        childId = {
          1,
          11,
          1
        }
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(500, 800),
        size = cc.size(150, 150)
      },
      {
        type = 2,
        style = 1,
        uiId = 36,
        nodeName = "role3"
      },
      {
        type = 2,
        style = 1,
        uiId = 36,
        nodeName = "ListView",
        childId = {
          1,
          11,
          1
        }
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(600, 800),
        size = cc.size(150, 150)
      },
      {
        type = 2,
        style = 1,
        uiId = 36,
        nodeName = "hero_tab"
      },
      {
        type = 2,
        style = 1,
        uiId = 36,
        nodeName = "ListView",
        childId = {
          1,
          11,
          1
        }
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(700, 800),
        size = cc.size(150, 150)
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00067"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00068",
        uiId = 36,
        nodeName = "Node_guide",
        size = cc.size(250, 50),
        color = 1
      }
    }
  },
  [6020] = {
    conditions = {
      {type = 12}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00069",
        uiId = 28,
        pos = cc.p(1038, 820),
        size = cc.size(250, 300),
        color = 1
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00070",
        save = true
      }
    }
  },
  [8010] = {
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "a00241",
        enableUI = false
      },
      {
        type = 2,
        style = 3,
        uiId = 31,
        nodeName = {
          "BloodLabelNode",
          "CoinLabelNode",
          "PopuLabelNode",
          "RoundNode"
        },
        text = {
          "t00004",
          "t00005",
          "t00006",
          "t00020"
        },
        needCallback = false,
        pause = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "a00242"
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(1250, 407),
        size = cc.size(150, 150),
        pause = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "a00243"
      },
      {
        type = 2,
        style = 1,
        uiId = 31,
        nodeName = "EnemyTip",
        pause = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "a00244"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "a00245"
      },
      {
        type = 2,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_1",
        childId = {1},
        enableUI = true
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(700, 400),
        size = cc.size(150, 150)
      },
      {
        type = 2,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_2",
        childId = {1}
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(700, 350),
        size = cc.size(150, 150)
      }
    }
  },
  [999] = {
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00050",
        enableUI = false,
        pause = true,
        sound = 2001
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00051",
        pause = true,
        uiId = 28,
        pos = cc.p(2500, 800),
        size = cc.size(200, 250),
        color = 2
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00052",
        uiId = 28,
        pos = cc.p(2050, 730),
        size = cc.size(500, 400),
        color = 2
      },
      {
        type = 1,
        style = 2,
        icon = "UI/touxiang/dialog/1.png",
        name = "mo00050",
        content = "wo00053",
        pause = true
      },
      {
        type = 1,
        style = 2,
        icon = "UI/touxiang/dialog/1.png",
        name = "mo00050",
        content = "wo00054"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00055"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/6.png",
        name = "he00001",
        content = "wo00056"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00057",
        pause = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00058"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/6.png",
        name = "he00001",
        content = "wo00059"
      },
      {
        type = 1,
        style = 2,
        icon = "UI/touxiang/dialog/1.png",
        name = "mo00050",
        content = "wo00060"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00061",
        uiId = 28,
        pos = cc.p(630, 650),
        size = cc.size(150, 150),
        color = 1
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(1250, 600),
        size = cc.size(150, 150),
        needCallback = false,
        pause = true,
        sound = 2002
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00064"
      },
      {
        type = 2,
        style = 1,
        uiId = 31,
        nodeName = "Button_skill1",
        needCallback = false,
        enableUI = true,
        sound = 2003
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(1470, 700),
        size = cc.size(150, 150),
        needCallback = false,
        pause = true
      },
      {
        type = 1,
        style = 2,
        icon = "UI/touxiang/dialog/1.png",
        name = "mo00050",
        content = "wo00062"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00063"
      }
    }
  },
  [1000] = {
    conditions = {
      {type = 1, cityId = 1000}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00112",
        pause = true,
        enableUI = false,
        sound = 2005
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00106"
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(2400, 660),
        size = cc.size(150, 150),
        delay = 2
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00107",
        pause = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00110"
      },
      {
        type = 2,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_1",
        childId = {1},
        enableUI = true,
        sound = 2006
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(1050, 550),
        size = cc.size(150, 150)
      },
      {
        type = 2,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_2",
        childId = {1}
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(1050, 550),
        size = cc.size(150, 150)
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00111",
        sound = 2004,
        pause = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00113"
      },
      {
        type = 2,
        style = 1,
        uiId = 31,
        nodeName = "Button_skill1",
        needCallback = false,
        enableUI = true,
        sound = 2003
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(2500, 700),
        size = cc.size(150, 150),
        needCallback = false,
        pause = true
      }
    }
  },
  [1001] = {
    conditions = {
      {type = 1, cityId = 1001}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00102",
        pause = true,
        enableUI = false
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(2550, 400),
        size = cc.size(150, 150),
        delay = 2
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00103"
      },
      {
        type = 2,
        style = 1,
        uiId = 31,
        nodeName = "Button_kezhi",
        pause = true,
        enableUI = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00104"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00105"
      }
    }
  },
  [1002] = {
    conditions = {
      {type = 1, cityId = 1002}
    },
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00100"
      }
    }
  },
  [1004] = {
    conditions = {
      {type = 1, cityId = 1004}
    },
    steps = {
      {
        type = 3,
        style = 3,
        title = "a00136",
        content = "t00013",
        image = {
          "UI/tips/mode_fangshou"
        }
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00071",
        sound = 2009
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00072",
        pause = true
      },
      {
        type = 1,
        style = 2,
        icon = "UI/touxiang/dialog/5.png",
        uiId = 28,
        pos = cc.p(980, 460),
        size = cc.size(100, 150),
        color = 1,
        pause = true
      },
      {
        type = 1,
        style = 2,
        icon = "UI/touxiang/dialog/5.png",
        uiId = 28,
        pos = cc.p(2160, 480),
        size = cc.size(100, 150),
        color = 1,
        pause = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00073",
        sound = 2010
      }
    }
  },
  [1008] = {
    conditions = {
      {type = 1, cityId = 1008}
    },
    steps = {
      {
        type = 3,
        style = 3,
        title = "a00138",
        content = "t00015",
        image = {
          "UI/tips/mode_shouji"
        },
        enableUI = false
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00074",
        pause = true,
        sound = 2011
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00076",
        uiId = 31,
        nodeName = "ResNode",
        childId = {"Res1"},
        size = cc.size(280, 200),
        color = 1
      },
      {
        type = 2,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_1",
        childId = {1},
        needCallback = false,
        enableUI = true
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(1850, 750),
        size = cc.size(150, 150),
        pause = true,
        needCallback = false,
        enableUI = false
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00077",
        uiId = 28,
        pos = cc.p(715, 1330),
        size = cc.size(250, 200),
        color = 1
      },
      {
        type = 2,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_2",
        childId = {1},
        enableUI = true,
        needCallback = false
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(300, 1200),
        size = cc.size(150, 150),
        needCallback = false
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(280, 1050),
        size = cc.size(150, 150),
        delay = 1,
        needCallback = false
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00078"
      }
    }
  },
  [1009] = {
    conditions = {
      {type = 1, cityId = 1009}
    },
    steps = {
      {
        type = 3,
        style = 3,
        title = "a00137",
        content = "t00014",
        image = {
          "UI/tips/mode_zhanling"
        },
        enableUI = false
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00079",
        pause = true,
        sound = 2012
      },
      {
        type = 1,
        style = 2,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00080",
        uiId = 28,
        pos = cc.p(2260, 1255),
        size = cc.size(300, 250),
        color = 1
      },
      {
        type = 2,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_2",
        childId = {1},
        needCallback = false,
        enableUI = true
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(2260, 1255),
        size = cc.size(150, 150),
        needCallback = false,
        enableUI = false
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00081"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00082",
        pause = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00083"
      },
      {
        type = 2,
        style = 1,
        uiId = 31,
        nodeName = "SoldierBtn_1",
        childId = {1},
        needCallback = false,
        enableUI = true
      },
      {
        type = 2,
        style = 1,
        uiId = 28,
        pos = cc.p(2060, 755),
        size = cc.size(150, 150),
        needCallback = false,
        enableUI = false,
        pause = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/5.png",
        content = "wo00084",
        uiId = 28,
        pos = cc.p(255, 180),
        size = cc.size(300, 250),
        color = 1,
        enableUI = true
      }
    }
  },
  [1011] = {
    steps = {
      {
        type = 1,
        style = 2,
        icon = "UI/touxiang/dialog/1.png",
        name = "",
        content = "wo00259"
      },
      {
        type = 3,
        style = 4,
        csb = "CCS/tips/TipBoss1.csb",
        pause = true,
        title = "t00058",
        content = {
          "t00063",
          "t00064",
          "t00065",
          "t00066"
        }
      },
      {
        type = 1,
        style = 2,
        icon = "UI/touxiang/dialog/1.png",
        name = "",
        content = "wo00260",
        pause = true
      },
      {
        type = 1,
        style = 2,
        icon = "UI/touxiang/dialog/1.png",
        name = "",
        content = "wo00261",
        pause = true
      },
      {
        type = 1,
        style = 2,
        icon = "UI/touxiang/dialog/1.png",
        name = "",
        content = "wo00262"
      }
    }
  },
  [1023] = {
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/3.png",
        name = "",
        content = "wo00263"
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/4.png",
        name = "",
        content = "wo00264"
      },
      {
        type = 3,
        style = 4,
        csb = "CCS/tips/TipBoss2.csb",
        title = "t00058",
        content = {
          "t00067",
          "t00068",
          "t00069"
        },
        enableUI = true
      }
    }
  },
  [1031] = {
    steps = {
      {
        type = 1,
        icon = "UI/touxiang/dialog/2.png",
        name = "",
        content = "wo00265",
        pause = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/2.png",
        name = "",
        content = "wo00266",
        pause = true
      },
      {
        type = 1,
        icon = "UI/touxiang/dialog/2.png",
        name = "",
        content = "wo00267",
        enableUI = true
      }
    }
  }
}
function GetGuideConfig(id)
  return clone(guide_config[id])
end
