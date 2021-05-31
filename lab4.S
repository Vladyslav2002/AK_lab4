.global lab4
.syntax unified

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ 8103 = 1 1111 1010 0111
@ F = 2(X1 + not(X2) + X3) - 16(X4 + 1)
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#define X1 #-9
#define X2 #10
#define X3 #31
#define X4 #-21

#define MINUS #-1
#define PLUS #0


.section .text
lab4:
    push {lr}
    bl task1
    bl task2
    pop {pc}

task1:
    push {lr}

    mov r0, X4          @ Виділяємо 2 регістри
    mov r1, MINUS


    adds r0, #1         @ X4 + 1
    adc r1, #0

    lsl r1, #1
    lsls r0, #1
    lsl r1, #1
    lsls r0, #1
    lsl r1, #1
    lsls r0, #1
    lsl r1, #1
    lsls r0, #1         @ r1:r0 = 16(X4 + 1)

    mov r2, X2
    mov r3, PLUS
    mvn r2, r2
    mvn r3, r3          @ not(X2)

    mov r4, X3
    mov r5, PLUS

    adds r2, r4         @ r3:r2 = not(X2) + X3
    adc r3, r5

    mov r4, X1
    mov r5, MINUS

    adds r2, r4         @ r3:r2 = X1 + not(X2) + X3
    add r3, r5


    lsls r2, #1
    lsl r3, #1          @ r3:r2 = 2(X1 + not(X2) + X3)

    subs r0, r2, r0
    sbc r1, r3, r1      @ r1:r0 2(X1 + not(X2) + X3) - 16(X4 + 1)

    bl step1
    pop {pc}

@ Result correction:
step1:
	push {lr}
	bvc step2

	mov r8, 0
	lsrs r1, #1
	adc r8, 0
	lsl r8, 31
	lsr r0, #1
	orr r0, r8

step2:
	orr r0, #0 // check if 0
	bne step4 // if != 0 go to step4

step3:
	mov r1, #0b1111110100111

step4:
	mov r8, #0b1111110100111
	add r0, r8

step5:
	and r3, r1, #0b10000000000000000000000000000000
	and r4, r1, #0b01000000000000000000000000000000
	lsl r4, #1
	cmp r3, r4
	beq step7

step6:
	mov r8, 0
	lsrs r1, #1
	adc r8, 0
	lsl r8, 31
	lsr r0, #1
	orr r0, r8

step7:
	bvs end_check_result
	push {r0}
	push {r1}
	pop {r1}
	pop {r0}

end_check_result:
	pop {pc}


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Точка переходу на підпрограму II
@ Точка переходу на підпрограму XII
@ Умови переходу C=1, N=0, V=0
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#define N1 #5
#define N2 #2

task2:
    push {lr}
    mov r0, N1
    mov r1, N2

    mul r2, r0, r1          @ s1 r2 = r0 * r1
    udiv r1, r2, r0         @ s2 r1 = r2 / r0

jump_to_step_3:
    adds r1, r1, r2         @ s3 r1 = r1 + r2
    IT CS                   @ s4 if C=1 go to @6 else (@5 and @7)
    bCS jump_to_step_6

    add r2, r1, #33         @ s5 r2 = r1 + 33
    adds r3, r3, #80        @ s7 r3 = r3 + 80
    b jump_to_step_8

jump_to_step_6:
    adds r3, r2, r3         @ s6 r3 = r2 + r3

jump_to_step_8:
    IT VC                   @ s8 if V=1 go to s9 else to s10
    bVC jump_to_step_10
    @ 9 r2 = not r0
    mvn r2, r0
    pop {pc}

jump_to_step_10:
    push {lr}

    lsr r3, r2              @ s10 r3 = r3 >> r2
    IT MI                   @ s11 if N=0 go to s12 else s13
    bMI jump_to_step_13     @ s12 r1 = 5 - r3

    rsbs r1, r3, #5

jump_to_step_13:
    IT CS                   @ s13 if C=1 go to s17 else to s14
    bCS jump_to_step_17

    mul r2, r1, r1          @ s14 r2 = r1 * r1
    sub r0, r2, r1          @ s15 r0 = r2 - r1
    pop {pc}

jump_to_step_17:
    push {lr}
    add r2, r1, #2          @ s17 r2 = r1+2
    sub r1, r1, r2          @ s18 r1 = r1 - r2
    pop {pc}
