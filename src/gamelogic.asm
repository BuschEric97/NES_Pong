.define PADDLEMOVEFACTOR      #$02

.segment "ZEROPAGE"
    PADDLEMOVE: .res 1      ; #%0000BBAA (AA == paddle 0, BB == paddle 1 (for each: 00 == not move, 01 == move up, 10 == move down))

.segment "CODE"
reset_paddles_pos:
    lda #$64
    sta PADDLE0YPOS
    sta PADDLE1YPOS

    rts 

move_paddles:
    ;move_paddle_0:
    lda PADDLEMOVE
    and #%00000011
    beq move_paddle_1
        cmp #%00000010
        beq move_paddle_0_up
            ;move_paddle_0_down:
            lda PADDLE0YPOS
            sec 
            sbc PADDLEMOVEFACTOR
            sta PADDLE0YPOS
            jmp move_paddle_1
        move_paddle_0_up:
            lda PADDLE0YPOS
            clc 
            adc PADDLEMOVEFACTOR
            sta PADDLE0YPOS

    move_paddle_1:
        lda PADDLEMOVE
        and #%00001100
        beq done_move_paddles
            cmp #%00001000
            beq move_paddle_1_up
                ;move_paddle_1_down:
                lda PADDLE1YPOS
                sec 
                sbc PADDLEMOVEFACTOR
                sta PADDLE1YPOS
                jmp done_move_paddles
            move_paddle_1_up:
                lda PADDLE1YPOS
                clc 
                adc PADDLEMOVEFACTOR
                sta PADDLE1YPOS

    done_move_paddles:
    rts 