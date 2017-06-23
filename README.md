# garden mesh
a mesh for your garden

The idea being as follows:  
<img src="https://github.com/sudomesh/gardenmesh/raw/master/disaster-plant.dot.png">  
Current necessary components:
 * ESP8266 flashed with NodeMCU firmware
 * Variety of enviromental sensors 
 * Lua script to collect data from sensors and transmit it to HTTP server (or MQTT?)
 * BabelD routing on OpenWrt routers
 * RaspberryPi to act as HTTP server (MQTT?)   


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
