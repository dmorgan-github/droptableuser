
App.soundflowerOut(s);
TempoClock.default.tempo


~p1 = ProxySpace.new(s);
~p1[\snd].mold

~p1[\snd].clear;
(~p1[\snd][0] = {

	var trig = \trig.tr(1);
	//var freq = \freq.kr();

	var freq = Vibrato.ar(K2A.ar(\freq.kr(432).lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var sig = SinOscFB.ar(freq, SinOsc.kr(0.05).range(0.3, 0.7));
	var env = Decay2.kr(trig, 0.01, \rel.kr(0.1));
	sig = Splay.ar(sig) * env * \amp.kr(0.1);

	sig;
})
(~p1[\snd][4] = \set -> Pbind(
	\trig, 1,
	\amp, 1,
	\dur, 4,
	\rel, 1,
	\scale, Scale.lydian,
	\degree, Pwalk([1,3,2,4], Pseq([1], inf), Pseq([1, -1], inf), 0),
	\octave, 5,
	\vdepth, 0.01
))

(~p1[\snd][8] = nil\filter -> {arg in;

	var sig, sig2;
	var trig;
	var fbNode1 = FbNode(2, 2, 4);
	var fbNode2 = FbNode(2, 2, 4);
	var fbNode3 = FbNode(2, 4.5, 4);
	var fbNode4 = FbNode(2, 2, 4);

	var tap1 = fbNode1.delay(0.25);
	var tap2 = fbNode2.delay(0.5);
	var tap3 = fbNode3.delay;
	var tap4 = (fbNode4.delay(1) * 2).distort;

	fbNode1.write(in + (tap1 * 0.7) + (tap2 * 0.3));
	fbNode2.write(in + (tap2 * 0));
	fbNode3.write(in + (tap3 * 0.6) );
	fbNode4.write(in + (tap4 * 0.3) + (tap1 * 0.4));

	sig = [tap1 + tap2, tap3 + tap4];

	sig;
})

~p1[\fx1].clear;
(~p1[\fx1][0] = {

	var in = ~p1[\snd].ar;
	var sig;
	var trig;
	var fbNode1 = FbNode(2, 2, 4);
	var fbNode2 = FbNode(2, 2, 4);
	var fbNode3 = FbNode(2, 4.5, 4);
	var fbNode4 = FbNode(2, 2, 4);

	var tap1 = fbNode1.delay(0.25);
	var tap2 = fbNode2.delay(0.5);
	var tap3 = fbNode3.delay;
	var tap4 = (fbNode4.delay(1) * 2).distort;

	fbNode1.write(in + (tap1 * 0.7) + (tap2 * 0.3));
	fbNode2.write(in + (tap2 * 0));
	fbNode3.write(in + (tap3 * 0.6) );
	fbNode4.write(in + (tap4 * 0.3) + (tap1 * 0.4));

	sig = [tap1.sum + tap2.sum, tap3.sum + tap4.sum];

	XFade2.ar(in, sig, \wet.kr(0));
});

~p1[\fx1].mold



~p1[\fx2].clear;
(~p1[\fx2][0] = {
	var in = ~p1[\snd].ar;
	XFade2.ar(in, in, 0);
})


~p1[\snd].set(\wet8, 0.8, \wet12, 1);
~p1[\snd].play(out:2);
~p1[\snd].stop;
~p1[\snd].stop(fadeTime:5);

~p1[\fx1].set(\wet, 0.8);
~p1[\fx1].play(out:2);
~p1[\fx1].stop(fadeTime:5);


~p1[\fx2].play(out:4);
~p1[\fx2].stop;



IBufWr




b = Buffer.alloc(s, s.sampleRate, 1);

(~p1[\snd][12] = nil\filter -> {arg in;

	var gain = 1, dur = 1, feedback = 0.7, interp = 1, freq=2000, lag = 0;
    var delout, index;
    index = Phasor.ar(0, Ramp.kr(dur.reciprocal,lag), 0, s.sampleRate);
    delout = BufRd.ar(1, b.bufnum, index,0,1);
	IBufWr.ar(BPF.ar((Mix.ar(in) * gain) + (delout * feedback),freq,1),b.bufnum,index,interp);

	GrainBuf.ar(1, Impulse.kr(SinOsc.kr(0.1).range(1, 20)), 0.1, b, 1, LFNoise2.kr(0.1).range(0.1, 0.3));
	//[0,delout];

})
