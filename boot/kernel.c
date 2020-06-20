/* BASIC KERNEL FOR NULLOS */
// NOTE: This kernel uses VGA text mode, invoke framebuffer via GRUB for forward compatibility

/* Freestanding Headers include:
 *  1. float.h
 *  2. iso646.h
 *  3. limits.h
 *  4. stdalign.h
 *  5. stdarg.h
 *  6. stdbool.h      +
 *  7. stddef.h       +
 *  8. stdint.h       +
 *  9. stdnoreturn.h    */

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#if defined(__linux__)
#error "GCC cross-compiler required, exiting"
#endif

#if !defined(__i386__)
#error "Kernel requires the ix86-elf compiler, exiting"
#endif

// Hardware text mode color constants
enum vga_color {
  VGA_COLOR_BLACK = 0,
  VGA_COLOR_BLUE = 1,
  VGA_COLOR_GREEN = 2,
  VGA_COLOR_CYAN = 3,
  VGA_COLOR_RED = 4,
  VGA_COLOR_MAGENTA = 5,
  VGA_COLOR_BROWN = 6,
  VGA_COLOR_LIGHT_GREY = 7,
  VGA_COLOR_DARK_GREY = 8,
  VGA_COLOR_LIGHT_BLUE = 9,
  VGA_COLOR_LIGHT_GREEN = 10,
  VGA_COLOR_LIGHT_CYAN = 11,
  VGA_COLOR_LIGHT_RED = 12,
  VGA_COLOR_LIGHT_MAGENTA = 13,
  VGA_COLOR_LIGHT_BROWN = 14,
  VGA_COLOR_WHITE = 15,
};

// Some artistic algebra for entry color
static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) 
{
  return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color) 
{
  return (uint16_t) uc | (uint16_t) color << 8;
}

// Calculates string length (recall string.h is not a freestanding header)
size_t strlen(const char* str) 
{
  size_t len = 0;
  while (str[len])
  len++;
  return len;
}

// Width and Height of our terminal
static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

// term variables (namely for coloring)
size_t term_row;
size_t term_column;
uint8_t term_color;
uint16_t *term_buffer;

// This fills out the terminal PIXEL BY PIXEL!
void term_initialize(void) 
{
  term_row = 0;
  term_column = 0;
  term_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
  term_buffer = (uint16_t *) 0xB8000;
  for (size_t y = 0; y < VGA_HEIGHT; y++)
  {
    for (size_t x = 0; x < VGA_WIDTH; x++)
    {
      const size_t index = y * VGA_WIDTH + x;
      term_buffer[index] = vga_entry(' ', term_color);
    }
  }
}

void term_setcolor(uint8_t color) 
{
  term_color = color;
}

// Replacing pixel (x, y) with different color
void term_put_entry_at(char c, uint8_t color, size_t x, size_t y) 
{
  const size_t index = y * VGA_WIDTH + x;
  term_buffer[index] = vga_entry(c, color);
}

// Text-based portion of our terminal
void term_write(const char* data, size_t size) 
{
  for (size_t i = 0; i < size; i++)
  {
    term_put_entry_at(data[i], term_color, term_column, term_row);

    // Reset terminal accumulator variables if exceeding max
    if (++term_column == VGA_WIDTH)
    {
      term_column = 0;
      if (++term_row == VGA_HEIGHT)
      {
        term_row = 0;
      }
    }
  }
}

// Write a string, whether user or system informational
void term_writestring(const char* data) 
{
  term_write(data, strlen(data));
}

// Main function called by linker
void kernel_main(void) 
{
  // Initialize term interface
  term_initialize();

  // TODO: Implement new-line character support
  // term_writestring("Hello World!\n");
  term_writestring("Hello World!");
}
