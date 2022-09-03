(
synth: {|freq|

    var sig;
    var vel = ~vel ?? 0;
    var velamt = ~velamt ?? 0.55;

    //var skewlforate = \skewlforate.kr(0, spec:ControlSpec(0, 20, \lin, 0, 0, "squine"));
    //var skewlfodepth = \skewlfodepth.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "squine"));
    //var skewlfo = SinOsc.ar(skewlforate).unipolar(skewlfodepth);

    //var cliplforate = \cliplforate.kr(0, spec:ControlSpec(0, 20, \lin, 0, 0, "squine"));
    //var cliplfodepth = \cliplfodepth.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "squine"));
    //var cliplfo = SinOsc.ar(cliplforate).unipolar(cliplfodepth);

    var clip = \clip.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"squine"));
    var skew = \skew.kr(0, spec:ControlSpec(-1, 1, \lin, 0, 0, units:"squine"));
    var sync = \hardsync.kr(0);

    vel = 1+(vel * velamt);

    skew = skew * vel;
    clip = clip * vel;

    sig = Squine.ar(freq, clip.clip(0, 1), skew.clip(-1, 1), sync);
    sig;
}
)