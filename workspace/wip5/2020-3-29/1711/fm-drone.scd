
  +-+
  | |
  m-+
  |
c c

(
Ndef(\drone)[0] = {

	var freq = \freq.kr(['E1', 'B1'].namecps);

	var mod = {arg freq, index=1, ivel=1, idur=1, fb=0;
		var ieg = Env.circle([0, 1, 0], [idur, idur]).ar.linlin(0, 1, index, index * ivel);
		var sig = SinOscFB.ar(freq, fb) * ieg;
		sig;
	};

	var car = {arg freq, mod=0;
		var sig = SinOsc.ar(freq, mod.mod(2pi));
		sig;
	};

	var sig = [
		{
			var sig = Pulse.ar(freq, SinOsc.kr(1/19).range(0.3, 0.7));
			sig = MoogFF.ar(sig, SinOsc.kr(1/9).range(100, 200), 3);
			sig;
		}.() * 0.2,

		{
			var myfreq = freq * 2;
			var modfreq = myfreq * 2;
			var fb = SinOsc.ar(1/11).range(0.1, 0.4);
			car.(myfreq, mod.(modfreq, 2, 0.1, 2, fb:fb))
		}.() * 0.7
	];

	var aeg = Env.adsr(2).ar(gate:1);

	sig = Splay.ar(sig, 0);

	sig = sig * aeg;

	sig;
};
)

Ndef(\drone).filter(100, {arg in; AllpassC.ar(in, 1, 0.3, 7)}).set(\wet100, 0.8);
Ndef(\drone).filter(105, {arg in; PitchShift.ar(in, 2, 1.5, 0.01, 0.01)}).set(\wet105, 0.3);
Ndef(\drone).filter(110, {arg in; JPverb.ar(in, 5, 0, 5)}).set(\wet110, 0.8);

Ndef(\drone).play(vol:0.15);