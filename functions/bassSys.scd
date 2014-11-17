(
SynthDef(\snd1, {
	var sig = SinOsc.ar(44.midicps, 0, 0.5) + SinOsc.ar(90.midicps, 0, 0.6);
	var env = EnvGen.ar(Env([0, 1, 0.6, 0], [0.0001, 0.4, 0.01]), 1, doneAction:2);
	sig = LPF.ar(sig, 32.midicps * 2);
	sig = sig + HPF.ar(LPF.ar(WhiteNoise.ar(0.008), 12000), 2400);
	OffsetOut.ar(0, Pan2.ar(sig * env, LFNoise0.kr(1, 1, 0)));
}).add;

~bassSys = (

	proto: ~instrument,
	bass1_new: {arg self, pattern;

		var ptrn = (
			instrument: \snd1,
			dur: Prand( (0.5!8) ++ (0.25!8) ++ [Pseq([0.125, 0.125], 1)] , inf)
		);

		if (pattern.isNil.not) {
			pattern.keysValuesDo({arg key, value;
				ptrn.put(key, value);
			});
		};
		self.inst_new(ptrn, inf);
	}
);
);