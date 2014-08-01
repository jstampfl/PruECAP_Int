//ieps.p   -  setup PRU INTC without help of Linux Prussdrv
//            uses the eCAP timer.
//            All the setup is done by the pru.  Still does the same
//            as iepx.p, Initalizes CAP1 and toggle the pin on interrupt
//            and on CAP2 hitting compare value.
//            toggles pin p9.31 -  attached to r30.t0 - mode 5 output
//
//            Changed the loop time to 1 second.
//
.setcallreg r2.w0  //  Going to use r30
.origin 0
.entrypoint TB
TB:
       set r30,r30, 0         //turn on 
       jmp ASET           //this is the routine to setup

TB1:
       ldi r17,0             // init loop counter
       call RSET             // routine to clear & enable interrupts
TB2:
       qbbc TB2,r31.t30     // spin here for interrupt
       lbco r3,c3,0x2E,4   //get status, which interrupt
       qbbs TB5,r3.t6       // check for CAP1
TB3:
       clr r30,r30,0        // CAP2 interrupt
TB4:
       call RSET            // clear, enable
       add r17,r17,1        //loop counter
       qblt TB9,r17,50      //loop 50 times
       jmp TB2

TB5:
       set r30,r30,0        // CMP0 interrupt
       jmp TB4

TB9:    //  exit point 

       clr r30,r30,0
       HALT

ASET: //  This section is to initialize the interrupts

//    INITIALIZE` THE PRU INTC

      mov r15,0xD00               //offset for SIPR0
      mov r14,0xFFFFFFFF          // must be oll bits = one
      sbco r14,c0,r15,4
      mov r15,0xD04               //offset for SIPR1
      sbco r14,c0,r15,4

      mov r15,0xD80               //offset for SITR0
      mov r14,0                   // must be zero
      sbco r14,c0,r15,4
      mov r15,0xD84               //offset for SITR1
      sbco r14,c0,r15,4

//    INITIALIZE eCap INTERRUPTS
//                  c3 = constant table entry for eCap
//
       mov r14,0x0BEBC200           //For CAP1, period trigger
       sbco r14,c3,0x8,4
       mov r14,0x05F5E100         //For CAP2, compare trigger
       sbco r14,c3,0xc,4
       mov r14,0x0                // set ECCTL1
       sbco r14,c3,0x28,2
       mov r14,0x2D0              //  set ECCTL2
       sbco r14,c3,0x2A,2        //
       mov r14,0xC0
       sbco r14,c3,0x2C,2        // enable interrupts for period & compare
       lbco r14,c3,0x2E,2
       sbco r14,c3,0x2E,2
       lbco r14,c3,0x30,2
       sbco r14,c3,0x30,2

//    DONE WITH IEP SETUP

//    SETUP CHANNEL MAP
       mov r18,0x43C
       mov r15,0x3FC            //set up Channel map
TB43:
       mov r14,0x09090909       // first map all events to
       add r15,r15,4            // to channel 9
       sbco r14,c0,r15,4
       qbgt TB43,r15,r18
       mov r14,0x00090909       // map SysEvt 15 to channel 0
       mov r15,0x40C            // now do 0x40C, which has the
       sbco r14,c0,r15,4        // entries for 12,13,14,15

//   Done with Channel Map, Host Interrupt Map now

       mov r14,0x09090900       // map channels 1,2,3 to Host Int 9 
                                // and channel 0 to host 0
       mov r15,0x800
       sbco r14,c0,r15,4
       mov r14,0x09090909       // map channels 4,5,6,7 to Host Int 9 
       mov r15,0x804
       sbco r14,c0,r15,4
       mov r14,0x00000909       // map channel 8 & 9 to Host Int 9
       mov r15,0x808
       sbco r14,c0,r15,4

       ldi r15, 0x24             //clear all events
       call RSET

       ldi r15,0x28              // enable all events
       call ALLEVT
       ldi r14,1
       ldi r15,0x10
       sbco r14,c0,r15,4         //turn on global interrupts
       ldi r14,0xFF
       ldi r15,0x1500
       sbco r14,c0,r15,4         //turn on  interrupts
       jmp TB1

RSET:  // Routine to clear & enable system events, also host interrupts
       mov r24,r2           // Save return address
                            // so can call ALLEVT
       mov r14,0xFFFFFFFF
       sbco r14,c3,0x2E,4   //clear all status for the eCap timer
       mov r15,0x24         //  to clear system event
       call ALLEVT
       mov r15,0x28         //  to enable system event
       call ALLEVT

       mov r2,r24            // restore return address
       ret
       
ALLEVT:  //Insert the system envent in the proper INTC register
         // register r15 must have the register offset
         // will only work with registers that take the event number
         // if you want to handle multiple events, just add 
         //   ldi r14,"sys event no."
         //   sbco r14, c0 ,r15,4

       ldi r14,15             //ecap is interrupt 15.
       sbco r14, c0 ,r15,4
       ret
