	.org 100h
	di
	lxi sp, datastart
	lxi h, 04000h
	lxi d, 02000h ; size in words
puu1:	pop b
	mov m, c
	inx h
	mov m, b
	inx h
	dcx d
	mov a, d
	ora e
	jnz puu1
	lxi h, 100h
	sphl
	push h
	lxi d, 100h ; unpack here
	jmp 04000h
datastart:	
	.end