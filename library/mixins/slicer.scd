/////////////////////////////////////////////////////////////////////
// buffer slicer
(
Pdef(\slicer, Pbind(
    \numslices, Pfunc({|evt| if (evt[\numslices].isNil) {8} {evt[\numslices]} }),
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
    \rel, 0,
    \atk, 0,
    \curve, 0,
    \startPos, Plazy({|evt|
        var val = evt[\slices];
        Pseq(val, 1)
    }).repeat,
    \loopprob, Pfunc({|evt|
        var val = evt[\loopprob];
        if (val.isNil) {val = 0};
        val
    }),
    \endPos, Pfunc({|evt|
        var slicedur = evt[\slicedur];
        var loopprob = evt[\loopprob];
        if (loopprob.coin) {
            evt[\startPos] + (slicedur * [1/3, 1/6, 1/8, 1/16].choose)
        }{
            1
        }
    })
))
)

