; ------------------------------------------------------------------------------
; The songs table
; ------------------------------------------------------------------------------
.include "songs.asm"


; ------------------------------------------------------------------------------
; APU control registers, constants and variables
; ------------------------------------------------------------------------------
; Channel index
SQUARE_1	= $00
SQUARE_2	= $01
TRIANGLE	= $02
NOISE		  = $03
; Channel mute value
MUTE_SQR_NOISE = $30
MUTE_TRIANGLE  = $80
; General registers
APU_STATUS            = $4015
; Square wave 1 channel
APU_SQ1_ENABLE_BIT    = (1 << 0)
APU_SQ1_PORTS_START   = $4000
APU_SQ1_VOLUME_CTRL   = $4000
APU_SQ1_SWEEP_CTRL    = $4001
APU_SQ1_FREQ_LOW      = $4002
APU_SQ1_FREQ_HIGH     = $4003
; Square wave 2 channel
APU_SQ2_ENABLE_BIT    = (1 << 1)
APU_SQ2_PORTS_START   = $4004
APU_SQ2_VOLUME_CTRL   = $4004
APU_SQ2_SWEEP_CTRL    = $4005
APU_SQ2_FREQ_LOW      = $4006
APU_SQ2_FREQ_HIGH     = $4007
; Triangle wave channel
APU_TRI_ENABLE_BIT    = (1 << 2)
APU_TRI_PORTS_START   = $4008
APU_TRI_LENGTH_CTRL   = $4008
APU_TRI_FREQ_LOW      = $400A
APU_TRI_FREQ_HIGH     = $400B
; Noise channel
APU_NOISE_ENABLE_BIT  = (1 << 3)
APU_NOISE_PORTS_START = $400C
APU_NOISE_VOLUME_CTRL = $400C
APU_NOISE_PERIOD_CTRL = $400E
APU_NOISE_LENGTH_HIGH = $400F

.segment "BSS"
; APU register buffers:
apu_register_buffers:
apu_sq1_register_buffer:   .res 4
apu_sq2_register_buffer:   .res 4
apu_tri_register_buffer:   .res 4
apu_noise_register_buffer: .res 4
; APU old square (1 & 2) period value
apu_sqr1_old_freq_high:     .res 1
apu_sqr2_old_freq_high:     .res 1


; ------------------------------------------------------------------------------
; Sound controller variables and constants
; ------------------------------------------------------------------------------
; Sound streams
MUSIC_SQ1 = $00
MUSIC_SQ2 = $01
MUSIC_TRI = $02
MUSIC_NOI = $03
SFX_1     = $04
SFX_2     = $05
.segment "BSS"
; Control flags
sound_enabled_flag: .res 1
sound_paused_flag:  .res 1
; Sound stream control variables
stream_current_sound:       .res 6    ; Current sound playing on the stream (song/sfx)
stream_status:              .res 6    ; The status of the stream (xxxxxxSE)
stream_used_channel:        .res 6    ; Current channel used by the stream
stream_vol_duty:            .res 6    ; The volume/duty control for the stream
stream_data_ptr_low:        .res 6    ; Low  byte of the pointer to the stream data
stream_data_ptr_high:       .res 6    ; High byte of the pointer to the stream data
stream_note_low:            .res 6    ; Low  8 bits byte of the current note
stream_note_high:           .res 6    ; High 3 bits byte of the current note
stream_tempo:               .res 6    ; The tempo of the stream (adds to ticker)
stream_ticker_total:        .res 6    ; The stream total ticker (counts time)
stream_note_length:         .res 6    ; The current used note length (refills the counter)
stream_note_length_counter: .res 6    ; The current note length counter (stops at 0)
; Sound loader variables
loading_song_number:        .res 1     ; The number of the loading song/sfx
loading_number_of_streams:  .res 1     ; The number of streams currently loading
fetching_temporary_y:       .res 1     ; A temporary variable to store y during the fetch
.segment "ZEROPAGE"
; Data pointers
current_sound_ptr:          .res 2
current_data_ptr:           .res 2


; ------------------------------------------------------------------------------
; Helper macros
; ------------------------------------------------------------------------------
.segment "CODE"
.macro readWordTable out_address, table_address, index
.scope
  ; Load index of the table
  .ifnblank index
    lda #index
  .endif
  asl a
  tay
  ; Put the lower byte of the table_address[index] into the out_address
  lda table_address, y
  sta out_address
  ; Put the higher byte of the table_address[index] into the out_address
  lda table_address+1, y
  sta out_address+1
.endscope
.endmacro


.macro loadSongNumber number
  pushRegisters
  lda #number
  jsr soundLoad
  pullRegisters
.endmacro


; ------------------------------------------------------------------------------
; Sound controller methods
; ------------------------------------------------------------------------------
soundInit:
  ; Enable all the channels (except DMC)
  lda #(APU_SQ1_ENABLE_BIT | APU_SQ2_ENABLE_BIT | APU_TRI_ENABLE_BIT | APU_NOISE_ENABLE_BIT)
  sta APU_STATUS

  ; Silence all the channels (sent to bufferred port)
  jsr silenceAllChannels

  ; Set the enabled bit to true
  lda #$01
  sta sound_enabled_flag

  ; Set the old value sent to the square port to an invalid note
  lda #$FF
  sta apu_sqr1_old_freq_high
  sta apu_sqr2_old_freq_high

  ; Put more initialization code here if needed
rts


silenceAllChannels:
  ; Mute all channels
  ; Square and noise channels
  lda #MUTE_SQR_NOISE
  sta apu_sq1_register_buffer
  sta apu_sq2_register_buffer
  sta apu_noise_register_buffer
  ; Triangle channels
  lda #MUTE_TRIANGLE
  sta apu_tri_register_buffer
rts


soundDisable:
  ; Disable all the channels
  lda #0
  sta APU_STATUS

  ; Set the enabled bit to false
  sta sound_enabled_flag

  ; Put more disabling code here if needed
rts


; Load the song/sfx with number stored at A
soundLoad:
  sta loading_song_number
  readWordTable current_sound_ptr, song_table

  ; Load all the data from the song header
  ldy #$00
  lda (current_sound_ptr), y      ; read the first byte: # streams
  sta loading_number_of_streams   ; store in a temp variable.  We will use this as a loop counter
  iny
  @loop:
    ; Load the current stream number
    lda (current_sound_ptr), y
    tax
    iny

    ; Check if the stream is enabled or disabled
    lda (current_sound_ptr), y
    sta stream_status, x
    beq @next_stream
      iny

      ; Load the channel used by the stream
      lda (current_sound_ptr), y
      sta stream_used_channel, x
      iny

      ; Load the initial duty cycle and volume settings
      lda (current_sound_ptr), y
      sta stream_vol_duty, x
      iny

      ; Load the address of the data stream
      lda (current_sound_ptr), y
      sta stream_data_ptr_low, x
      iny
      lda (current_sound_ptr), y
      sta stream_data_ptr_high, x
      iny

      ; Load the initial tempo
      lda (current_sound_ptr), y
      sta stream_tempo, x

      ; Put the length counter to 1 and the total tiker to FF,
      ; so the song is played imediately
      lda	#$FF
	    sta	stream_ticker_total, x
      lda #$01
      sta stream_note_length_counter, x
      sta stream_note_length, x
    @next_stream:
    iny

    ; Load the current sound number
    lda loading_song_number
    sta stream_current_sound, x

    ; Check if all the sound streams were loaded
    dec loading_number_of_streams
    bne @loop
rts


; Update the current song/sfx playing state
soundPlayFrame:
  ; Check if the sound is enabled
  lda sound_enabled_flag
  beq @end
    ; Silence all channels, so only the current playing
    ; channels are active
    jsr silenceAllChannels
    ; Update all streams
    ldx #$00
    @loop:
      ; Check whether the stream is active    
      lda stream_status, x
      and #$01
      beq @endLoop
        ; Add the tempo to the ticker total. If it overflows,
        ; we need to update the sound controller state
        lda stream_ticker_total, x
        clc
        adc stream_tempo, x
        sta stream_ticker_total, x
        bcc @setPortBuffer
          ; Decrement the note length counter, updating
          ; the controller state if it reaches 0
          dec stream_note_length_counter, x
          bne @setPortBuffer
            ; Refills the length counter and fetch the next stream data
            lda stream_note_length, x 
            sta stream_note_length_counter, x
            jsr fetchStreamData
        @setPortBuffer:
        ; Copy the current stream sound from the controll variables into
        ; port buffers
        jsr sendDataToBuffer
      @endLoop:
      inx
      cpx #$06
    bne @loop
    ; Send the data from the ports buffer to the actual APU port
    jsr sendDataToAPU
  @end:
rts


; Fetch the data of the current stream (loaded at X)
fetchStreamData:
  ; Copy the current stream data pointer into consecutives
  ; bytes to use in the load opcode
  lda	stream_data_ptr_low, x
  sta	current_data_ptr
  lda	stream_data_ptr_high, x
  sta	current_data_ptr + 1

  ldy	#$00
  @fetch:
    ; Load the current data fom the stream
    lda	(current_data_ptr), y
    ; Get what type of data we are reading
    bpl	@note		      ; If < #$80, it's a Note
    cmp	#$A0
    bcc	@note_length	; Else if < #$A0, it's a Note Length
    @opcode:			    ; Else it's an opcode
      ; Do Opcode stuff
      ; If the data was $FF, it's an end of stream so disable it and silence
      cmp	#$FF
      bne	@end
        ; Update the stream status, clear enable flag
        lda	stream_status, x
        and	#%11111110
        sta	stream_status, x
        ; Check witch channel this stream operates on and
        ; we are about to silence
        lda	stream_used_channel, x
        cmp	#TRIANGLE
        beq	@silenceTriangle
          lda	#MUTE_SQR_NOISE
          bne	@storeSilenceVolume
        @silenceTriangle:
          lda	#MUTE_TRIANGLE
        @storeSilenceVolume:
          ; Store the current silenced volume into the stream volume variable
          sta	stream_vol_duty, x ; Store silence value in the stream's volume
          jmp	@update_pointer	   ; Done
    @note_length:
      ; Do Note Length stuff
      ; Get the note length table index
      and	#%01111111
      ; Save Y
      sty	fetching_temporary_y
      ; Get the note length count value from the length table
      tay
      lda	note_length_table, y
      ; Store the note lenght in the stream variables
      sta	stream_note_length, x
      sta	stream_note_length_counter, x
      ; Restore Y
      ldy	fetching_temporary_y
      ; Fetch another byte for a new note
      iny
      jmp	@fetch
    @note:
      ; Do Note stuff
      ; Save Y
      sty	fetching_temporary_y	; Save our index into the data stream
      ; Load note into stream note variable
      asl	a
      tay
      lda	note_table, y
      sta	stream_note_low, x
      lda	note_table + 1, y
      sta	stream_note_high, x
      ; Restore Y
      ldy	fetching_temporary_y
      ; Process a rest note
      jsr	processRestNote
    @update_pointer:
      ; Advance the stream data pointer by the number of bytes read
      iny
      tya
      clc
      adc	stream_data_ptr_low, x
      sta	stream_data_ptr_low, x
      bcc	@end
        inc	stream_data_ptr_high, x
  @end:
rts


; Process a rest note (X := stream, Y := Data stream index)
processRestNote:
	lda	(current_data_ptr), y	; Read the note byte again
	cmp	#REST
	bne	@notRest
  @rest:
    lda	stream_status, x
    ora	#%00000010	; Set the rest bit in the status byte
    bne	@store		; This will always branch (cheaper than a jmp)
  @notRest:
    lda	stream_status, x
    and	#%11111101	; Clear the rest bit in the status byte
  @store:
	  sta	stream_status, x
rts

; Send data to the port buffers (X := stream)
sendDataToBuffer:
  ; Get the index of the current used channel port buffer 
  lda	stream_used_channel, x
	asl	a
	asl	a
	tay
	
	; Store the volume/duty cycle
	lda	stream_vol_duty, x
	sta	apu_register_buffers + 0, y

	; Store the sweep (always the same value)
  ; (not used for the noise and triangle)
	lda	#$08
	sta	apu_register_buffers + 1, y
	
	; Sotre the period low byte
	lda	stream_note_low, x
	sta	apu_register_buffers + 2, y
	
	; Sotre the period high 3 bits
	lda	stream_note_high, x
	sta	apu_register_buffers + 3, y

	; If the rest flag is set, silence the stream channel
	lda	stream_status, x
	and	#%00000010
	beq	@done
    lda	stream_used_channel, x
    cmp	#TRIANGLE
    beq	@silenceTriangle
      lda	#MUTE_SQR_NOISE
      bne	@storeSilence
    @silenceTriangle:
	    lda	#MUTE_TRIANGLE
    @storeSilence:
	    sta	apu_register_buffers + 0, y
  @done:
rts


sendDataToAPU:
  @square1:
    ; Write to the first 3 ports inconditionally
    .repeat 3, INDEX
      lda apu_sq1_register_buffer + INDEX
      sta APU_SQ1_PORTS_START + INDEX
    .endrep
    ; Only write to the last one if its value has changed
    lda apu_sq1_register_buffer + 3
    cmp apu_sqr1_old_freq_high
    beq @square2
      sta APU_SQ1_PORTS_START + 3
      sta apu_sqr1_old_freq_high
  @square2:
    ; Write to the first 3 ports inconditionally
    .repeat 3, INDEX
      lda apu_sq2_register_buffer + INDEX
      sta APU_SQ2_PORTS_START + INDEX
    .endrep
    ; Only write to the last one if its value has changed
    lda apu_sq2_register_buffer + 3
    cmp apu_sqr2_old_freq_high
    beq @triangle
      sta APU_SQ2_PORTS_START + 3
      sta apu_sqr2_old_freq_high
  @triangle:
    lda apu_tri_register_buffer + 0
    sta APU_TRI_PORTS_START + 0
    lda apu_tri_register_buffer + 2
    sta APU_TRI_PORTS_START + 2
    lda apu_tri_register_buffer + 3
    sta APU_TRI_PORTS_START + 3
  @noise:
    lda apu_noise_register_buffer + 0
    sta APU_NOISE_PORTS_START + 0
    lda apu_noise_register_buffer + 2
    sta APU_NOISE_PORTS_START + 2
    lda apu_noise_register_buffer + 3
    sta APU_NOISE_PORTS_START + 3
rts
