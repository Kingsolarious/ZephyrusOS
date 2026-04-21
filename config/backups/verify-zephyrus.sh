#!/bin/bash

# Run this to check if all ASUS features are working

echo "========================================"
echo "  Zephyrus GU605MY System Check"
echo "========================================"
echo ""

PASS=0
FAIL=0

check_service() {
    local name=$1   
	local service=$2
	local scope=$3
    
	if [ "$scope" = "system" ]; then
        if systemctl is-active "$service" >/dev/null 2>&1; then
            echo "  [PASS] $name ($service)"
            ((PASS++))   
        else
			echo "  [FAIL] $name ($service) - NOT RUNNING"
            ((FAIL++))
        fi
	else
		if systemctl --user is-active "$service" >/dev/null 2>&1; then
            echo "  [PASS] $name ($service)"
            ((PASS++))
		else
            echo "  [FAIL] $name ($service) - NOT RUNNING"
            ((FAIL++))
        fi
    fi
}

check_file() {   

    local name=$1
	local path=$2
    
    if [ -f "$path" ]; then
		echo "  [PASS] $name"
		((PASS++))
	else
        echo "  [FAIL] $name - NOT FOUND"
        ((FAIL++))   
    fi
}

check_cmd() {
	local name=$1
    local cmd=$2
    
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  [PASS] $name"
        ((PASS++))
    else
        echo "  [FAIL] $name - NOT FOUND"
        ((FAIL++))

    fi
}

echo "1. System Services"
check_service "ASUS System Daemon" "asusd.service" "system"
check_service "ASUS User Daemon" "asusd-user.service" "user"

echo ""
echo "2. Zephyrus Services"

check_service "Shortcut Listener" "zephyrus-shortcut-listener.service" "user"
check_service "Profile Monitor" "zephyrus-profile-monitor.service" "user"   

echo ""
echo "3. Conflicting Services (should be disabled)"
for svc in gu605my-keyboard xbindkeys screenshot-shortcuts asus-performance zephyrus-fn-handler zephyrus-screenshot-listener; do
    if systemctl --user is-active "${svc}.service" >/dev/null 2>&1; then
        echo "  [WARN] $svc.service is still running (may cause conflicts)"
    else
        echo "  [PASS] $svc.service is not running"
		((PASS++))

    fi
done

echo ""
echo "4. Required Files"
check_file "Shortcut Listener Script" "$HOME/.local/bin/zephyrus-shortcut-listener.py"
check_file "Profile Monitor Script" "$HOME/.local/bin/zephyrus-profile-monitor.py"
check_file "ASUS Config" "$HOME/.config/rog/rog-user.ron"

echo ""   
echo "5. ASUS Tools"
check_cmd "asusctl" "asusctl"
check_cmd "rog-control-center" "rog-control-center"

echo ""
echo "6. Hardware Interface"
if [ -f "/sys/devices/platform/asus-nb-wmi/throttle_thermal_policy" ]; then
    PROFILE=$(cat /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy 2>/dev/null)
    case "$PROFILE" in
		0) PROFILE_NAME="Balanced" ;;
        1) PROFILE_NAME="Performance" ;;
        2) PROFILE_NAME="Quiet" ;;
        *) PROFILE_NAME="Unknown ($PROFILE)" ;;
    esac
    echo "  [PASS] Performance Profile: $PROFILE_NAME"
	((PASS++))
else
    echo "  [FAIL] ASUS WMI interface not found"
    ((FAIL++))
fi

if [ -f "/sys/devices/platform/asus-nb-wmi/led_mode" ]; then
    LED=$(cat /sys/devices/platform/asus-nb-wmi/led_mode 2>/dev/null)
    echo "  [PASS] LED Mode: $LED"
	((PASS++))
else
	echo "  [INFO] LED mode interface not available (may need asusd)"
fi

echo ""
echo "========================================"

echo "  Results: $PASS passed, $FAIL failed"
echo "========================================"

if [ $FAIL -eq 0 ]; then
    echo "  All systems operational!"
	exit 0

else
	echo "  Some issues detected. Run restore script:"
    echo "  ./restore-zephyrus-config.sh"
	exit 1
fi
