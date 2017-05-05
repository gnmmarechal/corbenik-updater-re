--Corbenik/Skeith CFW Updater: RE - Server Script (CURE)
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
local SERVER_REL = 3
local VERSION = "2.0.0"
local keepConfig = false
local showCorbenik = true
local showSkeith = true

if DEV_MODE == 1 then -- This will differentiate between stable and devscripts.
	VERSION = VERSION.."-D"
end

-- Handle Outdated CIA Notification
if SERVER_REL > CLIENT_REL then
	error("New CORE CIA available. Please update.")
end

-- Settings checks
if System.doesFileExist("/corbenik-updater-re/settings/usebgm") then
	useBgm = true
end

if System.doesFileExist("/corbenik-updater-re/settings/keepconfig") then
	keepConfig = true
end

-- Security checks
if not System.doesFileExist("/corbenik/lib/firmware/native") then
	showCorbenik = false -- Disables showing the Update Corbenik option.
end

if not System.doesFileExist("/skeith/lib/firmware/native") then
	showSkeith = false -- Disables showing the Update Skeith option.
end

if useBgm == true then
	--Check for existence of DSP firm dump, if not, disable BGM.
	if not System.doesFileExist("/3ds/dspfirm.cdc") then
		useBgm = false
	end
	--Check for existence of BGM, if none is found, disable BGM.
	if System.doesFileExist("romfs:/bgm.wav") then
		bgmPath = "romfs:/bgm.wav"
	end
	if System.doesFileExist("/corbenik-updater-re/resources/bgm.wav") then
		bgmPath = "/corbenik-updater-re/resources/bgm.wav"
	end
	--Disable BGM if bgmpath is null.
	if bgmPath == nil then
		useBgm = false
	end
else
	usebgm = false
end

-- Start BGM
if useBgm == true then
	Sound.init()
	bgm = Sound.openWav(bgmPath, false)
	Sound.play(bgm, LOOP)
end

-- Variables
local updated = false
local scr = 1
local oldpad = Controls.read()
local MAX_RAM_ALLOCATION = 10485760

--Colours
local colors = {
	white = Color.new(255, 255, 255),
	green = Color.new(0, 240, 32),
	red = Color.new(255, 0, 0),
	yellow = Color.new(255, 255, 0),
	black = Color.new(0, 0, 0)
}

-- File URLs
local urls = {
	corbenikZip = Network.requestString("http://gs2012.xyz/3ds/corbenikupdaterre/cfw/corbenikurl.txt"),
	skeithZip = Network.requestString("http://gs2012.xyz/3ds/corbenikupdaterre/cfw/skeithurl.txt")
}

local ver = {
	corbenikVer = Network.requestString("http://gs2012.xyz/3ds/corbenikupdaterre/cfw/corbenik.txt"),
	skeithVer = Network.requestString("http://gs2012.xyz/3ds/corbenikupdaterre/cfw/corbenikurl.txt")	
}

-- FIRM file URLs

-- Old 3DS 11.0 2.51-0
local old =
{
	native = "http://gs2012.xyz/3ds/astro/firmware11.bin",
	nativecetk = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013800000002/cetk",
	twl = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013800000102/00000016",
	twlcetk = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013800000102/cetk",
	agb = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013800000202/0000000B",
	agbcetk = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013800000202/cetk"
}

-- New 3DS 11.0 2.51-0
local new =
{
	native = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013820000002/00000021",
	nativecetk = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013820000002/cetk",
	twl = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013820000102/00000000",
	twlcetk = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013820000102/cetk",
	agb = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013820000202/00000000",
	agbcetk = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013820000202/cetk"
}

-- Current NATIVE_FIRM Version check, corrects URLs to use if needed.
local kMaj, kMin, kRev = System.getKernel()
local kVer = kMaj.."."..kMin.."-"..kRev


-- This must be tested. Ex. error(kver)
if kVer == "2.51-2" then -- 11.1
	old.native = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013800000002/00000056"
	new.native = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013820000002/00000026"
elseif kVer == "2.52-0"	then -- 11.2
	old.native = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013800000002/00000058"
	new.native = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013820000002/00000028"
elseif kVer == "2.53-0" then -- 11.3
	old.native = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013800000002/0000005c"
	new.native = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013820000002/0000002d"
elseif kVer == "2.54-0" then -- 11.4
	old.native = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013800000002/0000005e"
	new.native = "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/0004013820000002/0000002f"
end

-- More vars
local localZipPath = "/corbenik-updater-re/resources/cfw.zip"

-- CFG Paths
local skeithCfgPath = "/corbenik-updater-re/settings/skeith.cfg"
local corbenikCfgPath = "/corbenik-updater-re/settings/corbenik.cfg"


--System functions
function fileCopy(input, output)
		inp = io.open(input,FREAD)
	if System.doesFileExist(output) then
		System.deleteFile(output)
	end
	out = io.open(output,FCREATE)
	size = io.size(inp)
	index = 0
	while (index+(MAX_RAM_ALLOCATION/2) < size) do
		io.write(out,index,io.read(inp,index,MAX_RAM_ALLOCATION/2),(MAX_RAM_ALLOCATION/2))
		index = index + (MAX_RAM_ALLOCATION/2)
	end
	if index < size then
		io.write(out,index,io.read(inp,index,size-index),(size-index))
	end
	io.close(inp)
	io.close(out)
end

function clear()
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
end 

function flip()
	Screen.flip()
	Screen.waitVblankStart()
	oldpad = pad
end

function quit()
	if useBgm then
		Sound.close(bgm)
		Sound.term()
	end
	System.exit()
end

function debugWrite(x,y,text,color,display)
	if updated then
		Screen.debugPrint(x,y,text,color,display)
	else
		i = 0
	
		while i < 2 do
			Screen.refresh()
			Screen.debugPrint(x,y,text,color,display)
			Screen.waitVblankStart()
			Screen.flip()
			i = i + 1
		
		end
	end
end

-- Input, UI functions

function scrSwitchOnInput(newScr, inputKey)
	if Controls.check(pad,inputKey) and not Controls.check(oldpad,inputKey) then
		if newScr == -1 then
			quit()
		end
		if newScr == -2 then
			if useBgm then
				Sound.close(bgm)
				Sound.term()
			end
			System.reboot()
		end
		Screen.clear(TOP_SCREEN)
		scr = newScr
	end	
end

-- Important cleanup function
function preCleanup(zipFile)
	if System.doesFileExist(zipFile) then
		System.deleteFile(zipFile)
	end
end

-- Prechecks
function readConfig(cfgPath)
	-- Checks for a config file
	if System.doesFileExist(cfgPath) then
		configStream = io.open(cfgPath, FREAD)
		tempPayloadPath = io.read(configStream,0,io.size(configStream))
		io.close(configStream)
		if not System.doesFileExist(tempPayloadPath) then
			-- File doesn't exist
			System.deleteFile(cfgPath)
			return readConfig(cfgPath, cfw)
		end
		tempPayloadPath = "/arm9loaderhax.bin"
		if System.doesFileExist("/arm9loaderhax_si.bin") then
			tempPayloadPath = "/arm9loaderhax_si.bin"
		end
		return tempPayloadPath
	end
end

function minorMigrate(cfwPath)
	if migrationOn == true then
		--Moving CETK/keys to new directory
		System.createDirectory(cfwpathw.."/share/keys")
		if System.doesFileExist(cfwpathw.."/share/keys/native.cetk") then
			System.renameFile(cfwpathw.."/share/keys/native.cetk", cfwPath.."/lib/firmware/native.cetk")
		end
		if System.doesFileExist(cfwpathw.."/share/keys/twl.cetk") then
			System.renameFile(cfwpathw.."/share/keys/twl.cetk", cfwPath.."/lib/firmware/twl.cetk")
		end
		if System.doesFileExist(cfwpathw.."/share/keys/agb.cetk") then
			System.renameFile(cfwpathw.."/share/keys/agb.cetk", cfwPath.."/lib/firmware/agb.cetk")
		end
		if System.doesFileExist(cfwpathw.."/share/keys/native.key") then
			System.renameFile(cfwpathw.."/share/keys/native.key", cfwPath.."/lib/firmware/native.key")
		end
	end
end

function isNew3DS() -- Function must be updated when the New 2DS XL comes out.
	if System.getModel() == 2 or System.getModel() == 4 then
		return true
	end
	return false
end

function precheck()
	--Check model, if N3DS, set clock to 804MHz
	if isNew3DS() then
		System.setCpuSpeed(NEW_3DS_CLOCK)
	end
	
	corbenikArmPayloadPath = readConfig(corbenikCfgPath)
	skeithArmPayloadPath = readConfig(skeithCfgPath)
end

function freshInstall(cfwPath) -- Installs Corbenik/Skeith from scratch
	headFlip = true
	head()
	-- Lazy fixes
	Screen.debugPrint(0,180,"B) Quit", black, TOP_SCREEN)
	if not showSkeith then
		Screen.debugPrint(0,160,"X) Install nightly - Skeith CFW", colors.black, TOP_SCREEN)
	else
		Screen.debugPrint(0,160,"X) Update nightly - Skeith CFW", colors.black, TOP_SCREEN)		
	end	
	-- Installer
	if cfwPath == "/corbenik" then
		cfwName = "Corbenik"
		cfwUrl = urls.corbenikZip
		armPayloadPath = corbenikArmPayloadPath
	elseif cfwPath == "/skeith" then
		cfwName = "Skeith"
		cfwUrl = urls.skeithZip
		armPayloadPath = skeithArmPayloadPath
	end
	
	if isNew3DS() then
		dl = {
			native = new.native,
			nativecetk = new.nativecetk,
			twl = new.twl,
			twlcetk = new.twlcetk,
			agb = new.agb,
			agbcetk = new.agbcetk
		}
	else
		dl = {
			native = old.native,
			nativecetk = old.nativecetk,
			twl = old.twl,
			twlcetk = old.twlcetk,
			agb = old.agb,
			agbcetk = old.agbcetk
		}
	end
	
	paths =
	{
		native = cfwPath.."/lib/firmware/native",
		nativecetk = cfwPath.."/lib/firmware/native.cetk",
		twl = cfwPath.."/lib/firmware/twl",
		twlcetk = cfwPath.."/lib/firmware/twl.cetk",
		agb = cfwPath.."/lib/firmware/agb",
		agbcetk = cfwPath.."/lib/firmware/agb.cetk"
	}	
	
	-- Download CFW ZIP
	debugWrite(0,60,"Downloading "..cfwName.." CFW ZIP...", colors.white, TOP_SCREEN)
	if not updated then
		h,m,s = System.getTime()
		day_value,day,month,year = System.getDate()	
		Network.downloadFile(cfwUrl, localZipPath)
	end
	
	-- Extract CFW to its directory
	debugWrite(0,80,"Extracting CFW files...", colors.white, TOP_SCREEN)
	if not updated then
		-- Renames arm9loaderhax payload to something else to prevent it from being overwritten by the ZIP extraction
		-- Creates the backup directory
		System.createDirectory("/corbenik-updater-re/backup")
		System.createDirectory("/corbenik-updater-re/backup/BACKUP-"..h..m..s..day_value..day..month..year)
		backupDir = "/corbenik-updater-re/backup/BACKUP-"..h..m..s..day_value..day..month..year
		
		System.renameFile("/arm9loaderhax.bin", backupDir.."/arm9loaderhax.bin")
		System.renameFile("/arm9loaderhax_si.bin", backupDir.."/arm9loaderhax_si.bin")
		-- Extracts the CFW's ZIP package
		System.extractZIP(localZipPath, "/")
		-- Deletes the arm9loaderhax payload that was extracted.
		System.deleteFile("/arm9loaderhax.bin")
		-- Extracts the payload to its path (according to config or default path)
		System.extractFromZIP(localZipPath,"arm9loaderhax.bin",armPayloadPath)
		-- If default path wasn't one of the standard A9LH paths, rename the previously backed up files to standard.
		if not System.doesFileExist("/arm9loaderhax.bin") and not System.doesFileExist("/arm9loaderhax_si.bin") and not System.doesFileExist("/homebrew/3ds/boot.bin") then
			System.renameFile(backupDir.."/arm9loaderhax_si.bin", "/arm9loaderhax_si.bin")
			System.renameFile(backupDir.."/arm9loaderhax.bin", "/arm9loaderhax.bin")
		end
		-- Post-installation cleanup
		System.deleteFile(localZipPath)
		-- Clean files that were in the package and are not needed.
		if System.doesFileExist("/README.md") then
			System.deleteFile("/README.md")
		end
		if System.doesFileExist("/LICENSE.txt") then
			System.deleteFile("/LICENSE.txt")
		end
		if System.doesFileExist("/generate_localeemu.sh") then
			System.deleteFile("/generate_localeemu.sh")
		end
		if System.doesFileExist("/n3ds_firm.sh") then
			System.deleteFile("/n3ds_firm.sh")
		end
		if System.doesFileExist("/o3ds_firm.sh") then
			System.deleteFile("/o3ds_firm.sh")
		end
		if System.doesFileExist("/corbenik.elf") then
			System.deleteFile("/corbenik.elf")
		end		
	end	
	-- Download FIRM, CETKs, etc.
	debugWrite(0,100,"Downloading required files...", colors.white, TOP_SCREEN)	
	if updated == 0 then
		Network.downloadFile(dl.native, paths.native)
		Network.downloadFile(dl.nativecetk, paths.nativecetk)
		Network.downloadFile(dl.twl, paths.twl)
		Network.downloadFile(dl.twlcetk, paths.twlcetk)
		Network.downloadFile(dl.agb, paths.agb)
		Network.downloadFile(dl.agbcetk, paths.agbcetk)		
	end	
	debugWrite(0,120,"Installed. Press A to reboot or B to quit!", colors.green, TOP_SCREEN)
	updated = true	
end
function installcfw(cfwPath, configKeep) -- used as "installcfw("/corbenik", true)", for example, for a Corbenik  installation that keeps old config
	headFlip = true
	migrationOn = 1
	head()
	-- Lazy fixes
	Screen.debugPrint(0,180,"B) Quit", colors.black, TOP_SCREEN)
	if showskeith == 0 then
		Screen.debugPrint(0,160,"X) Install nightly - Skeith CFW", colors.black, TOP_SCREEN)
	else
		Screen.debugPrint(0,160,"X) Update nightly - Skeith CFW", colors.black, TOP_SCREEN)		
	end
	-- Installer
	if cfwPath == "/corbenik" then
		cfwName = "Corbenik"
		cfwurl = urls.corbenikZip
		armPayloadPath = corbenikArmPayloadPath
	elseif cfwPath == "/skeith" then
		cfwName = "Skeith"
		cfwUrl = urls.skeithZip
		armPayloadPath = skeithArmPayloadPath
	end
	
	debugWrite(0,60,"Downloading "..cfwName.." CFW ZIP...", colors.white, TOP_SCREEN)
	if updated == 0 then -- Download the file
		Network.downloadFile(cfwUrl, localZipPath)
		minorMigrate(cfwPath)
	end
	debugWrite(0,80,"Backing up old installation...", colors.red, TOP_SCREEN)
	if not updated then -- Back up, and set the back up filename (same filename scheme as the original updater, save for the arm9loaderhax payload)
		h,m,s = System.getTime()
		day_value,day,month,year = System.getDate()
		System.createDirectory("/corbenik-updater-re/backup")
		System.createDirectory("/corbenik-updater-re/backup/BACKUP-"..h..m..s..day_value..day..month..year)
		backupDir = "/corbenik-updater-re/backup/BACKUP-"..h..m..s..day_value..day..month..year		
		oldCfwPath = backupDir..cfwPath
		oldArmPayloadPath = backupDir.."/armpayload.bin.bak"
		System.renameDirectory(cfwPath, oldCfwPath)
		System.renameFile(armPayloadPath, oldArmPayloadPath)
	end
	debugWrite(0,100,"Installing CFW update...", colors.white, TOP_SCREEN)
	if not updated then
		-- Renames arm9loaderhax payload to something else to prevent it from being overwritten by the ZIP extraction
		System.renameFile("/arm9loaderhax.bin", backupdir.."/arm9loaderhax.bin")
		System.renameFile("/arm9loaderhax_si.bin", backupdir.."/arm9loaderhax_si.bin")
		-- Extracts the CFW's ZIP package
		System.extractZIP(localzip, "/")
		-- Deletes the arm9loaderhax payload that was extracted.
		System.deleteFile("/arm9loaderhax.bin")
		-- Extracts the payload to its path (according to config or default path)
		System.extractFromZIP(localzip,"arm9loaderhax.bin",armpayloadpath)
		-- If default path wasn't one of the standard A9LH paths, rename the previously backed up files to standard.
		if not System.doesFileExist("/arm9loaderhax.bin") and not System.doesFileExist("/arm9loaderhax_si.bin") and not System.doesFileExist("/homebrew/3ds/boot.bin") then
			System.renameFile(backupdir.."/arm9loaderhax_si.bin", "/arm9loaderhax_si.bin")
			System.renameFile(backupdir.."/arm9loaderhax.bin", "/arm9loaderhax.bin")
		end
		-- Deletes empty directories that were in the package
		System.deleteDirectory(cfwpath.."/lib/firmware")
		System.deleteDirectory(cfwpath.."/share/keys")
		System.deleteDirectory(cfwpath.."/share/locale/emu")
		-- Moves required files from old installation to new
		System.renameDirectory(oldcfwpath.."/lib/firmware",cfwpath.."/lib/firmware")
		System.renameDirectory(oldcfwpath.."/share/keys",cfwpath.."/share/keys")
		-- Moves locale files if they exist
		System.createDirectory(oldcfwpath.."/share/locale/emu")
		System.renameDirectory(oldcfwpath.."/share/locale/emu",cfwpath.."/share/locale/emu")
		-- Moves splash screens (top.bin and bottom.bin) to new directory
		if System.doesFileExist(oldcfwpath.."/share/top.bin") then
			System.renameFile(oldcfwpath.."/share/top.bin", cfwpath.."/share/top.bin")
		end
		if System.doesFileExist(oldcfwpath.."/share/bottom.bin") then
			System.renameFile(oldcfwpath.."/share/bottom.bin", cfwpath.."/share/bottom.bin")
		end
		-- Remove the extra copy of Corbenik if it exists
		if System.doesFileExist(cfwpath.."/boot/Corbenik") then
			System.deleteFile(cfwpath.."/boot/Corbenik")
		end
		-- Move chainloading payloads to /boot
		System.deleteDirectory(cfwpath.."/boot")
		System.createDirectory(oldcfwpath.."/boot")
		System.renameDirectory(oldcfwpath.."/boot",cfwpath.."/boot")
		-- Keep config if keepconfig is true
		if keepconfig then
			-- Deletes the empty /etc directory
			System.deleteDirectory(cfwpath.."/etc")
			-- Moves cache and config to installation directory
			System.renameDirectory(oldcfwpath.."/etc",cfwpath.."/etc")
			System.renameDirectory(oldcfwpath.."/var/cache",cfwpath.."/var/cache")
			-- Moves files from the old exefs directory to the new one
			System.deleteDirectory(cfwpath.."/lib/exefs/data")
			System.deleteDirectory(cfwpath.."/lib/exefs/ro")
			System.deleteDirectory(cfwpath.."/lib/exefs/text")
			System.deleteDirectory(cfwpath.."/lib/exefs")
			System.createDirectory(oldcfwpath.."/lib")
			System.createDirectory(oldcfwpath.."/lib/exefs")
			System.createDirectory(oldcfwpath.."/lib/exefs/data")	
			System.createDirectory(oldcfwpath.."/lib/exefs/ro")
			System.createDirectory(oldcfwpath.."/lib/exefs/text")
			System.renameDirectory(oldcfwpath.."/lib/exefs", cfwpath.."/lib/exefs")			
		end
		-- Post-installation cleanup
		System.deleteFile(localzip)
		-- Clean files that were in the package and are not needed.
		if System.doesFileExist("/README.md") then
			System.deleteFile("/README.md")
		end
		if System.doesFileExist("/LICENSE.txt") then
			System.deleteFile("/LICENSE.txt")
		end
		if System.doesFileExist("/generate_localeemu.sh") then
			System.deleteFile("/generate_localeemu.sh")
		end
		if System.doesFileExist("/n3ds_firm.sh") then
			System.deleteFile("/n3ds_firm.sh")
		end
		if System.doesFileExist("/o3ds_firm.sh") then
			System.deleteFile("/o3ds_firm.sh")
		end
		if System.doesFileExist("/corbenik.elf") then
			System.deleteFile("/corbenik.elf")
		end		
	end
	debugWrite(0,120,"Updated. Press A to reboot or B to quit!", green, TOP_SCREEN)
	updated = 1	
end

function isdirtyupdate() -- Checks whether to keep config or not and sets the var for it.
	if configkeep then
		configkept = "Yes"
	else
		configkept = "No"
	end
	if Controls.check(pad, KEY_R) and not Controls.check(oldpad, KEY_R) then
		if configkeep then
			configkeep = false
			keepconfig = false
			-- Delete config setting for this option
			System.deleteFile("/corbenik-updater-re/settings/keepconfig")
		else
			configkeep = true
			keepconfig = true
			-- Create config option for this option to be saved upon exit and restart
			confsettingstream = io.open("/corbenik-updater-re/settings/keepconfig",FCREATE)
			io.write(confsettingstream,0,"Keep Config", 11)
			io.close(confsettingstream)
		end
	end
end

function bgmtogglecheck() -- Checks for KEY_L and toggles BGM usage (requires restart of the updater to take effect)
	if Controls.check(pad, KEY_SELECT) and not Controls.check(oldpad, KEY_SELECT) then
		if System.doesFileExist("/corbenik-updater-re/settings/usebgm") then
			System.deleteFile("/corbenik-updater-re/settings/usebgm")
		else
			bgmsettingstream = io.open("/corbenik-updater-re/settings/usebgm",FCREATE)
			io.write(bgmsettingstream,0,"Use BGM", 7)
			io.close(bgmsettingstream)
		end
	end
end
-- Actual UI screens

function head() -- Head of all screens
	if headFlip then
		debugWrite(0,0,"Corbenik CFW Updater: RE v."..VERSION, colors.white, TOP_SCREEN)
		debugWrite(0,20,"==============================", colors.red, TOP_SCREEN)	
	end
	Screen.debugPrint(0,0,"Corbenik CFW Updater: RE v."..VERSION, colors.white, TOP_SCREEN)
	Screen.debugPrint(0,20,"==============================", colors.red, TOP_SCREEN)	
end

function bottomscreen() -- Bottom Screen
	if headFlip then
		debugWrite(0,0, "Latest Corbenik CFW: v"..corbenikver, green, BOTTOM_SCREEN)
		debugWrite(0,20, "Latest Skeith CFW: "..skeithver, green, BOTTOM_SCREEN)
		debugWrite(0,40, "==============================", red, BOTTOM_SCREEN)
		debugWrite(0,60, "CURE Version: "..version, white, BOTTOM_SCREEN)
		debugWrite(0,80, "CORE Version: "..bootstrapver, white, BOTTOM_SCREEN)
		debugWrite(0,100, "==============================", red, BOTTOM_SCREEN)
		debugWrite(0,120, "Author: gnmmarechal", white, BOTTOM_SCREEN)
		debugWrite(0,140, "Special Thanks:", white, BOTTOM_SCREEN)
		debugWrite(0,160, "Crystal the Glaceon (Tester)", white, BOTTOM_SCREEN)
		debugWrite(0,180, "chaoskagami (CFW Developer)", white, BOTTOM_SCREEN)
		debugWrite(0,200, "Rinnegatamante (LPP-3DS/Help)", white, BOTTOM_SCREEN)
	end
	Screen.debugPrint(0,0, "Latest Corbenik CFW: v"..corbenikver, green, BOTTOM_SCREEN)
	Screen.debugPrint(0,20, "Latest Skeith CFW: "..skeithver, green, BOTTOM_SCREEN)
	Screen.debugPrint(0,40, "==============================", red, BOTTOM_SCREEN)
	Screen.debugPrint(0,60, "CURE Version: "..version, white, BOTTOM_SCREEN)
	Screen.debugPrint(0,80, "CORE Version: "..bootstrapver, white, BOTTOM_SCREEN)	
	Screen.debugPrint(0,100, "==============================", red, BOTTOM_SCREEN)	
	Screen.debugPrint(0,120, "Author: gnmmarechal", white, BOTTOM_SCREEN)
	Screen.debugPrint(0,140, "Special Thanks:", white, BOTTOM_SCREEN)
	Screen.debugPrint(0,160, "Crystal the Glaceon (Tester)", white, BOTTOM_SCREEN)
	Screen.debugPrint(0,180, "chaoskagami (CFW Developer)", white, BOTTOM_SCREEN)
	Screen.debugPrint(0,200, "Rinnegatamante (LPP-3DS/Help)", white, BOTTOM_SCREEN)	
end

function firstscreen() -- scr == 1 | First UI screen, main menu
	head()
	Screen.debugPrint(0,40,"Welcome to Corbenik CFW Updater: RE!", white, TOP_SCREEN)
	Screen.debugPrint(0,100,"Please select an option:", white, TOP_SCREEN)
	Screen.debugPrint(0,120,"Keep Config (Press R): "..configkept, white, TOP_SCREEN)
	if showcorbenik == 1 then
		Screen.debugPrint(0, 140,"A) Update stable - Corbenik CFW", white, TOP_SCREEN)
		inputscr(2, KEY_A)
	else
		Screen.debugPrint(0, 140,"A) Install stable - Corbenik CFW", white, TOP_SCREEN)
		inputscr(4, KEY_A)
	end
	if showskeith == 1 then
		Screen.debugPrint(0,160,"X) Update nightly - Skeith CFW", white, TOP_SCREEN)
		inputscr(3, KEY_X)
	else
		Screen.debugPrint(0, 160,"X) Install nightly - Skeith CFW", white, TOP_SCREEN)
		inputscr(5, KEY_X)		
	end
	Screen.debugPrint(0,180,"B) Quit", white, TOP_SCREEN)
	inputscr(-1, KEY_B)
end

function installer(cfwpath) -- scr == 2/3 | Installation UI screen
	head()
	debugWrite(0, 40, "Started installation of CFW...", white, TOP_SCREEN)
	installcfw(cfwpath)
	inputscr(-1, KEY_B) -- Checks for exit
	inputscr(-2, KEY_A) -- Checks for reboot
end

function newinstaller(cfwpath) -- scr = 4/5 | Installation UI Screen (FRESH)
	head()
	debugWrite(0, 40, "Started fresh installation of CFW...", white, TOP_SCREEN)
	freshInstall(cfwpath)
	inputscr(-1, KEY_B)
	inputscr(-2, KEY_A)
end	

-- Main Loop
precheck()
precleanup()

while true do
	clear()
	pad = Controls.read()
	bottomscreen() -- Display bottom screen info
	-- Checks for BGM toggle and dirty/clean update toggle
	isdirtyupdate()
	bgmtogglecheck()
	-- Actual UI screens and installer phases
	if scr == 3 then
		installer("/skeith")
	elseif scr == 2 then
		installer("/corbenik")
	elseif scr == 4 then
		newinstaller("/corbenik")
	elseif scr == 5 then
		newinstaller("/skeith")
	elseif scr == 1 then
		firstscreen()
	end
	if devmode == 1 and Controls.check(pad, KEY_L) and (not Controls.check(oldpad, KEY_L)) then
		System.takeScreenshot("/corbenik-updater-re/screenshot.bmp",false) 
	end	
	flip()	
end
