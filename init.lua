-- Copyright (c) 2016 dy008
-- https://github.com/dy008/NodeMcuForLEWEI50Test
--

gpio.write(0, gpio.LOW)    -- VFD ON
gpio.mode(0, gpio.OUTPUT)
gpio.mode(8, gpio.INT)    -- 感应输入

print("Connecteing To wifi...")
enduser_setup.start(
  function()
    print("Connected to wifi as:" .. wifi.sta.getip())
    print("Let's Go...")
    sntp.sync('1.pool.ntp.org',
        function(sec, usec, server, info)
        rtctime.set(sec+28800, usec)
        print('sync', sec, usec, server)
        end,
        
        function()
        print('failed!')
        end,
        autorepeat
    )

    dofile("run.lua")
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
    node.restart()
  end
);


