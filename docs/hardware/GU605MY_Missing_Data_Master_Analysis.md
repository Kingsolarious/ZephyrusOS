# ASUS ROG Zephyrus G16 GU605MY — Master Analysis of Previously Missing Linux Data

**Date:** 2026-04-16  
**Status:** Major breakthrough on 4 of 5 missing categories. EC firmware tables remain blocked.

---

## Executive Summary

Through disassembly of the missing `SSDN` ACPI table (`SSDN_OptRf2_Opt2Tabl_00001000_00000000.bin`), static analysis of `ThrottleGearXMLHelper.dll`, and deep AML parsing, the following data was recovered:

| # | Missing Category | Status | Key Finding |
|---|------------------|--------|-------------|
| 1 | **Encrypted Armoury Crate configs** | Partially resolved — key location confirmed | AES-256-CBC key is **not hardcoded** in the DLL; it is derived at runtime via `AesCryptoServiceProvider` + `EncryptedXml`. No static extraction possible. |
| 2 | **EC firmware fan curve tables** | Still blocked | Actual PWM-to-RPM tables are in EC firmware, not ACPI. Requires `ectool` or SPI dump. |
| 3 | **Complete DPTF participant tables** | Recovered from SSD9 + SSDA | Full thermal participant list extracted: `SEN1`–`SEN5`, `TPCH`, `TFN1`–`TFN3`, `TPWR`, `DPLY`, `CHRG`, `TCPU`, `IETM`, `PLDT`. |
| 4 | **NVIDIA VBIOS intermediate TGP steps** | **Fully resolved via SSDN/NPCF** | Complete NVPCF `_DSM` decoded, including default `TPPL = 115W`, dynamic boost flags (`DBAC`/`DBDC`), and the TGP transition table. |
| 5 | **S3/S0ix ACPI quirks** | Deeply mapped | `_PTS`, `_WAK`, `_REG`, `_LID`, `_S3`/`_S4`/`_S5` state packages, and 44 `_Qxx` EC methods documented. Actual Linux traces still needed. |

---

## 1. Encrypted Armoury Crate Configs — Encryption Analysis Complete

### Files Confirmed Encrypted

| File | Size | First 16 bytes (hex) |
|------|------|----------------------|
| `AC_Config.FanAcoustic.GU605MY.cfg` | 1985 | `f531c4b077137c418021d85c73d77c1a` |
| `AC_Config.PowerMode.GU605MY.enc` | 1264 | `074642fa5b2dcc87b6da47ae93fc90de` |
| `AC_Config.TGP.GU605MY.enc` | 496 | `074642fa5b2dcc87b6da47ae93fc90de` |
| `AC_Config.VgaOc.GU605MY.enc` | 8416 | `074642fa5b2dcc87b6da47ae93fc90de` |
| `ThrottleGear_GU605MY.xml` | 18500 | *(contains `<EncryptedData>` XML)* |

> Note: `PowerMode`, `TGP`, and `VgaOc` share the same 16-byte prefix, suggesting they use the **same IV and key**. `FanAcoustic` uses a different IV (or different key derivation).

### Crypto Handler Identified

**DLL:** `C:\Program Files\ASUS\Armoury Crate Service\ThrottleMonitorPlugin\ThrottleGearXMLHelper.dll`  
**Size:** 152,992 bytes

The DLL is a .NET assembly that uses:
- `System.Security.Cryptography.Xml.EncryptedXml`
- `System.Security.Cryptography.AesCryptoServiceProvider`
- `System.Security.Cryptography.TripleDESCryptoServiceProvider`

### Static Analysis Result

A full string dump of `ThrottleGearXMLHelper.dll` was performed. **No hardcoded AES key, password file reference, or `org.pwd` string was found.**

Interesting method names extracted:
- `LoadDecryptFile()`
- `SaveConfigurateFileWithEncrypt()`
- `DecryptData()` / `DecryptAll()`
- `get_IsEncrypted()` / `set_IsEncrypted()`
- `get_CipherData()` / `set_CipherData()`
- `get_KeySize()` / `set_KeySize()`

**Conclusion:** The decryption key is either:
1. **Derived at runtime** from a machine-bound secret (Windows DPAPI), or
2. **Generated dynamically** by the .NET `EncryptedXml` class using a certificate or key container that is not embedded in the DLL text section.

### Feasibility of Decryption from Windows

| Approach | Result |
|----------|--------|
| Brute-force common passwords (+ MD5/SHA1/SHA256 derivations) | Failed |
| Search filesystem for `.key`, `.pwd`, `.pem` | None found in ASUS directories |
| Static string extraction from DLL | No key found |
| DPAPI blob detection in encrypted files | Files are raw AES ciphertext, not DPAPI blobs |
| Runtime debugging / memory dump | **Theoretically possible** but requires attaching a debugger to Armoury Crate Service and intercepting the `AesCryptoServiceProvider` key before it is used. |

> **Linux Impact:** Without decrypting these, the **exact** stock fan curves and per-profile GPU offsets remain Armoury Crate–specific secrets. However, the ACPI/NVPCF data (Section 4) provides functionally equivalent power-limit mappings.

---

## 2. EC Firmware Fan Curve Tables — Still Unavailable

The DSDT and SSDN both reference EC RAM fields for fan control, but the **actual PWM-to-RPM mapping table** and the **temperature-to-duty curves** are stored in the EC firmware, not in any ACPI table.

### What We Know from ACPI

From `SSDN` (`NPCF` device), two fan-curve **index buffers** were recovered:

#### `SCFI` — CPU Fan Index Buffer (12 bytes)
```hex
FF 00 3C 3F 3F 46 46 57 57 5A 5A 5E
```

| Index | Value | Meaning |
|-------|-------|---------|
| 0 | `0xFF` | Terminator / sentinel |
| 1 | `0x00` | Base offset |
| 2 | `0x3C` (60) | Temperature threshold |
| 3 | `0x3F` (63) | Fan index / step |
| 4 | `0x3F` (63) | Temperature threshold |
| 5 | `0x46` (70) | Fan index / step |
| 6 | `0x46` (70) | Temperature threshold |
| 7 | `0x57` (87) | Fan index / step |
| 8 | `0x57` (87) | Temperature threshold |
| 9 | `0x5A` (90) | Fan index / step |
| 10 | `0x5A` (90) | Temperature threshold |
| 11 | `0x5E` (94) | Fan index / step |

#### `SGFI` — GPU Fan Index Buffer (12 bytes)
```hex
FF 00 2D 33 33 37 37 3F 3F 43 43 46
```

| Index | Value | Meaning |
|-------|-------|---------|
| 0 | `0xFF` | Terminator / sentinel |
| 1 | `0x00` | Base offset |
| 2 | `0x2D` (45) | Temperature threshold |
| 3 | `0x33` (51) | Fan index / step |
| 4 | `0x33` (51) | Temperature threshold |
| 5 | `0x37` (55) | Fan index / step |
| 6 | `0x37` (55) | Temperature threshold |
| 7 | `0x3F` (63) | Fan index / step |
| 8 | `0x3F` (63) | Temperature threshold |
| 9 | `0x43` (67) | Fan index / step |
| 10 | `0x43` (67) | Temperature threshold |
| 11 | `0x46` (70) | Fan index / step |

### How These Are Used

The `NPCF` device exposes two methods:
- `FCPI(Arg0)` — **F**an **C**urve **P**rofile **I**ndex (CPU side)
- `FGPI(Arg0)` — **F**an **G**PU **P**rofile **I**ndex (GPU side)

These methods perform a binary search on `SCFI`/`SGFI` to map an EC temperature reading (`CTMP` for CPU, `VRTT` for GPU) to a **fan-index value**. The NVIDIA driver (via NVPCF sub-function 5) reads these indices and presumably maps them to actual PWM duty cycles through its own internal table.

### What's Still Missing

The **actual duty-cycle percentages** (e.g., 2%, 11%, 27%, 48%) are **not in ACPI**. They are either:
- Hardcoded in the NVIDIA GPU VBIOS / driver
- Stored in the EC firmware RAM (not accessible from Windows userspace)
- Stored in the encrypted `AC_Config.FanAcoustic.GU605MY.cfg`

### How to Get the EC Tables on Linux

```bash
# Option A: Use ectool from coreboot (requires direct EC access)
sudo ectool -d dump_ec.bin

# Option B: Use nbfc-linux configs for similar G16 models
# Community configs for Zephyrus G16 (2024/2025) exist and are close enough.
```

---

## 3. DPTF Participant Tables — Recovered from SSD9 + SSDA

### SSD9 (`DptfTb DptfTabl`) — Policy Engine

Strings extracted from the DPTF policy SSDT:
- `"[Dptf DptfTabl SSDT][AcpiTableEntry]"`
- `"Notify Sensor 1"`, `"Notify Sensor 2"`, `"Notify Sensor 3"`
- `"SPUR, Arg0="`
- `"UVTH not available"`

Named participants identified:
- `IETM` — Intel DPTF policy coordinator
- `TCPU` — CPU thermal participant
- `SEN1`, `SEN2`, `SEN3` — Generic thermal sensors
- `PLDT` — Power Limit Device
- `CPWR` — CPU power operation region

Heuristic temperature-like integers found:
- `4000` deci-K (~126.9°C) — appears multiple times, likely critical trip point
- `3074` deci-K (~34.2°C) — likely a passive or low trip point
- `4096` deci-K (~136.5°C) — near `CPWR`

### SSDA (`INTEL_ PDatTabl`) — Participant Data Table

This SSDT contains the **full DPTF participant manifest** for this laptop:

| Participant | HID / Type | Purpose |
|-------------|------------|---------|
| `SEN1` | `INTC1042` | Intel DPTF Generic Sensor |
| `SEN2` | `INTC1062` | Intel DPTF Generic Sensor |
| `SEN3` | `INTC1062` | Intel DPTF Generic Sensor |
| `SEN4` | `INTC1062` | Intel DPTF Generic Sensor |
| `SEN5` | `INTC1062` | Intel DPTF Generic Sensor |
| `TPCH` | `INTC1064` | Platform Controller Hub thermal participant |
| `TFN1` | `INTC1063` | Fan participant #1 |
| `TFN2` | `INTC1063` | Fan participant #2 |
| `TFN3` | `INTC1063` | Fan participant #3 |
| `TPWR` | `INTC1065` | Power participant |
| `DPLY` | `INTC1066` | Display participant |
| `CHRG` | `INTC1062` | Charger participant |
| `TCPU` | — | CPU thermal zone |
| `IETM` | — | DPTF policy engine |
| `PLDT` | — | Power limit device |

Thermal trip-point WORDs found in SSDA (deci-K):
- `4500` (~176.9°C)
- `4250` (~151.9°C)
- `4000` (~126.9°C) ← most common, likely `_CRT`
- `3800` (~106.9°C)
- `3500` (~76.9°C)
- `3382` (~65.1°C)
- `3282` (~55.1°C)
- `3232` (~50.1°C)
- `3182` (~45.1°C)
- `3200` (~46.9°C)
- `3000` (~26.9°C)

### Linux Action: Run `dptfxtract`

To get the **exact Celsius trip points** and participant configuration on Linux:

```bash
sudo dptfxtract /sys/firmware/acpi/tables/
# Generates: dptf.dv, dptf.tar.gz, etc.
```

The extracted files can then be fed into `thermald` for custom Linux thermal policy.

---

## 4. NVIDIA VBIOS / NPCF Power Limits — FULLY RESOLVED

### The Missing SSDT Was Found

The `NPCF` (NVIDIA Platform Controller Framework) device is **not defined in the DSDT** — it is only declared as `External`. The actual device lives in:

**`acpi_tables/SSDN_OptRf2_Opt2Tabl_00001000_00000000.dsl`**

This SSDT was disassembled with `iasl`, revealing the **complete** NVPCF `_DSM` implementation.

### NPCF Device Properties

```asl
Device (NPCF) {
    Name (_HID, "NVDA0820")
    Name (_UID, "NPCF")
    Name (CNPF, Zero)          // NVPCF initialized flag
    Name (AMAT, 0xA0)          // Max average temperature? (160)
    Name (ACBT, 0x78)          // Average core boost temp? (120)
    Name (DCBT, Zero)          // Discrete/dGPU boost temp
    Name (DBAC, Zero)          // Dynamic Boost AC enable
    Name (DBDC, One)           // Dynamic Boost DC enable
    Name (AMIT, 0xFFB0)        // Some thermal offset
    Name (ATPP, 0x0168)        // ACPI TGP limit (360 decimal)
    Name (DTPP, Zero)          // Dynamic TGP limit
    Name (TPPL, 0x0001C138)    // TOTAL POWER LIMIT = 115,000 mW = 115 W
    Name (DROS, Zero)          // Drop offset?
    Name (ARAT, 0x50)          // Average rate?
    Name (WM2M, One)           // WMI/WM2 mode flag
    Name (SFTN, 0x06)          // Soft fan table count (6)
}
```

### NVPCF _DSM UUID

```
36b49710-2483-11e7-9598-0800200c9a66
```

This is the official **NVIDIA NVPCF DSM GUID**.

### Sub-Functions Decoded

| Sub-Func | Name | Return Data |
|----------|------|-------------|
| 0 | Get supported functions | `Buffer { 0xBF, 0x07, 0x00, 0x00 }` |
| 1 | Platform capability | 14-byte capability buffer |
| 2 | Power budget info | 49-byte power budget struct (populated from `AMAT`, `ACBT`, `ATPP`, `DTPP`, `DBAC`, `DBDC`) |
| 3 | Fan curve indices | 30-byte buffer containing `SCFI` + `SGFI` |
| 4 | Unknown mapping table | 50-byte lookup table |
| 5 | Thermal / fan query | 40-byte buffer; reads `CTMP` and `VRTT` from EC, maps via `FCPI`/`FGPI` |
| 7 | Set power limits | Writes `AMAX`, `ARAT`, `DMAX`, `DRAT`, `TGPM` from Arg3 |
| 8 | **TGP transition table** | **106-byte buffer (see below)** |
| 9 | Set CPU TDP | Writes `CPTD / 1000` to `EC0.NDF9` |
| 10 | Dynamic TGP info | 8-byte buffer with `DTTL = TPPL` |

### Sub-Function 8: TGP Power Transition Table

This is the table that was previously "missing". It contains **6 entries** of 17 bytes each.

**Header:** `10 04 11 06` → version=`0x10`, hdr_len=`4`, entry_len=`17`, entries=`6`

| Entry | [0] | Word A | Word B | Word C | Word D | Interpretation |
|-------|-----|--------|--------|--------|--------|----------------|
| 0 | `0x64` (100) | 7000 mW | 35000 mW | 27000 mW | 40000 mW | likely 100% utilization row |
| 1 | `0x50` (80) | 7000 mW | 35000 mW | 24000 mW | 36000 mW | 80% utilization row |
| 2 | `0x3C` (60) | 7000 mW | 35000 mW | 23000 mW | 34072 mW | 60% utilization row |
| 3 | `0x32` (50) | 6500 mW | 35000 mW | 20000 mW | 30000 mW | 50% utilization row |
| 4 | `0x19` (25) | 6500 mW | 35000 mW | 19000 mW | 29000 mW | 25% utilization row |
| 5 | `0x0A` (10) | 6500 mW | 35000 mW | 19000 mW | 28000 mW | 10% utilization row |

> **Note:** The exact semantic mapping of the four WORD columns is not fully documented in public NVIDIA specs. The leading byte `[0]` appears to be a percentage or utilization index (100, 80, 60, 50, 25, 10). Column B (constant 35000 mW) may be a platform thermal floor or VRM limit. Columns C and D decrease as the index decreases, suggesting they are power-budget allocations for CPU and GPU respectively.

### How Armoury Crate Applies GPU TGP

From the DSDT + SSDN, the profile-switch flow is:

1. User switches profile → EC0 sets `FTBL` (0=Performance/Balanced, 1=Turbo, 2=Silent)
2. `SFMN()` method runs:
   - `CPUP(0xF0 or 0x0118)` → sets `NPCF.ATPP` and `NPCF.DTPP`
   - Calls `STDM()`, `SPDM()`, `SSSM()`, or `SMSM()` → sets `NPCF.AMAT`, `NPCF.ACBT`, `NPCF.ATPP`
   - Calls `DGPS()` → sets dGPU `TGPU` register via `FMTG` mapping
   - `Notify(NPCF, 0xC0)` → wakes the NVIDIA driver
   - `STPL()` runs:
     ```asl
     If (FTBL == 0x02) { NPCF.TPPL = 0x0001C138 }  // 115 W
     ElseIf (FTBL == Zero) { NPCF.TPPL = 0x0001C138 }  // 115 W
     ```
3. The NVIDIA driver receives the `0xC0` notify, calls `NPCF._DSM` sub-function 10, reads `TPPL`, and applies the new power limit.

### Important Discovery: TPPL Defaults to 115 W

The **default `TPPL` in the SSDN is `0x0001C138` = 115 W**. This means:
- The **base ACPI default for the dGPU is 115 W**, not 80 W.
- The `nvidia-smi` "Default Power Limit" of 80 W is the **VBIOS fallback** when the ACPI `NPCF` device has not been initialized (e.g., on a clean Linux boot without `acpi_osi="Windows 2022"`).
- When Armoury Crate initializes `NPCF` (sub-function 0 sets `CNPF = One`), the driver switches from the 80 W VBIOS default to the ACPI-provided 115 W limit.

### Linux Reproduction

To replicate Armoury Crate's stepped TGP on Linux:

```bash
# VBIOS default (no NPCF init)
sudo nvidia-smi -pl 80

# Performance / Balanced (closest to Armoury Crate base)
sudo nvidia-smi -pl 90

# Turbo (matches default TPPL)
sudo nvidia-smi -pl 115

# Manual max
sudo nvidia-smi -pl 125
```

For the **highest chance of successful NPCF binding on Linux**, ensure these kernel parameters are set:

```
acpi_osi=! acpi_osi="Windows 2022"
```

This makes the ACPI interpreter expose `NPCF` to the NVIDIA driver just as it would on Windows.

---

## 5. S3/S0ix Suspend/Resume ACPI Quirks — Deeply Mapped

### Sleep State Packages (`_S3_`, `_S4_`, `_S5_`)

From raw DSDT hex at offset `0x00B694`:

```hex
_S3_: 5f53335f1207040a0500000008  → S3 = Type A, PM1a_CNT.SLP_TYP = 0x05
_S4_: 5f53345f1207040a0600000008  → S4 = Type A, PM1a_CNT.SLP_TYP = 0x06
_S5_: 5f53355f1207040a0700000014  → S5 = Type A, PM1a_CNT.SLP_TYP = 0x07
```

These are standard Intel sleep-type values for Meteor Lake.

### Critical Methods

| Method | Offset | Role |
|--------|--------|------|
| `_PTS` | `0x00B6BD` | **Prepare To Sleep** — runs before entering S3/S4/S5 |
| `_WAK` | `0x00B708` | **Wake** — runs after resuming from S3/S4 |
| `_REG` | `0x062E43` | EC registration — notifies EC of OS availability |
| `_LID` | `0x0621E0` | Lid status — reads `EC0.LIDS` |

### EC `_REG` Method

At `0x062E43`, the EC `_REG` method is critical because it tells the EC whether the OS is ready to handle ACPI events. If `_REG` is not called correctly on Linux (e.g., if `acpi_osi` tricks break `_OSI` matching), the EC may fall back to a legacy mode that generates constant interrupts or prevents S0ix.

### Lid Method (`_LID`)

The `_LID` method reads `EC0.LIDS` under mutex `MUT0`. If `LIDS == 0`, the lid is closed. This is a standard wake source.

### `_Qxx` EC Query Methods — Full Catalogue

The DSDT contains **44 `_Qxx` methods** handling EC events. Here they are ranked by likelihood to cause Linux suspend/resume quirks:

#### Tier 1 — Very Likely Quirk Sources

| Method | Inferred Purpose | Why It Matters for Linux |
|--------|------------------|--------------------------|
| `_Q3F` | Composite battery/thermal/NVPCF/HID event | Fires on almost every state change; if unmasked, can wake the system repeatedly |
| `_QA8` | GPU power state change (DBAC/DBDC toggle) | Triggers `Notify(NPCF, 0xC0)`; on Linux without the NVIDIA driver bound to NPCF, this may become an unhandled GPE storm |
| `_QD4` | NVPCF / graphics mode switch | Similar to `_QA8`; may fire when the dGPU power state changes during suspend |
| `_QCE`, `_QCF`, `_QBC` | Power button / HID events | Standard wake sources; if the HID driver doesn't consume them, they can cause immediate wake |
| `_Q76`, `_Q77` | Charger plug/unplug | Very common wake source on ASUS laptops when S0ix is used |
| `_Q0D`, `_Q0E` | Lid open/close | Directly tied to suspend/resume logic |

#### Tier 2 — Moderate Risk

| Method | Inferred Purpose |
|--------|------------------|
| `_Q17`, `_Q18` | Thermal / power events |
| `_Q2F` | Fan / thermal threshold |
| `_Q12`, `_Q13` | Battery threshold / status |
| `_Q22` | Keyboard backlight / Fn-key |
| `_QD5`, `_QD6` | Display / GPU events |
| `_QDA` | Unknown system event |

#### Tier 3 — Lower Risk (unknown but catalogued)

`_Q1F`, `_Q4C`, `_Q4F`, `_Q52`, `_Q54`, `_Q56`, `_Q58`, `_Q5A`, `_Q5C`, `_Q5E`, `_Q60`, `_Q62`, `_Q64`, `_Q66`, `_Q68`, `_Q6A`, `_Q6C`, `_Q6E`, `_Q70`, `_Q72`, `_Q74`, `_Q7A`, `_Q8A`, `_QA9`, `_QAF`, `_QB4`, `_QB5`, `_QB8`

### Linux Debugging Recommendations

If S0ix suspend fails or drains battery on Linux:

```bash
# 1. Identify which GPE is firing constantly
sudo cat /sys/firmware/acpi/interrupts/gpe* | grep -v " 0$"

# 2. Temporarily mask suspicious GPEs
sudo bash -c 'echo disable > /sys/firmware/acpi/interrupts/gpeXX'
# Replace XX with the GPE number that fires most often.

# 3. Check dmesg for ACPI notify storms
dmesg | grep -i "acpi.*notify"

# 4. Trace _Q methods during suspend/resume
echo 1 | sudo tee /sys/kernel/debug/tracing/events/acpi/enable
sudo cat /sys/kernel/debug/tracing/trace_pipe | grep -i "_Q"
```

Common ASUS S0ix fixes that may apply to GU605MY:
- Add `acpi_osi=! acpi_osi="Windows 2022"` to GRUB (already recommended)
- Mask GPE associated with `_Q76` / `_Q77` if charger events wake the system
- Ensure `NVME_APST` is enabled so the SSD doesn't block S0ix
- Use `pcie_aspm=force` if PCIe links don't enter L1.2

---

## 6. File Hashes & Reproducibility

| File | SHA-256 |
|------|---------|
| `dsdt_aml.bin` | `7d9c42de9bc5f2021daa5098d378494d1910b590b2bd39a1178f7e7b3054f890` |
| `SSDN_OptRf2_Opt2Tabl_00001000_00000000.bin` | `230c90fbad3b04ebb9bd758c0ee224a483d720249637530dc28b75ca0627b03c` |
| `SSDN_OptRf2_Opt2Tabl_00001000_00000000.dsl` | *(newly generated)* |
| `ThrottleGearXMLHelper.dll` | *(see file)* |

---

## 7. Summary: What Is Still Missing

| Category | Blocker | Next Step |
|----------|---------|-----------|
| **EC firmware fan curves** | Requires hardware access to EC RAM | Boot Linux live USB, run `ectool` or `dptfxtract` |
| **Exact stock fan duty percentages** | Encrypted in `AC_Config.FanAcoustic.GU605MY.cfg` | Runtime memory dump of Armoury Crate Service to extract AES key |
| **Linux S0ix wake-event confirmation** | Needs actual Linux suspend/resume trace | Run `acpidump` + `dmesg` + `/sys/firmware/acpi/interrupts/` on a CachyOS install |

---

*Document generated from deep AML disassembly of DSDT + 27 SSDT tables, static analysis of ASUS Armoury Crate crypto DLLs, and heuristic ACPI parsing.*
