(
synth: {|freq, gate, aeg|

    var slope = \slope.kr(0).linlin(0, 1, -8, 8);
    var skew = \skew.kr(0.5).linlin(0, 1, -1.5, 1.5);
    var sig = SinOscFB.ar(freq, skew).lincurve(-1, 1, -1, 1, slope);

    sig = LPG.ar(LeakDC.ar(sig),
        controlinput: aeg, //Env.perc(0, 0.1, curve:[\atkcurve.kr, \relcurve.kr]).ar(),
        controloffset: \controloffset.kr(0.1),
        controlscale: \controlscale.kr(0.2),
        vca: \vca.kr(0.1),
        resonance: \res.kr(0.2).linlin(0, 1, 0, 1.8),
        linearity: \linearity.kr(1)
    );

    sig;
}, specs: [
    controloffset: ControlSpec(0, 1, \lin, 0, 0, units:"filter"),
    controlscale: ControlSpec(0, 1, \lin, 0, 1, units:"filter"),
    linearity: ControlSpec(0, 1, \lin, 0, 1, units:"filter"),
    vca: ControlSpec(0, 1, \lin, 0, 1, units: "filter"),
    skew: ControlSpec(0, 1, \lin, 0, 0.5, units: "timbre"),
    slope: ControlSpec(0, 1, \lin, 0, 0.5, units:"timbre")
]
)