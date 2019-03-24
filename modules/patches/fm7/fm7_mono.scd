//////////////////////////////////////////////
// patch
(
Ndef(\fm7, {

	var trig = \trig.tr(0);

	var freq = Vibrato.kr(\freq.kr('C1'.namecps),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var ctrls = [
		[freq,        0,    1   ],
		[freq * 2,    0,    1   ],
		[0,           0,    0   ],
		[0,           0,    0   ],
		[0,           0,    0   ],
		[0,           0,    0   ]
	];

	var mods = [
		[1, 0, 0, 0, 0, 0],
		[0, 1, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0],
	];

	var sig = FM7.ar(ctrls, mods).slice([0,1]);

	//sig = sig * AmpCompA.kr(freq) * \amp.kr(0.3);

	//sig = Splay.ar(sig, \spread.kr(1), 0, \center.kr(0));

	SinOsc.ar(432);
});
)


Ndef(\fm7).play;

