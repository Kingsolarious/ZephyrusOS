#!/bin/bash

echo ""

echo "This will install your custom Zephyrus OS image with:"
echo "  ok NVIDIA proprietary driver"
echo "  ok asusctl + custom rog-control-center"
echo "  ok Working ROG Control Center GUI"
echo "  ok Your ROG logo"
echo "  ok zephyrus-os-tool"
echo ""
read -p "Continue? (y/N): " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
	echo "Cancelled."
	exit 0
fi

echo ""
echo "Rebasing to Zephyrus OS NVIDIA..."
sudo rpm-ostree rebase ostree-unverified-image:dir:/var/tmp/zephyrus-nvidia-fixed-export

if [ $? -eq 0 ]; then
	echo ""
	echo "ok Installation staged!"
	echo ""
	echo "IMPORTANT: You must REBOOT to activate the new image."
	echo ""
	read -p "Reboot now? (y/N): " reboot
	if [[ $reboot =~ ^[Yy]$ ]]; then
		reboot
	fi
else
	echo "fail Installation failed!"
	exit 1
fi
