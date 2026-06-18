PROJECT    = rp2350-bare-metall-riscv-blink
FAMILY     = 0xe48bff5a  # 5.5.3. UF2 Targeting Rules
SOURCES    = $(wildcard src/*.s)
OBJECTS    = $(patsubst src/%.s,build/%.o,$(SOURCES))
TARGET_ELF = build/$(PROJECT).elf
TARGET_UF2 = build/$(PROJECT).uf2
#AS         = riscv32-unknown-elf-gcc
AS         = riscv32-unknown-elf-as
LD         = riscv32-unknown-elf-ld
AS_OPTIONS = -c -g -march=rv32imac_zba_zbb_zbkb_zbs_zcmp_zicsr_zifencei
LD_OPTIONS = -T linker/linker.ld

.PHONY: all
all: clean $(TARGET_UF2)

.PHONY: clean
clean:
	rm -rf build *.elf *.uf2

build:
	mkdir -p build

.PHONY: deploy
deploy:
	# cp ./$(TARGET_UF2) /run/media/$(USER)/RP2350/
	picotool load -x ./$(TARGET_UF2)

# Program using Raspberry PI Debug Probe
.PHONY: program
program:
	openocd -f interface/cmsis-dap.cfg \
		-f target/rp2350-riscv.cfg \
		-c "adapter speed 10000" \
		-c "program $(TARGET_ELF) verify reset exit"

build/%.o: src/%.s | build
	$(AS) $(AS_OPTIONS) -o $@ $<

$(TARGET_ELF): $(OBJECTS)
	$(LD) $(LD_OPTIONS) -o $@ $(OBJECTS)

$(TARGET_UF2): $(TARGET_ELF)
	picotool uf2 convert $(TARGET_ELF) $(TARGET_UF2) --family $(FAMILY)
