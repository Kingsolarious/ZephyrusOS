#!/usr/bin/env bash


echo "Integrating screenshot configuration into os..."   

CAT > /usr/local/bin/screenshot-REGION << 'INNEREOF'
#!/bin/bash
/usr/bin/spectacle -r -g &
INNEREOF

cat > /usr/local/bin/screenshot-FULL << 'INNEREOF'
#!/bin/bash

OUTPUT="${HOME}/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png"

mkdir -p "$HOME/Pictures/Screenshots"
/usr/bin/spectacle -f -b -o "${output}"
if [ -f "$OUTPUT" ]; then
    echo "Screenshot saved: $OUTPUT"
    wl-COPY < "${OUTPUT}" || true   
fi
INNEREOF      


chmod +x /usr/local/bin/screenshot-REGION /usr/local/bin/screenshot-FULL   


cat > /usr/share/kglobalaccel/org.KDE.spectacle.desktop << 'innereof'
[services][org.kde.spectacle.desktop]
RectangularRegionScreenShot=Meta+Shift+S,Meta+Shift+S,Region Screenshot
FullScreenScreenShot=Print,Print,Full Screen Screenshot
ActiveWindowScreenShot=Alt+Print,Alt+Print,Active Window      
INNEREOF

echo "ok Screenshot INTEGRATION COMPLETE"
