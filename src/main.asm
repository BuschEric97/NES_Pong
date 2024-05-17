.segment "IMG"
    .incbin "rom.chr"

.segment "ZEROPAGE"
    GAMEFLAG: .res 1    ; #%00000WWG (WW == win flag (00 == no winner, 01 == P1 winner, 10 == P2 winner), G == game flag)
    PADDLE0YPOS: .res 1
    PADDLE1YPOS: .res 1
    BALLXPOS: .res 1
    BALLYPOS: .res 1

.segment "VARS"

.include "header.asm"
.include "utils.asm"
.include "gamepad.asm"
.include "ppu.asm"
.include "palette.asm"

.include "drawing.asm"
.include "gamelogic.asm"

.include "title.asm"
.include "nmi.asm"
.include "irq.asm"
.include "reset.asm"

.segment "CODE"
game_loop:
    lda nmi_ready
    bne game_loop

    ; get gamepad inputs
    jsr set_gamepads

    lda GAMEFLAG
    and #%00000001
    bne run_main_game
        ;run_title_screen:
        jsr title_screen_game
        jmp game_loop
    run_main_game:
        jsr main_game

    ; return to start of game loop
    jmp game_loop

; this subroutine is called when GAMEFLAG G bit is 0
title_screen_game:
    ; handle START button press on controller port 0
    lda gamepad_new_press
    and PRESS_START
    cmp PRESS_START
    bne title_start_not_pressed
        lda #%00000001
        sta GAMEFLAG    ; set GAMEFLAG to 1 to indicate a game is being played

        jsr clear_background
        jsr reset_paddles_pos
        jsr reset_ball_pos
    title_start_not_pressed:

    rts 

; this subroutine is called when GAMEFLAG G bit is 1
main_game:
    ; get paddle movements from both gamepads
    lda gamepad_press
    and #%00110000      ; isolate gamepad up and gamepad down
    lsr 
    lsr 
    lsr 
    lsr                 ; shift isolated gamepad input to PADDLEMOVE AA
    sta PADDLEMOVE
    lda gamepad_press+1
    and #%00110000      ; isolate gamepad up and gamepad down
    lsr 
    lsr                 ; shift isolated gamepad input to PADDLEMOVE BB
    ora PADDLEMOVE
    sta PADDLEMOVE
    ; move the paddles according to paddle movements
    jsr move_paddles

    ; draw the paddles and ball every frame
    jsr draw_game_pieces

    rts 