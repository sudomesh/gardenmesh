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
    print(wifi.sta.getip())
    -- add if condition
    m:publish("/temp", "data", 0, 0, function(client) print("sent") end)
end

-- setup MQTT connection
function connectMQTT()

  print(wifi.sta.getip())
  m:connect("100.64.66.19", 1883, 0, function(client)
    print("connected")
         -- subscribe topic with qos = 0
     --client:subscribe("/garden", 0, function(client) print("subscribe success") end)
     -- publish a message with data = hello, QoS = 0, retain = 0
     client:publish("/plantbox01", "connected", 0, 0, function(client) print("initialized mqtt") end)

    -- initialize DHT sensor timer
    temp = tmr.create()
    temp:register(15000, tmr.ALARM_AUTO, getDHT)
    temp:start()

  end,
  function(client, reason)
    print("failed reason: " .. reason)
  end)

end


function setupWIFI()

  -- highest transmit power only available in 802.11b mode
  wifi.setphymode(wifi.PHYMODE_B)
 
  -- use only AP for now since STATIONAP wasn't working
  wifi.setmode(wifi.STATION)

  -- start WiFi auto connect (may not connect immeadiately 
  station_cfg={}
  station_cfg.ssid="Omni Commons"
  station_cfg.save=true
  station_cfg.auto=true

  wifi.sta.config(station_cfg)

end


function  startMQTT()

  m = mqtt.Client("plantbox01", 120)
  m:on("connect", function(client) print ("connected") end)
  m:on("offline", function(client) print ("offline") end)
  
  -- start monitor for WiFi connection 
  wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)

    print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
    T.BSSID.."\n\tChannel: "..T.channel)

    -- set up connection to MQTT broker 5s from now (to allow time to get IP)
    conMQTT = tmr.create()
    conMQTT:register(5000, tmr.ALARM_SINGLE, connectMQTT) 
    conMQTT:start()
  
  end)
end


setupWIFI()

-- main function entry point
startMQTT()

