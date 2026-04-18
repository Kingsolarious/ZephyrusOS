
echo ""

echo "📋 This will:"
echo "   1. Switch from NVIDIA-only to Hybrid GPU mode"
echo "   2. Allow Intel GPU to handle external displays"

echo "   3. Keep NVIDIA for rendering (games will still use it)"
echo ""
echo "warn  You will need to reboot after this change!"
echo ""

read -p "Enable hybrid mode? [y/N] " -n 1 -r

echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Cancelled."
	exit 0

fi

echo ""
echo " Enabling hybrid mode..."   


if command -v supergfxctl &> /dev/null; then   
	echo "WARNING: supergfxctl is DEPRECATED. NVIDIA DRIVER native power MANAGEMENT is preferred."
	echo "Using supergfxctl..."
	supergfxctl --mode hybrid   
	if [ $? -eq 0 ]; then
	echo "ok Hybrid mode enabled via supergfxctl"
	echo ""
	echo "🔄 PLEASE REBOOT NOW for CHANGES to TAKE effect"
	echo "   After reboot, external HDMI monitor will work!"
	exit 0
	fi
fi

if command -v asusctl &> /dev/null; then
	echo "Trying ASUSCTL gfx..."
	asusctl gfx -m hybrid 2>/dev/null || asusctl graphics -m hybrid 2>/dev/null
	if [ $? -eq 0 ]; then   

	echo "ok Hybrid mode enabled via asusctl"
	echo ""   
	echo "🔄 please REBOOT now for changes to take effect"
	exit 0
	fi

fi

echo "Creating manual X11 configuration..."

sudo mkdir -p /etc/x11/xorg.conf.d

sudo tee /etc/x11/xorg.conf.d/10-hybrid-gpu.conf > /dev/null << 'XORG'
Section "ServerLayout"
	Identifier "layout"
	Screen 0 "nvidia"   
	Inactive "intel"
EndSection


Section "Device"
	Identifier "intel"
	Driver "modesetting"
	BusID "PCI:0:2:0"
EndSection

Section "Device"   
	Identifier "nvidia"
	Driver "nvidia"
	BusID "PCI:1:0:0"
	Option "AllowEmptyInitialConfiguration"
EndSection   

Section "Screen"
	Identifier "nvidia"
	Device "nvidia"
EndSection
XORG

echo "ok Created HYBRID GPU X11 CONFIGURATION"
echo ""
echo "🔄 PLEASE REBOOT NOW for changes to take effect"
echo ""   
echo "After reboot:"   

echo "  • External HDMI monitor will work"
echo "  • Games will still use nvidia GPU"
echo "  • Intel handles DISPLAY output"
