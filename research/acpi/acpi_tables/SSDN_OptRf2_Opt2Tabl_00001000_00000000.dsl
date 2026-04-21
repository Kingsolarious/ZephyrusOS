/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260408 (32-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of acpi_tables/SSDN_OptRf2_Opt2Tabl_00001000_00000000.bin
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00003719 (14105)
 *     Revision         0x02
 *     Checksum         0xE0
 *     OEM ID           "OptRf2"
 *     OEM Table ID     "Opt2Tabl"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20210930 (539035952)
 */
DefinitionBlock ("", "SSDT", 2, "OptRf2", "Opt2Tabl", 0x00001000)
{
    External (_SB_.GGOV, MethodObj)    // 1 Arguments
    External (_SB_.PC00, DeviceObj)
    External (_SB_.PC00.GFX0, DeviceObj)
    External (_SB_.PC00.LPCB.EC0_.CTMP, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.ECOK, IntObj)
    External (_SB_.PC00.LPCB.EC0_.EDAD, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.FTBL, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.G40C, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.GBLD, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.MUT0, MutexObj)
    External (_SB_.PC00.LPCB.EC0_.NDF9, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.PIDS, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.PMXL, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.PROL, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.PWMD, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.SBLD, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.SDNT, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC0_.VRTT, UnknownObj)
    External (_SB_.PC00.RP12, DeviceObj)
    External (_SB_.PC00.RP12.CEDR, UnknownObj)
    External (_SB_.PC00.RP12.DGCX, IntObj)
    External (_SB_.PC00.RP12.DL23, MethodObj)    // 0 Arguments
    External (_SB_.PC00.RP12.L23D, MethodObj)    // 0 Arguments
    External (_SB_.PC00.RP12.LREN, UnknownObj)
    External (_SB_.PC00.RP12.POFF, MethodObj)    // 0 Arguments
    External (_SB_.PC00.RP12.PXP_._OFF, MethodObj)    // 0 Arguments
    External (_SB_.PC00.RP12.PXP_._ON_, MethodObj)    // 0 Arguments
    External (_SB_.PC00.RP12.PXSX, DeviceObj)
    External (_SB_.PC00.RP12.PXSX._ADR, DeviceObj)
    External (_SB_.PC00.RP12.PXSX._STA, IntObj)
    External (_SB_.PC00.RP12.TDGC, IntObj)
    External (_SB_.PC00.RP12.TGPC, IntObj)
    External (_SB_.PR00, DeviceObj)
    External (_SB_.PR01, ProcessorObj)
    External (_SB_.PR02, ProcessorObj)
    External (_SB_.PR03, ProcessorObj)
    External (_SB_.PR04, ProcessorObj)
    External (_SB_.PR05, ProcessorObj)
    External (_SB_.PR06, ProcessorObj)
    External (_SB_.PR07, ProcessorObj)
    External (_SB_.PR08, ProcessorObj)
    External (_SB_.PR09, ProcessorObj)
    External (_SB_.PR10, ProcessorObj)
    External (_SB_.PR11, ProcessorObj)
    External (_SB_.PR12, ProcessorObj)
    External (_SB_.PR13, ProcessorObj)
    External (_SB_.PR14, ProcessorObj)
    External (_SB_.PR15, ProcessorObj)
    External (_SB_.PR16, ProcessorObj)
    External (_SB_.PR17, ProcessorObj)
    External (_SB_.PR18, ProcessorObj)
    External (_SB_.PR19, ProcessorObj)
    External (_SB_.SGOV, MethodObj)    // 2 Arguments
    External (CHPV, UnknownObj)
    External (CUMA, IntObj)
    External (DID1, UnknownObj)
    External (DID2, UnknownObj)
    External (DID3, UnknownObj)
    External (DID4, UnknownObj)
    External (DID5, UnknownObj)
    External (DID6, UnknownObj)
    External (DID7, UnknownObj)
    External (DID8, UnknownObj)
    External (DPMF, UnknownObj)
    External (EBAS, UnknownObj)
    External (EID1, UnknownObj)
    External (GPCE, IntObj)
    External (GTPM, IntObj)
    External (HGFL, UnknownObj)
    External (HGMD, UnknownObj)
    External (HYSS, UnknownObj)
    External (IOBS, UnknownObj)
    External (NBFM, IntObj)
    External (NVAF, UnknownObj)
    External (NVGA, UnknownObj)
    External (NVHA, UnknownObj)
    External (NXD1, UnknownObj)
    External (NXD2, UnknownObj)
    External (NXD3, UnknownObj)
    External (NXD4, UnknownObj)
    External (NXD5, UnknownObj)
    External (NXD6, UnknownObj)
    External (NXD7, UnknownObj)
    External (NXD8, UnknownObj)
    External (OSYS, UnknownObj)
    External (SDMF, UnknownObj)
    External (SGGP, UnknownObj)
    External (SSMP, UnknownObj)
    External (TCNT, FieldUnitObj)
    External (TRSG, UnknownObj)
    External (TRSP, UnknownObj)
    External (UMFG, IntObj)
    External (WOSR, IntObj)
    External (XBAS, UnknownObj)

    Scope (\_SB.PC00)
    {
        Method (SGPO, 3, Serialized)
        {
            If ((Arg1 == Zero))
            {
                Arg2 = ~Arg2
                Arg2 &= One
            }

            If (CondRefOf (\_SB.SGOV))
            {
                \_SB.SGOV (Arg0, Arg2)
            }
        }

        Device (AWMI)
        {
            Name (_HID, "PNP0C14" /* Windows Management Instrumentation Device */)  // _HID: Hardware ID
            Name (_UID, "0x00")  // _UID: Unique ID
            Name (_WDG, Buffer (0x28)
            {
                /* 0000 */  0x13, 0x96, 0x3E, 0x60, 0x25, 0xEF, 0x38, 0x43,  // ..>`%.8C
                /* 0008 */  0xA3, 0xD0, 0xC4, 0x61, 0x77, 0x51, 0x6D, 0xB7,  // ...awQm.
                /* 0010 */  0x41, 0x41, 0x01, 0x02, 0x21, 0x12, 0x90, 0x05,  // AA..!...
                /* 0018 */  0x66, 0xD5, 0xD1, 0x11, 0xB2, 0xF0, 0x00, 0xA0,  // f.......
                /* 0020 */  0xC9, 0x06, 0x29, 0x10, 0x30, 0x30, 0x01, 0x00   // ..).00..
            })
            Method (WMAA, 3, Serialized)
            {
                CreateByteField (Arg2, Zero, MODF)
                CreateDWordField (Arg2, 0x04, LEDB)
                Switch (Arg1)
                {
                    Case (One)
                    {
                        If ((MODF == Zero))
                        {
                            LEDB = \_SB.PC00.LPCB.EC0.GBLD /* External reference */
                            Return (LEDB) /* \_SB_.PC00.AWMI.WMAA.LEDB */
                        }
                        ElseIf ((MODF == One))
                        {
                            \_SB.PC00.LPCB.EC0.SBLD = LEDB /* \_SB_.PC00.AWMI.WMAA.LEDB */
                            Return (Zero)
                        }
                        ElseIf ((MODF == 0x02))
                        {
                            Return (0xC8)
                        }
                        Else
                        {
                            Return (One)
                        }
                    }
                    Case (0x02)
                    {
                        If ((MODF == Zero))
                        {
                            If ((\_SB.PC00.LPCB.EC0.PIDS == One))
                            {
                                Return (0x03)
                            }
                            Else
                            {
                                Return (0x02)
                            }
                        }
                        ElseIf ((MODF == One))
                        {
                            If ((LEDB < 0x03))
                            {
                                Return (Zero)
                            }

                            Return (One)
                        }
                        Else
                        {
                            Return (One)
                        }
                    }
                    Default
                    {
                        Return (One)
                    }

                }
            }
        }
    }

    Scope (\_SB.PC00.RP12.PXSX)
    {
        Name (LTRE, Zero)
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If ((\CUMA == Zero))
            {
                Return (0x0F)
            }

            Return (Zero)
        }

        Method (_EJ0, 1, NotSerialized)  // _EJx: Eject Device, x=0-9
        {
            If ((GPCE == One))
            {
                \_SB.PC00.RP12.DL23 ()
                \_SB.PC00.RP12.POFF ()
                UMFG = One
                WOSR = Zero
                \_SB.PC00.RP12.PXSX._STA () = Zero
            }
        }

        Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
        {
            Return (Zero)
        }

        OperationRegion (MSID, SystemMemory, EBAS, 0x0500)
        Field (MSID, DWordAcc, Lock, Preserve)
        {
            VEID,   16, 
            Offset (0x40), 
            NVID,   32, 
            Offset (0x4C), 
            ATID,   32
        }

        OperationRegion (QMIP, SystemIO, 0xB2, One)
        Field (QMIP, ByteAcc, NoLock, Preserve)
        {
            QSMI,   8
        }

        Name (MMID, Package (0x02)
        {
            Package (0x03)
            {
                Zero, 
                "PI3WVR13612", 
                0x00030002
            }, 

            Package (0x03)
            {
                One, 
                "NON-MUX or Error", 
                Zero
            }
        })
        Method (_DOD, 0, NotSerialized)  // _DOD: Display Output Devices
        {
            Return (Package (0x01)
            {
                0x8000A450
            })
        }

        Device (LCD0)
        {
            Method (_ADR, 0, Serialized)  // _ADR: Address
            {
                Return (0x8000A450)
            }

            Method (_DDC, 1, Serialized)  // _DDC: Display Data Current
            {
                If (((Arg0 == One) || (Arg0 == 0x02)))
                {
                    OperationRegion (EDMB, SystemMemory, \_SB.PC00.LPCB.EC0.EDAD, 0x0100)
                    Field (EDMB, AnyAcc, NoLock, Preserve)
                    {
                        EDMD,   2048
                    }

                    Name (BUFF, Buffer (0x0100)
                    {
                         0x00                                             // .
                    })
                    BUFF = EDMD /* \_SB_.PC00.RP12.PXSX.LCD0._DDC.EDMD */
                    Return (BUFF) /* \_SB_.PC00.RP12.PXSX.LCD0._DDC.BUFF */
                }

                Return (Zero)
            }

            Method (MXDS, 1, NotSerialized)
            {
                Local0 = Arg0
                Local1 = (Local0 & 0x0F)
                Local2 = (Local0 & 0x10)
                If ((Local1 == Zero))
                {
                    If ((\_SB.PC00.LPCB.EC0.PMXL == Zero))
                    {
                        Return (One)
                    }
                    Else
                    {
                        Return (0x02)
                    }
                }
                ElseIf ((Local1 == One))
                {
                    If ((Local2 == 0x10))
                    {
                        \_SB.PC00.LPCB.EC0.PMXL = One
                        \_SB.PC00.LPCB.EC0.PWMD = Zero
                    }
                    Else
                    {
                        \_SB.PC00.LPCB.EC0.PMXL = Zero
                        \_SB.PC00.LPCB.EC0.PWMD = One
                    }

                    Return (One)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (MXDM, 1, NotSerialized)
            {
                Local0 = Arg0
                Local1 = (Local0 & 0x07)
                If ((Local1 == Zero))
                {
                    Local2 = DPMF /* External reference */
                    Return (Local2)
                }
                ElseIf ((Local1 < 0x05))
                {
                    SDMF = Local1
                    QSMI = 0xB8
                }
                Else
                {
                    Return (Zero)
                }

                Return (One)
            }

            Method (MXID, 1, NotSerialized)
            {
                If ((Arg0 == Zero))
                {
                    Local0 = DerefOf (DerefOf (MMID [Zero]) [0x02])
                    Return (Local0)
                }
            }

            Method (LRST, 1, NotSerialized)
            {
                Local0 = Arg0
                Local1 = (Local0 & 0x07)
                If ((Local1 == Zero))
                {
                    If ((\_SB.PC00.LPCB.EC0.PROL == Zero))
                    {
                        Return (One)
                    }
                    Else
                    {
                        Return (0x02)
                    }
                }
                ElseIf ((Local1 == One))
                {
                    \_SB.PC00.LPCB.EC0.PROL = Zero
                }
                ElseIf ((Local1 == 0x02))
                {
                    \_SB.PC00.LPCB.EC0.PROL = One
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }

    Scope (\_SB.PC00.RP12)
    {
        OperationRegion (RPCX, SystemMemory, ((\XBAS + 0x8000) + Zero), 0x1000)
        Field (RPCX, AnyAcc, NoLock, Preserve)
        {
            Offset (0x04), 
            CMDR,   8, 
            Offset (0x19), 
            PRBN,   8, 
            Offset (0x4A), 
            CEDR,   1, 
            Offset (0x50), 
            ASPM,   2, 
                ,   2, 
            LNKD,   1, 
            Offset (0x69), 
                ,   2, 
            LREN,   1, 
            Offset (0xA4), 
            D0ST,   2
        }

        Name (TDGC, Zero)
        Name (DGCX, Zero)
        Name (TGPC, Buffer (0x04)
        {
             0x00                                             // .
        })
        Device (HDAU)
        {
            Name (_ADR, One)  // _ADR: Address
            Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
            {
                Return (Zero)
            }
        }
    }

    Scope (\_SB.PC00.RP12.PXSX)
    {
        OperationRegion (PCI2, SystemMemory, EBAS, 0x0500)
        Field (PCI2, DWordAcc, Lock, Preserve)
        {
            Offset (0x04), 
            CMDR,   8, 
            VGAR,   2000, 
            Offset (0x48B), 
                ,   1, 
            NHDA,   1
        }

        Name (VGAB, Buffer (0xFA)
        {
             0x00                                             // .
        })
        Name (GPRF, Zero)
        OperationRegion (NVHM, SystemMemory, NVHA, 0x00030400)
        Field (NVHM, DWordAcc, NoLock, Preserve)
        {
            NVSG,   128, 
            NVSZ,   32, 
            NVVR,   32, 
            NVHO,   32, 
            RVBS,   32, 
            RBF1,   262144, 
            RBF2,   262144, 
            RBF3,   262144, 
            RBF4,   262144, 
            RBF5,   262144, 
            RBF6,   262144, 
            MXML,   32, 
            MXM3,   1600
        }

        Name (OPCE, 0x02)
        Name (DGPS, Zero)
        Method (SGST, 0, Serialized)
        {
            If ((HGMD & 0x0F))
            {
                If ((SGGP != One))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }

            If ((\_SB.PC00.RP12.PXSX.VEID != 0xFFFF))
            {
                Return (0x0F)
            }

            Return (Zero)
        }

        Name (_PSC, Zero)  // _PSC: Power State Current
        Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
        {
            _PSC = Zero
            If ((DGPS != Zero))
            {
                _ON ()
                DGPS = Zero
            }
        }

        Method (_PS1, 0, NotSerialized)  // _PS1: Power State 1
        {
            _PSC = One
        }

        Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
        {
            If ((OPCE == 0x03))
            {
                If ((DGPS == Zero))
                {
                    _OFF ()
                    DGPS = One
                }

                OPCE = 0x02
            }

            _PSC = 0x03
        }

        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
        {
            CreateByteField (Arg0, 0x03, GUID)
            Name (NBCI, Zero)
            Name (OPCI, Zero)
            Name (BUFF, Zero)
            If ((Arg0 == ToUUID ("d4a50b75-65c7-46f7-bfb7-41514cea0244") /* Unknown UUID */))
            {
                NBCI = One
            }

            If ((Arg0 == ToUUID ("a3132d01-8cda-49ba-a52e-bc9d46df6b81") /* Unknown UUID */))
            {
                Return (\_SB.PC00.RP12.PXSX.GPS (Arg0, Arg1, Arg2, Arg3))
            }

            If ((Arg0 == ToUUID ("cbeca351-067b-4924-9cbd-b46b00b86f34") /* Unknown UUID */))
            {
                Return (\_SB.PC00.RP12.PXSX.NVJT (Arg0, Arg1, Arg2, Arg3))
            }

            If ((Arg0 == ToUUID ("a486d8f8-0bda-471b-a72b-6042a6b5bee0") /* Unknown UUID */))
            {
                OPCI = One
            }

            If ((OPCI || NBCI))
            {
                If (OPCI)
                {
                    If ((Arg1 != 0x0100))
                    {
                        Return (0x80000002)
                    }
                }
                ElseIf ((Arg1 != 0x0102))
                {
                    Return (0x80000002)
                }

                If ((Arg2 == Zero))
                {
                    If (NBCI)
                    {
                        Return (Buffer (0x04)
                        {
                             0x01, 0x00, 0x11, 0x00                           // ....
                        })
                    }
                    ElseIf (OPCI)
                    {
                        Return (Buffer (0x04)
                        {
                             0x01, 0x00, 0x00, 0x0C                           // ....
                        })
                    }
                }

                If ((Arg2 == 0x10))
                {
                    CreateWordField (Arg3, 0x02, USRG)
                    OperationRegion (EDM2, SystemMemory, (\_SB.PC00.LPCB.EC0.EDAD + 0x08), 0x0100)
                    Field (EDM2, AnyAcc, NoLock, Preserve)
                    {
                        PDVD,   32
                    }

                    If ((USRG == 0x4452))
                    {
                        Debug = "Get DR key"
                        If ((PDVD == 0x0C19E509))
                        {
                            Return (Buffer (0xD7)
                            {
                                /* 0000 */  0x7E, 0x78, 0x9F, 0x8B, 0x09, 0x99, 0x0D, 0x16,  // ~x......
                                /* 0008 */  0x52, 0x44, 0xD7, 0x00, 0x00, 0x00, 0x00, 0x01,  // RD......
                                /* 0010 */  0x00, 0x00, 0x00, 0x00, 0xDE, 0x10, 0x00, 0x00,  // ........
                                /* 0018 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0020 */  0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x00,  // ......4.
                                /* 0028 */  0x00, 0x00, 0x01, 0x00, 0x47, 0x00, 0x00, 0x00,  // ....G...
                                /* 0030 */  0x02, 0x00, 0x45, 0x00, 0x00, 0x00, 0x03, 0x00,  // ..E.....
                                /* 0038 */  0x87, 0x00, 0x00, 0x00, 0x04, 0x00, 0x85, 0x00,  // ........
                                /* 0040 */  0x00, 0x00, 0x05, 0x00, 0x83, 0x00, 0x00, 0x00,  // ........
                                /* 0048 */  0x06, 0x00, 0x81, 0x00, 0x00, 0x00, 0x07, 0x00,  // ........
                                /* 0050 */  0x7F, 0x00, 0x00, 0x00, 0x08, 0x00, 0x7D, 0x00,  // ......}.
                                /* 0058 */  0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0xD9, 0x1C,  // ........
                                /* 0060 */  0x04, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00,  // ........
                                /* 0068 */  0x41, 0x5D, 0xC9, 0x00, 0x01, 0x24, 0x2E, 0x00,  // A]...$..
                                /* 0070 */  0x02, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x01,  // ........
                                /* 0078 */  0x00, 0x00, 0x00, 0xD9, 0x1C, 0x04, 0x00, 0x00,  // ........
                                /* 0080 */  0x00, 0x02, 0x00, 0x00, 0x00, 0xE0, 0x7C, 0x97,  // ......|.
                                /* 0088 */  0x01, 0xC4, 0xD5, 0xC4, 0x32, 0x00, 0x00, 0x00,  // ....2...
                                /* 0090 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x26, 0x00, 0x00,  // .....&..
                                /* 0098 */  0x00, 0x32, 0x00, 0x34, 0x00, 0x30, 0x00, 0x2A,  // .2.4.0.*
                                /* 00A0 */  0x00, 0x31, 0x00, 0x30, 0x00, 0x30, 0x00, 0x30,  // .1.0.0.0
                                /* 00A8 */  0x00, 0x30, 0x00, 0x3B, 0x00, 0x36, 0x00, 0x30,  // .0.;.6.0
                                /* 00B0 */  0x00, 0x2A, 0x00, 0x34, 0x00, 0x30, 0x00, 0x30,  // .*.4.0.0
                                /* 00B8 */  0x00, 0x30, 0x00, 0x30, 0x00, 0x00, 0x00, 0x00,  // .0.0....
                                /* 00C0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 00C8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 00D0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00         // .......
                            })
                        }

                        If ((PDVD == 0x158E104D))
                        {
                            Return (Buffer (0xD7)
                            {
                                /* 0000 */  0x7E, 0x78, 0x9F, 0x8B, 0x09, 0x99, 0x0D, 0x16,  // ~x......
                                /* 0008 */  0x52, 0x44, 0xD7, 0x00, 0x00, 0x00, 0x00, 0x01,  // RD......
                                /* 0010 */  0x00, 0x00, 0x00, 0x00, 0xDE, 0x10, 0x00, 0x00,  // ........
                                /* 0018 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0020 */  0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x00,  // ......4.
                                /* 0028 */  0x00, 0x00, 0x01, 0x00, 0x47, 0x00, 0x00, 0x00,  // ....G...
                                /* 0030 */  0x02, 0x00, 0x45, 0x00, 0x00, 0x00, 0x03, 0x00,  // ..E.....
                                /* 0038 */  0x87, 0x00, 0x00, 0x00, 0x04, 0x00, 0x85, 0x00,  // ........
                                /* 0040 */  0x00, 0x00, 0x05, 0x00, 0x83, 0x00, 0x00, 0x00,  // ........
                                /* 0048 */  0x06, 0x00, 0x81, 0x00, 0x00, 0x00, 0x07, 0x00,  // ........
                                /* 0050 */  0x7F, 0x00, 0x00, 0x00, 0x08, 0x00, 0x7D, 0x00,  // ......}.
                                /* 0058 */  0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0xD9, 0x1C,  // ........
                                /* 0060 */  0x04, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00,  // ........
                                /* 0068 */  0x41, 0x5D, 0xC9, 0x00, 0x01, 0x24, 0x2E, 0x00,  // A]...$..
                                /* 0070 */  0x02, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x01,  // ........
                                /* 0078 */  0x00, 0x00, 0x00, 0xD9, 0x1C, 0x04, 0x00, 0x00,  // ........
                                /* 0080 */  0x00, 0x02, 0x00, 0x00, 0x00, 0xE0, 0x7C, 0x97,  // ......|.
                                /* 0088 */  0x01, 0xC4, 0xD5, 0xC4, 0x32, 0x00, 0x00, 0x00,  // ....2...
                                /* 0090 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x26, 0x00, 0x00,  // .....&..
                                /* 0098 */  0x00, 0x32, 0x00, 0x34, 0x00, 0x30, 0x00, 0x2A,  // .2.4.0.*
                                /* 00A0 */  0x00, 0x31, 0x00, 0x30, 0x00, 0x30, 0x00, 0x30,  // .1.0.0.0
                                /* 00A8 */  0x00, 0x30, 0x00, 0x3B, 0x00, 0x36, 0x00, 0x30,  // .0.;.6.0
                                /* 00B0 */  0x00, 0x2A, 0x00, 0x34, 0x00, 0x30, 0x00, 0x30,  // .*.4.0.0
                                /* 00B8 */  0x00, 0x30, 0x00, 0x30, 0x00, 0x00, 0x00, 0x00,  // .0.0....
                                /* 00C0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 00C8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 00D0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00         // .......
                            })
                        }

                        If ((PDVD == 0x41A3834C))
                        {
                            Return (Buffer (0xD7)
                            {
                                /* 0000 */  0x7E, 0x78, 0x9F, 0x8B, 0x09, 0x99, 0x0D, 0x16,  // ~x......
                                /* 0008 */  0x52, 0x44, 0xD7, 0x00, 0x00, 0x00, 0x00, 0x01,  // RD......
                                /* 0010 */  0x00, 0x00, 0x00, 0x00, 0xDE, 0x10, 0x00, 0x00,  // ........
                                /* 0018 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0020 */  0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x00,  // ......4.
                                /* 0028 */  0x00, 0x00, 0x01, 0x00, 0x47, 0x00, 0x00, 0x00,  // ....G...
                                /* 0030 */  0x02, 0x00, 0x45, 0x00, 0x00, 0x00, 0x03, 0x00,  // ..E.....
                                /* 0038 */  0x87, 0x00, 0x00, 0x00, 0x04, 0x00, 0x85, 0x00,  // ........
                                /* 0040 */  0x00, 0x00, 0x05, 0x00, 0x83, 0x00, 0x00, 0x00,  // ........
                                /* 0048 */  0x06, 0x00, 0x81, 0x00, 0x00, 0x00, 0x07, 0x00,  // ........
                                /* 0050 */  0x7F, 0x00, 0x00, 0x00, 0x08, 0x00, 0x7D, 0x00,  // ......}.
                                /* 0058 */  0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0xD9, 0x1C,  // ........
                                /* 0060 */  0x04, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00,  // ........
                                /* 0068 */  0x41, 0x5D, 0xC9, 0x00, 0x01, 0x24, 0x2E, 0x00,  // A]...$..
                                /* 0070 */  0x02, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x01,  // ........
                                /* 0078 */  0x00, 0x00, 0x00, 0xD9, 0x1C, 0x04, 0x00, 0x00,  // ........
                                /* 0080 */  0x00, 0x02, 0x00, 0x00, 0x00, 0xE0, 0x7C, 0x97,  // ......|.
                                /* 0088 */  0x01, 0xC4, 0xD5, 0xC4, 0x32, 0x00, 0x00, 0x00,  // ....2...
                                /* 0090 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x26, 0x00, 0x00,  // .....&..
                                /* 0098 */  0x00, 0x32, 0x00, 0x34, 0x00, 0x30, 0x00, 0x2A,  // .2.4.0.*
                                /* 00A0 */  0x00, 0x31, 0x00, 0x30, 0x00, 0x30, 0x00, 0x30,  // .1.0.0.0
                                /* 00A8 */  0x00, 0x30, 0x00, 0x3B, 0x00, 0x36, 0x00, 0x30,  // .0.;.6.0
                                /* 00B0 */  0x00, 0x2A, 0x00, 0x34, 0x00, 0x30, 0x00, 0x30,  // .*.4.0.0
                                /* 00B8 */  0x00, 0x30, 0x00, 0x30, 0x00, 0x00, 0x00, 0x00,  // .0.0....
                                /* 00C0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 00C8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 00D0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00         // .......
                            })
                        }
                    }

                    If ((USRG == 0x564B))
                    {
                        Debug = "Get VK key"
                        If ((PDVD == 0x0C19E509))
                        {
                            Return (Buffer (0xC9)
                            {
                                /* 0000 */  0x4D, 0x61, 0x4A, 0x51, 0x60, 0x61, 0x36, 0xAC,  // MaJQ`a6.
                                /* 0008 */  0x4B, 0x56, 0xC9, 0x00, 0x00, 0x00, 0x01, 0x00,  // KV......
                                /* 0010 */  0x39, 0x31, 0x34, 0x35, 0x37, 0x32, 0x32, 0x32,  // 91457222
                                /* 0018 */  0x37, 0x37, 0x31, 0x36, 0x47, 0x65, 0x6E, 0x75,  // 7716Genu
                                /* 0020 */  0x69, 0x6E, 0x65, 0x20, 0x4E, 0x56, 0x49, 0x44,  // ine NVID
                                /* 0028 */  0x49, 0x41, 0x20, 0x43, 0x65, 0x72, 0x74, 0x69,  // IA Certi
                                /* 0030 */  0x66, 0x69, 0x65, 0x64, 0x20, 0x47, 0x53, 0x79,  // fied GSy
                                /* 0038 */  0x6E, 0x63, 0x20, 0x52, 0x65, 0x61, 0x64, 0x79,  // nc Ready
                                /* 0040 */  0x20, 0x50, 0x6C, 0x61, 0x74, 0x66, 0x6F, 0x72,  //  Platfor
                                /* 0048 */  0x6D, 0x20, 0x66, 0x6F, 0x72, 0x20, 0x49, 0x56,  // m for IV
                                /* 0050 */  0x4C, 0x45, 0x57, 0x49, 0x55, 0x53, 0x54, 0x4A,  // LEWIUSTJ
                                /* 0058 */  0x52, 0x47, 0x4D, 0x52, 0x47, 0x4F, 0x55, 0x4D,  // RGMRGOUM
                                /* 0060 */  0x41, 0x47, 0x20, 0x2D, 0x20, 0x3F, 0x3E, 0x20,  // AG - ?> 
                                /* 0068 */  0x57, 0x26, 0x58, 0x50, 0x45, 0x2D, 0x53, 0x31,  // W&XPE-S1
                                /* 0070 */  0x35, 0x54, 0x50, 0x38, 0x31, 0x2B, 0x4C, 0x57,  // 5TP81+LW
                                /* 0078 */  0x45, 0x4A, 0x5D, 0x5D, 0x5B, 0x40, 0x23, 0x34,  // EJ]][@#4
                                /* 0080 */  0x45, 0x20, 0x2D, 0x20, 0x43, 0x6F, 0x70, 0x79,  // E - Copy
                                /* 0088 */  0x72, 0x69, 0x67, 0x68, 0x74, 0x20, 0x32, 0x30,  // right 20
                                /* 0090 */  0x32, 0x33, 0x20, 0x4E, 0x56, 0x49, 0x44, 0x49,  // 23 NVIDI
                                /* 0098 */  0x41, 0x20, 0x43, 0x6F, 0x72, 0x70, 0x6F, 0x72,  // A Corpor
                                /* 00A0 */  0x61, 0x74, 0x69, 0x6F, 0x6E, 0x20, 0x41, 0x6C,  // ation Al
                                /* 00A8 */  0x6C, 0x20, 0x52, 0x69, 0x67, 0x68, 0x74, 0x73,  // l Rights
                                /* 00B0 */  0x20, 0x52, 0x65, 0x73, 0x65, 0x72, 0x76, 0x65,  //  Reserve
                                /* 00B8 */  0x64, 0x2D, 0x37, 0x32, 0x35, 0x31, 0x31, 0x35,  // d-725115
                                /* 00C0 */  0x36, 0x36, 0x31, 0x33, 0x33, 0x31, 0x28, 0x52,  // 661331(R
                                /* 00C8 */  0x29                                             // )
                            })
                        }

                        If ((PDVD == 0x158E104D))
                        {
                            Return (Buffer (0xC9)
                            {
                                /* 0000 */  0x12, 0x61, 0x29, 0xB8, 0x58, 0x6B, 0x46, 0x2A,  // .a).XkF*
                                /* 0008 */  0x4B, 0x56, 0xC9, 0x00, 0x00, 0x00, 0x01, 0x00,  // KV......
                                /* 0010 */  0x39, 0x31, 0x34, 0x35, 0x37, 0x32, 0x32, 0x32,  // 91457222
                                /* 0018 */  0x37, 0x37, 0x31, 0x36, 0x47, 0x65, 0x6E, 0x75,  // 7716Genu
                                /* 0020 */  0x69, 0x6E, 0x65, 0x20, 0x4E, 0x56, 0x49, 0x44,  // ine NVID
                                /* 0028 */  0x49, 0x41, 0x20, 0x43, 0x65, 0x72, 0x74, 0x69,  // IA Certi
                                /* 0030 */  0x66, 0x69, 0x65, 0x64, 0x20, 0x47, 0x53, 0x79,  // fied GSy
                                /* 0038 */  0x6E, 0x63, 0x20, 0x52, 0x65, 0x61, 0x64, 0x79,  // nc Ready
                                /* 0040 */  0x20, 0x50, 0x6C, 0x61, 0x74, 0x66, 0x6F, 0x72,  //  Platfor
                                /* 0048 */  0x6D, 0x20, 0x66, 0x6F, 0x72, 0x20, 0x44, 0x45,  // m for DE
                                /* 0050 */  0x52, 0x44, 0x51, 0x57, 0x56, 0x45, 0x51, 0x54,  // RDQWVEQT
                                /* 0058 */  0x55, 0x42, 0x42, 0x57, 0x47, 0x4F, 0x47, 0x58,  // UBBWGOGX
                                /* 0060 */  0x56, 0x59, 0x20, 0x2D, 0x20, 0x2A, 0x2C, 0x37,  // VY - *,7
                                /* 0068 */  0x27, 0x57, 0x35, 0x4D, 0x30, 0x40, 0x49, 0x28,  // 'W5M0@I(
                                /* 0070 */  0x2D, 0x32, 0x37, 0x53, 0x5D, 0x3D, 0x28, 0x33,  // -27S]=(3
                                /* 0078 */  0x59, 0x2D, 0x34, 0x28, 0x42, 0x2C, 0x34, 0x43,  // Y-4(B,4C
                                /* 0080 */  0x2F, 0x20, 0x2D, 0x20, 0x43, 0x6F, 0x70, 0x79,  // / - Copy
                                /* 0088 */  0x72, 0x69, 0x67, 0x68, 0x74, 0x20, 0x32, 0x30,  // right 20
                                /* 0090 */  0x32, 0x33, 0x20, 0x4E, 0x56, 0x49, 0x44, 0x49,  // 23 NVIDI
                                /* 0098 */  0x41, 0x20, 0x43, 0x6F, 0x72, 0x70, 0x6F, 0x72,  // A Corpor
                                /* 00A0 */  0x61, 0x74, 0x69, 0x6F, 0x6E, 0x20, 0x41, 0x6C,  // ation Al
                                /* 00A8 */  0x6C, 0x20, 0x52, 0x69, 0x67, 0x68, 0x74, 0x73,  // l Rights
                                /* 00B0 */  0x20, 0x52, 0x65, 0x73, 0x65, 0x72, 0x76, 0x65,  //  Reserve
                                /* 00B8 */  0x64, 0x2D, 0x37, 0x32, 0x35, 0x31, 0x31, 0x35,  // d-725115
                                /* 00C0 */  0x36, 0x36, 0x31, 0x33, 0x33, 0x31, 0x28, 0x52,  // 661331(R
                                /* 00C8 */  0x29                                             // )
                            })
                        }

                        If ((PDVD == 0x41A3834C))
                        {
                            Return (Buffer (0xC9)
                            {
                                /* 0000 */  0x19, 0xE4, 0x92, 0x4B, 0xA0, 0x28, 0x27, 0x34,  // ...K.('4
                                /* 0008 */  0x4B, 0x56, 0xC9, 0x00, 0x00, 0x00, 0x01, 0x00,  // KV......
                                /* 0010 */  0x39, 0x31, 0x34, 0x35, 0x37, 0x32, 0x32, 0x32,  // 91457222
                                /* 0018 */  0x37, 0x37, 0x31, 0x36, 0x47, 0x65, 0x6E, 0x75,  // 7716Genu
                                /* 0020 */  0x69, 0x6E, 0x65, 0x20, 0x4E, 0x56, 0x49, 0x44,  // ine NVID
                                /* 0028 */  0x49, 0x41, 0x20, 0x43, 0x65, 0x72, 0x74, 0x69,  // IA Certi
                                /* 0030 */  0x66, 0x69, 0x65, 0x64, 0x20, 0x47, 0x53, 0x79,  // fied GSy
                                /* 0038 */  0x6E, 0x63, 0x20, 0x52, 0x65, 0x61, 0x64, 0x79,  // nc Ready
                                /* 0040 */  0x20, 0x50, 0x6C, 0x61, 0x74, 0x66, 0x6F, 0x72,  //  Platfor
                                /* 0048 */  0x6D, 0x20, 0x66, 0x6F, 0x72, 0x20, 0x41, 0x42,  // m for AB
                                /* 0050 */  0x45, 0x42, 0x46, 0x4B, 0x54, 0x58, 0x55, 0x4C,  // EBFKTXUL
                                /* 0058 */  0x4D, 0x43, 0x4A, 0x4B, 0x41, 0x4C, 0x44, 0x43,  // MCJKALDC
                                /* 0060 */  0x4D, 0x53, 0x20, 0x2D, 0x20, 0x35, 0x3D, 0x28,  // MS - 5=(
                                /* 0068 */  0x26, 0x5C, 0x24, 0x27, 0x5F, 0x2A, 0x5B, 0x22,  // &\$'_*["
                                /* 0070 */  0x53, 0x38, 0x25, 0x4D, 0x30, 0x4E, 0x38, 0x36,  // S8%M0N86
                                /* 0078 */  0x23, 0x57, 0x21, 0x26, 0x55, 0x21, 0x53, 0x5B,  // #W!&U!S[
                                /* 0080 */  0x2E, 0x20, 0x2D, 0x20, 0x43, 0x6F, 0x70, 0x79,  // . - Copy
                                /* 0088 */  0x72, 0x69, 0x67, 0x68, 0x74, 0x20, 0x32, 0x30,  // right 20
                                /* 0090 */  0x32, 0x33, 0x20, 0x4E, 0x56, 0x49, 0x44, 0x49,  // 23 NVIDI
                                /* 0098 */  0x41, 0x20, 0x43, 0x6F, 0x72, 0x70, 0x6F, 0x72,  // A Corpor
                                /* 00A0 */  0x61, 0x74, 0x69, 0x6F, 0x6E, 0x20, 0x41, 0x6C,  // ation Al
                                /* 00A8 */  0x6C, 0x20, 0x52, 0x69, 0x67, 0x68, 0x74, 0x73,  // l Rights
                                /* 00B0 */  0x20, 0x52, 0x65, 0x73, 0x65, 0x72, 0x76, 0x65,  //  Reserve
                                /* 00B8 */  0x64, 0x2D, 0x37, 0x32, 0x35, 0x31, 0x31, 0x35,  // d-725115
                                /* 00C0 */  0x36, 0x36, 0x31, 0x33, 0x33, 0x31, 0x28, 0x52,  // 661331(R
                                /* 00C8 */  0x29                                             // )
                            })
                        }
                    }
                }

                If ((Arg2 == 0x14))
                {
                    Return (Package (0x20)
                    {
                        0x8000A450, 
                        0x0200, 
                        Zero, 
                        Zero, 
                        0x05, 
                        One, 
                        0x03E8, 
                        0x32, 
                        0x03E8, 
                        0x0B, 
                        0x32, 
                        0x64, 
                        0x96, 
                        0xC8, 
                        0x012C, 
                        0x0190, 
                        0x01FE, 
                        0x0276, 
                        0x02F8, 
                        0x0366, 
                        0x03E8, 
                        Zero, 
                        0x64, 
                        0xC8, 
                        0x012C, 
                        0x0190, 
                        0x01F4, 
                        0x0258, 
                        0x02BC, 
                        0x0320, 
                        0x0384, 
                        0x03E8
                    })
                }

                If ((Arg2 == 0x1A))
                {
                    CreateField (Arg3, 0x18, 0x02, OMPR)
                    CreateField (Arg3, Zero, One, FLCH)
                    CreateField (Arg3, One, One, DVSR)
                    CreateField (Arg3, 0x02, One, DVSC)
                    If (ToInteger (FLCH))
                    {
                        \_SB.PC00.RP12.PXSX.OPCE = OMPR /* \_SB_.PC00.RP12.PXSX._DSM.OMPR */
                    }

                    Local0 = Buffer (0x04)
                        {
                             0x00, 0x00, 0x00, 0x00                           // ....
                        }
                    CreateField (Local0, Zero, One, OPEN)
                    CreateField (Local0, 0x03, 0x02, CGCS)
                    CreateField (Local0, 0x06, One, SHPC)
                    CreateField (Local0, 0x08, One, SNSR)
                    CreateField (Local0, 0x18, 0x03, DGPC)
                    CreateField (Local0, 0x1B, 0x02, HDAC)
                    OPEN = One
                    SHPC = One
                    HDAC = 0x03
                    DGPC = One
                    If (ToInteger (DVSC))
                    {
                        If (ToInteger (DVSR))
                        {
                            \_SB.PC00.RP12.PXSX.GPRF = One
                        }
                        Else
                        {
                            \_SB.PC00.RP12.PXSX.GPRF = Zero
                        }
                    }

                    SNSR = \_SB.PC00.RP12.PXSX.GPRF
                    If ((\_SB.PC00.RP12.PXSX.SGST () != Zero))
                    {
                        CGCS = 0x03
                    }

                    Return (Local0)
                }

                If ((Arg2 == 0x1B))
                {
                    CreateField (Arg3, Zero, One, OACC)
                    CreateField (Arg3, One, One, UOAC)
                    CreateField (Arg3, 0x02, 0x08, OPDA)
                    CreateField (Arg3, 0x0A, One, OPDE)
                    Local1 = Zero
                    BUFF = Zero
                    If (ToInteger (UOAC))
                    {
                        If (ToInteger (OACC))
                        {
                            BUFF = One
                        }

                        HGFL = BUFF /* \_SB_.PC00.RP12.PXSX._DSM.BUFF */
                    }

                    Local1 = HGFL /* External reference */
                    Return (Local1)
                }

                Return (0x80000002)
            }

            Return (0x80000001)
        }

        Name (CTXT, Zero)
        Method (_ON, 0, Serialized)  // _ON_: Power On
        {
            If (CondRefOf (\_SB.PC00.RP12.PXP._ON))
            {
                \_SB.PC00.RP12.PXP._ON ()
            }

            If ((GPRF != One))
            {
                Local0 = CMDR /* \_SB_.PC00.RP12.PXSX.CMDR */
                CMDR = Zero
                VGAR = VGAB /* \_SB_.PC00.RP12.PXSX.VGAB */
                CMDR = 0x06
                CMDR = Local0
            }
        }

        Method (_OFF, 0, Serialized)  // _OFF: Power Off
        {
            If ((CTXT == Zero))
            {
                If ((GPRF != One))
                {
                    VGAB = VGAR /* \_SB_.PC00.RP12.PXSX.VGAR */
                }

                CTXT = One
            }

            If (CondRefOf (\_SB.PC00.RP12.PXP._OFF))
            {
                \_SB.PC00.RP12.PXP._OFF ()
            }
        }
    }

    Scope (\_SB.PC00.GFX0)
    {
        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            TLPK [Zero] = DID1 /* External reference */
            TLPK [0x02] = DID2 /* External reference */
            TLPK [0x04] = DID3 /* External reference */
            TLPK [0x06] = DID4 /* External reference */
            TLPK [0x08] = DID5 /* External reference */
            TLPK [0x0A] = DID6 /* External reference */
            TLPK [0x0C] = DID7 /* External reference */
            TLPK [0x0E] = DID2 /* External reference */
            TLPK [0x0F] = DID1 /* External reference */
            TLPK [0x11] = DID2 /* External reference */
            TLPK [0x12] = DID3 /* External reference */
            TLPK [0x14] = DID2 /* External reference */
            TLPK [0x15] = DID4 /* External reference */
            TLPK [0x17] = DID2 /* External reference */
            TLPK [0x18] = DID5 /* External reference */
            TLPK [0x1A] = DID2 /* External reference */
            TLPK [0x1B] = DID6 /* External reference */
            TLPK [0x1D] = DID2 /* External reference */
            TLPK [0x1E] = DID7 /* External reference */
        }

        OperationRegion (NVIG, SystemMemory, NVGA, 0x45)
        Field (NVIG, DWordAcc, NoLock, Preserve)
        {
            NISG,   128, 
            NISZ,   32, 
            NIVR,   32, 
            GPSS,   32, 
            GACD,   16, 
            GATD,   16, 
            LDES,   8, 
            DKST,   8, 
            DACE,   8, 
            DHPE,   8, 
            DHPS,   8, 
            SGNC,   8, 
            GPPO,   8, 
            USPM,   8, 
            GPSP,   8, 
            TLSN,   8, 
            DOSF,   8, 
            ELCL,   16
        }

        Name (TLPK, Package (0x20)
        {
            0xFFFFFFFF, 
            0x2C, 
            0xFFFFFFFF, 
            0x2C, 
            0xFFFFFFFF, 
            0x2C, 
            0xFFFFFFFF, 
            0x2C, 
            0xFFFFFFFF, 
            0x2C, 
            0xFFFFFFFF, 
            0x2C, 
            0xFFFFFFFF, 
            0x2C, 
            0xFFFFFFFF, 
            0xFFFFFFFF, 
            0x2C, 
            0xFFFFFFFF, 
            0xFFFFFFFF, 
            0x2C, 
            0xFFFFFFFF, 
            0xFFFFFFFF, 
            0x2C, 
            0xFFFFFFFF, 
            0xFFFFFFFF, 
            0x2C, 
            0xFFFFFFFF, 
            0xFFFFFFFF, 
            0x2C, 
            0xFFFFFFFF, 
            0xFFFFFFFF, 
            0x2C
        })
        Method (INDL, 0, Serialized)
        {
            NXD1 = Zero
            NXD2 = Zero
            NXD3 = Zero
            NXD4 = Zero
            NXD5 = Zero
            NXD6 = Zero
            NXD7 = Zero
            NXD8 = Zero
        }

        Method (SND1, 1, Serialized)
        {
            If ((Arg0 == DID1))
            {
                NXD1 = One
            }

            If ((Arg0 == DID2))
            {
                NXD2 = One
            }

            If ((Arg0 == DID3))
            {
                NXD3 = One
            }

            If ((Arg0 == DID4))
            {
                NXD4 = One
            }

            If ((Arg0 == DID5))
            {
                NXD5 = One
            }

            If ((Arg0 == DID6))
            {
                NXD6 = One
            }

            If ((Arg0 == DID7))
            {
                NXD7 = One
            }

            If ((Arg0 == DID8))
            {
                NXD8 = One
            }
        }

        Method (SNXD, 1, Serialized)
        {
            INDL ()
            Local0 = One
            Local1 = Zero
            While ((Local0 < Arg0))
            {
                If ((DerefOf (TLPK [Local1]) == 0x2C))
                {
                    Local0++
                }

                Local1++
            }

            SND1 (DerefOf (TLPK [Local1]))
            Local1++
            If ((DerefOf (TLPK [Local1]) != 0x2C))
            {
                SND1 (DerefOf (TLPK [Local1]))
            }
        }

        Method (CTOI, 1, Serialized)
        {
            Switch (ToInteger (Arg0))
            {
                Case (One)
                {
                    Return (One)
                }
                Case (0x02)
                {
                    Return (0x02)
                }
                Case (0x04)
                {
                    Return (0x03)
                }
                Case (0x08)
                {
                    Return (0x04)
                }
                Case (0x10)
                {
                    Return (0x05)
                }
                Case (0x20)
                {
                    Return (0x06)
                }
                Case (0x40)
                {
                    Return (0x07)
                }
                Case (0x03)
                {
                    Return (0x08)
                }
                Case (0x06)
                {
                    Return (0x09)
                }
                Case (0x0A)
                {
                    Return (0x0A)
                }
                Case (0x12)
                {
                    Return (0x0B)
                }
                Case (0x22)
                {
                    Return (0x0C)
                }
                Case (0x42)
                {
                    Return (0x0D)
                }
                Default
                {
                    Return (One)
                }

            }
        }
    }

    Scope (\_SB.PC00.RP12.PXSX)
    {
        Method (GC6I, 0, Serialized)
        {
            Debug = "<<< GC6I >>>"
            \_SB.PC00.RP12.PXSX.LTRE = \_SB.PC00.RP12.LREN
            \_SB.PC00.RP12.DL23 ()
            Sleep (0x0A)
            \_SB.PC00.SGPO (TRSG, TRSP, One)
        }

        Method (GC6O, 0, Serialized)
        {
            Debug = "<<< GC6O >>>"
            \_SB.PC00.SGPO (TRSG, TRSP, Zero)
            Sleep (0x0A)
            \_SB.PC00.RP12.L23D ()
            \_SB.PC00.RP12.CMDR |= 0x04
            \_SB.PC00.RP12.D0ST = Zero
            While ((\_SB.PC00.RP12.PXSX.VEID != 0x10DE))
            {
                Sleep (One)
            }

            \_SB.PC00.RP12.LREN = \_SB.PC00.RP12.PXSX.LTRE
            \_SB.PC00.RP12.CEDR = One
        }

        Method (NVJT, 4, Serialized)
        {
            Debug = "------- NV JT DSM --------"
            If ((Arg1 < 0x0100))
            {
                Return (0x80000001)
            }

            Switch (ToInteger (Arg2))
            {
                Case (Zero)
                {
                    Debug = "JT fun0 JT_FUNC_SUPPORT"
                    Return (Buffer (0x04)
                    {
                         0x1B, 0x00, 0x00, 0x00                           // ....
                    })
                }
                Case (One)
                {
                    Debug = "JT fun1 JT_FUNC_CAPS"
                    Name (JTCA, Buffer (0x04)
                    {
                         0x00                                             // .
                    })
                    CreateField (JTCA, Zero, One, JTEN)
                    CreateField (JTCA, One, 0x02, SREN)
                    CreateField (JTCA, 0x03, 0x02, PLPR)
                    CreateField (JTCA, 0x05, One, SRPR)
                    CreateField (JTCA, 0x06, 0x02, FBPR)
                    CreateField (JTCA, 0x08, 0x02, GUPR)
                    CreateField (JTCA, 0x0A, One, GC6R)
                    CreateField (JTCA, 0x0B, One, PTRH)
                    CreateField (JTCA, 0x0D, One, MHYB)
                    CreateField (JTCA, 0x0E, One, RPCL)
                    CreateField (JTCA, 0x0F, 0x02, GC6V)
                    CreateField (JTCA, 0x11, One, GEIS)
                    CreateField (JTCA, 0x12, One, GSWS)
                    CreateField (JTCA, 0x14, 0x0C, JTRV)
                    JTEN = One
                    GC6R = Zero
                    MHYB = One
                    RPCL = One
                    SREN = One
                    FBPR = Zero
                    MHYB = One
                    GC6V = 0x02
                    JTRV = 0x0200
                    Return (JTCA) /* \_SB_.PC00.RP12.PXSX.NVJT.JTCA */
                }
                Case (0x02)
                {
                    Debug = "JT fun2 JT_FUNC_POLICYSELECT"
                    Return (0x80000002)
                }
                Case (0x03)
                {
                    Debug = "JT fun3 JT_FUNC_POWERCONTROL"
                    CreateField (Arg3, Zero, 0x03, GPPC)
                    CreateField (Arg3, 0x04, One, PLPC)
                    CreateField (Arg3, 0x07, One, ECOC)
                    CreateField (Arg3, 0x0E, 0x02, DFGC)
                    CreateField (Arg3, 0x10, 0x03, GPCX)
                    \_SB.PC00.RP12.TGPC = Arg3
                    If (((ToInteger (GPPC) != Zero) || (ToInteger (DFGC
                        ) != Zero)))
                    {
                        TDGC = ToInteger (DFGC)
                        DGCX = ToInteger (GPCX)
                    }

                    Name (JTPC, Buffer (0x04)
                    {
                         0x00                                             // .
                    })
                    CreateField (JTPC, Zero, 0x03, GUPS)
                    CreateField (JTPC, 0x03, One, GPWO)
                    CreateField (JTPC, 0x07, One, PLST)
                    If ((ToInteger (DFGC) != Zero))
                    {
                        GPWO = One
                        GUPS = One
                        Return (JTPC) /* \_SB_.PC00.RP12.PXSX.NVJT.JTPC */
                    }

                    If ((ToInteger (GPPC) == One))
                    {
                        GC6I ()
                        PLST = One
                        GUPS = Zero
                    }
                    ElseIf ((ToInteger (GPPC) == 0x02))
                    {
                        GC6I ()
                        If ((ToInteger (PLPC) == Zero))
                        {
                            PLST = Zero
                        }

                        GUPS = Zero
                    }
                    ElseIf ((ToInteger (GPPC) == 0x03))
                    {
                        GC6O ()
                        If ((ToInteger (PLPC) != Zero))
                        {
                            PLST = Zero
                        }

                        GPWO = One
                        GUPS = One
                    }
                    ElseIf ((ToInteger (GPPC) == 0x04))
                    {
                        GC6O ()
                        If ((ToInteger (PLPC) != Zero))
                        {
                            PLST = Zero
                        }

                        GPWO = One
                        GUPS = One
                    }
                    Else
                    {
                        Debug = "<<< GETS >>>"
                        If ((\_SB.GGOV (0x00141009) == One))
                        {
                            Debug = "<<< GETS() return 0x1 >>>"
                            GPWO = One
                            GUPS = One
                        }
                        Else
                        {
                            Debug = "<<< GETS() return 0x3 >>>"
                            GPWO = Zero
                            GUPS = 0x03
                        }
                    }

                    Return (JTPC) /* \_SB_.PC00.RP12.PXSX.NVJT.JTPC */
                }
                Case (0x04)
                {
                    Debug = "   JT fun4 JT_FUNC_PLATPOLICY"
                    CreateField (Arg3, 0x02, One, PAUD)
                    CreateField (Arg3, 0x03, One, PADM)
                    CreateField (Arg3, 0x04, 0x04, PDGS)
                    Local0 = Zero
                    Local0 = (\_SB.PC00.RP12.PXSX.NHDA << 0x02)
                    Return (Local0)
                }

            }

            Return (0x80000002)
        }
    }

    Scope (\_SB.PC00.RP12.PXSX)
    {
        Name (NLIM, Zero)
        Name (PSLS, Zero)
        Name (GPSP, Buffer (0x28){})
        CreateDWordField (GPSP, Zero, RETN)
        CreateDWordField (GPSP, 0x04, VRV1)
        CreateDWordField (GPSP, 0x08, TGPU)
        CreateDWordField (GPSP, 0x0C, PDTS)
        CreateDWordField (GPSP, 0x10, SFAN)
        CreateDWordField (GPSP, 0x14, SKNT)
        CreateDWordField (GPSP, 0x18, CPUE)
        CreateDWordField (GPSP, 0x1C, TMP1)
        CreateDWordField (GPSP, 0x20, TMP2)
        Method (GPS, 4, Serialized)
        {
            Debug = "------- NV GPS DSM --------"
            If ((Arg1 != 0x0200))
            {
                Return (0x80000002)
            }

            Switch (ToInteger (Arg2))
            {
                Case (Zero)
                {
                    Debug = "GPS fun 0"
                    Return (Buffer (0x08)
                    {
                         0x01, 0x00, 0x08, 0x00, 0x01, 0x04, 0x00, 0x00   // ........
                    })
                }
                Case (0x12)
                {
                    Debug = "GPS fun 18"
                }
                Case (0x13)
                {
                    Debug = "GPS fun 19"
                    CreateDWordField (Arg3, Zero, TEMP)
                    If (\_SB.PC00.LPCB.EC0.ECOK)
                    {
                        Acquire (\_SB.PC00.LPCB.EC0.MUT0, 0x2000)
                        \_SB.PC00.LPCB.EC0.SDNT = One
                        Release (\_SB.PC00.LPCB.EC0.MUT0)
                    }

                    If ((TEMP == Zero))
                    {
                        Return (0x04)
                    }

                    If ((TEMP && 0x04))
                    {
                        If (\_SB.PC00.LPCB.EC0.ECOK)
                        {
                            Acquire (\_SB.PC00.LPCB.EC0.MUT0, 0x2000)
                            \_SB.PC00.LPCB.EC0.SDNT = One
                            Release (\_SB.PC00.LPCB.EC0.MUT0)
                        }

                        Return (0x04)
                    }
                }
                Case (0x20)
                {
                    Debug = "GPS fun 32"
                    Name (RET1, Zero)
                    CreateBitField (Arg3, 0x02, SPBI)
                    If (NLIM)
                    {
                        RET1 |= One
                    }

                    If (PSLS)
                    {
                        RET1 |= 0x02
                    }

                    Return (RET1) /* \_SB_.PC00.RP12.PXSX.GPS_.RET1 */
                }
                Case (0x2A)
                {
                    Debug = "GPS fun 42"
                    CreateField (Arg3, Zero, 0x04, PSH0)
                    CreateBitField (Arg3, 0x08, GPUT)
                    VRV1 = 0x00010000
                    Switch (ToInteger (PSH0))
                    {
                        Case (Zero)
                        {
                            Return (GPSP) /* \_SB_.PC00.RP12.PXSX.GPSP */
                        }
                        Case (One)
                        {
                            RETN = 0x0100
                            RETN |= ToInteger (PSH0)
                            Return (GPSP) /* \_SB_.PC00.RP12.PXSX.GPSP */
                        }
                        Case (0x02)
                        {
                            RETN = 0x0102
                            If ((NBFM == One))
                            {
                                NBFM = Zero
                                TGPU = GTPM /* External reference */
                            }
                            Else
                            {
                                If ((TGPU == Zero))
                                {
                                    If ((\_SB.PC00.LPCB.EC0.FTBL == 0x02))
                                    {
                                        TGPU = 0x4B
                                    }
                                    ElseIf ((\_SB.PC00.LPCB.EC0.FTBL == Zero))
                                    {
                                        TGPU = 0x57
                                    }
                                    Else
                                    {
                                        TGPU = 0x57
                                    }
                                }
                                Else
                                {
                                }

                                NLIM = Zero
                            }

                            Return (GPSP) /* \_SB_.PC00.RP12.PXSX.GPSP */
                        }

                    }

                    Return (0x80000002)
                }

            }

            Return (0x80000002)
        }
    }

    Scope (\_SB.PC00.RP12.PXSX)
    {
        Name (AFST, 0xFF)
        Method (CAFL, 0, Serialized)
        {
            If ((AFST == 0xFF))
            {
                OperationRegion (SMIP, SystemIO, 0x0820, One)
                Field (SMIP, ByteAcc, NoLock, Preserve)
                {
                    IOB2,   8
                }

                OperationRegion (NVIO, SystemIO, IOBS, 0x10)
                Field (NVIO, ByteAcc, NoLock, Preserve)
                {
                    CPUC,   8
                }

                Local0 = IOB2 /* \_SB_.PC00.RP12.PXSX.CAFL.IOB2 */
                CPUC = Local0
            }
        }
    }

    Scope (\_SB)
    {
        Device (NPCF)
        {
            Name (CNPF, Zero)
            Name (AMAT, 0xA0)
            Name (ACBT, 0x78)
            Name (DCBT, Zero)
            Name (DBAC, Zero)
            Name (DBDC, One)
            Name (AMIT, 0xFFB0)
            Name (ATPP, 0x0168)
            Name (DTPP, Zero)
            Name (TPPL, 0x0001C138)
            Name (DROS, Zero)
            Name (LTBL, Zero)
            Name (STBL, Zero)
            Name (CDIS, Zero)
            Name (CUSL, Zero)
            Name (CUCT, 0x7C)
            Name (ARAT, 0x50)
            Name (WM2M, One)
            Name (CTDI, Zero)
            Name (GTDI, Zero)
            Name (AVGF, Zero)
            Name (AVGI, Zero)
            Name (AVG0, Zero)
            Name (AVG1, Zero)
            Name (AVG2, Zero)
            Name (AVG3, Zero)
            Name (AVG4, Zero)
            Name (SFTN, 0x06)
            Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
            {
                CDIS = Zero
                Return ("NVDA0820")
            }

            Name (_UID, "NPCF")  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((CDIS == One))
                {
                    Return (0x0D)
                }

                Return (0x0F)
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                CDIS = One
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == ToUUID ("36b49710-2483-11e7-9598-0800200c9a66") /* Unknown UUID */))
                {
                    Return (NPCF (Arg0, Arg1, Arg2, Arg3))
                }
            }

            Method (RCHV, 0, NotSerialized)
            {
                If ((IOBS != Zero))
                {
                    OperationRegion (NVIO, SystemIO, IOBS, 0x10)
                    Field (NVIO, ByteAcc, NoLock, Preserve)
                    {
                        CPUC,   8
                    }

                    CPUC = CHPV /* External reference */
                }
            }

            Method (NTCU, 0, Serialized)
            {
                Switch (ToInteger (TCNT))
                {
                    Case (0x14)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                        Notify (\_SB.PR04, 0x85) // Device-Specific
                        Notify (\_SB.PR05, 0x85) // Device-Specific
                        Notify (\_SB.PR06, 0x85) // Device-Specific
                        Notify (\_SB.PR07, 0x85) // Device-Specific
                        Notify (\_SB.PR08, 0x85) // Device-Specific
                        Notify (\_SB.PR09, 0x85) // Device-Specific
                        Notify (\_SB.PR10, 0x85) // Device-Specific
                        Notify (\_SB.PR11, 0x85) // Device-Specific
                        Notify (\_SB.PR12, 0x85) // Device-Specific
                        Notify (\_SB.PR13, 0x85) // Device-Specific
                        Notify (\_SB.PR14, 0x85) // Device-Specific
                        Notify (\_SB.PR15, 0x85) // Device-Specific
                        Notify (\_SB.PR16, 0x85) // Device-Specific
                        Notify (\_SB.PR17, 0x85) // Device-Specific
                        Notify (\_SB.PR18, 0x85) // Device-Specific
                        Notify (\_SB.PR19, 0x85) // Device-Specific
                    }
                    Case (0x13)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                        Notify (\_SB.PR04, 0x85) // Device-Specific
                        Notify (\_SB.PR05, 0x85) // Device-Specific
                        Notify (\_SB.PR06, 0x85) // Device-Specific
                        Notify (\_SB.PR07, 0x85) // Device-Specific
                        Notify (\_SB.PR08, 0x85) // Device-Specific
                        Notify (\_SB.PR09, 0x85) // Device-Specific
                        Notify (\_SB.PR10, 0x85) // Device-Specific
                        Notify (\_SB.PR11, 0x85) // Device-Specific
                        Notify (\_SB.PR12, 0x85) // Device-Specific
                        Notify (\_SB.PR13, 0x85) // Device-Specific
                        Notify (\_SB.PR14, 0x85) // Device-Specific
                        Notify (\_SB.PR15, 0x85) // Device-Specific
                        Notify (\_SB.PR16, 0x85) // Device-Specific
                        Notify (\_SB.PR17, 0x85) // Device-Specific
                        Notify (\_SB.PR18, 0x85) // Device-Specific
                    }
                    Case (0x12)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                        Notify (\_SB.PR04, 0x85) // Device-Specific
                        Notify (\_SB.PR05, 0x85) // Device-Specific
                        Notify (\_SB.PR06, 0x85) // Device-Specific
                        Notify (\_SB.PR07, 0x85) // Device-Specific
                        Notify (\_SB.PR08, 0x85) // Device-Specific
                        Notify (\_SB.PR09, 0x85) // Device-Specific
                        Notify (\_SB.PR10, 0x85) // Device-Specific
                        Notify (\_SB.PR11, 0x85) // Device-Specific
                        Notify (\_SB.PR12, 0x85) // Device-Specific
                        Notify (\_SB.PR13, 0x85) // Device-Specific
                        Notify (\_SB.PR14, 0x85) // Device-Specific
                        Notify (\_SB.PR15, 0x85) // Device-Specific
                        Notify (\_SB.PR16, 0x85) // Device-Specific
                        Notify (\_SB.PR17, 0x85) // Device-Specific
                    }
                    Case (0x11)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                        Notify (\_SB.PR04, 0x85) // Device-Specific
                        Notify (\_SB.PR05, 0x85) // Device-Specific
                        Notify (\_SB.PR06, 0x85) // Device-Specific
                        Notify (\_SB.PR07, 0x85) // Device-Specific
                        Notify (\_SB.PR08, 0x85) // Device-Specific
                        Notify (\_SB.PR09, 0x85) // Device-Specific
                        Notify (\_SB.PR10, 0x85) // Device-Specific
                        Notify (\_SB.PR11, 0x85) // Device-Specific
                        Notify (\_SB.PR12, 0x85) // Device-Specific
                        Notify (\_SB.PR13, 0x85) // Device-Specific
                        Notify (\_SB.PR14, 0x85) // Device-Specific
                        Notify (\_SB.PR15, 0x85) // Device-Specific
                        Notify (\_SB.PR16, 0x85) // Device-Specific
                    }
                    Case (0x10)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                        Notify (\_SB.PR04, 0x85) // Device-Specific
                        Notify (\_SB.PR05, 0x85) // Device-Specific
                        Notify (\_SB.PR06, 0x85) // Device-Specific
                        Notify (\_SB.PR07, 0x85) // Device-Specific
                        Notify (\_SB.PR08, 0x85) // Device-Specific
                        Notify (\_SB.PR09, 0x85) // Device-Specific
                        Notify (\_SB.PR10, 0x85) // Device-Specific
                        Notify (\_SB.PR11, 0x85) // Device-Specific
                        Notify (\_SB.PR12, 0x85) // Device-Specific
                        Notify (\_SB.PR13, 0x85) // Device-Specific
                        Notify (\_SB.PR14, 0x85) // Device-Specific
                        Notify (\_SB.PR15, 0x85) // Device-Specific
                    }
                    Case (0x0E)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                        Notify (\_SB.PR04, 0x85) // Device-Specific
                        Notify (\_SB.PR05, 0x85) // Device-Specific
                        Notify (\_SB.PR06, 0x85) // Device-Specific
                        Notify (\_SB.PR07, 0x85) // Device-Specific
                        Notify (\_SB.PR08, 0x85) // Device-Specific
                        Notify (\_SB.PR09, 0x85) // Device-Specific
                        Notify (\_SB.PR10, 0x85) // Device-Specific
                        Notify (\_SB.PR11, 0x85) // Device-Specific
                        Notify (\_SB.PR12, 0x85) // Device-Specific
                        Notify (\_SB.PR13, 0x85) // Device-Specific
                    }
                    Case (0x0C)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                        Notify (\_SB.PR04, 0x85) // Device-Specific
                        Notify (\_SB.PR05, 0x85) // Device-Specific
                        Notify (\_SB.PR06, 0x85) // Device-Specific
                        Notify (\_SB.PR07, 0x85) // Device-Specific
                        Notify (\_SB.PR08, 0x85) // Device-Specific
                        Notify (\_SB.PR09, 0x85) // Device-Specific
                        Notify (\_SB.PR10, 0x85) // Device-Specific
                        Notify (\_SB.PR11, 0x85) // Device-Specific
                    }
                    Case (0x0A)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                        Notify (\_SB.PR04, 0x85) // Device-Specific
                        Notify (\_SB.PR05, 0x85) // Device-Specific
                        Notify (\_SB.PR06, 0x85) // Device-Specific
                        Notify (\_SB.PR07, 0x85) // Device-Specific
                        Notify (\_SB.PR08, 0x85) // Device-Specific
                        Notify (\_SB.PR09, 0x85) // Device-Specific
                    }
                    Case (0x08)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                        Notify (\_SB.PR04, 0x85) // Device-Specific
                        Notify (\_SB.PR05, 0x85) // Device-Specific
                        Notify (\_SB.PR06, 0x85) // Device-Specific
                        Notify (\_SB.PR07, 0x85) // Device-Specific
                    }
                    Case (0x07)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                        Notify (\_SB.PR04, 0x85) // Device-Specific
                        Notify (\_SB.PR05, 0x85) // Device-Specific
                        Notify (\_SB.PR06, 0x85) // Device-Specific
                    }
                    Case (0x06)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                        Notify (\_SB.PR04, 0x85) // Device-Specific
                        Notify (\_SB.PR05, 0x85) // Device-Specific
                    }
                    Case (0x05)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                        Notify (\_SB.PR04, 0x85) // Device-Specific
                    }
                    Case (0x04)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                        Notify (\_SB.PR03, 0x85) // Device-Specific
                    }
                    Case (0x03)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                        Notify (\_SB.PR02, 0x85) // Device-Specific
                    }
                    Case (0x02)
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                        Notify (\_SB.PR01, 0x85) // Device-Specific
                    }
                    Default
                    {
                        Notify (\_SB.PR00, 0x85) // Device-Specific
                    }

                }
            }

            Name (SCFI, Buffer (0x0C)
            {
                /* 0000 */  0xFF, 0x00, 0x3C, 0x3F, 0x3F, 0x46, 0x46, 0x57,  // ..<??FFW
                /* 0008 */  0x57, 0x5A, 0x5A, 0x5E                           // WZZ^
            })
            Name (SGFI, Buffer (0x0C)
            {
                /* 0000 */  0xFF, 0x00, 0x2D, 0x33, 0x33, 0x37, 0x37, 0x3F,  // ..-3377?
                /* 0008 */  0x3F, 0x43, 0x43, 0x46                           // ?CCF
            })
            Method (MAVT, 1, Serialized)
            {
                Switch (ToInteger (AVGI))
                {
                    Case (Zero)
                    {
                        AVG0 = Arg0
                    }
                    Case (One)
                    {
                        AVG1 = Arg0
                    }
                    Case (0x02)
                    {
                        AVG2 = Arg0
                    }
                    Case (0x03)
                    {
                        AVG3 = Arg0
                    }
                    Case (0x04)
                    {
                        AVG4 = Arg0
                    }

                }

                If ((AVGI >= 0x04))
                {
                    AVGI = Zero
                    AVGF = One
                }
                Else
                {
                    AVGI += One
                }

                If ((AVGF >= One))
                {
                    Divide ((AVG0 + (AVG1 + (AVG2 + (AVG3 + AVG4))
                        )), 0x05, Local1, Local0)
                }
                Else
                {
                    Divide ((AVG0 + (AVG1 + (AVG2 + (AVG3 + AVG4))
                        )), AVGI, Local1, Local0)
                }

                Return (Local0)
            }

            Method (FCPI, 1, Serialized)
            {
                Local0 = CTDI /* \_SB_.NPCF.CTDI */
                While ((Local0 < SFTN))
                {
                    Local1 = ((Local0 * 0x02) + One)
                    If ((Arg0 >= DerefOf (SCFI [Local1])))
                    {
                        CTDI = Local0
                        Local0++
                    }
                    Else
                    {
                        Break
                    }
                }

                If ((CTDI == Local0))
                {
                    While ((Local0 > Zero))
                    {
                        Local1 = (Local0 * 0x02)
                        If ((Arg0 <= DerefOf (SCFI [Local1])))
                        {
                            Local0--
                            CTDI = Local0
                        }
                        Else
                        {
                            Break
                        }
                    }
                }

                Return (CTDI) /* \_SB_.NPCF.CTDI */
            }

            Method (FGPI, 1, Serialized)
            {
                Local0 = GTDI /* \_SB_.NPCF.GTDI */
                While ((Local0 < SFTN))
                {
                    Local1 = ((Local0 * 0x02) + One)
                    If ((Arg0 >= DerefOf (SGFI [Local1])))
                    {
                        GTDI = Local0
                        Local0++
                    }
                    Else
                    {
                        Break
                    }
                }

                If ((GTDI == Local0))
                {
                    While ((Local0 > Zero))
                    {
                        Local1 = (Local0 * 0x02)
                        If ((Arg0 <= DerefOf (SGFI [Local1])))
                        {
                            Local0--
                            GTDI = Local0
                        }
                        Else
                        {
                            Break
                        }
                    }
                }

                Return (GTDI) /* \_SB_.NPCF.GTDI */
            }

            Method (NPCF, 4, Serialized)
            {
                Debug = "------- NVPCF DSM --------"
                If ((ToInteger (Arg1) != 0x0200))
                {
                    Return (0x80000001)
                }

                Switch (ToInteger (Arg2))
                {
                    Case (Zero)
                    {
                        Debug = "   NVPCF sub-func#0"
                        \_SB.NPCF.CNPF = One
                        Return (Buffer (0x04)
                        {
                             0xBF, 0x07, 0x00, 0x00                           // ....
                        })
                    }
                    Case (One)
                    {
                        Debug = "   NVPCF sub-func#1"
                        Return (Buffer (0x0E)
                        {
                            /* 0000 */  0x20, 0x03, 0x01, 0x00, 0x24, 0x04, 0x05, 0x01,  //  ...$...
                            /* 0008 */  0x01, 0x01, 0x00, 0x00, 0x00, 0xAC               // ......
                        })
                    }
                    Case (0x02)
                    {
                        Debug = "   NVPCF sub-func#2"
                        Name (PBD2, Buffer (0x31)
                        {
                             0x00                                             // .
                        })
                        CreateByteField (PBD2, Zero, PTV2)
                        CreateByteField (PBD2, One, PHB2)
                        CreateByteField (PBD2, 0x02, GSB2)
                        CreateByteField (PBD2, 0x03, CTB2)
                        CreateByteField (PBD2, 0x04, NCE2)
                        PTV2 = 0x24
                        PHB2 = 0x05
                        GSB2 = 0x10
                        CTB2 = 0x1C
                        NCE2 = One
                        CreateWordField (PBD2, 0x05, TGPA)
                        CreateWordField (PBD2, 0x07, TGPD)
                        CreateByteField (PBD2, 0x15, PC01)
                        CreateByteField (PBD2, 0x16, PC02)
                        CreateWordField (PBD2, 0x19, TPPA)
                        CreateWordField (PBD2, 0x1B, TPPD)
                        CreateWordField (PBD2, 0x1D, MAGA)
                        CreateWordField (PBD2, 0x1F, MAGD)
                        CreateWordField (PBD2, 0x21, MIGA)
                        CreateWordField (PBD2, 0x23, MIGD)
                        CreateDWordField (PBD2, 0x25, DROP)
                        CreateDWordField (PBD2, 0x29, LTBC)
                        CreateDWordField (PBD2, 0x2D, STBC)
                        CreateField (Arg3, 0x28, 0x02, NIGS)
                        CreateByteField (Arg3, 0x15, IORC)
                        CreateField (Arg3, 0xB0, One, PWCS)
                        CreateField (Arg3, 0xB1, One, PWTS)
                        CreateField (Arg3, 0xB2, One, CGPS)
                        If ((ToInteger (NIGS) == Zero))
                        {
                            TGPA = ACBT /* \_SB_.NPCF.ACBT */
                            TGPD = DCBT /* \_SB_.NPCF.DCBT */
                            PC01 = Zero
                            PC02 = (DBAC | (DBDC << One))
                            TPPA = ATPP /* \_SB_.NPCF.ATPP */
                            TPPD = DTPP /* \_SB_.NPCF.DTPP */
                            MAGA = AMAT /* \_SB_.NPCF.AMAT */
                            MIGA = AMIT /* \_SB_.NPCF.AMIT */
                            DROP = DROS /* \_SB_.NPCF.DROS */
                        }

                        If ((ToInteger (NIGS) == One))
                        {
                            If ((ToInteger (PWCS) == One)){}
                            Else
                            {
                            }

                            If ((ToInteger (PWTS) == One)){}
                            Else
                            {
                            }

                            If ((ToInteger (CGPS) == One)){}
                            Else
                            {
                            }

                            TGPA = Zero
                            TGPD = Zero
                            PC01 = Zero
                            PC02 = Zero
                            TPPA = Zero
                            TPPD = Zero
                            MAGA = Zero
                            MIGA = Zero
                            MAGD = Zero
                            MIGD = Zero
                        }

                        Return (PBD2) /* \_SB_.NPCF.NPCF.PBD2 */
                    }
                    Case (0x03)
                    {
                        Debug = "   NVPCF sub-func#3"
                        Return (Buffer (0x1E)
                        {
                            /* 0000 */  0x11, 0x04, 0x0D, 0x02, 0x00, 0xFF, 0x00, 0x3C,  // .......<
                            /* 0008 */  0x3F, 0x3F, 0x46, 0x46, 0x57, 0x57, 0x5A, 0x5A,  // ??FFWWZZ
                            /* 0010 */  0x5E, 0x05, 0xFF, 0x00, 0x2D, 0x33, 0x33, 0x37,  // ^...-337
                            /* 0018 */  0x37, 0x3F, 0x3F, 0x43, 0x43, 0x46               // 7??CCF
                        })
                    }
                    Case (0x04)
                    {
                        Debug = "   NVPCF sub-func#4"
                        Return (Buffer (0x32)
                        {
                            /* 0000 */  0x11, 0x04, 0x2E, 0x01, 0x05, 0x00, 0x01, 0x02,  // ........
                            /* 0008 */  0x03, 0x04, 0x03, 0x00, 0x01, 0x02, 0x00, 0x00,  // ........
                            /* 0010 */  0x00, 0x01, 0x02, 0x03, 0x00, 0x00, 0x00, 0x01,  // ........
                            /* 0018 */  0x02, 0x03, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03,  // ........
                            /* 0020 */  0x01, 0x01, 0x01, 0x01, 0x02, 0x03, 0x02, 0x02,  // ........
                            /* 0028 */  0x02, 0x02, 0x02, 0x03, 0x03, 0x03, 0x03, 0x03,  // ........
                            /* 0030 */  0x03, 0x03                                       // ..
                        })
                    }
                    Case (0x05)
                    {
                        Debug = "   NVPCF sub-func#5"
                        Name (PBD5, Buffer (0x28)
                        {
                             0x00                                             // .
                        })
                        CreateByteField (PBD5, Zero, PTV5)
                        CreateByteField (PBD5, One, PHB5)
                        CreateByteField (PBD5, 0x02, TEB5)
                        CreateByteField (PBD5, 0x03, NTE5)
                        PTV5 = 0x11
                        PHB5 = 0x04
                        TEB5 = 0x24
                        NTE5 = One
                        CreateDWordField (PBD5, 0x04, F5O0)
                        CreateDWordField (PBD5, 0x08, F5O1)
                        CreateDWordField (PBD5, 0x0C, F5O2)
                        CreateDWordField (PBD5, 0x10, F5O3)
                        CreateDWordField (PBD5, 0x14, F5O4)
                        CreateDWordField (PBD5, 0x18, F5O5)
                        CreateDWordField (PBD5, 0x1C, F5O6)
                        CreateDWordField (PBD5, 0x20, F5O7)
                        CreateDWordField (PBD5, 0x24, F5O8)
                        CreateField (Arg3, 0x20, 0x03, INC5)
                        CreateDWordField (Arg3, 0x08, F5P1)
                        CreateDWordField (Arg3, 0x0C, F5P2)
                        Switch (ToInteger (INC5))
                        {
                            Case (Zero)
                            {
                                F5O0 = WM2M /* \_SB_.NPCF.WM2M */
                                F5O1 = Zero
                                F5O2 = Zero
                                F5O3 = Zero
                            }
                            Case (One)
                            {
                                F5O0 = 0x0C
                                F5O1 = Zero
                                F5O2 = Zero
                                F5O3 = Zero
                            }
                            Case (0x02)
                            {
                                F5O0 = Zero
                                Local0 = \_SB.PC00.LPCB.EC0.CTMP /* External reference */
                                Local1 = \_SB.PC00.LPCB.EC0.VRTT /* External reference */
                                Local0 = MAVT (Local0)
                                Local2 = FCPI (Local0)
                                F5O1 = ((Local0 << 0x10) | (Local2 & 0xFF))
                                Local2 = FGPI (Local1)
                                F5O2 = ((Local1 << 0x10) | (Local2 & 0xFF))
                                F5O3 = Zero
                                F5O4 = Zero
                                F5O5 = Zero
                                F5O6 = Zero
                                F5O7 = Zero
                                F5O8 = Zero
                            }
                            Case (0x03)
                            {
                                CUSL = (F5P1 & 0xFF)
                            }
                            Case (0x04)
                            {
                                CUCT = F5P2 /* \_SB_.NPCF.NPCF.F5P2 */
                            }
                            Default
                            {
                                Return (0x80000002)
                            }

                        }

                        Return (PBD5) /* \_SB_.NPCF.NPCF.PBD5 */
                    }
                    Case (0x07)
                    {
                        Debug = "   NVPCF sub-func#7"
                        CreateDWordField (Arg3, 0x05, AMAX)
                        CreateDWordField (Arg3, 0x09, ARAT)
                        CreateDWordField (Arg3, 0x0D, DMAX)
                        CreateDWordField (Arg3, 0x11, DRAT)
                        CreateDWordField (Arg3, 0x15, TGPM)
                        Return (Zero)
                    }
                    Case (0x08)
                    {
                        Debug = "   NVPCF sub-func#8"
                        Return (Buffer (0x6A)
                        {
                            /* 0000 */  0x10, 0x04, 0x11, 0x06, 0x64, 0x58, 0x1B, 0x00,  // ....dX..
                            /* 0008 */  0x00, 0xB8, 0x88, 0x00, 0x00, 0x78, 0x69, 0x00,  // .....xi.
                            /* 0010 */  0x00, 0x40, 0x9C, 0x00, 0x00, 0x50, 0x58, 0x1B,  // .@...PX.
                            /* 0018 */  0x00, 0x00, 0xB8, 0x88, 0x00, 0x00, 0xC0, 0x5D,  // .......]
                            /* 0020 */  0x00, 0x00, 0xA0, 0x8C, 0x00, 0x00, 0x3C, 0x58,  // ......<X
                            /* 0028 */  0x1B, 0x00, 0x00, 0xB8, 0x88, 0x00, 0x00, 0xD8,  // ........
                            /* 0030 */  0x59, 0x00, 0x00, 0xD0, 0x84, 0x00, 0x00, 0x32,  // Y......2
                            /* 0038 */  0x64, 0x19, 0x00, 0x00, 0xB8, 0x88, 0x00, 0x00,  // d.......
                            /* 0040 */  0x20, 0x4E, 0x00, 0x00, 0x30, 0x75, 0x00, 0x00,  //  N..0u..
                            /* 0048 */  0x19, 0x64, 0x19, 0x00, 0x00, 0xB8, 0x88, 0x00,  // .d......
                            /* 0050 */  0x00, 0x38, 0x4A, 0x00, 0x00, 0x48, 0x71, 0x00,  // .8J..Hq.
                            /* 0058 */  0x00, 0x0A, 0x64, 0x19, 0x00, 0x00, 0xB8, 0x88,  // ..d.....
                            /* 0060 */  0x00, 0x00, 0x38, 0x4A, 0x00, 0x00, 0x60, 0x6D,  // ..8J..`m
                            /* 0068 */  0x00, 0x00                                       // ..
                        })
                    }
                    Case (0x09)
                    {
                        Debug = "   NVPCF sub-func#9"
                        CreateDWordField (Arg3, 0x03, CPTD)
                        Local0 = CPTD /* \_SB_.NPCF.NPCF.CPTD */
                        Divide (Local0, 0x03E8, Local1, Local2)
                        \_SB.PC00.LPCB.EC0.NDF9 = Local2
                        Return (Zero)
                    }
                    Case (0x0A)
                    {
                        Debug = "   NVPCF sub-func#10"
                        Name (PBDA, Buffer (0x08)
                        {
                             0x00                                             // .
                        })
                        CreateByteField (PBDA, Zero, DTTV)
                        CreateByteField (PBDA, One, DTSH)
                        CreateByteField (PBDA, 0x02, DTSE)
                        CreateByteField (PBDA, 0x03, DTTE)
                        CreateDWordField (PBDA, 0x04, DTTL)
                        DTTV = 0x10
                        DTSH = 0x04
                        DTSE = 0x04
                        DTTE = One
                        DTTL = TPPL /* \_SB_.NPCF.TPPL */
                        Return (PBDA) /* \_SB_.NPCF.NPCF.PBDA */
                    }

                }

                Return (0x80000002)
            }
        }
    }
}

