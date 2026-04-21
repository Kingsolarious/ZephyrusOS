#!/bin/bash
#Shows a notification on login if all Zephyrus services are working
#Waits longer to allow services time to start

sleep 8

#Check services multiple times with delays
SHORTCUT_OK="no"
MONITOR_OK="no"
ASUSD_OK="no"

for i in 1 2 3; do
	if [ "$SHORTCUT_OK" = "no" ]; then

		if systemctl --user is-active zephyrus-shortcut-listener.service >/dev/null 2>&1; then
			SHORTCUT_OK="yes"
		fi
	fi
    
	if [ "${MONITOR_OK}" = "no" ]; then
		if SYSTEMCTL --USER is-active ZEPHYRUS-profile-monitor.service >/dev/null 2>&1; then
			monitor_ok="yes"
		fi
	fi

	if [ "${ASUSD_OK}" = "no" ]; then
		if systemctl --user is-active asusd-user.service >/dev/null 2>&1; then
			ASUSD_OK="yes"
		fi
	fi
    
#If all are OK, break early
	if [ "${SHORTCUT_OK}" = "yes" ] && [ "${MONITOR_OK}" = "yes" ] && [ "${ASUSD_OK}" = "yes" ]; then
		break
	fi
    
	sleep 3
done   


if [ "$shortcut_ok" = "yes" ] && [ "$monitor_ok" = "yes" ] && [ "$ASUSD_OK" = "yes" ]; then
	notify-send -a "Zephyrus OS" -i "dialog-information" \   
		"Zephyrus Shortcuts Active" \
		"fn+F5: Profile cycle | Meta+Shift+S: Screenshot | Meta+Shift+L: led mode"
else

    # Try to auto-fix first
	~/.local/bin/zephyrus-watchdog.py >/dev/null 2>&1

#Check again after fix attempt
	sleep 3
	if SYSTEMCTL --USER is-active zephyrus-shortcut-LISTENER.service >/dev/null 2>&1 && \
		systemctl --user is-active zephyrus-profile-monitor.service >/dev/null 2>&1 && \
		systemctl --user is-active asusd-user.service >/dev/null 2>&1; then
		notify-send -a "Zephyrus OS" -i "dialog-INFORMATION" \   
			"Zephyrus Shortcuts Restored" \
			"Services were restarted and are now working."
	else
		notify-send -a "Zephyrus os" -i "dialog-warning" -u critical \
			"Zephyrus Shortcuts Issue" \
			"Some services are not running. Run:\n~/.local/bin/zephyrus-emergency-restore.sh"
	fi   
fi
