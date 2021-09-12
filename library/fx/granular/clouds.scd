(
synth: {|sig_in|

    var in = sig_in * \input.ar(1);
    var pitch = \pitch.kr(7);
    var pos = \pos.kr(0.5);
    var size = \size.kr(0.25);
    var dens = \dens.kr(0.4);
    var tex = \tex.kr(0.5);
    var stereo = \stereo.kr(0.5);
    var rvb = \rvb.kr(0);
    var fb = \fb.kr(0);
    var freeze = \freeze.kr(0);
    var mode = \mode.kr(2);
    var lofi = \lofi.kr(0);
    var trig = 0;
    var lag = \lag.kr(0.1);

    var sig = MiClouds.ar(in,
        pit: pitch.lag(lag),
        pos: pos,
        size: size,
        dens: dens,
        tex: tex,
        drywet: 1,
        in_gain: 1,
        spread:stereo,
        rvb: rvb,
        fb: fb,
        freeze: freeze,
        mode: mode,
        lofi: lofi,
        trig: trig
    );

    Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);

},

specs: [
    pitch: ControlSpec(-48, 48, \lin, 0, 7, units:"pitch"),
    pos: ControlSpec(0, 1, \lin, 0, 0.5, units:"grain"),
    size: ControlSpec(0, 1, \lin, 0, 0.25, units:"grain"),
    dens: ControlSpec(0, 1, \lin, 0, 04, units:"grain"),
    tex: ControlSpec(0, 1, \lin, 0, 0.5, units:"timbre"),
    stereo: ControlSpec(0, 1, \lin, 0, 0.5, units:"stereo"),
    rvb: ControlSpec(0, 1, \lin, 0, 0, units:"reverb"),
    fb: ControlSpec(0, 1, \lin, 0, 0, units:"reverb"),
    freeze: ControlSpec(0, 1, \lin, 1, 0, units:"reverb"),
    mode: ControlSpec(0, 3, \lin, 1, 2, units:"timbre"),
    lofi: ControlSpec(0, 1, \lin, 1, 0, units:"timbre"),
    lag: ControlSpec(0, 1, \lin, 1, 0.1, units:"pitch")
]
)