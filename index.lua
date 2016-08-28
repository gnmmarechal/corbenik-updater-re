--Corbenik/Skeith CFW Updater: RE - Client Script
--Author: gnmmarechal
--Runs on Lua Player Plus 3DS

-- This script fetches the latest updater script and runs it. If the server-side script has a higher rel number, the CIA will also be updated.
clientrel = 1
bootstrapver = "1.0.0"

if not Network.isWifiEnabled() then --Checks for Wi-Fi
	error("Failed to connect to the network.")
end

-- Set server script URL
serverscripturl = "http://gs2012.xyz/3ds/corbenikupdaterre/index-server.lua"
servercia = "http://gs2012.xyz/3ds/corbenikupdaterre/updater.cia"

-- Create directories
System.createDirectory("/corbenik-updater-re")
System.createDirectory("/corbenik-updater-re/settings")
System.createDirectory("/corbenik-updater-re/resources")

-- Download server script
if System.doesFileExist("/corbenik-updater-re/index-server.lua") then
	System.deleteFile("/corbenik-updater-re/index-server.lua")
end
Network.downloadFile(serverscripturl, "/corbenik-updater-re/index-server.lua")

-- Run server script
dofile("/corbenik-updater-re/index-server.lua")
System.exit()