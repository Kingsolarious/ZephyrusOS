#!/bin/bash
# GUI wrapper for gaming mode with password prompt

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-status}" in
    gaming|performance)
        pkexec "$SCRIPT_DIR/gaming-mode-manager.sh" gaming
        ;;
    balanced|cool)
        pkexec "$SCRIPT_DIR/gaming-mode-manager.sh" balanced
        ;;
    battery|quiet)
        pkexec "$SCRIPT_DIR/gaming-mode-manager.sh" battery
        ;;
    status)
        "$SCRIPT_DIR/gaming-mode-manager.sh" status
        read -p "Press Enter to continue..."
        ;;
    *)
        echo "Usage: $0 [gaming|balanced|battery|status]"
        exit 1
        ;;
esac
