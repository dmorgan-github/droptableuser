Ndef.all[\localhost].envir
Ndef(\test1)
Ndef(\test2)


~p.push;

currentEnvironment.pop

q = q ? ();
q[\b] = q[\b] ? ();
q[\b][\b1] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/BassDrum/KickDrum0001.aif");
q[\b][\b2] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/SnareDrum/SnareDrum0002.aif");
q[\b][\b3] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Cls'd Hihat/Closed Hihat0001.aif");
q[\b][\b4] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Open Hihat/Open Hihat0001.aif");
q[\b][\cp] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Misc/Clap.aif");


~p.play

TempoClock.default.tempo_(90/60)

Pdefn(\t5_mtranspose, 0)

/////////////////////////////////////////
// t5 base pattern
(
Pdef(\t5_base,

	Pbind(
		\type, \set,
		\id, Pfunc({arg evt; evt[\node].nodeID;}),
		\trig, 1,
		\amp, Pkey(\amp) * 1,
		\scale, Scale.hexSus,
		\mtranspose, Pdefn(\t5_mtranspose),
	)
);
)

/////////////////////////////////////////
// t5
(
var func = {
	var numChannels = 1;
	var trig = \trig.tr(0);
	var buf = \buf.kr;
	var rate = \rate.kr(1);
	var frames = BufFrames.kr(buf);
	var start = \start.kr(0) * frames;
	var end = \end.kr(1) * frames;

	var dur = ((end-start)/44100) * rate.reciprocal;
	var phase = Env([start, start, end],[0, dur], \phasecurve.kr(0)).ar(gate:trig);
	var sig = BufRd.ar(numChannels, buf, phase, loop:0, interpolation:4);
	//var env = Env.linen(0, 1, 0).kr(gate:trig, timeScale:dur);
	//var sig = PlayBuf.ar(numChannels, buf, rate, trig, start, loop:0);

	sig = sig * \amp.kr(-12.dbamp);
	Pan2.ar(sig, \pan.kr(0));
};

var envir = currentEnvironment;

var patterns = [
	{
		var p = Pbind(
			\args, #[\trig, \amp, \freq],
			\amp, -3.dbamp,
			\foo, 1,
			\degree, Pstutter(5, Pseq([0, 1], inf)),
			\dec, Pseq([
				Pseq([0.1], 2),
				Pseq([1], 3)
			], inf),
			\octave, 4,//Pstutter(14, Pseq([4,5], inf)),
			\dur, Pbjorklund2(5, 7, inf) * 0.5
		);

		var n = {

			var numvoices = 2;
			var detune = \detune.kr(0.01);
			var trig = \trig.tr;
			var freq = Vibrato.kr(
				\freq.kr(432).lag(\lag.kr(0.1)),
				\vrate.kr(6),
				\vdepth.kr(0.01)
			);// * Env([2, 2, 1], [0, 0.05], 0).kr(gate:trig);

			var which = \which.kr(2);
			var focus = \focus.kr(0.1);
			var atk = \atk.kr(0.001);
			var decay = \dec.kr(0.3);
			var noise = SelectXFocus.kr(
				which,
				[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1)],
				focus,
				wrap:true);

			var ex = K2A.ar(trig);//Latch.ar(noise, trig);
			var sig = Formlet.ar(ex, freq * [1, 1.01], atk, decay);

			sig = Limiter.ar(sig.sum, 0.8) * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);

			//sig = Splay.ar(PMOsc.ar(freq * [1, 1.01], freq * [0.51, 1], Env([3, 3, 0.01],[0, 0.1],-4).kr(gate:trig)).tanh, 0.5) * 0.1 + sig;

			//sig = RLPF.ar(sig, Env([freq * 6, freq * 6, 220],[0, 1],-4).kr(gate:trig), 0.2);

			sig = JPverb.ar(HPF.ar(sig, 110), 3, 0, 5) * 0.4 + sig;
			sig;

			/*
			var freq = \freq.kr(432);
			var trig = \trig.tr;
			var sig = [
				SinOsc.ar(freq),
				SinOsc.ar(freq * 1.01).tanh
			] * [1, 0.5].normalizeSum;
			var env = Env.perc(releaseTime:0.8).kr(gate:trig);
			sig = sig.sum * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);

			sig;
			*/
		};

		(k:\t5_1, p:p, n:n);
	},

	{
		var p = Pbind(
			\args, #[\trig, \amp, \freq],
			\amp, -3.dbamp, //Pseq([0.dbamp, -12.dbamp], inf),
			\degree, Pseq([
				Pseq([0], 5),
				Pseq([-2, -5], 1),
				Pseq([2], 3)
			], inf),
			\octave, 6,
			\foo, 2,
			\dur, Pbjorklund2(3, 9, inf) * 0.25
		);

		var n = {

			var numvoices = 2;

			var detune = \detune.kr(0.01);
			var trig = \trig.tr;
			var freq = Vibrato.kr(
				\freq.kr(432).lag(\lag.kr(0.1)),
				\vrate.kr(6),
				\vdepth.kr(0.001)
			);

			var which = \which.kr(1);
			var focus = \focus.kr(0.5);
			var atk = \atk.kr(0.001);
			var decay = \dec.kr(0.1);
			var noise = SelectXFocus.kr(
				which,
				[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1)],
				focus,
				wrap:true);

			var sig = {
				var ex = Latch.ar(noise, trig);
				Formlet.ar(ex, freq * LFNoise2.kr(\ddepth.kr(5)).range(1 + detune.neg, 1 + detune), atk, decay);
			}.dup(numvoices) * Array.fill(numvoices,1).normalizeSum;

			sig = Limiter.ar(sig.sum, 0.8) * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
			//sig = FbC({arg fb; fb * 0.4 + sig}, [3/4, 4/4]) * 0.4 + sig;
			sig = JPverb.ar(sig, 5, 0, 5) * 0.2 + sig;
			sig;
		};

		(k:\t5_2, p:p, n:n);
	},

	{
		var p = Pbind(
			\args, #[\trig, \amp, \freq],
			\amp, -12.dbamp, //Pseq([0.dbamp, -12.dbamp], inf),
			\degree, Ppatlace([Pseq([-2, 4], inf), Prand([0,1,2,3], inf)], inf),
			\octave, 7,
			\foo, 2,
			\dur, 0.25
		);

		var n = {

			var numvoices = 2;
			var detune = \detune.kr(0.01);
			var trig = \trig.tr;
			var freq = Vibrato.kr(
				\freq.kr(432).lag(\lag.kr(0.1)),
				\vrate.kr(6),
				\vdepth.kr(0.001)
			);

			var which = \which.kr(1);
			var focus = \focus.kr(0.5);
			var atk = \atk.kr(0.001);
			var decay = \dec.kr(0.5);
			var noise = SelectXFocus.kr(
				which,
				[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1)],
				focus,
				wrap:true);

			var sig = {
				var ex = Latch.ar(noise, trig);
				Formlet.ar(ex, freq * LFNoise2.kr(\ddepth.kr(5)).range(1 + detune.neg, 1 + detune), atk, decay);
			}.dup(numvoices) * Array.fill(numvoices,1).normalizeSum;

			sig = Limiter.ar(sig.sum, 0.8) * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
			sig = FbC({arg fb; fb * 0.4 + sig}, [3/4, 4/4]) * 0.4 + sig;
			sig = JPverb.ar(sig, 5, 0, 5) * 0.2 + sig;
			sig;
		};

		(k:\t5_3, p:p, n:n);
	},

	{
		var p = Pbind(
			\args, #[\trig, \amp, \freq],
			\amp, 0.dbamp, //Pseq([0.dbamp, -12.dbamp], inf),
			\scale, Scale.dorian,
			\degree, 0,//Ppatlace([Pseq([-2, 4], inf), Prand([0,1,2,3], inf)], inf),
			\octave, 6,
			\foo, 2,
			\dur, Pbjorklund2(9, 13) * 0.25
		);

		var n = {

			var numvoices = 2;
			var detune = \detune.kr(0.01);
			var trig = \trig.tr;
			var freq = Vibrato.kr(
				\freq.kr(432).lag(\lag.kr(0.1)),
				\vrate.kr(6),
				\vdepth.kr(0.001)
			);

			var which = \which.kr(1);
			var focus = \focus.kr(0.5);
			var atk = \atk.kr(0.001);
			var decay = \dec.kr(0.5);
			var noise = SelectXFocus.kr(
				which,
				[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1)],
				focus,
				wrap:true);

			var sig = {
				var ex = Latch.ar(noise, trig);
				Formlet.ar(ex, freq * LFNoise2.kr(\ddepth.kr(5)).range(1 + detune.neg, 1 + detune), atk, decay);
			}.dup(numvoices) * Array.fill(numvoices,1).normalizeSum;

			sig = Limiter.ar(sig.sum, 0.8) * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);

			sig = HPF.ar(CombC.ar(Squiz.ar(sig, [2, 1.5], SinOsc.kr(1/32).range(1, 30)), 1, LFNoise0.kr(13).range(0.1, 1), 7), 880) * 0.18 + sig;

			sig = JPverb.ar(sig, 5, 0, 5) * 0.3 + sig;

			sig = Rotate2.ar(sig[0], sig[1], LFTri.kr(1/4));

			sig;
		};

		(k:\t5_4, p:p, n:n);
	},

	{
		var p = Pbind(
			\args, #[\trig, \amp, \buf],
			\amp, -6.dbamp, //Pseq([0.dbamp, -12.dbamp], inf),
			\buf, q[\b][\cp],
			\foo, 1,
			\dur, 1
		);

		var n = {

			var buf = \buf.kr(8);
			var trig = \trig.tr;
			var sig = PlayBuf.ar(1, bufnum:buf, rate:1, trigger:trig, startPos:0, loop:0);
			sig = Pan2.ar(sig) * \amp.kr(0.dbamp);
			sig;
		};

		(k:\t5_5, p:p, n:n);
	}

].collect({arg func, i;
	var obj = func.();
	var key = obj[\k];
	var pat = obj[\p];
	var node = obj[\n];
	if (node.isKindOf(Function)) {
		envir[key] = node;
		node = envir[key];
	};
	Pdef(\t5_base) <> Pbind(\node, Pfunc({node})) <> pat;
});

{
	var toMerge = List();
	var mergeFunc = {arg events;
		//events.detect({arg e; e[\foo] == 1})
		var event = events.detect({arg e; e[\foo] == 1});
		if (event.isNil.not) {
			event;
		} {
			event = events.detect({arg e; e[\foo] == 2});
			if (event.isNil.not) {
				event;
			}{
				events.choose;
			}
		}
	};
	Pdef(\t5_filter, Pfunc({arg event;

		// collect parallel events
		if (event[\delta] < 0.000001) {
			toMerge.add(event);
			// replace current event with silence
			event = Event.silent(event[\delta], event);
		} {
			// last parallel event will have non-zero delta
			if (toMerge.size > 0) {
				// add event to accumulation
				toMerge.add(event);
				// call logic to create merged event
				event = mergeFunc.(toMerge).put(\delta, event[\delta]);
				// start all over
				toMerge.clear();
			}
		};
		event;
	}));
}.();


Pdef(\t5_main, {
	"init".debug(\t5_main);
	Pdef(\t5_filter) <> Ppar(patterns, inf);
});
)



(
SynthDef(\oneshot, {

	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var sig = PlayBuf.ar(1, buf, rate, loop:0, doneAction:2);
	sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(0.1);

	OffsetOut.ar(\out.kr(0), sig);

}).add;
)

q[\b][\cp] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Misc/Clap.aif");

(
Pdef(\cp, Pbind(
	\instrument, \oneshot,
	\buf, q[\b][\cp],
	\dur, 1
))
)


(\a).do({arg val; val.postln;})


q[\b][\cp].play
/////////////////////////////////////////
// t5 play
~t5_1.play;
~t5_2.play;
~t5_3.play;

~t5_1.stop;
~t5_2.stop;
~t5_3.stop;

~t5_mix[0] = \mix -> {~t5_1.ar};
~t5_mix[1] = \mix -> {~t5_2.ar};
~t5_mix[2] = \mix -> {~t5_3.ar};
~t5_mix[3] = nil\mix -> {~t5_4.ar};
~t5_mix[4] = \mix -> {~t5_5.ar};
~t5_mix.play;


(
~t5_rev = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 5, 0, 5);
	fx
};
)
~t5_rev <<> ~t5_mix;
~t5_rev.play(vol:0.1);
~t5_rev.stop;

~t5_mix.play;
Pdef(\t5_main).play;
Pdef(\t5_main).stop;



App.saveWorkspace("ws4", rec:true);

s.record;
s.stopRecording;

