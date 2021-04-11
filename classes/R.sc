R {

    *rec {|bus, buf|
        var synth = Synth(\rec, [\buf, buf, \in, bus, \preLevel, 0, \run, 1], addAction:\addToTail);
        synth.onFree({ {
            U(\wave, buf);
        }.defer });
    }

    *initClass {

        StartUp.add({
            SynthDef(\rec, {
                var buf = \buf.kr(0);
                var in = In.ar(\in.kr(0), 2).asArray.sum;
                var sig = RecordBuf.ar(in, buf,
                    \offset.kr(0),
                    \recLevel.kr(1),
                    \preLevel.kr(0),
                    \run.kr(1),
                    \loop.kr(0),
                    1,
                    doneAction:Done.freeSelf);
                Out.ar(0, Silent.ar(2));
            }).add;

        });
    }
}