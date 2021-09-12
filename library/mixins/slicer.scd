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
        var numslices = 8;
        if (evt[\numslices].notNil) {
            numslices = evt[\numslices]
        };
        numslices
    }),
    \numbeats, Pfunc({|evt|
        var numbeats = 4;
        if (evt[\numbeats].notNil) {
            numbeats = evt[\numbeats]
        };
        numbeats
    }),
    \bufdur, Pfunc({|evt|
        evt[\buf].duration
    }),
    \rate, Pfunc({|evt|
        var numbeats = evt[\numbeats];
        var beatdur = (evt[\bufdur]/numbeats);
        (beatdur/thisThread.clock.beatDur)
    }),
    \slicedur, Pfunc({|evt|
        var numslices = evt[\numslices];
        var numbeats = evt[\numbeats];
        var dur = (thisThread.clock.beatDur * numbeats);
        numslices.reciprocal * dur * thisThread.clock.tempo;
    }),
    \slices, Pfunc({|evt|
        var numslices = evt[\numslices];
        (0..numslices-1)/numslices;
    }),
    \dur, Pkey(\slicedur),
    \legato, 1,
    \dir, 1,
    \rel, 0.01,
    \atk, 0.01,
    \curve, 0,
    \startPos, Plazy({|evt|
        var val = evt[\slices];
        Pseq(val, 1)
    }),
    \loopprob, Pfunc({|evt|
        var val = evt[\loopprob];
        if (val.isNil) {val = 0};
        val
    }),
    \endPos, Pfunc({|evt|
        var slicedur = evt[\slicedur];
        var loopprob = evt[\loopprob];
        var loopdurs = evt[\loopdurs];
        if (loopdurs.isNil) {
            loopdurs = [1/6, 1/8, 1/16, 1/32];
        };
        if (loopprob.coin) {
            evt[\startPos] + (slicedur * loopdurs.choose)
        }{
            1
        }
    })
))
)

/*
Pbind(
        \buf, Pfunc({|evt|
            var buf = evt[\buf];
            if (buf.isNumber) {
                buf = Buffer.cachedBufferAt(Server.default, buf.asInteger);
            };
            buf
        }),
        \numslices, Pfunc({|evt|
            var numslices = 8;
            if (evt[\numslices].notNil) {
                numslices = evt[\numslices]
            };
            numslices
        }),
        \numbeats, Pfunc({|evt|
            var numbeats = 4;
            if (evt[\numbeats].notNil) {
                numbeats = evt[\numbeats]
            };
            numbeats
        }),
        \bufdur, Pfunc({|evt|
            var bufdur = evt[\bufdur];
            if (bufdur.isNil) {
                var startPos = evt[\startPos] ? 0;
                var endPos = evt[\endPos] ? 1;
                var sr = evt[\buf].sampleRate;
                var numframes = evt[\buf].numFrames;
                var start = numframes * startPos;
                var end = numframes * endPos;
                bufdur = (end - start) / sr;
            };
            bufdur
        }),
        \rate, Pfunc({|evt|
            var rate = evt[\rate];
            if (rate.isNil) {
                if (evt[\bufdur] != evt[\buf].duration) {
                    rate = evt[\bufdur]/evt[\buf].duration;
                    rate = rate.reciprocal
                }{
                    var numbeats = evt[\numbeats];
                    var beatdur = (evt[\bufdur]/numbeats);
                    rate = (beatdur/thisThread.clock.beatDur);
                };
            };
            rate
        }),
        \slicedur, Pfunc({|evt|
            var numslices = evt[\numslices];
            var numbeats = evt[\numbeats];
            var dur = evt[\bufdur];//(thisThread.clock.beatDur * numbeats);
            numslices.reciprocal * dur * thisThread.clock.tempo;
        }),
        \slices, Pfunc({|evt|
            var numslices = evt[\numslices];
            var startPos = evt[\startPos] ? 0;
            var endPos = evt[\endPos] ? 1;
            numslices = (0..numslices-1)/numslices;
            numslices = numslices.linlin(0, 1, startPos, endPos);
            numslices
        }),
        \dur, Pkey(\slicedur),
        \legato, 1,
        \dir, Pfunc({|evt|
            var revprob = evt[\revprob] ? 0;
            if (revprob.coin) {
                -1
            }{
                1
            }
        }),
        \rel, 0.01,
        \atk, 0.01,
        \curve, 0,
        \startPos, Plazy({|evt|
            var val = evt[\slices].mirror2.scramble;
            Pseq(val, 1);
        }),
        \loopprob, Pfunc({|evt|
            var val = evt[\loopprob];
            if (val.isNil) {val = 0};
            val
        }),
        \endPos, Pfunc({|evt|
            var slicedur = evt[\slicedur];
            var loopprob = evt[\loopprob];
            var loopdurs = evt[\loopdurs];
            var endPos = evt[\endPos] ? 1;
            if (loopdurs.isNil) {
                loopdurs = [1/6, 1/8, 1/16, 1/32];
            };
            if (loopprob.coin) {
                evt[\startPos] + (slicedur * loopdurs.choose)
            }{
                1
            }
        })
    ).repeat
*/

