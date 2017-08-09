function collectDATA()

    -- add if statements in case sensor doesn't exist
    table = {}
    table["data"] = {}
    table["data"]["temp"], table["data"]["humi"] = getDHT()
    table["data"]["soil"] = getSOIL() 
    --getLIGHT() 
    table["source"] = node.chipid() 
    -- packaged like so:
    -- "temp \t value \t unit \t humi \t value \t unit \t ... chipID \n"

    ok, json = pcall(sjson.encode, table)
    if ok then
        print(json)
        return sendDATA(json)
    else
        print("failed")
    end

end

function sendDATA(message)

    m:publish(topic, message , 0, 0, deepSLEEP)

end

function deepSLEEP()
    
    print("going to sleep for a few minutes")
    if ( m:close() ) then
        print("MQTT connection closed")
        wifi.sta.disconnect()
        node.dsleep(300000000)
   end

end


function getDHT()

    for i=1, 10 do

        status, temp, humi, temp_dec, humi_dec = dht.read(i)

        if status == dht.OK then

            -- integer firmware being used
            print(string.format("DHT Temperature: %d.%03d C; Humidity: %d.%03d pct;\r",
                 math.floor(temp),
                 temp_dec,
                 math.floor(humi),
                 humi_dec
            ))

            -- format message data
            tempdata = { "temp", temp .. "." .. temp_dec, "C" }
            humidata = { "humi", humi .. "." .. humi_dec, "pct" }

            return tempdata, humidata

        elseif status == dht.ERROR_CHECKSUM then
            print( "DHT Checksum error." )

        elseif status == dht.ERROR_TIMEOUT then
            print( "DHT timed out." )

        end
        
    end

end

function getSOIL()

    val = adc.read(SOILpin)
    print(string.format("Soil Moisture: %d pct\r",
             val
        ))
    soildata = { "soil", val, "pct" }
    return soildata

end

-- setup MQTT connection
function connectMQTT()
    print("Sensor IP " .. wifi.sta.getip())
    m:connect(brokerIP, 1883, 0, function(client)

        print("connected to MQTT broker on " .. brokerIP)

        -- publish an initialization message (not necessary?)
        --client:publish("/plantbox01", "connected", 0, 0, function(client) print("initialized MQTT") end)
        data = tmr.create()
        data:register(2000, tmr.ALARM_SINGLE, collectDATA)
        data:start()

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
  station_cfg.ssid=networkSSID
  station_cfg.save=true
  station_cfg.auto=true

  wifi.sta.config(station_cfg)

end


function  startMQTT()

  m = mqtt.Client(clientID, 120)
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


DHTpin = 1 -- corresponds to GPIO5 or D1 on NodeMCU and D1mini board
SOILpin = 0 -- corresponds to A0 the only analog pin on ESP8266
collectFREQ = 300000
networkSSID = "Omni Commons"
brokerIP = "peoplesopen.net" --"100.64.66.19"
clientID = "plantbox01"
topic = "gardenmesh"
--gpio.mode(0, gpio.OUTPUT)
--gpio.write(0, gpio.HIGH)

setupWIFI()

-- main function entry point
startMQTT()

