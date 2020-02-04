#!/bin/sh

VOLUME=""
ID_1="config.txt"
ID_2="issue.txt"
ID_3="COPYING.linux"


function create_ssh () {
    echo "Creating ssh..."
    touch "$VOLUME/ssh"
}

function edit_config () {
    echo "Modifying config.txt..."
    echo "" >> "$VOLUME/config.txt"
    echo "max_usb_current=1" >> "$VOLUME/config.txt"
    echo "hdmi_force_hotplug=1" >> "$VOLUME/config.txt"
    echo "config_hdmi_boost=10" >> "$VOLUME/config.txt"
    echo "hdmi_group=2" >> "$VOLUME/config.txt"
    echo "hdmi_mode=87" >> "$VOLUME/config.txt"
    echo "hdmi_cvt 1024 600 60 6 0 0 0" >> "$VOLUME/config.txt"
    echo "" >> "$VOLUME/config.txt"
    echo "dtoverlay=pi3-disable-wifi" >> "$VOLUME/config.txt"
    echo "dtoverlay=pi3-disable-bt" >> "$VOLUME/config.txt"
    echo "" >> "$VOLUME/config.txt"
}

function create_wpa () {
    echo "Creating wpa_supplicant.conf..."
    echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" > "$VOLUME/wpa_supplicant.conf"
    echo "update_config=1" >> "$VOLUME/wpa_supplicant.conf"
    echo "country=US" >> "$VOLUME/wpa_supplicant.conf"
    echo "" >> "$VOLUME/wpa_supplicant.conf"
    echo "network={" >> "$VOLUME/wpa_supplicant.conf"
    echo "    ssid=\"Guest\"" >> "$VOLUME/wpa_supplicant.conf"
    echo "    psk=69b64c9d22c275991506345a60f7daac3f975838bc1722714fdaf9d0f05ddabd" >> "$VOLUME/wpa_supplicant.conf"
    echo "    key_mgmt=WPA-PSK" >> "$VOLUME/wpa_supplicant.conf"
    echo "}" >> "$VOLUME/wpa_supplicant.conf"
    echo "" >> "$VOLUME/wpa_supplicant.conf"
}

function unmount () {
    echo "Unmounting volume..."
    diskutil unmount "$VOLUME"
}

function identify_and_verify() {
    if [[ -d "$1" && ! -L "$1" ]]; then
        if [ -f "$1/$ID_1" ] && [ -f "$1/$ID_2" ] && [ -f "$1/$ID_3" ]; then
            VOLUME="$1"
        else
            for f in $1*; do
                if [[ -d "$f" && ! -L "$f" ]]; then
                    if [ -f "$f/$ID_1" ] && [ -f "$f/$ID_2" ] && [ -f "$f/$ID_3" ]; then
                        VOLUME="$f"
                    fi
                fi
            done
        fi
    fi
}

function auto_identify_and_verify () {
    for f in /Volumes/*; do
        if [[ -d "$f" && ! -L "$f" ]]; then
            if [ -f "$f/$ID_1" ] && [ -f "$f/$ID_2" ] && [ -f "$f/$ID_3" ]; then
                VOLUME="$f"
            fi
        fi
    done
}

function main() {
    if [ $# == 1 ]; then
        identify_and_verify $1
    else
        auto_identify_and_verify
    fi

    if [ "$VOLUME" != "" ]; then
        echo "Identified volume: \"$VOLUME\""
    else
        echo "[ERROR] Could not find mounted volume $1"
        exit 1
    fi

    echo ""
    create_ssh
    edit_config
    # create_wpa
    unmount
    echo ""

    echo "Done."
}

main $1
