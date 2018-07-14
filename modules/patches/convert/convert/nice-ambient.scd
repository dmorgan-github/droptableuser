(
SynthDef(\synth2, {

	var freq = \freq.kr(300);

	var trig = \trig.tr;

	var osc1 = {

		var noise = WhiteNoise.ar(0.1);
		var sig = Pluck.ar(noise, trig, freq.reciprocal, freq.reciprocal, 10, 0.05);
		sig;

	}.value;

	var sig = osc1;

	var fx = {arg sig;

		sig = FbC({arg fb;
			sig + fb * 0.8

		}, 0.2);

		sig = LPF.ar(sig.tanh, SinOsc.kr(0.05).range(660, 880));

		JPverb.ar(sig);

	}.value(sig);

	fx = fx.distort;

	fx = GVerb.ar(fx, 300, taillevel: 2);

	fx = RLPF.ar(fx, SinOsc.kr(0.05).range(660, 1200), 0.5).tanh;

	fx = JPverb.ar(fx);

	sig = Splay.ar(fx) * \amp.kr(0.1);

	Out.ar(\out.kr(0), sig);

}).add;

)

~synth2 = App.monoDevice(\synth2);
(~synth2.pattern.set(\delta, 0.125, \degree, Place([ [0, 2], [-3,1,4,1] ], inf), \octave, 4, \amp, 0.1 ));
~synth2.player.stop().play(quant:1.0)

~synth2.pattern.set(\scale, Scale.melodicMinor, \mtranspose, 0, \delta, 1, \octave, 4, \amp, 0.3)