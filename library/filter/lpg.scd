(
synth: {|in, gate, freq, aeg|

    var lpg = LPG.ar(LeakDC.ar(in),
        controlinput: aeg,
        controloffset: \controloffset.kr(0.1, spec: ControlSpec(0, 1, \lin, 0, 0, units:"lpg")),
        controlscale: \controlscale.kr(0.2, spec: ControlSpec(0, 1, \lin, 0, 1, units:"lpg")),
        vca: \vca.kr(0.1, spec: ControlSpec(0, 1, \lin, 0, 1, units: "lpg")),
        resonance: \res.kr(0.2, spec: ControlSpec(0, 1, \lin, 0, 0.2, units:"lpg")).linlin(0, 1, 0, 1.8),
        linearity: \linearity.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"lpg"))
    );

    lpg;
}
)


