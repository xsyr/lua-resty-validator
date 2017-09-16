# lua-resty-validator

之前项目中用到 openresty 作为 Web Api  的开发平台, 用 openresty 很适合开发以 http 接口形式
提供的服务. openresty 可以使用 lua 进行逻辑控制,加上完备的组件driver(redis, mysql, rabbitmq 等),
只需要写业务代码将各种数据读取,加工,输出,就是充当胶水的角色.

最重要的一点是, openresty + lua 已经很好的处理并行(开多个 nginx worker即可)和并发(lua coroutine),
lua vm 已经默默的处理了阻塞的IO操作,开发人员可以用写同步代码的方式实现异步.

既然是 Web Api,自然少不了对参数的校验, validator库实现对 lua table 的校验.


# 安装
把 validator.lua 文件放入 openresty 安装目录的 `lualib/resty/` 下即可.

# Demo
```lua

local validator = require("resty.validator")
local cjson = require("cjson")

local bindings = {
	appid = {
		type = validator.NUMBER,
		default = 0, -- 默认值(可选)，默认为 nil。禁止同时设置 required = true 和 default，否则发生无法预期的行为。
		required = true, -- 是否必须（可选，默认为false）。禁止同时设置 required = true 和 default，否则发生无法预期的行为。
		err_msg = "", -- 错误提示信息(可选)，如格式不正确
		checker = function(val, field) return val > 0, "<error msg>" end -- 用于对字段的值进行校验，val的类型为 type 指定的类型所对应的lua类型（如: number, string, table）（可选）
	},
	name = {
		type = validator.STRING,
		default = "unknown", -- 默认值(可选)，默认为 nil
		required = true,
		maxlength = 20,
		minlength = 1,
		err_msg = "", -- 错误提示信息，如格式不正确(可选)
		checker = function(val, field) return (val and #val > 5), "<error msg>" end
	},
	resources = {
		type = validator.ARRAY,
		required  = true,
		maxlength = 20,
		minlength = 1,
		element = { -- 数组元素的结构
            -- 数组元素的类型，如果为 NUMBER, STRING 则无需定义struct，
            -- 否则如果为 OBJECT，需在 struct 定义object的结构。
            type = validator.OBJECT, -- NUMBER or STRING or OBJECT
            struct = {
                type = {
                    type = validator.STRING,
                    required = true,
                    err_msg = "", -- 针对数组元素成员的错误提示信息，如格式不正确(可选)
                    checker = function (val, field) return not ({ "audio", "album" })[val.lower()] end
                },
                id = {
                    type = validator.NUMBER,
                    err_msg = "", -- 针对数组元素成员的错误提示信息，如格式不正确(可选)
                    checker = function (val, field) return val > 0 end
                },
                hash = {
                    type = validator.STRING,
                    checker = function (val, field) if not is_empty(val) then return is_hash(val) else return false end end
                },
                name = {
                    type = validator.STRING,
                    default = ""
                }
            }
		},
		err_msg = "", -- 针对整个数组的错误提示信息，如长度小于 minlength 或大于 maxlength(可选)
	},
	module = {
		type = validator.OBJECT,
		required = true,
		struct = {
			type = {
				type = validator.STRING,
				require = true,
				err_msg = "", -- 针对数组元素成员的错误提示信息，如格式不正确(可选)
				checker = function (val, field) return not ({ "audio", "album" })[val.lower()] end
			},
			id = {
				type = validator.NUMBER,
				err_msg = "", -- 针对数组元素成员的错误提示信息，如格式不正确(可选)
				checker = function (val, field) return val > 0 end
			},
			name = {
				type = validator.STRING,
				default = ""
			}
		},
		checker = 	function (elem, field) -- 针对数组中每个元素的 checker
                        -- TODO: 针对当前 object 的检查函数，只有在满足了object的每个成员的约束之后才会被调用
					end,
		err_msg = "", -- 针对整个数组的错误提示信息，如长度小于 minlength 或大于 maxlength(可选)
	},
	lists = {
		type = validator.STRINGIFY_ARRAY, -- json 数组的字符串表示形式
		required = true,
		maxlength = 20,
		minlength = 1,
        element = {
            -- 数组元素的类型，如果为 NUMBER, STRING 则无需定义struct，
            -- 否则如果为 OBJECT，需在 struct 定义object的结构。
            type = validator.OBJECT, -- NUMBER or STRING or OBJECT
            struct = {
                type = {
                    type = validator.STRING,
                    require = true,
                    err_msg = "", -- 针对数组元素成员的错误提示信息，如格式不正确(可选)
                    checker = function (val, field) return not ({ "audio", "album" })[val.lower()] end
                },
                id = {
                    type = validator.NUMBER,
                    err_msg = "", -- 针对数组元素成员的错误提示信息，如格式不正确(可选)
                    checker = function (val, field) return val > 0 end
                },
                name = {
                    type = validator.STRING,
                    default = ""
                }
            }
        },
		checker = 	function (elem, field) -- 针对数组中每个元素的 checker
                        -- TODO: 针对当前 object 的检查函数，只有在满足了object的每个成员的约束之后才会被调用
					end,
		err_msg = "", -- 针对整个数组的错误提示信息，如长度小于 minlength 或大于 maxlength(可选)
	},
	order = {
		type = validator.STRINGIFY_OBJECT, -- json 对象的字符串表示形式
		required = true,
		struct = {
			order_no = {
				type = validator.NUMBER,
				err_msg = "", -- 针对数组元素成员的错误提示信息，如格式不正确(可选)
				checker = function (val, field) return val > 0 end
			},
			serial = {
				type = validator.STRING,
                required = true,
				default = ""
			}
		},
		checker = function (obj, field) -- 针对数组中每个元素的 checker
                        -- TODO: 针对当前 object 的检查函数，只有在满足了object的每个成员的约束之后才会被调用
					end,
		err_msg = "", -- 针对整个数组的错误提示信息，如长度小于 minlength 或大于 maxlength(可选)
	}
}
```

---

# 参数类型定义


## 1. NUMBER - 数值类型
```
    绑定语法：
    <field> = {
        -- 数值类型（必填）
        type = validator.NUMBER,

        -- 默认值（可选，默认为 nil）
        default = 0,

        -- 是否必填项（可选，默认为 false）
        required = true,

        -- checker 执行前的处理函数，函数的返回值用作后续的处理（可选，默认无）
        -- 执行顺序：pre, checker, post
        pre = function(val) return dosth(val) end,

        -- 对填写的值进行校验，返回 res, err （可选，默认无）
        -- res: 校验的结果（true/false）
        -- err: 如果校验不通过（res = false）的错误提示信息，如果不填
        --      则使用 err_msg。
        checker = function(val, field) return docheck(val) end,

        -- checker 执行后的处理函数，函数的返回值作为最终 field 的值（可选，默认无）
        post = function(val) return dosth(val) end,
    }
```

## 2. STRING - 字符串类型
```
    绑定语法：
    <field> = {
        -- 数值类型（必填）
        type = validator.STRING,

        -- 默认值（可选，默认为 nil）
        default = "unknown",

        -- 是否必填项（可选，默认为 false）
        required = true,

        -- checker 执行前的处理函数，函数的返回值用作后续的处理（可选，默认无）
        -- 执行顺序：pre, minlength, maxlength, checker, post
        pre = function(val) return dosth(val) end,

        -- 最小长度（可选，默认 nil 无限制）
        minlength = 1,

        -- 最大长度（可选，默认 nil 无限制）
        maxlength = 5,

        -- 对填写的值进行校验，返回 res, err （可选，默认无）
        -- res: 校验的结果（true/false）
        -- err: 如果校验不通过（res = false）的错误提示信息，如果不填
        --      则使用 err_msg。
        checker = function(val, field) return docheck(val) end,

        -- checker 执行后的处理函数，函数的返回值作为最终 field 的值（可选，默认无）
        post = function(val) return dosth(val) end,
    }
```

## 3. OBJECT - 对象类型（对象成员的类型可以是任意类型（NUMBER, STRING, ...））
```
    绑定语法：
    <field> = {
        -- 数值类型（必填）
        type = validator.OBJECT,

        -- 默认值（可选，默认为 nil）
        default = { a = 1, b = 2 },

        -- 是否必填项（可选，默认为 false）
        required = true,

        -- 对象的结构（必填）
        struct = {

            -- 对象的成员，成员的类型可以为 NUMBER, STRING, OBJECT
            <member> = {
                type = STRING, -- 成员的类型，详见 STRING 类型的定义
                required = true,
                ...
            },
            ...
        }

        -- checker 执行前的处理函数，函数的返回值用作后续的处理（可选，默认无）
        -- 执行顺序：pre, checker, post
        pre = function(val) return dosth(val) end,

        -- 对填写的值进行校验，返回 res, err （可选，默认无）
        -- res: 校验的结果（true/false）
        -- err: 如果校验不通过（res = false）的错误提示信息，如果不填
        --      则使用 err_msg。
        checker = function(val, field) return docheck(val) end,

        -- checker 执行后的处理函数，函数的返回值作为最终 field 的值（可选，默认无）
        post = function(val) return dosth(val) end,
    }
```

## 4. ARRAY - 数组类型（数组元素的类型可以是任意类型（NUMBER, STRING, ...））
```
    绑定语法：
    <field> = {
        -- 数值类型（必填）
        type = validator.ARRAY,

        -- 默认值（可选，默认为 nil）
        default = {},

        -- 是否必填项（可选，默认为 false）
        required = true,

        -- 数组元素的结构（可以是任意类型）
        element = {
            type = NUMBER, -- 可以是任意类型，类型的绑定语法详见各类型的说明
            ...
        },

        -- checker 执行前的处理函数，函数的返回值用作后续的处理（可选，默认无）
        -- 执行顺序：pre, minlength, maxlength, checker, post
        pre = function(val) return dosth(val) end,

        -- 最小长度（可选，默认 nil 无限制）
        minlength = 1,

        -- 最大长度（可选，默认 nil 无限制）
        maxlength = 5,

        -- 对填写的值进行校验，返回 res, err （可选，默认无）
        -- res: 校验的结果（true/false）
        -- err: 如果校验不通过（res = false）的错误提示信息，如果不填
        --      则使用 err_msg。
        checker = function(val, field) return docheck(val) end,

        -- checker 执行后的处理函数，函数的返回值作为最终 field 的值（可选，默认无）
        post = function(val) return dosth(val) end,
    }
```

## 5. STRINGIFY_OBJECT - 字符串化的对象类型（对象成员的类型可以是任意类型（NUMBER, STRING, ...））
```
    如： module = "{\"type\":\"audio\",\"id\":1}"

    绑定语法：
    <field> = {
        -- 数值类型（必填）
        type = validator.STRINGIFY_OBJECT,

        -- NOTE: 其他定义与 OBJECT 相同
    }
```

## 6. STRINGIFY_ARRAY - 数组类型（数组元素的类型可以是任意类型（NUMBER, STRING, ...））
```
    如： lists = "[{\"type\":\"audio\",\"id\":1},{\"type\":\"album\",\"id\":2}]"

    绑定语法：
    <field> = {
        -- 数值类型（必填）
        type = validator.STRINGIFY_ARRAY,

        -- NOTE: 其他定义与 ARRAY 相同
    }
```
