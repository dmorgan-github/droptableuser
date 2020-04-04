//////////////////////////////////////////////
// patch
Ndef(\fm7).mold

(
Ndef(\fm7, {

	var trig = \trig.tr(0);

	var freq = Vibrato.kr(\freq.kr('C1'.namecps),
		\vrate.kr(6),
		\vdepth.kr(0.01),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var ctrls = [
		[freq,        0,    Env.circle([0, 1, 0], [13, 13, 7], -4).kr(gate:1) ],
		[freq * 2,    0,    Env.circle([0, 1, 0], [5, 5, 3], -4).kr(gate:1)   ],
		[freq * 1.5,  0,    Env.circle([0, 1, 0], [7, 7, 5], -4).kr(gate:1)   ],
		[0,           0,    0   ],
		[0,           0,    0   ],
		[0,           0,    0   ]
	];

	var mods = [
		[SinOsc.kr(0.01).range(0.3, 1), 0, 0.5, 0, 0, 0],
		[0, SinOsc.kr(0.1).range(0.1, 1.5), 0,   0, 0, 0],
		[0, 0, 0,   0, 0, 0],
		[0, 0, 0,   0, 0, 0],
		[0, 0, 0,   0, 0, 0],
		[0, 0, 0,   0, 0, 0],
	];

	var sig = FM7.ar(ctrls, mods).slice([0,1]);

	sig = sig * AmpCompA.kr(freq) * \amp.kr(0.3);

	sig = sig.blend(PitchShift.ar(sig, 0.2, [2, 1.5], 0.01, 0.01), 0.5);

	sig = sig.blend(FbC({arg fb; DFM1.ar(fb * 0.6 + sig, 1880, 0.5)}, [0.1, 0.3]), SinOsc.kr(0.15).range(0.01, 0.1));

	sig = sig.blend(FbC({arg fb; PitchShift.ar(fb * 0.9 + sig, 0.5, 1.5, 0.01, 0.01)}, [3/4, 5/8]), SinOsc.kr(0.25).range(0.3, 0.8));

	sig = BLowPass.ar(sig, SinOsc.kr(0.1).range(440, 2200), 0.9);

	sig = sig.blend(JPverb.ar(sig, 7, 0, 5), 0.7);

	sig = Splay.ar(sig, spread:\spread.kr(1), level:1, center:\center.kr(0));

	sig;
});
)


Ndef(\fm7).play(vol:0.3);

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
		[freq * 1.7,   0,    Env.circle([0, 1, 0], [5, 5, 3], -4).kr(gate:1)],
		[freq * 2,     0,    Env.circle([0, 1, 0], [7, 7, 5], -4).kr(gate:1)],
		[0,            0,    0   ],
		[0,            0,    0   ],
		[0,            0,    0   ]
	];

	var mods = [
		[1, 0, SinOsc.kr(0.103).range(0.1,2), 0, 0, 0],
		[0, 1, 0,   0, 0, 0],
		[0, 0, 0,   0, 0, 0],
		[0, 0, 0,   0, 0, 0],
		[0, 0, 0,   0, 0, 0],
		[0, 0, 0,   0, 0, 0],
	];

	var sig = FM7.ar(ctrls, mods).slice([0,1]);

	sig = sig * AmpCompA.kr(freq) * \amp.kr(0.3);

	sig = sig.blend(PitchShift.ar(sig, 0.2, [2, 1.5], 0.01, 0.01), 0.5);

	sig = sig.blend(SoftClipAmp8.ar(sig, 4), 0.5);

	sig = BLowPass.ar(sig, SinOsc.kr(0.103).range(440, 2200), 0.9);

	sig = sig.blend(JPverb.ar(sig, 7, 0, 5), 0.7);

	sig = Splay.ar(sig, spread:\spread.kr(1), level:1, center:\center.kr(0));

	sig;
});
)

App.recAtCommit("wip5", "7f76fc8");
Ndef(\fm7).play(vol:0.5);
Ndef(\fm7).stop(fadeTime:8);

App.recAtCommit("wip5", "7f76fc8");
Ndef(\fm7_2).play(vol:0.2);
Ndef(\fm7_2).stop(fadeTime:8);

s.stopRecording;



