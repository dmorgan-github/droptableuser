(
// adapted from https://github.com/madskjeldgaard/Sleet/blob/master/modules/granular.scd
synth: {|in|

    var numchans = 2;
    var fbgrainsize = \fbgrainsize.kr(0.25);
    var fbgrainrand = \fbgrainrand.kr(0.8);
    var fbGain = \fbGain.kr(0.1);

    var bufLength = 1.0;
    var localBuf = LocalBuf(
        bufLength * SampleRate.ir,
        numchans
    ).clear;

    var warp = Warp1.ar(
        numchans,
        localBuf,
        LFSaw.ar(1/bufLength).linlin(-1.0,1.0,0.0, 1.0),
        Drand([ 2, - 2 ], inf),
        fbgrainsize.linlin(0.0, 1.0, 0.0, 2.0),
        -1,
        2,
        fbgrainrand.linlin(0.0, 1.0, 0.2, 1.0),
        4
    );

    // record w/ feedback
    RecordBuf.ar(tanh(in + HPF.ar(tanh(warp * fbGain), 30)), localBuf);

    warp = warp.tanh;
    warp = HPF.ar(warp * 0.5, 150);
    warp.sanitize;
}
)