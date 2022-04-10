/////////////////////////////////////////////////////////////////////
// buffer slicer
// numslices, numbeats
(
Spec.add(\numslices, ControlSpec(1, 256, \lin, 1, 8));
Spec.add(\numbeats, ControlSpec(1, 64, \lin, 1, 4));
Pdef(\slicer, Pbind(
    \legato, 1,
    \atk, 0.01,
    \rel, 0.1,
    \suslevel, 1,
    \buf, Pfunc({|evt|
        var buf = evt[\buf];
        if (buf.isNumber) {
            buf = Buffer.cachedBufferAt(Server.default, buf.asInteger);
        };
        buf
    }),
    \numslices, Pfunc({|evt|
        var numslices = evt[\numslices];
        if (numslices.isNil) {
            numslices = 8;
        };
        numslices
    }),
    \numbeats, Pfunc({|evt|
        var numbeats = evt[\numbeats];
        if (numbeats.isNil) {
            numbeats = 2;
        };
        numbeats;
    }),
    \start, Pfunc({|evt|
        var start = evt[\startPos];
        if (start.isNil) {
            start = 0;
        };
        start;
    }),
    \end, Pfunc({|evt|
        var end = evt[\endPos];
        if (end.isNil) {
            end = 1;
        };
        end;
    }),
    \bufdur, Pfunc({|evt|
        var bufdur = evt[\bufdur];
        if (bufdur.isNil) {
            var buf = evt[\buf];
            var start = evt[\start] * buf.numFrames;
            var end = evt[\end] * buf.numFrames;
            var frames = end - start;
            bufdur = frames/buf.sampleRate;
        };
        bufdur;
    }),
    \rate, Pfunc({|evt|
        var rate = evt[\speed];
        if (rate.isNil) {
            //var buf = evt['buf'];
            var bufdur = evt['bufdur'];
            var dur = evt['numbeats'] * thisThread.clock.beatDur;
            rate = (bufdur/dur);
            rate;// = rate * thisThread.clock.beatDur;
        };
        rate;
    }),
    \slices, Pfunc({|evt|
        var numslices = evt[\numslices];
        (0..numslices-1)/numslices;
    }),
    \dur, Pfunc({|evt|
        var numslices = evt['numslices'];
        var numbeats = evt['numbeats'];
        numbeats/numslices;
    }),
    \startPos, Plazy({|evt|
        var val = evt[\slices];
        var start = evt[\start];
        var end = evt[\end];
        var filter = evt[\slicesfilter];
        if (filter.notNil) {
            val = filter.(val);
        };
        Pseq(val, 1).linlin(0, 1, start, end);
    }),
    \loopprob, Pfunc({|evt|
        var val = evt[\loopprob];
        if (val.isNil) {
            val = 0
        };
        val
    }),
    \endPos, Pfunc({|evt|
        var slicedur = evt[\dur];
        var loopprob = evt[\loopprob] ?? 0;
        var loopdurs = evt[\loopdurs];
        if (loopdurs.isNil) {
            loopdurs = [1/2, 1/4, 1/8, 1/32];
        };

        loopprob.asArray.collect({|val|
            if (val.coin) {
                evt[\startPos] + (slicedur * loopdurs.choose)
            }{
                1
            }
        });
    })
));
)

