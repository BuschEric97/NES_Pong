.define PADDLE0XPOS     #$08
.define PADDLE1XPOS     #$F0

.segment "ZEROPAGE"

.segment "CODE"
draw_sprites:
    jsr wait_for_vblank

    ; draw all sprites to screen
    lda #$02
    sta $4014

    rts 

draw_game_pieces:
    jsr draw_paddles
    jsr draw_ball
    jsr draw_sprites

    rts 

draw_paddles:
    lda PADDLE0YPOS
    sta $0204           ; paddle 0 sprite 0 - y pos
    clc 
    adc #$08
    sta $0208           ; paddle 0 sprite 1 - y pos
    clc 
    adc #$08
    sta $020C           ; paddle 0 sprite 2 - y pos
    clc 
    adc #$08
    sta $0210           ; paddle 0 sprite 3 - y pos
    lda PADDLE1YPOS
    sta $0214           ; paddle 1 sprite 0 - y pos
    clc 
    adc #$08
    sta $0218           ; paddle 1 sprite 1 - y pos
    clc 
    adc #$08
    sta $021C           ; paddle 1 sprite 2 - y pos
    clc 
    adc #$08
    sta $0220           ; paddle 1 sprite 3 - y pos

    lda #$01            ; all paddles sprites are tile #$01
    sta $0205
    sta $0209
    sta $020D
    sta $0211
    sta $0215
    sta $0219
    sta $021D
    sta $0221

    lda #%00000000      ; paddle 0 attributes are all 0
    sta $0206
    sta $020A
    sta $020E
    sta $0212
    lda #%01000000      ; paddle 1 sprites are mirrored horizontally
    sta $0216
    sta $021A
    sta $021E
    sta $0222

    lda PADDLE0XPOS     ; all paddle 0 sprites at same x pos
    sta $0207
    sta $020B
    sta $020F
    sta $0213
    lda PADDLE1XPOS     ; all paddle 1 sprites at same x pos
    sta $0217
    sta $021B
    sta $021F
    sta $0223

    rts 

draw_ball:
    lda BALLYPOS
    sta $0200

    lda #$00
    sta $0201

    lda #%00000000
    sta $0202

    lda BALLXPOS
    sta $0203

    rts 

clear_background:
    jsr wait_for_vblank

    ; disable sprites and background rendering
    lda #%00000000
    sta $2001

    lda $2002               ; read PPU status to reset the high/low latch
    lda #$20
    sta $2006               ; write the high byte of $2000 address
    lda #$00
    sta $2006               ; write the low byte of $2000 address
    ldx #$00                ; start out at 0
    load_background_clear_loop_0:
        lda #$FF
        sta $2007               ; write to PPU
        inx                     ; increment x by 1
        cpx #$00                ; compare x to hex $00 - copying 256 bytes
        bne load_background_clear_loop_0
    load_background_clear_loop_1:     ; loop for 2nd set of background data
        lda #$FF
        sta $2007
        inx 
        cpx #$00
        bne load_background_clear_loop_1
    load_background_clear_loop_2:     ; loop for 3rd set of background data
        lda #$FF
        sta $2007
        inx 
        cpx #$00
        bne load_background_clear_loop_2
    load_background_clear_loop_3:     ; loop for 4th set of background data
        lda #$FF
        sta $2007
        inx 
        cpx #$C0
        bne load_background_clear_loop_3

    ; enable sprites and background rendering
    lda #%00011110
    sta $2001

    ; reset scrolling
    lda #$00
    sta $2005
    sta $2005

    rts 