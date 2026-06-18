# Raspberry Pi Pico 2 – Bare-Metal RISC-V Assembly Interrupt-Driven LED Blink

This application shows basic RP2350 bring-up and interrupt handling. It:
- Installs the interrupt vector table.
- Releases the required peripherals from reset.
- Switches the reference clock from ROSC to the 12 MHz XOSC.
- Configures and enables the system PLL (optional).
- Switches the system clock to PLL_SYS at 150 MHz (optional).
- Configures the tick generator for a 1 μs tick period.
- Programs TIMER0 ALARM0 to generate an interrupt every 500 ms.
- Toggles the onboard LED from the TIMER0 interrupt handler.

## Build

```bash
$ make          # assembles and links; produces build/*.elf and build/*.uf2
$ make clean    # removes the build directory
```

### Flash via UF2 (BOOTSEL mode)

Hold the BOOTSEL button while connecting the Pico 2 to USB, then:

```bash
$ make deploy   # uses picotool to load and start the UF2
```

Or copy `build/*.uf2` to the `RP2350` USB mass-storage drive manually.

### Flash via Debug Probe (OpenOCD)

```bash
$ make program  # programs and resets via OpenOCD + CMSIS-DAP
```

## Toolchain Setup

### Install RISC-V Toolchain

Download and install the Raspberry Pi–provided RISC-V toolchain:

```bash
$ wget https://github.com/raspberrypi/pico-sdk-tools/releases/download/v2.2.0-3/riscv-toolchain-15-x86_64-lin.tar.gz
$ mkdir -p /home/$USER/source/tools/riscv-toolchain-15-x86_64-lin
$ tar xf riscv-toolchain-15-x86_64-lin.tar.gz -C /home/$USER/source/tools/riscv-toolchain-15-x86_64-lin
```

### Install OpenOCD (Open On-Chip Debugger)
https://openocd.org/doc-release/README

For on-chip debugging, install the Raspberry Pi–provided OpenOCD build:

```bash
$ wget https://github.com/raspberrypi/pico-sdk-tools/releases/download/v2.2.0-3/openocd-0.12.0+dev-x86_64-lin.tar.gz
$ mkdir -p /home/$USER/source/tools/openocd-0.12.0+dev-x86_64-lin
$ tar xf openocd-0.12.0+dev-x86_64-lin.tar.gz -C /home/$USER/source/tools/openocd-0.12.0+dev-x86_64-lin
```

### Install Picotool

Picotool is a command-line utility for RP2040 and RP2350 devices that can inspect firmware images, program flash memory, query connected boards, and reboot devices into normal or BOOTSEL mode.

```bash
$ wget https://github.com/raspberrypi/pico-sdk-tools/releases/download/v2.2.0-3/picotool-2.2.0-a4-x86_64-lin.tar.gz
$ mkdir -p /home/$USER/source/tools/picotool-2.2.0-a4-x86_64-lin
$ tar xf picotool-2.2.0-a4-x86_64-lin.tar.gz -C /home/$USER/source/tools/picotool-2.2.0-a4-x86_64-lin
```

### Environment Setup

Add binaries to your PATH, export the OpenOCD scripts directory, and reload your shell configuration:

```bash
$ cat << EOT >> ~/.bashrc
PATH="/home/$USER/source/tools/riscv-toolchain-15-x86_64-lin:\$PATH"
PATH="/home/$USER/source/tools/openocd-0.12.0+dev-x86_64-lin:\$PATH"
PATH="/home/$USER/source/tools/picotool-2.2.0-a4-x86_64-lin/picotool:\$PATH"
export OPENOCD_SCRIPTS=/home/$USER/source/tools/openocd-0.12.0+dev-x86_64-lin/scripts
EOT
. ~/.bashrc
```

## Hardware Debugging
### `udev` Rules (No `sudo` Required)

To allow OpenOCD to access the Raspberry Pi Debug Probe without requiring sudo, install the following udev rule:

```bash
$ sudo tee /etc/udev/rules.d/60-openocd-debugprobe.rules << EOT
# Raspberry Pi Debug Probe
ATTRS{idProduct}=="000c", ATTRS{idVendor}=="2e8a", MODE="666", GROUP="plugdev"
EOT
$ sudo udevadm control --reload-rules
$ sudo udevadm trigger
```

### GDB
https://sourceware.org/gdb/current/onlinedocs/gdb

The `riscv32-unknown-elf-gdb` provided with `pico-sdk-tools` is compiled without TUI support, which can make interactive debugging less convenient. `gdb-multiarch` is a good alternative, as it includes full TUI support.

#### Install GDB Multiarch (Optional)

```bash
$ sudo apt update
$ sudo apt install gdb-multiarch
```

### Starting a Debug Session

Connect the Raspberry Pi Pico 2 board to the Raspberry Pi Debug Probe, then connect the probe to your PC.
Once the Pico 2 is powered, it will immediately begin executing the loaded program.

#### Start OpenOCD

Launch an OpenOCD debug server for the RP2350 RISC-V core:

```bash
$ openocd -c "adapter speed 5000" -f interface/cmsis-dap.cfg -f target/rp2350-riscv.cfg
```

#### Start a GDB session

```bash
$ gdb-multiarch ./bare-metall-riscv.elf
```

Inside GDB:

```text
# Connect to OpenOCD
target extended-remote localhost:3333
# Reset the Pico 2 and halt execution
monitor reset halt
# Load the ELF image
load
# Enable TUI layout (if available)
layout next
# Set breakpoint at program entry point
break _start
# Start execution
continue
```

## Documentation

- RP2350 Datasheet: https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf
- Assembler: https://sourceware.org/binutils/docs/as/
- Linker: https://sourceware.org/binutils/docs/ld/
- Picotool: https://github.com/raspberrypi/picotool
- RISC-V ISA specification: https://riscv.org/technical/specifications/
- Assembly style guide: https://opentitan.org/book/doc/contributing/style_guides/asm_coding_style.html
