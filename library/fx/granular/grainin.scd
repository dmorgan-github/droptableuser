(
// TODO: in one case there was weird leakage of sound onto other buses caused by this function
// could it be related to the localbuf?
synth: {arg in;

    var sig, rate, dur;

    var buf = LocalBuf(44100 * 5, 1).clear;
    var phase = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
    BufWr.ar(in.asArray.sum, buf, phase);

    // ensure we don't jump ahead of the write head
    phase = phase - [20000, 44100 * 1, 44100 * 2];
    dur = LFNoise1.kr(1/3).range(0.05, 1);
    rate = TChoose.kr(Dust.kr(1), [
        -7.midiratio, 7.midiratio, 0.midiratio, 12.midiratio, -12.midiratio]) * TChoose.kr(Dust.kr(0.5), [-1, 1]);

    sig = GrainBuf.ar(1,
        Dust.ar(LFNoise1.kr([1/13, 1/21, 1/3]).range(5, 12)),
        dur,
        buf,
        rate,
        phase / BufFrames.kr(buf),
        2,
        0,
        -1
    );

    sig = in.blend(sig, \grainin_mix.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.4, "grainin")));
    sig;
}
)
