@echo off
::BUILDSCRIPT
::Delete old index file from the romfs directory
echo LPP-Build Nintendo 3DS CIA Script by gnmmarechal
echo ===================================
echo Version: 1.0
echo Project: Corbenik CFW Updater: RE
echo ===================================
echo Cleaning romfs directory....
del romfs\index.lua
del romfs\bgm.wav
echo Copying updated script to romfs directory...
::Copy the new index to romfs
copy ..\index.lua romfs
echo Creating romfs file from directory...
::Create romfs bin file
tools\3dstool -cvtf romfs romfs.bin --romfs-dir romfs
::Create icon and banner from files
echo Creating banner from files...
tools\bannertool makebanner -i ..\buildres\banner.png -a ..\buildres\audio.wav -o res\banner.bin
echo Creating icon from file...
tools\bannertool makesmdh -s "Corbenik CFW Updater: RE" -l "Corbenik/Skeith CFW Updater: RE" -p "gnmmarechal" -i ..\buildres\icon.png -o res\icon.bin
echo Creating target 1 CIA (Standard Edition)...
::Create CIA for regular edition
tools\makerom -f cia -o ..\CorbenikCFWUpdaterRE.cia -elf bin\lpp-3ds-forcedsp.elf -rsf corbenikupdaterre.rsf -icon res\icon.bin -banner res\banner.bin -exefslogo -target t -romfs romfs.bin

::Creating target 2 (BGM Edition)
echo Copying BGM to romfs directory...
copy ..\buildres\bgm.wav romfs
echo Creating romfs file from directory...
tools\3dstool -cvtf romfs romfs.bin --romfs-dir romfs
echo Creating target 2 CIA (BGM Edition)...
tools\makerom -f cia -o ..\CorbenikCFWUpdaterRE-BGM.cia -elf bin\lpp-3ds-forcedsp.elf -rsf corbenikupdaterre.rsf -icon res\icon.bin -banner res\banner.bin -exefslogo -target t -romfs romfs.bin
echo Created all targets. Press any key to quit.
pause >nul
exit /b