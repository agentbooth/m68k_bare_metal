#ifndef _3B1_H
#define _3B1_H

#define MAPRAM_START  ((unsigned short *)0x400000)
#define MAPRAM_END    ((unsigned short *)0x4007ff)
#define VRAM_START    ((unsigned short *)0x420000)
#define VRAM_END      ((unsigned short *)0x427fff)
#define BSR0          0x430000
#define BSR1          0x440000
#define TSR           0x450000
#define DMACOUNT      0x460000
#define LPSTATUS      0x470000
#define LPSTATBYTE    0x470001
#define DISKCONTROL   0x4e0000
#define CSR           0x4c0000
#define MCR           ((volatile unsigned short *)0x4a0000)
#define DMA_ADDR      0x4d0000
#define WD1010        0xe00000
#define WD2797        0xe10000
#define MODEM         0xe60000
#define KBC           ((volatile unsigned short *)0xe70000)
#define KBDATA        ((volatile unsigned short *)0xe70002)
#define ROMLMAP       ((volatile unsigned short *)0xe43000)
#define ERRENABLE     0xe40000
#define PARENABLE     0xe41000
#define L1MODEM       0xe44000
#define L2MODEM       0xe45000

#endif
