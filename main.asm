; iNES header
; ------------------------------------------------------------------------------
.segment "HEADER"

INES_MAPPER = 0 ; 0 = NROM
INES_MIRROR = 1 ; 0 = horizontal mirroring, 1 = vertical mirroring
INES_SRAM   = 0 ; 1 = battery backed SRAM at $6000-7FFF

.byte 'N', 'E', 'S', $1A ; ID
.byte $02 ; 16k PRG chunk count
.byte $01 ; 8k CHR chunk count
.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $f) << 4)
.byte (INES_MAPPER & %11110000)
.byte $0, $0, $0, $0, $0, $0, $0, $0 ; padding
; ------------------------------------------------------------------------------


; Interruption vector
; ------------------------------------------------------------------------------
.segment "VECTORS"

.word NMI
.word RESET
.word 0
; ------------------------------------------------------------------------------

.macro pushRegisters
  pha
  txa
  pha
  tya
  pha
.endmacro


.macro pullRegisters
  pla
  tay
  pla
  tax
  pla
.endmacro

; Include helper subroutines
; ------------------------------------------------------------------------------
.include "controller.asm"
.include "sound.asm"
.include "render.asm"
.include "gameStructure.asm"

; ------------------------------------------------------------------------------


; reset routine
; ------------------------------------------------------------------------------
.segment "CODE"

RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

  :       ; First wait for vblank to make sure PPU is ready
    BIT PPU_STATUS
  BPL :-

  :
    LDA #$00
    STA $0000, x
    STA $0100, x
    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x
    LDA #$FE
    STA $0200, x
    INX
  BNE :-
   
  :      ; Second wait for vblank, PPU is ready after this
    BIT PPU_STATUS
  BPL :-

  ; Rendering initialization
  JSR LoadPalettes
  setBackground titlescreen_bg
  ; Sound initialization
  JSR soundInit
  ; Game state initialization
  setGameState TITLE
  ; Start NMI
  JSR InitRender

  ; Init random number generator
  lda #10
  sta seed

  ; Jump into the infinite game loop
  JMP GameLoop
; ------------------------------------------------------------------------------


; nmi routine
; ------------------------------------------------------------------------------
.segment "CODE"

NMI:
  pushRegisters

  ; Rendering
  ; ----------------------------------------------------------------------------
  ; Call rendering method
  JSR Render
  ; Update frame 
  JSR ClearSprites
  lda gameState
  cmp #PLAYING
  bne :+
    JSR LoadScore
    JSR LoadBranches
    JSR LoadLumberjack
  :
  ; ----------------------------------------------------------------------------
  
  ; Sound engine
  ; ----------------------------------------------------------------------------
  ; Update sound engine playing states
  JSR soundPlayFrame
  ; ----------------------------------------------------------------------------

  pullRegisters
RTI             ; return from interrupt
; ------------------------------------------------------------------------------
