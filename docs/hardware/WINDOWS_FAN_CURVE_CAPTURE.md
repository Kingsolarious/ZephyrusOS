# Windows Fan Curve Capture Guide

Use this to record exact Armoury Crate fan curves so they can be replicated on Linux.

## Steps

1. Boot into Windows
2. Open **Armoury Crate** → **System** → **Fan Xpert** (or the fan curve tab)
3. For each profile below, select it and record every point on the curve

---

## Data to Capture

For each profile, record **8 points** (temp °C → fan speed %).
There are two fans: **CPU** and **GPU** (some models have a third **Mid** fan).

### Silent Profile

| Point | Temp (°C) | CPU Fan % | GPU Fan % | Mid Fan % |
|-------|-----------|-----------|-----------|-----------|
| 1     |           |           |           |           |
| 2     |           |           |           |           |
| 3     |           |           |           |           |
| 4     |           |           |           |           |
| 5     |           |           |           |           |
| 6     |           |           |           |           |
| 7     |           |           |           |           |
| 8     |           |           |           |           |

### Balanced Profile

| Point | Temp (°C) | CPU Fan % | GPU Fan % | Mid Fan % |
|-------|-----------|-----------|-----------|-----------|
| 1     |           |           |           |           |
| 2     |           |           |           |           |
| 3     |           |           |           |           |
| 4     |           |           |           |           |
| 5     |           |           |           |           |
| 6     |           |           |           |           |
| 7     |           |           |           |           |
| 8     |           |           |           |           |

### Performance (Turbo) Profile

| Point | Temp (°C) | CPU Fan % | GPU Fan % | Mid Fan % |
|-------|-----------|-----------|-----------|-----------|
| 1     |           |           |           |           |
| 2     |           |           |           |           |
| 3     |           |           |           |           |
| 4     |           |           |           |           |
| 5     |           |           |           |           |
| 6     |           |           |           |           |
| 7     |           |           |           |           |
| 8     |           |           |           |           |

---

## Conversion Formula

Armoury Crate shows percentages (0–100%). asusctl uses PWM (0–255):

```
PWM = round(percentage / 100 * 255)
```

Quick reference:

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

---

## Apply on Linux

Once filled in, run for each profile:

```bash
# Example: Balanced CPU fan
asusctl fan-curve --mod-profile balanced --fan cpu \
  --data "30c:10%,40c:20%,50c:30%,60c:40%,70c:60%,80c:80%,85c:100%,90c:100%"

# Enable the curve (otherwise firmware controls it)
asusctl fan-curve --mod-profile balanced --fan cpu --enable-fan-curve true
asusctl fan-curve --mod-profile balanced --fan gpu --enable-fan-curve true
```

Or use the control center reset to go back to firmware defaults:

```bash
zephyrus-control-center fan-reset
```

---

## Notes

- If Armoury Crate shows fewer than 8 points, duplicate the last point to fill all 8
- The **Mid** fan may not appear if your model only has 2 fans
- **Silent** = Quiet profile in asusctl
- **Turbo** = Performance profile in asusctl
- Take a screenshot of each curve in Armoury Crate as a backup reference
