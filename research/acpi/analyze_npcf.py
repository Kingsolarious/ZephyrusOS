#!/usr/bin/env python3
"""
Analyze DSDT AML/DSL for NPCF GPU power control references.
Outputs findings to npcf_gpu_power_analysis.txt.
"""
import os
import re
import struct
import subprocess
import sys

WORKDIR = r"C:\Users\kings\Desktop\Optimization"
AML_PATH = os.path.join(WORKDIR, "dsdt_aml.bin")
DSL_PATH = os.path.join(WORKDIR, "dsdt_aml.dsl")
IASL_PATH = os.path.join(WORKDIR, "iasl.exe")
OUT_PATH = os.path.join(WORKDIR, "npcf_gpu_power_analysis.txt")

# ---------------------------------------------------------------------------
# Helper: ensure DSL exists
# ---------------------------------------------------------------------------
def ensure_dsl():
    if os.path.exists(DSL_PATH):
        return
    if os.path.exists(IASL_PATH) and os.path.exists(AML_PATH):
        subprocess.run([IASL_PATH, "-d", AML_PATH], cwd=WORKDIR, check=False)
    if not os.path.exists(DSL_PATH):
        raise FileNotFoundError("Cannot generate DSL; iasl or AML missing.")

# ---------------------------------------------------------------------------
# Helper: read files
# ---------------------------------------------------------------------------
def read_binary():
    with open(AML_PATH, "rb") as f:
        return f.read()

def read_dsl():
    with open(DSL_PATH, "r", encoding="utf-8", errors="ignore") as f:
        return f.read()

# ---------------------------------------------------------------------------
# Binary scanner: find ASCII name references in AML
# ---------------------------------------------------------------------------
def find_binary_refs(data, keyword, radius=128):
    refs = []
    start = 0
    while True:
        idx = data.find(keyword.encode("ascii"), start)
        if idx == -1:
            break
        ctx = data[max(0, idx - radius): min(len(data), idx + len(keyword) + radius)]
        # represent as hex + ascii
        hex_part = " ".join(f"{b:02X}" for b in ctx)
        ascii_part = "".join(chr(b) if 32 <= b < 127 else "." for b in ctx)
        refs.append((idx, hex_part, ascii_part))
        start = idx + 1
    return refs

# ---------------------------------------------------------------------------
# DSL scanner: extract methods that reference a keyword
# ---------------------------------------------------------------------------
def extract_method_containing(dsl, keyword):
    """Return a list of (method_name, body) for methods containing keyword."""
    results = []
    pattern = re.compile(r'Method\s*\(\s*([A-Za-z0-9_]+)\s*,')
    for m in pattern.finditer(dsl):
        name = m.group(1)
        start = m.start()
        brace = 0
        i = start
        in_brace = False
        while i < len(dsl):
            if dsl[i] == '{':
                brace += 1
                in_brace = True
            elif dsl[i] == '}':
                brace -= 1
            i += 1
            if in_brace and brace == 0:
                break
        body = dsl[start:i]
        if keyword in body:
            results.append((name, body))
    return results

def extract_scope_block(dsl, scope_start_text):
    """Extract a top-level Scope/Method block starting with scope_start_text."""
    idx = dsl.find(scope_start_text)
    if idx == -1:
        return None
    brace = 0
    i = idx
    in_brace = False
    while i < len(dsl):
        if dsl[i] == '{':
            brace += 1
            in_brace = True
        elif dsl[i] == '}':
            brace -= 1
        i += 1
        if in_brace and brace == 0:
            break
    return dsl[idx:i]

# ---------------------------------------------------------------------------
# Main analysis
# ---------------------------------------------------------------------------
def main():
    ensure_dsl()
    data_bin = read_binary()
    dsl = read_dsl()

    lines = []
    lines.append("=" * 72)
    lines.append("NPCF GPU Power Analysis Report")
    lines.append("Generated from: " + AML_PATH)
    lines.append("Disassembly:    " + DSL_PATH)
    lines.append("=" * 72)
    lines.append("")

    # ------------------------------------------------------------------
    # 1. NPCF references in binary (raw AML)
    # ------------------------------------------------------------------
    lines.append("-" * 72)
    lines.append("1. RAW AML REFERENCES TO 'NPCF'")
    lines.append("-" * 72)
    npcf_bin_refs = find_binary_refs(data_bin, "NPCF", radius=96)
    lines.append(f"Total raw occurrences of 'NPCF' in AML: {len(npcf_bin_refs)}")
    for off, hex_part, ascii_part in npcf_bin_refs[:20]:
        lines.append(f"  Offset 0x{off:06X} : {ascii_part}")
    if len(npcf_bin_refs) > 20:
        lines.append(f"  ... ({len(npcf_bin_refs)-20} more omitted)")
    lines.append("")

    # ------------------------------------------------------------------
    # 2. NPCF references in DSL (grouped by method)
    # ------------------------------------------------------------------
    lines.append("-" * 72)
    lines.append("2. NPCF REFERENCES IN DISASSEMBLED DSL (by enclosing method)")
    lines.append("-" * 72)
    npcf_methods = extract_method_containing(dsl, "NPCF")
    lines.append(f"Methods in DSDT that reference NPCF: {len(npcf_methods)}")
    for name, body in npcf_methods:
        lines.append(f"\n--- Method {name} ---")
        # Print the body (trimmed if huge)
        if len(body) > 3000:
            lines.append(body[:1500])
            lines.append("\n... [truncated] ...\n")
            lines.append(body[-1500:])
        else:
            lines.append(body)
    lines.append("")

    # ------------------------------------------------------------------
    # 3. ATKD scope methods that call into NPCF
    # ------------------------------------------------------------------
    lines.append("-" * 72)
    lines.append("3. ATKD SCOPE / PROFILE SWITCH HANDLERS CALLING NPCF")
    lines.append("-" * 72)
    atkd_block = None
    # Find ATKD scope
    m = re.search(r'Scope\s*\(\s*_SB\.ATKD\s*\)', dsl)
    if m:
        start = m.start()
        brace = 0
        i = start
        in_brace = False
        while i < len(dsl):
            if dsl[i] == '{':
                brace += 1
                in_brace = True
            elif dsl[i] == '}':
                brace -= 1
            i += 1
            if in_brace and brace == 0:
                break
        atkd_block = dsl[start:i]
        # List methods inside ATKD that mention NPCF
        atkd_npcf = extract_method_containing(atkd_block, "NPCF")
        lines.append(f"ATKD scope size: {len(atkd_block)} chars")
        lines.append(f"ATKD methods referencing NPCF: {len(atkd_npcf)}")
        for name, body in atkd_npcf:
            lines.append(f"  -> {name}")
        # Show key handlers in detail
        key_handlers = ["SFMN", "STDM", "SPDM", "SSSM", "SMSM", "SPAB", "CPUP", "STPL", "WMSH", "DGPS"]
        for h in key_handlers:
            idx = atkd_block.find(f"Method ({h},")
            if idx != -1:
                # extract full method
                brace = 0
                i = idx
                in_b = False
                while i < len(atkd_block):
                    if atkd_block[i] == '{':
                        brace += 1
                        in_b = True
                    elif atkd_block[i] == '}':
                        brace -= 1
                    i += 1
                    if in_b and brace == 0:
                        break
                meth = atkd_block[idx:i]
                lines.append(f"\n<<< {h} >>>")
                lines.append(meth)
    else:
        lines.append("ATKD scope not found in DSDT.")
    lines.append("")

    # ------------------------------------------------------------------
    # 4. Power-limit integer constants
    # ------------------------------------------------------------------
    lines.append("-" * 72)
    lines.append("4. INTEGER CONSTANTS THAT LOOK LIKE GPU POWER LIMITS")
    lines.append("-" * 72)
    # Look for hex values that correspond to 90W,100W,115W,125W in mW
    target_hex = {
        0x15F90: "90 W (90000 mW)",
        0x186A0: "100 W (100000 mW)",
        0x1C138: "115 W (115000 mW)",
        0x1E848: "125 W (125000 mW)",
    }
    for val, desc in target_hex.items():
        hex_str = f"0x{val:05X}"
        # also match with leading zeros e.g. 0x0001C138
        hex_str8 = f"0x{val:08X}"
        if hex_str in dsl or hex_str8 in dsl:
            lines.append(f"FOUND {desc} -> hex {hex_str8}")
            # show context
            for m in re.finditer(re.escape(hex_str8), dsl):
                ctx = dsl[max(0, m.start()-120):m.end()+120]
                lines.append("  Context:")
                lines.append("    " + ctx.replace("\n", "\n    "))
                break
            # also try short form
            if hex_str != hex_str8:
                for m in re.finditer(re.escape(hex_str), dsl):
                    ctx = dsl[max(0, m.start()-120):m.end()+120]
                    lines.append("  Context (short):")
                    lines.append("    " + ctx.replace("\n", "\n    "))
                    break
        else:
            lines.append(f"NOT FOUND {desc} ({hex_str8})")
    # Also search for decimal watt values (90,100,115,125) near NPCF or power-related methods
    watt_vals = [90, 100, 115, 125]
    lines.append("\nDecimal watt constants near NPCF/power methods:")
    for w in watt_vals:
        pat = re.compile(r'\b0x[0]*' + f"{w:X}" + r'\b|\b' + str(w) + r'\b')
        hits = 0
        for m in pat.finditer(dsl):
            # only keep if within 500 chars of "NPCF" or "TPPL" or "AMAT" or "ACBT" or "ATPP"
            region = dsl[max(0, m.start()-300):m.end()+300]
            if any(k in region for k in ["NPCF", "TPPL", "AMAT", "ACBT", "ATPP", "DGPS", "FMTG"]):
                hits += 1
                if hits <= 3:
                    lines.append(f"  {w} (or 0x{w:X}) at offset {m.start()}: {m.group(0)}")
                    lines.append("    " + region.replace("\n", "\n    ")[:400])
        if hits == 0:
            lines.append(f"  No nearby hits for {w}")
    lines.append("")

    # ------------------------------------------------------------------
    # 5. FMTG package (GPU profile table)
    # ------------------------------------------------------------------
    lines.append("-" * 72)
    lines.append("5. GPU PROFILE TABLE (FMTG)")
    lines.append("-" * 72)
    fmtg_match = re.search(r'Name\s*\(\s*FMTG\s*,\s*Package\s*\([^)]+\)\s*\{[^}]+\}\s*\)', dsl, re.DOTALL)
    if fmtg_match:
        lines.append(fmtg_match.group(0))
        lines.append("\nInterpretation:")
        lines.append("  DGPS(Arg0) sets ^^^RP12.PXSX.TGPU = DerefOf(FMTG[Arg0])")
        lines.append("  FMTG indices map as follows (values in hex / decimal):")
        # extract numbers
        nums = re.findall(r'0x[0-9A-Fa-f]+|Zero|One', fmtg_match.group(0))
        for i, n in enumerate(nums):
            val = 0 if n == "Zero" else (1 if n == "One" else int(n, 16))
            lines.append(f"    Index {i}: {n} -> {val} decimal")
    else:
        lines.append("FMTG package not found.")
    lines.append("")

    # ------------------------------------------------------------------
    # 6. _DSM methods in NPCF
    # ------------------------------------------------------------------
    lines.append("-" * 72)
    lines.append("6. _DSM METHODS IN NPCF")
    lines.append("-" * 72)
    # Since NPCF device is not in DSDT, check if any _DSM is defined under a scope containing NPCF
    npcf_dsm = []
    for m in re.finditer(r'Method\s*\(_DSM', dsl):
        # find enclosing scope
        pre = dsl[:m.start()]
        scope_line = ""
        for line in reversed(pre.splitlines()):
            if line.strip().startswith("Scope (") or line.strip().startswith("Device ("):
                scope_line = line.strip()
                break
        if "NPCF" in scope_line:
            npcf_dsm.append(scope_line)
    if npcf_dsm:
        lines.append("Found _DSM under NPCF:")
        for s in npcf_dsm:
            lines.append("  " + s)
    else:
        lines.append("No _DSM methods defined under NPCF in this DSDT.")
        lines.append("(NPCF is only referenced via External declarations; its definition is likely in an SSDT.)")
    lines.append("")

    # ------------------------------------------------------------------
    # 7. GBD/CMB/GMB/PL1V/PL2V definitions and writes
    # ------------------------------------------------------------------
    lines.append("-" * 72)
    lines.append("7. POWER BUDGET TABLE FIELDS (GBD, CBD, CMB, GMB, PL1V, PL2V)")
    lines.append("-" * 72)
    # Locate the Field block containing these
    field_match = re.search(r'Field\s*\(\s*ERM2[^)]+\)[^\{]*\{', dsl)
    if field_match:
        start = field_match.start()
        brace = 0
        i = start
        in_brace = False
        while i < len(dsl):
            if dsl[i] == '{':
                brace += 1
                in_brace = True
            elif dsl[i] == '}':
                brace -= 1
            i += 1
            if in_brace and brace == 0:
                break
        field_block = dsl[start:i]
        lines.append("Field block found (ERM2) containing budget tables.")
        lines.append("Relevant fields extracted:")
        for line in field_block.splitlines():
            if any(k in line for k in ["PL1V", "PL2V", "GBD", "CBD", "CMB", "GMB"]):
                lines.append("  " + line.strip())
    else:
        lines.append("ERM2 Field block not found.")

    # Check for writes to these fields
    write_pattern = re.compile(r'\b([GCM]BD[0-9A-F]|[GCM]MB[0-9A-F])\s*=')
    writes = list(write_pattern.finditer(dsl))
    if writes:
        lines.append("\nDirect assignments found:")
        for w in writes:
            ctx = dsl[max(0, w.start()-100):w.end()+100]
            lines.append("  " + ctx.replace("\n", " "))
    else:
        lines.append("\nNo direct assignments to GBD/CMB/GMB/CBD fields found in DSDT.")
        lines.append("(They may be written by EC firmware or by methods in an SSDT.)")
    lines.append("")

    # ------------------------------------------------------------------
    # 8. NVidia / NVPCF / smi strings
    # ------------------------------------------------------------------
    lines.append("-" * 72)
    lines.append("8. NVIDIA/NVPCF/NVAPI STRINGS")
    lines.append("-" * 72)
    for term in ["NVPCF", "nvidia", "NVAPI"]:
        if term.lower() in dsl.lower():
            lines.append(f"'{term}' found in DSL (case-insensitive).")
        else:
            lines.append(f"'{term}' NOT found in DSL.")
    # 'smi' is generic; only report if it appears near NPCF
    smi_near_npcf = []
    for m in re.finditer(r'smi', dsl, re.IGNORECASE):
        region = dsl[max(0, m.start()-80):m.end()+80]
        if "NPCF" in region:
            smi_near_npcf.append(region.replace("\n", " "))
    if smi_near_npcf:
        lines.append("'smi' found near NPCF:")
        for s in smi_near_npcf[:5]:
            lines.append("  " + s)
    else:
        lines.append("'smi' not found near NPCF in DSL.")
    lines.append("")

    # ------------------------------------------------------------------
    # 9. FTBL profile mapping
    # ------------------------------------------------------------------
    lines.append("-" * 72)
    lines.append("9. FTBL PROFILE SWITCH LOGIC")
    lines.append("-" * 72)
    sfm = None
    for m in re.finditer(r'Method\s*\(\s*SFMN\s*,', dsl):
        start = m.start()
        brace = 0
        i = start
        in_b = False
        while i < len(dsl):
            if dsl[i] == '{':
                brace += 1
                in_b = True
            elif dsl[i] == '}':
                brace -= 1
            i += 1
            if in_b and brace == 0:
                break
        sfm = dsl[start:i]
        break
    if sfm:
        lines.append("SFMN method (profile switch handler):")
        lines.append(sfm)
    else:
        lines.append("SFMN not found.")

    stpl = None
    for m in re.finditer(r'Method\s*\(\s*STPL\s*,', dsl):
        start = m.start()
        brace = 0
        i = start
        in_b = False
        while i < len(dsl):
            if dsl[i] == '{':
                brace += 1
                in_b = True
            elif dsl[i] == '}':
                brace -= 1
            i += 1
            if in_b and brace == 0:
                break
        stpl = dsl[start:i]
        break
    if stpl:
        lines.append("\nSTPL method (GPU total power limit setter):")
        lines.append(stpl)
    lines.append("")

    # ------------------------------------------------------------------
    # 10. Summary / interpretation
    # ------------------------------------------------------------------
    lines.append("-" * 72)
    lines.append("10. SUMMARY – HOW GPU TGP IS CONTROLLED VIA ACPI (FROM DSDT)")
    lines.append("-" * 72)
    lines.append("""
Key observations from the DSDT:

1. NPCF device is NOT defined inside the DSDT; it is declared as External.
   The actual implementation (methods, _DSM, power-limit packages) lives in
   an SSDT that was not supplied. Therefore we can only see how the DSDT
   *calls* into NPCF, not how NPCF internally applies the limits.

2. The EC0 device exposes an OperationRegion ERM2 at SystemMemory
   0xFE108B00 (256 bytes). Inside ERM2 are fields that look like power-
   budget tables:
   - PL1V, PL2V (CPU power limits?)
   - CBD0-CBD7, GBD0-GBD7 ( possibly CPU/GPU budget tables )
   - CMB0-CMBF, GMB0-GMBF ( possibly combined/GPU memory budget tables )
   No DSDT methods write to these fields; writes likely come from the EC
   firmware or from the missing SSDT.

3. Profile-switch handlers inside ATKD / EC0 set NPCF registers before
   notifying NPCF with Notify(NPCF, 0xC0). The relevant DSDT methods are:
   - SFMN   : top-level switch on FTBL (0, 1, 2). Calls CPUP, STDM/SPDM/
              SSSM/SMSM, DGPS, WMSH, STPL, then Notifies NPCF twice.
   - STDM   : sets NPCF.AMAT=0xA0, NPCF.ACBT=0x78, NPCF.ATPP=0x0118
   - SPDM   : sets NPCF.AMAT=0x50, NPCF.ACBT=0x00, NPCF.ATPP=0xF0
   - SSSM   : sets NPCF.AMAT=0x50, NPCF.ACBT=0x00
   - SMSM   : sets NPCF.AMAT=0xA0, NPCF.ACBT=0xC8, NPCF.ATPP=0x0118
   - SPAB   : toggles NPCF.DBAC / NPCF.DBDC (enable/disable dynamic boost?)
   - CPUP   : copies Arg0 into NPCF.ATPP and NPCF.DTPP
   - STPL   : sets NPCF.TPPL = 0x0001C138 (115 000 decimal = 115 W) for
              FTBL == 0x02 and FTBL == Zero. No other FTBL cases are handled
              in the DSDT snippet.
   - DGPS   : maps profile index Arg0 -> FMTG[Arg0] and writes the value to
              ^^^RP12.PXSX.TGPU, then notifies the GPU device 0xC0.

4. FMTG package (size 4) contains:
      [0] = 0x00  -> likely default / unused
      [1] = 0x57  (87 dec)
      [2] = 0x4B  (75 dec)
      [3] = 0x57  (87 dec)
   These are passed to the dGPU (RP12.PXSX) as TGPU values. They are not
   raw watt figures, but they are profile-dependent GPU indices/limits.

5. The only literal TGP wattage found in the DSDT is 115 W (0x0001C138
   milliwatts) written to NPCF.TPPL. The other intermediate limits
   (90 W, 100 W, 125 W) do NOT appear in the DSDT; they are either:
      a) stored in the missing SSDT that defines NPCF, or
      b) applied by the NVIDIA driver (NVPCF) after reading tables from
         the SSDT.

6. No strings such as 'NVPCF', 'nvidia', or 'NVAPI' exist in the DSDT.
   There is no direct ACPI invocation of nvidia-smi. The communication
   path appears to be:
      ASUS ATKD/EC firmware -> writes NPCF fields -> Notify(NPCF, 0xC0)
      -> Windows ACPI driver -> NVIDIA GPU driver (via PCI/ACPI notify)
   The NVIDIA Platform Controller Framework (NPCF) device in the SSDT
   likely exposes a _DSM or custom method that the NVIDIA driver calls
   to retrieve the power-limit packages.

Conclusion:
The DSDT is the "orchestrator": it sets profile-dependent parameters in
NPCF and notifies it, but the actual power-limit tables and NVAPI bridging
are implemented in the SSDT that defines the NPCF device.
""")

    # Write report
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"Analysis written to {OUT_PATH}")

if __name__ == "__main__":
    main()
