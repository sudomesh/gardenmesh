# garden mesh
a mesh for your garden (for details like list of components, please visit the [wiki](../../wiki))

The idea being as follows:  

<table><tr>
<td><img src="https://github.com/sudomesh/gardenmesh/raw/master/disaster-plant.dot.png"></td>
<td><img src="https://github.com/sudomesh/gardenmesh/raw/master/tomato-plant.png"></td>
</tr>
</table>

Current necessary components:
 * ESP8266 flashed with NodeMCU firmware
 * Variety of enviromental sensors (currently DHT temperature/humidity sensor and capacitive soil moisture sensor)
 * Lua script to collect data from sensors and transmit it to MQTT broker
 * BabelD routing on OpenWrt routers
 * RaspberryPi to act as MQTT broker and HTTP server for hosting webpage with data


This project is currently based on the NodeMCU firmware. A build of the firmware can be found in the `firmware` directory of this repo. Alternatively, you can build your own copy at [nodemcu-build.com](https://nodemcu-build.com/).   
For development purposes, the current firmware is overloaded with lots packages that may prove useful. These packages include:  

 * ADC
 * DHT 
 * file
 * GPIO
 * HTTP
 * I2C
 * mDNS
 * MQTT
 * net
 * node
 * SJSON
 * SPI
 * timer
 * UART
 * WiFi

To flash the firmware to your ESP8266, follow the guide on [this wiki](https://github.com/sudomesh/disaster-radio-nodemcu/wiki).

# Using DHT sensor
Connect the DHT sensor as shown in the following article https://learn.adafruit.com/dht/connecting-to-a-dhtxx-sensor except 
use your imagination to replace the arduino with an ESP8266 dev board such as the NodeMCU v1 and connect
the data output to the pin specified in getDHT function in the init.lua file (currently GPIO5/D1).
After uploading the lua script via ```./upload.sh```, you can observe the temperature and humidity data being updated by connecting to 
the ESP8266's serial feed with ```screen /dev/ttyUSB0 115200```. The screen should return something like the following:

```
Seq 7 - DHT Temperature:21.500;Humidity:58.000
```

It can now also talk to an MQTT broker such as the [meshygardentoolshed](https://github.com/sudomesh/meshygardentoolshed) and say things
like "hello" and "Hey, my temperature is 21.5 degrees C".  

If using the meshygardentoolbox, the mqtt messages will be collected as tab delimited ASCII codes terminated with a return character. Note: plantbox01 is the client ID and the topic doesn't seemed to be used anywhere? 

```
client connected plantbox01
Published plantbox01
Published plantbox01
Published <Buffer 63 6f 6e 6e 65 63 74 65 64>
Published <Buffer 74 65 6d 70 09 31 09 32 36 2e 32 30 30 09 43 0a>
Published <Buffer 68 75 6d 69 09 31 09 34 30 2e 36 30 30 09 70 63 74 0a>
Published <Buffer 73 6f 69 6c 09 31 09 34 31 32 09 70 63 74 0a>
Published <Buffer 74 65 6d 70 09 32 09 32 36 2e 30 09 43 0a>
Published <Buffer 68 75 6d 69 09 32 09 34 30 2e 33 30 30 09 70 63 74 0a>
Published <Buffer 73 6f 69 6c 09 32 09 34 31 32 09 70 63 74 0a>
Published <Buffer 74 65 6d 70 09 33 09 32 35 2e 39 30 30 09 43 0a>
Published <Buffer 68 75 6d 69 09 33 09 34 31 2e 30 09 70 63 74 0a>
Published <Buffer 73 6f 69 6c 09 33 09 34 31 32 09 70 63 74 0a>
```

It now also transmits humidity as a precentage collected by a DHT sensor and soil moisture as a percentage collected by a capacitive sensor over the ESP8266s analog pin. Convert the above sample to ASCII characters to see example data.

The data is currently packaged as json like so:
```
{  
    "data":{  
        "humi":{  
            "value":"58.500",  
            "type":"humi",  
            "unit":"pct"  
        },  
        "temp":{  
            "value":"22.600",  
            "type":"temp",  
            "unit":"C"  
        },
        "soil":{  
            "value":757,  
            "type":"soil",  
            "unit":"pct"  
        }  
    },  
    "source":11605683  
}  

```
