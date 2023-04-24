#sccs	"@(#)uts/kern/io:rastop.m4	1.1"

 # General RasterOp Primitive
 # E. A. Hahn, February, 1984
 #
 #      xrastop( SrcBase, SrcWidth, DstBase, DstWidth,
 #		SrcX,    SrcY,     DstX,    DstY,
 #		Width,   Height,   SrcOp,   DstOp,
 #	        Pattern
 #	      )
 #
 #	The Bases and Pattern are pointers to shorts
 #	The Src/Dst Widths are in bytes
 #	The coordinates and Width/Height are in pixels
 #	The Ops are controls
 #
 #	If this module is compiled with SMALLROP, it gets smaller
 #	by omitting most of the source, destination operations leaving
 #	only SRCSRC and PATSRC.

undefine(`shift')

#define SrcBase		8(%a6)
#define SrcWidth	14(%a6)
#define DstBase		16(%a6)
#define DstWidth	22(%a6)
#define SrcX		26(%a6)
#define SrcY		30(%a6)
#define DstX		34(%a6)
#define DstY		38(%a6)
#define Width		42(%a6)
#define Height		46(%a6)
#define SrcOp		50(%a6)
#define DstOp		54(%a6)
#define Pattern		56(%a6)

					# Locals (all allocated as longs)
#define SavedHeight	-4(%a6)
#define DstWords	-8(%a6)
#define ShiftMask	-12(%a6)
#define SrcPat		-16(%a6)

#define SrcFstMask	-20(%a6)
#define SrcLstMask	-24(%a6)
#define DstFstMask	-28(%a6)
#define DstLstMask	-32(%a6)

#define SrcFstBit	-36(%a6)
#define SrcLstBit	-40(%a6)
#define DstFstBit	-44(%a6)
#define DstLstBit	-48(%a6)

	data
	even

	global	syspat,patwhite,patblack,patgray

syspat:				# System Pattern Table
	long	patblack		# PATBLACK (0)
	long	patwhite		# PATWHITE (1)
	long	patgray			# PATGRAY  (2)
	long	patltgray		# PATLTGRAY(3)

patblack:			# All Pixels off
	short	0x0000,0x0000,0x0000,0x0000
	short	0x0000,0x0000,0x0000,0x0000
	short	0x0000,0x0000,0x0000,0x0000
	short	0x0000,0x0000,0x0000,0x0000

patwhite:			# All Pixels on
	short	0xFFFF,0xFFFF,0xFFFF,0xFFFF
	short	0xFFFF,0xFFFF,0xFFFF,0xFFFF
	short	0xFFFF,0xFFFF,0xFFFF,0xFFFF
	short	0xFFFF,0xFFFF,0xFFFF,0xFFFF

patgray:			# Every other Pixel on
	short	0xAAAA,0x5555,0xAAAA,0x5555
	short	0xAAAA,0x5555,0xAAAA,0x5555
	short	0xAAAA,0x5555,0xAAAA,0x5555
	short	0xAAAA,0x5555,0xAAAA,0x5555

patltgray:			# Lighter gray
#ifdef WHITE
	short	0xEEEE,0xFFFF,0xEEEE,0xFFFF
	short	0xEEEE,0xFFFF,0xEEEE,0xFFFF
	short	0xEEEE,0xFFFF,0xEEEE,0xFFFF
	short	0xEEEE,0xFFFF,0xEEEE,0xFFFF
#else
	short	0x1111,0x0000,0x1111,0x0000
	short	0x1111,0x0000,0x1111,0x0000
	short	0x1111,0x0000,0x1111,0x0000
	short	0x1111,0x0000,0x1111,0x0000
#endif


set	SrcOpPattern,1

#ifndef SMALLROP
OpTable:			# Forward Versions
	long	FSrcSrc, FPatSrc, FAndSrc, FOrSrc
	long	FXorSrc, RastErr, RastErr, RastErr
	long	FSrcAnd, FPatAnd, FAndAnd, FOrAnd
	long	FXorAnd, RastErr, RastErr, RastErr
	long	FSrcOr, FPatOr, FAndOr, FOrOr
	long	FXorOr, RastErr, RastErr, RastErr
	long	FSrcXor, FPatXor, FAndXor, FOrXor
	long	FXorXor, RastErr, RastErr, RastErr
	long	FSrcCand, FPatCand, FAndCand, FOrCand
	long	FXorCand, RastErr, RastErr, RastErr

BOpTable:			# Backward Versions
	long	BSrcSrc, RastErr, BAndSrc, BOrSrc
	long	BXorSrc, RastErr, RastErr, RastErr
	long	BSrcAnd, RastErr, BAndAnd, BOrAnd
	long	BXorAnd, RastErr, RastErr, RastErr
	long	BSrcOr, RastErr, BAndOr, BOrOr
	long	BXorOr, RastErr, RastErr, RastErr
	long	BSrcXor, RastErr, BAndXor, BOrXor
	long	BXorXor, RastErr, RastErr, RastErr
	long	BSrcCand, RastErr, BAndCand, BOrCand
	long	BXorCand, RastErr, RastErr, RastErr
#else
OpTable:			# Forward Versions
	long	FSrcSrc, FPatSrc, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr

BOpTable:			# Backward Versions
	long	BSrcSrc, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
	long	RastErr, RastErr, RastErr, RastErr
#endif

FstMaskTab:	
	short	0xFFFF,0xFFFE,0xFFFC,0xFFF8
	short	0xFFF0,0xFFE0,0xFFC0,0xFF80
	short	0xFF00,0xFE00,0xFC00,0xF800
	short	0xF000,0xE000,0xC000,0x8000

	global	ForwardMask			# used by rastex

ForwardMask:
	short	0x0000				# rest is LstMaskTab

LstMaskTab:
	short	0x0001,0x0003,0x0007,0x000F
	short	0x001F,0x003F,0x007F,0x00FF
	short	0x01FF,0x03FF,0x07FF,0x0FFF
	short	0x1FFF,0x3FFF,0x7FFF,0xFFFF

ReverseMask:
	short	0x0000,0xFFFE,0xFFFC,0xFFF8
	short	0xFFF0,0xFFE0,0xFFC0,0xFF80
	short	0xFF00,0xFE00,0xFC00,0xF800
	short	0xF000,0xE000,0xC000,0x8000

	even
	text

 # Main entry point.  First, compute bit positions of first and last
 # points in the rectangle.

#ifdef DEBUGPRINT
	global	xrastop
xrastop:

#else
	global	rastop
rastop:

#endif
	link	%a6,&-104		# 48 locals, 56 (14*4) registers
	movm.l	&0x3FFF,-104(%a6)	# save the D0-D7, A0-A5

	sub.w	&1, Width		# convert width/height to offsets
	bcs	RastRet			# width must not be 0
	mov.w	Width,%d2
	mov.w	Height,SavedHeight	# get a copy of the height
	sub.w	&1,Height
	bcs	RastRet			# height must not be 0

 # In the code below, D1=&0xF and D2=Width.  Towards the end, D3 is
 # set to a copy of DstLstBit before being truncated to 4 bits.

	mov.w	&0xF,%d1
	mov.w	SrcX,%d0		# compute bit positions of xy pairs
	and.w	%d1,%d0
	mov.w	%d0,SrcFstBit
	add.w	%d2,%d0			# and of final xy pairs
	and.w	%d1,%d0
	mov.w	%d0,SrcLstBit

	mov.w	DstX,%d0
	and.w	%d1,%d0
	mov.w	%d0,DstFstBit
	add.w	%d2,%d0
	mov.w	%d0,%d3			# save a copy before the modulo
	and.w	%d1,%d0
	mov.w	%d0,DstLstBit

 # Compute the number of words wide in the destination rectangle from
 # (DstFirstBit+Width-1)/16 + 1.  The parenthetical quantity is in D3.

	lsr.w	&4,%d3
	add.w	&1,%d3
	mov.w	%d3,DstWords

 # Compute the number of bit places which must be shifted by subtracting
 # the two bit position quantities (DstLstBit-SrcLstBit) modulo the word
 # size (16), save it in D0 forever.  Also set the fNeedRem flag to false
 # in D7.

	sub.w	SrcLstBit,%d0
	and.w	%d1,%d0
	clr.l	%d7

 # Compute the pattern alignement 2*( DstY MOD 16 )

	mov.w	DstY,%d2
	and.w	%d1,%d2
	add.w	%d2,%d2
	mov.w	%d2,SrcPat

 # Now D0=rotate count, D7=flags=0
 # Compute the direction of the rasterop (forwards or backwards) in the
 # fBack flag.  Since D7 already has 0, the fBack flag is false, indicating
 # a forward direction.

	cmp.w	SrcOp,&SrcOpPattern	# source a simple pattern? 
	beq	Forward			# yes - forward is fine
	mov.l	SrcBase,%d1		# src & dst in different maps?
	cmp.l	%d1,DstBase 
	bne	Forward			# yes - forward is fine
	mov.w	DstY,%d1		# no - check which is sooner
	cmp.w	%d1,SrcY 
	bgt	Backward		# dest is greater, go backwards
	blt	Forward			# dest is lesser, go forwards
	mov.w	DstX,%d1		# too close, must check Xs
	cmp.w	%d1,SrcX 
	ble	Forward

 # If we're going backwards, adjust the xy pairs to be at the lower
 # right of the rectangle instead of the upper-left.

Backward:
	bset	&0,%d7			# light the backwards bit
	mov.w	Width,%d2		# get the width
	add.w	%d2,SrcX		# offset
	add.w	%d2,DstX
	mov.w	Height,%d2
	add.w	%d2,SrcY
	add.w	%d2,DstY

 # Compute the src and dst masks given the bit positions
 # D0 still has rotate count.

	mov.w	DstFstBit,%d2		# get dest first bit
	add.w	%d2,%d2
	mov.l	&FstMaskTab,%a0		# get base of table
	mov.w	0(%a0,%d2.w),%d1	# get the mask
	mov.w	%d1,SrcLstMask		# save it
	not.w	%d1
	mov.w	%d1,DstLstMask

	mov.w	DstLstBit,%d2
	add.w	%d2,%d2
	mov.l	&LstMaskTab,%a0
	mov.w	0(%a0,%d2.w),%d1
	mov.w	%d1,SrcFstMask
	not.w	%d1
	mov.w	%d1,DstFstMask

 # Compute SrcLine = -SrcWidth + (2*DstWords)
 #	   DstLine = -DstWidth + (2*DstWords)
 # D0 still has rotate count.
 # Note that SrcLine and DstLine are sign-extended longs.

	mov.w	DstWords,%d2
	add.w	%d2,%d2
	mov.w	DstWidth,%d1
	neg.w	%d1
	add.w	%d2,%d1
	ext.l	%d1
	mov.l	%d1,%a5

	cmp.w	SrcOp,&SrcOpPattern	# source a simple pattern? 
	beq	NoSrc

	mov.w	SrcWidth,%d1
	neg.w	%d1
	add.w	%d2,%d1
	ext.l	%d1
	mov.l	%d1,%a4

 # If SrcLstBit < DstLstBit then light the fNeedRem flag in D7 and
 # step SrcLine forward by 2 bytes.
 # D0 still has rotate count.

	mov.w	SrcLstBit,%d1
	cmp.w	%d1,DstLstBit 
	bge	XX1
	bset	&1,%d7
	add.l	&2,%a4

 # Use rotate count (still in D0) to find the ReverseMask entry

XX1:	mov.w	%d0,%d1			# don't hurt d0
	add.w	%d1,%d1
	mov.l	&ReverseMask,%a0
	mov.w	0(%a0,%d1.w),ShiftMask	# record the entry
	bra	Rast1			# and merge with normal code

 # Here when we're going forward.

Forward:
 # Compute the src and dst masks given the bit positions
 # D0 still has rotate count.

	mov.w	DstFstBit,%d2		# get dest first bit
	add.w	%d2,%d2
	mov.l	&FstMaskTab,%a0		# get base of table
	mov.w	0(%a0,%d2.w),%d1	# get the mask
	mov.w	%d1,SrcFstMask		# save it
	not.w	%d1
	mov.w	%d1,DstFstMask

	mov.w	DstLstBit,%d2
	add.w	%d2,%d2
	mov.l	&LstMaskTab,%a0
	mov.w	0(%a0,%d2.w),%d1
	mov.w	%d1,SrcLstMask
	not.w	%d1
	mov.w	%d1,DstLstMask

 # Compute SrcLine = SrcWidth - (2*DstWords)
 #	   DstLine = DstWidth - (2*DstWords)
 # D0 still has rotate count.
 # Note that SrcLine and DstLine are sign-extended longs.

	mov.w	DstWords,%d2
	add.w	%d2,%d2
	mov.w	DstWidth,%d1
	sub.w	%d2,%d1
	ext.l	%d1
	mov.l	%d1,%a5

 # If the source is just the pattern, skip all this

	cmp.w	SrcOp,&SrcOpPattern	# skip all this if no source 
	beq	NoSrc

	mov.w	SrcWidth,%d1
	sub.w	%d2,%d1
	ext.l	%d1
	mov.l	%d1,%a4

 # If DstFstBit < SrcFstBit then light the fNeedRem flag in D7 and
 # step SrcLine backward by 2 bytes.
 # D0 still has rotate count.

	mov.w	DstFstBit,%d1
	cmp.w	%d1,SrcFstBit 
	bge	XX2
	bset	&1,%d7
	sub.l	&2,%a4

 # Use rotate count (still in D0) to find the ReverseMask entry

XX2:	mov.w	%d0,%d1			# don't hurt d0
	add.w	%d1,%d1
	mov.l	&ForwardMask,%a0
	mov.w	0(%a0,%d1.w),ShiftMask	# record the entry

 # Compute the raw memory address of the source pointer in A0, as
 # follows	SrcRaw=A0=SrcBase + SrcY*SrcWidth + (SrcX/8 AND 0xFE)

Rast1:
	mov.w	SrcY,%d1
	mulu.w	SrcWidth,%d1		# produces a long (hi part of d1=0)
	mov.w	SrcX,%d2
	lsr.w	&3,%d2
	and.l	&0xFE,%d2		# produces a long
	add.l	%d2,%d1
	mov.l	SrcBase,%a0
	add.l	%d1,%a0

 # Do the same for the destination, DstRaw into A1

NoSrc:
	mov.w	DstY,%d1
	mulu.w	DstWidth,%d1
	mov.w	DstX,%d2
	lsr.w	&3,%d2
	and.l	&0xFE,%d2
	add.l	%d2,%d1
	mov.l	DstBase,%a1
	add.l	%d1,%a1

 # Compute a hash index of the two functions, SrcOp and DstOp as follows:
 #	CombinedOp = 8*DstOp + SrcOp
 # This will be used to jump through a table.
 # A0 has the SrcRaw and A1 has DstRaw at this point.
 # D0 has the rotate count and D7 has the flags.

	mov.w	DstOp,%d1
	lsl.w	&3,%d1
	or.w	SrcOp,%d1

 # Check if SrcOp is Src and DstOp is STORE.  If so, check further to see
 # if the rotate count is zero.  If so, branch off to a very fast special
 # case.  For all other cases, compute the inner loop address in A2.

	bne	NotFast
	tst.w	%d0
	bne	NotFast
	jmp	Fast

NotFast:
	bclr	&0,%d7			# check D7 for backwardsness
	beq	SlowForward		# if zero, its forward

SlowBackward:
	add.l	&2,%a0			# fix 68K predecrement
	add.l	&2,%a1
	add.w	&40,%d1			# if backwards, step to latter table
					# (40 = BopTable-OpTable)

SlowForward:
	mov.w	ShiftMask,%d6		# D6 = shift mask
	lsl.w	&2,%d1			# 4 bytes/entry
	mov.l	&OpTable,%a2
	mov.l	0(%a2,%d1.w),%d1
	mov.l	%d1,%a2			# A2 = inner loop address
	mov.l	Pattern,%a3		# A3 = pattern address
	jmp	(%a2)

Fast:
	bclr	&0,%d7
	beq	FFast
	add.l	&2,%a0			# fix 68K predecrement
	add.l	&2,%a1
	jmp	BFast

RastErr:
RastRet:
	movm.l	-104(%a6),&0x3FFF	# restore D0-D7, A0-A5
	unlk	%a6
	rts

 # These are the inner loops

 # Throughout this code:
 #
 # A0 = Src pointer (SrcRaw)
 # A1 = Dst pointer (DstRaw)
 # A2 = Inner Loop Routine Address
 # A3 = Base of Pattern Table
 # A4 = Src Line Increment
 # A5 = Dst Line Increment
 #
 # D0 = Rotate Count
 # D1 = Assembled Word
 # D2 = Aligned Pattern
 # D3 = Remainder for next iteration
 # D4 = General counter (esp for loop mode)
 # D5 = Temp (esp manipulations with DstWords)
 # D6 = ShiftMask
 # D7 = Need Rem Flag

define(RasterLoop,`

 #*****************************************************************************
 #
 #	INNER LOOP, Source Op=$1, Dest Op=$2, -=$3, +=$4, local symbol=$5
 #
 #*****************************************************************************

ifelse($4,`+',`
	global F$1$2
F$1$2:
ifelse($1,Pat,`
ifelse($2,Src,`
	cmp.l	%a3,&0		# check for fast pattern of zeros 
	beq	FZerSrc
')')
',`
	global B$1$2
B$1$2:
')
$51:
ifelse($1,Pat,,`
ifelse($1,Src,,`
	mov.w	SrcPat,%d1		# get source pattern alignment
	mov.w	0(%a3,%d1.w),%d2	# get pattern
	add.w	&2,%d1			# step to next pattern
	and.w	&0x1E,%d1		# mod 2*16
	mov.w	%d1,SrcPat		# update
')')
ifelse($1,Pat,`
	mov.w	SrcPat,%d1		# get source pattern alignment
	mov.w	0(%a3,%d1.w),%d3	# get pattern
	add.w	&2,%d1			# step to next pattern
	and.w	&0x1E,%d1		# mod 2*16
	mov.w	%d1,SrcPat		# update
	mov.w	%d3,%d1			# set up current word=remainder
',`					/* Source is not pattern */
	clr.w	%d3
	tst.l	%d7
	beq	$52
ifelse($1,Src,`				/* Source is Src */
	mov.w	$3(%a0)$4,%d3		# go directly into remainder
	rol.w	%d0,%d3
',`					/* Source is not Src, not Pat */
SrcProc($1,%d1,$3,$4)
	mov.w	%d1,%d3			# save remainder
')
	and.w	%d6,%d3			# mask off, leaving remainder in d3
$52:
SrcProc($1,%d2,$3,$4)
	exg	%d1,%d3			# D1 gets remainder from previous word
	eor.w	%d3,%d1
	and.w	%d6,%d3			# D3 gets remainder for next word
	eor.w	%d3,%d1			# D1 gets comb. of old rem. and current
')
	and.w	SrcFstMask,%d1		# mask with Fst word mask
ifelse($2,Xor,,`
ifelse($2,Cand,,`
ifelse($4,+,`
	mov.w	(%a1),%d5		# get first destination word
',`
	mov.w	-2(%a1),%d5		# get first destination word
')
	and.w	DstFstMask,%d5		# plug in unchanged part
	or.w	%d5,%d1
')')
ifelse($1,Pat,,`			/* Src is not pattern */
	mov.w	DstWords,%d5		# normal move operation
	sub.w	&1,%d5			# while DstWords > 1
	beq	$54
$53:
DstProc($2,$3,$4)
SrcProc($1,%d2,$3,$4)
	exg	%d1,%d3			# D1 gets remainder from previous word
	eor.w	%d3,%d1
	and.w	%d6,%d3			# D3 gets remainder for next word
	eor.w	%d3,%d1			# D1 gets comb. of old rem. and current
	sub.w	&1,%d5
	bne	$53
')
ifelse($1,Pat,`
	mov.w	DstWords,%d4		# case of SrcPat and nil Dest op
	sub.w	&1,%d4
	beq	$54
ifelse($2,Src,`
	mov.w	%d1,$3(%a1)$4		# store first word
	mov.w	%d3,%d1
	sub.w	&2,%d4
	blt	$54
$55:	mov.w	%d1,$3(%a1)$4		# rapidly store all but last
	dbf	%d4,$55
',`
$53:
DstProc($2,$3,$4)
	mov.w	%d3,%d1
	sub.w	&1,%d4
	bne	$53
')')
$54:
	and.w	SrcLstMask,%d1		# store last word under mask
ifelse($2,Xor,,`
ifelse($2,Cand,,`
ifelse($4,+,`
	mov.w	(%a1),%d5		# get first destination word
',`
	mov.w	-2(%a1),%d5		# get first destination word
')
	and.w	DstLstMask,%d5
	or.w	%d5,%d1			# plug in unchanged part of dest
')')
DstProc($2,$3,$4)

 #	SrcRaw=SrcRaw + SrcLine
 #	DstRaw=DstRaw + DstLine
 #	SavedHeight--

ifelse($1,Pat,,`
	add.l	%a4,%a0
')
	add.l	%a5,%a1
	sub.w	&1,SavedHeight
	bne	$51
	jmp	RastRet
')


define(DstProc,`
ifelse($1,Src,`
	mov.w	%d1,$2(%a1)$3
')
ifelse($1,And,`
	and.w	%d1,$2(%a1)$3
')
ifelse($1,Or,`
	or.w	%d1,$2(%a1)$3
')
ifelse($1,Xor,`
	eor.w	%d1,$2(%a1)$3
')
ifelse($1,Cand,`
	not.w	%d1
	and.w	%d1,$2(%a1)$3
')
')

define(SrcProc,`
ifelse($1,Src,`
	mov.w	$3(%a0)$4,%d1
	rol.w	%d0,%d1
')

ifelse($1,And,`
	mov.w	$3(%a0)$4,%d1
	rol.w	%d0,%d1
	and.w	$2,%d1
')

ifelse($1,Or,`
	mov.w	$3(%a0)$4,%d1
	rol.w	%d0,%d1
	or.w	$2,%d1
')

ifelse($1,Xor,`
	mov.w	$3(%a0)$4,%d1
	rol.w	%d0,%d1
	eor.w	$2,%d1
')
')


define(FastLoop,`

 # Optimized routine for case of no shift and just moving (scrolling)
 # Direction = $1

	global	$1Fast

$1Fast:
	mov.w	SavedHeight,%d3

$1FZ1:
	mov.w	$2(%a0)$3,%d1		# Fetch first source
	and.w	SrcFstMask,%d1		# mask with first mask
ifelse($3,+,`
	mov.w	(%a1),%d5		# get first destination word
',`
	mov.w	-2(%a1),%d5		# get first destination word
')
	and.w	DstFstMask,%d5
	or.w	%d5,%d1			# plug in unchanged

	mov.w	DstWords,%d4
	sub.w	&1,%d4
	beq	$1FZ4
	mov.w	%d1,$2(%a1)$3
	sub.w	&2,%d4
	blt	$1FZ3

$1FZ2:	mov.w	$2(%a0)$3,$2(%a1)$3
	dbf	%d4,$1FZ2

$1FZ3:	mov.w	$2(%a0)$3,%d1
$1FZ4:	and.w	SrcLstMask,%d1
ifelse($3,+,`
	mov.w	(%a1),%d5		# get first destination word
',`
	mov.w	-2(%a1),%d5		# get first destination word
')
	and.w	DstLstMask,%d5
	or.w	%d5,%d1
	mov.w	%d1,$2(%a1)$3

 #	rawSrc=rawSrc + dbLineSrc;
 #	rawDst=rawDst + dbLineDst;
 #	dy=dy - 1;

	add.l	%a4,%a0
	add.l	%a5,%a1
	sub.w	&1,%d3
	bne	$1FZ1
	jmp	RastRet
')

 # Optimized case of Clearing Dest

	global	FZerSrc

FZerSrc:
	

ZZ1:	mov.w	(%a1),%d1
	and.w	DstFstMask,%d1
	mov.w	DstWords,%d4
	sub.w	&1,%d4
	beq	ZZ3

	mov.w	%d1,(%a1)+
	clr.w	%d1
	sub.w	&2,%d4
	blt	ZZ3

ZZ2:	clr.w	(%a1)+
	dbf	%d4,ZZ2

ZZ3:	and.w	SrcLstMask,%d1
	mov.w	(%a1),%d5
	and.w	DstLstMask,%d5
	or.w	%d5,%d1
	mov.w	%d1,(%a1)+
	add.l	%a5,%a1
	sub.w	&1,SavedHeight
	bne	ZZ1
	jmp 	RastRet

	
FastLoop(F, ,+)
FastLoop(B,-, )

RasterLoop(Src,Src, ,+,R1)
RasterLoop(Pat,Src, ,+,R2)

#ifndef SMALLROP
RasterLoop(And,Src, ,+,R3)
RasterLoop(Or,Src, ,+,R4)
RasterLoop(Xor,Src, ,+,R5)
RasterLoop(Src,And, ,+,R6)
RasterLoop(Pat,And, ,+,R7)
RasterLoop(And,And, ,+,R8)
RasterLoop(Or,And, ,+,R9)
RasterLoop(Xor,And, ,+,R10)
RasterLoop(Src,Or, ,+,R11)
RasterLoop(Pat,Or, ,+,R12)
RasterLoop(And,Or, ,+,R13)
RasterLoop(Or,Or, ,+,R14)
RasterLoop(Xor,Or, ,+,R15)
RasterLoop(Src,Xor, ,+,R16)
RasterLoop(Pat,Xor, ,+,R17)
RasterLoop(And,Xor, ,+,R18)
RasterLoop(Or,Xor, ,+,R19)
RasterLoop(Xor,Xor, ,+,R20)
RasterLoop(Src,Cand, ,+,R21)
RasterLoop(Pat,Cand, ,+,R22)
RasterLoop(And,Cand, ,+,R23)
RasterLoop(Or,Cand, ,+,R24)
RasterLoop(Xor,Cand, ,+,R25)
#endif

RasterLoop(Src,Src,-, ,R26)

#ifndef SMALLROP
RasterLoop(And,Src,-, ,R27)
RasterLoop(Or,Src,-, ,R28)
RasterLoop(Xor,Src,-, ,R29)
RasterLoop(Src,And,-, ,R30)
RasterLoop(And,And,-, ,R31)
RasterLoop(Or,And,-, ,R32)
RasterLoop(Xor,And,-, ,R33)
RasterLoop(Src,Or,-, ,R34)
RasterLoop(And,Or,-, ,R35)
RasterLoop(Or,Or,-, ,R36)
RasterLoop(Xor,Or,-, ,R37)
RasterLoop(Src,Xor,-, ,R38)
RasterLoop(And,Xor,-, ,R39)
RasterLoop(Or,Xor,-, ,R40)
RasterLoop(Xor,Xor,-, ,R41)
RasterLoop(Src,Cand,-, ,R42)
RasterLoop(And,Cand,-, ,R43)
RasterLoop(Or,Cand,-, ,R44)
RasterLoop(Xor,Cand,-, ,R45)
#endif
