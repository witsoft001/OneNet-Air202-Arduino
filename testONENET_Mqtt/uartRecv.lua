--- 模块功能：串口功能测试(TASK版)
-- @author openLuat
-- @module uart.testUartTask
-- @license MIT
-- @copyright openLuat
-- @release 2018.10.20
require "utils"
require "pm"
require "testMqtt"
module(..., package.seeall)


-------------------------------------------- 配置串口 --------------------------------------------
-- 串口ID,串口读缓冲区
local UART_ID, sendQueue = 1, {}
-- 串口超时，串口准备好后发布的消息
local uartimeout, recvReady = 25, "UART_RECV_ID"
--保持系统处于唤醒状态，不会休眠
pm.wake("mcuart")
uart.setup(UART_ID, 115200, 8, uart.PAR_NONE, uart.STOP_1)

uart.on(1, "receive", function(uid)
    log.info("receive temp")
    msgPack(uart.read(uid, 1460))
    --table.insert(sendQueue, uart.read(uid, 1460))
    --sys.timerStart(sys.publish, uartimeout, recvReady)
end)

