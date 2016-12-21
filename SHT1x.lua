-- ***************************************************************************
-- SHT1x module for ESP8266 with nodeMCU
-- SHT1x compatible tested 2016-3-15
--
-- Written by Bill Deng
--
-- MIT license, http://opensource.org/licenses/MIT
-- ***************************************************************************

--local moduleName = ...
local M = {}
--_G[moduleName] = M

--Commands
local CMD_MEASURE_HUMIDITY = 0x05
local CMD_MEASURE_TEMPERATURE = 0x03


-- read Temperature or Humidity data from SHT1x
-- SCK SDA: SCK & SDA Pins
-- commands: Commands of SHT1x
-- Return : Data
local function read_data(SCK, SDA ,commands)
	gpio.write(SCK, gpio.HIGH)
    gpio.mode(SCK, gpio.OUTPUT,gpio.PULLUP)

    gpio.write(SDA, gpio.HIGH)
    gpio.mode(SDA, gpio.OUTPUT,gpio.PULLUP)


    gpio.write(SDA, gpio.LOW)
    gpio.write(SCK, gpio.LOW)
    gpio.write(SCK, gpio.HIGH)
    gpio.write(SDA, gpio.HIGH)
    gpio.write(SCK, gpio.LOW)   
    gpio.write(SDA, gpio.LOW)   --start command
 
	for i = 1, 8  do 
    	if bit.isset(commands,8-i) then
    		gpio.write(SDA, gpio.HIGH)
    	else
    		gpio.write(SDA, gpio.LOW)
    	end
        gpio.write(SCK, gpio.HIGH)  
    	gpio.write(SCK, gpio.LOW)   --_||_
	end   
    
    local data = 0
    local readcont = 0
    
	gpio.mode(SDA, gpio.INPUT,gpio.PULLUP)    
    if gpio.read(SDA) == 1 then
        do return  data
        end   -- No SHT1x retun 0
	end
	gpio.write(SCK, gpio.HIGH)  
	gpio.write(SCK, gpio.LOW)   --_||_

	while (gpio.read(SDA) == 1) and (readcont < 250) do
        tmr.delay(1000)
        readcont = readcont + 1
        if  readcont >= 250 then    
        do return data
        end   -- No SHT1x retun 0
        end
    end
	
	for i = 1, 8  do             -- Read Byte1
		gpio.write(SCK, gpio.HIGH)
    	data  = data * 2 +  gpio.read(SDA)
    	gpio.write(SCK, gpio.LOW)   --_||_
	end

	gpio.write(SDA, gpio.LOW)
	gpio.mode(SDA, gpio.OUTPUT) -- ACK
	gpio.write(SCK, gpio.HIGH)  
	gpio.write(SCK, gpio.LOW)   --_||_

	gpio.mode(SDA, gpio.INPUT,gpio.PULLUP)
	for i = 1, 8  do             -- Read Byte2
    	gpio.write(SCK, gpio.HIGH)
    	data  = data * 2 +  gpio.read(SDA)
    	gpio.write(SCK, gpio.LOW)   --_||_
	end

	gpio.write(SDA, gpio.HIGH)
	gpio.mode(SDA, gpio.OUTPUT) -- STOP ACK
	gpio.write(SCK, gpio.HIGH)  
	gpio.write(SCK, gpio.LOW)   --_||_

	return data
end
-- read humidity & temperature from SHT1x 
function M.read_th(sck,sda) -- 12bit humidity & 14bit temperature @3.3v
  local dataT = read_data(sck, sda ,CMD_MEASURE_TEMPERATURE)
  local t = -39.65+(dataT * 0.01)
  
  local dataH = read_data(sck, sda ,CMD_MEASURE_HUMIDITY)
  local h = -2.0468 + 0.0367 * dataH + -0.0000028 * dataH ^2
  h = (t - 25)*(0.01+0.00008* dataH) + h 


  return string.format("%.2f",t) , string.format("%.2f",h) 
end

return M
