;-------------------------------------
; Lumberjack control variables
.segment "BSS"
lumberjack: .res 1
NONE = $00
LEFT = $01
RIGHT = $02
; Random number generator variables
seed: .res 2       ; initialize 16-bit seed to any value except 0
; Tree branches array
treeBranches: .res 5
; Game states variables
score:  .res 1
gameState:  .res 1
TITLE = $03
WIN = $02
LOSE = $01
PLAYING = $00
MAXSCORE = 99  ; max score 99

.macro setGameState state
  lda #state
  sta gameState
.endmacro


.segment "CODE"
; The main game loop
;-------------------------------------
GameLoop:
  ; Read game controller 
  JSR readController

  ; Process the current game state
  lda gameState
  cmp #PLAYING
  beq PLAYING_CASE
  TITLE_CASE:
    binp BUTTON_A, :+
      setGameState PLAYING
      setBackground game_bg
      loadSongNumber $00
      jsr initGameState
    :
    jmp END_CASE
  PLAYING_CASE:
    ; Update game states
    jsr moveLumberjack
    binp BUTTON_LEFT | BUTTON_RIGHT, AfterMoveTree
      jsr moveTree
      loadSongNumber $05
    AfterMoveTree:
    jsr checkIfLost
    binp BUTTON_LEFT | BUTTON_RIGHT, AfterAddPoint
      jsr addPoint
    AfterAddPoint:
    jsr checkIfWon
    jmp END_CASE
  END_CASE:
jmp GameLoop

;-------------------------------------
initGameState:
  jsr initScore
  jsr initLumberjack
  jsr initTree
rts

;-------------------------------------
initScore:
  lda #0
  sta score
rts

;-------------------------------------
initLumberjack:
  lda #RIGHT ; the lumberjack will always start at the right side of the tree
  sta lumberjack
rts

;-------------------------------------
moveLumberjack:
  binp BUTTON_LEFT, :+
    lda #LEFT
    sta lumberjack
  :
  binp BUTTON_RIGHT, :+
    lda #RIGHT
    sta lumberjack
  :
rts

;-----------------------------------------
randomNumberGenerator:
  pushRegisters

	ldx #8     ; iteration count (generates 8 bits)
	lda seed+0
  :
	  asl        ; shift the register
  	rol seed+1
  	bcc :+
	    eor #$2D   ; apply XOR feedback whenever a 1 bit is shifted out
    :
	  dex
	bne :--
	sta seed+0
	cmp #0     ; reload flags
  
  pullRegisters
rts

;------------------------------------------------------
moveTree:
  pushRegisters
  
  ldx #3  ; x = tree base
  ldy #4  ; y = tree base + 1
  :
    lda treeBranches, x ; a = treeBranches[x]
    sta treeBranches, y ; treeBranches[y] = a
    dex
    dey
  bne :-
  :
    jsr randomNumberGenerator
    lda seed
    and #%00000011 ; making the seed value become either 00, 01, 10 or 11
    cmp #$03  ; if the seed value is 3, we generate a random number again
  beq :-
  sta treeBranches ; treeBranches[0] = random number
  
  pullRegisters
rts

;------------------------------------------------------
initTree:
  ldx #04
  :
    lda #0
    sta treeBranches, x
    dex
  bne :-
  lda #0
  sta treeBranches; treeBranches[x] = 0 (so there are no branches in the tree base when the game starts)
rts

;------------------------------------------------------
checkIfLost:
  lda treeBranches + 4 ; a = treeBranches[4]
  cmp lumberjack
  bne :+
    setGameState TITLE
    setBackground gameover_bg
    loadSongNumber $04
  :
rts

;-------------------------------------------------------
checkIfWon:
  lda score
  cmp #MAXSCORE
  bne :+
    setGameState TITLE
    setBackground win_bg
    loadSongNumber $03
  :
rts

;-------------------------------------------------------
addPoint:
  lda gameState
  cmp #LOSE
  beq :++
    inc score
    lda score
    cmp #100
    bne :+
      lda #0
      sta score
    :
  :
rts
