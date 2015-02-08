// Alex Carrillo (alejandro.carrillo@yale.edu)
// January 2015
// Electric Imp-powered automated window blind controller

// create global variables corresponding to H bridge transistors
//
// H bridge design is two pMOS-nMOS pairs, each driven by
// an NPN transistor that switches gate voltages between 0v and
// 12v.

M_plus <- hardware.pin9; // Transistors switching the (+) lead
M_minus <- hardware.pin8; // Transistors switching the (-) lead
State <- 1 // 0 means open, 1 means closed!
// configure H-bridge transistors to be digital outputs
M_plus.configure(DIGITAL_OUT);
M_minus.configure(DIGITAL_OUT);


function motor_cw() {
  // configure H bridge to supply positive voltage to the motor

  M_plus.write(1);
  M_minus.write(0);
}
function motor_ccw() {
  // configure H bridge to supply negative voltage to the motor

  M_plus.write(0);
  M_minus.write(1);

}

function motor_off() {
  M_plus.write(0);
  M_minus.write(0);

}

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

function trimHandler(direction) {
    if (direction > 0) {
        open_blinds(0.1, 1);
    }
    else {
        close_blinds(0.1, 1);
    }
}
function open_blinds(duration, trim=0) {
    if (State == 1 || trim) {
        motor_cw();
        imp.wakeup(duration, motor_off);
        State = 0;
    }
}
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
