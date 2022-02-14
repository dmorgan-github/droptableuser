(
// credit: "http://sccode.org/1-5aD"
synth: {|freq, gate, aeg|

    var dec = \rel.kr;
    var exatk = \exatk.kr(0.001);
    var exrel = \exrel.kr(0.05);
    var exciter = WhiteNoise.ar(Env.perc(exatk, exrel, 0.25).ar);
    var t60 = 1;

    var sig = DynKlank.ar(
        specificationsArrayRef: Ref.new([
            [1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // harmonics
            [1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
            [1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047] * t60    // ring times
        ]),
        input: exciter,
        freqscale: freq,
        decayscale: dec
    );

    sig * 0.1
},
presets: (
    preset1: [
        'rel': 1.66,
        'atk': 0.01,
        'atkcurve': -4.0,
        'detunehz': 0.67669172932331,
        'relcurve': 5.8046511627907
    ]
)
)
