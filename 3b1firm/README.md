# How to make custom firmware for your UNIX PC (7300 / 3B1)
All made possible by: https://github.com/tomstorey/m68k_bare_metal

* Install gcc-m68k (`sudo apt install gcc-m68k-linux-gnu`)
* Install srecord package (`sudo apt install srecord`)

* Build **libmetal-68010.a**: run `make` from *libmetal* directory

* Run `make crt` from *3b1firm* directory

* Run `make` from *3b1firm* directory

**hack-14c.rom** and **hack-15c.rom** should be created if all goes well.

## To use with FreeBee emulator

Edit `.freebee.toml` to use custom hack rom files:
```
[roms]
#	rom_14c = "roms/14c.bin"	# Odd locations
#	rom_15c = "roms/15c.bin"	# Even locations
	rom_14c = "roms/hack-14c.rom"	# Odd locations
	rom_15c = "roms/hack-15c.rom"	# Even locations
```

Run `freebee`

## To use on real hardware
UNIX PC uses two 27C64 EPROMs (2x8KB). BUT the hardware allegedly supports 27C128 so 2x16KB should be possible.

Alternative EEPROMs to try?: Winbond W27C512, 28C256


