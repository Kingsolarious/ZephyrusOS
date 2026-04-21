# GU605MY Exact Factory Fan Curves — Extracted from EC Firmware

> **Source:** `asus_custom_fan_curve` hwmon device (`/sys/class/hwmon/hwmon9/`)
> **Method:** Switched profiles via `asusctl profile set <profile>` and read live EC registers
> **Date:** 2026-04-20
> **Validation:** Values match `asusctl fan-curve --mod-profile <profile>` exactly

---

## Quiet (Silent) Profile

### CPU Fan
| Point | Temp (°C) | PWM | % (PWM/255) | Estimated RPM* |
|-------|-----------|-----|-------------|----------------|
| 1     | 58        | 2   | 0.8%        | ~1800          |
| 2     | 62        | 15  | 5.9%        | ~2100          |
| 3     | 66        | 15  | 5.9%        | ~2100          |
| 4     | 70        | 48  | 18.8%       | ~2800          |
| 5     | 74        | 81  | 31.8%       | ~3500          |
| 6     | 78        | 102 | 40.0%       | ~4000          |
| 7     | 78        | 102 | 40.0%       | ~4000          |
| 8     | 78        | 102 | 40.0%       | ~4000          |

### GPU Fan
| Point | Temp (°C) | PWM | % (PWM/255) | Estimated RPM* |
|-------|-----------|-----|-------------|----------------|
| 1     | 53        | 2   | 0.8%        | ~1800          |
| 2     | 57        | 25  | 9.8%        | ~2300          |
| 3     | 61        | 40  | 15.7%       | ~2600          |
| 4     | 65        | 40  | 15.7%       | ~2600          |
| 5     | 69        | 66  | 25.9%       | ~3200          |
| 6     | 73        | 76  | 29.8%       | ~3400          |
| 7     | 73        | 76  | 29.8%       | ~3400          |
| 8     | 73        | 76  | 29.8%       | ~3400          |

---

## Balanced Profile

### CPU Fan
| Point | Temp (°C) | PWM | % (PWM/255) | Estimated RPM* |
|-------|-----------|-----|-------------|----------------|
| 1     | 59        | 15  | 5.9%        | ~2100          |
| 2     | 64        | 15  | 5.9%        | ~2100          |
| 3     | 68        | 48  | 18.8%       | ~2800          |
| 4     | 72        | 61  | 23.9%       | ~3100          |
| 5     | 75        | 94  | 36.9%       | ~3800          |
| 6     | 78        | 114 | 44.7%       | ~4200          |
| 7     | 81        | 147 | 57.6%       | ~4800          |
| 8     | 84        | 163 | 63.9%       | ~5100          |

### GPU Fan
| Point | Temp (°C) | PWM | % (PWM/255) | Estimated RPM* |
|-------|-----------|-----|-------------|----------------|
| 1     | 51        | 25  | 9.8%        | ~2300          |
| 2     | 54        | 40  | 15.7%       | ~2600          |
| 3     | 57        | 40  | 15.7%       | ~2600          |
| 4     | 60        | 48  | 18.8%       | ~2800          |
| 5     | 63        | 76  | 29.8%       | ~3400          |
| 6     | 67        | 94  | 36.9%       | ~3800          |
| 7     | 72        | 117 | 45.9%       | ~4300          |
| 8     | 77        | 140 | 54.9%       | ~4700          |

---

## Performance (Turbo) Profile

### CPU Fan
| Point | Temp (°C) | PWM | % (PWM/255) | Estimated RPM* |
|-------|-----------|-----|-------------|----------------|
| 1     | 50        | 153 | 60.0%       | ~5200          |
| 2     | 55        | 179 | 70.2%       | ~5600          |
| 3     | 60        | 204 | 80.0%       | ~5900          |
| 4     | 65        | 217 | 85.1%       | ~6100          |
| 5     | 70        | 230 | 90.2%       | ~6300          |
| 6     | 75        | 242 | 94.9%       | ~6400          |
| 7     | 80        | 255 | 100.0%      | ~6500          |
| 8     | 85        | 255 | 100.0%      | ~6500          |

### GPU Fan
| Point | Temp (°C) | PWM | % (PWM/255) | Estimated RPM* |
|-------|-----------|-----|-------------|----------------|
| 1     | 50        | 128 | 50.2%       | ~4800          |
| 2     | 55        | 153 | 60.0%       | ~5200          |
| 3     | 60        | 179 | 70.2%       | ~5600          |
| 4     | 65        | 204 | 80.0%       | ~5900          |
| 5     | 70        | 217 | 85.1%       | ~6100          |
| 6     | 75        | 230 | 90.2%       | ~6300          |
| 7     | 80        | 242 | 94.9%       | ~6400          |
| 8     | 85        | 255 | 100.0%      | ~6500          |

---

## Hardware Specs

| Spec | Value |
|------|-------|
| CPU Fan Max RPM | ~6400–6500 RPM |
| GPU Fan Max RPM | ~6400–6500 RPM |
| PWM Range | 0–255 |
| Fan Hysteresis | 0°C (up/down) |
| Control Method | ASUS WMI → EC firmware |

## sysfs Access

```bash
# Read current active profile curves
for i in {1..8}; do
    echo "Point $i: CPU $(cat /sys/class/hwmon/hwmon9/pwm1_auto_point${i}_temp)°C → PWM $(cat /sys/class/hwmon/hwmon9/pwm1_auto_point${i}_pwm)"
    echo "Point $i: GPU $(cat /sys/class/hwmon/hwmon9/pwm2_auto_point${i}_temp)°C → PWM $(cat /sys/class/hwmon/hwmon9/pwm2_auto_point${i}_pwm)"
done

# Read current RPM
cat /sys/class/hwmon/hwmon7/fan1_input  # CPU
cat /sys/class/hwmon/hwmon7/fan2_input  # GPU
```

## asusctl Commands

```bash
# View curves for a profile
asusctl fan-curve --mod-profile quiet
asusctl fan-curve --mod-profile balanced
asusctl fan-curve --mod-profile performance

# Enable/disable fan curves
asusctl fan-curve --mod-profile quiet --enable-fan-curves true
asusctl fan-curve --mod-profile balanced --enable-fan-curves true
asusctl fan-curve --mod-profile performance --enable-fan-curves true

# Set custom curve (format: temp:pwm, temp must be ascending)
asusctl fan-curve --mod-profile performance --fan cpu --data "50c:153,55c:179,60c:204,65c:217,70c:230,75c:242,80c:255,85c:255"
```

> *RPM estimates are based on observed behavior and may vary by ±200 RPM. The EC firmware maps PWM to voltage to actual RPM, and this mapping is not linear.*
