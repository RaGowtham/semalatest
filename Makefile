SEMA_OBJS = $(patsubst %.c,%.o,$(wildcard lib/*.c))
WDOG_OBJS = $(patsubst %.c,%.o,$(wildcard watchdogtest/*.c))
APP_OBJS = $(patsubst %.c,%.o,$(wildcard app/*.c))

obj-m += driver/adl-bmc.o \
	 driver/adl-bmc-bklight.o \
 	 driver/adl-bmc-wdt.o \
	 driver/adl-bmc-i2c.o \
 	 driver/adl-bmc-boardinfo.o \
 	 driver/adl-bmc-nvmem.o \
 	 driver/adl-bmc-hwmon.o \
 	 driver/vm-core.o \
 	 driver/adl-bmc-vm.o \

all: libsema.so semautil wdogtest modules

driver: modules

libsema.so: 	$(SEMA_OBJS) 
		gcc -shared -fPIC -g -o lib/$@ $^

modules:
	make -C /lib/modules/`uname -r`/build M=`pwd` $@

clean: driver_clean app_clean

install: all driver_install app_install

driver_install:
	make -C /lib/modules/`uname -r`/build M=`pwd` modules_install 2> /dev/null
	@depmod -a

app_install:
	@cp lib/libsema.so /usr/lib64
	@cp wdogtest semautil /usr/bin

driver_clean:
	make -C /lib/modules/`uname -r`/build M=`pwd` clean

app_clean:
	rm -f semautil wdogtest app/*.o lib/*.o lib/*.so

semautil: $(APP_OBJS)
	gcc -g -o $@ $^ -Llib -lsema

wdogtest: $(WDOG_OBJS)
	gcc $^ -g -o $@

%.o: %.c
	gcc -Wall -I lib -g -fPIC -c $^ -o $@
