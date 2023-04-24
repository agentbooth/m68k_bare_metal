#include "3b1.h"
#include "font.h"
#include "kbd.h"

#define FONT_CHAR_SIZE 8  // in bytes
#define FONT_HEIGHT 8  // in rows
#define VRAM_WIDTH_BYTES (720/8)
const char hex_string[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
unsigned char println = 0;

/* COL: 0-89, ROW: 0-42 */
void putchar_8x8(const unsigned char col, const unsigned char row, const char letter)
{
    char *font_data = font8x8_basic + (letter-32)*FONT_CHAR_SIZE;
    char *vram_ptr = (char *)VRAM_START + (row*VRAM_WIDTH_BYTES*FONT_HEIGHT) + col;

    // adjust forward or backward due to reverse ordering of 16-bit data in bitmap memory (D0..D15 instead of D15..D0)
    if (col&1)
        vram_ptr--;
    else
        vram_ptr++;

    for (int i = 0; i < FONT_HEIGHT; i++)
    {
        *vram_ptr = *font_data;
        font_data++;  // assumes font data is 8 bits wide
        vram_ptr += VRAM_WIDTH_BYTES;  // advance to next horizontal line
    }
}

void __attribute__((interrupt))
IRQ6(void)
{
    // Vsync (60 Hz) interrupt
    *MCR = 0x0e00; // LEDs to 1
}

void __attribute__((interrupt))
IRQ5(void)
{
    // Expansion slots interrupt
}

void __attribute__((interrupt))
IRQ4(void)
{
    // RS232 (7201/8274) interrupt
}

void __attribute__((interrupt))
IRQ3(void)
{
    // Keyboard (6850) interrupt
    *MCR = 0x0e00; // LEDs to 1
    unsigned short kbd = *KBDATA;
    
    putchar_8x8(1,println,hex_string[(kbd & 0xf00)>>8]);
    putchar_8x8(0,println,hex_string[(kbd & 0xf000)>>12]);
    if (++println > 42) println = 0;
}

int
main(void)
{
    //*MCR = 0x0f00; // turn off LEDs

    // Init keyboard controller (6850)
    *KBC = 0x0300;  // master reset
    *KBC = 0x9500;  // RxInt enable, TxInt disable, N81, 16x clk divide
    // Init keyboard microcontroller
    // technically should read 6850 (*KBC status & 0x0200) to confirm Tx data reg empty
    *KBDATA = (unsigned short)KBDRST << 8;
    *KBDATA = (unsigned short)KBDRST << 8;
    *KBDATA = (unsigned short)KBDRST << 8;
    *KBDATA = (unsigned short)KBDRST << 8;
    *KBDATA = (unsigned short)MSENABLE << 8;  // mouse enable, tell keyboard to send mouse data too

    while (1)
    {
        //*MCR = 0x0e00; // LEDs to 1

#if 0
        int x, line;
        for (line = 0; line < 40; line++)
        {
            for (x = 0; x < VRAM_WIDTH_BYTES; x++)
            {
                putchar_8x8(x, line, 32+x);                
            }
        }
#endif

    }

    return 0;
}
