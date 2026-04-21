#!/usr/bin/env python3
"""
Enhanced heuristic ACPI AML parser for DPTF tables.
Better cross-referencing of temperatures with names and methods.
"""

import struct
import os
from pathlib import Path

TEMP_MIN = 2900
TEMP_MAX = 4600

KNOWN_THERMAL_NAMES = [
    b'_AC0', b'_AC1', b'_AC2', b'_AC3', b'_AC4', b'_AC5', b'_AC6', b'_AC7', b'_AC8', b'_AC9',
    b'_AL0', b'_AL1', b'_AL2', b'_AL3', b'_AL4', b'_AL5', b'_AL6', b'_AL7', b'_AL8', b'_AL9',
    b'_CRT', b'_HOT', b'_PSV', b'_SCP', b'_TC1', b'_TC2', b'_TSP', b'_TZP', b'_TMP', b'_STR',
    b'_DSM', b'_STA', b'_INI', b'_OFF', b'_ON_', b'_REG',
    b'IETM', b'DPTF', b'TCPU', b'TPCH', b'TPWR', b'CHRG', b'DPLY',
    b'SEN1', b'SEN2', b'SEN3', b'SEN4', b'SEN5', b'TFN1', b'TFN2', b'TFN3',
    b'ART0', b'ART1', b'PTRT', b'PSVT', b'PTYP', b'PWRE', b'PLDT',
]


def read_file(path):
    with open(path, 'rb') as f:
        return f.read()


def parse_acpi_header(data):
    if len(data) < 36:
        return {}
    return {
        'signature': data[0:4].decode('ascii', errors='replace'),
        'length': struct.unpack('<I', data[4:8])[0],
        'revision': data[8],
        'oemid': data[10:16].decode('ascii', errors='replace').strip(),
        'oem_table_id': data[16:24].decode('ascii', errors='replace').strip(),
    }


def extract_strings(data):
    strings = []
    i = 0
    while i < len(data):
        if data[i] == 0x0D:
            start = i + 1
            end = data.find(b'\x00', start)
            if end == -1:
                break
            s = data[start:end]
            if 1 <= len(s) <= 128 and all(32 <= b <= 126 or b in (9, 10, 13) for b in s):
                strings.append((i, s.decode('ascii', errors='replace')))
            i = end + 1
        else:
            i += 1
    return strings


def read_pkg_length(data, idx):
    """Read ACPI PkgLength from data at idx. Returns (length, next_idx)."""
    if idx >= len(data):
        return 0, idx
    lead = data[idx]
    extra = (lead >> 6) & 0x3
    if extra == 0:
        return lead & 0x3F, idx + 1
    elif extra == 1:
        if idx + 1 >= len(data):
            return 0, idx + 1
        return (lead & 0x0F) | (data[idx+1] << 4), idx + 2
    elif extra == 2:
        if idx + 2 >= len(data):
            return 0, idx + 2
        return (lead & 0x0F) | (data[idx+1] << 4) | (data[idx+2] << 12), idx + 3
    else:
        if idx + 3 >= len(data):
            return 0, idx + 3
        return (lead & 0x0F) | (data[idx+1] << 4) | (data[idx+2] << 12) | (data[idx+3] << 20), idx + 4


def read_term_arg_int(data, idx):
    """Try to read an integer term-arg at idx. Returns (value, bytes_consumed) or (None, 0)."""
    if idx >= len(data):
        return None, 0
    op = data[idx]
    if op == 0x00:
        return 0, 1
    if op == 0x01:
        return 1, 1
    if op == 0xFF:
        return 0xFFFFFFFF, 1
    if op == 0x0A and idx + 1 < len(data):
        return data[idx+1], 2
    if op == 0x0B and idx + 2 < len(data):
        return struct.unpack('<H', data[idx+1:idx+3])[0], 3
    if op == 0x0C and idx + 4 < len(data):
        return struct.unpack('<I', data[idx+1:idx+5])[0], 5
    if op == 0x0E and idx + 8 < len(data):
        return struct.unpack('<Q', data[idx+1:idx+9])[0], 9
    return None, 0


def extract_name_op_values(data, names_list):
    """Find NameOp (0x08) assignments to known names and extract their immediate integer values."""
    results = []
    for name_bytes in names_list:
        if len(name_bytes) != 4:
            continue
        start = 0
        while True:
            idx = data.find(b'\x08' + name_bytes, start)
            if idx == -1:
                break
            val_idx = idx + 5
            val, consumed = read_term_arg_int(data, val_idx)
            if val is not None:
                results.append((name_bytes.decode('ascii'), idx, val, consumed))
            start = idx + 1
    return results


def extract_method_returns(data, names_list):
    """Find MethodOp definitions for known names and look for immediate integer returns inside."""
    results = []
    for name_bytes in names_list:
        if len(name_bytes) != 4:
            continue
        start = 0
        while True:
            idx = data.find(b'\x14' + name_bytes, start)
            if idx == -1:
                break
            # MethodOp = 0x14, then PkgLength, then NameSeg, then Flags
            pkg_len, after_pkg = read_pkg_length(data, idx + 1)
            method_end = idx + 1 + pkg_len
            body_start = after_pkg + 4  # skip NameSeg
            body_start += 1  # skip flags byte
            # Search body for ReturnOp (0xA4) followed by integer
            ret_idx = data.find(b'\xA4', body_start, method_end)
            if ret_idx != -1 and ret_idx + 1 < method_end:
                val, consumed = read_term_arg_int(data, ret_idx + 1)
                if val is not None:
                    results.append((name_bytes.decode('ascii'), idx, val))
            start = idx + 1
    return results


def extract_all_temp_ints(data):
    """Extract all integer constants and filter by temperature range."""
    ints = []
    i = 0
    while i < len(data):
        val, consumed = read_term_arg_int(data, i)
        if consumed > 0:
            if TEMP_MIN <= val <= TEMP_MAX:
                ints.append((i, val))
            i += consumed
        else:
            i += 1
    return ints


def find_uuids(data):
    """Find 16-byte UUIDs that are preceded by BufferOp or common UUID prefixes."""
    uuids = []
    # Scan for BufferOp 0x11 near which UUIDs often appear
    i = 0
    while i < len(data) - 20:
        # Look for BufferOp or direct 16-byte patterns
        if data[i] == 0x11:
            buf_len, after = read_pkg_length(data, i + 1)
            buf_end = i + 1 + buf_len
            # Search inside buffer for 16 bytes that look like a UUID
            j = after
            while j <= buf_end - 16:
                chunk = data[j:j+16]
                if chunk not in (b'\x00'*16, b'\xFF'*16) and len(set(chunk)) >= 8:
                    if not all(0x20 <= b <= 0x7E for b in chunk):
                        try:
                            g1 = struct.unpack('<I', chunk[0:4])[0]
                            g2 = struct.unpack('<H', chunk[4:6])[0]
                            g3 = struct.unpack('<H', chunk[6:8])[0]
                            g4 = chunk[8:16]
                            guid = f"{g1:08X}-{g2:04X}-{g3:04X}-{g4[0]:02X}{g4[1]:02X}-{g4[2]:02X}{g4[3]:02X}{g4[4]:02X}{g4[5]:02X}{g4[6]:02X}{g4[7]:02X}"
                            uuids.append((guid, j))
                            break
                        except Exception:
                            pass
                j += 1
        i += 1
    return uuids


def find_dsm_uuids(data):
    """Find UUIDs specifically associated with _DSM methods."""
    uuids = []
    i = 0
    while i < len(data) - 4:
        if data[i:i+4] == b'_DSM':
            # Look backward up to 300 bytes for a Buffer/UUID
            search_start = max(0, i - 300)
            segment = data[search_start:i]
            # Find BufferOp
            buf_idx = segment.rfind(b'\x11')
            if buf_idx != -1:
                abs_buf = search_start + buf_idx
                buf_len, after = read_pkg_length(data, abs_buf + 1)
                buf_end = abs_buf + 1 + buf_len
                j = after
                if j <= buf_end - 16:
                    chunk = data[j:j+16]
                    if chunk not in (b'\x00'*16, b'\xFF'*16) and len(set(chunk)) >= 8:
                        try:
                            g1 = struct.unpack('<I', chunk[0:4])[0]
                            g2 = struct.unpack('<H', chunk[4:6])[0]
                            g3 = struct.unpack('<H', chunk[6:8])[0]
                            g4 = chunk[8:16]
                            guid = f"{g1:08X}-{g2:04X}-{g3:04X}-{g4[0]:02X}{g4[1]:02X}-{g4[2]:02X}{g4[3]:02X}{g4[4]:02X}{g4[5]:02X}{g4[6]:02X}{g4[7]:02X}"
                            uuids.append((guid, j))
                        except Exception:
                            pass
            start = i + 1
            i = data.find(b'_DSM', start)
            if i == -1:
                break
        else:
            i += 1
    return uuids


def analyze_file(path, out_lines):
    data = read_file(path)
    fname = os.path.basename(path)
    hdr = parse_acpi_header(data)

    out_lines.append(f"{'='*70}")
    out_lines.append(f"FILE: {fname}")
    out_lines.append(f"ACPI HEADER: {hdr}")
    out_lines.append(f"{'='*70}")

    # Strings
    strings = extract_strings(data[36:])
    out_lines.append(f"\n--- STRINGS ({len(strings)} found, showing all) ---")
    for off, s in strings:
        out_lines.append(f'  0x{off:04X}: "{s}"')

    # NameOp values for known names
    name_vals = extract_name_op_values(data, KNOWN_THERMAL_NAMES)
    if name_vals:
        out_lines.append(f"\n--- NAMEOP INTEGER ASSIGNMENTS ---")
        for name, off, val, consumed in name_vals:
            note = ""
            if TEMP_MIN <= val <= TEMP_MAX:
                note = f"  <-- TEMP ≈ {val/10 - 273.15:.1f}°C"
            out_lines.append(f"  Name({name}, {val}) @ 0x{off:04X}{note}")

    # Method return values
    method_rets = extract_method_returns(data, KNOWN_THERMAL_NAMES)
    if method_rets:
        out_lines.append(f"\n--- METHOD IMMEDIATE RETURN VALUES ---")
        for name, off, val in method_rets:
            note = ""
            if TEMP_MIN <= val <= TEMP_MAX:
                note = f"  <-- TEMP ≈ {val/10 - 273.15:.1f}°C"
            out_lines.append(f"  Method {name} returns {val} @ 0x{off:04X}{note}")

    # All temperature ints
    temp_ints = extract_all_temp_ints(data)
    out_lines.append(f"\n--- ALL TEMPERATURE-LIKE INTEGERS ({len(temp_ints)} found) ---")
    for off, val in temp_ints[:100]:
        out_lines.append(f"  0x{off:04X}: {val} deci-K ≈ {val/10 - 273.15:.1f}°C")

    # UUIDs near _DSM
    dsm_uuids = find_dsm_uuids(data)
    if dsm_uuids:
        out_lines.append(f"\n--- _DSM UUIDS ---")
        for guid, off in dsm_uuids:
            out_lines.append(f"  0x{off:04X}: {guid}")

    # All buffer UUIDs
    all_uuids = find_uuids(data)
    if all_uuids:
        out_lines.append(f"\n--- BUFFER UUIDS ---")
        seen = set()
        for guid, off in all_uuids:
            if guid not in seen:
                seen.add(guid)
                out_lines.append(f"  0x{off:04X}: {guid}")

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
    out_lines.append("DPTF ACPI AML Enhanced Heuristic Analysis")
    out_lines.append("=" * 70)
    out_lines.append("")

    for f in files:
        if f.exists():
            try:
                analyze_file(str(f), out_lines)
            except Exception as e:
                import traceback
                out_lines.append(f"ERROR analyzing {f.name}: {e}\n{traceback.format_exc()}")
        else:
            out_lines.append(f"MISSING: {f.name}")

    with open(out_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(out_lines))
    print(f"Saved enhanced analysis to {out_path}")


if __name__ == '__main__':
    main()
