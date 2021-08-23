; ------------------------------------------------------------------------------
; The notes, periods and length tables
; ------------------------------------------------------------------------------
.include "notes.asm"


; ------------------------------------------------------------------------------
; Songs/Sound effects header table
; ------------------------------------------------------------------------------
.segment "RODATA"
song_table:
	.word	song0_header
	.word	song1_header
	.word	song2_header
	.word	song3_header
	.word	song4_header
	.word	song5_header

; ------------------------------------------------------------------------------
; Song 0: No song (silence)
; ------------------------------------------------------------------------------
song0_header:
  .byte $06           ;6 streams
  
  .byte MUSIC_SQ1     ;which stream
  .byte $00           ;status byte (stream disabled)
  
  .byte MUSIC_SQ2     ;which stream
  .byte $00           ;status byte (stream disabled)
  
  .byte MUSIC_TRI     ;which stream
  .byte $00           ;status byte (stream disabled)
  
  .byte MUSIC_NOI     ;which stream
  .byte $00           ;disabled.
  
  .byte SFX_1         ;which stream
  .byte $00           ;disabled

  .byte SFX_2         ;which stream
  .byte $00           ;disabled

; ------------------------------------------------------------------------------
; Song 1: 
; ------------------------------------------------------------------------------
song1_header:
  .byte $04           ; The number of streams
  
  .byte MUSIC_SQ1     ; The stream
  .byte $01           ; The status byte (stream enabled)
  .byte SQUARE_1      ; The used channel
  .byte $77           ; The initial volume (7) and duty (01)
  .word song1_square1 ; The pointer to stream
  .byte $40		        ; The tempo
  
  .byte MUSIC_SQ2     ; The stream
  .byte $01           ; The status byte (stream enabled)
  .byte SQUARE_2      ; The used channel
  .byte $B7           ; The initial volume (7) and duty (01)
  .word song1_square2 ; The pointer to stream
  .byte $40		        ; The tempo
  
  .byte MUSIC_TRI     ; The stream
  .byte $01           ; The status byte (stream enabled)
  .byte TRIANGLE      ; The used channel
  .byte $81           ; The initial volume (on)
  .word song1_tri     ; The pointer to stream
  .byte $40		        ; The tempo
  
  .byte MUSIC_NOI     ; The used stream
  .byte $00           ; The status byte (stream enabled)
    
song1_square1:
  .byte THIRTYSECOND, B2, D3, F3, GS3, B3, D4, F4, GS4, B4, D5, F5, GS5, B5, D6, F6, GS6
  .byte BB2, DB3, E3, G3, BB3, DB4, E4, G4, BB4, DB5, E5, G5, BB5, DB6, E6, G6
  .byte $FF
    
song1_square2:
  .byte THIRTYSECOND, GS5, F5, D5, GS5, F5, D5, B4, F5, D5, B4, GS4, D5, B4, GS4, F4, B4
  .byte G5, E5, DB5, G5, E5, DB5, BB4, E5, DB5, BB4, G4, DB5, BB4, G4, E4, BB4
  .byte $FF
    
song1_tri:
  .byte THIRTYSECOND, F6, D6, B5, D6, B5, GS5, B5, GS5, F5, GS5, F5, D5, F5, D5, B4, GS4
  .byte E6, DB6, BB5, DB6, BB5, G5, BB5, G5, E5, G5, E5, DB5, E5, DB5, BB4, G4
  .byte $FF

song2_header:
  .byte $01           ; The number of streams
  
  .byte SFX_1         ; The stream
  .byte $01           ; The status byte (stream enabled)
  .byte SQUARE_1      ; The used channel
  .byte $7F           ; The initial volume (F) and duty (01)
  .word song2_square1 ; The pointer to stream
  .byte $80           ; The tempo
    
    
song2_square1:
  .byte EIGHTH, D3, D2
  .byte $FF
	

song3_header:
  .byte $04           ; The number of streams
  
  .byte MUSIC_SQ1     ; The stream
  .byte $01           ; The status byte (stream enabled)
  .byte SQUARE_1      ; The used channel
  .byte $BC           ; The initial volume (C) and duty (10)
  .word song3_square1 ; The pointer to stream
  .byte $80           ; The tempo
  
  .byte MUSIC_SQ2     ; The stream
  .byte $01           ; The status byte (stream enabled)
  .byte SQUARE_2      ; The used channel
  .byte $3A           ; The initial volume (A) and duty (00)
  .word song3_square2 ; The pointer to stream
  .byte $80           ; The tempo
  
  .byte MUSIC_TRI     ; The stream
  .byte $01           ; The status byte (stream enabled)
  .byte TRIANGLE      ; The used channel
  .byte $81           ; The initial volume (on)
  .word song3_tri     ; The pointer to stream
  .byte $80           ; The tempo
  
  .byte MUSIC_NOI     
  .byte $00           
    
song3_square1:
  .byte EIGHTH, A3, C4, E4, A4, C5, E5, A5, F3
  .byte G3, B3, D4, G4, B4, D5, G5, E3
  .byte F3, A3, C4, F4, A4, C5, F5, C5
  .byte F3, A3, C4, F4, A4, C5, F5, REST
  .byte $FF
    
song3_square2:
  .byte EIGHTH, A3, A3, A3, E4, A3, A3, E4, A3 
  .byte G3, G3, G3, D4, G3, G3, D4, G3
  .byte F3, F3, F3, C4, F3, F3, C4, F3
  .byte F3, F3, F3, C4, F3, F3, C4, REST
  .byte $FF
    
song3_tri:
  .byte WHOLE, A3, G3, F3, F3
  .byte $FF

song4_header:
  .byte $04           ; The number of streams
  
  .byte MUSIC_SQ1     ; The stream
  .byte $01           ; The status byte (stream enabled)
  .byte SQUARE_1      ; The used channel
  .byte $BC           ; The initial volume (C) and duty (10)
  .word song4_square1 ; The pointer to stream
  .byte $60           ; The tempo
  
  .byte MUSIC_SQ2     ; The stream
  .byte $01           ; The status byte (stream enabled)
  .byte SQUARE_2      ; The used channel
  .byte $3A           ; The initial volume (A) and duty (00)
  .word song4_square2 ; The pointer to stream
  .byte $60           ; The tempo
  
  .byte MUSIC_TRI     ; The stream
  .byte $01           ; The status byte (stream enabled)
  .byte TRIANGLE      ; The used channel
  .byte $81           ; The initial volume (on)
  .word song4_tri     ; The pointer to stream
  .byte $60           ; The tempo
  
  .byte MUSIC_NOI
  .byte $00
                        
song4_square1:
  .byte HALF, E4, QUARTER, G4, EIGHTH, FS4, E4, D_SIXTEENTH, EB4, E4, FS4, T_QUARTER, REST, HALF, REST
  .byte       FS4, QUARTER, A4, EIGHTH, G4, FS4, D_SIXTEENTH, E4, FS4, G4, T_QUARTER, REST, HALF, REST
  .byte       G4, QUARTER, B4, EIGHTH, A4, G4, QUARTER, A4, B4, C5, EIGHTH, B4, A4
  .byte       B4, A4, G4, FS4, EB4, E4, FS4, G4, FS4, E4, D_HALF, REST
  .byte $FF
    
song4_square2:
  .byte EIGHTH, E3, REST, B3, REST, B3, REST, B3, REST, B2, REST, FS3, REST, FS3, REST, FS3, REST
  .byte         FS3, REST, A3, REST, A3, REST, A3, REST, B2, REST, E3, REST, E3, REST, E3, REST
  .byte         E3, REST, B3, REST, B3, REST, B3, REST, B3, REST, A3, REST, G3, REST, FS3, REST
  .byte EIGHTH, E3, REST, B3, REST, A3, REST, FS3, REST, E3, REST, D_HALF, REST
  .byte $FF
    
song4_tri:
  .byte HALF, E4, G4, B3, EB4
  .byte FS4, A4, B3, E4
  .byte G4, B4, QUARTER, A4, B4, HALF, C5
  .byte EIGHTH, E4, FS4, G4, A4, B3, C4, D4, EB4, A3, E4, D_HALF, REST
  .byte $FF

song5_header:
  .byte $01           ; The number of streams
  
  .byte SFX_2         ; The stream
  .byte $01           ; The status byte (stream enabled)
  .byte SQUARE_2      ; The used channel
  .byte $7F           ; The initial volume (F) and duty (01)
  .word song5_square2 ; The pointer to stream
  .byte $FF           ; The tempo
    
    
song5_square2:
  .byte THIRTYSECOND, C4, D8, C5, D7, C6, D6, C7, D5, C8, D8
  .byte $FF