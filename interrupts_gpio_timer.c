#include "hal.h"
#include "traps.h"
#include "lio_lcd.h"
#include "stdint.h"

#define RED 	0xF800
#define PINK    0xF910
#define GREEN	0x07E0
#define BLUE	0x001F

volatile uint32_t running = 1;
volatile uint64_t time = 0;
volatile uint32_t stopwatch = 0;
volatile uint32_t color_toggle = 0;

void color_callback(){
    color_toggle ^= 1;

    //Clear and reinstate interrupt for next time
    system_timer_clear_interrupt(1, 1);
    system_timer_new_alarm(1, 1, system_timer_read(0) + 500033, color_callback);
}

void timer_100ms_callback(){
    uint16_t color;
    if(running) {
        stopwatch+=10;
        color = color_toggle ? RED : PINK;
    } else color = color_toggle ? GREEN : BLUE;

    time += 100000;
    lio_lcd_printf_scaled(10, 10, color, 2, "%02d:%02d:%02d", stopwatch/(100*60), (stopwatch/100)%60, (stopwatch)%100);

    //Clear and reinstate interrupt for next time
    system_timer_clear_interrupt(0, 0);
    system_timer_new_alarm(0, 0, time, timer_100ms_callback);
    
}

void gpio_callback(){
    if(gpio_pin_read(24)) running = 1;
    else running = 0;
    gpio_clear_interrupt(24, GPIO_IRQ_EDGE_HIGH);
    gpio_clear_interrupt(24, GPIO_IRQ_EDGE_LOW);
}

int main(){
    gpio_config(24, 0); //A5
    gpio_config(23, 0); //A6
    gpio_config(22, 0); //A7
    gpio_config(21, 0); //A8

    for(int i = 0; i < 11; i++) gpio_config(i, 1);

    lio_lcd_config_t lcd_conf = {.background = 0x00, 
                                 .width = 160, 
                                 .height = 80, 
                                 .invert = 0, 
                                 .offset_y = 24, 
                                 .offset_x = 0
                                };

	lio_lcd_init(lcd_conf);
    lio_lcd_clear(0x0);

    //Setup custom trap handling
    trap_init_handler();
    
    //Setup gpio interrupt, enable on gpio 24, enable on both from 1 -> 0 and 0 -> 1
    trap_install_platform_interrupt(INT_IO_IRQ_BANK0, gpio_callback);
    trap_enable_external_interrupt(INT_IO_IRQ_BANK0);
    gpio_enable_interrupt(24, GPIO_IRQ_EDGE_HIGH, 0);
    gpio_enable_interrupt(24, GPIO_IRQ_EDGE_LOW, 0);

    //Setup timer interrupts, one for counting up and one for toggling the color
    time = system_timer_read(0);
    system_timer_new_alarm(0, 0, time + 1000, timer_100ms_callback);
    system_timer_new_alarm(1, 1, time + 500000, color_callback);

    //Enable peripheral interrupts
    trap_external_interrupt_enable();
    //Enable interrupts globally
    trap_interrupt_enable();

    

    while(1){
        __asm__ volatile ("wfi"); //Wait for interrupt
    }
}