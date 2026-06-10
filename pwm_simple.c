#include "hal.h"

int main(void){
    //Configure GPIO27 and 26 as PWM
    pwm_pin(27);
    pwm_pin(26);
    //Initialize PWM channel 5 (Connected to pins above)
    pwm_init(5);
    
    int32_t pulsewidth = 0;
    uint32_t change = 100;
    uint32_t ms = 0;

    while(1){
        while(system_timer_read(0) < (ms * 1000));
        ms++;

        //Set pulse width, default configuration is 16bit
        pwm_set_pulsewidth(pulsewidth, 5, 0);
        pwm_set_pulsewidth(65535 - pulsewidth, 5, 1);
        pulsewidth += change;
        if((pulsewidth <= 0) || (pulsewidth > 65535)) {
            change = -change;
            pulsewidth += change;
        }
    }
    
}