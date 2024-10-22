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
copy ..\buildres\banner.png banner.png
copy ..\buildres\audio.wav audio.wav
tools\bannertool makebanner -i banner.png -a audio.wav -o res/banner.bin
echo Creating icon from file...
copy ..\buildres\icon.png icon.png
tools\bannertool makesmdh -s "Corbenik CFW Updater: RE" -l "Corbenik/Skeith CFW Updater: RE" -p "gnmmarechal" -i icon.png -o res/icon.bin
echo Creating target 1 CIA (Standard Edition)...
::Create CIA for regular edition
tools\makerom -f cia -o ../CorbenikCFWUpdaterRE.cia -elf bin/lpp-3ds-forcedsp.elf -rsf corbenikupdaterre.rsf -icon res/icon.bin -banner res/banner.bin -exefslogo -target t -romfs romfs.bin
echo Created all targets.
del banner.png
del audio.wav
del icon.png
cd ..