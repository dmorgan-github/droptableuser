Library.put(\bufs, \s16, Buffer.alloc(Server.default, 44100 * 16, 1));

(
Ndef(\broken, {

	var buffer = Library.at(\bufs, \s16);
	var trig = Impulse.kr(1/16);
	var freqval = Demand.kr(trig, 0, Dstutter(2, Dseq(['C2', 'F2'].namecps, inf)));
	var amp = Demand.kr(trig, 0, Dwhite(0.5, 1) * -12.dbamp);
	var freq = Vibrato.kr(freqval.lag(0.1), 6, 0.01);

	var sig = SinOscFB.ar(freq * [1, 1.01], feedback:LFNoise2.kr(0.1).range(0.4, 0.7));

	var env = Env.linen(attackTime:1, releaseTime:4).kr(gate:trig);

	sig = sig * env * AmpCompA.kr(freq) * amp;

	RecordBuf.ar(
		RLPF.ar([sig.sum, Ndef(\broken).ar.sum].sum.softclip, 880, LFNoise2.kr(1/8).range(0.1, 0.5)),
		buffer
	);

	sig = sig.blend(
		GrainBufJ.ar(1,
			trigger: Dust.kr(SinOsc.kr(0.15).range(1,10)),
			dur: SinOsc.kr(0.1).range(0.01, 0.2),
			sndbuf: buffer,
			rate: LFNoise0.kr(0.5).range(0.89, 1.49),
			pos: LFNoise2.kr(0.1).range(0, 1),
			loop:1,
			interp:4),
		0.4
	);

	sig = sig.blend(JPverb.ar(sig, 5, 0, SinOsc.kr(1/64).range(1,2), modDepth:0.7), 0.4);

	sig = sig.blend(JPverb.ar(sig, 3, 0, 3, modDepth:0.7), 0.4);

	sig = BLowShelf.ar(sig, 100, 1, -22);

	sig = Splay.ar(sig);

	sig;
})
)
Ndef(\broken).play(fadeTime:12);
Ndef(\broken).stop(fadeTime:12);