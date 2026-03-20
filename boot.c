
// boot.c - C entry point, called from boot.asm
// No stdlib, no runtime, pure K&R style

void print_char(char c) {
    __asm__ volatile (
        "movb $0x0E, %%ah\n"
        "int $0x10\n"
        : : "a"(c) : "bx"
    );
}

void print_string(const char *s) {
    while (*s)
        print_char(*s++);
}

void boot_main(void) {
    print_string("Hello from C!");
}
