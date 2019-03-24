(
Routine({

	SynthDef(\thing, {

		var trig = \trig.tr;
		var freq = \freq.kr(432);
		var sig = SinOsc.ar(freq);
		var fb;

		var env = {arg trig;
			var suslevel = \suslevel.kr(0.7);
			Env(
				[0,1,suslevel,suslevel,0],
				[\atk.kr(0.001), \dec.kr(0.01), \sus.kr(0), \rel.kr(1)],
				curve:\curve.kr(-4)
			).kr(gate:trig);
		};

		sig = sig * env.(trig) * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);

		fb = FbC({arg fb;
			JPverb.ar(
				PitchShift.ar(fb * 0.4 + sig, 0.5, [7,12].midiratio, 0.01, 0.01),
				10, 0, 5);
		}, 0.1);

		sig = sig.blend(fb, 0.6);

		sig = sig.blend(
			FbC({arg fb; fb * 0.3 + sig}, [0.3, 0.5]),
			0.5
		);

		sig = sig.blend(JPverb.ar(sig, 10, 0, SinOsc.kr(1/16).range(0.01, 0.1)), 0.7);

		sig = Splay.ar(sig);

		Out.ar(\out.kr(0), sig);

	}).add;

	// wait for synthdef to be added
	Server.default.sync();

	Pdef(\thing,

		Ppar([
			Pmono(\thing,
				\dur, 5,
				\atk, 1,
				\sus, 1,
				\rel, 1,
				\dec, 0.3,
				\suslevel, 0.7,

				\scale, Scale.ritusen,
				\degree, Pbrown(0, 7, 1, inf),
				\octave, Prand([3, 4], inf),

				\amp, -12.dbamp
			),

			Pmono(\thing,
				\dur, 7,
				\atk, 1,
				\sus, 1,
				\rel, 1,
				\dec, 0.3,
				\suslevel, 0.7,

				\scale, Scale.ritusen,
				\degree, Pwhite(0, 7, inf),
				\octave, 5,

				\amp, -18.dbamp
			)
		])
	);

	Pdef(\thing).play(argClock:TempoClock.new(60/60));

}).run;
//Pdef(\thing).stop;
)

Pdef(\thing).play(argClock:TempoClock.new(60/60));
Pdef(\thing).stop;