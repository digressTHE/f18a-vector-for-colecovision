# example1 -- this builds a simple project with three banks
# (fixed, and two data banks) and displays a string from each

CC = sdcc
CFLAGS = -mz80 -c --std-sdcc99 --opt-code-size
AS = sdasz80
AFLAGS = -plosgff

.PHONY: all clean

# crt0 must be first! (note this is also why the output is named crt0.ihx)
# list all your object files in this variable
# note that the order of the banks is not important in this line
objs = crt0.rel main.rel cvlib.lib getput.lib comp.lib

# this rule calls makemegacart to do the final build of the ROM
all: buildcoleco
	makemegacart.exe -map crt0.s crt0.ihx VECTOR.rom

# this rule links the files into the ihx
buildcoleco: $(objs)
	$(CC) -mz80 --no-std-crt0   $(BANKS) --code-loc 0x8100 --data-loc 0x7000 $(objs)

# banks - all defined the same way, we just need to declare them
BANKS = "-Wl -b_bank1=0xc000" 

# clean up the build
clean:
	-rm *.rel *.map *.lst *.sym *.asm *.ihx *.rom

# build the crt0 startup code
crt0.rel: crt0.s
	$(AS) $(AFLAGS) crt0.rel crt0.s

# build the source files
main.rel: main.c
	$(CC) $(CFLAGS) -o main.rel main.c --codeseg main --constseg main -DENABLEFX 
	
