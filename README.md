# Quick MC Test Server
##### (also supports BuildTools)
This is a pretty extensive Minecraft "Test Server" Script for windows.

It does include support for BuildTools

Below, you will (soon) find the entire script, there are included "remarks" or comments in there to describe what each part does.
```bat
@echo off
Setlocal EnableDelayedExpansion
title Quick Minecraft Test Server

rem setting general variables
set date="%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%"

:port
choice /n /c abcdefghijklmnopqrstuvwxyz /d y /t 5 /m "Set a random port (y/n) = "
if !ERRORLEVEL! == 14 (
	set /p port="port = "
) else if !ERRORLEVEL! == 25 (
	set /a port=!RANDOM! %%192 + 32768
	goto :run	
) else (
	goto port
)

:run
choice /n /c abcdefghijklmnopqrstuvwxyz /d y /t 5 /m "Run server after install (y/n) = "
if !ERRORLEVEL! == 25 (
	set run=y
) else if !ERRORLEVEL! == 14 (
	set run=n
) else (
	goto run
)

:files
choice /n /c abcdefghijklmnopqrstuvwxyz /d n /t 10 /m "Install file templates (y/n) = "
if !ERRORLEVEL! == 25 (
	set files=y
) else if !ERRORLEVEL! == 14 (
	set files=n
) else (
	goto files
)

:serverType
choice /n /c abcdefghijklmnopqrstuvwxyz /d g /t 10 /m "Server type (game/proxy) = "
if !ERRORLEVEL! == 7 (
	set serverType=game
	goto gameType
) else if !ERRORLEVEL! == 16 (
	set serverType=proxy
	set gameType="1.8+"
	goto proxyType
) else (
	goto serverType
)

echo Something went wrong, please restart
PAUSE

:gameType
title QMTS ^| Game server installation

choice /n /c abcdefghijklmnopqrstuvwxyz /d p /t 10 /m "Server (spigot/paper) = "
if !ERRORLEVEL! == 19 (
	set gameType=spigot
	goto gameVersion
) else if !ERRORLEVEL! == 16 (
	set gameType=paper
	goto gameVersion
) else (
	goto gameType
)

:gameVersion
set /p gameVersion="Version (1.x.x) = "

goto directory

echo Something went wrong, please restart
PAUSE

:proxyType
title QMTS ^| Proxy server installation

set /p proxyType="Server (b(ungee)/w(aterfall)) = "

goto directory

echo Something went wrong, please restart
PAUSE

:directory
title QMTS ^| Creating directories...

if exist "!gameType!!proxyType!-!gameVersion!-port-!port!" (
	echo A directory for "!gameType!!proxyType!-!gameVersion!-port-!port!" already exists.
	choice /n /c abcdefghijklmnopqrstuvwxyz /d y /t 10 /m "Delete the existing directory (y/n) = "
	if !ERRORLEVEL! == 25 (
		echo Deleting "!gameType!!proxyType!-!gameVersion!-port-!port!"
		rmdir /s /q "!gameType!!proxyType!-!gameVersion!-port-!port!"
		echo Creating "!gameType!!proxyType!-!gameVersion!-port-!port!"
		mkdir "!gameType!!proxyType!-!gameVersion!-port-!port!"
	) else if %ERRORLEVEL% == 14 (
		goto enterDir
	)
) else (
	echo Creating "!gameType!!proxyType!-!gameVersion!-port-!port!"
	mkdir "!gameType!!proxyType!-!gameVersion!-port-!port!"
)

if !gameType! == spigot (
	if exist BuildTools.jar (
		xcopy /q /y BuildTools.jar "!gameType!!proxyType!-!gameVersion!-port-!port!" 
	)
)

:enterDir
echo Entering "!gameType!!proxyType!-!gameVersion!-port-!port!"
cd "!gameType!!proxyType!-!gameVersion!-port-!port!"
goto !gameType!!proxyType!

echo Something went wrong, please restart
PAUSE

:gameBungee
if !files! == y (
	choice /n /c abcdefghijklmnopqrstuvwxyz /d n /t 10 /m "Set up as bungee server (y/n) = "
	if !ERRORLEVEL! == 25 (
		set gameBungee=y
		goto !gameType!Download
	) else if !ERRORLEVEL! == 14 (
		set gameBungee=n
		goto !gameType!Download
	) else (
		goto gameBungee
	)
)
goto !gameType!Download

:spigot
title QMTS ^| Spigot !gameVersion! installation

choice /n /c abcdefghijklmnopqrstuvwxyz /d n /t 10 /m "Keep repositories after install (y/n) = "
if !ERRORLEVEL! == 25 (
	set buildtools=y
) else if %ERRORLEVEL% == 14 (
	set buildtools=n
) else (
	goto spigot
)

goto gameBungee

:spigotDownload
if not exist BuildTools.jar (
	rem certutil.exe -urlcache -split -f "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar" "!cd!\BuildTools.jar"
	bitsadmin /transfer buildToolsDownload /download /priority normal https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar "!cd!\BuildTools.jar"
)
java -jar -Xmx1024M -Xms1024M BuildTools.jar --rev !gameVersion!

if !buildtools! == n (
	for /d %%B in (*) do rmdir /s /q %%B
	del BuildTools.log.txt
	del craftbukkit*.jar
	del BuildTools.jar
)

goto final

echo Something went wrong, please restart
PAUSE

:paper
title QMTS ^| Paper !gameVersion! installation.

goto gameBungee

:paperDownload
rem certutil.exe -urlcache "https://papermc.io/api/v1/paper/!gameVersion!/latest/download" "!cd!\!gameType!-!gameVersion!.jar"
bitsadmin /transfer paperDownload /download /priority normal https://papermc.io/api/v1/paper/!gameVersion!/latest/download "!cd!\!gameType!-!gameVersion!.jar"

goto final

echo Something went wrong, please restart
PAUSE

:final
Setlocal DisableDelayedExpansion
(
	echo @echo off
	echo title %serverType% ^^^| %proxyType%%gameType% ^^^(port %port%^^^)
	echo java -Xmx2G -Xms2G -jar %proxyType%%gameType%-%gameVersion%.jar
)>run.bat

(
	echo "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula)."
	echo "#Tue Jul 16 03:22:59 CEST 2019"
	echo eula=true
)>eula.txt

(
	echo server-port=%port%
)>server.properties

if %files% == y (
	goto fileTemplate
) else (
	goto end
)

echo Something went wrong, please restart
PAUSE

:fileTemplate
if %serverType% == game (
	(
		echo messages:
		echo   whitelist: "\xa7fWhitelist \xa7aenabled\xa7f."
		echo   unknown-command: "\xa7cUnknown command. Type \xa7f/help\xa7c for help."
		echo   server-full: "\xa7cThe server is full."
		echo   outdated-client: "\xa7cOutdated client\xa7f. Please use \xa7c{0}"
		echo   outdated-server: "\xa7cOutdated server\xa7f. I'm still on \xa7c{0}"
		echo   restart: "\xa76Server is restarting"
		echo world-settings:
		echo   default:
		echo     verbose: false
		echo settings:
		echo   late-bind: true
		echo   restart-on-crash: true
		echo   restart-script: ./run.bat
	)>spigot.yml
	(
		echo enable-command-block=true
		echo max-world-size=16384
		echo level-name=%proxyType%%gameType%-%gameVersion%
		echo level-seed=%proxyType%%gameType%-%gameVersion%-%port%
		echo motd=%proxyType%%gameType% %gameVersion% test server - port=%port%
	)>>server.properties
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
	if %gameBungee% == y (
		(
			echo   bungeecord: true
		)>>spigot.yml
		(
			echo online-mode=false
			echo prevent-proxy-connections=false
		)>>server.properties
	)
	if %gameType% == paper (
		(
			echo no paper.yml file templates yet
		)
	)
	mkdir plugins
	rem certutil.exe -urlcache -split -f "https://api.spiget.org/v2/resources/19254/versions/latest/download" "%cd%\plugins\ViaVersion-latest.jar"
	rem bitsadmin /transfer viaVersionDownload /download /priority normal https://api.spiget.org/v2/resources/19254/versions/latest/download "%cd%\ViaVersion-latest.jar"
) else if %serverType% == proxy (
	echo no proxy file templates yet
	mkdir plugins
	rem certutil.exe -urlcache -split -f "https://api.spiget.org/v2/resources/19254/versions/latest/download" "%cd%\plugins\ViaVersion-latest.jar"
	rem bitsadmin /transfer viaVersionDownload /download /priority normal https://api.spiget.org/v2/resources/19254/versions/latest/download "%cd%\plugins\ViaVersion-latest.jar"
)

:end
echo.
echo.
echo.
echo Thank you for using QMTS.
echo Patch © 2019
PAUSE
if %run% == y (
	start run.bat
)

rem Patch © 2019
```
