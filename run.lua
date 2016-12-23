--[[require("LeweiTcpClient")

LeweiTcpClient.init("02","dab6a862154c4ebfab05b845eb4b5652")


function test(p1)
   print("switch01--"..p1)
   if (p1 == '0') then gpio.write(0, gpio.HIGH)
     else gpio.write(0, gpio.LOW) end
end

function test2(p1)
   print("switch02--"..p1)
end

LeweiTcpClient.addUserSwitch(test,"switch01",1)
LeweiTcpClient.addUserSwitch(test2,"switch02",1)
]]


uart.setup(0, 19200, 8, uart.PARITY_EVEN, uart.STOPBITS_1, 0 )
--10 02 01 D3 10 03 C1
uart.write(0,0x10,0x02,0x01,0xD3,0x10,0x03,0xC1)    -- Init VFD

function vfdsend(cmd,disp)
    --uart.setup(0, 19200, 8, uart.PARITY_EVEN, uart.STOPBITS_1, 0 )
    local x1 = cmd
    x1 = bit.bxor(x1,#disp+1)
    uart.write(0,0x10,0x02,#disp+1,cmd) 
    for i=1,#disp do
        x1 = bit.bxor(x1,string.byte(disp,i))
        if string.byte(disp,i) == 0x10 then  --如果数据是0x10就多发一个
           uart.write(0,0x10)
        end
        uart.write(0,string.byte(disp,i)) 
    end
    x1 = bit.bxor(x1,0x10,0x03)

    uart.write(0,0x10,0x03,x1)
    --uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1 )
end

local function human(level)
    gpio.write(0, gpio.LOW)    -- VFD ON
    tmr.stop(1)
    tmr.start(1)        -- restart VFD Timer
end

gpio.trig(7,"up",human)     -- star check human

tmr.alarm(1, 180000, tmr.ALARM_SEMI, function()
        gpio.write(0, gpio.HIGH)    -- VFD Timer OFF
end)
    
--tm = rtctime.epoch2cal(rtctime.get())
--vfdsend(0x11,26,0,string.format("%2d",tm["hour"]+8)..":"..string.format("%02d",tm["min"])..":"..string.format("%02d",tm["sec"]))
--vfdsend(0x10,34,3,string.format("%4d",tm["year"]).." "..string.format("%2d",tm["mon"]).." "..string.format("%2d",tm["day"]))
--
--[[
tmr.alarm(0, 5000, tmr.ALARM_AUTO, function()                      
        local SCK = 5
        local SDA = 6
        local sht10 = require("SHT1x")
        local Temp,Humi =sht10.read_th(SCK,SDA)
        print("Temp="..Temp)
        print("Humi="..Humi)
        vfdsend(0x11,0,3," "..Temp.."C".."  "..Humi.."%")
        -- release module
        sht10 = nil
        end
)    
]]
week = {"SUN","MON","TUE","WED","THU","FRI","SAT"}

tmr.alarm(0, 2000, tmr.ALARM_AUTO, function()
         local si7021 = require("si7021")
          
          SDA_PIN = 6 -- sda pin, GPIO12
          SCL_PIN = 5 -- scl pin, GPIO14

          si7021.init(SDA_PIN, SCL_PIN)
          si7021.read(OSS)
          Hum = si7021.getHumidity()
          Temp = si7021.getTemperature()
          -- release module
          si7021 = nil
          _G["si7021"]=nil

          
         local tm = rtctime.epoch2cal(rtctime.get())
         --uart.write(0,0x10,0x02,0x05,0x3A,0x01,0x15,0x07,0x04,0x10,0x03,0x3B)
         local tmmin = tm["min"] + math.floor(tm["min"]/10)*6
         local tmhour = tm["hour"] + math.floor(tm["hour"]/10)*6

         vfdsend(0x3A,string.char(0x01)..string.char(tmhour)..string.char(tmmin)..string.char(0x06))

         
         vfdsend(0x35,string.char(0)..string.format("%04d/%02d/%02d", tm["year"], tm["mon"], tm["day"]).." "..week[tm["wday"]].."   Temp    Humi    "..string.format("%3.1f",Temp).."C".."   "..string.format("%3.1f",Hum).."%")
         --vfdsend(0x34,string.format("%04d/%02d/%02d", tm["year"], tm["mon"], tm["day"]).." "..week[tm["wday"]])
        end
)
