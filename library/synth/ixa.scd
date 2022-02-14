(
// adapted from https://nathan.ho.name/posts/ixa-synthesis/
synth: {|freq, gate, aeg|

    var ixa = { |freq, in, index|
        var phase, waveform, snd;
        phase = Phasor.ar(Impulse.ar(0), freq / SampleRate.ir, 0, 1);
        waveform = (phase % 0.5 * 2pi).sin * (2 * (phase % 0.5 < 0.25) - 1);
        waveform = waveform + (2 * (phase % 0.5 >= 0.25));
        waveform = waveform + (2 * (phase >= 0.5));
        snd = (waveform + (in * index)).fold2;
        snd;
    };

    var index = {
        var atk = \iatk.kr(0.01);
        var dec = \idec.kr(0.3);
        var suslevel = \isuslevel.kr(1);
        var peak = \ipeak.kr(1);
        var rel = \irel.kr(0.1);
        var curve = [\iatkcurve.kr(-4), \ideccurve.kr(-4), \irelcurve.kr(-4)];
        var index = \index.kr(1);
        Env.adsr(atk, dec, suslevel, rel, peak, curve).ar * index;
    };

    var modratio = \mratio.kr(1);
    var sig = ixa.(freq, SinOsc.ar(freq * modratio), index.()) * 0.5;
    sig;
},

specs: [
    index: ControlSpec(0, 20, \lin, 0, 1, units:"ixa"),
    iatk: ControlSpec(0, 1, \lin, 0, 0.01, units:"ixa"),
    idec: ControlSpec(0, 1, \lin, 0, 0.3, units:"ixa"),
    irel: ControlSpec(0, 1, \lin, 0, 0.2, units:"ixa"),
    isuslevel: ControlSpec(0, 1, \lin, 0, 1, units:"ixa"),
    ipeak: ControlSpec(0, 1, \lin, 0, 1, units:"ixa"),
    iatkcurve: ControlSpec(-8, 8, \lin, 0, -4, units:"ixa"),
    ideccurve: ControlSpec(-8, 8, \lin, 0, -4, units:"ixa"),
    irelcurve: ControlSpec(-8, 8, \lin, 0, -4, units:"ixa"),
    mratio: ControlSpec(1/8, 12, \lin, 0, 1, units:"ixa")
],
presets: (

    preset1: [
        'mratio', 1.01,
        'iatakcurve', -4.0,
        'irelcurve', -4.0,
        'ipeak', 1.0,
        'iatk', 0.057591623036649,
        'isuslevel', 0.52552552552553,
        'idec', 0.19895287958115,
        'iatkcurve', -4.0,
        'index', 1.0,
        'irel', 0.2,
        'ideccurve', 0.12565445026178,
    ]
)
)




    