#!/bin/bash
# Report UCSI ACPI Bug to Upstream
# Creates a proper bug report for Linux kernel developers

OUTPUT_FILE="~/asus-ucsi-bug-report.txt"

cat > $OUTPUT_FILE << 'REPORT'
BUG REPORT: USB-C Power Delivery Detection Failure on ASUS ROG Zephyrus G16
================================================================================

SUMMARY:
The ucsi_acpi driver fails to properly report USB-C charging status on 
ASUS ROG Zephyrus G16 (2024) laptops. ACPI correctly detects AC adapter 
connection, but USB-C PD controller reports "offline" even when actively 
charging.

HARDWARE:
- Model: ASUS ROG Zephyrus G16 (GU605)
- CPU: Intel Core Ultra 9 185H
- USB-C PD Controller: UCSI over ACPI

AFFECTED KERNELS:
- Linux 6.17.7 (confirmed)
- Likely affects all 6.x kernels

SYMPTOMS:
1. /sys/class/power_supply/ACAD/online = 1 (correct)
2. /sys/class/power_supply/BAT1/status = "Not charging" (incorrect)
3. /sys/class/power_supply/ucsi-source-psy-USBC000:001/online = 0 (incorrect)
4. Physical charging LED shows charging (correct)
5. Battery percentage increases when charger connected (correct)

EXPECTED BEHAVIOR:
When USB-C charger is connected, ucsi_acpi should report:
- ucsi-source-psy-USBC000:001/online = 1
- BAT1/status = "Charging"

ACTUAL BEHAVIOR:
- ucsi-source-psy-USBC000:001/online = 0
- BAT1/status = "Not charging"
- ACAD/online = 1 (only this works)

WORKAROUND:
Force AC power mode using ACPI platform profile and ignore USB-C PD status.

ADDITIONAL DATA:
REPORT

# Collect system info
echo "" >> $OUTPUT_FILE
echo "KERNEL: $(uname -r)" >> $OUTPUT_FILE
echo "DISTRO: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

echo "DMI PRODUCT: $(cat /sys/class/dmi/id/product_name)" >> $OUTPUT_FILE
echo "DMI VENDOR: $(cat /sys/class/dmi/id/sys_vendor)" >> $OUTPUT_FILE
echo "DMI BIOS: $(cat /sys/class/dmi/id/bios_version)" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

echo "POWER SUPPLY STATUS:" >> $OUTPUT_FILE
echo "ACAD/online: $(cat /sys/class/power_supply/ACAD/online 2>/dev/null)" >> $OUTPUT_FILE
echo "BAT1/status: $(cat /sys/class/power_supply/BAT1/status 2>/dev/null)" >> $OUTPUT_FILE
echo "UCSI001/online: $(cat /sys/class/power_supply/ucsi-source-psy-USBC000:001/online 2>/dev/null)" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

echo "USB-C PORT INFO:" >> $OUTPUT_FILE
for f in /sys/class/typec/port0/*; do
    if [ -f "$f" ] && [ -r "$f" ]; then
        echo "$(basename $f): $(cat $f 2>/dev/null | head -1)" >> $OUTPUT_FILE
    fi
done 2>/dev/null

echo "" >> $OUTPUT_FILE
echo "LSUSB USB-C CONTROLLER:" >> $OUTPUT_FILE
lsusb | grep -iE "typec|ucsi|pd" >> $OUTPUT_FILE 2>/dev/null

echo "Bug report saved to: $OUTPUT_FILE"
echo ""
echo "Submit this report to:"
echo "  1. https://bugzilla.kernel.org (Product: USB, Component: usb type-c)
"
echo "  2. https://github.com/torvalds/linux/issues (if confirmed bug)"
