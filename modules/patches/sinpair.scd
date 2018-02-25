/////////////////////////////////
// synth
(
~anasine = {arg freq = [432], amp = [0], func = {arg sig;sig};

	{
		var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		// try to model a more analog sound
		var sig = Mix.fill(4,{
			//between 1 +- 0.01
			var freqmult = 1+SinOsc.ar(LFNoise1.kr(rrand(0.25,0.5),4,5),pi.rand,0.01);
			SinOsc.ar(freq_in * (freqmult), pi.rand);
		});

		sig = sig + VarSaw.ar(freq_in, mul: LFDNoise3.kr(0.25).range(0.1,0.4) );

		sig = sig * AmpCompA.kr(freq_in) * \amp.kr(amp);

		Splay.ar(sig);
	}
};
)

/////////////////////////////////
// patch
~sinpair = ProxySpace.new(s);
~sinpair.quant = 1.0;

(~sinpair[\pairseq][0] = {
	var trig = \trig.tr;
	var freq = \freq.kr;
	var freq2 = \freq2.kr;
	[trig, freq, freq2];
})
(~sinpair[\pairseq][4] = \set -> Pbind(

	\trig, 1,

	\delta, 8,

	\degree, Pbrown(0, 5, 1, inf),

	\vrate, 0.003,
	\vrate2, 0.003,

	\mtranspose, 0,
	\gtranspose, 0,
	\ctranspose, 0,//Pstep(Pseq([0,2,-2], inf), Pseq([16], inf), inf),//0,
	\root, 0,
	\scale, Scale.kumoi,
	\stepsPerOctave, 12,

	\octave2, Prand([5, 6], inf),
	\degree2, Pkey(\degree) + (Prand([2, 3], inf) * Prand([-1,1], inf)),
	\freq2, Pfunc({arg evt;
		var note = (evt[\degree2] + evt[\mtranspose]).degreeToKey(evt[\scale], evt[\stepsPerOctave]);
		var midinote = ((note + evt[\gtranspose] + evt[\root])/ evt[\stepsPerOctave] + evt[\octave2]) * 12.0;
		var freq = (midinote + evt[\ctranspose]).midicps;
		freq;
	})
));

/////////////////////////////////
// 1
~sinpair[\sinpair1][0] = ~anasine.();
~sinpair[\sinpair1].set(\vdepth, 0.001, \vrate, 2, \vrateVar, 0.5, \vdepthVar, 0.5)

/////////////////////////////////
// 2
~sinpair[\sinpair2][0] = ~anasine.();
~sinpair[\sinpair2].set(\vdepth, 0.01, \vrate, 3, \vrateVar, 0.1, \vdepthVar, 0.3)

/////////////////////////////////
// trig
~sinpair[\pairtrig] = {~sinpair[\pairseq].kr[0]};

/////////////////////////////////
// env 1
(~sinpair[\pairenv1] = {
	var trig_in = ~sinpair[\pairtrig];
	var ts_in = 1;
	var atk_in = 2;
	var sus_in = 2;
	var rel_in = 1;
	var curve_in = -4;
	var ls_in = 1;
	var env = Env.linen(atk_in,sus_in,rel_in,curve:curve_in).kr(gate:trig_in, timeScale:ts_in, mul:ls_in);
	env;
})

/////////////////////////////////
// env 2
(~sinpair[\pairenv2] = {
	var trig_in = ~sinpair[\pairtrig];
	var ts_in = 1;
	var atk_in = 1;
	var sus_in = 1;
	var rel_in = 1;
	var curve_in = -4;
	var ls_in = 1;
	var env = Env.linen(atk_in,sus_in,rel_in,curve:curve_in).kr(gate:trig_in, timeScale:ts_in, mul:ls_in);
	env;
});

/////////////////////////////////
//
~sinpair[\pairfreq1] = {~sinpair[\pairseq].kr[1]}
~sinpair[\pairfreq2] = {~sinpair[\pairseq].kr[2]};

~sinpair[\sinpair1].set(\freq, ~sinpair[\pairfreq1], \amp, ~sinpair[\pairenv1]);
~sinpair[\sinpair2].set(\freq, ~sinpair[\pairfreq2], \amp, ~sinpair[\pairenv2]);

~sinpair[\mix][0] = {~sinpair[\sinpair1]};
~sinpair[\mix][1] = {~sinpair[\sinpair2]};

/////////////////////////////////
// fx
(~sinpair[\mix][4] = \filter -> {arg in;
	JPverb.ar(in, t60:10, size:5);
});
~sinpair[\mix].set(\wet4, 0.5);

/////////////////////////////////
// play
~sinpair[\mix].play
~sinpair[\mix].stop
~sinpair[\mix].vol = 0.1






