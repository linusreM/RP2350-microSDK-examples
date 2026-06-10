#include "hal.h"
#include "stdint.h"
#include "lio_lcd.h"
int main(void){

    uint8_t m10 = 0;
    uint8_t seconds = 0;
    uint8_t minutes = 0;
    
    uint64_t time = system_timer_read(0);

    //Initialize LCD
    lio_lcd_config_t lcd_conf = {.background = 0x00, 
                                 .width = 160, 
                                 .height = 80, 
                                 .invert = 0, 
                                 .offset_y = 24, 
                                 .offset_x = 0
                                };

	lio_lcd_init(lcd_conf);

    //Fill entire display with black
    lio_lcd_clear(0);

    while(1){

        //Print a timer to the screen
        lio_lcd_printf_scaled(10, 10, 0xFFFF, 2, "%02d:%02d:%02d", minutes, seconds, m10);

        while(system_timer_read(0) < (time + 10000));
        time += 10000;

        m10 = (m10 + 1) % 100;
        if(m10 == 0) {
            seconds = (seconds + 1) % 60;
            if(seconds == 0) minutes = (minutes + 1) % 60;
        }
    }
    
}