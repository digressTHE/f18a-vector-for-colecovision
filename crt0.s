; crt0.s for Colecovision cart



	;; external routines
	;;.globl set_snd_table

	;; global from this code
	.globl  _buffer32
	;;.globl snd_areas
	.globl _no_nmi
	.globl _nmi_flag
	.globl _nmi_direct
	.globl _vdp_status
	.globl _joypad_1
	.globl _keypad_1
	.globl _joypad_2
	.globl _keypad_2

	.globl spinner_enabled
	.globl _spinner_1
	.globl _spinner_2

	;; global from C code
	.globl _main
	.globl _nmi
	
	.globl l__INITIALIZER
	.globl s__INITIALIZER
	.globl s__INITIALIZED

	;; Ordering of segments for the linker - copied from sdcc crt0.s
	.area _HOME
	.area _CODE

		.ascii "LinkTag:Fixed\0"	; also to ensure there is data BEFORE the banking LinkTags
		.area _main			;   to work around a bug that drops the first AREA: tag in the ihx


        .area _INITIALIZER
	.area _GSINIT
	.area _GSFINAL
	
	;; banking (must be located before the RAM sections)
	.area _bank1
		.ascii "LinkTag:Bank1\0"
            



	;; end of list - needed for makemegacart. Must go before RAM areas.
	; This isn't used by anything else and should not contain data
	.area _ENDOFMAP
        
	.area _DATA
	.area _INITIALIZED
	.area _BSEG
	.area _BSS
	.area _HEAP

	;; TABLE OF VARIABLES (IN RAM)
	.area	_DATA
_buffer32::
	.ds	32 ; buffer space 32    [7000-701F]
snd_addr::
	.ds	11 ; sound addresses    [7020-702A]
snd_areas::
	.ds	61 ; 5 sound slots + NULL (00h) [702B-...]
_no_nmi::
	.ds    1
_vdp_status::
	.ds    1
_nmi_flag::
	.ds    1
_joypad_1::
	.ds    1
_keypad_1::
	.ds    1
_joypad_2::
	.ds    1
_keypad_2::
	.ds    1
	
spinner_enabled::
	.ds	1
	
_spinner_1 = 0x73eb
_spinner_2 = 0x73ec

	.module crt0

	;; CARTRIDGE HEADER (IN ROM)
	.area _HEADER(ABS)
	.org 0x8000
	
	.db	0x55, 0xaa 		; no default colecovision title screen => 55 AA

	.dw	0			; no copy of sprite table, etc.
	.dw	0			; all unused
	.dw	_buffer32		; work buffer
	.dw	0			; ??
	.dw	start_program	; start address for game coding
	.db	0xc9,0,0		; no RST 08 support
	.db	0xc9,0,0		; no RST 10 support
	.db	0xc9,0,0		; no RST 18 support
	.db	0xc9,0,0		; no RST 20 support
	.db	0xc9,0,0		; no RST 28 support
	.db	0xc9,0,0		; no RST 30 support
	jp    spinner_int             ; RST38 - spinner interrupt
	jp	  _nmi_asm

	;; CODE STARTS HERE WITH NMI
        .area _CODE

  ;; direct force NMI call for the release_nmi handler
_nmi_direct:
	      push	  af
	      push    hl
	      ld      a,#1
	      ld      (_nmi_flag),a						; flag an nmi happened even if we won't process it!
	      ld      hl,#_no_nmi
        set     0,(hl)                  ; prevent re-entrancy
	      jr      _nmi_direct2

;; This is the real interrupt-driven entry point
_nmi_asm:
	      push	  af
	      push    hl
	      ld      a,#1
	      ld      (_nmi_flag),a						; flag an nmi happened even if we won't process it!

	;;;
	      ld      hl,#_no_nmi
        bit     0,(hl)                  ; check if nmi() should be called
        jp      nz,nmi_skip
        set     0,(hl)                  ; prevent re-entrancy

_nmi_direct2:
        push    bc
        push    de
        push    ix
        push    iy
        ex      af,af'
        push    af
        exx
        push    bc
        push    de
        push    hl
        call    0x1f76                   ; update controllers
        ld      a,(0x73ee)
        and	#0x4f
        ld      (_joypad_1),a
        ld      a,(0x73ef)
        and	#0x4f
        ld      (_joypad_2),a
        ld      a,(0x73f0)
        and	#0x4f
        ld      (_keypad_1),a
        ld      a,(0x73f1)
        and	#0x4f
        ld      (_keypad_2),a
        call    decode_controllers
        call    _nmi                    ; call C function
        ;;call    0x1f61                ; play sounds
        ;;call    0x1ff4                ; update snd_addr with snd_areas
        pop     hl
        pop     de
        pop     bc
        exx
        pop     af
        ex      af,af'
        pop     iy
        pop     ix
        pop     de
        pop     bc
        
 	      xor     a
 	      ld      (_no_nmi),a             ; allow next nmi AND clear any miss bit
 	      
        in      a,(#0xbf)               ; get VDP status faster
        ld      (_vdp_status),a
        jp      nmi_exit

; if you skipped the NMI, you better mean it in your code! :) (tursi)
; we no longer read the VDP status in that case, which means that
; unless you read the status register, you will never get another NMI
; so on every enable, ALWAYS read VDP status to reset it.
nmi_skip:
        set     7,(hl)									; flag missed interrupt

nmi_exit:
				ld	a,(spinner_enabled)
				or	a
				jr	z,nmi_end
				ei
				
nmi_end:
        pop     hl
        pop     af
        ret

keypad_table::
	.db    0xff,8,4,5,0xff,7,11,2,0xff,10,0,9,3,1,6,0xff

; joypads will be decoded as follows:
; bit
; 0     left
; 1     down
; 2     right
; 3     up
; 4     button 4
; 5     button 3
; 6     button 2
; 7     button 1
; keypads will hold key pressed (0-11), or 0xff
decode_controllers:
	ld      ix, #_joypad_1
	call    decode_controller
	inc     ix
	inc     ix
decode_controller:
	ld      a,0(ix)
	ld      b,a
	and     #0x40
	rlca
	ld      c,a
	ld      a,b
	and     #0x0f
	or      c
	ld      b,a
	ld      a,1(ix)
	ld      c,a
	and     #0x40
	or      b

	ld      0(ix),a

	ld      b,a
	ld      a,c
	cpl
	and     #0x0f
	cp      #8
	jr      nz,no_button_3
	ex      af,af'
	ld      a,b
	or      #0x20
	ld      b,a
	ex      af,af'
no_button_3:
	cp      #4
	jr      nz,no_button_4
	ex      af,af'
	ld      a,b
	or      #0x10
	ld      b,a
	ex      af,af'
no_button_4:
	ld      0(ix),b
;;;;
	ld      a,c
	cpl
	and    #0x0f
	ld      e,a
	ld      d,#0
	ld      hl,#keypad_table
	add     hl,de
	ld      a,(hl)
	ld      1(ix),a
	ret
	
spinner_int:
	push    af
	push    hl
	call    0x1f88
	pop     hl
	pop     af
	ei
	reti

start_program:
	im       1                      ; interrupt mode -> rst 38h
	di

	xor     a                       ; clear carry
	ld      bc,#0x3b8								; ram size left
	ld      hl,#0x7000							; starting from 7000
	ld      de,#0x7001
	ld      (hl),a
	ldir                            ; zero-fill bss

  ld	    a,#1                    ; this is after we zero fill, should still be early
  ld      (_no_nmi),a             ; don't process NMI during setup (tursi)

  ld bc,#0xFFFE ; switch in code bank
  ld a,(bc) ; note that this does NOT set the local pBank

	call gsinit											; Initialize global variables.

	ld	h,#0 ; set dummy sound table
	; update snd_addr with snd_areascall set_snd_table

	ld      hl,#0x0033              ; initialise random generator
	ld      (0x73c8),hl
                                  ; set screen mode 2 text
	call    0x1f85                  ; set default VDP regs 16K
	ld      de,#0x4000              ; clear VRAM
	xor     a
	ld      l,a
	ld      h,a
	call    0x1f82
	
	; re-enable NMIs (tursi)
	xor     a
	ld      (_no_nmi),a
	in      a,(#0xbf)               ; clear VDP status 	
  ld      (_vdp_status),a         ; and save it
	
	; call main rountine
	jp      _main
	
	.area _GSINIT
gsinit::
	ld      bc, #l__INITIALIZER
	ld	a,b
	or	a,c
	jr	z, gsinit_next
	ld      de, #s__INITIALIZED
  ld      hl, #s__INITIALIZER

	ldir
gsinit_next:


	.area _GSFINAL
	ret
	;
