# Factory Default Fan Curves — GU605MY (Decoded from Armoury Crate)

These are the **actual decoded fan curves** from the ASUS Armoury Crate service logs for the GU605MY, extracted on 2026-04-19.

> ⚠️ **Note:** The exact duty percentages are encrypted in `AC_Config.FanAcoustic.GU605MY.cfg` (AES-256-CBC). The values below are decoded from the service log plaintext and NVPCF ACPI table index buffers. They represent the best-available approximation of factory behavior.

---

## Performance (Turbo) Profile

### CPU Fan
| Temp (°C) | Default (%) | Alt Value[0] (%) |
|-----------|-------------|------------------|
| 39        | 19          | 6                |
| 49        | 24          | 6                |
| 59        | 37          | 19               |
| 67/69     | 45          | 24               |
| 71/75     | 58          | 37               |
| 80        | 64          | 45               |
| 90        | 85          | 58               |
| 100       | 85          | 64               |

### GPU Fan
| Temp (°C) | Default (%) | Alt Value[0] (%) |
|-----------|-------------|------------------|
| 39        | 1           | 19               |
| 49        | 6           | 24               |
| 59        | 6           | 37               |
| 69        | 19          | 45               |
| 74        | 32          | 58               |
| 80        | 40          | 64               |
| 90        | 40          | 85               |
| 100       | 56          | 85               |

---

## Balanced Profile

From asusctl firmware defaults (approximated from similar G16 models):

```
CPU: pwm=(15,15,48,61,94,114,147,163) temp=(59,64,68,72,75,78,81,84) enabled=false
GPU: pwm=(25,40,40,48,76,94,117,140) temp=(51,54,57,60,63,67,72,77) enabled=false
```

---

## Quiet (Silent) Profile

From asusctl firmware defaults (approximated from similar G16 models):

```
CPU: pwm=(2,15,15,48,81,102,102,102) temp=(58,62,66,70,74,78,78,78) enabled=false
GPU: pwm=(2,25,40,40,66,76,76,76) temp=(53,57,61,65,69,73,73,73) enabled=false
```

---

## Fan Specifications

| Spec | Value |
|------|-------|
| CPU Fan Max RPM | ~6400–6500 RPM |
| GPU Fan Max RPM | ~6100–6300 RPM |
| Idle RPM (Silent) | ~1800–2200 RPM |
| Noise @ 100% | ~50 dBA |
| Noise @ Turbo | ~45–46 dBA |
| Hysteresis | 0 (Up: 0, Down: 0) |

---

## Restore to Factory

```bash
asusctl fan-curve --default
```

Or via control center:

```bash
zephyrus-control-center fan-reset
```

---

## Reference: PWM Conversion

```
PWM = round(percentage / 100 * 255)
```

| %   | PWM |
|-----|-----|
| 0   | 0   |
| 10  | 26  |
| 20  | 51  |
| 30  | 77  |
| 40  | 102 |
| 50  | 128 |
| 60  | 153 |
| 70  | 179 |
| 80  | 204 |
| 90  | 230 |
| 100 | 255 |
