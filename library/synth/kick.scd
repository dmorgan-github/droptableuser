(
synth: {|freq|
    var fdecay = \fdecay.kr(0.35, spec: ControlSpec(0, 1, \lin, 0, 0.35, "kick"));
    var fcurve = \fcurve.kr(-8, spec: ControlSpec(-8, 8, \lin, 0, -4, "kick"));
    var freqmul = \freqmul.kr(3.99, spec:ControlSpec(1, 4, \lin, 0, 3.99, "kick"));
    var phaseoffset = \phaseoffset.kr(0.5pi, spec: ControlSpec(0pi, 2pi, \lin, 0, 0.5pi, "kick"));
    var baseq = \basseq.kr(60, spec: ControlSpec(20, 110, \lin, 0, 60, "kick"));
    var bassgain = \bassgain.kr(1, spec: ControlSpec(0, 12, \lin, 0, 0, "kick"));
    var drive = \drive.kr(1.02, spec: ControlSpec(1, 12, \lin, 0, 1.02, "kick"));
    var clickamt = \clickamt.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "kick"));

    var freqmulenv = Env.perc(0.001,
        releaseTime: fdecay,
        curve: fcurve
    ).ar(gate:1).linlin(0, 1, 1, freqmul);

    var click = BPF.ar(WhiteNoise.ar, 10120, 0.5) * Env.perc(0.001, 0.03).ar;

    var sig = SinOsc.ar(freq * freqmulenv, phaseoffset);
    sig = sig + (click * clickamt);
    sig = sig * (Env.perc.ar(0.001, 0.2).linlin(0, 1, 1, drive));
    sig = tanh(sig);
    sig = LeakDC.ar(sig);
    sig = CompanderD.ar(sig, \thresh.kr(0.1), \slopebelow.kr(0.5), \slopeabove.kr(1.3), 0.001);
    sig = BPeakEQ.ar(sig, baseq, bassgain);
    //sig = sig * Line.ar(2, 1, 0.002);
    sig
},
credits: "based on a nathan ho recipe",
presets: [

    preset1: [
        atk: 0.001, 
        rel: 0.8,
        fcurve: -12, 
        basseq: 30,
        clickamt: 0.3, 
        amp: 0.5,
        relcurve: -2, 
        drive: 1.02,
        midinote: 34
    ]
]
)

