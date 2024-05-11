.segment "ZEROPAGE"

.segment "CODE"
reset_paddles_pos:
    lda #$64
    sta PADDLE0YPOS
    sta PADDLE1YPOS

    rts 