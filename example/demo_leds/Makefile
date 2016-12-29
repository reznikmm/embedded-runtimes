all:
	gprbuild -p
	arm-eabi-objcopy -O binary obj/demo obj/demo.bin
	echo 'Flash board using this line in MICO bootloader:'; \
	printf '4 -i -start 0x800C000 -end 0x%x\n' `echo $$((0x0800C000 + $$(stat -c %s obj/demo.bin) ))`
