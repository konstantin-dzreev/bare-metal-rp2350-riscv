# 5.5.3. UF2 Targeting Rules
PROGRAM_NAME  = bare-metall-riscv
UF2_FAMILY_ID = 0xe48bff59

AS      = riscv32-unknown-elf-gcc
LD      = riscv32-unknown-elf-ld
ASFLAGS = -c -march=rv32imac_zicsr_zifencei_zba_zbb_zbkb_zbs -g
LDFLAGS = -T memory-map.ld

SOURCES    = $(wildcard *.s)
OBJECTS    = $(SOURCES:.s=.o)
TARGET_ELF = $(PROGRAM_NAME).elf
TARGET_UF2 = $(PROGRAM_NAME).uf2

.PHONY: all
all: clean $(TARGET_UF2)

.PHONY: clean
clean:
	rm -f $(OBJECTS) $(TARGET_ELF) $(TARGET_UF2)

.PHONY: deploy
deploy:
	cp ./$(TARGET_UF2) /media/$(USER)/RP2350/

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

$(TARGET_ELF): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS)

$(TARGET_UF2): $(TARGET_ELF)
	picotool uf2 convert $(TARGET_ELF) $(TARGET_UF2) --family $(UF2_FAMILY_ID)
