
local validator = require("resty.validator")
local ut = require("Test.More")
local cjson = require("cjson")

local bind   = validator.bind
local NUMBER = validator.NUMBER
local STRING = validator.STRING
local ARRAY  = validator.ARRAY
local OBJECT = validator.OBJECT
local STRINGIFY_ARRAY  = validator.STRINGIFY_ARRAY
local STRINGIFY_OBJECT = validator.STRINGIFY_OBJECT


local function number_required()
    local binding = {
        appid = {
            type = NUMBER,
            required = true
        }
    }

    local ok, res, err = bind(binding, { appid = 1 })
    ut.ok(ok, "number_required")
    ut.is(res.appid, 1, "number_required")

    local ok, res, err = bind(binding, { })
    ut.nok(ok, "number_required")
    ut.is(res, nil, "number_required")
end

local function number_nonrequired()
    local binding = {
        appid = {
            type = NUMBER
        }
    }

    local ok, res, err = bind(binding, { })
    ut.ok(ok, "number_nonrequired")
    ut.is(res.appid, nil, "number_nonrequired")
end

local function number_default()
    local binding = {
        appid = {
            type = NUMBER,
            default = 0
        }
    }

    local ok, res, err = bind(binding, { appid = 1 })
    ut.ok(ok, "number_default")
    ut.is(res.appid, 1, "number_default")

    local ok, res, err = bind(binding, { })
    ut.ok(ok, "number_default")
    ut.is(res.appid, 0, "number_default")
end

local function number_err_msg()
    local binding = {
        appid = {
            type = NUMBER,
            required = true,
            err_msg = "You must provide the appid"
        }
    }

    local ok, res, err = bind(binding, { })
    ut.nok(ok, "number_err_msg")
    ut.is(res, nil, "number_err_msg")
    ut.like(err, "must provide", "number_err_msg")
end

local function number_checker()
    local binding = {
        appid = {
            type = NUMBER,
            checker = function(val) return val > 5, "error" end
        }
    }

    local ok, res, err = bind(binding, { appid = 6 })
    ut.ok(ok, "number_checker")

    local ok, res, err = bind(binding, { appid = 1 })
    ut.nok(ok, "number_checker")
    ut.is(err, "error", "number_checker")
end

local function number_string_input()
    local binding = {
        appid = {
            type = NUMBER,
            required = true
        }
    }

    local ok, res, err = bind(binding, { appid = "1" })
    ut.ok(ok, "number_string_input")
    ut.is(res.appid, 1, "number_string_input")

    local ok, res, err = bind(binding, { appid = "a"})
    ut.nok(ok, "number_string_input")
    ut.is(res, nil, "number_string_input")
end

local function number_pre()
    local binding = {
        appid = {
            type = NUMBER,
            pre = function(val) return val + 5 end,
            checker = function(val) return val == 10 end
        }
    }

    local ok, res, err = bind(binding, { appid = 5 })
    ut.ok(ok, "number_pre")
    ut.is(res.appid, 10, "number_pre")
end

local function number_post()
    local binding = {
        appid = {
            type = NUMBER,
            post = function(val) return val + 5 end
        }
    }

    local ok, res, err = bind(binding, { appid = 5 })
    ut.ok(ok, "number_post")
    ut.is(res.appid, 10, "number_post")
end



local function string_required()
    local binding = {
        name = {
            type = STRING,
            required = true
        }
    }

    local ok, res, err = bind(binding, { name = "" })
    ut.ok(ok, "string_required")
    ut.is(res.name, "", "string_required")

    local ok, res, err = bind(binding, { })
    ut.nok(ok, "string_required")
    ut.is(res, nil, "string_required")
end

local function string_nonrequired()
    local binding = {
        name = {
            type = STRING
        }
    }

    local ok, res, err = bind(binding, { })
    ut.ok(ok, "string_nonrequired")
    ut.is(res.name, nil, "string_nonrequired")
end

local function string_default()
    local binding = {
        name = {
            type = STRING,
            default = "unknown"
        }
    }

    local ok, res, err = bind(binding, { })
    ut.ok(ok, "string_default")
    ut.is(res.name, "unknown", "string_default")
end

local function string_err_msg()
    local binding = {
        name = {
            type = STRING,
            required = true,
            err_msg = "You must provide the name"
        }
    }

    local ok, res, err = bind(binding, { })
    ut.nok(ok, "string_err_msg")
    ut.like(err, "must provide", "string_err_msg")
end

local function string_checker()
    local binding = {
        name = {
            type = STRING,
            checker = function(val) return string.match(val, "one") end
        }
    }

    local ok, res, err = bind(binding, { name = "two three"})
    ut.nok(ok, "string_checker")

    local ok, res, err = bind(binding, { name = "one two three"})
    ut.ok(ok, "string_checker")
end

local function string_minlength()
    local binding = {
        name = {
            type = STRING,
            minlength = 2
        }
    }

    local ok, res, err = bind(binding, { name = " 12 " })
    ut.ok(ok, "string_minlength")
    ut.is(res.name, "12", "string_minlength")

    local ok, res, err = bind(binding, { name = " 1 " })
    ut.nok(ok, "string_minlength")
    ut.is(res, nil, "string_minlength")
end

local function string_maxlength()
    local binding = {
        name = {
            type = STRING,
            maxlength = 2
        }
    }

    local ok, res, err = bind(binding, { name = " 12" })
    ut.ok(ok, "string_maxlength")
    ut.is(res.name, "12", "string_maxlength")

    local ok, res, err = bind(binding, { name = " 123 " })
    ut.nok(ok, "string_maxlength")
    ut.is(res, nil, "string_maxlength")
end

local function string_pre()
    local binding = {
        name = {
            type = STRING,
            pre = string.upper,
            checker = function(val) return val == "JACK" end
        }
    }

    local ok, res, err = bind(binding, { name = "jack" })
    ut.ok(ok, "string_pre")
    ut.is(res.name, "JACK", "string_pre")
end

local function string_post()
    local binding = {
        name = {
            type = STRING,
            post = string.upper
        }
    }

    local ok, res, err = bind(binding, { name = "jack" })
    ut.ok(ok, "string_post")
    ut.is(res.name, "JACK", "string_post")
end



local function object_required()
    local binding = {
        module = {
            type = OBJECT,
            required = true,
            struct = {
                type = {
                    type = STRING
                },
                id = {
                    type = NUMBER
                }
            }
        }
    }

    local ok, res, err = bind(binding, { module = { type = "audio", id = 1 } })
    ut.ok(ok, "object_required")
    ut.is(res.module.type, "audio", "object_required")
    ut.is(res.module.id, 1, "object_required")

    local ok, res, err = bind(binding, { })
    ut.nok(ok, "object_required")
    ut.is(res, nil, "object_required")
end

local function object_nonrequired()
    local binding = {
        module = {
            type = OBJECT,
            struct = {
                type = {
                    type = STRING
                },
                id = {
                    type = NUMBER
                }
            }
        }
    }

    local ok, res, err = bind(binding, { })
    ut.ok(ok, "object_nonrequired")
    ut.is(res.module, nil, "object_nonrequired")
end

local function object_default()
    local binding = {
        module = {
            type = OBJECT,
            default = { type = "audio", id = 1 },
            struct = {
                type = {
                    type = STRING
                },
                id = {
                    type = NUMBER
                }
            }
        }
    }

    local ok, res, err = bind(binding, { })
    ut.ok(ok, "object_default")
    ut.is(res.module.type, "audio", "object_default")
    ut.is(res.module.id, 1, "object_default")
end

local function object_err_msg()
    local binding = {
        module = {
            type = OBJECT,
            required = true,
            struct = {
                type = {
                    type = STRING
                },
                id = {
                    type = NUMBER
                }
            },
            err_msg = "You must provide module infomation"
        }
    }

    local ok, res, err = bind(binding, { })
    ut.nok(ok, "object_err_msg")
    ut.like(err, "must provide", "object_err_msg")
end

local function object_checker()
    local binding = {
        module = {
            type = OBJECT,
            struct = {
                type = {
                    type = STRING
                },
                id = {
                    type = NUMBER
                }
            },
            checker = function(obj) return obj.type == "audio" and obj.id == 1, "error" end
        }
    }

    local ok, res, err = bind(binding, { module = { type = "album", id = 1 }})
    ut.nok(ok, "object_checker")
    ut.is(err, "error", "object_checker")

    local ok, res, err = bind(binding, { module = { type = "audio", id = 1 }})
    ut.ok(ok, "object_checker")
end

local function object_pre()
    local binding = {
        module = {
            type = OBJECT,
            struct = {
                type = {
                    type = STRING
                },
                id = {
                    type = NUMBER
                }
            },
            pre = function(obj)
                        obj.type = string.upper(obj.type)
                        obj.id = obj.id * 10
                        return obj
                  end,
            checker = function(obj) return obj.type == "AUDIO" and obj.id == 10, "error" end
        }
    }

    local ok, res, err = bind(binding, { module = { type = "audio", id = 1 }})
    ut.ok(ok, "object_pre")
    ut.is(res.module.type, "AUDIO", "object_pre")
    ut.is(res.module.id, 10, "object_pre")
end

local function object_post()
    local binding = {
        module = {
            type = OBJECT,
            struct = {
                type = {
                    type = STRING
                },
                id = {
                    type = NUMBER
                }
            },
            post = function(obj)
                        obj.type = string.upper(obj.type)
                        obj.id = obj.id * 10
                        return obj
                  end
        }
    }

    local ok, res, err = bind(binding, { module = { type = "audio", id = 1 }})
    ut.ok(ok, "object_post")
    ut.is(res.module.type, "AUDIO", "object_post")
    ut.is(res.module.id, 10, "object_post")
end



local function array_required()
    local binding = {
        lists = {
            type = ARRAY,
            required = true,
            element = {
                type = NUMBER,
                struct = {
                    err_msg = "error",
                    checker = function(val) return val > 0, "gt 2" end
                }
            }
        }
    }

    local ok, res, err = bind(binding, { lists = { 1, 2 } })
    ut.ok(ok, "array_required")
    ut.is(#res.lists, 2, "array_required")
    ut.is(res.lists[1], 1, "array_required")
    ut.is(res.lists[2], 2, "array_required")

    local ok, res, err = bind(binding, { })
    ut.nok(ok, "array_required")
end

local function array_nonrequired()
    local binding = {
        lists = {
            type = ARRAY,
            required = false,
            element = {
                type = NUMBER,
                struct = {
                    err_msg = "error",
                    checker = function(val) return val > 0, "gt 2" end
                }
            }
        }
    }

    local ok, res, err = bind(binding, { })
    ut.ok(ok, "array_nonrequired")
end

local function array_default()
    local binding = {
        lists = {
            type = ARRAY,
            default = { 1 },
            element = {
                type = NUMBER,
                struct = {
                    err_msg = "error",
                    checker = function(val) return val > 0, "gt 2" end
                }
            }
        }
    }

    local ok, res, err = bind(binding, { })
    ut.ok(ok, "array_default")
    ut.is(#res.lists, 1, "array_default")
    ut.is(res.lists[1], 1, "array_default")
end

local function array_err_msg()
    local binding = {
        lists = {
            type = ARRAY,
            required = true,
            element = {
                type = NUMBER,
                struct = {
                    checker = function(val) return val > 0, "gt 2" end
                }
            },
            err_msg = "You must provide the lists"
        }
    }

    local ok, res, err = bind(binding, { })
    ut.nok(ok, "array_err_msg")
    ut.like(err, "must provide", "array_err_msg")
end

local function array_checker()
    local binding = {
        lists = {
            type = ARRAY,
            required = true,
            element = {
                type = NUMBER,
                checker = function(val) return val > 1, "gt 2" end
            }
        }
    }

    local ok, res, err = bind(binding, { lists = { 0 } })
    ut.nok(ok, "array_checker")
end

local function array_minlength()
    local binding = {
        lists = {
            type = ARRAY,
            required = true,
            minlength = 2,
            element = {
                type = NUMBER
            }
        }
    }

    local ok, res, err = bind(binding, { lists = { 1 } })
    ut.nok(ok, "array_minlength")
end

local function array_maxlength()
    local binding = {
        lists = {
            type = ARRAY,
            required = true,
            maxlength = 2,
            element = {
                type = NUMBER
            }
        }
    }

    local ok, res, err = bind(binding, { lists = { 1, 2, 3 } })
    ut.nok(ok, "array_maxlength")
end

local function array_pre()
    local binding = {
        lists = {
            type = ARRAY,
            required = true,
            element = {
                type = NUMBER
            },
            pre = function(array)
                    for idx, val in pairs(array) do
                        array[idx] = val * 10
                    end
                    return array
                  end
        }
    }

    local ok, res, err = bind(binding, { lists = { 1, 2 } })
    ut.ok(ok, "array_pre")
    ut.is(res.lists[1], 10, "array_pre")
    ut.is(res.lists[2], 20, "array_pre")
end

local function array_post()
    local binding = {
        lists = {
            type = ARRAY,
            required = true,
            element = {
                type = NUMBER
            },
            post = function(array)
                    for idx, val in pairs(array) do
                        array[idx] = val * 10
                    end
                    return array
                  end
        }
    }

    local ok, res, err = bind(binding, { lists = { 1, 2 } })
    ut.ok(ok, "array_post")
    ut.is(res.lists[1], 10, "array_post")
    ut.is(res.lists[2], 20, "array_post")
end

local function array_elem_pre()
    local binding = {
        lists = {
            type = ARRAY,
            required = true,
            element = {
                type = NUMBER,
                pre = function(val) return val * 10 end
            },
        }
    }

    local ok, res, err = bind(binding, { lists = { 1, 2 } })
    ut.ok(ok, "array_elem_pre")
    ut.is(res.lists[1], 10, "array_elem_pre")
    ut.is(res.lists[2], 20, "array_elem_pre")
end

local function array_elem_post()
    local binding = {
        lists = {
            type = ARRAY,
            required = true,
            element = {
                type = NUMBER,
                post = function(val) return val * 10 end
            },
        }
    }

    local ok, res, err = bind(binding, { lists = { 1, 2 } })
    ut.ok(ok, "array_elem_post")
    ut.is(res.lists[1], 10, "array_elem_post")
    ut.is(res.lists[2], 20, "array_elem_post")
end

local function array_string()
    local binding = {
        lists = {
            type = ARRAY,
            required = true,
            element = {
                type = STRING
            }
        }
    }

    local ok, res, err = bind(binding, { lists = { "a", "b" } })
    ut.ok(ok, "array_string")
    ut.is(res.lists[1], "a", "array_string")
    ut.is(res.lists[2], "b", "array_string")
end

local function array_number()
    local binding = {
        lists = {
            type = ARRAY,
            required = true,
            element = {
                type = NUMBER
            }
        }
    }

    local ok, res, err = bind(binding, { lists = { "1", "2" } })
    ut.ok(ok, "array_number")
    ut.is(res.lists[1], 1, "array_number")
    ut.is(res.lists[2], 2, "array_number")
end

local function array_object()
    local binding = {
        lists = {
            type = ARRAY,
            required = true,
            element = {
                type = OBJECT,
                struct = {
                    type = {
                        type = STRING,
                        checker = function(val)
                            return ({ ["audio"] = true, ["album"] = true})[val:lower()]
                        end
                    },
                    id = {
                        type = NUMBER,
                        checker = function(val) return val > 0 end
                    }
                }
            }
        }
    }

    local ok, res, err = bind(binding, {
        lists = {
            {
                type = "audio",
                id = 1
            },
            {
                type = "album",
                id = 2
            }
        }
    })

    ut.ok(ok, "array_object")
    ut.is(res.lists[1].type, "audio", "array_object")
    ut.is(res.lists[1].id,   1,       "array_object")
    ut.is(res.lists[2].type, "album", "array_object")
    ut.is(res.lists[2].id,   2,       "array_object")
end


local function stringify_array()
    local binding = {
        lists = {
            type = STRINGIFY_ARRAY,
            required = true,
            element = {
                type = OBJECT,
                struct = {
                    type = {
                        type = STRING,
                        checker = function(val)
                            return ({ ["audio"] = true, ["album"] = true})[val:lower()]
                        end
                    },
                    id = {
                        type = NUMBER,
                        required = true,
                        checker = function(val) return val > 0 end
                    }
                }
            }
        }
    }

    local ok, res, err = bind(binding, {
        lists = "[{\"type\":\"audio\",\"id\":1},{\"type\":\"album\",\"id\":2}]"
    })

    ut.ok(ok, "stringify_array")
    ut.is(res.lists[1].type, "audio", "stringify_array")
    ut.is(res.lists[1].id,   1,       "stringify_array")
    ut.is(res.lists[2].type, "album", "stringify_array")
    ut.is(res.lists[2].id,   2,       "stringify_array")
end

local function stringify_object()
    local binding = {
        module = {
            type = STRINGIFY_OBJECT,
            required = true,
            struct = {
                type = {
                    type = STRING
                },
                id = {
                    type = NUMBER
                }
            }
        }
    }

    local ok, res, err = bind(binding, { module = "{\"type\":\"audio\",\"id\":1}" })
    ut.ok(ok, "stringify_object")
    ut.is(res.module.type, "audio", "stringify_object")
    ut.is(res.module.id, 1, "stringify_object")
end


local function run_test()
  number_required()
  number_nonrequired()
  number_default()
  number_err_msg()
  number_checker()
  number_string_input()
  number_pre()
  number_post()

  string_required()
  string_nonrequired()
  string_default()
  string_err_msg()
  string_checker()
  string_minlength()
  string_maxlength()
  string_pre()
  string_post()

  object_required()
  object_nonrequired()
  object_default()
  object_err_msg()
  object_checker()
  object_pre()
  object_post()

  array_required()
  array_nonrequired()
  array_default()
  array_err_msg()
  array_checker()
  array_minlength()
  array_maxlength()
  array_pre()
  array_post()
  array_elem_pre()
  array_elem_post()
  array_string()
  array_number()
  array_object()

  stringify_array()
  stringify_object()
end

local ok, err = pcall(run_test)
if not ok then
  ngx.say('test failed: ' .. err)
else
  ngx.say('test pass')
end
