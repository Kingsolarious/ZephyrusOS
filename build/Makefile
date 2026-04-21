# ASUS Charger Fix Kernel Module Makefile

obj-m += asus-charger-fix-dkms.o

KVERSION := $(shell uname -r)
KDIR := /usr/src/kernels/$(KVERSION)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

install:
	$(MAKE) -C $(KDIR) M=$(PWD) modules_install
	depmod -a

load:
	insmod asus-charger-fix-dkms.ko

unload:
	rmmod asus-charger-fix-dkms
