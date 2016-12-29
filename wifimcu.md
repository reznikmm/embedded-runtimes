# WiFiMCU

[WiFiMCU](http://www.wifimcu.com/) is the board that has
 * EMW3165
 * USB <-> UART chip CP2102
 * DC/DC converter
 * one LED and one buttons (besides power LED and reset button)

It has [open schematic in .pdf](https://github.com/SmartArduino/WiFiMCU/blob/master/Document/WiFiMCU_SCH.pdf)

EMW3165 is another mini-board with
 * STM32F411CE
 * 2M bytes of SPI flash
 * WiFi chip BCM43362
 * two 26MHz oscillators

STM32F411xx has
 * 512K bytes of on-chip flash
 * 128K bytes of RAM
 * max freq. of the SYSCLK and HCLK is 100 MHz, PCLK2 - 100 MHz and PCLK1 - 50 MHz

This is modified ravenscar-sfp-stm32f4 runtime and LED blinking example.

Modifications overview:
 * drop ccm linker section, due to chip doesn't have CCM
 * fix STM32F411xx.svd and generate i-smt32* with [svd2ada](https://github.com/adacore/svd2ada)
 * CR.VOS has two bits and should by set to 0x3
 * change frequencies to 100/50 Mhz and oscilattor freq to 26 Mhz
 * change FLASH_Periph.ACR.LATENCY
 * change PLL settings

I'm not sure about FLASH_Periph.ACR.LATENCY because datasheet says it
should be 7 CPU cycles for HCLK = 100 MHz.

I keep original 'bootloader' of WiFiMCU to be able to update flash,
because I don't have hardware tools to do this. That's why base code
address is 0x0800_C000 instead of 0x0800_0000.

