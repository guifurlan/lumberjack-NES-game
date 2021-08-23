; ------------------------------------------------------------------------------
; Sprite OAM data to be uploaded by DMA
; ------------------------------------------------------------------------------
.segment "OAM"
oam: .res 256

; ------------------------------------------------------------------------------
; Render state
; ------------------------------------------------------------------------------
.segment "BSS"

position_counter:   .res 1
sprite_counter:     .res 1
a_value:            .res 1

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

PPU_STATUS = $2002
PPU_ADDRESS = $2006
PPU_INPUT = $2007

; ------------------------------------------------------------------------------
; Render methods
; ------------------------------------------------------------------------------
.segment "ZEROPAGE"

bg_pointer: .res 2

.segment "CODE"

.macro setBackground nametable_address
  ; Pause rendering
  LDA #$00   ; enable sprites, enable background, no clipping on left side
  STA $2001

  ; Store a pointer to the background nametable
  ; Since 6502 is little-endian, lower byte has to come first in memory
  LDA #<nametable_address
  STA bg_pointer
  LDA #>nametable_address
  STA bg_pointer+1
  jsr LoadBackground

  ; Un-pause rendering
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
.endmacro

LoadBackground:
.scope
  LDA PPU_STATUS             ; read PPU status to reset the high/low latch

  LDA #$20
  STA PPU_ADDRESS             ; write the high byte of $2000 address
  LDA #$00
  STA PPU_ADDRESS             ; write the low byte of $2000 address

  ; Copy the whole background into the PPU memory, $400 bytes of data
  LDX #$00              ; start out at 0
  LDY #$00              ; start out at 0
  @LoopX:
    @LoopY:
      LDA (bg_pointer), y
      STA PPU_INPUT
      INY
    BNE @LoopY

    INC bg_pointer+1

    INX
    CPX #$04
  BNE @LoopX
.endscope
rts

; ------------------------------------------------------------------------------
ClearSprites:
  LDX #$00
  LDA #$FE
  :
    STA $0200, x
    INX
  BNE :-
  
  RTS

; ------------------------------------------------------------------------------

LoadPalettes:
  LDA PPU_STATUS             ; read PPU status to reset the high/low latch
  LDA #$3F
  STA PPU_ADDRESS             ; write the high byte of $3F00 address
  LDA #$00
  STA PPU_ADDRESS             ; write the low byte of $3F00 address
  LDX #$00              ; start out at 0
:
  LDA palette, x        ; load data from address (palette + the value in x)
                          ; 1st time through loop it will load palette+0
                          ; 2nd time through loop it will load palette+1
                          ; 3rd time through loop it will load palette+2
                          ; etc
  STA PPU_INPUT             ; write to PPU
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE :-  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep 
                        
  RTS

; ------------------------------------------------------------------------------
InitRender:
  LDA #%10001000   ; enable NMI, sprites from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  
  ; Disable scrolling
  LDA #$00
  STA $2005
  STA $2005
  RTS
  
; ------------------------------------------------------------------------------

LoadLumberjack:
  LDX #$00
  LDY lumberjack
:
  CPY #$01
  BEQ LoadLeft
  LDA spritesright, x        ; load data from address (sprites +  x)
  JMP StoreSprites
LoadLeft:
  LDA spritesleft, x
StoreSprites:
  STA $0264, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$18              ; Compare X to hex $18, decimal 24
  BNE :-   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down
  RTS
; ------------------------------------------------------------------------------

.macro ldb address, index
.scope
  LDY index
  LDX #$00
  SpriteLoop:
    STX sprite_counter
    TXA
    AND #$03                  ; Check if that sprite is the y position sprite
    BNE LoadSprite

    CPY #$00                  ; if branch index = 0, dont add anything to y position.
    BEQ LoadSprite
    
    STY position_counter      ; Check if in that level, branch should be on left (1), 
    LDX treeBranches, y       ; right (2) or none (0)
    CPX #$00
    BEQ EndBranches
    CPX #$01
    BNE LoadRightBranch1
    
    LDX sprite_counter
    LDA branchleft, x
    JMP AddYPosition
    
    LoadRightBranch1:
    LDX sprite_counter
    LDA branchright, x
    
    AddYPosition:               ; Each branch should be 24 pixels bellow the previous.
    ADC #$20                  ; So for the branch index (0 to 4), add that times 18 (hex)
    DEY                       ; to the original Y position 
    CPY #$00
    BNE AddYPosition
    LDY position_counter
    JMP Transfer
    
    LoadSprite:
    LDX treeBranches, y       ; Check if in that level, branch should be on left (1),
    CPX #$00                  ; right (2) or none (0)
    BEQ EndBranches
    CPX #$01
    BNE LoadRightBranch2
    LDX sprite_counter
    LDA branchleft, x
    JMP Transfer
    
    LoadRightBranch2:
    LDX sprite_counter
    LDA branchright, x
    
    Transfer:
    LDX sprite_counter
    STA address, x 
    INX 
    CPX #$14
    BNE SpriteLoop
    
  EndBranches:
.endscope
.endmacro
       
; ------------------------------------------------------------------------------

LoadBranches:
 ldb $0200, #$00
 ldb $0214, #$01
 ldb $0228, #$02
 ldb $023C, #$03
 ldb $0250, #$04
RTS

; ------------------------------------------------------------------------------

LoadScore:
  LDX #$00
  ScoreLoop:                ; Write base for score sprites
    LDA scoresprites, x
    STA $027C, x
    INX
    CPX #$08
    BNE ScoreLoop
    
  LDA score            ; Calculate each digits of score
  LDY #$30             ; y = decimals. Tiles for numbers start at 30.
  LDX #$00             ; x = units
  Sub10:
    SEC
    SBC #$0A
    BMI Negative
    Positive:
      INY 
      JMP Sub10
      
    Negative:
      CLC
      ADC #$3A         ; Add 10 to make it positive. Add 30 for tile
      TAX 
      STY $027D                  ; Load correct tiles
      STX $0281
  
  RTS

; ------------------------------------------------------------------------------

Render:
  LDA #$00
  STA $2003      ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014      ; set the high byte (02) of the RAM address, start the transfer
rts

; ------------------------------------------------------------------------------

  .segment "RODATA"

palette:
  .byte $0F,$06,$18,$08,$0F,$16,$06,$18,$0F,$16,$06,$26,$3B,$3C,$3D,$3E
  .byte $0F,$11,$36,$17,$0F,$06,$18,$08,$0F,$38,$28,$3A,$3B,$3C,$3D,$3E


spritesleft:
     ;vert tile attr horiz
  .byte $BC, $00, $00, $60   ;sprite 0
  .byte $BC, $01, $00, $68   ;sprite 1
  .byte $C4, $10, $00, $60   ;sprite 2
  .byte $C4, $11, $00, $68   ;sprite 3
  .byte $CB, $20, $00, $60   ;sprite 4
  .byte $CB, $21, $00, $68   ;sprite 5
  

spritesright:
     ;vert tile attr horiz
  .byte $BC, $00, $40, $90   ;sprite 0
  .byte $BC, $01, $40, $88   ;sprite 1
  .byte $C4, $10, $40, $90   ;sprite 2
  .byte $C4, $11, $40, $88   ;sprite 3
  .byte $CB, $20, $40, $90   ;sprite 4
  .byte $CB, $21, $40, $88   ;sprite 5
  
branchleft:
     ;vert tile attr horiz
  .byte $30, $04, $01, $5A   ;sprite 0
  .byte $30, $05, $01, $60   ;sprite 1
  .byte $38, $14, $01, $5A   ;sprite 2
  .byte $38, $15, $01, $60   ;sprite 3
  .byte $38, $16, $01, $68   ;sprite 4
  
branchright:
    ;vert tile attr horiz
  .byte $30, $04, $41, $98   ;sprite 0
  .byte $30, $05, $41, $90   ;sprite 1
  .byte $38, $14, $41, $98   ;sprite 2
  .byte $38, $15, $41, $90   ;sprite 3
  .byte $38, $16, $41, $88   ;sprite 4
  
  
scoresprites:
  .byte $05, $30, $01, $36   ;sprite 0
  .byte $05, $30, $01, $3E  ;sprite 1    
  
  .segment "RODATA"
  game_bg:          .incbin "bg.nam"
  gameover_bg:      .incbin "gameover.nam"
  win_bg:           .incbin "win.nam"
  titlescreen_bg:   .incbin "titlescreen.nam"

  .segment "TILES"
  .incbin "lumberjack.chr"   ;includes 8KB graphics file from SMB1
