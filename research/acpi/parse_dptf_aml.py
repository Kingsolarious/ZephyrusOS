#!/usr/bin/env python3
"""
Heuristic ACPI AML parser for DPTF tables.
Extracts names, strings, integers, UUIDs, and known thermal method references.
"""

import struct
import re
import os
import sys
from pathlib import Path

# Temperature range in deci-Kelvin
TEMP_MIN = 3000
TEMP_MAX = 4500

# Known DPTF/thermal related names to highlight
KNOWN_NAMES = {
    # Thermal methods
    b'_AC0', b'_AC1', b'_AC2', b'_AC3', b'_AC4', b'_AC5', b'_AC6', b'_AC7', b'_AC8', b'_AC9',
    b'_AL0', b'_AL1', b'_AL2', b'_AL3', b'_AL4', b'_AL5', b'_AL6', b'_AL7', b'_AL8', b'_AL9',
    b'_CRT', b'_HOT', b'_PSV', b'_SCP', b'_TC1', b'_TC2', b'_TSP', b'_TZP', b'_TMP', b'_STR',
    b'_DSM', b'_STA', b'_INI', b'_OFF', b'_ON_', b'_REG', b'_PRW', b'_PS0', b'_PS1', b'_PS2',
    b'_PS3', b'_S0D', b'_S1D', b'_S2D', b'_S3D', b'_S4D',
    # DPTF scopes/devices
    b'IETM', b'DPTF', b'TSR0', b'TSR1', b'TSR2', b'TSR3', b'TSR4', b'TSR5',
    b'TSR6', b'TSR7', b'TSR8', b'TSR9', b'TCPU', b'TSKN', b'TSAM', b'TS0 ', b'TS1 ',
    b'TB00', b'TB01', b'TB02', b'TB03', b'TB04', b'TB05', b'TB06', b'TB07',
    b'TB10', b'TB11', b'TB12', b'TB13', b'TB14', b'TB15', b'TB16', b'TB17',
    b'SPWR', b'FPWR', b'CPWR', b'POWR', b'PWR ', b'CHRG', b'BATT',
    b'DPS0', b'DPS1', b'DPS2', b'DPS3', b'DPS4', b'DPS5', b'DPS6', b'DPS7',
    b'DPS8', b'DPS9', b'DSPA', b'DPSB', b'DPSC', b'DPSD', b'DPSE', b'DPSF',
    b'SEN0', b'SEN1', b'SEN2', b'SEN3', b'SEN4', b'SEN5', b'SEN6', b'SEN7',
    b'SEN8', b'SEN9', b'SEN10', b'SEN11', b'SEN12', b'SEN13', b'SEN14', b'SEN15',
    b'CTYP', b'PTYP', b'LPMV', b'ARTG',
    # Common Intel DPTF UUIDs fragments (for confirmation)
}


def read_file(path):
    with open(path, 'rb') as f:
        return f.read()


def parse_acpi_header(data):
    if len(data) < 36:
        return {}
    sig = data[0:4].decode('ascii', errors='replace')
    length = struct.unpack('<I', data[4:8])[0]
    revision = data[8]
    checksum = data[9]
    oemid = data[10:16].decode('ascii', errors='replace').strip()
    oem_table_id = data[16:24].decode('ascii', errors='replace').strip()
    oem_revision = struct.unpack('<I', data[24:28])[0]
    creator_id = data[28:32].decode('ascii', errors='replace').strip()
    creator_rev = struct.unpack('<I', data[32:36])[0]
    return {
        'signature': sig,
        'length': length,
        'revision': revision,
        'checksum': checksum,
        'oemid': oemid,
        'oem_table_id': oem_table_id,
        'oem_revision': oem_revision,
        'creator_id': creator_id,
        'creator_rev': creator_rev,
    }


def is_name_char(b, first=False):
    if first:
        return (0x41 <= b <= 0x5A) or b == 0x5F  # A-Z or _
    return (0x41 <= b <= 0x5A) or (0x30 <= b <= 0x39) or b == 0x5F  # A-Z, 0-9, _


def extract_name_segs(data):
    """Extract potential 4-char ACPI NameSegs."""
    names = set()
    i = 0
    while i <= len(data) - 4:
        if is_name_char(data[i], first=True) and is_name_char(data[i+1]) and is_name_char(data[i+2]) and is_name_char(data[i+3]):
            name = bytes(data[i:i+4])
            # Filter out common false positives
            if name not in (b'ACPI', b'HPET', b'APIC', b'SRAT', b'SLIT', b'ASF!', b'UEFI', b'MCFG', b'RSDT', b'XSDT'):
                names.add(name.decode('ascii'))
            i += 4
        else:
            i += 1
    return sorted(names)


def extract_strings(data):
    """Extract AML StringPrefix (0x0D) strings."""
    strings = []
    i = 0
    while i < len(data):
        if data[i] == 0x0D:
            start = i + 1
            end = data.find(b'\x00', start)
            if end == -1:
                break
            s = data[start:end]
            # Sanity: printable, length 1-128
            if 1 <= len(s) <= 128 and all(32 <= b <= 126 or b in (9, 10, 13) for b in s):
                strings.append(s.decode('ascii', errors='replace'))
            i = end + 1
        else:
            i += 1
    return strings


def extract_integers(data):
    """Extract integer constants from AML."""
    ints = []
    i = 0
    while i < len(data):
        op = data[i]
        if op == 0x0A and i + 1 < len(data):  # BytePrefix
            val = data[i+1]
            ints.append(('byte', val, i))
            i += 2
        elif op == 0x0B and i + 2 < len(data):  # WordPrefix
            val = struct.unpack('<H', data[i+1:i+3])[0]
            ints.append(('word', val, i))
            i += 3
        elif op == 0x0C and i + 4 < len(data):  # DWordPrefix
            val = struct.unpack('<I', data[i+1:i+5])[0]
            ints.append(('dword', val, i))
            i += 5
        elif op == 0x0E and i + 8 < len(data):  # QWordPrefix
            val = struct.unpack('<Q', data[i+1:i+9])[0]
            ints.append(('qword', val, i))
            i += 9
        elif op == 0x00:  # ZeroOp
            ints.append(('zero', 0, i))
            i += 1
        elif op == 0x01:  # OneOp
            ints.append(('one', 1, i))
            i += 1
        elif op == 0xFF:  # OnesOp -> 0xFFFFFFFF
            ints.append(('ones', 0xFFFFFFFF, i))
            i += 1
        else:
            i += 1
    return ints


def extract_uuids(data):
    """Find 16-byte sequences that look like UUIDs near _DSM references."""
    uuids = []
    # _DSM in bytes
    dsm_bytes = b'_DSM'
    start = 0
    while True:
        idx = data.find(dsm_bytes, start)
        if idx == -1:
            break
        # Look for a 16-byte buffer/UUID in the vicinity (within 256 bytes before)
        search_start = max(0, idx - 256)
        segment = data[search_start:idx]
        # Look for UUID pattern: typically stored as 16 bytes in a Buffer
        # We'll scan for any 16-byte region that has reasonable entropy
        j = 0
        while j <= len(segment) - 16:
            candidate = segment[j:j+16]
            # UUIDs usually have specific byte patterns (version 4 or known Intel UUIDs)
            # Accept anything that doesn't have too many repeats and isn't all zeros/ones
            if candidate != b'\x00'*16 and candidate != b'\xFF'*16:
                # Check if it could be a GUID (first byte not 00, some variation)
                unique = len(set(candidate))
                if unique >= 8:
                    # Format as GUID string (ACPI typically stores UUIDs in mixed endian)
                    try:
                        g1 = struct.unpack('<I', candidate[0:4])[0]
                        g2 = struct.unpack('<H', candidate[4:6])[0]
                        g3 = struct.unpack('<H', candidate[6:8])[0]
                        g4 = candidate[8:16]
                        guid = f"{g1:08X}-{g2:04X}-{g3:04X}-{g4[0]:02X}{g4[1]:02X}-{g4[2]:02X}{g4[3]:02X}{g4[4]:02X}{g4[5]:02X}{g4[6]:02X}{g4[7]:02X}"
                        uuids.append((guid, idx))
                        break
                    except Exception:
                        pass
            j += 1
        start = idx + 1
    return uuids


def extract_known_names_context(data):
    """Find offsets of known thermal/DPTF names and their nearby integer values."""
    results = []
    for name_bytes in KNOWN_NAMES:
        if len(name_bytes) != 4:
            continue
        start = 0
        while True:
            idx = data.find(name_bytes, start)
            if idx == -1:
                break
            # Look for nearby integers within 64 bytes
            context_start = max(0, idx - 32)
            context_end = min(len(data), idx + 64)
            context = data[context_start:context_end]
            nearby_temps = []
            ints = extract_integers(context)
            for typ, val, off in ints:
                if TEMP_MIN <= val <= TEMP_MAX:
                    nearby_temps.append(val)
            results.append((name_bytes.decode('ascii'), idx, nearby_temps))
            start = idx + 1
    return results


def find_packages_near_names(data):
    """Find PackageOp (0x12) near known names to infer policy packages."""
    pkg_info = []
    for name_bytes in KNOWN_NAMES:
        if len(name_bytes) != 4:
            continue
        start = 0
        while True:
            idx = data.find(name_bytes, start)
            if idx == -1:
                break
            # Search forward for PackageOp within 128 bytes
            search_end = min(len(data), idx + 128)
            sub = data[idx:search_end]
            pkg_idx = sub.find(b'\x12')
            if pkg_idx != -1:
                abs_pkg = idx + pkg_idx
                # Try to read package element count
                if abs_pkg + 2 < len(data):
                    # PackageOp followed by PkgLength then NumElements
                    # PkgLength encoding: first byte, bits 7-6 = extra bytes count
                    plen_byte = data[abs_pkg + 1]
                    extra = (plen_byte >> 6) & 0x03
                    num_elements = data[abs_pkg + 2 + extra]
                    pkg_info.append((name_bytes.decode('ascii'), abs_pkg, num_elements))
            start = idx + 1
    return pkg_info


def find_all_uuids_raw(data):
    """Scan for any 16-byte sequences that decode to known-looking UUIDs."""
    uuids = []
    for i in range(len(data) - 16):
        chunk = data[i:i+16]
        # Skip all zeros / all ones
        if chunk == b'\x00'*16 or chunk == b'\xFF'*16:
            continue
        # UUIDs in ACPI are usually in a Buffer; look for BufferOp nearby
        # But let's just decode anything with decent byte variation
        if len(set(chunk)) >= 8:
            try:
                g1 = struct.unpack('<I', chunk[0:4])[0]
                g2 = struct.unpack('<H', chunk[4:6])[0]
                g3 = struct.unpack('<H', chunk[6:8])[0]
                g4 = chunk[8:16]
                guid = f"{g1:08X}-{g2:04X}-{g3:04X}-{g4[0]:02X}{g4[1]:02X}-{g4[2]:02X}{g4[3]:02X}{g4[4]:02X}{g4[5]:02X}{g4[6]:02X}{g4[7]:02X}"
                # Check if any nibble pattern suggests a real UUID
                # Accept if it doesn't look like ASCII
                if not all(0x20 <= b <= 0x7E for b in chunk):
                    uuids.append((guid, i))
            except Exception:
                pass
    return uuids


def analyze_file(path, out_lines):
    data = read_file(path)
    fname = os.path.basename(path)
    hdr = parse_acpi_header(data)

    out_lines.append(f"{'='*70}")
    out_lines.append(f"FILE: {fname}")
    out_lines.append(f"SIZE: {len(data)} bytes")
    out_lines.append(f"ACPI HEADER: {hdr}")
    out_lines.append(f"{'='*70}")

    # Strings
    strings = extract_strings(data[36:])  # skip header for strings
    out_lines.append(f"\n--- STRINGS ({len(strings)} found) ---")
    for s in strings:
        out_lines.append(f'  "{s}"')

    # UUIDs
    uuids = find_all_uuids_raw(data)
    out_lines.append(f"\n--- UUIDS ({len(uuids)} candidates) ---")
    for guid, off in uuids[:30]:
        out_lines.append(f"  offset 0x{off:04X}: {guid}")

    # UUIDs near _DSM specifically
    dsm_uuids = extract_uuids(data)
    if dsm_uuids:
        out_lines.append(f"\n--- UUIDS NEAR _DSM ({len(dsm_uuids)} found) ---")
        for guid, off in dsm_uuids:
            out_lines.append(f"  offset 0x{off:04X}: {guid}")

    # Known names with nearby temperatures
    known_ctx = extract_known_names_context(data)
    out_lines.append(f"\n--- KNOWN DPTF/THERMAL NAMES WITH NEARBY TEMPERATURES ---")
    seen_names = set()
    for name, off, temps in known_ctx:
        if name not in seen_names:
            seen_names.add(name)
            temp_str = ', '.join(str(t) for t in temps) if temps else 'none'
            out_lines.append(f"  {name} @ 0x{off:04X} -> temps: [{temp_str}]")

    # Packages near known names
    pkgs = find_packages_near_names(data)
    if pkgs:
        out_lines.append(f"\n--- PACKAGES NEAR KNOWN NAMES ---")
        for name, off, count in pkgs[:40]:
            out_lines.append(f"  {name} -> Package with ~{count} elements @ 0x{off:04X}")

    # All integers in temperature range
    all_ints = extract_integers(data)
    temp_ints = [(typ, val, off) for typ, val, off in all_ints if TEMP_MIN <= val <= TEMP_MAX]
    out_lines.append(f"\n--- ALL TEMPERATURE-LIKE INTEGERS ({len(temp_ints)} found) ---")
    for typ, val, off in temp_ints[:80]:
        out_lines.append(f"  0x{off:04X}: {typ} {val} (deci-K) ≈ {val/10 - 273.15:.1f}°C")

    # Name segments list
    names = extract_name_segs(data)
    out_lines.append(f"\n--- POTENTIAL ACPI NAME SEGMENTS ({len(names)} found) ---")
    out_lines.append("  " + ", ".join(names[:200]))
    out_lines.append("")


def main():
    base = Path(r'C:\Users\kings\Desktop\Optimization\acpi_tables')
    out_path = Path(r'C:\Users\kings\Desktop\Optimization\dptf_analysis.txt')
    files = [
        base / 'SSD9_DptfTb_DptfTabl_00001000_00000000.bin',
        base / 'SSDA_INTEL__PDatTabl_00001000_00000000.bin',
        base / 'DSDT__ASUS__Notebook_01072009_00000000.bin',
    ]

    out_lines = []
    out_lines.append("DPTF ACPI AML Heuristic Analysis")
    out_lines.append(f"Generated by parse_dptf_aml.py")
    out_lines.append("")

    for f in files:
        if f.exists():
            try:
                analyze_file(str(f), out_lines)
            except Exception as e:
                out_lines.append(f"ERROR analyzing {f.name}: {e}")
        else:
            out_lines.append(f"MISSING: {f.name}")

    with open(out_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(out_lines))
    print(f"Saved analysis to {out_path}")


if __name__ == '__main__':
    main()
