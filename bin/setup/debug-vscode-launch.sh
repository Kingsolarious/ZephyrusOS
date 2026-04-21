#!/bin/bash
# Debug why native VS Code: won't launch from menu

echo "=== Debugging VS Code: Launch ==="
echo ""

# Check if code exists
echo "1. Checking /usr/bin/code:"
ls -la /usr/bin/code 2>&1
/usr/bin/code --version 2>&1
echo ""

# Check desktop file
echo "2. Desktop file:"
grep "Exec=" ~/.local/share/applications/code.desktop 2>/dev/null || grep "Exec=" /usr/share/applications/code.desktop 2>/dev/null
echo ""

# Try to launch with error output
echo "3. Testing launch with verbose output:"
/usr/bin/code --verbose 2>&1 &
sleep 3
echo ""

# Check if process is running
echo "4. Checking if VS Code: is running:"
ps aux | grep -E "code|vscode" | grep -v grep | head -5
echo ""

# Check for errors
echo "5. Recent errors:"
journalctl --user -n 20 --no-pager 2>/dev/null | tail -10
echo ""

echo "=== Done ==="
