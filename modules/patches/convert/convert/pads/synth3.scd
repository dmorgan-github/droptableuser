(
SynthDef(\synth3, {

	var freq = Vibrato.ar( \freq.ar(300), 6, 0.01, 0.1 );

	var trig = \trig.tr;

	var osc1 = {

		var env = Env([0, 0,1,0], [0, 0.01,1], [ SinOsc.kr(0.01).range(-4,4) ]).kr(gate: trig, doneAction:2);
		var sig = SinOscFB.ar(freq, SinOsc.kr(0.1).range(0.5, 0.7) );
		sig * env;

	}.value;

	var sig = osc1;

	var fx = {

		var fb = FbC({arg fb;
			Limiter.ar(
				sig + XFade2.ar(fb,
				GrainIn.ar(1,
						Impulse.ar( SinOsc.kr(0.1).range(7.9, 9.9) ),
						0.1, (fb * 1.1).distort, mul:1.3),
					LFPulse.kr(0.4).range(-1,1)), 0.9) * 0.98
		}, 0.5 );

		GVerb.ar(fb, 250, taillevel: 2);

	}.value;

	sig = sig + fx;

	sig = Splay.ar(sig) * \amp.kr(0.1);

	Out.ar(\out.kr(0), sig);

}).add;
)


~synth3 = App.monoDevice(\synth3);
(~synth3.pattern.set(
	\freq, Pseq([
		Pseq(['d3', 'f3', 'g3#', 'B3'].namecps, 2),
		Pseq(['d3b', 'f3', 'g3#', 'B3b'].namecps, 2),
		//Pseq( (['c3', 'f3', 'g3#', 'B3b'].namemidi - 2).midicps, 2),
		//Pseq([ 'B2b', 'D3b', 'E3', 'G3'].namecps, 1)
	], inf),
	\trig, 1,
	\delta, Pseq([0.5, 0.5, 0.5, 6.5], inf),
	\amp, 0.015
	//\amp, 0.1
));
~synth3.player.stop().play(quant:1.0);
