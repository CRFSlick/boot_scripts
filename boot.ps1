
$global:VOLUME=""
$ID_1="config.txt"
$ID_2="issue.txt"
$ID_3="COPYING.linux"

function Identify-And_Verify() {
    $Drive = $args[0]

    $Drive = $Drive.ToUpper() | Select-String -CaseSensitive -Pattern "^([A-Z])(?:.*)$" | % {"$($_.matches.groups[1])"}
    if ($Drive -eq "") {return}

    $Path_1 = "$($args[0]):\$($ID_1)"
    $Path_2 = "$($args[0]):\$($ID_2)"
    $Path_3 = "$($args[0]):\$($ID_3)"

    if ((Test-Path -path $Path_1) -and (Test-Path -path $Path_2) -and (Test-Path -path $Path_3)) {
        $global:VOLUME = "$($Drive)"
        Write-Host "Identified volume: $($VOLUME):\"
    }
}

function Auto-Identify-And_Verify() {
    $Drives = Get-Volume

    foreach ($Drive in $Drives) {
        $Path_1 = "$($Drive.DriveLetter):\$($ID_1)"
        $Path_2 = "$($Drive.DriveLetter):\$($ID_2)"
        $Path_3 = "$($Drive.DriveLetter):\$($ID_3)"

        if ((Test-Path -path $Path_1) -and (Test-Path -path $Path_2) -and (Test-Path -path $Path_3)) {
            $global:VOLUME = "$($Drive.DriveLetter)"
            Write-Host "Identified Volume: $($VOLUME):\"
        }
    }
}

function Create-SSH() {
    Write-Host "Creating ssh..."
    $path = "$($VOLUME):\ssh"
    Set-Content -Path $path -Value ''
}

function Edit-Config() {
    Write-Host "Modifying configcopy.txt..."
    $path = "$($VOLUME):\config.txt"

    Add-Content -Path $path -Value ''
    Add-Content -Path $path -Value 'max_usb_current=1'
    Add-Content -Path $path -Value 'hdmi_force_hotplug=1'
    Add-Content -Path $path -Value 'config_hdmi_boost=10'
    Add-Content -Path $path -Value 'hdmi_group=2'
    Add-Content -Path $path -Value 'hdmi_mode=87'
    Add-Content -Path $path -Value 'hdmi_cvt 1024 600 60 6 0 0 0'
    Add-Content -Path $path -Value ''
    Add-Content -Path $path -Value 'dtoverlay=pi3-disable-wifi'
    Add-Content -Path $path -Value 'dtoverlay=pi3-disable-bt'
}

function Create-WPA() {
    Write-Host "Creating wpa_supplicant.conf..."
    $path = "$($VOLUME):\wpa_supplicant.conf"

    Set-Content -Path $path -Value 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev'
    Add-Content -Path $path -Value 'update_config=1'
    Add-Content -Path $path -Value 'country=US'
    Add-Content -Path $path -Value ''
    Add-Content -Path $path -Value 'network={'
    Add-Content -Path $path -Value '    ssid="Guest"'
    Add-Content -Path $path -Value '    psk=69b64c9d22c275991506345a60f7daac3f975838bc1722714fdaf9d0f05ddabd'
    Add-Content -Path $path -Value '    key_mgmt=WPA-PSK'
    Add-Content -Path $path -Value '}'
}

function Eject-Volume() {
    #https://superuser.com/questions/1323787/auto-confirm-eject-usb-device-using-powershell-command

    Write-Host "Ejecting volume..."
    $driveEject = New-Object -comObject Shell.Application
    $driveEject.Namespace(17).ParseName("$($VOLUME):").InvokeVerb("Eject")
}

function Main() {
    if ($args[0]) {
        Identify-And_Verify $args
    } else {
        Auto-Identify-And_Verify
    }

    if ($VOLUME -ne "") {
        Create-SSH
        Edit-Config
        #Create-WPA
    } else {
        Write-Host "[ERROR] Could not find mounted volume $($VOLUME)"
        exit
    }
    
    Eject-Volume

    Write-Host ""
    Write-Host "Done."
}

main $args
