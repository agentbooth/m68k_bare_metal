#ifndef _KBD_H
#define _KBD_H

/* Keyboard Output Codes				*/
#define KBDRST	0x92		/* reset		*/
#define CAPLED	0xB0		/* caplck (b0=0 b1=1)	*/
#define NUMLED	0xA0		/* numlck (a0=0 a1=1)	*/

/* Keyboard/Mouse Codes						*/
#define MSENABLE	0xD0	/* enable mouse			*/
#define MSDISABLE	0xD1	/* disable mouse		*/
#define BEGMOUSE	0xCE	/* mouse data follows		*/
#define BEGEMOUSE	0xCF	/* mouse data lost		*/
#define BEGKBD		0xDF	/* kbd data follows		*/

/* Bits in the mouse byte #1					*/
#define MBUTR	0x01			/* right button down	*/
#define MBUTM	0x02			/* middle button down	*/
#define MBUTL	0x04			/* left button down	*/
#define MSY	0x08			/* sign of Y		*/
#define MSX	0x10			/* sign of X		*/
#define MBUTALL	(MBUTL|MBUTM|MBUTR)	/* all the buttons	*/


#endif
