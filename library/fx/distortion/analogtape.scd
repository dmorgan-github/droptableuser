(
synth: {|in|

    var tape_bias = \tape_bias.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "analogtape"));
    var saturation = \tape_sat.kr(0.5, spec:ControlSpec(0, 2, \lin, 0, 0.5, "analogtape"));
    var drive = \tape_drive.kr(0.5, spec:ControlSpec(0, 2, \lin, 0, 0.5, "analogtape"));
    var tape_oversample = \tape_oversample.kr(2, spec:ControlSpec(0, 4, \lin, 1, 2, "analogtape"));
    var mode = \tape_mode.kr(0, spec:ControlSpec(0, 3, \lin, 1, 0, "analogtape"));

    var sig = AnalogTape.ar(in, tape_bias, saturation, drive, tape_oversample, mode);
    sig = in.blend(sig, \analogtape_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "analogtape")));
    sig;
},

doc: "
oversampe: 0 = No oversampling, 1 = x2, 2 = x4, 3 = x8, 4 = x16
mode: Change the mode (solver type) of the tape algorithm: 0 = RK2 (2nd order Runge Kutta) 1 = RK4 (4th order Runge Kutta) 2 = NR4 (4-iteration Newton Raphson) 3 = NR8 (8-iteration Newton Raphson)

The Runge-Kutta solvers are computationally cheaper, but somewhat less accurate than the Newton-Raphson solvers. Similarly, the higher-order solvers will be more accurate, but will also consume more compute resources.
"
)