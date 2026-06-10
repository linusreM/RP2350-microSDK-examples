#include "hal.h"
#include "stdint.h"

int main(void){

    uint32_t value = 0;

    //Configure outputs
    gpio_config(0, 1);
    gpio_config(1, 1);
    gpio_config(2, 1);

    //Configure inputs
    gpio_config(24, 0); //A5
    gpio_config(23, 0); //A6
    gpio_config(22, 0); //A7
    
    while(1){
        //Read the inputs and shift to output positions
        value = (gpio_read() >> 22) & 0x7;
        //Write value to outputs
        gpio_write(0x7, value);
    }
    
}