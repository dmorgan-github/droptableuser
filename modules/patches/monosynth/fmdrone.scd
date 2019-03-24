//////////////////////////////////////////////
// patch


(
Ndef(\fm7, {

	var trig = \trig.tr(0);

	var freq = Vibrato.kr(\freq.kr('C1'.namecps),
		\vrate.kr(6),
		\vdepth.kr(0.001),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var ctrls = [
		[freq,         0,    1 ],
		[freq * 2,     0,    Env.circle([0, 1, 0], [5, 5, 3], -4).kr(gate:1)  ],
		[freq * 2.99,  0,    Env.circle([0, 1, 0], [7, 7, 5], -4).kr(gate:1)   ],
		[0,            0,    0   ],
		[0,            0,    0   ],
		[0,            0,    0   ]
	];

	var mods = [
		[0.6, 0,   1,  0, 0, 0],
		[0,   0.7, 0,  0, 0, 0],
		[0,   0,   0,  0, 0, 0],
		[0,   0,   0,  0, 0, 0],
		[0,   0,   0,  0, 0, 0],
		[0,   0,   0,  0, 0, 0],
	];

	var sig = FM7.ar(ctrls, mods).slice([0,1,3]);

	sig = sig * AmpCompA.kr(freq) * \amp.kr(0.3) * SinOsc.kr(0.1).range(0.1, 1);

	sig = sig.blend(FbC({arg fb; PitchShift.ar(fb * LFSaw.kr(0.05).range(0.0001, 0.8) + sig, 0.2, [1.5,2], 0.01, 0.01)}, 0.5), 0.5);

	sig = BLowShelf.ar(sig, 60, 1.0, -30);

	sig = sig.blend(JPverb.ar(sig, 11, 0, 5), 0.5);

	sig = Splay.ar(sig, spread:\spread.kr(0.5), level:1, center:\center.kr(0.2));

	sig;
});
)

Ndef(\fm7).play;

/////////////////////////////////////////
// fm7 2
(
Ndef(\fm7_2, {

	var trig = \trig.tr(0);

	var freq = Vibrato.kr(\freq.kr('G1'.namecps),
		\vrate.kr(6),
		\vdepth.kr(0.01),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var ctrls = [
		[freq,         0,    1   ],
		[freq * 2.66,  0,    Env.circle([0, 1, 0], [5, 5, 3], -4).kr(gate:1)],
		[freq * 2,     0,    Env.circle([0, 1, 0], [7, 7, 5], -4).kr(gate:1)],
		[0,            0,    0   ],
		[0,            0,    0   ],
		[0,            0,    0   ]
	];

	var mods = [
		[0.7, 0,      2, 0, 0, 0],
		[0,   0.5,    0, 0, 0, 0],
		[0,   0, 0,   0, 0, 0],
		[0,   0, 0,   0, 0, 0],
		[0,   0, 0,   0, 0, 0],
		[0,   0, 0,   0, 0, 0],
	];

	var sig = FM7.ar(ctrls, mods).slice([0,1]);

	sig = sig * AmpCompA.kr(freq) * \amp.kr(0.3) * SinOsc.kr(0.07).range(0.1, 1);

	sig = sig.blend(PitchShift.ar(sig, 0.2, [2, 1.5], 0.01, 0.01), 0.5);

	sig = BLowShelf.ar(sig, 60, 1.0, -60);

	sig = sig.blend(JPverb.ar(sig, 11, 0, 5), 0.7);

	sig = Splay.ar(sig, spread:\spread.kr(0.5), level:1, center:\center.kr(-0.2));

	sig;
});
)

Ndef(\fm7).play;
Ndef(\fm7).set(\freq, 'G1'.namecps);

Ndef(\fm7_2).play(vol:0.4);
Ndef(\fm7_2).set(\freq, 'D2'.namecps);

Ndef(\fm7_2).stop;

/////////////////////////////////////////
// buf
"pdefs.scd".loadRelative;
"fdefs.scd".loadRelative;

Library.put(\bufs, \rec, Buffer.alloc(s, 44100 * 16, 2) );

(
Fdef(\buf, {arg key;

	var buf = Library.at(\bufs, \rec);
	var numFrames = buf.numFrames;
	var dur = buf.duration;

	Ndef(key, {

		var buf = Library.at(\bufs, \rec);

		var foo = {
			var sig = Splay.ar(Ndef(\fm7).ar + Ndef(\fm7_2).ar);// In.ar(0, 2); //Ndef(\synth_1).ar;
			RecordBuf.ar(sig, buf, recLevel:1);
		}.();

		var trig = \trig.tr;
		var numChannels = 2;
		var rate = \rate.kr(1);
		var startPos = \pos.kr(0);
		var loop = \loop.kr(0);
		var dur = \dur.kr(1);
		var sig = PlayBufCF.ar(numChannels, buf, rate, trig, startPos, loop, 0.1, 4);
		var env = Env([0,1,1,0], [0.001, dur, 0.01], curve:\step).kr(gate:trig);
		sig = sig * env * \amp.kr(-12.dbamp);

		//sig = sig.blend( FbC({arg fb; fb * 0.7 + sig}, 4, 4),  1);

		sig = DelayC.ar(sig, 4, 4);

		sig = sig.blend( FbC({arg fb; fb * 0.5 + sig}, [3/4, 5/8]),  0.3);

		//sig = sig.blend(Squiz.ar(sig, [1.5, 2], LFNoise1.kr(1/4).range(1, 30)), 0.5);

		//sig = sig.blend(JPverb.ar(sig, 5, 0, 5), 0.4);

		sig = BLowShelf.ar(sig, 400, 1.0, -60);

		//sig = BHiShelf.ar(sig, 4000, 1.0, -20);

		//sig = sig.blend( FbC({arg fb; fb * 0.7 + sig}, [3/4, 5/8]), 0.5 );
		sig = sig.blend(Greyhole.ar(sig, 5, 0, 5), 0.3);

		sig = Splay.ar(sig, 0.2, 1, 0);

		sig;
	});

	Pdef(key,
		Pdef(\nbind) <> (node:Ndef(key)) <> Pbind(
			\buf, Pfunc({buf}),
			\foo, Pseg([0, numFrames], [dur], 0, inf).collect({arg val; if (0.7.coin){val}{Rest()}}),
			\pos, Pkey(\foo),
			\delta, 0.5,
			\dur, Pkey(\delta) * Pwhite(0.5, 2.0, inf),
			\bar, Pxrand(([12,7,5,14]).midiratio, inf),
			\rate, Pfunc({arg evt; if (0.6.coin) {1}{-1} * if (0.7.coin) {1} {evt[\bar]} }), // reverse is tricky
			\amp, -6.dbamp
		)
	)
});
Fdef(\buf).(\t2);
)

Ndef(\t2).stop;
Pdef(\t2).play;
Pdef(\t2).stop;


(
Ndef(\fm7)
.set(\freq, 'G1'.namecps)
.play(fadeTime:10);
)
Ndef(\fm7).stop;


(
Ndef(\fm7_2)
.set(\freq, 'D2'.namecps)
.play(vol:0.4, fadeTime:10);
)
Ndef(\fm7_2).stop;


/////////////////////////////////////////
// score
(
Tdef(\main, {

	"a".debug("main");

	Ndef(\fm7)
	.set(\freq, 'G1'.namecps)
	.play(fadeTime:10);

	32.wait;

	"b".debug("main");

	Ndef(\fm7_2)
	.set(\freq, 'D2'.namecps)
	.play(vol:0.4, fadeTime:10);

	32.wait;

	"c".debug("main");

	Pdef(\t2).play;

	128.wait;

	"d".debug("main");

	Ndef(\fm7).stop(fadeTime:30);

	16.wait;

	"e".debug("main");

	Ndef(\fm7_2).stop(fadeTime:30);

	Ndef(\t2).stop(fadeTime:45);

})
)

App.saveWorkspace("fmdrone", rec:true);
Tdef(\main).play;

App.saveWorkspace("fmdrone", rec:true);
s.stopRecording


