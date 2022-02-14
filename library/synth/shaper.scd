(
if (~tbuf.isNil) {
    var tf = Signal.newClear(1025).waveFill({|x, old, i|
        sin(x)
    }, -pi/2, pi/2);
    tf = tf.waveFill({|x, old, i|
        old * ( (cos(x*0.08) / 4) + 0.3 )
    }, 0, 25pi).normalize;

    tf = tf.asWavetableNoWrap;
    ~tbuf = Buffer.loadCollection(s, tf)
};

(
synth: {|freq, gate, aeg|

    var slope = \slope.kr(0).linlin(0, 1, -8, 8);
    var buf = \buf.kr(0);
    var input = LFTri.ar(freq).lincurve(-1, 1, -1, 1, slope);
    var sig = Shaper.ar(buf, input);

    var feg = {
        Env.adsr(
            attackTime: \fatk.kr(1),
            decayTime: \fdec.kr(0.3),
            sustainLevel: \fsuslevel.kr(1),
            releaseTime: \frel.kr(8),
            peakLevel: \fpeak.kr(1),
            curve: [\fatkcurve.kr(0), \fdeccurve.kr(0), \frelcurve.kr(-4)],
            bias: \fbias.kr(0.5)
        ).ar(gate:gate)
    };

    sig = LeakDC.ar(sig);

    sig = RLPF.ar(sig,
        (\cutoff.kr(1000) * feg.()).clip(20, 20000),
        \res.kr(0).linlin(0, 1, 1, 0.001)
    );

    sig
},
specs: [
    slope: ControlSpec(0, 1, \lin, 0, 0.5, units:"timbre"),
]
)
)