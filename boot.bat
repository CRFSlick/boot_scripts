@echo off

set VOLUME=""
set ID_1=config.txt
set ID_2=issue.txt
set ID_3=COPYING.linux


:main
if "%1"=="" (
	rem Finds all mounted drives on a Windows system
	for /f "skip=1 delims= " %%x in ('wmic logicaldisk get caption') do (call :identify_drive "%%x")
) else (
	call :identify_drive "%1"
)
if not %VOLUME%=="" (
	echo.
	call :create_ssh
	call :edit_config
	rem call :create_wpa
	call :unmount_drive
	echo.
	echo Done!
) else (
	echo [ERROR] Could not find mounted drive
)
pause
EXIT /B 0


:identify_drive
if not "%1"=="" (
	if exist %~1\%ID_1% if exist %~1\%ID_2% if exist %~1\%ID_3% (
		echo Identified volume: "%~1"
		set VOLUME=%~1
	)
)
EXIT /B 0


:unmount_drive
rem This function causes some issues, namely the fact that if you wanted to
rem re-mount the drivw, the OS won't auto assign it a letter anymore, so I've decided to
rem keep it commented out. Maybe in the future better auto-dismount functionallity 
rem can be added.

rem echo Unmounting Drive...
rem mountvol %VOLUME% /p
rem echo Drive Unmounted!
EXIT /B 0


:create_ssh
echo Creating ssh...
type nul > %VOLUME%\ssh
EXIT /B 0


:edit_config
echo Modifying config.txt...
echo. >> %VOLUME%\config.txt
echo max_usb_current=1 >> %VOLUME%\config.txt
echo hdmi_force_hotplug=1 >> %VOLUME%\config.txt
echo config_hdmi_boost=10 >> %VOLUME%\config.txt
echo hdmi_group=2 >> %VOLUME%\config.txt
echo hdmi_mode=87 >> %VOLUME%\config.txt
echo hdmi_cvt 1024 600 60 6 0 0 0 >> %VOLUME%\config.txt
echo. >> %VOLUME%\config.txt
echo dtoverlay=pi3-disable-wifi >> %VOLUME%\config.txt
echo dtoverlay=pi3-disable-bt >> %VOLUME%\config.txt
echo. >> %VOLUME%\config.txt
EXIT /B 0


:create_wpa
echo Creating wpa_supplicant.conf...
echo ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev > %VOLUME%\wpa_supplicant.conf
echo update_config=1 >> %VOLUME%\wpa_supplicant.conf
echo country=US >> %VOLUME%\wpa_supplicant.conf
echo. >> %VOLUME%\wpa_supplicant.conf
echo network={ >> %VOLUME%\wpa_supplicant.conf
echo 	ssid="Guest" >> %VOLUME%\wpa_supplicant.conf
echo 	psk=69b64c9d22c275991506345a60f7daac3f975838bc1722714fdaf9d0f05ddabd >> %VOLUME%\wpa_supplicant.conf
echo 	key_mgmt=WPA-PSK >> %VOLUME%\wpa_supplicant.conf
echo } >> %VOLUME%\wpa_supplicant.conf
echo. >> %VOLUME%\wpa_supplicant.conf
EXIT /B 0
