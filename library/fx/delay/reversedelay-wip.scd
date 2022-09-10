(
//b = Buffer.alloc(s, Server.default.sampleRate * 4);
synth: {|in|

    var buf = b;
    var recorder1, input, player1, crossovertrigs, crossoverbumps, filt;
    input = in.asArray.sum;

    // Note the phase
    crossovertrigs = Impulse.ar(BufDur.kr(buf).reciprocal * 2, 0.05);
    crossoverbumps = Env.perc(0.05, 0.05, 2, curve: 'sine').ar(crossovertrigs);

    recorder1 = RecordBuf.ar(input, buf, 0, 1, 0, 1, 1);
    player1 = PlayBuf.ar(1, buf, -1, 1, 0, 1);

    filt = XFade2.ar(player1, LPF.ar(player1, 1000), -1 + crossoverbumps);
    in.blend( Splay.ar(filt), 0.5)
},
credits: "https://listarc.cal.bham.ac.uk/lists/sc-users-2007/msg08044.html"
)