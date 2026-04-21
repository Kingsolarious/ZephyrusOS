# GU605MY Linux Support Project — Master Index & Transfer Manifest

**Project:** ASUS ROG Zephyrus G16 GU605MY Linux Reverse Engineering  
**Date:** 2026-04-16  
**Status:** Phase 1 Complete — 4 of 5 missing hardware categories resolved via static analysis.

---

## Quick Summary

This directory contains the complete artifact set from a deep reverse-engineering effort to extract Linux-compatible hardware data from a Windows 11 installation on the ASUS ROG Zephyrus G16 GU605MY.

**What was accomplished:**
- Dumped and analyzed the full DSDT + 27 SSDT ACPI tables
- Disassembled the hidden `SSDN` table containing the NVIDIA NVPCF `_DSM`
- Decoded GPU TGP power limits, fan curve index buffers, and DPTF participants
- Mapped all 44 `_Qxx` EC query methods and sleep/wake ACPI structures
- Analyzed encryption on Armoury Crate configs and determined static extraction is infeasible
- Created a ready-to-run Linux setup script for CachyOS/Arch

**What remains blocked:**
- Exact PWM duty-cycle percentages (locked in EC firmware or encrypted config)
- Decryption of Armoury Crate XML/enc files (key is runtime-derived via DPAPI)
- Live confirmation of S0ix wake sources (requires Linux runtime trace)

---

## 1. Primary Documentation (Start Here)

These Markdown files are the human-readable deliverables. Transfer all of them to the master project wiki/docs.

| File | Purpose | Audience | Priority |
|------|---------|----------|----------|
| `GU605MY_Linux_Hardware_Debug_and_Fan_Profiles.md` | **The canonical reference.** Hardware IDs, DSDT findings, NVPCF decode, DPTF participants, fan specs, performance profiles, `_Qxx` map, checksums. | Linux users, `asus-linux` maintainers, distro packagers | **CRITICAL** |
| `GU605MY_Missing_Data_Master_Analysis.md` | Deep-dive into the 5 missing categories. What was found, what is blocked, and why. | Developers writing custom kernel modules or ACPI overrides | **CRITICAL** |
| `GU605MY_Reverse_Engineering_Writeup.md` | Narrative of the methodology, tools, dead-ends, and breakthroughs. | Future reverse-engineers, technical writers | HIGH |
| `Linux_Gaming_Performance_Optimization_Guide.md` | End-user tuning guide for CachyOS. Kernel params, `asusctl`, `nvidia-smi` wrappers, per-game scripts. | End users installing Linux on this laptop | HIGH |
| `ASUS_GU605MY_Keyboard_Lighting_Keybind_Analysis.md` | Pre-existing analysis of keyboard RGB mappings and WMI keybinds. | `asusctl` / `rog-control-center` devs | MEDIUM |
| `ASUS_GU605MY_LED_Mapping_Capture.md` | Pre-existing LED mapping documentation. | Firmware/LED developers | MEDIUM |
| `Audio_Dropout_Diagnosis_Report.md` | Pre-existing audio issue diagnosis. | Audio driver developers | LOW |

---

## 2. Executable Artifacts & Scripts

Transfer these to the master project's `scripts/` or `tools/` directory.

| File | Purpose | Platform | Notes |
|------|---------|----------|-------|
| `setup_gu605my.sh` | One-shot Linux setup script. Installs ASUS Linux stack, enables services, sets max fan curves, creates NVIDIA/RAPL systemd services, and creates per-game GPU power wrappers. | Linux (CachyOS/Arch) | Syntax-validated but not executed. Review kernel params before running. |
| `apply_audio_fixes.ps1` | Pre-existing Windows PowerShell script for audio fixes. | Windows | Keep for reference if dual-booting. |
| `elevate_and_run.ps1` | Pre-existing Windows elevation helper. | Windows | Utility script. |
| `validate_script.py` | Python heredoc validator used to check `setup_gu605my.sh` syntax. | Any | Optional; can be discarded. |

---

## 3. Analysis Scripts (Methodology Artifacts)

These Python scripts generated the raw analysis text files. Transfer them to the master project's `tools/analysis/` directory for reproducibility.

| File | Purpose | Generated Output |
|------|---------|------------------|
| `analyze_npcf.py` | Scans DSDT AML for `NPCF` references, method bodies, power-limit constants, and `FMTG` mappings. | `npcf_gpu_power_analysis.txt` |
| `parse_dptf_aml.py` | Heuristic parser for DPTF SSDTs. Extracts strings, UUIDs, thermal names, packages, and temperature-like integers. | `dptf_analysis.txt` |
| `parse_dptf_aml_enhanced.py` | Extended version of the DPTF parser with additional name detection. | (intermediate) |

---

## 4. Raw Analysis Outputs

These are the machine-generated reports from the scripts above. They are large but valuable for traceability. Transfer to `analysis/raw/`.

| File | Size | Contents |
|------|------|----------|
| `npcf_gpu_power_analysis.txt` | ~24 KB | Full `NPCF` AML scan from DSDT: offsets, method bodies (`STPL`, `SFMN`, `SPAB`, `CPUP`), `FMTG` decode, power-limit constant search results. |
| `dptf_analysis.txt` | ~100 KB | Heuristic parse of SSD9, SSDA, and DSDT. Strings, UUIDs, thermal names, package sizes, deci-K temperatures, ACPI name segments. |

---

## 5. Hardware Dumps & Source Artifacts

These are the original binary artifacts extracted from the Windows host. They are **irreplaceable source material**. Transfer all of them to `hardware_dumps/`.

### ACPI Tables

| File | Size | Description |
|------|------|-------------|
| `dsdt_aml.bin` | 434.5 KB | Main DSDT dumped from registry |
| `dsdt_aml.dsl` | 2,928.5 KB | Disassembled DSDT (IASL output) |
| `acpi_tables/*.bin` | ~200 KB total | 27 SSDT/FADT/RSDT tables |
| `acpi_tables/SSDN_OptRf2_Opt2Tabl_00001000_00000000.dsl` | 92.7 KB | **Critical disassembly** — contains full `NPCF` device definition and NVPCF `_DSM` |

### Windows Registry / Config Artifacts

| File | Size | Description |
|------|------|-------------|
| `GU605MY_BAPowerScheme.pwcfg` | 20 KB | Performance profile registry hive |
| `GU605MY_HPPowerScheme.pwcfg` | 20 KB | Turbo profile registry hive |
| `GU605MY_PSPowerScheme.pwcfg` | 12 KB | Silent profile registry hive |
| `GU605MY_export_BA.pwcfg` | 0 KB | Export artifact (empty?) |
| `GU605MY_export_HP.pwcfg` | 0 KB | Export artifact (empty?) |
| `GU605MY_export_PP.pwcfg` | 0 KB | Export artifact (empty?) |
| `InitialSetting.ini` | 0.1 KB | Armoury Crate initial settings |
| `ConfigInstaller.xml` | 0.1 KB | Armoury Crate installer config |

### Encrypted Armoury Crate Configs

| File | Size | Status |
|------|------|--------|
| `AC_Config.FanAcoustic.GU605MY.cfg` | 1.9 KB | AES-encrypted; key not extractable statically |
| `AC_Config.PowerMode.GU605MY.enc` | 1.2 KB | AES-encrypted |
| `AC_Config.TGP.GU605MY.enc` | 0.5 KB | AES-encrypted |
| `AC_Config.VgaOc.GU605MY.enc` | 8.2 KB | AES-encrypted |
| `ThrottleGear_GU605MY.xml` | 18.1 KB | .NET `EncryptedXml` wrapper |

### Diagnostic Dumps

| File | Size | Description |
|------|------|-------------|
| `dxdiag.txt` | 172.5 KB | Windows DirectX diagnostic dump |
| `config_dump.txt` | 20 KB | Generic config dump |

### External Tools Used

| File | Size | Description |
|------|------|-------------|
| `iasl.exe` | 1,011.5 KB | Intel ACPI Source Language compiler/disassembler (used to decompile SSDN/DSDT) |
| `LatencyMon.exe` | 3,396.8 KB | Audio latency monitor (pre-existing) |

---

## 6. Recommended Directory Structure for Master Project

When transferring these files to the master project repository, organize them as follows:

```
GU605MY-Linux-Support/
├── docs/
│   ├── GU605MY_Linux_Hardware_Debug_and_Fan_Profiles.md   (canonical ref)
│   ├── GU605MY_Missing_Data_Master_Analysis.md            (deep-dive)
│   ├── GU605MY_Reverse_Engineering_Writeup.md             (methodology)
│   ├── Linux_Gaming_Performance_Optimization_Guide.md     (user guide)
│   ├── ASUS_GU605MY_Keyboard_Lighting_Keybind_Analysis.md
│   ├── ASUS_GU605MY_LED_Mapping_Capture.md
│   └── Audio_Dropout_Diagnosis_Report.md
├── scripts/
│   ├── setup_gu605my.sh
│   ├── apply_audio_fixes.ps1
│   └── elevate_and_run.ps1
├── tools/
│   ├── analyze_npcf.py
│   ├── parse_dptf_aml.py
│   ├── parse_dptf_aml_enhanced.py
│   └── validate_script.py
├── analysis/
│   ├── npcf_gpu_power_analysis.txt
│   └── dptf_analysis.txt
├── hardware_dumps/
│   ├── dsdt_aml.bin
│   ├── dsdt_aml.dsl
│   ├── acpi_tables/
│   │   ├── SSDN_OptRf2_Opt2Tabl_00001000_00000000.dsl   <-- CRITICAL
│   │   └── *.bin
│   ├── windows_registry/
│   │   ├── *.pwcfg
│   │   ├── InitialSetting.ini
│   │   └── ConfigInstaller.xml
│   ├── encrypted_configs/
│   │   ├── AC_Config.*
│   │   └── ThrottleGear_GU605MY.xml
│   └── diagnostics/
│       ├── dxdiag.txt
│       └── config_dump.txt
└── README.md
```

---

## 7. Key Findings Summary for README.md

Use this blurb as the project summary:

> This repository contains the most complete public hardware analysis of the ASUS ROG Zephyrus G16 GU605MY for Linux support. Through static reverse-engineering of 27 ACPI tables from Windows, we recovered the hidden NVIDIA NVPCF `_DSM` (GPU TGP control), DPTF thermal participant tables, fan curve index buffers, and a full map of 44 EC query methods. We also determined that Armoury Crate's encrypted thermal configs use a runtime-derived AES-256-CBC key (not statically extractable), and that the EC firmware itself holds the final PWM duty tables. A ready-to-run CachyOS setup script is included.

---

## 8. Checklist for Transfer

- [ ] Copy all `.md` files under `docs/`
- [ ] Copy `setup_gu605my.sh` under `scripts/`
- [ ] Copy `acpi_tables/` and `dsdt_aml.bin` under `hardware_dumps/`
- [ ] Copy `SSDN_OptRf2_Opt2Tabl_00001000_00000000.dsl` (ensure it is preserved)
- [ ] Copy `npcf_gpu_power_analysis.txt` and `dptf_analysis.txt` under `analysis/`
- [ ] Copy Python analysis scripts under `tools/`
- [ ] Preserve encrypted configs in `hardware_dumps/encrypted_configs/` for future runtime debugging
- [ ] Write top-level `README.md` summarizing findings and linking to the 3 critical docs
- [ ] (Optional) Generate SHA-256 manifest for all binary artifacts to ensure integrity

---

## 9. Contacts & Attribution

This work was performed by analyzing the Windows 11 host of an ASUS ROG Zephyrus G16 GU605MY (Intel Core Ultra 9 185H, RTX 4090 Laptop). All findings are derived from static analysis of registry hives, ACPI AML, and .NET assembly metadata.
