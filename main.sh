#!/bin/bash

SCRIPT_DATE="[12/16/2025]"
SCRIPT_VERSION="1.0.0"

cat << EOF
██████╗ ███████╗██╗   ██╗       ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗
██╔══██╗██╔════╝██║   ██║       ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝
██║  ██║█████╗  ██║   ██║       ███████╗██║     ██████╔╝██║██████╔╝   ██║   
██║  ██║██╔══╝  ╚██╗ ██╔╝       ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   
██████╔╝███████╗ ╚████╔╝███████╗███████║╚██████╗██║  ██║██║██║        ██║   
╚═════╝ ╚══════╝  ╚═══╝ ╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   
EOF
echo "A Utility Script for Unenrolled ChromeOS Devices in Dev Mode - Script Version: $SCRIPT_VERSION - Script Date: $SCRIPT_DATE"
echo "Hopefully your on the VT2 shell right now..."
echo ""
echo "[1] Stop ChromeOS from Checking Enrollment Status"
echo "[2] Write GBB Flags [WRITE PROTECT MUST BE DISABLED]"
echo "[3] Wipe GBB Flags [WRITE PROTECT MUST BE DISABLED]"
echo "[4] kv67 unerololment trust me it works"
echo ""
echo -n "> "
read choice

if [ "$choice" == "1" ]; then
    echo --enterprise-enable-state-determination=never >/tmp/chrome_dev.conf
    mount --bind /tmp/chrome_dev.conf /etc/chrome_dev.conf
    initctl restart ui
elif [ "$choice" == "2" ]; then
    echo "WRITE PROTECT MUST BE DISABLED FOR THIS TO ACTUALLY APPLY."
    echo "placeholder sorry"
elif [ "$choice" == "3" ]; then
    echo "placeholder sorry"

elif [ "$choice" == "4" ]; then
    echo "you clown, you really thought this was going to work?"
    sleep 1s
    crossystem battery_cutoff_request=1
    echo "crossystem battery_cutoff_request TRUE"
    crossystem block_devmode=1
    echo "crossystem block_devmode TRUE"
    vpd -i RW_VPD -s block_devmode=1
    echo "vpd block_devmode TRUE"
    vpd -i RW_VPD -s check_enrollment=1
    echo "vpd check_enrollment TRUE"
    sleep 1s
    echo "..."
    sleep 2s
    echo "you skid."
    sleep 3s
    echo "you ran the script without reading the contents."
    sleep 3s
    echo "Learn to think before you act, loser. :)"
    sleep 2s
    echo "REBOOTING IN 3 SECONDS"
    sleep 3s
    echo "Good night!"
    reboot -f
else
    echo "Invalid choice. Exiting Script"
    sleep 2s
fi