;
; MD201512
;

; Code by T.M.R/Cosine
; Graphics conversions T.M.R/Cosine
; Music by Tonka/ex-Cosine


; This source code is formatted for the ACME cross assembler from
; http://sourceforge.net/projects/acme-crossass/
; Compression is handled with PuCrunch which can be downloaded at
; http://csdb.dk/release/?id=6089

; build.bat will call both to create an assembled file and then the
; crunched release version.


; Select an output filename
		!to "md201512.prg",cbm


; Yank in binary data
		* = $1000
		!binary "data/its_christmas.prg",,2

		* = $2000
		!binary "data/air_rescue_sms.chr"

		* = $2800
		!binary "data/ariston.spr"

		* = $4000
		!binary "data/prof4d_np_afli.kla"


; Constants: raster split positions
rstr1p		= $00
rstr2p		= $2c


; Labels
rn		= $50
scroll_x	= $51
scroll_speed	= $52
cos_at_1	= $53
cos_offset_1	= $f9		; constant

cos_at_2	= $54
cos_speed_2	= $fe		; constant
cos_offset_2	= $0e		; constant



; Add a BASIC startline
		* = $0801
		!word entry-2
		!byte $00,$00,$9e
		!text "2066"
		!byte $00,$00,$00


; Entry point at $0812
		* = $0812
entry		sei

		lda #$01
		sta rn

		lda #<nmi
		sta $fffa
		lda #>nmi
		sta $fffb

		lda #<int
		sta $fffe
		lda #>int
		sta $ffff

		lda #$7f
		sta $dc0d
		sta $dd0d

		lda $dc0d
		lda $dd0d

		lda #rstr1p
		sta $d012

		lda #$0b
		sta $d011
		lda #$01
		sta $d019
		sta $d01a

		lda #$35
		sta $01


		ldx #$00
picture_invert	lda $6000,x
		eor #$ff
		sta $6000,x
		inx
		bne picture_invert

		inc picture_invert+$02
		inc picture_invert+$07
		lda picture_invert+$02
		cmp #$80
		bne picture_invert-$02

; Fill the colour RAM for scanline $00
		lda #$ff
		sta $4000
		sta $4001
		sta $4002

; Colour RAM
		ldx #$00
		lda #$0f
colour_ram_init	sta $d800,x
		sta $d900,x
		sta $da00,x
		sta $dae8,x
		inx
		bne colour_ram_init


		jsr reset
		lda #$01
		sta scroll_speed


		ldx #$00
		txa
		tay
		jsr $1000

		cli


; Infinite loop
		jmp *


;glarge		bit $ea
;		inc $d022
;		dec $0600,x
;		dex
;		inc $07e7
;		jmp glarge


; IRQ INTERRUPT
int		pha
		txa
		pha
		tya
		pha

		lda $d019
		and #$01
		sta $d019
		bne ya
		jmp ea31

ya		lda rn
		cmp #$02
		bne *+$05
		jmp rout2


; Raster split 1
rout1		lda #$02
		sta rn
		lda #rstr2p
		sta $d012

		lda #$0c
		sta $d020
		lda #$0f
		sta $d021

		lda #$00
		sta $3fff
		sta $7fff
		sta $d015

		lda #$1b
		sta $d011
		lda #$00
		sta $d016
		lda #$08
		sta $d018

		lda #$c6
		sta $dd00

; Set up the hardware sprites for the lower border
		ldx #$00
set_sprite_1a	lda sprite_pos,x
		sta $d000,x
		inx
		cpx #$11
		bne set_sprite_1a

		ldx #$00
set_sprite_1b	lda sprite_dps,x
		sta $07f8,x
		inx
		cpx #$08
		bne set_sprite_1b

; Update the scroller
		ldy scroll_speed

scroll_loop	ldx scroll_x
		inx
		cpx #$08
		bne scr_xb

		ldx #$00
mover		lda $07c1,x
		sta $07c0,x
		inx
		cpx #$26
		bne mover

mread		lda scroll_text
		bne okay
		jsr reset
		jmp mread

okay		cmp #$80
		bcc okay_2
		and #$0f
		beq okay_1a
		sta scroll_speed

okay_1a		lda #$20

okay_2		sta $07c0+$26

		inc mread+$01
		bne *+$05
		inc mread+$02

		ldx #$00
scr_xb		stx scroll_x

		txa
		and #$07
		eor #$07
		sta scrx_smod+$01

		dey
		bne scroll_loop


; Unrolled scroll colour updater (for science... and speed!)
		inc cos_at_1

		ldx cos_at_1
		ldy scr_col_cosinus,x
		lda split_colours+$00,y
		sta scrl_col_1a+$01
		lda split_colours+$01,y
		sta scrl_col_2a+$01
		lda split_colours+$02,y
		sta scrl_col_3a+$01
		lda split_colours+$03,y
		sta scrl_col_4a+$01
		lda split_colours+$04,y
		sta scrl_col_5a+$01
		lda split_colours+$05,y
		sta scrl_col_6a+$01
		lda split_colours+$06,y
		sta scrl_col_7a+$01

		txa
		clc
		adc #cos_offset_1
		tax
		ldy scr_col_cosinus,x
		lda split_colours+$00,y
		sta scrl_col_1b+$01
		lda split_colours+$01,y
		sta scrl_col_2b+$01
		lda split_colours+$02,y
		sta scrl_col_3b+$01
		lda split_colours+$03,y
		sta scrl_col_4b+$01
		lda split_colours+$04,y
		sta scrl_col_5b+$01
		lda split_colours+$05,y
		sta scrl_col_6b+$01
		lda split_colours+$06,y
		sta scrl_col_7b+$01

		txa
		clc
		adc #cos_offset_1
		tax
		ldy scr_col_cosinus,x
		lda split_colours+$00,y
		sta scrl_col_1c+$01
		lda split_colours+$01,y
		sta scrl_col_2c+$01
		lda split_colours+$02,y
		sta scrl_col_3c+$01
		lda split_colours+$03,y
		sta scrl_col_4c+$01
		lda split_colours+$04,y
		sta scrl_col_5c+$01
		lda split_colours+$05,y
		sta scrl_col_6c+$01
		lda split_colours+$06,y
		sta scrl_col_7c+$01

		txa
		clc
		adc #cos_offset_1
		tax
		ldy scr_col_cosinus,x
		lda split_colours+$00,y
		sta scrl_col_1d+$01
		lda split_colours+$01,y
		sta scrl_col_2d+$01
		lda split_colours+$02,y
		sta scrl_col_3d+$01
		lda split_colours+$03,y
		sta scrl_col_4d+$01
		lda split_colours+$04,y
		sta scrl_col_5d+$01
		lda split_colours+$05,y
		sta scrl_col_6d+$01
		lda split_colours+$06,y
		sta scrl_col_7d+$01

		txa
		clc
		adc #cos_offset_1
		tax
		ldy scr_col_cosinus,x
		lda split_colours+$00,y
		sta scrl_col_1e+$01
		lda split_colours+$01,y
		sta scrl_col_2e+$01
		lda split_colours+$02,y
		sta scrl_col_3e+$01
		lda split_colours+$03,y
		sta scrl_col_4e+$01
		lda split_colours+$04,y
		sta scrl_col_5e+$01
		lda split_colours+$05,y
		sta scrl_col_6e+$01
		lda split_colours+$06,y
		sta scrl_col_7e+$01

		txa
		clc
		adc #cos_offset_1
		tax
		ldy scr_col_cosinus,x
		lda split_colours+$00,y
		sta scrl_col_1f+$01
		lda split_colours+$01,y
		sta scrl_col_2f+$01
		lda split_colours+$02,y
		sta scrl_col_3f+$01
		lda split_colours+$03,y
		sta scrl_col_4f+$01
		lda split_colours+$04,y
		sta scrl_col_5f+$01
		lda split_colours+$05,y
		sta scrl_col_6f+$01
		lda split_colours+$06,y
		sta scrl_col_7f+$01

		txa
		clc
		adc #cos_offset_1
		tax
		ldy scr_col_cosinus,x
		lda split_colours+$00,y
		sta scrl_col_1g+$01
		lda split_colours+$01,y
		sta scrl_col_2g+$01
		lda split_colours+$02,y
		sta scrl_col_3g+$01
		lda split_colours+$03,y
		sta scrl_col_4g+$01
		lda split_colours+$04,y
		sta scrl_col_5g+$01
		lda split_colours+$05,y
		sta scrl_col_6g+$01
		lda split_colours+$06,y
		sta scrl_col_7g+$01

		txa
		clc
		adc #cos_offset_1
		tax
		ldy scr_col_cosinus,x
		lda split_colours+$00,y
		sta scrl_col_1h+$01
		lda split_colours+$01,y
		sta scrl_col_2h+$01
		lda split_colours+$02,y
		sta scrl_col_3h+$01
		lda split_colours+$03,y
		sta scrl_col_4h+$01
		lda split_colours+$04,y
		sta scrl_col_5h+$01
		lda split_colours+$05,y
		sta scrl_col_6h+$01
		lda split_colours+$06,y
		sta scrl_col_7h+$01

		jmp ea31


		* = $a000

; Raster split 2
rout2		nop
		nop
		nop
		nop
		nop
		bit $ea

		lda $d012
		cmp #rstr2p+$01
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		nop
		lda $d012
		cmp #rstr2p+$02
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr2p+$03
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr2p+$04
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		bit $ea
		nop
		lda $d012
		cmp #rstr2p+$05
		bne *+$02
;		sta $d020

		nop
		nop
		nop

		ldx #$09
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr2p+$06
		bne *+$02
;		sta $d020


; AFLI - first character line
		ldx #$09
		dex
		bne *-$01

		lda #$3b
		sta $d011

		ldx #$04
		dex
		bne *-$01
		nop


		ldx #$3c
		ldy #$18
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3d
		ldy #$28
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3e
		ldy #$38
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3f
		ldy #$48
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$38
		ldy #$58
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$39
		ldy #$68
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3a
		ldy #$78
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop


; AFLI - second character line onwards
!set line_cnt=$00
!do {
		ldx #$3b
		ldy #$08
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3c
		ldy #$18
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3d
		ldy #$28
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3e
		ldy #$38
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3f
		ldy #$48
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$38
		ldy #$58
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$39
		ldy #$68
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3a
		ldy #$78
		nop
		nop
		nop
		sty $d018
		stx $d011

		!if line_cnt<>$16 {
		bit $ea
		nop
		}

		!set line_cnt=line_cnt+$01
} until line_cnt=$17

		lda #$c7
		sta $dd00
		lda #$1b
		sta $d011
		lda #$18
		sta $d018
scrx_smod	lda #$00
		sta $d016

		nop
		nop
		nop

; Scroller splits
scrl_col_1a	lda #$0b
		sta $d021
scrl_col_1b	lda #$06
		sta $d021
scrl_col_1c	lda #$00
		sta $d021
scrl_col_1d	lda #$00
		sta $d021
scrl_col_1e	lda #$00
		sta $d021
scrl_col_1f	lda #$06
		sta $d021
scrl_col_1g	lda #$0b
		sta $d021
scrl_col_1h	lda #$00
		sta $d021

		ldx #$02
		dex
		bne *-$01
		bit $ea
		nop

scrl_col_2a	lda #$04
		sta $d021
scrl_col_2b	lda #$0b
		sta $d021
scrl_col_2c	lda #$06
		sta $d021
scrl_col_2d	lda #$00
		sta $d021
scrl_col_2e	lda #$06
		sta $d021
scrl_col_2f	lda #$0b
		sta $d021
scrl_col_2g	lda #$04
		sta $d021
scrl_col_2h	lda #$00
		sta $d021

		ldx #$02
		dex
		bne *-$01
		bit $ea
		nop

scrl_col_3a	lda #$0e
		sta $d021
scrl_col_3b	lda #$04
		sta $d021
scrl_col_3c	lda #$0b
		sta $d021
scrl_col_3d	lda #$06
		sta $d021
scrl_col_3e	lda #$0b
		sta $d021
scrl_col_3f	lda #$04
		sta $d021
scrl_col_3g	lda #$0e
		sta $d021
scrl_col_3h	lda #$00
		sta $d021

		ldx #$02
		dex
		bne *-$01
		bit $ea
		nop

scrl_col_4a	lda #$03
		sta $d021
scrl_col_4b	lda #$0e
		sta $d021
scrl_col_4c	lda #$04
		sta $d021
scrl_col_4d	lda #$0b
		sta $d021
scrl_col_4e	lda #$04
		sta $d021
scrl_col_4f	lda #$0e
		sta $d021
scrl_col_4g	lda #$03
		sta $d021
scrl_col_4h	lda #$00
		sta $d021

		ldx #$02
		dex
		bne *-$01
		bit $ea
		nop

scrl_col_5a	lda #$0e
		sta $d021
scrl_col_5b	lda #$04
		sta $d021
scrl_col_5c	lda #$0b
		sta $d021
scrl_col_5d	lda #$06
		sta $d021
scrl_col_5e	lda #$0b
		sta $d021
scrl_col_5f	lda #$04
		sta $d021
scrl_col_5g	lda #$0e
		sta $d021
scrl_col_5h	lda #$00
		sta $d021

		ldx #$01
		dex
		bne *-$01
		nop
		nop

		lda #$14		; Upper/lower border thingy
		sta $d011

scrl_col_6a	lda #$04
		sta $d021
scrl_col_6b	lda #$0b
		sta $d021
scrl_col_6c	lda #$06
		sta $d021
scrl_col_6d	lda #$00
		sta $d021
scrl_col_6e	lda #$06
		sta $d021
scrl_col_6f	lda #$0b
		sta $d021
scrl_col_6g	lda #$04
		sta $d021
scrl_col_6h	lda #$00
		sta $d021

		ldx #$01
		dex
		bne *-$01
		nop
		nop

		lda #$14
		sta $d011

scrl_col_7a	lda #$0b
		sta $d021
scrl_col_7b	lda #$06
		sta $d021
scrl_col_7c	lda #$00
		sta $d021
scrl_col_7d	lda #$00
		sta $d021
scrl_col_7e	lda #$00
		sta $d021
scrl_col_7f	lda #$06
		sta $d021
scrl_col_7g	lda #$0b
		sta $d021
scrl_col_7h	lda #$00
		sta $d021

		lda #$0f
		sta $d021

		lda #$3f
		sta $d015

		lda #$fc
		cmp $d012
		bne *-$03
		lda #$1b
		sta $d011

; Split the sprite colours
		ldx #$03
		dex
		bne *-$01

!set line_cnt=$00
!do {

		lda split_colours+$06+line_cnt
		ldx split_colours+$0e+line_cnt
		ldy split_colours+$16+line_cnt
		sta $d027
		stx $d028
		sty $d029
		lda split_colours+$1e+line_cnt
		sta $d02a
		lda split_colours+$26+line_cnt
		sta $d02b
		lda split_colours+$2e+line_cnt
		sta $d02c
		!set line_cnt=line_cnt+$01

} until line_cnt=$16


; Update the sprite positions for the next frame
		lda cos_at_2
		clc
		adc #cos_speed_2
		sta cos_at_2
		tax
		lda sprite_cosinus,x
		clc
		adc #$64
		sta sprite_pos+$00

		txa
		clc
		adc #cos_offset_2
		tax
		lda sprite_cosinus,x
		clc
		adc #$74
		sta sprite_pos+$02

		txa
		clc
		adc #cos_offset_2
		tax
		lda sprite_cosinus,x
		clc
		adc #$84
		sta sprite_pos+$04

		txa
		clc
		adc #cos_offset_2
		tax
		lda sprite_cosinus,x
		clc
		adc #$94
		sta sprite_pos+$06

		txa
		clc
		adc #cos_offset_2
		tax
		lda sprite_cosinus,x
		clc
		adc #$a4
		sta sprite_pos+$08

		txa
		clc
		adc #cos_offset_2
		tax
		lda sprite_cosinus,x
		clc
		adc #$b4
		sta sprite_pos+$0a

		txa
		clc
		adc #cos_offset_2
		tax
		lda sprite_cosinus,x
		clc
		adc #$c4
		sta sprite_pos+$0c



; Play the music
;		inc $d020
		jsr $1003
;		dec $d020


		lda #$01
		sta rn
		lda #rstr1p
		sta $d012

ea31		pla
		tay
		pla
		tax
		pla
nmi		rti


; Self mod reset for the scroller
reset		lda #<scroll_text
		sta mread+$01
		lda #>scroll_text
		sta mread+$02
		rts


; Not-so-great tidings of joy - values from $81 to $8f set scroll speed
scroll_text	!scr $82,"hello one and all, welcome to "
		!scr "          "

		!scr $81,"-+- md201512 - humbug -+-"
		!scr "          "

		!scr $83,"yet another ",$22,"festive",$22," demo on the c64 for "
		!scr "2015, this time originating from the",$82,"not-exactly-wintery"
		!scr $81,"cosine grotto!"
		!scr "          "

		!scr $84,"code, graphics ports and tweaking by t.m.r with a "
		!scr "converted spectrum picture drawn by prof4d, the character "
		!scr "set unceremoniously yanked from air rescue on the sega "
		!scr "master system and some appropriate-sounding music from tonka "
		!scr "(who is still, technically, a member of cosine!)"
		!scr "          "

		!scr $83,"it's t.m.r writing in this winter ",$22,"wonderland",$22,", but "
		!scr "i really don't do the whole christmas thing.    in fact it's just me "
		!scr "and my beloved this year for a small dinner and a quiet evening in "
		!scr "front of the telly for doctor who, strictly and call the midwife, "
		!scr "but that works for me and the closest i'll get to watching a "
		!scr "christmas movie this year will be die hard!"
		!scr "          "

		!scr "in fact, if i can avoid leaving the house until the shops aren't "
		!scr "complete bedlam then that'll be even better!   i know all of this "
		!scr "makes me sound like a grinch, but i don't see the point in pretending "
		!scr "to enjoy listening to",$82,$22,"santa baby",$22,$83,"for the "
		!scr "fourth damned time whilst browsing twee christmas tat...    "
		!scr $81,"in early feckin' november!"
		!scr "          "

		!scr $82,"how exactly does ",$22,"do they know it's christmas",$22," or "
		!scr $22,"stop the cavalry",$22," count as a festive song anyway?    "
		!scr "they're about famine in africa and the futility of war, so even "
		!scr $22,"i'm gonna spend my christmas with a dalek",$22," by the go-gos "
		!scr "is more bloody festive than that!!"
		!scr "          "

		!scr $84,"ahem...      ooo-kay, that'll be enough ranting from me for now "
		!scr "which probably means we should get around to handing out presents...    "
		!scr "and by ",$22,"presents",$22," i really mean "
		!scr $22,"greetings",$22,"!"
		!scr "          "

		!scr $82,"cosine shout ",$22,"bah, humbug",$22," in the general "
		!scr "direction of..."
		!scr "          "
		!scr $85,"abyss connection -+- "
		!scr "arkanix labs -+- "
		!scr "artstate -+- "
		!scr "ate bit -+- "
		!scr "booze design -+- "
		!scr "camelot -+- "
		!scr "chorus -+- "
		!scr "chrome -+- "
		!scr "cncd -+- "
		!scr "cpu -+- "
		!scr "crescent -+- "
		!scr "crest -+- "
		!scr "covert bitops -+- "
		!scr "defence force -+- "
		!scr "dekadence -+- "
		!scr "desire -+- "
		!scr "dac -+- "
		!scr "dmagic -+- "
		!scr "dualcrew -+- "
		!scr "exclusive on -+- "
		!scr "fairlight -+- "
		!scr "fire -+- "
		!scr "focus -+- "
		!scr "french touch -+- "
		!scr "funkscientist productions -+- "
		!scr "genesis project -+- "
		!scr "gheymaid inc. -+- "
		!scr "hitmen -+- "
		!scr "hokuto force -+- "
		!scr "level64 -+- "
		!scr "maniacs of noise -+- "
		!scr "meanteam -+- "
		!scr "metalvotze -+- "
		!scr "noname -+- "
		!scr "nostalgia -+- "
		!scr "nuance -+- "
		!scr "offence -+- "
		!scr "onslaught -+- "
		!scr "orb -+- "
		!scr "oxyron -+- "
		!scr "padua -+- "
		!scr "plush -+- "
		!scr "psytronik -+- "
		!scr "reptilia -+- "
		!scr "resource -+- "
		!scr "rgcd -+- "
		!scr "secure -+- "
		!scr "shape -+- "
		!scr "side b -+- "
		!scr "slash -+- "
		!scr "slipstream -+- "
		!scr "success and trc -+- "
		!scr "style -+- "
		!scr "suicyco industries -+- "
		!scr "taquart -+- "
		!scr "tempest -+- "
		!scr "tek -+- "
		!scr "triad -+- "
		!scr "trsi -+- "
		!scr "viruz -+- "
		!scr "vision -+- "
		!scr "wow -+- "
		!scr "wrath -+- "
		!scr "xenon -+- "
		!scr "and to all of the groups who have no doubt put us on their various "
		!scr "naughty lists for not greeting them!"
		!scr "          "

		!scr $82,"don't forget to visit the cosine website at"
		!scr $81,"    cosine.org.uk    ",$82,"for more 8-bit goodness by the way, "
		!scr "we promise it won't have any fake snow or a santa hat on the logo!"
		!scr "          "

		!scr $83,"the end of the greets means we're pretty much spent for this one, "
		!scr "so this was the unusually verbose but rather un-merry t.m.r of cosine, "
		!scr "signing off on christmas day 2015... .. .  ."
		!scr "                    "

		!byte $00


; Scroll colours
		* = ((*/$100)+1)*$100
split_colours	!byte $06,$06,$00,$06,$00,$00

		!byte $00,$00,$09,$00,$09,$09,$02,$09
		!byte $02,$02,$08,$02,$08,$08,$0a,$08
		!byte $0a,$0a,$0f,$0a,$0f,$0f,$07,$0f
		!byte $07,$07,$01,$07,$01,$01,$0d,$01
		!byte $0d,$0d,$03,$0d,$03,$03,$05,$03
		!byte $05,$05,$0e,$05,$0e,$0e,$04,$0e
		!byte $0e,$0e,$0b,$0e,$0b,$0b,$06,$0b
		!byte $06,$06,$00,$06,$00,$00,$00,$00

		!byte $00,$00,$09,$00,$09,$09,$09,$09

; Sprite positions and data pointers
sprite_pos	!byte $20,$fc,$30,$fc,$40,$fc,$50,$fc
		!byte $60,$fc,$70,$fc,$80,$00,$90,$00
		!byte $00

sprite_dps	!byte $a8,$b5,$ad,$a2,$b5,$a7,$bb,$a1

; Scroll colour cosinus
		* = ((*/$100)+1)*$100
scr_col_cosinus	!byte $46,$46,$46,$46,$46,$46,$46,$46
		!byte $46,$46,$45,$45,$45,$45,$44,$44
		!byte $44,$43,$43,$43,$42,$42,$41,$41
		!byte $41,$40,$3f,$3f,$3e,$3e,$3d,$3d
		!byte $3c,$3b,$3b,$3a,$39,$39,$38,$37
		!byte $37,$36,$35,$34,$34,$33,$32,$31
		!byte $31,$30,$2f,$2e,$2d,$2c,$2c,$2b
		!byte $2a,$29,$28,$27,$26,$26,$25,$24

		!byte $23,$22,$21,$20,$1f,$1f,$1e,$1d
		!byte $1c,$1b,$1a,$19,$19,$18,$17,$16
		!byte $15,$15,$14,$13,$12,$11,$11,$10
		!byte $0f,$0e,$0e,$0d,$0c,$0c,$0b,$0a
		!byte $0a,$09,$09,$08,$07,$07,$06,$06
		!byte $05,$05,$04,$04,$04,$03,$03,$03
		!byte $02,$02,$02,$01,$01,$01,$01,$00
		!byte $00,$00,$00,$00,$00,$00,$00,$00

		!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $00,$00,$01,$01,$01,$01,$02,$02
		!byte $02,$03,$03,$03,$04,$04,$05,$05
		!byte $06,$06,$07,$07,$08,$08,$09,$09
		!byte $0a,$0b,$0b,$0c,$0d,$0d,$0e,$0f
		!byte $0f,$10,$11,$12,$12,$13,$14,$15
		!byte $16,$16,$17,$18,$19,$1a,$1b,$1b
		!byte $1c,$1d,$1e,$1f,$20,$21,$21,$22

		!byte $23,$24,$25,$26,$27,$28,$28,$29
		!byte $2a,$2b,$2c,$2d,$2d,$2e,$2f,$30
		!byte $31,$32,$32,$33,$34,$35,$35,$36
		!byte $37,$38,$38,$39,$3a,$3a,$3b,$3c
		!byte $3c,$3d,$3d,$3e,$3f,$3f,$40,$40
		!byte $41,$41,$42,$42,$42,$43,$43,$44
		!byte $44,$44,$45,$45,$45,$45,$45,$46
		!byte $46,$46,$46,$46,$46,$46,$46,$46

; Sprite movement cosinus
sprite_cosinus	!byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
		!byte $3f,$3f,$3f,$3e,$3e,$3e,$3e,$3d
		!byte $3d,$3d,$3c,$3c,$3c,$3b,$3b,$3b
		!byte $3a,$3a,$39,$39,$38,$38,$37,$37
		!byte $36,$36,$35,$34,$34,$33,$33,$32
		!byte $31,$31,$30,$2f,$2f,$2e,$2d,$2c
		!byte $2c,$2b,$2a,$29,$29,$28,$27,$26
		!byte $26,$25,$24,$23,$23,$22,$21,$20

		!byte $1f,$1f,$1e,$1d,$1c,$1c,$1b,$1a
		!byte $19,$18,$18,$17,$16,$15,$15,$14
		!byte $13,$12,$12,$11,$10,$10,$0f,$0e
		!byte $0e,$0d,$0c,$0c,$0b,$0b,$0a,$09
		!byte $09,$08,$08,$07,$07,$06,$06,$05
		!byte $05,$04,$04,$04,$03,$03,$03,$02
		!byte $02,$02,$01,$01,$01,$01,$00,$00
		!byte $00,$00,$00,$00,$00,$00,$00,$00

		!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $00,$00,$00,$01,$01,$01,$01,$02
		!byte $02,$02,$03,$03,$03,$04,$04,$05
		!byte $05,$05,$06,$06,$07,$07,$08,$08
		!byte $09,$0a,$0a,$0b,$0b,$0c,$0d,$0d
		!byte $0e,$0f,$0f,$10,$11,$11,$12,$13
		!byte $13,$14,$15,$16,$16,$17,$18,$19
		!byte $19,$1a,$1b,$1c,$1d,$1d,$1e,$1f

		!byte $20,$20,$21,$22,$23,$24,$24,$25
		!byte $26,$27,$27,$28,$29,$2a,$2a,$2b
		!byte $2c,$2d,$2d,$2e,$2f,$2f,$30,$31
		!byte $31,$32,$33,$33,$34,$35,$35,$36
		!byte $36,$37,$37,$38,$38,$39,$39,$3a
		!byte $3a,$3b,$3b,$3b,$3c,$3c,$3d,$3d
		!byte $3d,$3d,$3e,$3e,$3e,$3e,$3f,$3f
		!byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
