SynthDef(\resonz, { |out, freq = 440|
    var    sig, ffreq;
    sig = Mix.ar(Saw.ar([freq, freq+1, freq * 7.midiratio], 0.2));
    ffreq = LFNoise1.kr(2, 0.5, 1);
    Out.ar(out, Mix.ar(Resonz.ar(sig, (800, 1000..1800) * ffreq, 0.1)))
}).add

a = Synth(\resonz);
a.trace;
a.free;

(
~patch3 = {arg key, path, numChannels = 1;

	var buf = Library.at(\bufs, key);
	if (buf.isNil) {
		buf = Buffer.read(s, path);
		Library.put(\bufs, key, buf);
	};

	Ndef(key, {

		var trig = \trig.tr(0);
		var buf = \buf.kr;
		var rate = \rate.kr(1);
		var frames = BufFrames.kr(buf);
		var start = \start.kr(0) * frames;
		var end = \end.kr(1) * frames;
		var dur = ((end-start)/44100) * rate.reciprocal;

		var phase = Env([0, start, end],[0, dur], 0).ar(gate:trig);
		var sig = BufRd.ar(numChannels, buf, phase, interpolation:4);
		//var env = Env.linen(0, 1, 0).kr(gate:trig, timeScale:dur);
		sig = sig * \amp.kr(-12.dbamp);
		Splay.ar(sig, \spread.kr(1), 1, \center.kr(0));
	});

	Pdef(key,
		Pdef(\nbind) <> (node:Ndef(key))
		<> Pbind(\buf, buf)
		<> Pbind(*Ndef(key)
			.controlNames
			.reject({arg ctrl; (ctrl.name == \freq) || (ctrl.name == \trig)})
			.collect({arg ctrl; [ctrl.name, ctrl.defaultValue]}).flatten)
	)
};
)

~patch3.(\p3_s1, "/Users/david/projects/droptableuser/samples/1channel/drums/perc1/djembe/djembe_low.wav");

Pdef(\p3_s1).play;
Pdef(\p3_s1).stop;

(
Pdef(\p3_s1_v1,
	Pchain(
		Pbind(
			\dur, Prand([0.25, 0.5, 1], inf),
			\amp, Pwhite(0.2, 1.0, inf) * -3.dbamp,
		),
		Pdef(\p3_s1)
	)
)
)

Pdef(\p3_s1_v1).play;
(
Ndef(\p3_s1).filter(2, {arg in;
	var beatDur = \beat_dur.kr(1.09091);
	var sig = Squiz.ar(in, 1.5, LFNoise2.kr(1/8).range(2, 20));
	sig = FbC({arg fb; fb * 0.3 + sig}, 2, [3/8, 4/8] * beatDur) + sig;
	Splay.ar(sig);
}).set(\wet2, 0.5);
)