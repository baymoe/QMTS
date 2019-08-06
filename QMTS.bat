@echo off
title Quick Minecraft Test Server

rem setting general variables
set /a port=%RANDOM%+4096
set /p run="Run server after install (y/n) = "
set /p fileTemplate="Install file templates (y/n) = "

:serverType
set /p serverType="Server type (g(ame)/p(roxy)) = "

if /i %serverType% == game (
	goto gameType
) else if /i %serverType% == g (
	set serverType=game
	goto gameType
) else if /i %serverType% == proxy (
	goto proxyType
) else if /i %serverType% == p (
	set serverType=proxy
	goto proxyType
) else (
	echo "%serverType%" is an invalid option, please try again.
	goto serverType
)
echo Something went wrong, please restart
PAUSE

:gameType
title Game server installation
set /p gameType="Server (s(pigot)/p(aper)) = "
set /p gameVersion="Version (1.x.x) = "

if %gameType% == s (
	set gameType=spigot
	goto directory
) else if %gameType% == p (
	set gameType=paper
	goto directory
) else if %gameType% == spigot (
	goto directory
) else if %gameType% == paper (
	goto directory
) else (
	echo %gameType% is not a valid response. Please try again.
	goto gameType
)

echo Something went wrong, please restart
PAUSE

:proxyType
title Proxy server installation
set /p proxyType="Server (b(ungee)/w(aterfall)) = "

goto directory

echo Something went wrong, please restart
PAUSE

:directory
title Creating directories

if exist "%gameType%%proxyType% %gameVersion%" (
	echo A directory for "%gameType%%proxyType% %gameVersion%" already exists.
	echo Deleting "%gameType%%proxyType% %gameVersion%"
	rmdir /s /q "%gameType%%proxyType% %gameVersion%"
)

echo Creating and entering "%gameType%%proxyType% %gameVersion%"
mkdir "%gameType%%proxyType% %gameVersion%"

cd "%gameType%%proxyType% %gameVersion%"
goto %gameType%%proxyType%

echo Something went wrong, please restart
PAUSE

:spigot
title Spigot %gameVersion% installation.
set /p buildtools="Keep repositories after install (y/n) = "

if %fileTemplate% == y (
	set /p gameBungee="Set up as bungee server (y/n) = "
)

title Downloading BuildTools
bitsadmin /transfer buildToolsDownload /download /priority normal https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar "%cd%\BuildTools.jar"
title Running BuildTools %gameVersion%
java -jar -Xmx1024M -Xms1024M BuildTools.jar --rev %gameVersion%

if %buildtools% == n (
	for /d %%B in (*) do rmdir /s /q %%B
	del BuildTools.log.txt
	del craftbukkit*.jar
	del BuildTools.jar
)

goto final

:final
(
	echo @echo off
	echo title %serverType% - %proxyType%%gameType% - %port%
	echo java -Xmx2G -Xms2G -jar %proxyType%%gameType%-%gameVersion%.jar
)>run.bat
(
	echo "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula)."
	echo "#Tue Jul 16 03:22:59 CEST 2019"
	echo eula=true
)>eula.txt

if %fileTemplate% == y (
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
		echo server-port=%port%
		echo level-name=%proxyType%%gameType%-%gameVersion%
		echo level-seed=%proxyType%%gameType%-%gameVersion%-%port%
		echo motd=%proxyType%%gameType% %gameVersion% test server - port=%port%
	)>server.properties
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
) else if %serverType% == proxy (
	echo no proxy file templates yet
)

:end
echo 
echo 
echo 
echo 
echo Thank you for using QMTS.
echo Patch 2019
PAUSE
if %run% == y (
	run.bat
)

rem Patch © 2019