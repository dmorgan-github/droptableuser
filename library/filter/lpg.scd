(
synth: {|in, gate, freq, aeg|

    var fatk = \fatk.kr(0, spec: DMControlSpec(0, 1, \lin, 0, 0.0, units:"lpg", sort:0));
    var frel = \frel.kr(0.05, spec: DMControlSpec(0, 1, \lin, 0, 0.05, units:"lpg", sort:1));
    var fatkcurve = \fatkcurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"lpg", sort:2));
    var frelcurve = \frelcurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"lpg", sort:3));

    var feg = Env(
        [0, 0, 1, 0],
        [0, fatk, frel],
        curve: [
            fatkcurve,
            frelcurve
        ]
    ).ar(gate: gate);

    var lpg = LPG.ar(in,
        controlinput: feg,
        controloffset: \controloffset.kr(0.1, spec: DMControlSpec(0, 1, \lin, 0, 0.1, units:"lpg", sort:4)),
        controlscale: \controlscale.kr(0.2, spec: DMControlSpec(0, 1, \lin, 0, 0.2, units:"lpg", sort:5)),
        vca: \vca.kr(0.1, spec: DMControlSpec(0, 1, \lin, 0, 0.1, units: "lpg", sort:6)),
        resonance: \res.kr(0.2, spec: DMControlSpec(0, 1.8, \lin, 0, 0.2, units:"lpg", sort:7)).linlin(0, 1, 0, 1.8),
        lowpassmode:1,
        linearity: \linearity.kr(1, spec: DMControlSpec(0, 1, \lin, 0, 1, units:"lpg", sort:8))
    );

    lpg;
}
)


