/*
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
*/

R : D {

    var <phase;

    deviceInit {
        this.prBuild
    }

    prBuild {

        // requires mono buffer
        //~rec.set(\rate, -1, \rec, 0, \fb, 0.99)
		this.play;
        this.filter(100, {|sig_in|
            var updateFreq = 15;
            var replyid = \bufposreplyid.kr(-1);
            var buf = \buf.kr(0);
            var in = sig_in.asArray.sum;//In.ar(\in.kr(0), 2).asArray.sum;
            var frames = BufFrames.kr(buf);
            var rate = \rate.kr(1);
            var start = \startPos.kr(0) * frames;
            var end = \endPos.kr(1) * frames;
            var rec = \rec.kr(1);
            var phase = Phasor.ar(1, rate * BufRateScale.kr(buf), start, end);
            var fb = LocalIn.ar(1);
            var wr = BufWr.ar( (in * rec) + (fb * \fb.kr(0.7)), buf, phase, 1);
            var sig = BufRd.ar(1, buf, phase, 1, 4);
            sig = LeakDC.ar(sig);
            LocalOut.ar(sig);
            SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase], replyid);
            Splay.ar(sig, \spread.kr(1), center:\pan.kr(0));
		});
	}

    view {|index|
       U(\buf, this)
    }
}
