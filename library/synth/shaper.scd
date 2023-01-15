(
if (topEnvironment[\tbuf].isNil) {
    var tf = Signal.newClear(1025).waveFill({|x, old, i|
        sin(x)
    }, -pi/2, pi/2);
    tf = tf.waveFill({|x, old, i|
        old * ( (cos(x*0.08) / 4) + 0.3 )
    }, 0, 25pi).normalize;

    tf = tf.asWavetableNoWrap;
    topEnvironment[\tbuf] = Buffer.loadCollection(s, tf)
};

(
synth: {|freq, gate, aeg|

    var slope = \slope.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"shaper") ).linlin(0, 1, -8, 8);
    var buf = \buf.kr(0);
    var input = LFTri.ar(freq).lincurve(-1, 1, -1, 1, slope);
    var sig = Shaper.ar(buf, input);
    sig = LeakDC.ar(sig);
    sig
}
)
)
