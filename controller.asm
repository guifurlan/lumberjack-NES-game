; Constants
; ------------------------------------------------------------------------------
; Controller 1 address
CONTROLLER_ADDRESS = $4016

; Controller buttons mask
BUTTON_A      = $01
BUTTON_B      = $02
BUTTON_SELECT = $04
BUTTON_START  = $08
BUTTON_UP     = $10
BUTTON_DOWN   = $20
BUTTON_LEFT   = $40
BUTTON_RIGHT  = $80
; ------------------------------------------------------------------------------

; Controller state
; ------------------------------------------------------------------------------
.segment "BSS"

controller_state:   .res 1
controller_pressed: .res 1
; ------------------------------------------------------------------------------

; Controller methods and macros
; ------------------------------------------------------------------------------
.segment "CODE"

readController:
  ; Latch the controller, which makes them update their state.
  ; In order, to do so, we should make a signal go from 1 to 0
  ; in the controller address.
  lda #$01
  sta CONTROLLER_ADDRESS
  lda #$00
  sta CONTROLLER_ADDRESS
  ; We need to read the controller address 8 times to acquire
  ; the 8 buttoms states.
  ldx #$08
  : ; for(x = 8; x > 0; x--)
    ; Backup the previous reading
    tay
    ; Load the new buttom state and store it in the carry bit
    lda CONTROLLER_ADDRESS
    lsr
    ; Restore the previous reading and aggregate it with the new one
    tya
    ror
    ; Decrement the number of remaining buttoms
    dex
  bne :-
  ; Extract the buttons that where pressed just now. This is done by
  ; checking if a buttom wasn't pressed before but it is now pressed
  ; (!previous_controller_state) and (current_controller_state).
  tay
  lda #$FF
  eor controller_state
  sty controller_state
  and controller_state
  sta controller_pressed
  rts
; readController

.macro binp buttom, address
  lda #buttom
  bit controller_pressed
  beq address
.endmacro

.macro bip buttom, address
  lda #buttom
  bit controller_pressed
  bne address
.endmacro 
; ------------------------------------------------------------------------------
