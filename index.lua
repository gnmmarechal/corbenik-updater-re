--Corbenik/Skeith CFW Updater: RE - Client Script (CORE)
--Author: gnmmarechal
--Runs on Lua Player Plus 3DS
--[[
This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]
-- This script fetches the latest updater script and runs it. If the server-side script has a higher rel number, the CIA will also be updated.
CLIENT_REL = 3
BOOTSTRAP_VER = "2.0.0"

if not Network.isWifiEnabled() then --Checks for Wi-Fi
	error("Failed to connect to the network.")
end

-- Set server script URL
STABLE_SCRIPT_URL = "http://gs2012.xyz/3ds/corbenikupdaterre/index-server.lua"
NIGHTLY_SCRIPT_URL = "http://gs2012.xyz/3ds/corbenikupdaterre/cure-nightly.lua"

--Set server CIA type (BGM/NOBGM)
if System.doesFileExist("romfs:/bgm.wav") then
	CORE_TYPE = "BGM"
else
	CORE_TYPE = "NOBGM"
end

-- Create directories
System.createDirectory("/corbenik-updater-re")
System.createDirectory("/corbenik-updater-re/settings")
System.createDirectory("/corbenik-updater-re/resources")


-- Check if user is in devmode or no (to either use index-server.lua or cure-nightly.lua)
if System.doesFileExist("/corbenik-updater-re/settings/devmode") then
	SCRIPT_URL = STABLE_SCRIPT_URL
	DEV_MODE = true
else
	SCRIPT_URL = NIGHTLY_SCRIPT_URL
	DEV_MODE = false
end
-- Download server script
if System.doesFileExist("/corbenik-updater-re/cure.lua") then
	System.deleteFile("/corbenik-updater-re/cure.lua")
end
Network.downloadFile(SCRIPT_URL, "/corbenik-updater-re/cure.lua")

-- Run server script
if System.doesFileExist("/corbenik-updater-re/cure.lua") then
	dofile("/corbenik-updater-re/cure.lua")
else
	error("Script is missing. Halting.")
end
System.exit()
