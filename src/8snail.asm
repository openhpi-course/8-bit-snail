	;;
	;; 8-BIT SNAIL
	;; A PROD FOR VECTOR-06C
	;; BY SVO, ST PETERSBURG 2009
	;;
	;; player/kvaz version
	;; 

dlist_length			equ 0x400	; display list length
dlist_lengthw			equ 0x200	; display list length in words

clist_length			equ 0x200     

displaylist_shorterby		equ 56		; display list length is 256-displaylist_shorterby

mp_loopcount			equ 4b8h	; this many frames in the main part
;mp_loopcount			equ 40h

snail_wasteland			equ 7f00h	; scratchpad for the snail clipping, 256 bytes

text_fadein_time		equ 48		; outro texts are displayed for this long, 16 of which is fade-in
text_pause_time			equ 16		; pause for this, then shake it away

playerdst			equ 0xa000	; music player gets relocated here


rastint				equ 38h

	.org 100h
	di
	jmp begin
msg:
	db '8-BIT SNAIL BY SVO, 2009',0dh,0ah,'$'
	db 27
begin:
	xra a
	out 10h

	mvi a, 0c3h 
	sta 38h
	mvi a, 0c3h
	sta 0
	lxi h, begin
	shld 1

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; PHASE 1
	;; Roll display and clear the screen
	;;
	lxi sp, $100

	mvi a, 0
	sta scroll
	sta phase1+1
	xra a
	sta ii_line
	lxi h, intr_intro
	shld $39
ph1loop:
	ei
	hlt
phase1:
	mvi a,1
	ora a
	jnz ph1loop

	; move player to $a000
	call relocate_player

	; init player
	mvi a, 0x20
	out 10h
	lxi h, 0xabfc
	call 0xa000
	xra a
	out 10h
	;

	; invoke outro sequencer to display our warning
	; after the sequence is over, it will jump to back to switch_to_phase2
	jmp intromessage

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; PHASE 2
	;; 
	;; Prepare colour list
	;; Display gorilla
	;; Display marching checkers
	;; Relocate music player + music to playerdst
	;; Init player
	;; Load the snail
	;; Init string pointer
	;; Install phase2 interrupt
	;; Loop until it's over
switch_to_phase2:
	;; let the outro interrupt tick once 
	;; to set the palette 
	ei
	hlt

	lxi h, inth
	shld 39h

	lxi sp, 100h
	call prepare_colorlist
	call init_dlist_sub
	call prepare_message_sub

	; display the gorilla
	lxi d, 0xe000
	lxi h, gorilla_0
	shld gorilla_src_ptr
	lxi h, gorilla_columns*256 + gorilla_rows
	shld gorilla_dimension
	lxi h, 256*19-18 ;64
	shld gorilla_origin
	call display_gorilla_sub

	lxi h, 256*20-18 ;64
	shld gorilla_origin
	lxi d, 0xc000
	lxi h, gorilla_0
	shld gorilla_src_ptr
	call display_gorilla_sub

	call display_checkers_sub

	; init snails
	xra a
	sta snail_idx
	;mvi a, 31
	mvi a, 63
	sta snail_column

	; init loop count
	lxi h, mp_loopcount ;$4b0
	shld loopctr

	; init first string
	lxi h, txtmsg_0
	shld txtmsg_ptr
	lxi de, $1238
	call js_load_sub

	; init time
	xra a
	sta txtmsg_time


	jmp eternal_loop

	; relocate the player+music
relocate_player:	
	; select ramdisk @ 0xa000-0xdfff
	mvi a, 0x20
	out 10h
	lxi d, playersrc
	lxi h, playerdst
	lxi b, 0x2000
moveplr:ldax d
	mov m,a
	inx d
	inx h
	dcx b
	mov a, b
	ora c
	jnz moveplr
	xra a
	out 10h	       
	; it won't be there for the second time
	mvi a, $c9
	sta relocate_player
	ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; MAIN PART LOOP
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
eternal_loop:
	; increment loop counter
	lhld loopctr
	dcx h
	shld loopctr
	mov a, h	
	ora l
	jz endgame

	; update hardware scroll
	mvi a, 255
	sta scroll

	; display a string every once in a while
	lda txtmsg_time
	ora a
	jz el_advance_load
	dcr a
	sta txtmsg_time
	jmp el_01

	; message advance
el_advance_load:
	lhld txtmsg_ptr
	inx h
	mov a,m
	inx h
	sta txtmsg_time
	mov e,m
	inx h
	mov d,m
	inx h
	mov a, d
	ora e
	jz el_03
	call js_load_sub
	jmp el_03

el_01:	      
	call js_jiffy_sub
	; test if the message is over and re-display it in another layer
	ora a
	jnz el_03
	lhld dss_ptr	    ;store the pointer to the EOM
	shld txtmsg_ptr	       
el_03:

prepare_list:
	; prepare display list
	di

	; dlist_length == 0x400
	;
	; 1. dlist_ofs++
	; 2. if (dlist_ofs >= dlist_length-256) dlist_ofs = dlist_length-256
	; 3. dlist_ptr = dlist + dlist_ofs
	; 4. *dlist_saved_ptr = dlist_saved
	; 5. dlist_saved_ptr = dlist_ptr + 256
	; 4. dlist_saved = *dlist_saved_ptr
	; 4. *dlist_saved_ptr = dlist_terminator

	lhld dlist_ofs
scrl_0: lxi d, 8
	dad d
	mov a, h
	cpi dlist_length - 256 >> 8
	jnz scrl_aa

	lxi h, 0xfff8
	shld scrl_0+1
	lxi h, dlist_length - 256
	jmp scrl_a

scrl_aa:
	cpi 0xff
	jnz scrl_a
	lxi h, 8
	shld scrl_0+1
	lxi h, 0
	
scrl_a: shld dlist_ofs
	; 
	; dlist_ofs done
	;

	; dlist_ptr = dlist + dlist_ofs
	xchg
	lxi h, dlist0
	dad d
	shld dlist_ptr

	; *dlist_saved_ptr = dlist_saved_piece
	lhld dlist_saved_ptr
	shld scrl_b+1
	lhld dlist_saved_piece
scrl_b: shld 0

	; dlist_saved_ptr = dlist_ptr + 256 - 2
	lhld dlist_ptr
	lxi d, 256 - displaylist_shorterby
	dad d
	shld dlist_saved_ptr
	shld scrl_c+1
	shld scrl_d+1
scrl_c: lhld 0 ; hl = saved piece
	; dlist_saved = *dlist_saved_ptr
	shld dlist_saved_piece

	; store terminator	  
	lxi h, dlist_terminator
scrl_d: shld 0

	; all doneski!

display_list_prepared:

	; enable full interrupt
	mvi a, 0c3h 
	sta 38h

	; ready to rock
	lxi sp, 100h

	ei
	hlt

	; player
	mvi a, 0x20
	out 10h
	call 0xa006
	call 0xa003
	xra a
	out 10h

	; loop the palette
	lda loopctr
	ani 1
	jz skip_palette_loop

	lxi b, palette_loop4
	lxi d, palette_loop4+1
	ldax b
	mov h,a
	mvi l, 3
lpal1:
	ldax d
	stax b
	inx b
	inx d
	dcr l
	jnz lpal1
	mov a, h
	stax b
skip_palette_loop:

	; roll snails
	lda loopctr
	ani 3
	jnz snail_samecolumn

	lxi h, snail_idx
	mov a, m
	inr a
	ani 3
	mov m, a
	jnz snail_samecolumn
	lxi h, snail_column
	dcr m
	mov a, m
	cpi $f4
	jnz snail_samecolumn
	mvi m, 31
snail_samecolumn:

	jmp eternal_loop

	;; outro_tptr points to a sequence of "jiffy" routines
	;; each routine must take care of its own execution time
	;; after the outro scheduler counts outro_time down to 0,
	;; it selects the next routine in list.
	;;
	;; null pointer stops the sequence, after which scheduler dies.
	;; a pointer to a non-returning subroutine can be used to
	;; switch between parts.
outro_time:
	db 0
outro_tptr:
	dw 0
outro_table: 
	dw outro_cxoff, outro_empty, outro_pause
	dw outro_still, outro_musicby, outro_cxon, outro_fadein, outro_wave, outro_pause, ;outro_clrscr2, 
	dw outro_codeby,  outro_still, outro_fadein, outro_wave, outro_pause, ;outro_clrscr2, 
	dw outro_v06c,	  outro_still, outro_fadein, outro_wave, outro_fadeout, 
	dw outro_cxoff, outro_empty, outro_pause, outro_clrscr2, 
	dw outro_snail, outro_gruu, outro_fadein, 0
	
intro_table:
	dw outro_empty, intro_warning, outro_fadein, outro_fadeout
	dw outro_clrscr, intro_switch_to_main

	;; same as endgame except that the sequence jumps to the main part
intromessage:
	xra a
	sta checkers_active+1
	lxi h, intro_table-2
	jmp endgame2
	
endgame:
	; player
	mvi a, 0x20
	out 10h
	call 0xa00c
	xra a
	out 10h

	lxi h, intr_plain
	shld $39
	call outro_init_palette_sub
	ei 
	hlt

	lxi h, outro_table-2
endgame2:
	shld outro_tptr
	call checkers_init
	call clrscr_sub	       
	mvi a, 1
	sta outro_time
	jmp chx_loop
demo_end:
	; chill
	di
	hlt
	
intro_switch_to_main:
	call clrscr_sub
	call outro_init_palette_sub
	jmp switch_to_phase2

outro_init_palette_sub:
	; init palette
	lxi h, palette_outro
	lxi b, $1000
	mov m, c
	inx h
	dcr b
	jnz $-3
	ret

outro_cxoff:
	mvi a, 1
	sta outro_time
	xra a
	sta checkers_active+1
	ret

outro_cxon:
	mvi a, 1
	sta outro_time
	ori 1
	sta checkers_active+1
	ret

outro_clrscr:
	call clrscr_sub
	mvi a, 1
	sta outro_time
	ret

oclrssp: dw 0

outro_clrscr2:
	lxi h, outro_time
	mvi m, 1
outro_clrscr2a:
	lxi h, 0
	dad sp 
	shld oclrssp

	lxi h, $e09a

	lxi b, $2003
	lxi d, $0000
	sphl
ocr2:
	push d
	push d
	push d
	push d
	push d
	push d
	push d
	push d
	dcr c
	jnz ocr2

	mvi c, $03
	dcr b
	jz ocrlexit

	lxi h, 256+48
	dad sp
	sphl

	jmp ocr2
ocrlexit:
	lhld oclrssp
	sphl
	ret	   

outro_empty:
	lxi h, outro_msg_empty
	shld outrotxt_ptr+1
	jmp outro_textshow

outro_pause:
	lxi h, outro_time
	mov a,m
	ora a
	jnz opau1
	; init our time
	mvi m, text_pause_time
opau1:
	ret
	

outro_wave:
	mvi a, 1
	sta outro_time
	jmp chx_wave
	
outro_still:
	mvi a, 1
	sta outro_time
	jmp chx_still


outro_musicby:
	lxi h, outro_msg_musicby
	shld outrotxt_ptr+1
	jmp outro_textshow

outro_codeby:
	call outro_clrscr2a
	lxi h, outro_msg_codeby
	shld outrotxt_ptr+1
	jmp outro_textshow

outro_v06c:
	call outro_clrscr2a
	lxi h, outro_msg_v06c
	shld outrotxt_ptr+1
	jmp outro_textshow


outro_snail:
	lxi h, outro_msg_snail
	shld outrotxt_ptr+1
	jmp outro_textshow

intro_warning:
	lxi h, intro_msg_warning
	shld outrotxt_ptr+1
	jmp outro_textshow
	
outro_gruu:
	lxi h, $e964
	lxi b, $0d26
	
	mvi d, $ff
	
og0:	    mov m, d
	dcr l
	dcr c
	jnz og0
	
	mvi c, $26
	dcr b
	jz og1
	
	mov a, c
	add l
	mov l, a
	inr h
	jmp og0

og1:
	lxi h, $0a60
	shld gorilla_origin
	lxi d, 0xe000
	lxi h, snail_c_0
	shld gorilla_src_ptr
	lxi h, 0x0b1e	     ; 11 columns, 30 lines
	shld gorilla_dimension
	call display_gorilla_sub

	mvi a, 1
	sta outro_time
	ret

outro_textshow: 
	lxi h, outro_time
	mov a,m
	ora a
	jnz outro_1_proc
	; init our time
	mvi m, 2
	cma
	sta o1tst+1

	call outro_init_palette_sub

	; first jiffy - lights out
	ret

outro_1_proc:
o1tst:
	mvi a, 1
	ora a
	rz

	xra a
	sta o1tst+1

	; output text to $e000 layer
	lxi h, $e000
	shld text_layer+1

outrotxt_ptr:
	lxi h, 0
	call out_at_hl
	;
	lhld dss_ptr
	inx h
	shld outrotxt_ptr+1
	mov a, m
	ora a
	jnz outrotxt_ptr

	ret

out_at_hl:
	mov e, m
	inx h
	mov d, m
	inx h
	call js_load_sub
oahl1:
	call js_jiffy_nolayerflip_sub
	ora a
	jnz oahl1
	ret

outro_fadein:
	; fade in
	lxi h, outro_time
	mov a,m
	ora a
	jnz outro_fi_proc
	; init our time
	mvi m, text_fadein_time
	ret

outro_fi_proc:	      
	lda outro_time
	cpi text_fadein_time-7
	rm 
	ani $1
	rnz
	lxi h, palette_outro+1
	mvi a, $52
	add m
	mov m, a
	ret

outro_fadeout:
	; fade out
	lxi h, outro_time
	mov a,m
	ora a
	jnz outro_fo_proc
	; init our time
	mvi m, 16
	ret

outro_fo_proc:	      
	ani $3
	rnz
	lxi h, palette_outro+1
	mov a, m
	sui $52
	mov m, a
	ret

	; de = layer address (0x8000 etc)
display_gorilla_sub:
	; store dimension
	lhld gorilla_dimension
	shld dg_0a+1

	mov a, l
	sta dg_b+1

	lhld gorilla_origin
	dad d
	xchg
	lhld gorilla_src_ptr
dg_0a:	      
	lxi b, 0000h
dg_a:
	mov a,m
	inx h
	xchg
	mov m,a
	dcr l
	xchg
	
	dcr c
	jnz dg_a

	lda dg_0a+1
	mov c,a
	
	; next column
	inr d
dg_b:	     
	mvi a, 0
	add e
	mov e, a
	
	dcr b
	jnz dg_a

	ret
	
snail_ncolumns		equ 11
snail_top		equ 30
snail_column		db 0
snail_columnx		db 0
snail_idx		db 0
snail_array		dw snail_a_0, snail_b_0, snail_c_0, snail_d_0

	;;;;;;;;;;;;;;;;;;;;;;;;
	;; DISPLAY SNAIL
	;;;;;;;;;;;;;;;;;;;;;;;;
	;;
	;; The snail lives in layer $a000
	;; Its dimensions are 88x30, or 11 columns of 15 words
	;; The source of snail is passed in snail_src_ptr
	;; The column is in snail_column, the sprite is clipped within 
	;; reasonable limits.
	;; Each invocation takes exactly the same time.
	;; For clipping waste, 256 bytes at $7f00-$7fff is used.
snail_display_sub:
	lxi h, 0
	dad sp
	shld savedsp

	lda snail_idx
	ral
	mov l,a
	mvi h,0
	lxi d, snail_array
	dad d
	shld sds_loadsrc+1
sds_loadsrc:
	lhld 0
	sphl

	; calculate screen address (top-left)
	mvi e, snail_top
	lxi h, $a000
	lda snail_column
	sta snail_columnx
	mov d, a
	dad d

	lxi d, snail_wasteland

	mvi a, snail_ncolumns
	sta sds_colctr+1
sds_column:
	; test real column number
	lxi b, snail_columnx
	ldax b
	ani $e0 ; $20	     
	jz no_switch_dst
	mvi a, $eb ; xchg
	jmp sds_lala	    
no_switch_dst:	      
	mvi a, $00 ; nop
	jmp sds_lala
sds_lala:
	sta sds_sw0
	sta sds_sw1
	;
snail_columni:
	ldax b
	inr a
	stax b
	
	; 
sds_sw0: nop
	;
	
	; (1) move 2 bytes to screen 
	pop b
	mov m, c
	dcr l
	mov m, b
	dcr l
	; do that 14 more times for the total of 15 words
	; which adds up to 30 lines
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d
	db $c1,$71,$2d,$70,$2d

	;
sds_sw1:nop
	;

	; adjust hl to point to the beginning of next column
	inr h
	mvi l, snail_top

sds_colctr:	   
	mvi a, 0
	dcr a
	sta sds_colctr+1

	jnz sds_column	      

sds_end
	; restore frame
	lhld savedsp
	sphl
	ret

palette_gorilla:
	;db 0h,52h,0a4h,0ffh ; greys 4
	db 0h,99h,0a5h,0ffh ; pop art colour shift 
	db 0ffh, 0f2h, 057h, 0fch
palette_loop8:
	db 255,255,255,255
palette_loop4:
	db 0,0,$95,$95

palette_outro:
	db 0,$ff,$ff,$ff
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; PREP THE MARCHING CHECKERS
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; layers get F0/CC/AA for 4 lines, then 0F/CC/AA for the next 4
	;; fill total of 32 lines
	;; layer 8000h = ff, e000=f0/0f..
n_checkerlines		equ 32
checkerlines_ofs	equ 32*32

display_checkers_sub:
	lxi h, 08000h
	shld dcs_layer+1
	lxi h, 0ffffh
	shld dcs_pattern1+1
	shld dcs_pattern2+1
	call display_checkers_layer_sub

	lxi h, 0a000h
	shld dcs_layer+1
	lxi h, 0ffffh; 0f0f0h
	shld dcs_pattern1+1
	lxi h, 0ffffh; 0f0fh
	shld dcs_pattern2+1
	call display_checkers_layer_sub

	lxi h, 0c000h
	shld dcs_layer+1
	lxi h, 0f0f0h; 0cccch
	shld dcs_pattern1+1
	lxi h, 0f0fh ; 0cccch
	shld dcs_pattern2+1
	call display_checkers_layer_sub

	lxi h, 0e000h
	shld dcs_layer+1
	lxi h, 0cccch ;		0aaaah
	shld dcs_pattern1+1
	shld dcs_pattern2+1
	call display_checkers_layer_sub

	ret

display_checkers_layer_sub:
	lxi h, 0
	dad sp
	shld savedsp

	mvi b, 32

dcs_layer: 
	lxi h, 8000h
	lxi d, n_checkerlines
	dad d
	sphl

	; push 32 lines
dcs_b:
	mvi c, 4
dcs_pattern1:
dcs_a:	      
	lxi d, 0f0f0h
	push d
	push d
dcs_pattern2:
	lxi d, 00f0fh
	push d
	push d
	dcr c
	jnz dcs_a

	; readjust sp to point to the next column
	lxi h, 256+n_checkerlines
	dad sp
	sphl

	dcr b
	jnz dcs_b


	lhld savedsp
	sphl
	ret


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; LOAD JIFFYSTRING 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; DE = col:row
	;; HL = pointer to 0-terminated string
	;; text layer base in textlayer+1

js_load_sub:
	shld dss_ptr
	xchg
	shld dss_de
	ret

	;;;;;;;;;;;;;;;;;;;;;
	;; DISPLAY STRING
	;;;;;;;;;;;;;;;;;;;;;

dss_ptr:	dw 0
dss_de:		dw 0

	; Subsequent calls to this render a character string
	; on one layer in (text_layer+1)
js_jiffy_nolayerflip_sub:
	lhld dss_ptr
	mov a, m
	ora a
	rz
	mov c, a
	inx h
	shld dss_ptr
	xchg
	lhld dss_de
	inr h
	shld dss_de
	xchg
	jmp js_savefrm

	; Subsequent calls to this render a character string
	; on two alternating layers: $e0/$c0
js_jiffy_sub:
	lhld dss_ptr			    ; check for the EOL in the first place
	mov a, m			    ; and don't waste time if it is there
	ora a
	rz

	mov c,a
	lda text_layer+2
	cpi $e0
	jnz js_toE0
js_toC0:
	mvi a,$c0
	sta text_layer+2
	lhld dss_de
	xchg
	jmp js_savefrm

js_toE0:
	mvi a,$e0
	inx h
	shld dss_ptr

	lhld dss_de
	inr h
	shld dss_de
	dcr h
	xchg
js_updlayer:
	sta text_layer+2

js_savefrm:
	lxi h,0
	dad sp
	shld savedsp

	; where's the char sprite?
	; bc = (c-32)*8
	mov a,c
	sui 32
	mov c, a
	rlc
	rlc
	rlc
	ani 7
	mov b,a
	mov a,c
	rlc
	rlc
	rlc
	ani $f8
	mov c,a
	lxi h, font_table
	dad b
	sphl	    ; sp -> char

display_1_char: 
text_layer:    
	lxi h, $e000
	dad d	     ; hl -> destination

	; gruu the bits in
	pop b
	mov m, c
	dcr l
	mov m, b
	dcr l
	pop b
	mov m, c
	dcr l
	mov m, b
	dcr l
	pop b
	mov m, c
	dcr l
	mov m, b
	dcr l
	pop b
	mov m, c
	dcr l
	mov m, b
	dcr l

dss_end:
	lhld savedsp
	sphl
	mvi a, 1
	ret	   

time:		dw 0
prlistptr:	dw 0
prlist_tmp:	dw 0

savedsp: dw 0

dlist_ptr:		dw dlist0		 ; pointer to the beginning of display list
dlist_ofs:		dw 0			    ; display list offset 
dlist_saved_ptr:	dw 0
dlist_saved_piece:	dw 0

colorlistptr_default:	dw clist
colorlistptr:		dw clist

scroll:			db 0ffh

message: 
			dw char__, char__, char_9, char_o, char_o, char_2,
			dw char__,
			dw char_o, char_v, char_s, 0
messageptr:		dw 0

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; INTRO INTERRUPT ROUTINE
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Scroll down and clear screen

ii_lines_per_tick equ 8
ii_line: db 0

intr_intro:
	mvi a, 88h
	out 0
	lda scroll
	out 03


	adi ii_lines_per_tick
	sta scroll
	sta phase1+1

	cpi $f0
	jnz ii_oldpal

	mvi c, $f
	mvi b, $00
ii_pal:	       mov a,c
	out 2
	mov a, b
	out $c
	dcr c
	jp ii_pal
ii_oldpal:
	lda ii_line
	mov l, a	
	mvi c, ii_lines_per_tick
ii_0:	     mvi b, 128
	mvi h, $80
ii_1:
	xra a
	mov m, a
	inr h
	dcr b
	jnz ii_1

	mov a,h
	sui 128
	inr l
	dcr c
	jnz ii_0
	mov a, l
	sta ii_line

	ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; THE PLAIN INTERRUPT
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
intr_plain: 
	lxi h, palette_outro+15
	lxi b, 0x0010
into_0:
	mov a,c
	dcr a
	out 02
	mov a, m
	out 0ch
	dcx h
	dcr c	     
	jnz into_0

	; set scroll
	lda scroll
	out 03

	ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; MAIN INTERRUPT ROUTINE
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Main section, time critical

inth:
	; program palette
	mvi a, 88h
	out 0
	
	lxi h, palette_gorilla+15
	lxi b, 0x0010
inth_0:
	mov a,c
	dcr a
	out 02
	mov a, m
	out 0ch
	dcx h
	dcr c	     
	jnz inth_0

	; set scroll
	lda scroll
	out 03

	; display snail
	call snail_display_sub

	; save SP
	lxi h,0
	dad sp
	shld savedsp

	lhld dlist_ptr
	sphl
    
	lxi d, 0
	lhld colorlistptr
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	ret	   ; hop on to the beginning of the display list

clrscr_sub:
	lxi h, 0
	dad sp
	shld savedsp
	lxi sp, 0h
	lxi d, 0800h
	lxi bc, 0
clrscr1:
	push b
	push b
	push b
	push b
	push b
	push b
	push b
	push b
	dcr e
	jnz clrscr1
	dcr d
	jnz clrscr1
	lhld savedsp
	sphl
	ret


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; DISPLAY LIST BUSINESS
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

frame_tmp: dw 0

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; DISPLAY LIST INIT
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_dlist_sub:
	lxi h, 0
	dad sp
	shld frame_tmp
	lxi sp, dlist
	lxi d, dlist_terminator
	push d
	lxi h, dlist_lengthw-1
	lxi d, dlist_dlank
init_dlist_1:
	push d
	dcx h
	mov a, h
	ora l
	jnz init_dlist_1

	; init related variables
	lxi h, dlist_dlank
	shld dlist_saved_piece
	lxi h, dlist0
	shld dlist_saved_ptr
	lxi h, 0
	shld dlist_ofs

	xra a
	sta scroll


	lhld frame_tmp
	sphl
	ret

prepare_message_sub:
	lxi h, 0
	dad sp
	shld frame_tmp

	lxi sp, dlist
	lxi b, dlist_terminator
	push b			      ; put end of list command
	lxi h, 0
	dad sp
	shld prlistptr	       

pm_prepare_chars:
	lxi h, message
	shld messageptr
		
pm_prepare_onechar:
	lhld messageptr
	sphl 
	inx h
	inx h
	shld messageptr
	pop h
	
	mov a,h
	ora l
	jz pm_prepare_chars_done

pm01:
	shld  pm00+1
	xchg
	inx d
	inx d

	; set frame
	lhld prlistptr
	sphl
pm00: 
	lhld 0 ; hl <- (ptr)
	mov a, h
	ora l
	jz pm_char_complete
	push h
	push h
	push h
	; restore frame
	; store current ptr and enable interrupts
	lxi h, 0
	dad sp
	shld prlistptr
	lxi sp, 100h

	xchg ; hl = ptr
	jmp pm01
pm_char_complete:
	jmp pm_prepare_onechar

pm_prepare_chars_done:
	; restore frame and return
	lhld frame_tmp
	sphl
	ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; COLOR LIST INIT
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
prepare_colorlist:
	lhld colorlistptr_default
	shld colorlistptr
xorro0:
	mvi a, 0e0h; 0c0h 
	mvi e, 256-clist_length/12
	
pclrl1:
	mvi d, 12
pclrl2:
	mov m, a
	inx h
	dcr d
	jnz pclrl2

	inr a
	inr e
	jnz pclrl1
	ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; EXECUTABLE VISUALS
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; blank line
dlist_blank:
	xra a
	out 0ch
	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe
	nop
	ret

	; double blank line
dlist_dlank:
	xra a
	out 0ch
	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe
	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe
	dw 0xbebe,0xbebe
	nop
	ret


dlist_terminator:    
	xra a
	out 0ch

	lhld time
	inx h
	shld time
    
	lhld savedsp
	sphl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; CHARACTER PATTERNS
;;;;;;;;;;;;;;;;;;;;;;;;;;;
ch_s_1:
	mov e, m	; 16
	inx h

	ana d		     ; 16
	out 0ch
	ora e		     
	out 0ch
	ana d
	out 0ch

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe

	nop
	jmp dlist_blank

ch_s_2:
	mov e, m
	inx h

	mov a, d ; 8
	ora e	      
	out 0ch
	ora e
	out 0ch
	ana d
	out 0ch
	mov a, d
	ana d
	out 0ch

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe

	nop
	jmp dlist_blank
		
ch_s_3:
	mov e, m
	inx h

	ora e
	out 0ch
	ana d
	out 0ch
	ora e
	out 0ch
	ana d
	out 0ch

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe

	nop
	jmp dlist_blank
	
ch_s_4:
	mov e, m
	inx h

	ora e
	out 0ch
	ana d
	out 0ch

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe

	nop
	jmp dlist_blank

ch_s_5:
	mov e, m
	inx h

	cmp m

	ora e
	out 0ch
	ana d
	out 0ch

	cmp m

	ana d
	out 0ch

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe

	nop
	jmp dlist_blank

ch_s_7:
	mov e, m
	inx h

	ana d
	out 0ch

	cmp m

	ora e
	out 0ch
	ana d
	out 0ch

	cmp m

	ana d
	out 0ch

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe
	nop
	jmp dlist_blank

ch_s_8:
	mov e, m
	inx h

	ana d
	out 0ch
	ana d
	out 0ch
	ora e
	out 0ch
	ana d
	out 0ch
	
	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe

	nop
	jmp dlist_blank


;;;;;; CHARACTER "V"


; letter V
ch_v_10:
	mov e, m
	inx h
	
	xra a
	xra a
	ora e
	out 0ch
	xra a
	xra a
	ora e
	out 0ch
	ana d
	out 0ch

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe
	nop
	jmp dlist_blank

ch_v_11:
	mov e, m
	inx h
	
	ana d
	out 0ch
	ora e
	out 0ch
	ora e
	out 0ch
	ana d
	out 0ch

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe
	nop
	jmp dlist_blank

ch_v_12:
	mov e, m
	inx h
	ana d
	out 0ch
	xra a
	xra a
	ora e
	out 0ch
	xra a
	xra a
	ana d
	out 0ch

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe
	nop
	jmp dlist_blank


;; G interlace mix
ch_g_1:
	mov e, m
	inx h

	ora e
	out 0ch
	ana d
	out 0ch

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe
	dw 0xbebe,0xbebe,0xbebe

	; interlace, second half 
	ana d
	out 0ch
	ana d
	out 0ch

	cmp m
	ora e
	out 0ch
	cmp m
	ana d
	out 0ch

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe

	nop
	ret


ch_r_1:
	mov e, m
	inx h
	ora e
	out 0ch
	ora e
	out 0ch
	ana d
	out 0ch

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe
	nop
	jmp dlist_blank

ch_r_2:
	mov e, m
	inx h
	ora e
	out 0ch
	ora e
	out 0ch
	cmp m
	ana d
	out 0ch
	cmp m

	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe
	nop
	jmp dlist_blank

ch_2_13:
	mov e,m
	inx h
	ora e
	out 0ch
	ora e
	out 0ch
	ora e
	out 0ch
	ana d
	out 0ch
	dw 0xbebe,0xbebe,0xbebe,0xbebe,0xbebe,0xbebe
	nop
	jmp dlist_blank


char_s: dw dlist_dlank, ch_s_1, ch_s_2, ch_s_3, ch_s_3, ch_s_8, ch_s_7, ch_s_1, 
	dw ch_s_5, ch_s_4, ch_s_3, ch_s_3, ch_s_2, ch_s_1, 0

char_v: dw dlist_dlank, ch_s_8, ch_v_12, ch_v_11, ch_v_10, ch_s_3, ch_s_3, ch_s_3, 
	dw ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_3, 0

char_o:
	dw dlist_dlank, ch_s_1, ch_s_2, 
	dw ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_3
	dw ch_s_2, ch_s_1, 0

char__:
	dw dlist_dlank, dlist_dlank, 
	dw dlist_dlank, dlist_dlank, dlist_dlank, dlist_dlank
	dw dlist_dlank, dlist_dlank, dlist_dlank, dlist_dlank, 
	dw dlist_dlank, dlist_dlank, dlist_dlank, dlist_dlank, 0

char_2:	       dw dlist_dlank
	dw ch_2_13, ch_s_4, ch_s_5, ch_s_1, ch_s_7, ch_s_8,ch_s_8,ch_s_8
	dw ch_s_3, ch_s_3, ch_s_2, ch_s_1, 0

char_9: dw dlist_dlank
	dw ch_s_2, ch_s_3, ch_s_8, ch_s_8, ch_s_8, ch_v_10, 
	dw ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_2, ch_s_1, 0

; unused but working characters
;char_g:
;	 dw dlist_dlank, ch_s_1, ch_s_2,
;	 dw ch_s_3, ch_s_3, ch_g_1, ch_g_1, ch_s_4, ch_s_4, ch_s_4, ch_s_3, ch_s_3,
;	 dw ch_s_2, ch_s_1, 0	     
;char_r:
;	 dw dlist_dlank, ch_s_3, ch_s_3, ch_s_3, ch_s_3, 
;	 dw ch_r_2, ch_r_1, ch_r_2
;	 dw ch_s_3, ch_s_3, ch_s_3, ch_s_3, 
;	 dw ch_r_2, ch_r_1,  0
;char_u: dw dlist_dlank, ch_s_2, ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_3, 
;	 dw ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_3, ch_s_3, 0
;char_c:
;	 dw dlist_dlank, ch_s_1, ch_s_2,
;	 dw ch_s_3, ch_s_3, ch_s_4, ch_s_4, ch_s_4, ch_s_4, ch_s_4, ch_s_3, ch_s_3,
;	 dw ch_s_2, ch_s_1, 0



checkers_height equ 8
checkers_init:
    lxi h, dlist0
    shld dlist_ptr
    lxi h, 16
    shld dlist_ofs
    call chx_colorlist_sub
    lxi h, chx_inth
    shld $39
    mvi a, 0c9h ; ret at first
    sta 38h
    
    xra a    
    sta chx_waveofs
    sta chx_loopctr
    lxi h, twave_still	  
    shld twave_ptr
    
    ; store ADI/SBI opcode at chx_addsub
    ; if wrong opcode is stored at initialization time, the checkers will flicker
    mvi a, $c6 ; $de ; $c6 
    sta chx_addsub
    
    ret 
    
chx_wave:
    lxi h, twave_wave
    shld twave_ptr
    ret
chx_still:
    lxi h, twave_still
    shld twave_ptr
    ret 
    

chx_colorlist_sub:
    lhld colorlistptr_default
    shld colorlistptr
    mvi b, 01001000b
    mvi d, 01000001b
    mvi e, 32 
chx_pclrl1a:
    mvi c, 5
chx_pclrl2:
    mov m, d
    inx h
    mov m, b
    inx h
    dcr c
    jnz chx_pclrl2

    mvi c, 10
chx_pclrl1:
    mov m, b
    inx h
    dcr c
    jnz chx_pclrl1

    mov d, b

    mov a, e
    ani 1
    jnz chx_cn
    inr b
chx_cn:
    mov a,e
    cpi 15
    jnz chx_co
    mov a, b
    adi 00001000b
    mov b, a
chx_co:
 
    mov a, e
    cpi 22
    jnz chx_cp
    mov a, b
    adi 01000000b
    mov b, a
chx_cp

    dcr e
    jnz chx_pclrl1a
    ret

chx_loop:
    lxi h, chx_loopctr
    inr m

chx_noswitch:
    lxi h, chx_loopctr
    mvi a, 03h
    ana m
    jnz chx_noswitch2

    ; invert sbi/adi for jumping up/down
    lxi h, chx_addsub
    mvi a, 18h
    xra m
    mov m, a

chx_noswitch2:

chx_prepare_list:
    ; prepare display list
    di
    lxi sp, dlist0+checkers_height*16*2
    lxi b, checker_end
    push b			  ; put end of list command
    lxi h, 0
    dad sp
    shld prlistptr   
    lxi sp, 100h

    mvi b, checkers_height ; 8h; 0fh
    lda chx_waveofs
    mov c,a

chx_prlist_1:
    di
    ; c is wave offset (* 16)
    inr c

chx_prlist_11:
    mov a, b
    dcr a
    ani 1
    jnz chx_prlist_chb
    lxi h, twave_ia
    shld prlist_tmp
    jmp chx_prlist_12
chx_prlist_chb:
    lxi h, twave_ib
    shld prlist_tmp

chx_prlist_12:
    lhld twave_ptr
    mov a,c
    ani 0fh

    mov e,a
    mvi d,0
    dad d	  ; hl = hl + de
    mov e,m	    ; de = twave[c]
    lhld prlist_tmp ; h = twave_ia or twave_ib
    dad d	 ; h = twave_ia + twave[c]

    mov e,m
    inx h
    mov d,m

    ; restore list ptr
    lhld prlistptr
    sphl
    
    push d
    push d
    push d
    push d
    push d
    push d
    push d
    push d
    push d
    push d
    push d
    push d
    push d
    push d
    push d

    mov a, b
    cpi 1
    jz chx_nolastpush
    push d
chx_nolastpush:
    ; store current ptr and enable interrupts
    lxi h, 0
    dad sp
    shld prlistptr
    lxi sp, 100h

    ; break in the middle of list update to allow the rasters to scan
    ; {
    mvi a, checkers_height/2
    cmp b
    jnz chx_nowait
    push b
    push d
    ei
    hlt		       
    pop d	 
    pop b
    ; }

chx_nowait:

    ; loop 256 lines
    dcr b
    jnz chx_prlist_1

    mov a,c
    adi 6 ; 5 = hysterical, 9 = chill
    sta chx_waveofs

    ; enable full interrupt
    mvi a, 0c3h ; ret at first
    sta 38h

    ; ready to rock
    lxi sp, 100h
    
    ;;;;;; 
    ;#####
    ;;;;;;
	lxi h, outro_time
	dcr m
	jnz outro_jiffy

	; advance to the next part
	lhld outro_tptr
	inx h
	inx h
	shld outro_tptr

outro_jiffy:
	lhld outro_tptr
	mov e,m
	inx h
	mov d,m
	xchg		    ; hl = outro_musicby, outro_fadein, etc..

	mov a,h		       
	ora l
	jz demo_end	   ; don't call at null

	shld outro_jcall+1
outro_jcall:
	call 0
outro_ended:	    
	ei
	hlt
    
    ;;;;;;
    ;#####
    ;;;;;;    
    
    jmp chx_loop

chx_inth:
	lxi h, palette_outro+15
	lxi b, 0x0010
chx_i0:
	mov a,c
	dcr a
	out 02
	mov a, m
	out 0ch
	dcx h
	dcr c	     
	jnz chx_i0

	; set scroll
	lda scroll
	out 03

checkers_active:
	mvi a, 0
    ora a
    rz

    ; save SP
    lxi h,0
    dad sp
    shld savedsp

    lhld dlist_ptr
    xchg
    lhld dlist_ofs
    mov a, l
chx_addsub:
    adi 2
    ani 7fh
    mov l, a
    shld dlist_ofs
    dad d
    sphl
    
    ; wait for the visible part
    lxi h, 0eeh
    dcx h
    mov a,h
    ora l
    jnz $-3

    lxi d, 0
    lhld colorlistptr
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    ret	       ; hop on to the beginning of the display list

checker_a1:
    mov e, m
    inx h
    
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ana d
    out 0ch
    ana d
    out 0ch

    nop
    nop
    nop
    nop
    nop ; 4
    out 0ch ; 12
    ;-half- 

    ; 16x11

db $e3,$e3,$e3,$e3,$e3,$e3,$be,$be,$be,$be
    nop ; 4
    ret ; 12

checker_a2:
    nop
    mov e, m
    inx h   
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ana d
    out 0ch
    ana d
    out 0ch
    nop
    nop
    nop
    nop ; 4
    out 0ch ; 12
    ; -- half
    db $e3,$e3,$e3,$e3,$e3,$e3,$be,$be,$be,$be
    nop ; 4
    ret ; 12

checker_a3:
    nop
    nop

    mov e, m
    inx h
    
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ana d
    out 0ch
    ana d
    out 0ch

    nop
    nop
    nop ; 4
    out 0ch ; 12
    ;-half-
    db $e3,$e3,$e3,$e3,$e3,$e3,$be,$be,$be,$be
    nop ; 4
    ret ; 12

checker_b1:
    mov e, m
    inx h

    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ana d
    out 0ch

    nop
    nop
    nop
    nop
    nop ; 4
    out 0ch ; 12
    ;-half-
    db $e3,$e3,$e3,$e3,$e3,$e3,$be,$be,$be,$be
    nop ; 4
    ret ; 12

checker_b2:
    nop
    mov e, m
    inx h

    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ana d
    out 0ch
    nop
    nop
    nop
    nop ; 4
    out 0ch ; 12
    ;-half
    db $e3,$e3,$e3,$e3,$e3,$e3,$be,$be,$be,$be
    nop ; 4
    ret ; 12


checker_b3:
    nop
    nop
    mov e, m
    inx h

    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    ora e
    out 0ch
    ana d
    out 0ch
    
    ana d
    out 0ch

    nop
    nop
    nop ; 4
    out 0ch ; 12
    ;-half-
    db $e3,$e3,$e3,$e3,$e3,$e3,$be,$be,$be,$be
    nop ; 4
    ret ; 12

checker_end:	
    xra a
    out 0ch

    lhld savedsp
    sphl

    ret

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; CHECKER VARIABLES
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
chx_loopctr:	    db 0
chx_waveofs:	db 0

twave_ia:	 
	dw checker_a1, checker_a2, checker_a3
twave_ib: 
	dw checker_b1, checker_b2, checker_b3
twave_ptr:
	dw twave_still
twave_wave:
	db 2, 2, 2, 0, 0, 0, 0, 0, 2, 2, 2, 4, 4, 4, 4, 4
twave_still:
	db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
twave_n	       equ 16


gorilla_columns equ 13
gorilla_rows	equ 172
; layer 0
gorilla_0:
db 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,01h,03h,03h,07h,07h,0fh,01fh,01fh,01fh,03fh,03fh,03fh,07fh,07fh,07fh,07fh,07fh,07fh,03fh,03fh,03fh,03fh,01fh,0fh,07h,03h,01h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,
db 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,01h,03h,07h,07h,0fh,01fh,01fh,01fh,03fh,07fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,
db 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,03h,03h,03h,07h,0fh,0fh,01fh,01fh,03fh,03fh,07fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,
db 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,01h,03h,03h,03h,07h,0fh,0fh,01fh,03fh,03fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,01h,01h,01h,01h,01h,01h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,07h,07h,07h,07h,07h,07h,07h,0fh,0fh,0fh,0fh,07h,07h,07h,07h,03h,03h,01h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,
db 00h,00h,01h,03h,03h,07h,0fh,0fh,01fh,01fh,03fh,07fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fch,0f8h,0f0h,0e0h,0e0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0e0h,0e0h,0f0h,0f8h,0fch,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,01fh,0fh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,03fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,03fh,01fh,0fh,03h,01h,00h,00h,00h,
db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,080h,00h,00h,00h,00h,00h,03eh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,03eh,00h,00h,00h,00h,00h,080h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0fch,0f0h,0e0h,0c0h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0e0h,0f0h,0f8h,0f8h,0fch,0fch,0feh,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,01fh,00h,00h,
db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,03fh,01fh,0fh,07h,03h,03h,01h,081h,081h,081h,081h,081h,01h,03h,03h,07h,0fh,01fh,03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fch,0f8h,0f0h,0e0h,0c0h,080h,080h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,080h,080h,0c0h,0e0h,0f0h,0f8h,0fch,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,00h,
db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f0h,0e0h,080h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,080h,0e0h,0f0h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,00h,
db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f8h,080h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,080h,0f8h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f8h,00h,
db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,00h,00h,
db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,07h,01h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,07h,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0c0h,00h,00h,
db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,03fh,01fh,07h,03h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,03h,07h,01fh,03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,00h,00h,00h,
db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,03fh,01fh,0fh,07h,07h,03h,01h,01h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,01h,03h,07h,07h,0fh,01fh,03fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,00h,00h,00h,


snail_a_columns equ 11
snail_a_rows	    equ 30
; layer 0
snail_a_0:
db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f3h,0e0h,0e0h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0feh,0feh,0fch,0f9h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,07fh,03fh,0bfh,098h,090h,010h,010h,00h,00h,00h,00h,00h,080h,0e0h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0feh,0fch,0f8h,0e0h,0f0h,0fch,01eh,0fh,03h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0e0h,0ffh,0ffh,0feh,0f0h,0e0h,0c0h,080h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,080h,0e0h,0feh,01fh,00h,00h,00h,00h,00h,00h,00h,00h,0ffh,0e0h,00h,00h,00h,00h,00h,00h,00h,00h,01h,01h,01h,01h,01h,00h,00h,00h,00h,00h,00h,0e0h,0ffh,00h,00h,00h,00h,00h,00h,00h,0ffh,00h,00h,00h,00h,00h,00h,01ch,062h,0cah,0c4h,080h,080h,0c0h,0c0h,0e0h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,03h,0ffh,0ffh,03fh,01fh,07h,03h,01h,01h,01h,00h,00h,00h,00h,00h,00h,00h,01h,01h,03h,03h,0fh,01eh,010h,060h,00h,00h,00h,00h,00h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,03fh,07h,00h,00h,00h,00h,00h,00h,0e0h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07h,01h,00h,00h,00h,00h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,01fh,07h,01h,00h,
snail_b_columns equ 11
snail_b_rows	    equ 30
; layer 0
snail_b_0:
db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dfh,07h,03h,0e1h,0fch,0feh,0fch,0fch,0f8h,0f8h,0f8h,0f8h,0f0h,0e4h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fch,060h,040h,040h,040h,00h,00h,00h,00h,00h,00h,080h,0e0h,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fch,0fch,0f8h,0f8h,0f8h,0f0h,0e0h,080h,0c0h,0f0h,0f8h,07eh,01fh,03h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0ffh,0ffh,0f8h,0c0h,080h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,080h,0f8h,0ffh,00h,00h,00h,00h,00h,00h,00h,00h,0c0h,080h,00h,00h,00h,00h,00h,00h,01h,03h,07h,06h,06h,07h,07h,03h,00h,00h,00h,00h,00h,080h,0fch,00h,00h,00h,00h,00h,00h,00h,00h,03h,00h,00h,00h,00h,00h,070h,088h,028h,010h,00h,00h,00h,00h,080h,00h,00h,00h,00h,00h,00h,00h,01h,03h,00h,00h,00h,00h,00h,00h,0ffh,0ffh,07fh,01fh,0fh,07h,07h,07h,03h,03h,03h,03h,03h,03h,03h,07h,07h,0fh,0fh,03fh,07fh,070h,0c0h,080h,00h,00h,00h,00h,00h,01fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,0fh,00h,00h,00h,00h,00h,00h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,01fh,07h,01h,00h,00h,00h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,01fh,0fh,
snail_c_columns equ 11
snail_c_rows	    equ 30
; layer 0
snail_c_0:
db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fch,0fch,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,03fh,0fh,07h,0c3h,0f3h,0f9h,0f1h,0e1h,0e0h,0e0h,0e0h,0c0h,090h,0f8h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0ffh,0ffh,0ffh,0f0h,080h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0e0h,0ffh,0ffh,0ffh,0feh,0fch,0f8h,0f0h,0f0h,0e0h,0e0h,0e0h,0c0h,080h,00h,00h,0c0h,0e0h,0f8h,01eh,07h,01h,00h,00h,00h,00h,00h,00h,00h,00h,0fh,0feh,0e0h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0e0h,0feh,07h,00h,00h,00h,00h,00h,00h,00h,0f8h,00h,00h,00h,00h,00h,00h,01h,06h,0ch,01ch,018h,018h,01ch,01ch,0eh,00h,00h,00h,00h,00h,00h,0f0h,00h,00h,00h,00h,00h,00h,00h,00h,0fh,03h,01h,00h,00h,00h,0c0h,020h,0a0h,040h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,01h,07h,00h,00h,00h,00h,00h,00h,00h,0ffh,0ffh,0ffh,07fh,03fh,01fh,01fh,01fh,0fh,0fh,0fh,0fh,0fh,0fh,0fh,01fh,01fh,03fh,03fh,0ffh,0ffh,03h,00h,00h,00h,00h,00h,00h,00h,00h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,03fh,03h,00h,00h,00h,00h,00h,03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,0fh,07h,01h,00h,0fch,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,03fh,
snail_d_columns equ 11
snail_d_rows	    equ 30
; layer 0
snail_d_0:
db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fdh,0f0h,0f0h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,03fh,01fh,0cfh,0e6h,0c4h,0c4h,084h,080h,080h,0c0h,00h,040h,0e0h,0f8h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f8h,0fch,0ffh,0c7h,03h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0e0h,0ffh,0ffh,0ffh,0fch,0f8h,0f0h,0e0h,0c0h,0c0h,080h,080h,080h,00h,00h,00h,00h,00h,080h,0e0h,0f8h,03fh,07h,00h,00h,00h,00h,00h,00h,00h,00h,0ffh,0f8h,080h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,080h,0f8h,03fh,00h,00h,00h,00h,00h,00h,07fh,0ffh,00h,00h,00h,00h,00h,00h,07h,018h,032h,071h,060h,060h,070h,070h,038h,00h,00h,00h,00h,00h,00h,0c0h,00h,00h,00h,00h,00h,00h,0ffh,0ffh,03fh,0fh,07h,01h,00h,00h,00h,080h,080h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,03h,07h,04h,018h,00h,00h,00h,00h,00h,00h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,07fh,07fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,07fh,07fh,0ffh,0ffh,0ffh,08fh,01h,00h,00h,00h,00h,00h,00h,00h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,03fh,01h,00h,00h,00h,00h,00h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,0fh,03h,01h,00h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,

dlist0	      equ 3000h
dlist	     equ 3400h
clist	     equ 3600h

font_table:
; Font: 8X8!FONT.pf
Char_032		db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; !
Char_033		db	0x30, 0x00, 0x30, 0x00, 0x00, 0x00, 0x30, 0x00	; "
Char_034		db	0x6C, 0x6C, 0x6C, 0x00, 0x00, 0x00, 0x00, 0x00	; #
Char_035		db	0x6C, 0x6C, 0xFE, 0x6C, 0xFE, 0x6C, 0x6C, 0x00	; $
Char_036		db	0x30, 0x7C, 0xC0, 0x78, 0x0C, 0xF8, 0x30, 0x00	; %
Char_037		db	0x00, 0xC6, 0xCC, 0x18, 0x30, 0x66, 0xC6, 0x00	; &
Char_038		db	0x38, 0x6C, 0x38, 0x76, 0xDC, 0xCC, 0x76, 0x00	; '
Char_039		db	0x60, 0x60, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00	; (
Char_040		db	0x18, 0x00, 0x60, 0x00, 0x60, 0x00, 0x18, 0x00	; )
Char_041		db	0x60, 0x00, 0x18, 0x00, 0x18, 0x00, 0x60, 0x00	; *
Char_042		db	0x00, 0x66, 0x3C, 0xFF, 0x3C, 0x66, 0x00, 0x00	; +
Char_043		db	0x00, 0x30, 0x30, 0xFC, 0x30, 0x30, 0x00, 0x00	; ,
Char_044		db	0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x30, 0x60	; -
Char_045		db	0x00, 0x00, 0x00, 0x00, 0xFC, 0x00, 0x00, 0x00	; .
Char_046		db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00	; /
Char_047		db	0x06, 0x00, 0x18, 0x00, 0x60, 0x00, 0x80, 0x00	; 0
Char_048		db	0x7C, 0x00, 0xC6, 0x00, 0xC6, 0x00, 0x7C, 0x00	; 1
Char_049		db	0x30, 0x70, 0x30, 0x30, 0x30, 0x30, 0x30, 0x00	; 2
Char_050		db	0x78, 0x00, 0x0C, 0x00, 0x78, 0x00, 0xFC, 0x00	; 3
Char_051		db	0x78, 0xCC, 0x0C, 0x38, 0x0C, 0xCC, 0x78, 0x00	; 4
Char_052		db	0x1C, 0x3C, 0x6C, 0xCC, 0xFE, 0x0C, 0x0C, 0x00	; 5
Char_053		db	0xFC, 0xC0, 0xF8, 0x0C, 0x0C, 0xCC, 0x78, 0x00	; 6
Char_054		db	0x18, 0x00, 0x60, 0x00, 0xCC, 0x00, 0x78, 0x00	; 7
Char_055		db	0xFC, 0x0C, 0x0C, 0x18, 0x30, 0x30, 0x30, 0x00	; 8
Char_056		db	0x78, 0x00, 0x48, 0x00, 0xCC, 0x00, 0x78, 0x00	; 9
Char_057		db	0x78, 0x00, 0xCC, 0x00, 0x3C, 0x00, 0x70, 0x00	; :
Char_058		db	0x00, 0x30, 0x30, 0x00, 0x00, 0x30, 0x30, 0x00	; ;
Char_059		db	0x00, 0x30, 0x30, 0x00, 0x00, 0x30, 0x30, 0x60	; <
Char_060		db	0x18, 0x30, 0x60, 0xC0, 0x60, 0x30, 0x18, 0x00	; =
Char_061		db	0x00, 0x00, 0xFC, 0x00, 0x00, 0xFC, 0x00, 0x00	; >
Char_062		db	0x60, 0x30, 0x18, 0x0C, 0x18, 0x30, 0x60, 0x00	; ?
Char_063		db	0x78, 0xCC, 0x0C, 0x18, 0x30, 0x00, 0x30, 0x00	; @
Char_064		db	0x7C, 0xC6, 0xDE, 0xDE, 0xDE, 0xC0, 0x78, 0x00	; A
Char_065		db	0x3C, 0x00, 0x66, 0x00, 0x7E, 0x00, 0x66, 0x00	; B
Char_066		db	0x7C, 0x00, 0x6E, 0x00, 0x6E, 0x00, 0x7C, 0x00	; C
Char_067		db	0x7C, 0x00, 0xC0, 0x00, 0xC0, 0x00, 0x7C, 0x00	; D
Char_068		db	0x7C, 0x00, 0x66, 0x00, 0x66, 0x00, 0x7C, 0x00	; E
Char_069		db	0x7E, 0x00, 0x60, 0x00, 0x78, 0x00, 0x7E, 0x00	; F
Char_070		db	0x7E, 0x00, 0x60, 0x00, 0x78, 0x00, 0x60, 0x00	; G
Char_071		db	0x7C, 0x00, 0xC0, 0x00, 0xCE, 0x00, 0x7E, 0x00	; H
Char_072		db	0x66, 0x00, 0x66, 0x00, 0x7E, 0x00, 0x66, 0x00	; I
Char_073		db	0x18, 0x00, 0x18, 0x00, 0x18, 0x00, 0x18, 0x00	; J
Char_074		db	0x06, 0x00, 0x06, 0x00, 0x66, 0x00, 0x3C, 0x00	; K
Char_075		db	0x66, 0x00, 0x70, 0x00, 0x78, 0x00, 0x66, 0x00	; L
Char_076		db	0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x7E, 0x00	; M
Char_077		db	0xC6, 0x00, 0xFE, 0x00, 0xD6, 0x00, 0xC6, 0x00	; N
Char_078		db	0xC6, 0x00, 0xF6, 0x00, 0xDE, 0x00, 0xC6, 0x00	; O
Char_079		db	0x3C, 0x00, 0x66, 0x00, 0x66, 0x00, 0x3C, 0x00	; P
Char_080		db	0x7C, 0x00, 0x66, 0x00, 0x7C, 0x00, 0x60, 0x00	; Q
Char_081		db	0x3C, 0x00, 0x66, 0x00, 0x6E, 0x00, 0x3E, 0x00	; R
Char_082		db	0x7C, 0x00, 0x66, 0x00, 0x6C, 0x00, 0x66, 0x00	; S
Char_083		db	0x3E, 0x00, 0x70, 0x00, 0x1E, 0x00, 0x7C, 0x00	; T
Char_084		db	0x7E, 0x00, 0x18, 0x00, 0x18, 0x00, 0x18, 0x00	; U
Char_085		db	0x66, 0x00, 0x66, 0x00, 0x66, 0x00, 0x3E, 0x00	; V
Char_086		db	0x66, 0x00, 0x66, 0x00, 0x66, 0x00, 0x18, 0x00	; W
Char_087		db	0xC6, 0x00, 0xD6, 0x00, 0xFE, 0x00, 0xC6, 0x00	; X
Char_088		db	0x66, 0x00, 0x3C, 0x00, 0x3C, 0x00, 0x66, 0x00	; Y
Char_089		db	0x66, 0x00, 0x66, 0x00, 0x18, 0x00, 0x18, 0x00	; Z
Char_090		db	0xFE, 0x00, 0x0C, 0x00, 0x30, 0x00, 0xFE, 0x00	; [
Char_091		db	0x78, 0x60, 0x60, 0x60, 0x60, 0x60, 0x78, 0x00	; \
Char_092		db	0xC0, 0x60, 0x30, 0x18, 0x0C, 0x06, 0x02, 0x00	; ]
Char_093		db	0x78, 0x18, 0x18, 0x18, 0x18, 0x18, 0x78, 0x00	; ^
;----
db	  0x07, 0x0E, 0x39, 0x63, 0x83, 0x31, 0x1C, 0x07	; ^ = chaos constructions
db	  0xC0, 0xE0, 0x38, 0x8C, 0x82, 0x18, 0x70, 0xC0	; _ = logo

schmap	      equ 4000h

outro_msg_empty:
	db $10,$10,' ',0,0,0

outro_msg_musicby:
	db $98,$0a,'M U S I C',0
	db $80,$00,'FLASH IN PARADISE/PROGMASTER',0
	db 0, 0

outro_msg_codeby:
	db $98, $06, 'C O D E / G F X',0
	db $80, $0c, 'SVO',0, 0, 0

outro_msg_v06c:
	db $88, $04, 'A VECTOR-06C PROD', 0, 0, 0


outro_msg_snail:
	db $98, $d, '8', 0
	db $88, $b, 'B I T', 0
	db $78, $9, 'S N A I L', 0, 0, 0  
	
intro_msg_warning:
	db $98, $08, 'W A R N I N G',0
	db $80, $01, 'THE FOLLOWING PRESENTATION', 0
	db $70, $05, 'IS EXTREMELY SHORT', 0, 0, 0

txtmsg_0: 
	db 0
	db 32, $1,$1, 0
	db $60, $c0,$a,'HULLO!',0
	db $60, $90,$a,'GREETINGS TO',0
	;db $30, $80,$a,'CHAOS^_CONSTRUCTIONS',0
	db $30, $80,$a,'CHAOS  CONSTRUCTIONS',0
	db $90, $76,$a,'2009',0
	db $30, $4c,$a,'ALL HAIL',0
	db $ff, $3e,$a,'THE 8-BIT SNAIL!',0
	db $50, $2b,$12,'(GRUUU...)',0
	db $20, $2b,$12,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',0
	db 0, 0, 0
txtmsg_ptr:
	dw 0
txtmsg_time:	    
	db 0

gorilla_src_ptr:	dw 0
gorilla_origin:		dw 0
gorilla_dimension:	dw 0
loopctr:		dw 0 ; $4b0
switch:			db 0
c_c_switch:		db 0


playersrc:
	
	end
	
