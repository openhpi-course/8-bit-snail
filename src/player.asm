;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°              This file was created by              °°°°
;°°°°          PROGRAM RECOMPILE SYSTEM v(1.15)          °°°°
;°°°°           (C) 1995 by FRIENDS Software             °°°°
;°°°°     (C) 2008 by TIMSoft  (i8080/i8085 rebuild)     °°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
          .org  0A000h
ram_F000  equ 0f000h          
START:	  jmp	INIT
LA003:	  jmp	LA00F
LA006:	  jmp	LA031
LA009:	  jmp	LA016
LA00C:	  jmp	LA05E
LA00F:	  mvi	a, 000h
 	  ora	a
 	  rz
 	  jmp	LA6D9
LA016:	  mvi	a, 001h
 	  sta	0ABF6h
 	  mvi	a, 008h
 	  sta	0A042h
 	  ret
INIT:	  xra	a
 	  sta	0ABF6h
 	  inr	a
 	  sta	0A010h
 	  jmp	LA2C1
LA02C:	  inr	a
 	  sta	0A010h
 	  ret
LA031:	  lda	0A010h
 	  cpi	001h
 	  rc
 	  jz	LA02C
 	  lda	0ABF6h
 	  ora	a
 	  jz	LA642
 	  mvi	a, 000h
 	  dcr	a
 	  sta	0A042h
 	  jnz	LA642
 	  mvi	a, 008h
 	  sta	0A042h
 	  lda	0ABF6h
 	  cpi	00Fh
 	  jz	LA05E
 	  inr	a
 	  sta	0ABF6h
 	  jmp	LA642
LA05E:	  xra	a
 	  sta	0A010h
 	  lxi	b, 00010h
LA065:	  mov	a, b
 	  out	015h
 	  xra	a
 	  out	014h
 	  inr	b
 	  dcr	c
 	  jnz	LA065
 	  ret
 	  .db	 020h,050h,052h,04Fh
 	  .db	 054h,052h,041h,043h
 	  .db	 04Bh,045h,052h,020h
 	  .db	 032h,02Eh,031h,020h
 	  .db	 042h,059h,020h,047h
 	  .db	 04Fh,04Ch,044h,045h
 	  .db	 04Eh,020h,044h,049h
 	  .db	 053h,04Bh,020h
LA090:	  .db	 0F8h,00Eh,010h,00Eh
 	  .db	 060h,00Dh,080h,00Ch
 	  .db	 0D8h,00Bh,028h,00Bh
 	  .db	 088h,00Ah,0F0h,009h
 	  .db	 060h,009h,0E0h,008h
 	  .db	 058h,008h,0E0h,007h
 	  .db	 07Ch,007h,008h,007h
 	  .db	 0B0h,006h,040h,006h
 	  .db	 0ECh,005h,094h,005h
 	  .db	 044h,005h,0F8h,004h
 	  .db	 0B0h,004h,070h,004h
 	  .db	 02Ch,004h,0FDh,003h
 	  .db	 0BEh,003h,084h,003h
 	  .db	 058h,003h,020h,003h
 	  .db	 0F6h,002h,0CAh,002h
 	  .db	 0A2h,002h,07Ch,002h
 	  .db	 058h,002h,038h,002h
 	  .db	 016h,002h,0F8h,001h
 	  .db	 0DFh,001h,0C2h,001h
 	  .db	 0ACh,001h,090h,001h
 	  .db	 07Bh,001h,065h,001h
 	  .db	 051h,001h,03Eh,001h
 	  .db	 02Ch,001h,01Ch,001h
 	  .db	 00Ah,001h,0FCh,000h
 	  .db	 0EFh,000h,0E1h,000h
 	  .db	 0D6h,000h,0C8h,000h
 	  .db	 0BDh,000h,0B2h,000h
 	  .db	 0A8h,000h,09Fh,000h
 	  .db	 096h,000h,08Eh,000h
 	  .db	 085h,000h,07Eh,000h
 	  .db	 077h,000h,070h,000h
 	  .db	 06Bh,000h,064h,000h
 	  .db	 05Eh,000h,059h,000h
 	  .db	 054h,000h,04Fh,000h
 	  .db	 04Bh,000h,047h,000h
 	  .db	 042h,000h,03Fh,000h
 	  .db	 03Bh,000h,038h,000h
 	  .db	 035h,000h,032h,000h
 	  .db	 02Fh,000h,02Ch,000h
 	  .db	 02Ah,000h,027h,000h
 	  .db	 025h,000h,023h,000h
 	  .db	 021h,000h,01Fh,000h
 	  .db	 01Dh,000h,01Ch,000h
 	  .db	 01Ah,000h,019h,000h
 	  .db	 017h,000h,016h,000h
 	  .db	 015h,000h,013h,000h
 	  .db	 012h,000h,011h,000h
 	  .db	 010h,000h,00Fh,000h
LA150:	  .db	 000h,000h,000h,000h
 	  .db	 000h,000h,000h,000h
 	  .db	 000h,000h,000h,000h
 	  .db	 000h,000h,000h,000h
 	  .db	 000h,000h,000h,000h
 	  .db	 000h,000h,000h,000h
 	  .db	 001h,001h,001h,001h
 	  .db	 001h,001h,001h,001h
 	  .db	 000h,000h,000h,000h
 	  .db	 001h,001h,001h,001h
 	  .db	 001h,001h,001h,001h
 	  .db	 002h,002h,002h,002h
 	  .db	 000h,000h,000h,001h
 	  .db	 001h,001h,001h,001h
 	  .db	 002h,002h,002h,002h
 	  .db	 002h,003h,003h,003h
LA190:	  .db	 000h,000h,001h,001h
 	  .db	 001h,001h,002h,002h
 	  .db	 002h,002h,003h,003h
 	  .db	 003h,003h,004h,004h
 	  .db	 000h,000h,001h,001h
 	  .db	 001h,002h,002h,002h
 	  .db	 003h,003h,003h,004h
 	  .db	 004h,004h,005h,005h
 	  .db	 000h,000h,001h,001h
 	  .db	 002h,002h,002h,003h
 	  .db	 003h,004h,004h,004h
 	  .db	 005h,005h,006h,006h
 	  .db	 000h,000h,001h,001h
 	  .db	 002h,002h,003h,003h
 	  .db	 004h,004h,005h,005h
 	  .db	 006h,006h,007h,007h
 	  .db	 000h,001h,001h,002h
 	  .db	 002h,003h,003h,004h
 	  .db	 004h,005h,005h,006h
 	  .db	 006h,007h,007h,008h
 	  .db	 000h,001h,001h,002h
 	  .db	 002h,003h,004h,004h
 	  .db	 005h,005h,006h,007h
 	  .db	 007h,008h,008h,009h
 	  .db	 000h,001h,001h,002h
 	  .db	 003h,003h,004h,005h
 	  .db	 005h,006h,007h,007h
 	  .db	 008h,009h,009h,00Ah
 	  .db	 000h,001h,001h,002h
 	  .db	 003h,004h,004h,005h
 	  .db	 006h,007h,007h,008h
 	  .db	 009h,00Ah,00Ah,00Bh
LA210:	  .db	 000h,001h,002h,002h
 	  .db	 003h,004h,005h,006h
 	  .db	 006h,007h,008h,009h
 	  .db	 00Ah,00Ah,00Bh,00Ch
LA220:	  .db	 000h,001h,002h,003h
 	  .db	 003h,004h,005h,006h
 	  .db	 007h,008h,009h,00Ah
 	  .db	 00Ah,00Bh,00Ch,00Dh
 	  .db	 000h,001h,002h,003h
 	  .db	 004h,005h,006h,007h
 	  .db	 007h,008h,009h,00Ah
 	  .db	 00Bh,00Ch,00Dh,00Eh
LA240:	  .db	 000h,001h,002h,003h
 	  .db	 004h,005h,006h,007h
 	  .db	 008h,009h,00Ah,00Bh
 	  .db	 00Ch,00Dh,00Eh,00Fh
LA250:	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 050h,095h,079h,095h
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 0AEh,095h,0C2h,095h
 	  .db	 054h,096h,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
LA290:	  .db	 0B6h,096h,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
 	  .db	 02Fh,08Ah,02Fh,08Ah
LA2B0:	  .db	 000h
LA2B1:	  .db	 001h
LA2B2:	  .db	 000h
LA2B3:	  .db	 0C2h
LA2B4:	  .db	 001h
LA2B5:	  .db	 02Ch,001h
LA2B7:	  .db	 02Ch,001h,000h
LA2BA:	  .db	 000h,006h,003h
LA2BD:	  .db	 00Ah
LA2BE:	  .db	 000h,000h
LA2C0:	  .db	 000h
LA2C1:	  push	h
 	  shld	LA3D5_+1
 	  push	h
 	  mov	a, m
 	  sta	0A81Ah
 	  sta	0A6DFh
 	  inx	h
 	  inx	h
 	  mov	a, m
 	  inx	h
 	  shld	LA36E_+1
 	  lxi	d, 00020h
 	  dad	d
 	  dad	d
 	  shld	LA382_+1
 	  dad	d
 	  mov	e, m
 	  inx	h
 	  mov	d, m
 	  inx	h
 	  lxi	b, 0001Eh
 	  dad	b
 	  shld	LA3C1_+1
 	  mov	c, a
 	  dad	b
 	  shld	LA3AC_+1
 	  pop	h
 	  dad	d
 	  shld	LA3D0_+1
 	  lxi	h, LA2B3
 	  lxi	d, LA2B4
 	  lxi	b, 0000Dh
 	  mov	m, b
LA2FC:	  mov	a, b
 	  ora	c
 	  jz	LA309
 	  mov	a, m
 	  stax	d
 	  inx	h
 	  inx	d
 	  dcx	b
 	  jmp	LA2FC
LA309:	  nop
 	  xra	a
 	  sta	0A2B0h
 	  sta	0A2B1h
 	  sta	0A2B2h
 	  sta	0A76Ch
 	  sta	0A7D5h
 	  sta	0A49Ah
 	  sta	0A537h
 	  sta	0A5D7h
 	  sta	0A767h
 	  sta	0A7D0h
 	  sta	0A4FCh
 	  sta	0A59Ch
 	  sta	0A63Dh
 	  mov	b, a
 	  cma
 	  sta	0A464h
 	  sta	0A501h
 	  sta	0A5A1h
 	  mvi	a, 02Fh
 	  sta	0A7B8h
 	  sta	0A74Fh
 	  lxi	h, LA240
 	  shld	LA771_+1
 	  shld	LA7DA_+1
 	  shld	LA4F7_+1
 	  shld	LA597_+1
 	  shld	LA638_+1
 	  call	LA3B3
 	  xchg
 	  shld	LA6F9_+1
 	  xchg
 	  pop	b
 	  shld	LA36B_+1
 	  lxi	h, 00000h
 	  dad	sp
 	  shld	LA396_+1
LA36B_ 	  lxi	h, 00000h
LA36E_ 	  lxi	sp, 08A32h
 	  lxi	d, LA250
 	  mvi	a, 020h
LA375:	  pop	h
 	  dad	b
 	  xchg
 	  mov	m, e
 	  inx	h
 	  mov	m, d
 	  inx	h
 	  xchg
 	  dcr	a
 	  jnz	LA375
LA382_ 	  lxi	sp, 08A72h
 	  lxi	d, LA290
 	  mvi	a, 010h
LA389:	  pop	h
 	  dad	b
 	  xchg
 	  mov	m, e
 	  inx	h
 	  mov	m, d
 	  inx	h
 	  xchg
 	  dcr	a
 	  jnz	LA389
LA396_ 	  lxi	sp, 05FF5h
 	  lhld	LA290
 	  shld	LA782_+1
 	  shld	LA7EB_+1
 	  shld	LA470_+1
 	  shld	LA50D_+1
 	  shld	LA5AD_+1
 	  ret
LA3AB
LA3AC_	  lxi	h, 08ACEh
 	  mov	a, m
 	  add	a
 	  jmp	LA3C8
LA3B3:	  shld	LA3BE_+1
 	  lxi	h, 00000h
 	  dad	sp
 	  shld	LA3E5_+1
LA3BE_ 	  lxi	h, 00000h
LA3C1_ 	  lxi	h, 08AB6h
 	  mov	a, m
 	  add	a
 	  jc	LA3AB
LA3C8:	  add	m
 	  add	a
 	  inx	h
 	  shld	LA3C1_+1
 	  mov	c, a
LA3D0_ 	  lxi	h, 08AD0h
 	  dad	b
 	  sphl
LA3D5_ 	  lxi	b, 08A2Fh
 	  pop	h
 	  dad	b
 	  xchg
 	  pop	h
 	  dad	b
 	  shld	LA718_+1
 	  pop	h
 	  dad	b
 	  shld	LA732_+1
LA3E5_ 	  lxi	sp, 05FDFh
 	  mvi	b, 000h
 	  ret
LA3EA:	  mov	a, e
 	  add	a
 	  add	e
 	  mov	e, a
 	  mvi	d, 000h
 	  dad	d
 	  mov	a, m
 	  rar
 	  jnc	LA3F8
 	  mvi	d, 004h
LA3F8:	  rar
 	  sta	0A400h
 	  mov	a, d
 	  ral
 	  mov	d, a
 	  mvi	a, 000h
 	  rar
 	  call	LABC4
 	  inx	h
 	  mov	a, m
 	  rrc
 	  rrc
 	  rrc
 	  rrc
 	  ani	00Fh
 	  call	LABC4
 	  sta	0A418h
 	  push	psw
 	  mov	a, d
 	  ani	008h
 	  mvi	a, 000h
 	  jnz	LABF1
 	  pop	psw
 	  push	psw
 	  add	b
 	  sta	0A2B9h
 	  pop	psw
LA423:	  mov	a, m
 	  ral
 	  ani	01Fh
 	  inx	h
 	  mov	l, m
 	  mov	h, a
 	  sta	0A432h
 	  mov	a, d
 	  sta	0ABC3h
 	  mvi	a, 000h
 	  xchg
 	  mvi	b, 000h
LA437_ 	  lxi	h, 096B8h
 	  dad	b
 	  lda	0ABC2h
 	  add	m
 	  add	a
 	  mov	c, a
 	  lxi	h, LA090
 	  dad	b
 	  mov	a, m
 	  inx	h
 	  mov	h, m
 	  mov	l, a
 	  sta	0A451h
 	  mov	a, d
 	  stc
 	  cmc
 	  rar
 	  mov	d, a
 	  mvi	a, 000h
 	  jc	LA461
 	  sta	0A45Fh
 	  mov	a, l
 	  sub	e
 	  mov	l, a
 	  mov	a, h
 	  sbb	d
 	  mov	h, a
 	  mvi	a, 000h
 	  ret
LA461:	  dad	d
 	  ret
LA463:	  mvi	a, 000h
 	  inr	a
 	  jz	LA4FD
LA46A_ 	  lxi	b, 02800h
LA46D_ 	  lxi	d, 095C2h
LA470_ 	  lxi	h, 096B6h
 	  mov	a, c
 	  inr	a
 	  cmp	m
 	  inx	h
 	  jnz	LA47A
 	  mov	a, m
LA47A:	  sta	0A46Ah
 	  inx	h
 	  shld	LA437_+1
 	  xchg
 	  mov	a, b
 	  mov	e, a
 	  inr	a
 	  cmp	m
 	  inx	h
 	  jnz	LA48B
 	  mov	a, m
LA48B:	  sta	0A46Bh
 	  inx	h
 	  sta	0A498h
 	  mvi	a, 000h
 	  sta	0ABC2h
 	  mvi	a, 000h
 	  mvi	b, 000h
 	  call	LA3EA
LA49F_ 	  lxi	d, 00000h
 	  dad	d
 	  shld	LA2B3
 	  xchg
LA4A7_ 	  lxi	d, 00000h
 	  dcr	d
 	  jm	LA4EC
 	  jz	LA4E6
 	  push	h
LA4B2_ 	  lxi	h, 00000h
 	  mov	a, e
 	  ana	a
 	  jp	LA4C0
 	  sta	0A4BFh
 	  mvi	a, 000h
 	  sui	000h
LA4C0:	  mov	c, a
 	  ana	a
 	  sta	0A4CCh
 	  mov	a, l
 	  sbb	c
 	  mov	l, a
 	  mov	a, h
 	  sbb	b
 	  mov	h, a
 	  mvi	a, 000h
 	  jnc	LA4E2
 	  pop	h
 	  mvi	a, 000h
 	  sta	0A493h
 	  xra	a
 	  sta	0A4A8h
 	  mov	h, a
 	  mov	l, a
 	  shld	LA49F_+1
 	  jmp	LA4EC
LA4E2:	  shld	LA4B2_+1
 	  pop	h
LA4E6:	  mvi	d, 000h
 	  dad	d
 	  shld	LA49F_+1
LA4EC:	  lda	0ABC3h
 	  sta	0A2BAh
 	  call	LABC4
 	  mov	c, a
LA4F7_ 	  lxi	h, LA210
 	  dad	b
 	  mov	a, m
 	  ori	000h
LA4FD:	  sta	0A2BBh
 	  mvi	a, 000h
 	  inr	a
 	  jz	LA59D
LA507_ 	  lxi	b, 00A00h
LA50A_ 	  lxi	d, 09654h
LA50D_ 	  lxi	h, 096B6h
 	  mov	a, c
 	  inr	a
 	  cmp	m
 	  inx	h
 	  jnz	LA517
 	  mov	a, m
LA517:	  sta	0A507h
 	  inx	h
 	  shld	LA437_+1
 	  xchg
 	  mov	a, b
 	  mov	e, a
 	  inr	a
 	  cmp	m
 	  inx	h
 	  jnz	LA528
 	  mov	a, m
LA528:	  sta	0A508h
 	  inx	h
 	  sta	0A535h
 	  mvi	a, 000h
 	  sta	0ABC2h
 	  mvi	a, 000h
 	  mvi	b, 000h
 	  call	LA3EA
LA53C_ 	  lxi	d, 00000h
 	  dad	d
 	  shld	LA2B5
 	  xchg
LA544_ 	  lxi	d, 00000h
 	  dcr	d
 	  jm	LA589
 	  jz	LA583
 	  push	h
LA54F_ 	  lxi	h, 00000h
 	  mov	a, e
 	  ana	a
 	  jp	LA55D
 	  sta	0A55Ch
 	  mvi	a, 000h
 	  sui	000h
LA55D:	  mov	c, a
 	  ana	a
 	  sta	0A569h
 	  mov	a, l
 	  sbb	c
 	  mov	l, a
 	  mov	a, h
 	  sbb	b
 	  mov	h, a
 	  mvi	a, 000h
 	  jnc	LA57F
 	  pop	h
 	  mvi	a, 000h
 	  sta	0A530h
 	  xra	a
 	  sta	0A545h
 	  mov	h, a
 	  mov	l, a
 	  shld	LA53C_+1
 	  jmp	LA589
LA57F:	  shld	LA54F_+1
 	  pop	h
LA583:	  mvi	d, 000h
 	  dad	d
 	  shld	LA53C_+1
LA589:	  lda	0ABC3h
 	  lxi	h, LA2BA
 	  rlc
 	  ora	m
 	  mov	m, a
 	  call	LABC4
 	  mov	c, a
LA597_ 	  lxi	h, LA190
 	  dad	b
 	  mov	a, m
 	  ori	000h
LA59D:	  sta	0A2BCh
 	  mvi	a, 000h
 	  inr	a
 	  jz	LA63E
LA5A7_ 	  lxi	b, 00A00h
LA5AA_ 	  lxi	d, 09654h
LA5AD_ 	  lxi	h, 096B6h
 	  mov	a, c
 	  inr	a
 	  cmp	m
 	  inx	h
 	  jnz	LA5B7
 	  mov	a, m
LA5B7:	  sta	0A5A7h
 	  inx	h
 	  shld	LA437_+1
 	  xchg
 	  mov	a, b
 	  mov	e, a
 	  inr	a
 	  cmp	m
 	  inx	h
 	  jnz	LA5C8
 	  mov	a, m
LA5C8:	  sta	0A5A8h
 	  inx	h
 	  sta	0A5D5h
 	  mvi	a, 000h
 	  sta	0ABC2h
 	  mvi	a, 000h
 	  mvi	b, 000h
 	  call	LA3EA
LA5DC_ 	  lxi	d, 00000h
 	  dad	d
 	  shld	LA2B7
 	  xchg
LA5E4_ 	  lxi	d, 00000h
 	  dcr	d
 	  jm	LA629
 	  jz	LA623
 	  push	h
LA5EF_ 	  lxi	h, 00000h
 	  mov	a, e
 	  ana	a
 	  jp	LA5FD
 	  sta	0A5FCh
 	  mvi	a, 000h
 	  sui	000h
LA5FD:	  mov	c, a
 	  ana	a
 	  sta	0A609h
 	  mov	a, l
 	  sbb	c
 	  mov	l, a
 	  mov	a, h
 	  sbb	b
 	  mov	h, a
 	  mvi	a, 000h
 	  jnc	LA61F
 	  mvi	a, 000h
 	  sta	0A5D0h
 	  xra	a
 	  sta	0A5E5h
 	  mov	h, a
 	  mov	l, a
 	  shld	LA5DC_+1
 	  pop	h
 	  jmp	LA629
LA61F:	  shld	LA5EF_+1
 	  pop	h
LA623:	  mvi	d, 000h
 	  dad	d
 	  shld	LA5DC_+1
LA629:	  lda	0ABC3h
 	  lxi	h, LA2BA
 	  rlc
 	  rlc
 	  ora	m
 	  mov	m, a
 	  call	LABC4
 	  mov	c, a
LA638_ 	  lxi	h, LA220
 	  dad	b
 	  mov	a, m
 	  ori	000h
LA63E:	  sta	0A2BDh
 	  ret
LA642:	  lxi	h, LA2C0
 	  lxi	d, ram_F000+0FBFh
 	  mvi	c, 0FDh
 	  xra	a
 	  ora	m
 	  mvi	a, 00Dh
 	  jnz	LA659
 	  sui	003h
 	  lxi	h, LA2BD
 	  jmp	LA672
LA659:	  out	015h
 	  mov	c, a
 	  mov	a, m
 	  dcx	h
 	  out	014h
 	  dcr	c
 	  mov	a, c
 	  out	015h
 	  mov	a, m
 	  out	014h
 	  dcx	h
 	  dcr	c
 	  mov	a, c
 	  out	015h
 	  mov	a, m
 	  out	014h
 	  dcx	h
 	  dcr	c
 	  mov	a, c
LA672:	  out	015h
 	  mov	c, a
 	  mov	a, m
 	  dcx	h
 	  call	LABF5
 	  out	014h
 	  dcr	c
 	  mov	a, c
 	  out	015h
 	  mov	a, m
 	  dcx	h
 	  call	LABF5
 	  out	014h
 	  dcr	c
 	  mov	a, c
 	  out	015h
 	  mov	a, m
 	  dcx	h
 	  call	LABF5
 	  out	014h
 	  dcr	c
 	  mov	a, c
 	  out	015h
 	  mov	a, m
 	  dcx	h
 	  out	014h
 	  dcr	c
 	  mov	a, c
 	  out	015h
 	  mov	a, m
 	  dcx	h
 	  out	014h
 	  dcr	c
 	  mov	a, c
 	  out	015h
 	  mov	a, m
 	  dcx	h
 	  out	014h
 	  dcr	c
 	  mov	a, c
 	  out	015h
 	  mov	a, m
 	  dcx	h
 	  out	014h
 	  dcr	c
 	  mov	a, c
 	  out	015h
 	  mov	a, m
 	  dcx	h
 	  out	014h
 	  dcr	c
 	  mov	a, c
 	  out	015h
 	  mov	a, m
 	  out	014h
 	  dcx	h
 	  dcr	c
 	  mov	a, c
 	  out	015h
 	  mov	a, m
 	  out	014h
 	  dcx	h
 	  dcr	c
 	  mov	a, c
 	  out	015h
 	  mov	a, m
 	  out	014h
 	  mov	a, c
 	  sta	0A2BAh
 	  sta	0A2C0h
 	  ret
LA6D9:	  xra	a
 	  mov	b, a
 	  call	LABC4
 	  mvi	a, 001h
 	  dcr	a
 	  sta	0A6DFh
 	  jz	LA728
 	  dcr	a
 	  jz	LA70E
 	  dcr	a
 	  jnz	LA463
 	  lxi	h, LA2B0
 	  dcr	m
 	  jp	LA463
 	  mvi	m, 000h
LA6F9_ 	  lxi	d, 08C6Fh
 	  ldax	d
 	  ana	a
 	  cz	LA3B3
 	  call	LA8BA
 	  sta	0A73Dh
 	  xchg
 	  shld	LA6F9_+1
 	  xchg
 	  jmp	LA463
LA70E:	  lxi	h, LA2B1
 	  dcr	m
 	  jp	LA463
 	  mvi	m, 001h
LA718_ 	  lxi	d, 08D01h
 	  call	LAA00
 	  sta	0A7A6h
 	  xchg
 	  shld	LA718_+1
 	  xchg
 	  jmp	LA463
LA728:	  lxi	h, LA2B2
 	  dcr	m
 	  jp	LA73C
 	  mvi	m, 001h
LA732_ 	  lxi	d, 08D38h
 	  call	LAB25
 	  xchg
 	  shld	LA732_+1
 	  xchg
LA73C:	  xra	a
 	  stc
 	  jnc	LA75F
 	  sta	0A73Dh
 	  sta	0A4A8h
 	  mov	h, a
 	  mov	l, a
 	  shld	LA46A_+1
 	  shld	LA49F_+1
 	  nop
 	  sta	0A464h
 	  mvi	a, 023h
 	  sta	0A493h
LA759_ 	  lxi	h, 095C2h
 	  shld	LA46D_+1
 	  xra	a
LA75F:	  stc
 	  jnc	LA777
 	  sta	0A75Fh
 	  mvi	a, 000h
 	  sta	0A4FCh
 	  mvi	a, 000h
 	  sta	0A49Ah
LA771_ 	  lxi	h, 08198h
 	  shld	LA4F7_+1
 	  xra	a
LA777:	  nop
 	  jnc	LA788
 	  sta	0A46Ah
 	  sta	0A777h
LA782_ 	  lxi	h, 096B6h
 	  shld	LA470_+1
 	  xra	a
LA788:	  nop
 	  jnc	LA7A6
 	  sta	0A788h
 	  mvi	a, 000h
 	  sta	0A4D2h
LA795_ 	  lxi	h, 00000h
 	  shld	LA4B2_+1
 	  mvi	a, 000h
 	  sta	0A4E7h
LA7A0_ 	  lxi	h, 00000h
 	  shld	LA4A7_+1
 	  xra	a
LA7A6:	  stc
 	  jnc	LA7C8
 	  mov	h, a
 	  mov	l, a
 	  sta	0A545h
 	  shld	LA53C_+1
 	  shld	LA507_+1
 	  sta	0A7A6h
 	  nop
 	  sta	0A501h
 	  mvi	a, 036h
 	  sta	0A530h
LA7C2_ 	  lxi	h, 09654h
 	  shld	LA50A_+1
 	  xra	a
LA7C8:	  stc
 	  jnc	LA7E0
 	  sta	0A7C8h
 	  mvi	a, 000h
 	  sta	0A59Ch
 	  mvi	a, 000h
 	  sta	0A537h
LA7DA_ 	  lxi	h, 081A8h
 	  shld	LA597_+1
 	  xra	a
LA7E0:	  nop
 	  jnc	LA7F1
 	  sta	0A507h
 	  sta	0A7E0h
LA7EB_ 	  lxi	h, 096B6h
 	  shld	LA50D_+1
 	  xra	a
LA7F1:	  nop
 	  jnc	LA80E
 	  sta	0A7F1h
LA7F9_ 	  lxi	h, 00000h
 	  shld	LA54F_+1
 	  mvi	a, 000h
 	  sta	0A56Fh
 	  mvi	a, 000h
 	  sta	0A584h
LA809_ 	  lxi	h, 00000h
 	  shld	LA544_+1
LA80E:	  mvi	a, 000h
 	  sta	0A2C0h
 	  lxi	h, 00000h
 	  shld	LA2BE
 	  mvi	a, 005h
 	  sta	0A6DFh
 	  xra	a
 	  sta	0A80Fh
 	  jmp	LA463
LA825:	  sta	0A790h
 	  lda	0A7A1h
 	  dcr	a
 	  jz	LA834
 	  mov	a, c
 	  sta	0A754h
 	  xra	a
LA834:	  sta	0A74Fh
 	  mvi	a, 037h
 	  sta	0A788h
 	  ret
LA83D:	  call	LABC4
 	  sta	0A75Fh
 	  lda	0A493h
 	  mov	c, a
 	  call	LABC4
 	  sta	0A754h
 	  inr	b
 	  jz	LA825
 	  xra	a
 	  sta	0A7A1h
 	  sta	0A74Fh
 	  mvi	a, 037h
 	  ret
LA85B:	  add	a
 	  add	a
 	  add	a
 	  add	a
 	  lxi	h, LA150
 	  mov	c, a
 	  dad	b
 	  shld	LA771_+1
 	  mvi	a, 037h
 	  call	LABC4
 	  jmp	LA8BA
LA86F:	  mvi	a, 037h
 	  sta	0A788h
 	  ldax	d
 	  inx	d
 	  mvi	h, 001h
 	  mov	l, a
 	  shld	LA7A0_+1
 	  ana	a
 	  mov	a, b
 	  jp	LA882
 	  cma
LA882:	  sta	0A79Bh
 	  dcr	b
 	  jmp	LA8BA
LA889:	  ldax	d
 	  inx	d
 	  mvi	h, 002h
 	  mov	l, a
 	  shld	LA7A0_+1
 	  ana	a
 	  mov	a, b
 	  jp	LA897
 	  cma
LA897:	  sta	0A79Bh
 	  ldax	d
 	  mov	l, a
 	  inx	d
 	  ldax	d
 	  inx	d
 	  mov	h, a
 	  shld	LA795_+1
 	  dcr	b
 	  jmp	LA8BA
LA8A7:	  ldax	d
 	  inx	d
 	  sta	0A76Ch
 	  mvi	a, 037h
 	  call	LABC4
 	  jmp	LA8BA
LA8B4:	  sta	0A2B0h
 	  sta	0A6F7h
LA8BA:	  ldax	d
 	  inx	d
 	  adi	020h
 	  jc	LA8F6
 	  adi	060h
 	  jc	LA83D
 	  adi	010h
 	  jc	LA941
 	  adi	010h
 	  jc	LA909
 	  adi	040h
 	  jc	LA8B4
 	  adi	010h
 	  jc	LA85B
 	  inr	a
 	  jz	LA963
 	  inr	a
 	  jz	LA86F
 	  inr	a
 	  jz	LA889
 	  inr	a
 	  jnz	LA8A7
 	  xra	a
 	  sta	0A7A1h
 	  mvi	a, 037h
 	  sta	0A788h
 	  jmp	LA8BA
LA8F6:	  jz	LA91E
 	  add	a
 	  lxi	h, LA250
 	  mov	c, a
 	  dad	b
 	  mov	a, m
 	  inx	h
 	  mov	h, m
 	  mov	l, a
 	  shld	LA759_+1
 	  jmp	LA8BA
LA909:	  lxi	h, LA290
 	  add	a
 	  mov	c, a
 	  dad	b
 	  mov	a, m
 	  inx	h
 	  mov	h, m
 	  mov	l, a
 	  shld	LA782_+1
 	  mvi	a, 037h
 	  sta	0A777h
 	  jmp	LA8BA
LA91E:	  call	LABC4
 	  sta	0A75Fh
 	  mvi	a, 02Fh
 	  sta	0A74Fh
 	  mvi	a, 037h
 	  ret
LA92C:	  call	LABC4
 	  sta	0A75Fh
 	  mvi	a, 0A7h
 	  ret
LA935:	  xra	a
 	  sta	0A767h
 	  mvi	a, 037h
 	  call	LABC4
 	  jmp	LA8BA
LA941:	  jz	LA92C
 	  cpi	00Fh
 	  jz	LA935
 	  sta	0A80Fh
 	  mvi	a, 010h
 	  sta	0A767h
 	  ldax	d
 	  sta	0A814h
 	  inx	d
 	  ldax	d
 	  sta	0A815h
 	  inx	d
 	  mvi	a, 037h
 	  call	LABC4
 	  jmp	LA8BA
LA963:	  ldax	d
 	  inx	d
 	  sta	0A81Ah
 	  jmp	LA8BA
LA96B:	  sta	0A7FFh
 	  lda	0A80Ah
 	  dcr	a
 	  jz	LA97A
 	  mov	a, c
 	  sta	0A7BDh
 	  xra	a
LA97A:	  sta	0A7B8h
 	  mvi	a, 037h
 	  sta	0A7F1h
 	  ret
LA983:	  call	LABC4
 	  sta	0A7C8h
 	  lda	0A530h
 	  mov	c, a
 	  call	LABC4
 	  sta	0A7BDh
 	  inr	b
 	  jz	LA96B
 	  xra	a
 	  sta	0A80Ah
 	  sta	0A7B8h
 	  mvi	a, 037h
 	  ret
LA9A1:	  add	a
 	  add	a
 	  add	a
 	  add	a
 	  lxi	h, LA150
 	  mov	c, a
 	  dad	b
 	  shld	LA7DA_+1
 	  mvi	a, 037h
 	  call	LABC4
 	  jmp	LAA00
LA9B5:	  mvi	a, 037h
 	  sta	0A7F1h
 	  ldax	d
 	  inx	d
 	  mvi	h, 001h
 	  mov	l, a
 	  shld	LA809_+1
 	  ana	a
 	  mov	a, b
 	  jp	LA9C8
 	  cma
LA9C8:	  sta	0A804h
 	  dcr	b
 	  jmp	LAA00
LA9CF:	  ldax	d
 	  inx	d
 	  mvi	h, 002h
 	  mov	l, a
 	  shld	LA809_+1
 	  ana	a
 	  mov	a, b
 	  jp	LA9DD
 	  cma
LA9DD:	  sta	0A804h
 	  ldax	d
 	  mov	l, a
 	  inx	d
 	  ldax	d
 	  inx	d
 	  mov	h, a
 	  shld	LA7F9_+1
 	  dcr	b
 	  jmp	LAA00
LA9ED:	  ldax	d
 	  inx	d
 	  sta	0A7D5h
 	  mvi	a, 037h
 	  call	LABC4
 	  jmp	LAA00
LA9FA:	  sta	0A2B1h
 	  sta	0A716h
LAA00:	  ldax	d
 	  inx	d
 	  adi	020h
 	  jc	LAA3C
 	  adi	060h
 	  jc	LA983
 	  adi	010h
 	  jc	LAA87
 	  adi	010h
 	  jc	LAA4F
 	  adi	040h
 	  jc	LA9FA
 	  adi	010h
 	  jc	LA9A1
 	  inr	a
 	  jz	LAAA9
 	  inr	a
 	  jz	LA9B5
 	  inr	a
 	  jz	LA9CF
 	  inr	a
 	  jnz	LA9ED
 	  xra	a
 	  sta	0A80Ah
 	  mvi	a, 037h
 	  sta	0A7F1h
 	  jmp	LAA00
LAA3C:	  jz	LAA64
 	  add	a
 	  lxi	h, LA250
 	  mov	c, a
 	  dad	b
 	  mov	a, m
 	  inx	h
 	  mov	h, m
 	  mov	l, a
 	  shld	LA7C2_+1
 	  jmp	LAA00
LAA4F:	  lxi	h, LA290
 	  add	a
 	  mov	c, a
 	  dad	b
 	  mov	a, m
 	  inx	h
 	  mov	h, m
 	  mov	l, a
 	  shld	LA7EB_+1
 	  mvi	a, 037h
 	  sta	0A7E0h
 	  jmp	LAA00
LAA64:	  call	LABC4
 	  sta	0A7C8h
 	  mvi	a, 02Fh
 	  sta	0A7B8h
 	  mvi	a, 037h
 	  ret
LAA72:	  call	LABC4
 	  sta	0A7C8h
 	  mvi	a, 0A7h
 	  ret
LAA7B:	  xra	a
 	  sta	0A7D0h
 	  mvi	a, 037h
 	  call	LABC4
 	  jmp	LAA00
LAA87:	  jz	LAA72
 	  cpi	00Fh
 	  jz	LAA7B
 	  sta	0A80Fh
 	  mvi	a, 010h
 	  sta	0A7D0h
 	  ldax	d
 	  sta	0A814h
 	  inx	d
 	  ldax	d
 	  sta	0A815h
 	  inx	d
 	  mvi	a, 037h
 	  call	LABC4
 	  jmp	LAA00
LAAA9:	  ldax	d
 	  inx	d
 	  sta	0A81Ah
 	  jmp	LAA00
LAAB1:	  call	LABC4
 	  lda	0A5D0h
 	  mov	c, a
 	  call	LABC4
 	  sta	0A5D0h
 	  inr	b
 	  jz	LAAC9
 	  xra	a
 	  sta	0A5E5h
 	  jmp	LAAD8
LAAC9:	  sta	0A60Eh
 	  lda	0A5E5h
 	  dcr	a
 	  jz	LAAD8
 	  mov	a, c
 	  sta	0A5D0h
 	  xra	a
LAAD8:	  mov	h, a
 	  mov	l, a
 	  shld	LA5DC_+1
 	  sta	0A5A1h
 	  shld	LA5A7_+1
 	  ret
LAAE4:	  ldax	d
 	  inx	d
 	  mvi	h, 001h
 	  mov	l, a
 	  shld	LA5E4_+1
 	  ana	a
 	  mov	a, b
 	  jp	LAAF2
 	  cma
LAAF2:	  sta	0A624h
 	  dcr	b
 	  jmp	LAB25
LAAF9:	  ldax	d
 	  inx	d
 	  mov	l, a
 	  mvi	h, 002h
 	  shld	LA5E4_+1
 	  ana	a
 	  mov	a, b
 	  jp	LAB07
 	  cma
LAB07:	  sta	0A624h
 	  ldax	d
 	  mov	l, a
 	  inx	d
 	  ldax	d
 	  inx	d
 	  mov	h, a
 	  shld	LA5EF_+1
 	  dcr	b
 	  jmp	LAB25
LAB17:	  ldax	d
 	  inx	d
 	  sta	0A5D7h
 	  jmp	LAB25
LAB1F:	  sta	0A2B2h
 	  sta	0A730h
LAB25:	  ldax	d
 	  inx	d
 	  adi	020h
 	  jc	LAB5C
 	  adi	060h
 	  jc	LAAB1
 	  adi	010h
 	  jc	LAB89
 	  adi	010h
 	  jc	LAB6F
 	  adi	040h
 	  jc	LAB1F
 	  adi	010h
 	  jc	LABB3
 	  inr	a
 	  jz	LABAB
 	  inr	a
 	  jz	LAAE4
 	  inr	a
 	  jz	LAAF9
 	  inr	a
 	  jnz	LAB17
 	  xra	a
 	  sta	0A5E5h
 	  jmp	LAB25
LAB5C:	  jz	LAB83
 	  add	a
 	  lxi	h, LA250
 	  mov	c, a
 	  dad	b
 	  mov	a, m
 	  inx	h
 	  mov	h, m
 	  mov	l, a
 	  shld	LA5AA_+1
 	  jmp	LAB25
LAB6F:	  lxi	h, LA290
 	  add	a
 	  mov	c, a
 	  dad	b
 	  mov	a, m
 	  inx	h
 	  mov	h, m
 	  mov	l, a
 	  shld	LA5AD_+1
 	  xra	a
 	  sta	0A5A7h
 	  jmp	LAB25
LAB83:	  mvi	a, 0FFh
 	  sta	0A5A1h
 	  ret
LAB89:	  rz
 	  cpi	00Fh
 	  jz	LABA4
 	  sta	0A80Fh
 	  mvi	a, 010h
 	  sta	0A63Dh
 	  ldax	d
 	  sta	0A814h
 	  inx	d
 	  ldax	d
 	  sta	0A815h
 	  inx	d
 	  jmp	LAB25
LABA4:	  xra	a
 	  sta	0A63Dh
 	  jmp	LAB25
LABAB:	  ldax	d
 	  inx	d
 	  sta	0A81Ah
 	  jmp	LAB25
LABB3:	  add	a
 	  add	a
 	  add	a
 	  add	a
 	  lxi	h, LA150
 	  mov	c, a
 	  dad	b
 	  shld	LA638_+1
 	  jmp	LAB25
 	  .db	 000h,000h
LABC4:	  shld	LABDB_+1
 	  push	psw
 	  pop	h
LABCA_ 	  jmp	LABCC
LABCC:	  shld	LABED
 	  lxi	h, LABDE
 	  shld	LABCA_+1
 	  lhld	LABEF
 	  push	h
 	  pop	psw
LABDB_ 	  lxi	h, 00000h
 	  ret
LABDE:	  .db	 022h,0EFh,0ABh,021h
 	  .db	 0CCh,0ABh,022h,0CAh
 	  .db	 0ABh,02Ah,0EDh,0ABh
 	  .db	 0C3h,0D8h,0ABh
LABED:	  .db	 000h,000h
LABEF:	  .db	 000h,000h
LABF1:	  pop	psw
 	  jmp	LA423
LABF5:	  sui	000h
 	  cpi	080h
 	  rc
 	  xra	a
 	  ret
.end
