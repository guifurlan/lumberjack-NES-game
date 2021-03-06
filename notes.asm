; ------------------------------------------------------------------------------
; Period/Frequency table
; ------------------------------------------------------------------------------
.segment "RODATA"
note_table:
  .word                                                                $07F1, $0780, $0713 ; A1-B1  ($00-$02)
  .word $06AD, $064D, $05F3, $059D, $054D, $0500, $04B8, $0475, $0435, $03F8, $03BF, $0389 ; C2-B2  ($03-$0E)
  .word $0356, $0326, $02F9, $02CE, $02A6, $027F, $025C, $023A, $021A, $01FB, $01DF, $01C4 ; C3-B3  ($0F-$1A)
  .word $01AB, $0193, $017C, $0167, $0151, $013F, $012D, $011C, $010C, $00FD, $00EF, $00E2 ; C4-B4  ($1B-$26)
  .word $00D2, $00C9, $00BD, $00B3, $00A9, $009F, $0096, $008E, $0086, $007E, $0077, $0070 ; C5-B5  ($27-$32)
  .word $006A, $0064, $005E, $0059, $0054, $004F, $004B, $0046, $0042, $003F, $003B, $0038 ; C6-B6  ($33-$3E)
  .word $0034, $0031, $002F, $002C, $0029, $0027, $0025, $0023, $0021, $001F, $001D, $001B ; C7-B7  ($3F-$4A)
  .word $001A, $0018, $0017, $0015, $0014, $0013, $0012, $0011, $0010, $000F, $000E, $000D ; C8-B8  ($4B-$56)
  .word $000C, $000C, $000B, $000A, $000A, $0009, $0008                                    ; C9-F#9 ($57-$5D)
  .word $0000                                                                              ; Rest pseudo-note

; ------------------------------------------------------------------------------
; Notes addresses
; ------------------------------------------------------------------------------
A1  = $00		; the "1" means Octave 1
AS1 = $01		; the "s" means "sharp"
BB1 = $01		; the "b" means "flat"  A# == Bb, so same value
B1  = $02

C2  = $03
CS2 = $04
DB2 = $04
D2  = $05
DS2 = $06
EB2 = $06
E2  = $07
F2  = $08
FS2 = $09
GB2 = $09
G2  = $0A
GS2 = $0B
AB2 = $0B
A2  = $0C
AS2 = $0D
BB2 = $0D
B2  = $0E

C3  = $0F
CS3 = $10
DB3 = $10
D3  = $11
DS3 = $12
EB3 = $12
E3  = $13
F3  = $14
FS3 = $15
GB3 = $15
G3  = $16
GS3 = $17
AB3 = $17
A3  = $18
AS3 = $19
BB3 = $19
B3  = $1A

C4  = $1B
CS4 = $1C
DB4 = $1C
D4  = $1D
DS4 = $1E
EB4 = $1E
E4  = $1F
F4  = $20
FS4 = $21
GB4 = $21
G4  = $22
GS4 = $23
AB4 = $23
A4  = $24
AS4 = $25
BB4 = $25
B4  = $26

C5  = $27
CS5 = $28
DB5 = $28
D5  = $29
DS5 = $2A
EB5 = $2A
E5  = $2B
F5  = $2C
FS5 = $2D
GB5 = $2D
G5  = $2E
GS5 = $2F
AB5 = $2F
A5  = $30
AS5 = $31
BB5 = $31
B5  = $32

C6  = $33
CS6 = $34
DB6 = $34
D6  = $35
DS6 = $36
EB6 = $36
E6  = $37
F6  = $38
FS6 = $39
GB6 = $39
G6  = $3A
GS6 = $3B
AB6 = $3B
A6  = $3C
AS6 = $3D
BB6 = $3D
B6  = $3E

C7  = $3F
CS7 = $40
DB7 = $40
D7  = $41
DS7 = $42
EB7 = $42
E7  = $43
F7  = $44
FS7 = $45
GB7 = $45
G7  = $46
GS7 = $47
AB7 = $47
A7  = $48
AS7 = $49
BB7 = $49
B7  = $4A

C8  = $4B
CS8 = $4C
DB8 = $4C
D8  = $4D
DS8 = $4E
EB8 = $4E
E8  = $4F
F8  = $50
FS8 = $51
GB8 = $51
G8  = $52
GS8 = $53
AB8 = $53
A8  = $54
AS8 = $55
BB8 = $55
B8  = $56

C9  = $57
CS9 = $58
DB9 = $58
D9  = $59
DS9 = $5A
EB9 = $5A
E9  = $5B
F9  = $5C
FS9 = $5D
GB9 = $5D

REST     = $5E


; ------------------------------------------------------------------------------
; Notes table
; ------------------------------------------------------------------------------
.segment "RODATA"
note_length_table:
	.byte	$01		; 32nd note
	.byte	$02		; 16th note
	.byte	$04		; 8th note
	.byte	$08		; Quarter note
	.byte	$10		; Half note
	.byte	$20		; Whole note

	; Dotted notes
	.byte	$03		; Dotted 16th note
	.byte	$06		; Dotted 8th note
	.byte	$0c		; Dotted quarter note
	.byte	$18		; Dotted half note
	.byte	$30		; Dotted whole note?

	; Other
	.byte	$07


; ------------------------------------------------------------------------------
; Notes length addresses
; ------------------------------------------------------------------------------
THIRTYSECOND  = $80
SIXTEENTH     = $81
EIGHTH        = $82
QUARTER       = $83
HALF          = $84
WHOLE         = $85
D_SIXTEENTH   = $86
D_EIGHTH      = $87
D_QUARTER     = $88
D_HALF        = $89
D_WHOLE       = $8A
T_QUARTER     = $8B