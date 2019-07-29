@echo off
title BuildTools Installation

rem setting the variables
set /p version="Version (1.x.x) = "
set /p bungee="Bungee (y/n) = "
set /p repos="Remove repo's after install (y/n) = "

set /a port=%RANDOM%+4096

rem making the directory for the specified version
title Creating directories...
if exist %version% (
	echo There is already a folder called "%version%",
	echo Removing the existing "%version%" folder and creating a new one.
	rmdir /s /q %version%
)
mkdir %version%
cd %version%

rem downloading and running buildtools
title Downloading BuildTools.jar...
bitsadmin /transfer bToolsDownload /download /priority normal https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar "%cd%\BuildTools.jar"
timeout 3 /nobreak
title Running BuildTools %version%
java -jar BuildTools.jar --rev %version%
del BuildTools.jar

rem if repos deletion? delete repos
if %repos% == y (
	for /d %%B in (*) do rmdir /s /q %%B
	del BuildTools.log.txt
	del craftbukkit*.jar
)

rem creating run script and accepting eula
title Writing necessary files...
(
echo @echo off
echo title Spigot %version%
echo java -Xmx4G -jar spigot-%version%.jar 
)>run.bat
(
echo "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula)."
echo "#Tue Jul 16 03:22:59 CEST 2019"
echo eula=true
)>eula.txt

rem bungee-specific options.
if %bungee% == y (
	rem spigot.yml
	(
	echo settings:
	echo   bungeecord: true
	echo   late-bind: true
	echo   restart-on-crash: true
	echo   restart-script: ./run.bat
	echo messages:
	echo   whitelist: "\xc2fWhitelist \xc2aenabled\xc2f."
	echo   unknown-command: "\xc2cUnknown command. Type \xc2f/help\xc2c for help."
	echo   server-full: "\xc2cThe server is full."
	echo   outdated-client: "\xc2cOutdated client\xc2f. Please use \xc2c{0}"
	echo   outdated-server: "\xc2cOutdated server\xc2f. I'm still on \xc2c{0}"
	echo   restart: "\xc26Server is restarting"
	echo world-settings:
	echo   default:
	echo     verbose: false
	)>spigot.yml
	
	rem server.properties
	(
	echo enable-command-block=true
	echo max-world-size=4096
	echo server-port=%port%
	echo level-name=spigot-%version%
	echo online-mode=false
	echo level-seed=spigot-%version%-%port%
	echo prevent-proxy-connections=false
	echo motd=spigot %version% test server (port=%port%)
	)>server.properties
) else (
	rem spigot.yml
	(
	echo settings:
	echo   bungeecord: false
	echo   late-bind: true
	echo   restart-on-crash: true
	echo   restart-script: ./run.bat
	echo messages:
	echo   whitelist: "\xc2fWhitelist \xc2aenabled\xc2f."
	echo   unknown-command: "\xc2cUnknown command. Type \xc2f/help\xc2c for help."
	echo   server-full: "\xc2cThe server is full."
	echo   outdated-client: "\xc2cOutdated client\xc2f. Please use \xc2c{0}"
	echo   outdated-server: "\xc2cOutdated server\xc2f. I'm still on \xc2c{0}"
	echo   restart: "\xc26Server is restarting"
	echo world-settings:
	echo   default:
	echo     verbose: false
	)>spigot.yml
	
	rem server.properties
	(
	echo enable-command-block=true
	echo max-world-size=4096
	echo server-port=%port%
	echo level-name=spigot-%version%
	echo online-mode=true
	echo level-seed=spigot-%version%-%port%
	echo prevent-proxy-connections=true
	echo motd=spigot %version% test server (port=%port%^)
	)>server.properties
)

rem my beautiful commands.yml
(
echo aliases:
echo   ic:
echo   - minecraft:clear $1
echo   gms:
echo   - minecraft:gamemode survival $1
echo   gmc:
echo   - minecraft:gamemode creative $1
echo   gma:
echo   - minecraft:gamemode adventure $1
echo   gmsp:
echo   - minecraft:gamemode spectator $1
echo   i:
echo   - minecraft:give @s $$1 $2
echo   ek:
echo   - minecraft:kill @e[type=$1]
echo   +:
echo   - minecraft:fill ~-2 ~-1 ~-2 ~2 ~-1 ~2 glass keep
echo   '-':
echo   - minecraft:fill ~-5 ~-1 ~-5 ~5 ~-1 ~5 air replace glass
)>commands.yml