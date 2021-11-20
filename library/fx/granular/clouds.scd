(
synth: {|sig_in|

    var in = sig_in * \clouds_input.ar(1);
    var pitch = \clouds_pitch.kr(7);
    var pos = \clouds_pos.kr(0.5);
    var size = \clouds_size.kr(0.25);
    var dens = \clouds_dens.kr(0.4);
    var tex = \clouds_tex.kr(0.5);
    var stereo = \clouds_stereo.kr(0.5);
    var rvb = \clouds_rvb.kr(0);
    var fb = \clouds_fb.kr(0);
    var freeze = \clouds_freeze.kr(0);
    var mode = \clouds_mode.kr(2);
    var lofi = \clouds_lofi.kr(0);
    var trig = 0;
    var lag = \clouds_lag.kr(0.1);

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

    sig = in.blend(sig, \clouds_mix.kr(0.5));
    sig = sig * \clouds_output.ar(1);
    sig;

},

specs: [
    clouds_pitch: ControlSpec(-48, 48, \lin, 0, 7, units:"pitch"),
    clouds_pos: ControlSpec(0, 1, \lin, 0, 0.5, units:"grain"),
    clouds_size: ControlSpec(0, 1, \lin, 0, 0.25, units:"grain"),
    clouds_dens: ControlSpec(0, 1, \lin, 0, 04, units:"grain"),
    clouds_tex: ControlSpec(0, 1, \lin, 0, 0.5, units:"timbre"),
    clouds_stereo: ControlSpec(0, 1, \lin, 0, 0.5, units:"stereo"),
    clouds_rvb: ControlSpec(0, 1, \lin, 0, 0, units:"reverb"),
    clouds_fb: ControlSpec(0, 1, \lin, 0, 0, units:"reverb"),
    clouds_freeze: ControlSpec(0, 1, \lin, 1, 0, units:"reverb"),
    clouds_mode: ControlSpec(0, 3, \lin, 1, 2, units:"timbre"),
    clouds_lofi: ControlSpec(0, 1, \lin, 1, 0, units:"timbre"),
    clouds_lag: ControlSpec(0, 1, \lin, 1, 0.1, units:"pitch"),
    clouds_input: ControlSpec(0, 2, \lin, 0, 1, "fb delay"),
    clouds_output: ControlSpec(0, 2, \lin, 0, 1, "fb delay"),
    clouds_mix: ControlSpec(0, 1, \lin, 0, 0.4, "fb delay")
]
)