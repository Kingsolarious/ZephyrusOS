# Zephyrus Global Menu System

## Overview

A custom global menu system built specifically for Zephyrus OS and GNOME 49+.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GNOME Shell (Top Panel)                   │
│  ┌──────────┐ ┌──────────────────────────────────┐          │
│  │ ROG Logo │ │ Zephyrus Global Menu Widget      │          │
│  └──────────┘ └──────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
                           ▲
                           │ D-Bus
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  Zephyrus Menu Service                       │
│         (Extracts menus from running applications)           │
└─────────────────────────────────────────────────────────────┘
                           ▲
                           │ GTK Hooks
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Running Applications                            │
└─────────────────────────────────────────────────────────────┘
```

## Why This Will Work on GNOME 49

- Doesn't rely on deprecated GNOME AppMenu API
- Uses low-level GTK hooks (always available)
- D-Bus is standard and stable
- Shell extension uses standard St widgets

## Development Time Estimate

- Basic prototype: 2-3 days
- Full GTK support: 1-2 weeks
- Qt support: +1 week
- Polish: +1 week

**Total: 4-6 weeks**
