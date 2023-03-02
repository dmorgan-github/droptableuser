(
synth: {|freq, gate|

    var strike_in = 0;//~strike ?? 0;//PinkNoise.ar(0.3);
    var pit = A2K.kr(freq).cpsmidi;
    var strength = \strength.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"elements"));
    var contour = \contour.kr(0.2, spec:ControlSpec(0, 1, \lin, 0, 0.2, units:"elements"));
    var bow_level = \bowlevel.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"elements"));
    var blow_level = \blowlevel.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"elements"));
    var strike_level = \strikelevel.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"elements"));
    var flow = \flow.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"elements"));
    var mallet = \mallet.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"elements"));
    var bow_timb = \bowtimb.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"elements"));
    var blow_timb = \blowtimb.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"elements"));
    var strike_timb = \striketimb.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"elements"));
    var geom = \geom.kr(0.25, spec:ControlSpec(0, 1, \lin, 0, 0.25, units:"elements"));
    var bright = \bright.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"elements"));
    var damp = \damp.kr(0.7, spec:ControlSpec(0, 1, \lin, 0, 0.7, units:"elements"));
    var pos = \pos.kr(0.2, spec:ControlSpec(0, 1, \lin, 0, 0.2, units:"elements"));
    var space = \space.kr(0.3, spec:ControlSpec(0, 1, \lin, 0, 0.3, units:"elements"));
    var model = \model.kr(0, spec:ControlSpec(0, 2, \lin, 1, 0, units:"elements"));

    var blow_in = PinkNoise.ar(0.5);
    if (~blow.notNil) {
        blow_in = ~blow
    };

    MiElements.ar(
        PinkNoise.ar(1),//Hasher.ar(Sweep.ar(0)),//PinkNoise.ar(0.5),
        0,
        gate, //A2K.kr(gate),
        pit,
        strength,
        contour,
        bow_level,
        blow_level,
        strike_level,
        flow,
        mallet,
        bow_timb,
        blow_timb,
        strike_timb,
        geom,
        bright,
        damp,
        pos,
        space,
        model
    );
}
)
