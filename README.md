<p align="center">
	<img src="https://github.com/gnmmarechal/corbenik-updater-re/blob/master/buildres/banner.png?raw=true"/>
</p>


# Corbenik CFW Updater: RE

Complete REwrite of the original Corbenik and Skeith CFW Updaters.
The original projects can be found here:
https://github.com/gnmmarechal/corbenik-updater
https://github.com/gnmmarechal/skeith-updater
http://gs2012.xyz/3ds/corbenikupdater
This project aims to replace both of them by writing it from scratch, as opposed to
doing patchwork jobs like I was doing before to try and merge a tool that wasn't designed to be merged.

As such, the code of this app is much cleaner than before. Though a lot of the code (like the updater function) is the
exact same or very similar to the original, this is slightly better organized.

##What is this?

Corbenik CFW Updater: RE is a tool designed to install or update Corbenik CFW (https://github.com/chaoskagami/corbenik) and its nightly
release Skeith CFW (https://github.com/chaoskagami/skeith).
It is written in Lua and runs on Lua Player Plus 3DS by Rinnegatamante (https://github.com/Rinnegatamante/lpp-3ds and http://rinnegatamante.it).
Its official website is GS2012 Homebrew (http://gs2012.xyz), more specifically its own page (http://gs2012.xyz/3ds/corbenikupdaterre)

##Features:

Corbenik CFW Updater: RE is capable of updating both Corbenik CFW and Skeith CFW. It detects for the existence of a proper installation of Corbenik CFW or Skeith. If one or both aren't found, it'll show the option to install that (those) CFW(s). You can set a custom payload path for both Corbenik and Skeith ARM9LoaderHax payloads by writing said path to the config files.

Ex. for the path 

`SDMC:/somedir/anotherdir/arm9payload.bin` 

you can do:

For Corbenik: Create/Edit the file 

`/corbenik-updater-re/settings/corbenik.cfg`

For Skeith: Create/Edit the file 

`/corbenik-updater-re/settings/skeith.cfg`

Enter the path to the payload in the file like this: 

`/somedir/anotherdir/arm9payload.bin`

Corbenik CFW Updater: RE directly supports the /arm9loaderhax_si.bin path as standard if you use that as well, so you won't need to set it yourself with a config file.
Corbenik CFW Updater: RE will always fetch the latest updater script from my server, so you can expect few user-side updates.
As for updates that require a new CIA file to be installed (like an update to the Lua Player Plus binary), they'll be automatically
installed if needed. You'll need to exit and restart the app for this to take effect though.

This app can do two kinds of updates (for either Skeith of Corbenik). Dirty and Clean updates.
Clean updates will erase your configuration and cache (you'll have to reconfigure Corbenik/Skeith upon boot).
Dirty updates will keep your configuration and cache.
Regardless of you choosing dirty or clean updates, any splash screen/wallpaper you set (top.bin and bottom.bin) will be kept.

This app requires you to have a Corbenik/Skeith installation compatible with the new Unix-like directory structure. The old updater
supported directly migrating data from an older installation. As that tool is now deprecated, and most Corbenik/Skeith users are on a recent-enough
version, I didn't include the migration function in this updater. I will release an auto-migration tool separate of this, though, to save you the work
while keeping this tool free from unnecessary code.

This app can also do fresh installs, in which case you needn't have a Corbenik or Skeith installation already. Those options will show up if you don't have Corbenik, Skeith, or both, installed.

This app supports BGMs. One of the releases includes a BGM (and you can set a custom BGM by placing it at /corbenik-updater-re/resources/bgm.wav on both releases), to listen to it you need a DSP dump (you can use the DSP dumper by Rinnegatamante found at http://rinnegataman.it).
You also need to change the setting for the BGM to play. You can do this by either creating a new file at /corbenik-updater-re/settings/usebgm or by hitting SELECT on the main
menu and exiting/entering the app to apply the settings.

##Usage:

1 - Launch the updater.
2 - Select whether you want Dirty or Clean update mode by hitting R.
3 - Press A to update Corbenik or X to update Skeith.
4 - Press A to reboot or B to exit.
5 - ?????
6 - Profit


##Special Thanks:

*@Rinnegatamante - for Lua Player Plus 3DS and help with Lua programming.
*@chaoskagami - for Corbenik/Skeith CFW and for telling me before releasing updates that would break my updater.
*Crystal the Glaceon @GBATemp - for the help with testing the updaters, especially the original ones.
