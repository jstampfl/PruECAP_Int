PruECAP_Int  
========
Example using the PRUSS eCAP timer interrupt on the BEAGLEBONE to toggle a pin.

notes - comments about this example

iec.c - Initialize the Pruss loads iec.bin and exits.  Does not initialize the PRUSS INTC, does not wait for the PRUSS.

iec.p - Initialize the PRUSS INTC interrupt system.  Initializes the eCAP interrupts for CAP1 & CAP2.  Toggles P9.31 using interrupts form CAP1 & CAP2.
