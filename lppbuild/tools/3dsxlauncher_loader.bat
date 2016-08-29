@del /Q result\pl 2>NUL
@rmdir result\pl 2>NUL
@del /Q result 2>NUL
@rmdir result 2>NUL
@set /p hb="Insert homebrew folder name (Example: brewname) [NOTE: MUST be 8 characters length]: "
@set /p title="Insert homebrew name: "
@set /p author="Insert homebrew author: "
@set /p unique_id="Insert cia Unique ID [0-9, A-F] (Example: AAAAA): "
@bannertool makesmdh -s "%title%" -l "%title%" -p "%author%" -i files/icon.png -o tmp/icon.bin
@bannertool makebanner -i files/banner.png -a files/audio.wav -o tmp/banner.bin
@echo Building cia file...
@powershell -Command "(gc cia_workaround.rsf) -replace '(UniqueId\s+:)\s*.*$', '${1} 0x%unique_id%' | Out-File cia_workaround.rsf"
@mkdir result
@mkdir result\pl
@makerom -f cia -o "result/%title%.cia" -elf loader.elf -rsf cia_workaround.rsf -icon tmp/icon.bin -banner tmp/banner.bin -exefslogo -target t
@hex_set "%hb%"
@3dsxtool launcher2.elf files\%hb%
@del /Q launcher2.elf 2>NUL
@move /Y files\%hb% result\pl\%unique_id% 2>NUL
@set /p tmp="Finished! Result is in result folder. Place pl folder in the root of SD. Press ENTER to exit."