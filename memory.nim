import types
import bitops
import cartridge
import sdl

export types.CPUMemory

proc readByte*(gameboy: Gameboy, address: uint16): uint8 =
  if address < 0x8000:
    return gameboy.cartridge.readByte(address)
  if address < 0xA000:
    return 1
  if address < 0xC000:
    return gameboy.cartridge.readByte(address)
  if address < 0x9FFF:
    return gameboy.vpu.readByte(address)
  if 0xFF0F == address:
    return gameboy.intFlag
  # VPU Allocations
  if 0xFF40 == address:
    return gameboy.vpu.lcdc
  if 0xFF41 == address:
    return gameboy.vpu.stat
  if 0xFF42 == address:
    return gameboy.vpu.scy
  if 0xFF43 == address:
    return gameboy.vpu.scx
  if 0xFF44 == address:
    return gameboy.vpu.ly
  if 0xFF45 == address:
    return gameboy.vpu.lyc
  if 0xFF46 == address:
    return gameboy.vpu.dma
  if 0xFF47 == address:
    return gameboy.vpu.bgp
  if 0xFF48 == address:
    return gameboy.vpu.obp0
  if 0xFF49 == address:
    return gameboy.vpu.obp1
  if 0xFF4A == address:
    return gameboy.vpu.wy
  if 0xFF4B == address:
    return gameboy.vpu.ly
  if 0xFF51 == address:     # Gameboy Color Only
    return gameboy.vpu.hdma1
  if 0xFF52 == address:     # Gameboy Color Only
    return gameboy.vpu.hdma2
  if 0xFF53 == address:     # Gameboy Color Only
    return gameboy.vpu.hdma3
  if 0xFF54 == address:     # Gameboy Color Only
    return gameboy.vpu.hdma4
  if 0xFF55 == address:     # Gameboy Color Only
    return gameboy.vpu.hdma5
  if 0xFF68 == address:     # Gameboy Color Only
    return gameboy.vpu.bgpi
  if 0xFF69 == address:     # Gameboy Color Only
    return gameboy.vpu.bgpd
  if 0xFF6A == address:     # Gameboy Color Only
    return gameboy.vpu.ocps
  # Global Interrupts Table
  if 0xFFFF == address:
    return gameboy.intEnable

proc writeByte*(gameboy: Gameboy; address: uint16; value: uint8): void =
  if address < 0x8000:
    gameboy.cartridge.writeByte(address, value)
  if address < 0xA000:
      discard
  if address < 0xC000:
    gameboy.cartridge.writeByte(address, value)
  if 0xFF0F == address:
    gameboy.intFlag = value
  if 0xFFFF == address:
    gameboy.intEnable = value

proc newCPUMemory*(gameboy: Gameboy): CPUMemory =
  CPUMemory(gameboy: gameboy)

proc newTimerGb*(gameboy: Gameboy): TimerGb =
  TimerGb(gameboy: gameboy)

proc clearAllInterrupts*(gameboy: Gameboy): void =
  gameboy.intFlag = 0x0000

proc testVSyncInterrupt*(gameboy: Gameboy): bool =
  return gameboy.readByte(0xFF0F).testBit(0)

proc testLCDStatInterrupt*(gameboy: Gameboy): bool =
  return gameboy.readByte(0xFF0F).testBit(1)

proc testTimerInterrupt*(gameboy: Gameboy): bool =
  return gameboy.readByte(0xFF0F).testBit(2)

proc testSerialInterrupt*(gameboy: Gameboy): bool =
  return gameboy.readByte(0xFF0F).testBit(3)

proc testJoypadInterrupt*(gameboy: Gameboy): bool =
  return gameboy.readByte(0xFF0F).testBit(4)

proc testVSyncIntEnabled*(gameboy: Gameboy): bool =
  return gameboy.readByte(0xFFFF).testBit(0)

proc testLCDStatIntEnabled*(gameboy: Gameboy): bool =
  return gameboy.readByte(0xFFFF).testBit(1)

proc testTimerIntEnabled*(gameboy: Gameboy): bool =
  return gameboy.readByte(0xFFFF).testBit(2)

proc testSerialIntEnabled*(gameboy: Gameboy): bool =
  return gameboy.readByte(0xFFFF).testBit(3)

proc testJoypadIntEnabled*(gameboy: Gameboy): bool =
  return gameboy.readByte(0xFFFF).testBit(4)

proc triggerVSyncInterrupt*(gameboy: var Gameboy): void =
  var ie = gameboy.readByte(0xFF0F)
  ie.setBit(0)
  gameboy.writeByte(0xFF0F, ie)

proc triggerLCDStatInterrupt*(gameboy: var Gameboy): void =
  var ie = gameboy.readByte(0xFF0F)
  ie.setBit(1)
  gameboy.writeByte(0xFF0F, ie)

proc triggerTimerInterrupt*(gameboy: var Gameboy): void =
  var ie = gameboy.readByte(0xFF0F)
  ie.setBit(2)
  gameboy.writeByte(0xFF0F, ie)

proc triggerSerialInterrupt*(gameboy: var Gameboy): void =
  var ie = gameboy.readByte(0xFF0F)
  ie.setBit(3)
  gameboy.writeByte(0xFF0F, ie)

proc triggerJoypadInterrupt*(gameboy: var Gameboy): void =
  var ie = gameboy.readByte(0xFF0F)
  ie.setBit(4)
  gameboy.writeByte(0xFF0F, ie)

proc clearVSyncInterrupt*(gameboy: var Gameboy): void =
  var ie = gameboy.readByte(0xFF0F)
  ie.clearBit(0)
  gameboy.writeByte(0xFF0F, ie)

proc clearLCDStatInterrupt*(gameboy: var Gameboy): void =
  var ie = gameboy.readByte(0xFF0F)
  ie.clearBit(1)
  gameboy.writeByte(0xFF0F, ie)

proc clearTimerInterrupt*(gameboy: var Gameboy): void =
  var ie = gameboy.readByte(0xFF0F)
  ie.clearBit(2)
  gameboy.writeByte(0xFF0F, ie)

proc clearSerialInterrupt*(gameboy: var Gameboy): void =
  var ie = gameboy.readByte(0xFF0F)
  ie.clearBit(3)
  gameboy.writeByte(0xFF0F, ie)

proc clearJoypadInterrupt*(gameboy: var Gameboy): void =
  var ie = gameboy.readByte(0xFF0F)
  ie.clearBit(4)
  gameboy.writeByte(0xFF0F, ie)
