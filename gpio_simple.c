#include "hal.h"

int main(void){
    //Configure GPIO0 as an output
    gpio_config(0, 1);
    
    while(1){
        //GPIO0 High
        gpio_pin_set(0);
        //Wait 10 million loops (takes some time)
        for(volatile int i = 0; i < 10000000; i++);
        //GPIO0 Low
        gpio_pin_clear(0);
        //Wait again
        for(volatile int i = 0; i < 10000000; i++);
    }
    
}