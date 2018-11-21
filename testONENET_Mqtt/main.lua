--必须在这个位置定义PROJECT和VERSION变量
--PROJECT：ascii string类型，可以随便定义，只要不使用,就行
--VERSION：ascii string类型，如果使用Luat物联云平台固件升级的功能，必须按照"X.X.X"定义，X表示1位数字；否则可随便定义
PROJECT = "ONENET_MQTT_TEST"
VERSION = "2.0.5"
-- 日志级别
require "log"
LOG_LEVEL = log.LOGLEVEL_TRACE

require "sys"

require "utils"
require "patch"
require "pins"

-- 加载GSM
require "net"
--8秒后查询第一次csq
net.startQueryAll(8 * 1000, 600 * 1000)
-- 控制台
require "console"
console.setup(1, 115200)
-- 系统工具
require "misc"

--加载网络指示灯功能模块
--根据自己的项目需求和硬件配置决定：1、是否加载此功能模块；2、配置指示灯引脚
--合宙官方出售的Air800和Air801开发板上的指示灯引脚为pio.P0_28，Air268F开发板上的指示灯引脚为KP_LEDR，其他开发板上的指示灯引脚为pio.P1_1
--MODULE_TYPE = "Air268F"
--MODULE_TYPE = "Air8XX"
require "netLed"
netLed.setup(true,MODULE_TYPE=="Air268F" and (function(value) pmd.ldoset(value,pmd.KP_LEDR) end) or (MODULE_TYPE=="Air8XX" and pio.P0_28 or pio.P1_1))
--网络指示灯功能模块中，默认配置了各种工作状态下指示灯的闪烁规律，参考netLed.lua中ledBlinkTime配置的默认值
--如果默认值满足不了需求，此处调用netLed.updateBlinkTime去配置闪烁时长

-- 看门狗
require "wdt"
wdt.setup(pio.P0_30, pio.P0_31)

--加载应用功能模块
require "testMqtt"
--require "uartRecv"

require "ntp"
ntp.timeSync(1,function()log.info("----------------> AutoTimeSync is Done ! <----------------")end)
-- 启动系统框架
sys.init(0, 0)
sys.run()
