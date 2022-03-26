/////////////////////////////////////////////////////////////////////
// buffer slicer
// numslices, numbeats
(
Spec.add(\numslices, ControlSpec(1, 256, \lin, 1, 8));
Spec.add(\numbeats, ControlSpec(1, 64, \lin, 1, 4));
Pdef(\slicer, Pbind(
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
            var buf = evt['buf'];
            rate = (buf.duration.roundUp/buf.duration).reciprocal;
            rate = rate * thisThread.clock.beatDur;
        };
        rate;
    }),
    \slicedur, Pfunc({|evt|
        var rate = evt['rate'];
        var numslices = evt[\numslices];
        var bufdur = evt[\bufdur] * rate.reciprocal;
        bufdur/numslices
        //var numbeats = evt[\numbeats];
        //var dur = (thisThread.clock.beatDur * numbeats);
        //numslices.reciprocal * dur * thisThread.clock.tempo;
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
        var slicedur = evt[\slicedur];
        var loopprob = evt[\loopprob];
        var loopdurs = evt[\loopdurs];
        if (loopdurs.isNil) {
            loopdurs = [1/2, 1/4, 1/8, 1/32, 1/64, 1/128];
        };
        if (loopprob.coin) {
            evt[\startPos] + (slicedur * loopdurs.choose)
        }{
            1
        }
    })
));
)

