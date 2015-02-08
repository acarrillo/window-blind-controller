// Alex Carrillo (alejandro.carrillo@yale.edu)
// January 2015
// Electric Imp-powered automated window blind controller

// create global variables corresponding to H bridge transistors
//
// H bridge design is two pMOS-nMOS pairs, each driven by
// an NPN transistor that switches gate voltages between 0v and
// 12v.

M_plus <- hardware.pin9; // Transistor switching the (+) lead
M_minus <- hardware.pin8; // Transistor switching the (-) lead
State <- 1 // 0 means blinds are open, 1 means blinds are closed!
//
// configure H-bridge transistors to be digital outputs
M_plus.configure(DIGITAL_OUT);
M_minus.configure(DIGITAL_OUT);


/**
 * Configure H bridge to supply positive voltage to the motor.
 */
function motor_cw() {

  M_plus.write(1);
  M_minus.write(0);
}

/**
 * Configure H bridge to supply nevative voltage to the motor.
 */
function motor_ccw() {

  M_plus.write(0);
  M_minus.write(1);

}

/**
 * Turns off the window motor.
 */
function motor_off() {
  M_plus.write(0);
  M_minus.write(0);

}

/**
 * Callback function for handling requests from the agent.
 */
function motorHandler(state) {
    server.log("[motorHandler] State is " + state);

    switch(state) {
        case 0: // OFF
            motor_off();
            break;
        case 1: // Motor CCW
            motor_ccw();
            break;
        case 2: // Motor CW
            motor_cw();
            break;
        case 3: // Open blinds
            open_blinds(17);
            break;
        case 4: // Close blinds
            close_blinds(18.5);
            break;
        default:
            motor_off();
            break;
    }
}

/**
 * Callback function for briefly trimming the position of the blinds one way
 * or another.
 */
function trimHandler(direction) {
    if (direction > 0) {
        open_blinds(0.1, 1);
    }
    else {
        close_blinds(0.1, 1);
    }
}

/**
 * Function for opening the blinds for a set time. Function is state-aware,
 * meaning it will not try to open already opened blinds, EXCEPT when trimming.
 */
function open_blinds(duration, trim=0) {
    if (State == 1 || trim) {
        motor_cw();
        imp.wakeup(duration, motor_off);
        State = 0;
    }
}
/**
 * Function for closing the blinds for a set time. Function is state-aware,
 * meaning it will not try to open already opened blinds, EXCEPT when trimming.
 */
function close_blinds(duration, trim=0) {
    if (State == 0 || trim) {
        motor_ccw();
        imp.wakeup(duration, motor_off);
        State = 1;
    }
}

// start the loop
motor_off(); // Just to be safe!
agent.on("xmotorx", motorHandler)
agent.on("trim", trimHandler)
