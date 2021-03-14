(
// adapted from: https://github.com/madskjeldgaard/Sleet/blob/master/modules/delay.scd
synth: { |in|
    var numchans = 2;
    var phaserrate = \phaserrate.kr(1.0);
    var phaserdepth = \phaserdepth.kr(0.5);

    Array.fill(numchans, {|cNum|
        var phase =  LFPar.kr(phaserrate.linexp(0.0,1.0,0.1,100.0) * cNum.linlin(0, numchans, 0.95,1.05)).range(0.0088, 0.01);
        phaserdepth = phaserdepth.clip(0, 1);
        AllpassL.ar(in[cNum], 4, phase, 0, phaserdepth);
    })
}
)
