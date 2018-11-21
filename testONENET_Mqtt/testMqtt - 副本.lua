--- testMqtt
-- @module testMqtt
-- @author ??
-- @license MIT
-- @copyright openLuat.com
-- @release 2017.10.24

module(..., package.seeall)

require "mqtt"

require "misc"
require "utils"
require "pm"
--require "math"

require"ntp"


ntp.timeSync()



-- 这里请填写修改为自己的IP和端口
local host, port = "183.230.40.39", 6002

local uartTemp
local uartTH

-- 串口ID,串口读缓冲区
local UART_ID, readQueue = 1, {}
-- 串口超时，串口准备好后发布的消息
local uartimeout, recvReady = 1000, "UART_RECV_ID"

local function msgPack()

		--[[
    local temp=math.random(0,80)-20
    print("Temp:",temp)
    local humi=20 --math.random(0,100)
    print("Humi:",humi)
    ]]
    local str = table.concat(readQueue)
    -- 串口的数据读完后清空缓冲区
    readQueue = {}
    
    log.info("recv:" .. str)
    
    if #str>0 then
    local temp,humi = string.match(str,"Temp:(%w*\.%w*),Humi:(%w*)")
    --a,b=string.find(str,"Temp:(%d+)")
        
    log.info(temp .. "-----" .. humi)
    
    
    local torigin ={Temp=temp ,Humi=humi}

		
    local msg =json.encode(torigin)

    print("json data",msg)

    local len = msg.len(msg)

    buf = pack.pack("bbbA", 0x03,0x00,len,msg)

    return buf
    else
    return ""
    end

end


-- 测试MQTT的任务代码
sys.taskInit(function()
    --math.randomseed(os.time())
    while not socket.isReady() do sys.wait(1000) end
    local mqttc = mqtt.client("503964186", 300, "187777", "001",0)
    while true do
        while not mqttc:connect(host, port) do sys.wait(2000) end
        if mqttc:subscribe(string.format("/device/%s/req", misc.getImei())) then
            if mqttc:publish(string.format("/device/%s/report", misc.getImei()), "test publish " .. os.time()) then
                readQueue = {}
                while true do
                	--if sys.waitUntil("UART1_RECEIVE", 60000) then
                	  local msg=msgPack()
                	  if #msg>0 then
                	  local result = mqttc:publish("$dp",msg,0)
			              if result then
					              log.info("onenet send","success")
			              else
					              log.info("onenet send","failed")
	                  end
	                  else
					              log.info("msg is empty","failed")
	                  end-- #msg=0
                  --else
                  --    log.info("uart read wait timeout!")
                  --end
                  sys.wait(10000)
                
                --[[    local r, data, param = mqttc:receive(120000, "pub_msg")
                    if r then
                        log.info("这是收到了服务器下发的消息:", data.payload or "nil")
                    elseif data == "pub_msg" then
                        log.info("这是收到了订阅的消息和参数显示:", data, param)
                        mqttc:publish(string.format("/device/%s/resp", misc.getImei()), "response " .. param)
                    elseif data == "timeout" then
                        log.info("这是等待超时主动上报数据的显示!")
                        mqttc:publish(string.format("/device/%s/report", misc.getImei()), "test publish " .. os.time())
                    end
                  --]]  
                    
                end --while end
            end
        end
        mqttc:disconnect()
    end
end)

-- 测试代码,用于发送消息给socket
sys.taskInit(function()
    while true do
        sys.publish("pub_msg", "11223344556677889900AABBCCDDEEFF" .. os.time())
        --sys.publish("$dp","")
        sys.wait(180000)
    end
end)

-------------------------------------------- 配置串口 --------------------------------------------

--保持系统处于唤醒状态，不会休眠
pm.wake("mcuart")
uart.setup(UART_ID, 115200, 8, uart.PAR_NONE, uart.STOP_1)

uart.on(1, "receive", function(uid)
    --log.info("receive temp&Humi")
    uartTH=uart.read(uid, "*l")
    --log.info("receive temp&Humi" .. uartTH)
    --sys.publish("UART1_RECEIVE")
    table.insert(readQueue, uartTH)
    
    --sys.timerStart(sys.publish, uartimeout, recvReady)
end)