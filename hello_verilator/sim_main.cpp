// #include "Vour.h"
// #include "verilated.h"

// int main(int argc, char **argv) {
//     VerilatedContext *contextp = new VerilatedContext;
//     contextp->commandArgs(argc, argv);
//     Vour *top = new Vour{contextp};
//     while (!contextp->gotFinish()) {
//         top->eval();
//     }
//     // delete top;
//     delete contextp;
//     return 0;
// }


#include <stdio.h>
#include <stdlib.h>
#include "Vthruwire.h"
#include "verilated.h"

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    
    Vthruwire *tb = new Vthruwire;
    
    for(int k = 0; k < 20; k++)
    {
        tb->i_sw = k&1;
        
        tb->eval();
        
        printf("k = %2d, ", k);
        printf("i_sw = %2d, ", tb->i_sw);
        printf("led = %2d, ", tb->o_led);
    }
}
