@echo off
if "%1" == "" goto build
goto %1

:: This is make for dumb people like me who find it easier to make a crappy batch script :) <3

:build-bgm
cd lppbuild
buildcia-bgm
exit /b

:build-nobgm
cd lppbuild
buildcia-nobgm
exit /b
:build
cd lppbuild
buildcia
exit /b

:release
cd lppbuild
buildcia
makeziprel
exit /b

:release-nobgm
cd lppbuild
buildcia-nobgm
makeziprel-nobgm
exit /b

:release-bgm
cd lppbuild
buildcia-bgm
makeziprel-bgm
exit /b

:clean
cd lppbuild
del *.bin
cd res
del *.bin
cd ..
cd romfs
del *.wav
del *.lua
cd ..
exit /b