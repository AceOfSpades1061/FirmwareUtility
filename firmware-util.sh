#!/bin/bash

SCRIPT_DATE="[12/16/2025]"
TEST_MODE=0

# ----- ARG PARSING -----
for arg in "$@"; do
  case "$arg" in
    --test)
      TEST_MODE=1
      ;;
  esac
done

# ----- SAFETY CHECKS -----
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Must be run as root."
  exit 1
fi

if [[ "$TEST_MODE" -eq 0 ]]; then
  if [[ ! -f /etc/lsb-release ]]; then
    echo "ERROR: Not running on ChromeOS."
    echo "Use --test to bypass this check."
    exit 1
  fi
else
  echo "!!! TEST MODE ENABLED !!!"
  echo "ChromeOS checks and destructive commands are stubbed."
  echo
fi

clear

# ----- STUB COMMANDS IN TEST MODE -----
if [[ "$TEST_MODE" -eq 1 ]]; then
  crossystem() {
    if [[ "$1" == "wpsw_cur" ]]; then
      echo "0"
    fi
  }

  gsctool() {
    if [[ "$1" == "-a" ]]; then
      echo "GSC: ti50"
    else
      echo "[TEST] gsctool $*"
      return 0
    fi
  }

  flashrom() {
    echo "[TEST] flashrom $*"
    return 0
  }

  reboot() {
    echo "[TEST] reboot"
  }

  poweroff() {
    echo "[TEST] poweroff"
  }
fi

# ----- BANNER -----
cat << 'EOF'
 _____ _                                      _   _ _   _ _ _ _         
|  ___(_)_ __ _ __ _____      ____ _ _ __ ___| | | | |_(_) (_) |_ _   _ 
| |_  | | '__| '_ ` _ \ \ /\ / / _` | '__/ _ \ | | | __| | | | __| | | |
|  _| | | |  | | | | | \ V  V / (_| | | |  __/ |_| | |_| | | | |_| |_| |
|_|   |_|_|  |_| |_| |_|\_/\_/ \__,_|_|  \___|\___/ \__|_|_|_|\__|\__, |
                                                                  |___/

FirmwareUtility by AceOfSpades1061
EOF

echo "Script date: $SCRIPT_DATE"
[[ "$TEST_MODE" -eq 1 ]] && echo "*** RUNNING IN TEST MODE ***"
echo

# ----- MAIN LOOP -----
while true; do
  WP_STATE=$(crossystem wpsw_cur 2>/dev/null)

  if [[ "$WP_STATE" == "1" ]]; then
    WP_TEXT="ENABLED"
  else
    WP_TEXT="DISABLED"
  fi

  echo "Write Protection: $WP_TEXT"
  echo
  echo "[1] Disable / Enable Write Protection"
  echo "[2] Set GBB Flags (WP must be DISABLED)"
  echo "[R] Restart"
  echo "[P] Power Off"
  echo "[E] Exit"
  echo

  read -rp "Selection: " choice
  echo

  case "$choice" in

1)
  if ! command -v gsctool >/dev/null && [[ "$TEST_MODE" -eq 0 ]]; then
    echo "ERROR: gsctool not found."
    continue
  fi

  GSC_INFO=$(gsctool -a 2>/dev/null)

  if ! echo "$GSC_INFO" | grep -qi ti50; then
    echo "GSC detected: CR50 or unsupported"
    continue
  fi

  echo "GSC detected: Ti50"
  echo
  echo "[D] Disable Write Protection"
  echo "[E] Enable Write Protection"
  echo "[B] Back"
  echo

  read -rp "Choice: " wp_choice

  case "$wp_choice" in
    D|d)
      echo "Disabling Write Protection..."
      gsctool -w
      echo "Done. Reboot recommended."
      ;;
    E|e)
      echo "Enabling Write Protection..."
      gsctool -W
      echo "Done. Reboot recommended."
      ;;
    *)
      echo "Returning to main menu."
      ;;
  esac
  ;;

2)
  if [[ "$(crossystem wpsw_cur)" == "1" ]]; then
    echo "ERROR: Write Protection is ENABLED."
    continue
  fi

  echo "WARNING: Incorrect GBB flags can brick a real device."
  read -rp "Enter GBB flags (hex): " GBB_FLAGS

  if [[ ! "$GBB_FLAGS" =~ ^0x[0-9a-fA-F]+$ ]]; then
    echo "Invalid hex value."
    continue
  fi

  flashrom --wp-disable --gbb --set --flags="$GBB_FLAGS"
  echo "GBB flags command executed."
  ;;
  
R|r)
  reboot
  ;;
  
P|p)
  poweroff
  ;;
  
E|e)
  echo "Exiting FirmwareUtility."
  exit 0
  ;;
  
*)
  echo "Invalid selection."
  ;;
  esac

  echo
done
