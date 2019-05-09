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

Ndef(\fm7).play(vol:1 * 0.2);
Ndef(\fm7).set(\freq, 'G1'.namecps);
Ndef(\fm7).stop;

Ndef(\fm7_2).play(vol:0.4 * 0.2);
Ndef(\fm7_2).set(\freq, 'D2'.namecps);
Ndef(\fm7_2).stop;




