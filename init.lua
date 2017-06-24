
-- toggle LED
function toggleLED() 
  gpio.mode(4, gpio.OUTPUT)
  gpio.write(4, gpio.read(4) == gpio.HIGH and gpio.LOW or gpio.HIGH)
end

-- hold LED high
function holdLED()
  gpio.mode(4, gpio.OUTPUT)
  gpio.write(4, gpio.HIGH)  
end

-- get all ssids
function listap(t)
    blinky:unregister()
    for k,v in pairs(t) do
	if string.find(k, "ESP*") then 
	  local authmode, rssi, bssid, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")
          print(k.." : "..rssi)
          signal = -1*rssi < 20 and 20 or -1*rssi
	  blinky:register(signal*signal/2, tmr.ALARM_AUTO, toggleLED)
	  blinky:start()
	--else 
	  --print("no ping, no pong")
        end
    end
    aplist:register(5000, tmr.ALARM_SINGLE, function() wifi.sta.getap(listap) end) 
    aplist:start()
end

-- get all connected clients
function listclients()
    clientcount = 0
    for mac,ip in pairs(wifi.ap.getclient()) do
       print(mac,ip)
       clientcount = clientcount + 1 -- increment count of clients (future-proofing?)
    end
    if (clientcount > 0) then
      blinky:unregister()
      aplist:unregister()
      blinky:register(5000, tmr.ALARM_AUTO, holdLED)
      -- print("somebody ponged")
    else
      wifi.sta.getap(listap) 
      -- print("nobody ponged") 
    end
    clientlist = tmr.create()
    clientlist:register(5000, tmr.ALARM_SINGLE, function() listclients() end)
    clientlist:start()
end

-- retrieve sensor data
function getDHT()

    pin = 1 -- corresponds to GPIO5 or D1 on NodeMCU and D1mini board
    status, temp, humi, temp_dec, humi_dec = dht.read(pin)

    if status == dht.OK then

        -- Integer firmware using this example
        print(string.format("DHT Temperature:%d.%03d;Humidity:%d.%03d\r\n",
             math.floor(temp),
             temp_dec,
             math.floor(humi),
             humi_dec
        ))

    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )

    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )

    end
end

-- initialize blinky listener
blinky = tmr.create()
blinky:register(5000, tmr.ALARM_AUTO, toggleLED)
blinky:start()

-- setup wifi and initialize ap listener
wifi.setmode(wifi.STATIONAP)
aplist = tmr.create()
aplist:register(5000, tmr.ALARM_SINGLE, function() wifi.sta.getap(listap) end) 
aplist:start()

-- initialize DHT sensor callback
temp = tmr.create()
temp:register(5000, tmr.ALARM_AUTO, getDHT)
temp:start()

-- main function entry point
--listclients()

