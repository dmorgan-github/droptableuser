(
synth: {|in|

    var gain = \clouds_gain.kr(1, spec: ControlSpec(0.125, 8, \lin, 0, 1, units:"clouds") );
    var pitch = \clouds_pitch.kr(7, spec:ControlSpec(-48, 48, \lin, 0, 0, units:"clouds"));
    var pos = \clouds_pos.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"clouds"));
    var size = \clouds_size.kr(0.25, spec: ControlSpec(0, 1, \lin, 0, 0.25, units:"clouds"));
    var dens = \clouds_dens.kr(0.4, spec: ControlSpec(0, 1, \lin, 0, 04, units:"clouds"));
    var tex = \clouds_tex.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"clouds"));
    var stereo = \clouds_stereo.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"clouds"));
    var rvb = \clouds_rvb.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"clouds"));
    var fb = \clouds_fb.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"clouds"));
    var freeze = \clouds_freeze.kr(0, spec: ControlSpec(0, 1, \lin, 1, 0, units:"clouds"));
    var mode = \clouds_mode.kr(0, spec: ControlSpec(0, 3, \lin, 1, 2, units:"clouds"));
    var lofi = \clouds_lofi.kr(0, spec: ControlSpec(0, 1, \lin, 1, 0, units:"clouds"));
    var trig = ~graintrig ?? { 0 };
    var rate = \clouds_rate.kr(1, spec:ControlSpec(0.5, 4, \lin, 0, 1, units:"clouds"));
    //var lag = \clouds_lag.kr(0.1, spec: ControlSpec(0, 1, \lin, 1, 0.1, units:"clouds"));

    var sig = MiClouds.ar(in,
        pit: pitch,
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
        trig: Impulse.kr(rate)
    );

    sig = in.blend(sig, \clouds_mix.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"clouds")));
    sig;
},
doc: "
0:PLAYBACK_MODE_GRANULAR
1:PLAYBACK_MODE_STRETCH
2:PLAYBACK_MODE_LOOPING_DELAY
3:PLAYBACK_MODE_SPECTRAL
"
)