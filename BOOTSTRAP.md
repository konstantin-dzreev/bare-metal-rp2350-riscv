# Bootstrap Process

- RP2350 contains 32K boot ROM that has a program that executes on restart
- there are 3 forms of flash boot. We will try the simplest: flash image boot.

## An Example Of A Simple Image

### 5.10. Example Boot Scenarios

```
--------------------------
| Vector table
--------------------------
| Initial Metadata Block
| (must be in first 4kB)
| IMAGE_DEF Item
--------------------------
| Code
--------------------------
| Data
--------------------------
```

### 5.1.12. Flash Image Boot

RP2350 is designed primarily to run code from a QSPI flash device, either in-package or soldered separately to the
circuit board. Code runs either in-place in flash, or in SRAM after being loaded from flash. Flash boot is the process of
discovering that code and preparing to run it. Flash image boot uses a program binary stored directly in flash rather
than in a flash partition. Flash image boot requires the bootrom to discover a block loop starting within the first 4 kB of
flash which contains a valid IMAGE_DEF (and no PARTITION_TABLE).

Flash image boot has no partition table, so it cannot be used with A/B version checking, which requires separate A/B partitions. The IMAGE_DEF will boot if it is valid (which includes requiring a signature on a secured RP2350).

For the non-signed case, the IMAGE_DEF can be as small as a 20-bytes; see Section 5.9.5.

## Blocks

### 5.1.5.1. Blocks

IMAGE_DEFs and PARTITION_TABLEs are both examples of blocks. A block is a recognisable, self-checking data structure
containing one or more distinct data items. The type of the first item in a block defines the type of that entire block.

Blocks are backwards and forwards compatible; item types will not be changed in the future in ways that could cause
existing code to misinterpret data. Consumers of blocks (including the bootrom) must skip items within the block
whose types are currently listed as reserved; encountering reserved item types must not cause a block to fail validation.

To be considered valid, a block must have the following properties:
• it must begin with the 4 byte magic header, PICOBIN_BLOCK_MARKER_START (0xffffded3)
• the end of each (variably-sized) item must also be the start of another valid item
• the last item must have type PICOBIN_BLOCK_ITEM_2BS_LAST and specify the correct full length of the block
• it must end with the 4 byte magic footer, PICOBIN_BLOCK_MARKER_END (0xab123579)

The magic header and footer values are chosen to be unlikely to appear in executable Arm and RISC-V code. For more
information about the block format, see Section 5.9.1.

Given a region of memory or flash (e.g. a partition), blocks are found by searching the first 4 kB of that given region (for
flash boot) or the entire region (for RAM/OTP image boots) for a valid block which is part of a valid block loop.

Currently IMAGE_DEFs and PARTITION_TABLEs are the only types of block used by the RP2350 bootrom, but the block format
reserves encoding space for future expansion.


### 5.9.5. Minimum Viable Image Metadata

A minimum amount of metadata (i.e. a valid IMAGE_DEF block) must be embedded in any binary for the bootrom to
recognise it as a valid program image, as opposed to, for example, blank flash contents or a disconnected flash device.

This must appear within the first 4 kB of a flash image, or anywhere in a RAM or OTP image.

Unlike RP2040, there is no requirement for flash binaries to have a checksummed "boot2" flash setup function at flash
address 0. The RP2350 bootrom performs a simple best-effort XIP setup during flash scanning, and a flash-resident
program can continue executing in this state, or can choose to reconfigure the QSPI interface at a later time for best
performance.


### 5.9.5.1. Minimum Arm IMAGE_DEF

```text
Word    LE Value   Bytes    Description
   0  0xffffded3       4    PICOBIN_BLOCK_MARKER_START
   1  0x10210142       1    0x42(item_type == PICOBIN_BLOCK_ITEM_1BS_IMAGE_TYPE)
                       1    0x01 (Item is 1 word in size)
                       2    0x1021
                            (PICOBIN_IMAGE_TYPE_IMAGE_TYPE_AS_BITS(EXE)|
                            PICOBIN_IMAGE_TYPE_EXE_SECURITY_AS_BITS(S)|
                            PICOBIN_IMAGE_TYPE_EXE_CPU_AS_BITS(Arm)|
                            PICOBIN_IMAGE_TYPE_EXE_CHIP_AS_BITS(RP23500))
   2  0x000001ff       1    0xff(size_type == 1, item_type_ == PICOBIN_BLOCK_ITEM_2BS_LAST)
                       2    0x0001 (size)
                       1    0x00 (pad)
   3  0x00000000       4    Relative pointer to next block in block loop - 0x00000000 means link to self, i.e. a
                            loop containing just this block
   4  0xab123579       4    PICOBIN_BLOCK_MARKER_END
```
