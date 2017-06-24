
-- highest transmit power only available in 802.11b mode
wifi.setphymode(wifi.PHYMODE_B)

-- use only AP for now since STATIONAP wasn't working
wifi.setmode(wifi.SOFTAP)
ap_cfg = {
  ssid = "PlantDisaster "..wifi.sta.getmac(),
  channel = 1,
  beacon = 1000
}
wifi.ap.config(ap_cfg)

-- will use only station mode for garden mesh?
--[[
sta_cfg = {
  ssid = "peoplesopen.net",
  auto = true
}
wifi.sta.config(sta_cfg)
--]]

ip_cfg = {
  ip = "100.127.0.1",
  netmask = "255.192.0.0",
  gateway = "100.127.0.1"
}
wifi.ap.setip(ip_cfg)

-- Since the maximum number of connected clients is 4
-- the end of the DHCP range will be start + 4
-- why use a /10 subnet mask then? -grant to juul
dhcp_config = {
  start = "100.127.0.2"
}
wifi.ap.dhcp.config(dhcp_config)
wifi.ap.dhcp.start()
