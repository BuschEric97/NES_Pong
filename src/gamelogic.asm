.define PADDLEMOVEFACTOR        #$02

.define PADDLEDEFAULTYPOS       #$64
.define BALLDEFAULTXPOS         #$7C
.define BALLDEFAULTYPOS         #$64

.segment "ZEROPAGE"
    PADDLEMOVE: .res 1      ; #%0000BBAA (AA == paddle 0, BB == paddle 1 (for each: 00 == not move, 01 == move up, 10 == move down))
    TEMPVEL: .res 1

.segment "CODE"
reset_paddles_pos:
    lda PADDLEDEFAULTYPOS
    sta PADDLE0YPOS
    sta PADDLE1YPOS

    rts 

reset_ball_pos:
    lda BALLDEFAULTXPOS
    sta BALLXPOS
    lda BALLDEFAULTYPOS
    sta BALLYPOS

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

move_ball:
    ;move_ball_x_pos:

    lda BALLXVEL
    bmi ball_x_dir_minus
        ;ball_x_dir_plus:
        lda BALLXPOS
        clc 
        adc BALLXVEL
        sta BALLXPOS
        jmp move_ball_y_pos
    ball_x_dir_minus:
        ; calculate and store absolute value of BALLXVEL
        lda BALLXVEL
        eor #%11111111
        clc 
        adc #1
        sta TEMPVEL

        lda BALLXPOS
        sec 
        sbc TEMPVEL
        sta BALLXPOS

    move_ball_y_pos:

    lda BALLYVEL
    bmi ball_y_dir_minus
        ;ball_y_dir_plus:
        lda BALLYPOS
        clc 
        adc BALLYVEL
        sta BALLYPOS
        jmp done_move_ball
    ball_y_dir_minus:
        ; calculate and store absolute value of BALLYVEL
        lda BALLYVEL
        eor #%11111111
        clc 
        adc #1
        sta TEMPVEL

        lda BALLYPOS
        sec 
        sbc TEMPVEL
        sta BALLYPOS

    done_move_ball:
    rts 