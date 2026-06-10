#include "hal.h"
#include "stdint.h"

#define BLINK_INTERVAL_US (500000)

int main(void){
    //Configure GPIO0 as an output
    gpio_config(0, 1);

    //Read current time, system timer 0 counts in microseconds by default
    uint64_t wait_until = system_timer_read(0) + BLINK_INTERVAL_US;
    uint32_t toggle = 0;

    while(1){
        //GPIO0 toggle
        gpio_pin_value(0, toggle);
        toggle ^= 1;
        //Wait for time interval
        while(system_timer_read(0) < wait_until);
        //Setup next interval
        wait_until += BLINK_INTERVAL_US;
    }
    
}