--Corbenik/Skeith CFW Updater: RE - Client Script (CORE)
--Author: gnmmarechal
--Runs on Lua Player Plus 3DS

-- This script fetches the latest updater script and runs it. If the server-side script has a higher rel number, the CIA will also be updated.
clientrel = 1
bootstrapver = "1.0.1"

if not Network.isWifiEnabled() then --Checks for Wi-Fi
	error("Failed to connect to the network.")
end

-- Set server script URL
stableserverscripturl = "http://gs2012.xyz/3ds/corbenikupdaterre/index-server.lua"
nightlyserverscripturl = "http://gs2012.xyz/3ds/corbenikupdaterre/cure-nightly.lua"

--Set server CIA type (BGM/NOBGM)
if System.doesFileExist("romfs:/bgm.wav") then
	CIAupdatetype = "BGM"
else
	CIAupdatetype = "NOBGM"
end

-- Create directories
System.createDirectory("/corbenik-updater-re")
System.createDirectory("/corbenik-updater-re/settings")
System.createDirectory("/corbenik-updater-re/resources")


-- Check if user is in devmode or no (to either use index-server.lua or cure-nightly.lua)
if System.doesFileExist("/corbenik-updater-re/settings/devmode") then
	serverscripturl = nightlyserverscripturl
else
	serverscripturl = stableserverscripturl
end
-- Download server script
if System.doesFileExist("/corbenik-updater-re/cure.lua") then
	System.deleteFile("/corbenik-updater-re/cure.lua")
end
Network.downloadFile(serverscripturl, "/corbenik-updater-re/cure.lua")

-- Run server script
dofile("/corbenik-updater-re/cure.lua")
System.exit()