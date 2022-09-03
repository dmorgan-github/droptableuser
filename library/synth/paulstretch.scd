(
// http://sccode.org/1-5d6
// Based on the Paul's Extreme Sound Stretch algorithm by Nasca Octavian PAUL
// https://github.com/paulnasca/paulstretch_python/blob/master/paulstretch_steps.png
//
// By Jean-Philippe Drecourt
// http://drecourt.com
// April 2020
// see comment: http://sccode.org/1-5d6#c1012
synth: {|freq|

    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var bufnum = \buf.kr(0);
    var start = \startPos.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "paulstretch"));
    var end = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, "paulstretch"));
    var bufFrames = BufFrames.kr(bufnum);
    var bufdur = BufDur.kr(bufnum);

    var envBufnum = {
        if (~psenvbuf.isNil.debug("psenvbuf")) {
            var server = Server.default;
            var envBuf = Buffer.alloc(server, server.sampleRate, 1);
            var envSignal = Signal.newClear(server.sampleRate).waveFill({|x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
            envBuf.loadCollection(envSignal);
            ~psenvbuf = envBuf;
        };
        ~psenvbuf;
    }.();

    //var pan = \pan.kr(0);
    var stretch = \stretchamt.kr(50, spec: ControlSpec(1, 100, \lin, 0, 50, "paulstretch"));
    var window = \window.kr(0.25);
    var amp = 1;

    var root = \rootfreq.kr(60.0.midicps,
        spec:ControlSpec(20, 20000, \exp, 0, 60.0.midicps, units:"paulstretch")
    ).clip(20, 20000);

    var pitched = \pitched.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, units:"paulstretch"));

    var rate = Select.kr(pitched, [
        1,
        (freq ?? root)/root
    ]).asArray[0];

    var trigPeriod, sig, chain, trig, pos, fftSize;

	// Calculating fft buffer size according to suggested window size
	fftSize = 2**floor(log2(window*SampleRate.ir));
	// Grain parameters
	// The grain is the exact length of the FFT window
	trigPeriod = fftSize/SampleRate.ir;
	trig = Impulse.ar(1/trigPeriod);
    pos = Demand.ar(trig, 0, demandUGens: Dseries(start, trigPeriod/(stretch*bufdur))).wrap(start, end);
	// Extraction of 2 consecutive grains
	// Both grains need to be treated together for superposition afterwards
	sig = [GrainBuf.ar(1, trig, trigPeriod, bufnum, rate, pos, envbufnum: envBufnum),
		GrainBuf.ar(1, trig, trigPeriod, bufnum, rate, pos + (trigPeriod/(2*stretch*bufdur)), envbufnum: envBufnum)] * amp;
	// FFT magic
	sig = sig.collect({ |item, i|
		chain = FFT(LocalBuf(fftSize), item, hop: 1.0, wintype: -1);
		// PV_Diffuser is only active if its trigger is 1
		// And it needs to be reset for each grain to get the smooth envelope
		chain = PV_Diffuser(chain, 1 - trig);
		item = IFFT(chain, wintype: -1);
	});
	// Reapply the grain envelope because the FFT phase randomization removes it
	sig = sig*PlayBuf.ar(1, envBufnum, 1/(trigPeriod), loop:1);
	// Delay second grain by half a grain length for superposition
	sig[1] = DelayC.ar(sig[1], trigPeriod/2, trigPeriod/2);
	// Panned output
	//Out.ar(out, Pan2.ar(Mix.new(sig), pan));
    //Mix.new(sig)


    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, pos * bufFrames], replyid);

    sig.sum!2
}
)