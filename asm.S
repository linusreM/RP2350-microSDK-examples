.section .text

.equ ATOMIC_XOR,	0x1000
.equ ATOMIC_SET,	0x2000
.equ ATOMIC_CLEAR,	0x3000

.equ RESETS_BASE,			0x40020000
.equ RESETS_RESET,			RESETS_BASE+0x0
.equ RESETS_RESET_DONE,		RESETS_BASE+0x8

.equ IO_BANK0_BASE,			0x40028000
.equ IO_BANK0_GPIO25_CTRL,	IO_BANK0_BASE+0x0cc

.equ PADS_BANK0_BASE,		0x40038000
.equ PADS_BANK0_GPIO25,		PADS_BANK0_BASE+0x68

.equ SIO_BASE,				0xd0000000
.equ SIO_GPIO_OE_SET,		SIO_BASE+0x038
.equ SIO_GPIO_OUT_SET,		SIO_BASE+0x018
.equ SIO_GPIO_OUT_CLR,		SIO_BASE+0x020
.equ GPIO_OUT_SET,			0x18
.equ GPIO_OUT_CLR,			0x20
.equ GPIO_IN,			0x4

.equ TIMER0_BASE,		0x400b0000
.equ TIMER0_TIMEHR,		TIMER0_BASE+0x08
.equ TIMER0_TIMELR,		TIMER0_BASE+0x0c
.equ TIMER0_TIMERAWH,	TIMER0_BASE+0x24
.equ TIMER0_TIMERAWL,	TIMER0_BASE+0x28

.global main
main:

	#Outputs
	li		a1, 1
	li		a0, 0
	call	config_gpio
	li		a1, 1
	li		a0, 1
	call	config_gpio
	li		a1, 1
	li		a0, 2
	call	config_gpio
	li		a1, 1
	li		a0, 3
	call	config_gpio
	li		a1, 1
	li		a0, 4
	call	config_gpio
	li		a1, 1
	li		a0, 5
	call	config_gpio
	li		a1, 1
	li		a0, 6
	call	config_gpio
	li		a1, 1
	li		a0, 7
	call	config_gpio
	li		a1, 1
	li		a0, 8
	call	config_gpio
	li		a1, 1
	li		a0, 9
	call	config_gpio
	li		a1, 1
	li		a0, 10
	call	config_gpio

	#Inputs
	li		a1, 0
	li		a0, 21
	call	config_gpio
	li		a1, 0
	li		a0, 22
	call	config_gpio
	li		a1, 0
	li		a0, 23
	call	config_gpio
	li		a1, 0
	li		a0, 24
	call	config_gpio

    
    //Load first display data
    li a1, 0
    la  a0, display_data_base + 8
    la  a2, row_data
    call copy_data_to_rows

    j input_loop


input_loop:
    call    increment_row
    mv      a1, a0
    la      a0, row_data
    call    display_row    
    j input_loop 
    


increment_row:
    la a1, current_row
    lw a0, (a1)
    addi a0, a0, 1
    andi a0, a0, 0x7
    sw a0, (a1)
    ret

copy_data_to_rows:
#copy_data_to_rows(*base, offset, *data)
    slli a1, a1, 3
    add a0, a1, a0
    lw t0, (a0)
    sw t0, (a2)
    lw t0, 4(a0)
    sw t0, 4(a2)
    ret


display_row:
    #display_row(*base, row)
    addi sp, sp, -4
    sw ra, (sp)
    li		t0, 0x7FF
	li		t1, SIO_BASE
	li		t3, 0
    add a0, a1, a0
    lb a0, (a0)
	slli a0, a0, 3
	or a0, a1, a0
	call	rearrange_bits
	xor		a0, a0, t0
	sw		a0, GPIO_OUT_CLR(t1)
	xor		a0, a0, t0
	sw		a0, GPIO_OUT_SET(t1)
	li		a0, 0

    lw ra, (sp)
    addi sp, sp, 4
    ret

config_gpio:
	li		t0, 0x1f 
	li		t1, IO_BANK0_BASE+ATOMIC_CLEAR
	slli	t2, a0, 3
	addi	t2, t2, 4
	add		t1, t1, t2
	sw		t0, (t1)

	li		t0, 0x05 
	li		t1, IO_BANK0_BASE+ATOMIC_SET
	add		t1, t1, t2
	sw		t0, (t1)

	beqz	a1, 1f
	li		t0, 1
	sll		t0, t0, a0
	li		t1, SIO_GPIO_OE_SET
	sw		t0, (t1)
1:
	li		t0,  (1<<7)|(1<<8)
	li		t1, PADS_BANK0_BASE+ATOMIC_CLEAR
	slli	t2, a0, 2
	addi	t2, t2, 4
	add		t1, t1, t2
	sw		t0, (t1)
	li		t0,  (1<<6)
	li		t1, PADS_BANK0_BASE+ATOMIC_SET
	slli	t2, a0, 2
	addi	t2, t2, 4
	add		t1, t1, t2
	sw		t0, (t1)
	ret


# Don't use with durations longer than 1 hour.
wait_ms:
	mv		a2, a0				//ms into a2
	li		a0, TIMER0_TIMELR   //TIMER0 low bits
	li		a1, TIMER0_TIMEHR	//TIMER0 high bits
	lw		a0, (a0)			//a0 = TIMER0 low bits			
	lw		a1, (a1)			//a1 = TIMER0 high bits
	li		a3, 1000			//a3 = 1000
	mul		a2, a2, a3			//a2 = ms * 1000 = us
	add		a0, a0, a2			//a0 = TIMER0 low + us
	sltu	a3, a0, a2			//if TIMER0 low bits + us < us (overflow?)
	add		a1, a1, a3			//TIMER0 high bits += 1
	li		a2, TIMER0_TIMERAWL	//
	li		a3, TIMER0_TIMERAWH
1:
	lw		a5, (a3)			//load TIMER0 high bits
	blt		a5, a1, 1b			//if current TIMER0H < old TIMER0H+us spin
2:
	lw		a5, (a3)			//load high bits
	bne		a5, a1, 3f			//if not equal finish
	lw		a4, (a2)			//load low bits
	blt		a4, a0, 2b			//if timer low is less than TIMER0+us spin
3:
	ret

rearrange_bits:
	#clear bits to rearrange
	andi t6, a0, 0x3f
	#Move bit 6 to position 10
	bexti t5, a0, 6
	slli t5, t5, 10
	or t6, t6, t5
	#Move bit 7 to position 9
	bexti t5, a0, 7
	slli t5, t5, 9
	or t6, t6, t5
	# b8 -> 6
	bexti t5, a0, 8
	slli t5, t5, 6
	or t6, t6, t5
	# b9 -> 8
	bexti t5, a0, 9
	slli t5, t5, 8
	or t6, t6, t5
	# b10 -> 7
	bexti t5, a0, 10
	slli t5, t5, 7
	or t6, t6, t5

	mv a0, t6
	ret


	.section .data
	display_data_base:
.byte 0b01111110,0b11111111,0b11100111,0b11100111,0b11100111,0b11100111,0b11111111,0b01111110
.byte 0b00011100,0b00111100,0b01111100,0b00011100,0b00011100,0b00011100,0b00111110,0b00111110
.byte 0b01111110,0b11111111,0b11100111,0b00011100,0b00111000,0b01110000,0b11111111,0b11111111
.byte 0b11111110,0b11111111,0b00000111,0b00011110,0b00011110,0b00000111,0b11111111,0b11111110
.byte 0b11101110,0b11101110,0b11101110,0b11111110,0b11111110,0b00001110,0b00001110,0b00001110
.byte 0b11111111,0b11111111,0b11100000,0b11111110,0b11111111,0b00000111,0b11111111,0b11111110
.byte 0b00001110,0b00011100,0b00111000,0b01111110,0b11111111,0b11100111,0b11111111,0b01111110
.byte 0b11111111,0b11111111,0b00000111,0b00000111,0b00001110,0b00011100,0b00111000,0b01110000
.byte 0b01111110,0b11111111,0b11100111,0b01111110,0b11100111,0b11100111,0b11111111,0b01111110
.byte 0b01111110,0b11111111,0b11100111,0b11111111,0b01111111,0b00000111,0b11111111,0b11111110
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0b01111110,0b11111111,0b11100111,0b11111111,0b11111111,0b11100111,0b11100111,0b11100111
.byte 0b11111100,0b11111110,0b11100111,0b11111110,0b11111100,0b11111110,0b11100111,0b11111110
.byte 0b00111100,0b01111110,0b11100111,0b11100000,0b11100000,0b11100111,0b01111110,0b00111100
.byte 0b11111100,0b11111110,0b11100111,0b11100111,0b11100111,0b11100111,0b11111110,0b11111100
.byte 0b00111100,0b01111110,0b11111111,0b11111111,0b11111111,0b11111111,0b01111110,0b00111100
.byte 0b01100110,0b11111111,0b11111111,0b01100110,0b01100110,0b11111111,0b11111111,0b01100110

current_row:
.word 0
row_data:
.zero 8
current_data:
.word 0

