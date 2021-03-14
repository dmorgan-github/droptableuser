(
// adapted from: https://github.com/madskjeldgaard/Sleet/blob/master/modules/delay.scd
synth: { |in|

    var numchans = 2;
    var flangdelay = \flangdelay.kr(0.1);
    var flangdepth = \flangdepth.kr(0.5);
    var flangrate = \flangrate.kr(0.06);
    var flangfb = \flangfb.kr(0.1);

    var input, maxdelay, maxrate, dsig, mixed, local;
    maxdelay = 0.013;
    maxrate = 10.0;
    input = in;
    local = LocalIn.ar(numchans);

    dsig = Array.fill(numchans, {|cNum|
        AllpassC.ar(
            input[cNum] + (local[cNum] * flangfb),
            maxdelay,
            LFTri.kr(
                flangrate.linexp(0.0,1.0,0.00001, maxrate),
                0,
                flangdepth * maxdelay,
                flangdelay * maxdelay
            ),
            0
        );
    });

    LocalOut.ar(dsig);
    dsig;
}
)