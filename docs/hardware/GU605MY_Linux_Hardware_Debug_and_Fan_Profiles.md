# ASUS ROG Zephyrus G16 GU605MY — Missing Linux Data & Fan/Profile Specifications

**Date:** 2026-04-16  
**Model:** ASUS ROG Zephyrus G16 GU605MY  
**CPU:** Intel Core Ultra 9 185H (MTL, 6P+8E+2LPE)  
**dGPU:** NVIDIA GeForce RTX 4090 Laptop GPU (16GB, AD103)  
**RAM:** 32GB LPDDR5X-7467 (soldered)  
**Display:** 16" Samsung OLED SDC41A3 (2560×1600, 240Hz, HDR)  

---

## 1. Critical Hardware IDs for Linux

These IDs are required for writing udev rules, custom kernel modules, or debugging driver support on Linux.

### PCI Device IDs

| Device | PCI ID | Subsystem | Linux Driver |
|--------|--------|-----------|--------------|
| Intel Core Ultra 9 185H (Host bridge) | `8086:7D01` | — | — |
| Intel Arc iGPU | `8086:7D55` | `1043:3778` | `i915` / `xe` |
| NVIDIA RTX 4090 Laptop | `10DE:2757` | `1043:3608` | `nvidia` / `nouveau` |
| Intel Wi-Fi 6E AX211 | `8086:7E40` | `8086:0094` | `iwlwifi` |
| Intel USB 3.2 xHCI #1 | `8086:7E7D` | `1043:201F` | `xhci_hcd` |
| Intel USB 3.2 xHCI #2 | `8086:7EC0` | `1043:201F` | `xhci_hcd` |
| Intel USB4 Host Router | `8086:7EC2` | `1043:1C63` | `thunderbolt` |
| Realtek Audio Codec | `10EC:0285` | `1043:1C63` | `snd-hda-intel` / `snd-soc-skl` |
| NVIDIA HDA | `10DE:00A4` | `1043:3608` | `snd-hda-intel` |
| Cirrus Logic Smart Amp | `ACPI\CSC3556` | — | `cs35l41` |

### USB Device IDs

| Device | USB ID | Purpose | Linux Notes |
|--------|--------|---------|-------------|
| ASUS N-KEY / ROG Keyboard Controller | `0B05:19B6` | Keyboard RGB, hotkeys, WMI proxy | Primary `asusctl` target |
| ASUS Slash / Firmware Update HID | `0B05:193B` | LED strip, firmware update | `asusctl` AniMe/Slash support |
| ASUS Precision Touchpad | `ASUF1207` (HID) | Touchpad | `hid-multitouch` |
| DualSense Controller | `054C:0CE6` | Gamepad | `hid-playstation` |
| PANORAMA P4 Webcam | `2467:2021` | FHD webcam + IR | `uvcvideo` |
| ASIX USB Ethernet | `0B95:1790` | USB-C ethernet dongle | `ax88179_178a` |

> **Note:** The `0B05:19B6` device is the critical HID interface for `asusctl`. If `lsusb` does not show it on Linux, keyboard RGB and fan control will not work.

### ACPI / WMI Interfaces

| ACPI Device | HID / Name | Linux Relevance |
|-------------|------------|-----------------|
| ASUS System Control Interface v3 | `ACPI\ASUS2018` | `asus_wmi` kernel module binds here |
| ATKD (ASUS ATK) | `\_SB_.ATKD` | Legacy WMI method namespace in DSDT |
| FAN0 Thermal Zone | `PNP0C0B` | ACPI fan device; `_FST` controls speeds |
| IETM (Intel DPTF) | `\_SB_.IETM` | Dynamic Platform and Thermal Framework |
| PLDT (Power Limit Device) | `\_SB_.PLDT` | Thermal policy / PL1-PL2 coordination |
| EC0 (Embedded Controller) | `\_SB_.PC00.LPCB.EC0_` | Handles fan RPMs (`_FRMS`), temps, power |
| NPCF (NVIDIA Platform Ctrl) | `\_SB_.NPCF` | ACPI interface for GPU TGP switching (`NVDA0820`) |

---

## 2. DSDT / ACPI Findings

The DSDT was dumped from Windows registry (`HKEY_LOCAL_MACHINE\HARDWARE\ACPI\DSDT\_ASUS_\Notebook\01072009`) and saved as `dsdt_aml.bin` (434,724 bytes).

### 2.1 Fan Control — FAN0 Thermal Zone

The DSDT defines a single ACPI fan device `FAN0` under `\_TZ_`:

```asl
Device (FAN0) {
    Name (_HID, EisaId ("PNP0C0B"))
    Name (LRPM, 0)
    Name (URPM, 0)
    Name (CFST, Package (0x03) { 0, 0, 0 })
    Name (GRAN, 0)
    Name (FOPR, Package (0x04) { 0x0960, 0x0028, 0x0B1C, 0x0D48 })
    // 2400, 40, 2844, 3400 decimal
}
```

| Field | Value | Interpretation |
|-------|-------|----------------|
| `FOPR[0]` | `2400` | Likely minimum stable RPM (or low-speed threshold) |
| `FOPR[1]` | `40` | Possibly a hysteresis or duty-step value |
| `FOPR[2]` | `2844` | Mid-range operating RPM |
| `FOPR[3]` | `3400` | High-speed target RPM |

**Important:** The DSDT shows `LRPM = 0` and `URPM = 0`, meaning the actual min/max RPM limits are **not hardcoded in ACPI** — they are either stored in the EC firmware or supplied by Armoury Crate at runtime.

### 2.2 Fan Methods

| Method | Location | Purpose |
|--------|----------|---------|
| `GCFR()` | `FAN0` | **G**et **C**urrent **F**an **R**PM. Reads `_SB.PC00.LPCB.EC0._FRMS` from the EC. |
| `_FST()` | `FAN0` | **F**an **S**tatus / **S**e**t** fan speed. Uses `GCFR()` to populate `CFST`. |
| `SFST()` | `FAN0` | **S**et **F**an **ST**ate. Notifies `FAN0` with thermal event `0x80`. |
| `CRNF()` | `FAN0` | Appears to calculate a corrected/normalized RPM value. |
| `FANL()` | `\_SB_.ATKD` | Returns `1` — likely a **fan limit** or **fan lock** query. |

### 2.3 Embedded Controller (EC) Fields

The DSDT references these EC0 fields for power/thermal management:

| EC Field | DSDT Reference | Likely Purpose |
|----------|----------------|----------------|
| `EC0._FRMS` | `GCFR()` | Fan RPM reading from EC |
| `EC0._TTT1` | `TGPU` scope | GPU temperature sensor |
| `EC0._TTT2` | `TGPU` scope | Secondary GPU temp / hotspot |
| `EC0.VLTT` | `PLDT` scope | VRM or voltage limit temp |
| `EC0.VRTT` | `PLDT` scope | VR thermal throttle |
| `EC0.SKE9` | Various | Possibly skin / chassis temp |
| `EC0.CLOT` | Thermal zone | CPU load or thermal offset |
| `EC0.VLTT` | Thermal zone | VLimit temperature |

### 2.4 Power Limit Variables

Under the `\_SB_.NPCF` (NVIDIA Platform Controller Framework?) and `ATKD` scopes:

| Variable | DSDT Offset | Purpose |
|----------|-------------|---------|
| `PL1V` | `0x063542` | CPU PL1 (sustained TDP) value — written by DPTF |
| `PL2V` | `0x063547` | CPU PL2 (turbo TDP) value — written by DPTF |
| `GBD0-GBD7` | `0x063579` | GPU boost / TGP limit table entries |
| `CBD0-CBD7` | `0x063544` | CPU boost / TDP limit table entries |
| `CMB0-CMBF` | `0x06359A` | Combined CPU+GPU power budget table (16-bit entries) |
| `GMB0-GMBF` | `0x0635EE` | GPU-only power budget table (16-bit entries) |

There is also a CPU power management operation region (`CPWR`) at `0x02557F` with methods:
- `SPL1()` — **S**et CPU **PL1** limit (writes `PPL1` to `PLSV`, `PL1E` to `PLEN`, `CLP1` to `CLMP`)
- `RPL1()` — **R**estore CPU **PL1** limit (restores saved values)

> **Linux Relevance:** Tools like `throttled`, `intel-undervolt`, or `rapl-tune.service` can override `PL1V`/`PL2V` via MSR, but they cannot directly write these ACPI variables. The EC/BIOS will re-apply them on profile changes.

### 2.5 Thermal Sensors

The DSDT defines multiple TMP sensor objects (`TMP1`–`TMPG`) under what appears to be the DPTF participant driver. These map to:

- `TMP1`–`TMPG`: Various DPTF thermal zones / trip points
- `TCPU`: CPU thermal zone (PCI device scope, `_ADR 0x00040000`)
- `TGPU`: GPU thermal zone (RP12 / PXSX scope)
- `TSYS`: System/chassis thermal zone

### 2.6 Fan PWM / RPM Limit Tables in DSDT

At offset `0x007A3B`, the DSDT contains a large block of thermal/fan limit tables:

```
FMH1, FML1, FMD1, FPH1, FPL1, FPD1, HSH1, HSL1, HSD1
FMH2, FML2, FMD2, FPH2, FPL2, FPD2, HSH2, HSL2, HSD2
...
```

| Prefix | Likely Meaning |
|--------|----------------|
| `FMH*` | Fan Max High threshold |
| `FML*` | Fan Max Low threshold |
| `FMD*` | Fan Max Delta / deadband |
| `FPH*` | Fan P-curve High threshold |
| `FPL*` | Fan P-curve Low threshold |
| `FPD*` | Fan P-curve Delta |
| `HSH*` | Heatsink / thermal High |
| `HSL*` | Heatsink / thermal Low |
| `HSD*` | Heatsink / thermal Delta |

There are at least 5 indexed sets (1–5), likely corresponding to the **Silent / Balanced / Performance / Turbo / Manual** profiles. These tables are referenced by DPTF/EC firmware to choose the appropriate fan response per profile.

### 2.7 ACPI Table Dump Results

All ACPI tables were extracted from the Windows registry and saved to `acpi_tables/`. In total, **27 tables** were recovered:

| Table | Signature / OEM ID | Purpose | SHA-256 |
|-------|-------------------|---------|---------|
| `DSDT__ASUS__Notebook_01072009_00000000.bin` | `_ASUS_ Notebook` | Differentiated System Description Table | `7d9c42de9bc5f2021daa5098d378494d1910b590b2bd39a1178f7e7b3054f890` |
| `FADT__ASUS__Notebook_01072009_00000000.bin` | `_ASUS_ Notebook` | Fixed ACPI Description Table | `94c3d1d1060a4d2bad44d839a9fdb8410dabbf5d90553f9aab80dc629c50a5e1` |
| `RSDT__ASUS__Notebook_01072009_00000000.bin` | `_ASUS_ Notebook` | Root System Description Table | `8af3b13f175fe3dc1752de7a4f0e32ecfc363fcab75d21ec52cf4e756fa6fcc5` |
| `SSD1_PmRef_Cpu0Hwp_00003000_00000000.bin` | `PmRef Cpu0Hwp` | CPU HWP states | `c87c484538bd20b0130d269c33e7417f4f3434497190a4791e0458dcd13d525a` |
| `SSD2_PmRef_Cpu0Psd_00003000_00000000.bin` | `PmRef Cpu0Psd` | CPU Power State Dependencies | `1cdad51df820a1333c018e22b8852c54be4825adf3a2d098a1d0e597abfa1bd8` |
| `SSD3_PmRef_Cpu0Cst_00003001_00000000.bin` | `PmRef Cpu0Cst` | CPU C-States | `d32c176fcb5c2bf9e3a458c95b8f98fa0be651c471eb9d877c9636d0f939e13e` |
| `SSD4_PmRef_ApIst_00003000_00000000.bin` | `PmRef ApIst` | AP P-states | `8fab06cadf1be2618b42a22a30859becbe9ebd3e767ad9f294a246e48c1429fd` |
| `SSD5_PmRef_ApHwp_00003000_00000000.bin` | `PmRef ApHwp` | AP HWP states | `0951cf4561be4f4981a87a056e6c60ecf838ffe5f975e18be6bd2439a6f60322` |
| `SSD6_PmRef_ApPsd_00003000_00000000.bin` | `PmRef ApPsd` | AP Power State Dependencies | `374fbe231b0a1dc3161cc32c7baf62adef073005522eb79e9a3353ad1e5a5c24` |
| `SSD7_PmRef_ApCst_00003000_00000000.bin` | `PmRef ApCst` | AP C-States | `098f3337d19a7ff11c6b437f2710377264d692c02d0e7772f526f5e9eef797fe` |
| `SSD8_CpuRef_CpuSsdt_00003000_00000000.bin` | `CpuRef CpuSsdt` | CPU SSDT overrides | `5ed82401fe8634a06b4f3f9eed8c607b3c328950d9684362f3fe6e3d72504e62` |
| `SSD9_DptfTb_DptfTabl_00001000_00000000.bin` | `DptfTb DptfTabl` | **Intel DPTF policy tables** | `ffdc1ed210414bd88fe6f5a9fc76cb27cbf24d6ebcda63de15493895ad0489dd` |
| `SSDA_INTEL__PDatTabl_00001000_00000000.bin` | `INTEL_ PDatTabl` | DPTF participant data | `875987f3f83171110572fe56a0b4f7a13d3a261c3c768b224e49f0ef3b1c6138` |
| `SSDB_PmaxDv_Pmax_Dev_00000001_00000000.bin` | `PmaxDv Pmax_Dev` | Platform max power device | `8e49069233b212ffaeb1b7b0229968d3d3970c12c12a172e5129ebddcbf9a210` |
| `SSDC_INTEL__IgfxSsdt_00003000_00000000.bin` | `INTEL_ IgfxSsdt` | iGPU SSDT | `15650a7a087c5ef414eb0ff82bc19e2e8825b67074f8e5711f83fb5ae1967963` |
| `SSDD_INTEL__TcssSsdt_00001000_00000000.bin` | `INTEL_ TcssSsdt` | TCSS (Thunderbolt) SSDT | `96c9723aab8a950738bc3efd7ccd3de715ed7c84f848c11a47b2c41bacf5718a` |
| `SSDE__ASUS__MtlP_Rvp_00001000_00000000.bin` | `_ASUS_ MtlP_Rvp` | Meteor Lake P RVP | `6b64fab5ff2a18190e89481602f5cccea9038b2af0c42398595c8cf84645c381` |
| `SSDF__ASUS__I2Pm_Rvp_00001000_00000000.bin` | `_ASUS_ I2Pm_Rvp` | I2C PMIC RVP | `e1ec1a95d118addf78f1209374a0672fe2a717934e93db2e286e0fd3b9c4e652` |
| `SSDG__ASUS__PtidDevc_00001000_00000000.bin` | `_ASUS_ PtidDevc` | PTID device config | `ae774b5c289e89449c87f8a74b3ac0e8d8e26d53d5509c0767f2d246b05ace62` |
| `SSDH__ASUS__TbtTypeC_00000000_00000000.bin` | `_ASUS_ TbtTypeC` | Thunderbolt Type-C config | `39beeda2138743280fcf877ace350313c1a18c63b4bd8ba32b46bfcf7db7ec51` |
| `SSDI__ASUS__UsbCTabl_00001000_00000000.bin` | `_ASUS_UsbCTabl` | USB-C power delivery tables | `f5f7e09fdd40880a36f54c7aa7a5afd99a84acdb71c9d72c2b643a26a540e44a` |
| `SSDJ_INTEL_xh_mtlp3_00000000_00000000.bin` | `INTEL_ xh_mtlp3` | xHCI MTL-P3 | `0d948e78f4e92585c7ac98e0359f89adace908d13c479f67c5925168b050a7d4` |
| `SSDK_SocGpe_SocGpe__00003000_00000000.bin` | `SocGpe SocGpe_` | SoC GPE config | `2dc22abde593caef99af32ea9c414ddd8bf372d99d95e3ff8c9ed5eccc75a8c1` |
| `SSDL_SocCmn_SocCmn__00003000_00000000.bin` | `SocCmn SocCmn_` | SoC common config | `ec04be83e2e57c5b2505baaa2be5c43839afdcbf850d3d72bce5c3666d4edbe8` |
| `SSDM_INTEL_St00Ssdt_00001000_00000000.bin` | `INTEL_ St00Ssdt` | Storage SSDT | `8acda4f001ff71cf91ca21519c4d9ee13b0a105bd77916da87e9ea3d97d2bbda` |
| `SSDN_OptRf2_Opt2Tabl_00001000_00000000.bin` | `OptRf2 Opt2Tabl` | **Optimizer RF / NPCF device** | `230c90fbad3b04ebb9bd758c0ee224a483d720249637530dc28b75ca0627b03c` |
| `SSDT_PmRef_Cpu0Ist_00003000_00000000.bin` | `PmRef Cpu0Ist` | CPU P-states | `1222c7d8883c3429ac1db6bf52269c9f0a5ed2ec1be9336d7d1252bd746816c9` |

### 2.8 EC Query Method Map (`_Qxx`)

The DSDT defines **44 EC query methods** (`_Q00`–`_QFF` range) that handle real-time events from the Embedded Controller. These are the primary candidates for Linux suspend/resume quirks and hotkey support.

| Method | DSDT Location | Known / Inferred Purpose |
|--------|--------------|--------------------------|
| `_Q0D` | `0x03FB98` | Lid open/close event |
| `_Q0E` | `0x03FC46` | Lid state change (mirror of `_Q0D`) |
| `_Q12` | `0x04008F` | Battery threshold / charge event |
| `_Q13` | `0x04019B` | Battery status change |
| `_Q17` | `0x040282` | Thermal / power event |
| `_Q18` | `0x0402EB` | Thermal / power event |
| `_Q1F` | `0x040353` | Unknown HID/thermal event |
| `_Q22` | `0x0404AB` | Keyboard backlight / Fn-key |
| `_Q2F` | `0x04059E` | Fan / thermal threshold |
| `_Q31` | `0x040660` | Unknown system event |
| `_Q3F` | `0x040C7B` | **Composite event** — battery, thermal, NVPCF, HID updates |
| `_Q4C` | `0x041097` | Unknown |
| `_Q4F` | `0x04110A` | Unknown system event |
| `_Q52` | `0x0411B2` | Unknown |
| `_Q54` | `0x04121F` | Unknown |
| `_Q56` | `0x0412C4` | Unknown |
| `_Q58` | `0x04133E` | Unknown |
| `_Q5A` | `0x0413C6` | Unknown |
| `_Q5C` | `0x041455` | Unknown |
| `_Q5E` | `0x0414D1` | Unknown |
| `_Q60` | `0x04155C` | Unknown |
| `_Q62` | `0x0415D6` | Unknown |
| `_Q64` | `0x04165E` | Unknown |
| `_Q66` | `0x0416EB` | Unknown |
| `_Q68` | `0x041767` | Unknown |
| `_Q6A` | `0x0417F5` | Unknown |
| `_Q6C` | `0x041885` | Unknown |
| `_Q6E` | `0x041900` | Unknown |
| `_Q70` | `0x04198C` | Unknown |
| `_Q72` | `0x041A08` | Unknown |
| `_Q74` | `0x041A97` | Unknown |
| `_Q76` | `0x041B6D` | Power / charger event |
| `_Q77` | `0x041C19` | Power / charger event |
| `_Q7A` | `0x041E39` | Unknown system event |
| `_Q8A` | `0x0422E5` | Unknown HID event |
| `_QA8` | `0x042C79` | **GPU power state change** — calls `NPCF.GNVP()` |
| `_QA9` | `0x042D0E` | GPU / display event |
| `_QAF` | `0x042D7D` | Unknown |
| `_QB4` | `0x042E65` | Unknown |
| `_QB5` | `0x042EB0` | Unknown |
| `_QB8` | `0x042F6B` | Unknown |
| `_QBC` | `0x04304A` | Power button / HID event |
| `_QD4` | `0x043125` | **NVPCF / graphics event** |
| `_QD5` | `0x0431B0` | Display / GPU event |
| `_QD6` | `0x0431F3` | Display / GPU event |
| `_QDA` | `0x043269` | Unknown system event |
| `_QCE` | `0x0432E0` | Power button / HID event |
| `_QCF` | `0x043331` | Power button / HID event |

> **Linux Suspend/Resume Note:** `_Q3F`, `_QA8`, `_QD4`, `_QCE`, `_QCF`, `_QBC`, `_Q76`, and `_Q77` are the most likely sources of unexpected wake events. If Linux S0ix suspend drains battery or wakes immediately, masking these EC GPEs in a custom ACPI override or via `/sys/firmware/acpi/interrupts/` may be required.

### 2.9 Sleep / Wake ACPI Methods

From raw DSDT parsing, the following critical sleep/wake methods were located:

| Method | Offset | Role |
|--------|--------|------|
| `_PTS` | `0x00B6BD` | **Prepare To Sleep** — runs before entering S3/S4/S5 |
| `_WAK` | `0x00B708` | **Wake** — runs after resuming from S3/S4 |
| `_REG` | `0x062E43` | EC registration — notifies EC of OS availability |
| `_LID` | `0x0621E0` | Lid status — reads `EC0.LIDS` |

Sleep state packages (`_S3_`, `_S4_`, `_S5_`) are at `0x00B694`:
- `_S3_` = `0x05` (S3 sleep type)
- `_S4_` = `0x06` (S4 sleep type)
- `_S5_` = `0x07` (S5 sleep type)

The `_REG` method is critical: if it is not invoked correctly on Linux (e.g., due to `acpi_osi` mismatches), the EC may fall back to a legacy mode that prevents S0ix or generates constant GPE interrupts.

### 2.10 DPTF Participant Analysis

The **Intel Dynamic Platform and Thermal Framework** on this laptop spans:

- **SSD9** (`DptfTb DptfTabl`) — primary DPTF policy tables
- **SSDA** (`INTEL_ PDatTabl`) — participant data tables
- **DSDT** — `IETM`, `PLDT`, `SEN1`–`SEN8`, `TCPU`, `TGPU`, `TSYS` thermal devices

From **SSDA**, the complete participant manifest is:

| Participant | HID / Type | Purpose |
|-------------|------------|---------|
| `SEN1` | `INTC1042` | Generic DPTF sensor |
| `SEN2`–`SEN5` | `INTC1062` | Generic DPTF sensors |
| `TPCH` | `INTC1064` | Platform Controller Hub thermal participant |
| `TFN1`–`TFN3` | `INTC1063` | Fan participants (3 fans) |
| `TPWR` | `INTC1065` | Power participant |
| `DPLY` | `INTC1066` | Display thermal participant |
| `CHRG` | `INTC1062` | Charger thermal participant |
| `TCPU` | — | CPU thermal zone |
| `IETM` | — | DPTF policy engine |
| `PLDT` | — | Power limit device |

Heuristic trip-point temperatures found in SSDA/SSD9 (deci-K):
- `4000` (~126.9°C) — most common, likely `_CRT` (critical)
- `3800` (~106.9°C)
- `3500` (~76.9°C)
- `3382` (~65.1°C)
- `3282` (~55.1°C)
- `3182` (~45.1°C)
- `3074` (~34.2°C)

Because DPTF trip points are computed at runtime via `IETM._DSM` and `IETM.CTOK()`, the **exact Celsius values are not hardcoded in the AML**. To extract them on Linux, run:

```bash
sudo dptfxtract /sys/firmware/acpi/tables/
```

This will generate `dptf.dv` files with the decoded participant tables for use with `thermald`.

---

## 3. Fan Specifications

### 3.1 Physical Fan Specs (from teardowns & public data)

The GU605MY uses **dual fans** with a shared vapour-chamber heatsink:

| Spec | Value |
|------|-------|
| **Number of fans** | 2 (CPU-side + GPU-side) |
| **Fan type** | Blower / centrifugal, ~50–55mm diameter |
| **Max observed RPM (CPU fan)** | ~6400–6500 RPM |
| **Max observed RPM (GPU fan)** | ~6100–6300 RPM |
| **Max RPM in Manual 100% mode** | ~6600 RPM (target), typically hits ~6100–6400 |
| **Idle RPM (Silent profile, cool)** | ~1800–2200 RPM |
| **Noise @ 100% fans** | ~50 dBA at head level |
| **Noise @ Turbo** | ~45–46 dBA |
| **Noise @ Performance** | ~42 dBA |
| **Noise @ Silent** | ~35 dBA or lower |

### 3.2 ACPI Fan Operating Points

From the DSDT `FOPR` package:

| Index | Hex | Decimal | Likely Meaning |
|-------|-----|---------|----------------|
| 0 | `0x0960` | `2400` | Low-speed floor RPM |
| 1 | `0x0028` | `40` | Fan curve step / hysteresis |
| 2 | `0x0B1C` | `2844` | Mid-speed target RPM |
| 3 | `0x0D48` | `3400` | High-speed target RPM |

> These are **not** the absolute min/max. The EC firmware supports higher RPMs (up to ~6400) through PWM duty cycles that are not exposed in ACPI constants.

### 3.3 NVPCF Fan Curve Index Buffers (from SSDN)

The `NPCF` device in `SSDN` exposes two 12-byte index buffers used by NVPCF sub-function 5 to map EC temperatures to fan indices:

#### `SCFI` — CPU Fan Index Buffer
```hex
FF 00 3C 3F 3F 46 46 57 57 5A 5A 5E
```

| Bytes | Value | Meaning |
|-------|-------|---------|
| [0] | `0xFF` | Sentinel |
| [1] | `0x00` | Base offset |
| [2,4,6,8,10] | `60,63,70,87,90` | Temperature thresholds (°C) |
| [3,5,7,9,11] | `63,70,87,90,94` | Fan index / step |

#### `SGFI` — GPU Fan Index Buffer
```hex
FF 00 2D 33 33 37 37 3F 3F 43 43 46
```

| Bytes | Value | Meaning |
|-------|-------|---------|
| [0] | `0xFF` | Sentinel |
| [1] | `0x00` | Base offset |
| [2,4,6,8,10] | `45,51,55,63,67` | Temperature thresholds (°C) |
| [3,5,7,9,11] | `51,55,63,67,70` | Fan index / step |

> **Note:** The actual duty-cycle percentages (e.g., 2%, 11%, 27%, 48%) are **not in ACPI**. They are stored in the EC firmware or in the encrypted `AC_Config.FanAcoustic.GU605MY.cfg`.

### 3.4 Linux Fan Curve Examples

A CachyOS user with a 2025 Zephyrus G16 reported the following stock curves visible via `asusctl fan-curve -g`:

```
CPU: enabled: true, 40c:2%,44c:4%,55c:11%,64c:13%,68c:17%,72c:27%,76c:36%,80c:48%
GPU: enabled: true, 40c:7%,44c:11%,55c:20%,64c:22%,68c:24%,72c:32%,76c:37%,80c:50%
MID: enabled: true, 40c:8%,44c:12%,55c:17%,64c:25%,68c:29%,72c:40%,76c:52%,80c:66%
```

> **Note:** These are from a similar G16 model and serve as a reference. Your exact stock curves may differ slightly.

### 3.5 Linux Fan Control Compatibility

- **asusctl fan-curve**: Supported on kernels ≥ 5.17 with the ASUS WMI fan-curve patch. The GU605MY appears to expose 3 fan curve channels on Linux:
  - `CPU` fan curve
  - `GPU` fan curve  
  - `MID` (middle / auxiliary) fan curve

- **ROG Control Center**: GUI editor works for setting per-profile curves.

- **Warning from upstream**: Custom fan curves on some ASUS laptops can cause "stuttering, videos dropping frames or other seemingly power related issues." If this occurs, disable custom curves and fall back to BIOS/EC defaults.

---

## 4. Performance Profiles — Detailed Specifications

### 4.1 Armoury Crate / Windows Power Profiles

| Profile | Windows Power Scheme GUID | Default Throttle Mode |
|---------|---------------------------|----------------------|
| **Silent** | `64a64f24-65b9-4b56-befd-5ec1eaced9b3` | `1` (from `InitialSetting.ini`) |
| **Balanced** | `381b4222-f694-41f0-9685-ff5bb260df2e` | — |
| **Performance** | `27fa6203-3987-4dcc-918d-748559d549ec` | `2` (from `InitialSetting.ini`) |
| **Turbo** | `6fecc5ae-f350-48a5-b669-b472cb895ccf` | — |
| **Audio Performance** | `9ef1ab32-2a62-4ae8-9e24-260a1bc91305` | — |

> `InitialSetting.ini` shows `ThrottleModeOnAC=2` and `ThrottleModeOnDC=1`, which maps to **Performance on AC** and **Balanced on DC**.

### 4.2 Real-World Power & Thermal Limits (from review data)

These values were validated by [UltrabookReview](https://www.ultrabookreview.com/67347-asus-rog-zephyrus-g16-gu605my-review-core-ultra-9-185h-rtx-4090/) for the RTX 4090 configuration with vapour-chamber cooling:

| Profile | CPU PL1 | CPU PL2 | GPU TGP (solo) | GPU TGP (crossload) | Combined Power | Noise |
|---------|---------|---------|----------------|---------------------|----------------|-------|
| **Silent** | 55W | 60W | ~55W | D-Notify / limited | ~110W (30W CPU + 80W GPU) | ~35 dBA |
| **Performance** | 70W | 95W | 90W | ~110W (30W CPU + 80W GPU) | ~140W | ~42 dBA |
| **Turbo** | 80W | 100W | 115W | ~130W (35W CPU + 95W GPU) | ~160W | ~45–46 dBA |
| **Manual** | 85W | 110W | 125W | ~140W (35W CPU + 105W GPU) | ~170W+ | ~50 dBA |

> **Crossload** = simultaneous CPU + GPU stress. The shared heatsink forces a trade-off: raising GPU TGP reduces available CPU power and vice versa.

### 4.3 Windows Processor Power Management (from registry hives)

Settings extracted from the `.pwcfg` registry hive files:

#### Performance (BA) & Turbo (HP)
- **Minimum Processor State (AC):** `100%`
- **Minimum Processor State (DC):** `5%`
- **Maximum Processor State (AC):** `100%`
- **Maximum Processor State (DC):** `100%`
- **Intel Graphics Power Plan (AC/DC):** `Maximum Performance (2)`
- **PCI Express ASPM (AC):** `Off (0)`

#### Silent (PS)
- **Minimum Processor State (AC):** `5%`
- **Minimum Processor State (DC):** `5%`
- **Maximum Processor State (AC):** `100%`
- **Maximum Processor State (DC):** `100%`
- **Intel Graphics Power Plan (AC/DC):** `Balanced (1)`
- **PCI Express ASPM (AC/DC):** `Off (0)` / `Moderate power savings (1)`

> The **Silent** profile is the only one that significantly reduces the Intel Graphics power plan and allows deeper ASPM power saving.

### 4.4 NVIDIA Power Limits — Full NPCF Decode

The `NPCF` device is defined in **`SSDN_OptRf2_Opt2Tabl_00001000_00000000.bin`** (disassembled to `.dsl`). It exposes the official NVIDIA NVPCF `_DSM` with UUID:

```
36b49710-2483-11e7-9598-0800200c9a66
```

#### NPCF Default Properties

| Property | Value | Meaning |
|----------|-------|---------|
| `TPPL` | `0x0001C138` | **Total Power Limit = 115,000 mW = 115 W** |
| `ATPP` | `0x0168` | ACPI TGP parameter (360) |
| `AMAT` | `0xA0` | Max average temperature threshold (160) |
| `ACBT` | `0x78` | Average core boost temp threshold (120) |
| `DBAC` | `0` | Dynamic Boost on AC (disabled by default) |
| `DBDC` | `1` | Dynamic Boost on DC (enabled by default) |
| `WM2M` | `1` | WMI mode flag |

#### How TGP Is Applied

1. The DSDT `STPL()` method sets `NPCF.TPPL = 115W` for `FTBL == 0x02` (Silent) and `FTBL == 0` (Performance/Balanced).
2. `SFMN()` calls `Notify(NPCF, 0xC0)` to tell the NVIDIA driver to re-read the power limit.
3. The NVIDIA driver calls `NPCF._DSM` sub-function 10 and receives `DTTL = TPPL`.
4. The driver then applies the new GPU power ceiling.

> **Critical Finding:** The **ACPI default TGP is 115 W**. The `nvidia-smi` "Default Power Limit" of 80 W is only the **VBIOS fallback** when the ACPI `NPCF` device has **not been initialized** by the OS. This commonly happens on Linux boots without the `acpi_osi="Windows 2022"` workaround.

#### NVPCF Sub-Functions

| Sub-Func | Purpose | Linux Relevance |
|----------|---------|-----------------|
| 0 | Get supported functions | `0x07BF` bitmask |
| 1 | Platform capability | 14-byte caps |
| 2 | Power budget info | Populated from `AMAT`/`ACBT`/`ATPP`/`DTPP` |
| 3 | Fan curve indices | Returns `SCFI` + `SGFI` buffers |
| 4 | Unknown mapping table | 50-byte lookup |
| 5 | Thermal / fan query | Reads `EC0.CTMP`/`EC0.VRTT`, maps to fan indices |
| 7 | Set power limits | Accepts `AMAX`, `ARAT`, `DMAX`, `DRAT`, `TGPM` |
| 8 | TGP transition table | 106-byte table (see below) |
| 9 | Set CPU TDP | Writes `CPTD/1000` to `EC0.NDF9` |
| 10 | Dynamic TGP info | Returns 8-byte buffer with `DTTL = TPPL` |

#### NVPCF Sub-Function 8 — TGP Transition Table

```
Header: 10 04 11 06  → version=0x10, hdr=4, entry_len=17, entries=6
```

| Entry | [0] | A (mW) | B (mW) | C (mW) | D (mW) | Notes |
|-------|-----|--------|--------|--------|--------|-------|
| 0 | `0x64` (100) | 7000 | 35000 | 27000 | 40000 | 100% index |
| 1 | `0x50` (80) | 7000 | 35000 | 24000 | 36000 | 80% index |
| 2 | `0x3C` (60) | 7000 | 35000 | 23000 | 34072 | 60% index |
| 3 | `0x32` (50) | 6500 | 35000 | 20000 | 30000 | 50% index |
| 4 | `0x19` (25) | 6500 | 35000 | 19000 | 29000 | 25% index |
| 5 | `0x0A` (10) | 6500 | 35000 | 19000 | 28000 | 10% index |

> The exact semantic mapping of columns A–D is not publicly documented by NVIDIA, but the structure confirms that NVPCF manages a **platform power budget table** indexed by utilization percentage.

#### Linux TGP Commands

```bash
# VBIOS fallback (no NPCF init)
sudo nvidia-smi -pl 80

# Performance-like
sudo nvidia-smi -pl 90

# Turbo (matches default ACPI TPPL)
sudo nvidia-smi -pl 115

# Manual maximum
sudo nvidia-smi -pl 125
```

---

## 5. Missing Data That Is Still Needed for Linux

Despite extensive probing, the following data remains **unavailable or encrypted** and would be helpful for complete Linux support:

### 5.1 Encrypted Armoury Crate Configs

The following files are **AES-256-CBC encrypted** via .NET `EncryptedXml` and their contents could not be decrypted:

| File | Size | First 16 bytes (hex) | Contents (inaccessible) |
|------|------|----------------------|-------------------------|
| `AC_Config.FanAcoustic.GU605MY.cfg` | 1985 | `f531c4b077137c418021d85c73d77c1a` | Exact fan curve tables for each profile |
| `AC_Config.PowerMode.GU605MY.enc` | 1264 | `074642fa5b2dcc87b6da47ae93fc90de` | PL1/PL2/GPU TGP mappings per profile |
| `AC_Config.TGP.GU605MY.enc` | 496 | `074642fa5b2dcc87b6da47ae93fc90de` | GPU Total Graphics Power limits |
| `AC_Config.VgaOc.GU605MY.enc` | 8416 | `074642fa5b2dcc87b6da47ae93fc90de` | GPU clock/voltage offsets |
| `ThrottleGear_GU605MY.xml` | 18500 | *(XML EncryptedData)* | Full thermal & fan policy XML |

**Encryption Analysis:**
- File format: .NET `EncryptedXml` with `EncryptedData` element
- Cipher: AES-256-CBC
- IV: prepended to ciphertext in `.cfg`/`.enc` files (first 16 bytes)
- Key source: **Not found on filesystem** (`org.pwd` missing)
- Crypto handler: `ThrottleGearXMLHelper.dll` (`C:/Program Files/ASUS/Armoury Crate Service/ThrottleMonitorPlugin/`)
- DLL uses `AesCryptoServiceProvider` + `EncryptedXml`; **no hardcoded key** was found in static string analysis
- Brute-force attempts with 30+ passwords and MD5/SHA1/SHA256 derivations **all failed**
- Key is likely derived at runtime via Windows DPAPI or a certificate/key container

> **Impact on Linux:** Without decrypting these, we cannot replicate the **exact** stock fan duty percentages or GPU voltage/clock offsets that Armoury Crate applies on Windows. The ACPI/NVPCF data provides functionally equivalent power-limit and fan-index mappings.

### 5.2 EC Firmware Fan Curve Tables

The EC firmware stores the actual PWM-to-RPM and temperature-to-duty mappings. These are **not exposed in ACPI** and would require:
- EC firmware dump (risky, requires SPI flasher or vulnerability)
- Runtime probing with tools like `ectool` (from `coreboot`) or `nbfc`

### 5.3 Complete DPTF Participant Tables

Intel DPTF on this laptop uses ACPI namespace `IETM` with multiple thermal participants (`SEN1`–`SEN8`, `PLDT`, `TCPU`, `TGPU`). The **full participant configuration tables** are partially visible in DSDT/SSD9/SSDA but the complete power/thermal trade-off logic is not fully decoded. Use `dptfxtract` on Linux to pull the remaining tables from runtime ACPI.

### 5.4 Linux S0ix Suspend/Resume Confirmation

While the DSDT contains 44 EC query methods (`_Qxx`) and the critical `_PTS`/`_WAK`/`_REG`/`_LID` methods have been mapped, a **full trace during actual S3/S0ix suspend and resume on Linux** is still needed to confirm which wake events must be masked.

Key candidates:
- `_Q3F` (battery/thermal/NVPCF/HID composite event)
- `_QA8` (GPU power state changes)
- `_QD4` (NVPCF/graphics event)
- `_QCE` / `_QCF` / `_QBC` (power button / HID events)
- `_Q76` / `_Q77` (charger / power events)
- `_Q0D` / `_Q0E` (lid events)

---

## 6. Recommendations for Linux Users

1. **Use `asusctl` + `rog-control-center`** for profile switching and approximate fan curves. The `0B05:19B6` USB HID device is your canary — if it is missing from `lsusb`, install `acpi_osi=! acpi_osi="Windows 2022"` kernel params.

2. **For exact GPU power limiting**, use `nvidia-smi -pl <watts>` rather than trying to replicate Armoury Crate's stepped tables:
   - CPU-bound games: `90W`
   - GPU-bound games: `115W`
   - Benchmarks / manual mode: `125W`

3. **Ensure NPCF is initialized** by the NVIDIA driver. If `nvidia-smi -q -d POWER` shows **Default = 80W** even after boot, the ACPI `NPCF` device was not bound. Add `acpi_osi=! acpi_osi="Windows 2022"` to GRUB and reboot.

4. **For fan control fallback**, if `asusctl` curves are unstable, use `nbfc-linux` and point it at a profile for the Zephyrus G16 (community configs exist for similar models).

5. **For thermal monitoring**, the `asus_wmi` module exposes some sensors, but you may also want `dptfxtract` (Intel DPTF extractor) to pull the DPTF tables from ACPI for use with `thermald`.

6. **For OLED brightness in Hybrid mode**, add `i915.enable_dpcd_backlight=1` to GRUB (confirmed working on GU605MI/GU605MY by the ASUS Linux community).

7. **If S0ix suspend drains battery or wakes immediately**, check `/sys/firmware/acpi/interrupts/gpe*` for a firing GPE, then mask it. The most likely culprits on this laptop are `_Q76`/`_Q77` (charger) and `_Q3F`/`_QA8`/`_QD4` (thermal/NVPCF composite events).

8. **Keep the DSDT dump** (`dsdt_aml.bin`) and the **SSDN disassembly** (`SSDN_OptRf2_Opt2Tabl_00001000_00000000.dsl`) for future reference. If you need to write a custom ACPI override or report a bug to `asus-linux`, these are the first files maintainers will ask for.

---

## 7. File Checksum Reference

For reproducibility, here are the SHA-256 hashes of the key hardware-dump files in this repo:

| File | SHA-256 |
|------|---------|
| `dsdt_aml.bin` | `7d9c42de9bc5f2021daa5098d378494d1910b590b2bd39a1178f7e7b3054f890` |
| `GU605MY_BAPowerScheme.pwcfg` | `4223cd3eabe7dc198994bcb6e16acfec0d1a611e419fda9cd6ab2b0e410706db` |
| `GU605MY_HPPowerScheme.pwcfg` | `bb60750a32242d73f46de661996259832ad5ddc004d1c760efb48d3eb6daeae1` |
| `GU605MY_PSPowerScheme.pwcfg` | `57b7aa410c7d5c0b3e0dc6769a758c0c3ec59284e2d8b3ca836a4e6e6f277a15` |
| `AC_Config.FanAcoustic.GU605MY.cfg` | `747c8c06cffb1610eaef5887a9ae66689d329968aac923281e1372c1d427bb4d` |
| `AC_Config.PowerMode.GU605MY.enc` | `79fb05d79907a7f16d1428e939362c984d7beaf3c4f5d58015abb60355a2f113` |
| `AC_Config.TGP.GU605MY.enc` | `35caa670918502d96897cfd7357d9bbd1f747cf31173cdbee7f1df3ec50e70d3` |
| `AC_Config.VgaOc.GU605MY.enc` | `2174664d610b1ab1dfa9051fe684692d879b0681b516b9c7f74e63ca2845f081` |
| `ThrottleGear_GU605MY.xml` | `7457fffc07360c4216df2a1fd43c317b65fb20560e3e74a6b0535b2f73888d71` |
| `SSDN_OptRf2_Opt2Tabl_00001000_00000000.bin` | `230c90fbad3b04ebb9bd758c0ee224a483d720249637530dc28b75ca0627b03c` |

All 27 ACPI table dumps are in `acpi_tables/` with their own SHA-256 values (see Section 2.7).
